// PreToolUse Gate Hook Template
// Intercepts edits to governance-critical files before they execute.
//
// Typical use: refuse oversized rule files, require AAR evidence before
// modifying core governance surfaces, enforce modification protocol.
//
// Responsibility boundary:
//   - Only blocks edits to files matching governance path markers.
//   - Does NOT replace agent-side self-discipline or routing.
//   - Does NOT auto-approve any edit.
//
// Usage: copy to plugins/<name>.ts and register in opencode.json#/plugin

import type { Plugin } from "@opencode-ai/plugin"
import { stat, readFile } from "node:fs/promises"

const GOVERNANCE_MARKERS = [
  "AGENTS.md",
  "rules/ai/",
  "workflows/ai/",
  "references/ai/",
  "opencode.json",
]

const MAX_FILE_BYTES = 15_000
const MAX_FILE_LINES = 350

function matchesGovernance(path: string): boolean {
  return GOVERNANCE_MARKERS.some((m) => path.includes(m))
}

async function checkSize(path: string): Promise<string | null> {
  try {
    const s = await stat(path)
    if (s.size > MAX_FILE_BYTES) {
      const lines = (await readFile(path, "utf8")).split("\n").length
      if (lines > MAX_FILE_LINES) {
        return `governance file too large: ${lines} lines / ${(s.size / 1024).toFixed(1)} KB. Split or trim first.`
      }
    }
  } catch { /* file does not exist */ }
  return null
}

export const PreToolUsePlugin: Plugin = async () => {
  return {
    "permission.ask": async (input, output) => {
      if (input.type !== "edit" || !matchesGovernance(input.title)) return

      if (output.status === "allow") {
        const err = await checkSize(input.title)
        if (err) {
          output.status = "deny"
          output.message = err
          return
        }
        // Escalate to ask: user must confirm governance edits.
        output.status = "ask"
      }
    },
  }
}

export default PreToolUsePlugin
