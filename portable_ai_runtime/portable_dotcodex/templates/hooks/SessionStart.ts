// SessionStart Hook Template
// Injects the root SKILL.md / AGENTS.md back into context after session lifecycle events.
//
// Trigger events:
//   - session.startup
//   - session.clear
//   - session.compact
//
// Responsibility boundary:
//   - Only re-injects the entry file into context.
//   - Does NOT auto-execute Always Read on behalf of the agent.
//   - Does NOT auto-run task closure or AAR.
//
// Usage: copy to plugins/<name>.ts and register in opencode.json#/plugin

import type { Plugin } from "@opencode-ai/plugin"
import { readFile } from "node:fs/promises"
import { join } from "node:path"

async function safeRead(path: string): Promise<string> {
  try { return await readFile(path, "utf8") } catch { return "" }
}

export const SessionStartPlugin: Plugin = async ({ directory }) => {
  const entryPath = join(directory, "AGENTS.md")

  return {
    "experimental.chat.system.transform": async (_input, output) => {
      const content = await safeRead(entryPath)
      if (content) {
        output.system.unshift(
          [
            "## Session Entry Reloaded",
            "The root governance entry has been re-injected after a session lifecycle event.",
            "Re-read AGENTS.md, re-match Common Tasks routing, and re-read the files listed under the matched route.",
            "",
            content,
          ].join("\n"),
        )
      }
    },
  }
}

export default SessionStartPlugin
