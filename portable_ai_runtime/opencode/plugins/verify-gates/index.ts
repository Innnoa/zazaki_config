// verify-gates.ts — governance-file static verification plugin.
//
// Behavior:
//   - This plugin performs STATIC verification on governance files only:
//     (a) JSON files listed in VERIFY_TARGETS must parse; and
//     (b) governance markdown files over 350 lines get a size WARN.
//   - It NEVER captures browser images and NEVER probes local dev-server ports.
//     No browser automation, no npx invocation, no localhost fetches, no child_process.
//   - This behavior note is referenced by references/ai/governance-smoke-check.md.
//
// Soft gate only: notes are appended to the tool output; nothing is thrown or denied.

import { readFile, stat } from "node:fs/promises"
import { join, isAbsolute } from "node:path"
import { Plugin } from "@opencode/plugin"

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

function shouldVerify(filePath: string): boolean {
  return VERIFY_TARGETS.some((marker) => filePath.includes(marker))
}

function normalizePath(directory: string, filePath: string): string {
  if (isAbsolute(filePath)) return filePath
  // filePath is relative to the workspace; try both dir-relative and cwd-relative
  return filePath.startsWith(".") ? join(directory, filePath) : filePath
}

export default Plugin.define({
  id: "verify-gates",

  async setup(ctx) {
    const directory = ctx.location.directory

    await ctx.tool.hook("execute.after", async (event) => {
      // Soft gate only: never throw, never deny. Append verification notes to output.
      if (event.tool !== "edit" && event.tool !== "write") return
      const args = event.input as { filePath?: unknown; path?: unknown }
      const filePath = args.filePath ?? args.path
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

      if (notes.length > 0 && event.status === "completed") {
        const note = notes.join("\n")
        const content = event.result.content
        event.result = {
          ...event.result,
          content:
            typeof content === "string"
              ? `${content}${content ? "\n" : ""}${note}`
              : [...(content ?? []), { type: "text", text: note }],
        }
      }
    })
  },
})
