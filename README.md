# Codex++

<p align="center">
  <img src="docs/images/codex-plus-plus.png" alt="Codex++ 图标" width="160">
</p>

<p align="center">
  中文 | <a href="README_EN.md">English</a>
</p>

<p align="center">
  <img alt="Release" src="https://img.shields.io/github/v/release/BigPizzaV3/CodexPlusPlus">
  <img alt="Stars" src="https://img.shields.io/github/stars/BigPizzaV3/CodexPlusPlus">
  <img alt="License" src="https://img.shields.io/github/license/BigPizzaV3/CodexPlusPlus">
  <img alt="Rust" src="https://img.shields.io/badge/rust-1.85%2B-orange">
  <img alt="Tauri" src="https://img.shields.io/badge/tauri-2.x-24C8DB">
</p>

Codex++ 是面向 Codex App 的外部增强启动器和管理工具。不修改 Codex App 原始文件，通过 Chromium DevTools Protocol 注入增强脚本，为 Codex 补充原生不具备的功能。

## 安装

从 [GitHub Releases](https://github.com/XYGcat/CodexPlusPlus/releases) 下载最新版安装包：

- Windows：`CodexPlusPlus-*-windows-x64-setup.exe`
- macOS Intel：`CodexPlusPlus-*-macos-x64.dmg`
- macOS Apple Silicon：`CodexPlusPlus-*-macos-arm64.dmg`

安装后有两个入口：

- **Codex++** — 静默启动器，启动 Codex 并注入增强功能，不显示管理界面
- **Codex++ 管理工具** — Tauri 控制面板，用于配置增强功能、管理脚本、检查更新

## 功能

### 增强功能

通过管理工具的「页面增强」菜单统一开关，关闭后不会注入 Codex++ 菜单和脚本。

| 功能 | 说明 |
|---|---|
| 插件入口解锁 | 解除 Codex 对第三方插件的安装限制 |
| 强制安装插件 | 自动安装未签名或未验证的插件 |
| 会话删除 | Codex 原版不支持删除本地会话，此功能补上（支持撤销） |
| Markdown 导出 | 将对话导出为 Markdown 文件 |
| 项目迁移 | 将会话的工作目录迁移到其他路径 |
| 对话时间线 | 在对话右侧显示时间轴导航 |
| 对话视图 | 对话视图增强 |
| 滚动恢复 | 切换会话后恢复之前的滚动位置 |
| Zed 远程打开 | 在 Zed 编辑器中远程打开文件（支持 SSH 场景） |
| Worktree 创建 | 从上游分支创建 git worktree，自动 fetch 远程 |
| 原生菜单位置 | 调整 Codex++ 菜单的显示位置 |
| 服务等级控制 | 控制 Codex 的 Service Tier 选项 |

### 脚本市场

从 GitHub 仓库浏览、安装、启用、禁用社区 JavaScript 脚本。脚本通过 CDP 注入到 Codex 渲染器，可扩展 UI 和添加自定义功能。

### 会话管理

列出、删除 Codex 本地 SQLite 会话，支持 Provider 同步。

### 安装维护

检测/修复入口点和快捷方式、Watcher（Codex 崩溃自动重启）、自定义端口手动启动。

### 自动更新

GitHub Release 自动更新检测，管理工具可一键下载安装。静默启动器发现新版本时自动拉起管理工具提示更新。

## Codex++ 菜单

启动 Codex 后，顶部菜单栏出现 `Codex++` 菜单，包含两个 tab：

- **主页** — 后端连接状态、增强功能开关、诊断信息
- **用户脚本** — 管理已安装的用户脚本（启用/禁用/重新加载）

## 工作原理

```
codex-plus-plus.exe (启动器)
  ├─ 启动 Helper TCP 服务 (:57321)
  ├─ 启动 Codex（带 --remote-debugging-port）
  ├─ CDP 连接 Codex 渲染器
  ├─ Runtime.addBinding → 创建 bridge 函数
  └─ Page.addScriptToEvaluateOnNewDocument → 注入 renderer-inject.js
```

CodexPlusPlus 通过 CDP 往 Codex 的 Chromium 渲染器注入 JavaScript 实现增强，不修改 Codex 原始安装文件。详见 [docs/startup-flow.md](docs/startup-flow.md)。

## 数据位置

| 路径 | 内容 |
|---|---|
| `~/.codex/config.toml` | Codex 配置 |
| `~/.codex/auth.json` | Codex 登录状态 |
| `~/.codex/state_5.sqlite` | Codex 本地会话数据库 |
| `~/.codex-session-delete/` | Codex++ 状态与日志 |

## 常见问题

### Codex++ 菜单没出现

确认从 `Codex++` 入口启动，而不是原版 Codex。可打开管理工具的「关于」页查看日志。

### 插件内显示后端连不上

先测试后端接口：

```powershell
Invoke-RestMethod -Method Post -Uri http://127.0.0.1:57321/backend/status -Body "{}" -ContentType "application/json"
```

接口正常但插件仍超时，通常是 CDP bridge 或脚本缓存问题。重启 Codex++ 或在管理工具查看日志。

### macOS 提示无法打开或已损坏

未签名/未公证的安装包会被 Gatekeeper 拦截。终端执行：

```bash
sudo xattr -rd com.apple.quarantine /Applications/Codex++\ 管理工具.app
sudo xattr -rd com.apple.quarantine /Applications/Codex++.app
```

## 开发

```bash
# 前端
cd apps/codex-plus-manager
npm install
npm run check       # TypeScript 检查
npm run vite:build   # 构建前端

# Rust
cargo xcheck         # 类型检查
cargo xtest          # 运行测试
cargo build --release # 编译 release
```

项目结构：

```text
apps/
  codex-plus-launcher/          静默启动入口
  codex-plus-manager/           Tauri 管理工具
assets/inject/
  renderer-inject.js            注入到 Codex 渲染器的增强脚本
crates/
  codex-plus-core/              启动、注入、配置、更新、桥接等核心逻辑
  codex-plus-data/              会话数据、导出、Provider 同步
scripts/installer/
  windows/CodexPlusPlus.nsi     Windows NSIS 安装包
  macos/package-dmg.sh          macOS DMG 打包
```

## 说明

Codex++ 是外部增强工具，不修改 Codex App 原始文件。Codex App 更新后如果页面结构变化，可能需要更新注入脚本。
