---
name: ansible-ssh-deployment
description: Use when deploying or operating Linux servers with Ansible, SSH, containers, configuration templates, backups, restore jobs, cron, or systemd timers; especially when hosts differ in architecture, Python, service API, or offline-network constraints.
---

# Ansible / SSH 运维部署

## Overview

把部署当成“受约束的状态收敛”，而不是一次性远程脚本。先确认控制端、目标端和运行时版本，再用单一事实源、可重复任务和证据闭环推进。该能力补充项目自身的 `AGENTS.md`、运行手册和用户要求；发生冲突时以更具体的 project-specific 约束为准。

## When to Use

适用：

- Ansible inventory、`group_vars`、roles、playbook、SSH 批量部署或巡检
- Linux 服务、Docker/Compose、离线镜像 runner、NAS/NFS、配置模板
- 配置采集/备份、归档保留、cron 或 systemd timer

不适用：普通应用代码修改、只读文档问答，或已有项目流程明确禁止自动化的任务。

## Deployment Order

1. **侦察**：先读项目规则和现状；记录控制机/目标机 OS、架构、Python、Docker/API、网络、权限、磁盘和可用命令。不要凭记忆假定版本。
2. **锁定兼容性**：明确 `version compatibility`，锁定最窄的 Ansible/collection/镜像版本。若目标 Python 较旧，使用经过验证的 runner；在真实部署前检查 `ansible --version`、`ansible-playbook --version`、架构、模块解析和容器入口。
3. **建立 SSH**：优先密钥认证。创建密钥目录 `0700`、私钥 `0600`、公钥 `0644`；用 `ssh -o BatchMode=yes` 逐主机验证，不把密码放命令行、变量输出或日志。容器 runner 中将项目密钥目录只读挂载到 `/root/.ssh`，除非项目明确需要 agent 转发。
4. **单一事实源**：用 inventory/`group_vars` 或一个结构化 JSON/YAML 配置管理主机和参数；模板（如 `*.example`、`*.bak`）只读，工作副本单独维护。部署前拒绝空值、占位符、重复主机和非法角色。
5. **分层收敛**：按 `base → storage/network → images → config → firewall → service → verify` 或项目等价阶段执行；组件和阶段使用 tags。先 `--check`/dry-run、syntax check、`--list-tags`/`--list-tasks`，再执行变更。任务应幂等（idempotent），中断后能重跑；以第二次运行 `changed=0` 或等价状态证据验证。
6. **传输选择**：目标没有 rsync 且大文件需要离线分发时，可采用 tar-over-SSH；同步时排除目标机本地配置和 secrets，避免控制端模板覆盖现场事实。不要把该策略当成所有场景的默认答案。

## Backup / Collection Pattern

- 动态 inventory 先校验配置根对象、启用状态、主机 ID、用户、端口和私钥路径；同一主机只生成一次。
- 采集前定义 `allowed source roots`，禁止根目录 `/`；逐文件拒绝 `..`、越界路径和非绝对路径。
- 远端先写 `staging`，记录 manifest/metadata；必备文件失败则最终失败，可选文件失败须明确记录，不能静默吞掉。
- 归档先写隐藏的 `.part`，比较远端与目标端大小和 **SHA-256**，通过后再 `mv` 为正式文件。发布成功后才按 retention 清理旧归档；失败时保留可诊断的中间产物。
- cron/systemd 命令使用绝对路径、固定工作目录、明确环境和日志重定向；手工先跑同一命令并检查输出、退出码和目标产物。

## Verification Gate

```text
preflight → syntax/check mode → SSH/module probe → staged apply
→ second-run idempotency → service/API/文件校验 → acceptance evidence
```

部署后至少检查目标服务状态、端口/API、挂载、容器/定时器、生成文件权限和关键日志。只读 `verify` playbook 的查询任务应标记 `changed_when: false`。不能用“playbook 返回 0”替代业务就绪、跨节点一致性或备份校验和证据。

## Common Mistakes

| 问题 | 修正 |
|---|---|
| 只在控制机测版本 | 同时验证 runner 架构、目标 Python 和服务 API |
| 以为 `docker compose` 等于 `docker-compose` | 按实际调用方检查并在 preflight 明确断言 |
| 直接覆盖已有配置 | 默认拒绝覆盖，显式确认后才允许，并先备份 |
| 用 `shell` 拼接未校验路径 | 白名单、转义、断言；不把用户数据直接拼进命令 |
| `.part` 未校验就发布或先清理旧备份 | 先大小 + SHA-256，再原子改名，最后清理 |
| 把密码、私钥、真实地址写进模板或输出 | 使用环境/secret 管理，最小权限，日志脱敏 |
| 把静态检查当成已完成 | 明确哪些只读、哪些真实执行，补目标端 acceptance evidence |

## Minimal Template

```yaml
- name: Apply service configuration
  hosts: app
  serial: "{{ rollout_batch | default(1) }}"
  become: true
  tasks:
    - name: Reject unresolved configuration
      ansible.builtin.assert:
        that: service_version is defined and service_version != 'CHANGE_ME'
    - name: Render configuration
      ansible.builtin.template:
        src: service.conf.j2
        dest: /etc/example/service.conf
        mode: "0640"
      notify: Restart service
  handlers:
    - name: Restart service
      ansible.builtin.service:
        name: example
        state: restarted
```

先替换 inventory、变量、路径、权限和验证命令，再运行 syntax check；不要把此片段直接用于生产。
