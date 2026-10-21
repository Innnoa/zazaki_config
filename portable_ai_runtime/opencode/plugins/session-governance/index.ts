import { readFile, stat, writeFile, mkdir } from "node:fs/promises"
import { join, dirname } from "node:path"
import { Plugin } from "@opencode/plugin"

const GOVERNANCE_PATH_MARKERS = [
  "AGENTS.md",
  "CURRENT_TASK.md",
  "DECISIONS.md",
  "AI_GUIDE.md",
  "rules/ai/",
  "workflows/ai/",
  "references/ai/",
  "opencode.json",
  "plugins/session-governance",
  "templates/",
]

const MAX_GOVERNANCE_FILE_BYTES = 25_000 // oversized governance files are a smell
const MAX_GOVERNANCE_FILE_LINES = 350
const MAX_GOVERNANCE_LINE_CHARS = 500 // a single wall-of-text line is unnavigable

async function checkFileSize(filePath: string): Promise<string | null> {
  try {
    const stats = await stat(filePath)
    const lines = (await readFile(filePath, "utf8")).split("\n")
    const lineCount = lines.length
    const maxLineChars = lines.reduce((max: number, line: string) => Math.max(max, line.length), 0)
    if (
      stats.size > MAX_GOVERNANCE_FILE_BYTES ||
      lineCount > MAX_GOVERNANCE_FILE_LINES ||
      maxLineChars > MAX_GOVERNANCE_LINE_CHARS
    ) {
      return `governance file exceeds size limit (${lineCount} lines, ${(stats.size / 1024).toFixed(1)}KB, max line ${maxLineChars} chars). Split or trim before editing.`
    }
  } catch {
    // file does not exist — no size check needed
  }
  return null
}

async function safeRead(path: string): Promise<string> {
  try {
    return await readFile(path, "utf8")
  } catch {
    return ""
  }
}

function section(title: string, body: string): string {
  return `## ${title}\n${body.trim()}\n`
}

function shouldAskForGovernanceEdit(permission: {
  action: string
  resources: readonly string[]
  metadata?: Record<string, unknown>
}) {
  if (permission.action !== "edit") {
    return false
  }

  const targets = [...permission.resources]

  if (permission.metadata) {
    for (const value of Object.values(permission.metadata)) {
      if (typeof value === "string") {
        targets.push(value)
        continue
      }

      if (!Array.isArray(value)) {
        continue
      }

      for (const item of value) {
        if (typeof item === "string") {
          targets.push(item)
        }
      }
    }
  }

  return targets.some((target) =>
    GOVERNANCE_PATH_MARKERS.some((marker) => target.includes(marker)),
  )
}

export default Plugin.define({
  id: "session-governance",

  async setup(ctx) {
    const directory = ctx.location.directory
  // This plugin is an event-level runtime gate only.
  // It injects governance context during prompt assembly and compaction,
  // but it does not implement a token-count-based final-answer hard gate
  // because the current public plugin hook inputs do not expose reliable
  // context-usage/token-usage values for threshold enforcement.
  const agentsPath = join(directory, "AGENTS.md")
  const currentTaskPath = join(directory, "CURRENT_TASK.md")
  const decisionsPath = join(directory, "DECISIONS.md")
  const sessionBudgetPath = join(directory, "references", "ai", "session-budget-rules.md")

  const receiptPath = join(directory, "outputs", "runtime", "plugin-loaded-receipt.json")
  try {
    await mkdir(dirname(receiptPath), { recursive: true })
    await writeFile(
      receiptPath,
      JSON.stringify({ plugin: "session-governance", loadedAt: new Date().toISOString() }),
      "utf8",
    )
  } catch {
    // receipt is best-effort; do not block plugin initialization on I/O failure
  }

    await ctx.permission.hook("evaluate", async (event) => {
      // Escalate edits to core governance files so the user can confirm
      // before high-impact governance surfaces are modified.
      // Check title, pattern(s), and metadata because different host layers
      // expose slightly different permission payload shapes.
      if (!shouldAskForGovernanceEdit(event)) {
        return
      }

      // Hard-deny edits to oversized governance files.
      // Oversized rules files are a smell that violates "structure serves content"
      // and "references must be sparse" governance principles.
      if (event.effect === "allow") {
        const sizeErrs = (
          await Promise.all(event.resources.map((resource) => checkFileSize(resource)))
        ).filter((message): message is string => message !== null)
        const sizeErr = sizeErrs[0]
        if (sizeErr) {
          event.effect = "deny"
          event.message = sizeErr
          return
        }
        event.effect = "ask"
      }
    })

    await ctx.session.hook("context", async (event) => {
      const [agents, budgetRules] = await Promise.all([
        safeRead(agentsPath),
        safeRead(sessionBudgetPath),
      ])

      const contextBlocks: string[] = []

      if (agents) {
        contextBlocks.push(
          section(
            "Governance Shell",
            [
              "Re-read the governance entry for every new task.",
              "Do not inherit routing from the previous task.",
              "Before non-trivial completion claims, rerun closure and verification.",
              "When session context is at or above 100000 tokens, compress non-essential detail and warn the user to prepare a new session.",
              "When session context is at or above 150000 tokens, append the fixed Chinese new-session reminder to every final answer.",
            ].join("\n"),
          ),
        )
      }

      if (budgetRules) {
        contextBlocks.push(
          section(
            "Session Budget",
            [
              "100000 tokens = warning threshold.",
              "150000 tokens = hard reminder threshold.",
              "Do not claim there is a host-enforced runtime gate unless runtime evidence exists.",
            ].join("\n"),
          ),
        )
      }

      if (contextBlocks.length > 0) {
        event.system.unshift({ type: "text", text: contextBlocks.join("\n") })
      }
    })

    await ctx.session.hook("compaction", async (event) => {
      const [currentTask, decisions, budgetRules] = await Promise.all([
        safeRead(currentTaskPath),
        safeRead(decisionsPath),
        safeRead(sessionBudgetPath),
      ])

      const preserve: string[] = []

      if (currentTask) {
        preserve.push(section("Current Task", currentTask))
      }
      if (decisions) {
        preserve.push(section("Reusable Decisions", decisions))
      }
      if (budgetRules) {
        preserve.push(section("Session Budget Rules", budgetRules))
      }

      if (preserve.length > 0) {
        event.system.push({
          type: "text",
          text: [
            "# Governance Context To Preserve",
            "Preserve routing discipline, current task state, reusable decisions, and session budget rules across compaction.",
            ...preserve,
          ].join("\n\n"),
        })
      }
    })
  },
})
