import { writeFileSync, appendFileSync } from "node:fs"
import { join } from "node:path"
import { spawn } from "node:child_process"

const LOG = "outputs/runtime/notif-debug.log"

function log(dir, msg) {
  appendFileSync(join(dir, LOG), JSON.stringify({ time: Date.now(), msg }) + "\n")
}

function run(dir, cmd, args) {
  return new Promise((resolve) => {
    const p = spawn(cmd, args, { stdio: "ignore", detached: true })
    p.on("close", (code) => {
      log(dir, `spawn: ${cmd} ${args[0]} exit=${code}`)
      resolve(code)
    })
    p.on("error", (err) => {
      log(dir, `spawn error: ${cmd} ${err.message}`)
      resolve(-1)
    })
    p.unref()
  })
}

function esc(s) {
  return s.replace(/'/g, "''")
}

function psCmd(title, body, icon) {
  return [
    "-WindowStyle", "Hidden", "-Command",
    `Add-Type -AssemblyName System.Windows.Forms; $n=New-Object System.Windows.Forms.NotifyIcon; $n.Icon=[System.Drawing.SystemIcons]::${icon || "Information"}; $n.BalloonTipTitle='${esc(title)}'; $n.BalloonTipText='${esc(body)}'; $n.BalloonTipIcon='${icon || "Info"}'; $n.Visible=$true; $n.ShowBalloonTip(8000); Start-Sleep 9; $n.Dispose()`
  ]
}

let timer = null
let lastCompletionTime = 0
let lastTaskTitle = ""
let lastTaskSummary = ""
let mainSessionID = ""

export async function NotificationPlugin({ directory }) {
  writeFileSync(join(directory, "outputs/runtime/notif-loaded.txt"), "v5 loaded at " + new Date().toISOString())
  log(directory, "plugin init")

  return {
    event: async ({ event }) => {
      const sid = event.properties?.sessionID
      if (!sid) return

      if (!mainSessionID && event.type === "session.updated") {
        mainSessionID = sid
        log(directory, `main session: ${sid.slice(-20)}`)
      }

      if (sid !== mainSessionID) return

      // --- task info ---
      if (event.type === "session.updated") {
        const info = event.properties?.info
        if (info?.title) {
          lastTaskTitle = info.title
          const s = info.summary
          if (s && (s.additions || s.deletions || s.files)) {
            lastTaskSummary = `修改 ${s.files || 0} 个文件，+${s.additions || 0}/-${s.deletions || 0} 行`
          }
        }
        return
      }

      // --- completion ---
      if (event.type === "session.status") {
        if (event.properties?.status?.type === "idle") {
          if (timer) clearTimeout(timer)
          const now = Date.now()
          if (now - lastCompletionTime < 15000) return
          lastCompletionTime = now
          run(directory, "powershell.exe", psCmd(lastTaskTitle || "OpenCode", lastTaskSummary || "回复已完成", "Information"))
        }
        return
      }

      if (event.type === "session.idle") {
        if (timer) clearTimeout(timer)
        run(directory, "powershell.exe", psCmd(lastTaskTitle || "OpenCode", lastTaskSummary || "回复已完成", "Information"))
        return
      }

      // --- permission request ---
      if (event.type === "permission.updated") {
        const perm = event.properties
        const title = `权限请求: ${perm.type || ""}`
        const detail = perm.title || perm.pattern || ""
        const body = detail || "需要你的确认"
        log(directory, `PERM: ${title} | ${body}`)
        run(directory, "powershell.exe", psCmd(title, body, "Warning"))
        return
      }
    },
  }
}

export const server = NotificationPlugin
export default NotificationPlugin
