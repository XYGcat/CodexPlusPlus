# CodexPlusPlus 功能说明

## 核心定位

CodexPlusPlus 是 Codex App 的外部增强注入器。通过 CDP（Chrome DevTools Protocol）往 Codex 的 Chromium 渲染器注入 JavaScript，实现原版 Codex 不具备的功能。**不修改 Codex 原始文件**。

---

## 增强功能

通过管理工具的"页面增强"菜单统一开关，默认开启。关闭后不会注入 Codex++ 菜单和脚本。

### 插件入口解锁

解除 Codex 对第三方插件的安装限制，允许安装未在官方列表中的插件。

### 强制安装插件

自动安装未签名或未经 Codex 官方验证的插件。

### 模型白名单解锁

解锁 Codex 限制的模型列表，允许使用未在默认白名单中的模型。

### 会话删除

Codex 原版不支持删除本地会话。此功能通过直接操作 SQLite（`~/.codex/state_5.sqlite`）实现会话删除，支持撤销（先备份再删除）。

### Markdown 导出

将 Codex 对话的 rollout NDJSON 文件转换为格式化的 Markdown 文档并保存到本地。

### 项目迁移

将 Codex 会话的工作目录（cwd）迁移到其他路径，方便在不同项目间整理会话。

### 对话时间线

在 Codex 对话右侧显示时间轴导航条，可快速跳转到对话的不同节点。

### 对话视图

对话视图增强，改善 Codex 的对话展示体验。

### 滚动恢复

切换会话后自动恢复之前的滚动位置，避免每次切换都要重新滚动到底部。

### Zed 远程打开

在 Zed 编辑器中远程打开 Codex 对话中涉及的文件，支持 SSH 远程开发场景。

### Worktree 创建

从上游分支创建 git worktree，支持自动 fetch 远程分支，方便在隔离环境中处理不同分支的代码。

### 原生菜单位置

调整 Codex++ 注入菜单的显示位置，使其更符合原生 UI 风格。

### 服务等级控制

控制 Codex 的服务等级（Service Tier）选项。

---

## 脚本市场

从 GitHub 仓库（`BigPizzaV3/CodexPlusPlusScriptMarket`）浏览、安装、启用、禁用社区 JavaScript 脚本。

- 远程索引地址：`https://raw.githubusercontent.com/BigPizzaV3/CodexPlusPlusScriptMarket/main/index.json`
- 脚本通过 CDP `Page.addScriptToEvaluateOnNewDocument` 注入到 Codex 渲染器
- 本质是"用户脚本"（类似 Tamopermonkey），直接操作 Codex 的 DOM 和前端 UI
- 支持单个脚本的启用/禁用/删除，支持从市场一键安装

---

## 会话管理

通过管理工具的"会话管理"菜单操作 Codex 的本地会话数据：

- **列出会话**：读取 `~/.codex/state_5.sqlite`，展示所有本地会话（标题、工作目录、模型、更新时间等）
- **删除会话**：支持带撤销的删除（先创建 JSON 备份，再从 SQLite 删除）
- **Provider 同步**：读取 rollout NDJSON 文件，更新 SQLite 中的 provider 元数据

---

## 安装维护

### 入口点管理

检测、安装、修复 CodexPlusPlus 的快捷方式和入口点：
- 静默启动器快捷方式（`codex-plus-plus.exe`）
- 管理工具快捷方式（`codex-plus-plus-manager.exe`）

### Watcher（进程监控）

Codex 进程监控和自动重启：
- 安装/卸载 Watcher 服务
- 启用/禁用 Watcher
- Codex 崩溃或退出时自动重新启动

### 手动启动

支持自定义端口手动启动 Codex，用于调试或多实例场景。

---

## 自动更新

- 检查 GitHub Release 的 `latest.json` 获取最新版本信息
- 静默启动器发现新版本时自动拉起管理工具并显示更新提示
- 管理工具"关于"页面可手动检查更新并下载安装包
- Windows 生成 NSIS 安装程序，macOS 生成 DMG

---

## 诊断日志

- JSON-line 格式的诊断日志，记录所有关键操作（启动、bridge 请求、CDP 连接等）
- 日志路径：`~/.codex-session-delete/`
- 管理工具"关于"页面可查看最近日志和复制完整诊断报告

---

## 数据位置

| 路径 | 内容 |
|---|---|
| `~/.codex/config.toml` | Codex 配置文件 |
| `~/.codex/auth.json` | Codex 登录状态 |
| `~/.codex/state_5.sqlite` | Codex 本地会话数据库 |
| `~/.codex-session-delete/` | CodexPlusPlus 状态与日志 |
