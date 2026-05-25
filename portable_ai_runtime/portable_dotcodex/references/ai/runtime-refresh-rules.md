## Runtime Refresh Rules

Only record changes that affect actual runtime behavior, not ordinary documentation edits.

## Core Rule

- If a change only updates static governance text and does not alter a live tool, runtime prompt surface, loaded config, session state, or activation state, normal file verification is enough.
- If a change affects runtime-effective behavior, the task is not complete until the required refresh action happens and post-refresh evidence is collected.

## Runtime-Effective Change Types

### 1. Serena / language-server capability changes

- Examples: changing Serena language coverage, activation behavior, language-loading assumptions, or related runtime wiring.
- Required action: re-activate the project or restart the session if re-activation is insufficient.
- Required evidence: a fresh Serena query or project activation result that proves the target capability is now actually available.

### 2. OpenCode native LSP behavior changes

- Examples: changes whose truth depends on refreshed diagnostics, symbol queries, or LSP-backed editor/runtime state.
- Required action: refresh the relevant LSP-backed context or restart the session/tooling layer if needed.
- Required evidence: fresh diagnostics or explicit LSP-facing evidence gathered after the refresh.

### 3. MCP/runtime tool configuration changes

- Examples: changes to MCP availability, routing, or tool configuration that only become true after reload/restart.
- Required action: reload or restart the affected runtime surface.
- Required evidence: a fresh tool invocation or availability check after reload.

### 4. Agent prompt / runtime instruction surface changes

- Examples: changes to agent prompt files, runtime wrappers, or config surfaces that shape newly started agent behavior.
- Required action: start a fresh agent/session/path that actually consumes the updated prompt surface.
- Required evidence: fresh runtime output, dispatch behavior, or observed prompt-consumption result from the new run.

## Canonical Example

- Serena language support is the canonical case.
- Editing a file to say Serena supports a language is only a static edit.
- The change becomes delivery-true only after Serena is re-activated or the session is restarted, and a fresh Serena operation confirms that the language is actually loaded and usable.

## Reporting Format

- Change type:
- Why this is runtime-effective:
- Refresh action performed:
- Fresh post-refresh evidence:
- If no refresh was required, why the change was static-only:
