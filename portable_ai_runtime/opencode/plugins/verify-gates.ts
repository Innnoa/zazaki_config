import { readFile, stat, mkdir } from "node:fs/promises"
import { join, isAbsolute } from "node:path"
import { execFile } from "node:child_process"
import { promisify } from "node:util"
import type { Plugin } from "@opencode-ai/plugin"

const execFileAsync = promisify(execFile)

const VERIFY_TARGETS = [
  "opencode.json",
  "AGENTS.md",
  "CURRENT_TASK.md",
  "DECISIONS.md",
  "AI_GUIDE.md",
  "rules/ai/",
  "workflows/ai/",
  "references/ai/",
  "agents/",
  "plugins/",
]

const FRONTEND_EXTENSIONS = [".html", ".htm", ".tsx", ".jsx", ".vue", ".svelte", ".css", ".scss"]
const DEV_PORTS = [5173, 3000, 8080, 4321, 8000]
const DEFAULT_OUT_DIR = "outputs/screenshots"
const TARGET_CONFIG = "outputs/screenshots/target.json"

function shouldVerify(filePath: string): boolean {
  return VERIFY_TARGETS.some((marker) => filePath.includes(marker))
}

function isFrontendFile(filePath: string): boolean {
  const lower = filePath.toLowerCase()
  return FRONTEND_EXTENSIONS.some((ext) => lower.endsWith(ext))
}

function normalizePath(directory: string, filePath: string): string {
  if (isAbsolute(filePath)) return filePath
  // filePath is relative to the workspace; try both dir-relative and cwd-relative
  return filePath.startsWith(".") ? join(directory, filePath) : filePath
}

async function resolveScreenshotTarget(directory: string): Promise<{ url: string; outDir: string } | null> {
  // 1. Explicit config override: outputs/screenshots/target.json { "url": "...", "outDir": "..." }
  try {
    const raw = await readFile(join(directory, TARGET_CONFIG), "utf8")
    const cfg = JSON.parse(raw) as { url?: unknown; outDir?: unknown }
    if (typeof cfg.url === "string" && cfg.url) {
      return {
        url: cfg.url,
        outDir: typeof cfg.outDir === "string" ? cfg.outDir : DEFAULT_OUT_DIR,
      }
    }
  } catch {
    // no config or unparsable — fall through to port probing
  }

  // 2. Probe common dev-server ports
  for (const port of DEV_PORTS) {
    try {
      const ctrl = new AbortController()
      const timer = setTimeout(() => ctrl.abort(), 800)
      const res = await fetch(`http://localhost:${port}`, { signal: ctrl.signal })
      clearTimeout(timer)
      if (res.status < 500) {
        return { url: `http://localhost:${port}`, outDir: DEFAULT_OUT_DIR }
      }
    } catch {
      // port not live — try next
    }
  }
  return null
}

async function takeScreenshot(directory: string, url: string, outDir: string): Promise<string> {
  await mkdir(join(directory, outDir), { recursive: true })
  const ts = new Date().toISOString().replace(/[:.]/g, "-").slice(0, 19)
  const out = join(directory, outDir, `shot-${ts}.png`)
  await execFileAsync(
    "npx",
    ["-y", "playwright", "screenshot", "--viewport-size=1280,720", "--wait-for-timeout=1000", url, out],
    { timeout: 30000 },
  )
  return out
}

export const VerifyGatesPlugin: Plugin = async ({ directory }) => {
  return {
    "tool.execute.after": async (input, output) => {
      // Soft gate only: never throw, never deny. Append verification notes to output.
      if (input.tool !== "edit" && input.tool !== "write") return
      const filePath = input.args?.filePath ?? input.args?.path
      if (typeof filePath !== "string" || !filePath) return
      const target = normalizePath(directory, filePath)

      const notes: string[] = []

      // Branch A: governance/JSON verification (existing)
      if (shouldVerify(target)) {
        try {
          const stats = await stat(target)
          if (stats.isFile()) {
            // JSON files: validate parseable
            if (target.endsWith(".json") && !target.endsWith(".jsonc")) {
              const content = await readFile(target, "utf8")
              JSON.parse(content)
              notes.push(`[verify] JSON OK: ${target}`)
            }

            // Governance markdown files: size guard (mirror session-governance)
            if (target.endsWith(".md")) {
              const content = await readFile(target, "utf8")
              const lines = content.split("\n").length
              if (lines > 350) {
                notes.push(`[verify] WARN: ${target} has ${lines} lines (>350) — consider splitting`)
              } else {
                notes.push(`[verify] governance edit recorded: ${target}`)
              }
            }
          }
        } catch (err) {
          const message = err instanceof Error ? err.message : String(err)
          notes.push(`[verify] FAIL: ${target} — ${message}`)
        }
      }

      // Branch B: frontend file edited → auto screenshot when a dev server is reachable
      if (isFrontendFile(target)) {
        try {
          const sTarget = await resolveScreenshotTarget(directory)
          if (sTarget) {
            const shot = await takeScreenshot(directory, sTarget.url, sTarget.outDir)
            notes.push(`[screenshot] saved: ${shot}`)
          } else {
            notes.push(
              "[screenshot] skipped: no live dev server detected (5173/3000/8080/4321/8000) and no outputs/screenshots/target.json override",
            )
          }
        } catch (err) {
          const message = err instanceof Error ? err.message : String(err)
          notes.push(`[screenshot] FAIL: ${message}`)
        }
      }

      if (notes.length > 0) {
        output.output = (output.output ? output.output + "\n" : "") + notes.join("\n")
      }
    },
  }
}

export const server = VerifyGatesPlugin
export default VerifyGatesPlugin
