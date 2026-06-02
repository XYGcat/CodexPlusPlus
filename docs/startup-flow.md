# CodexPlusPlus 启动流程

## 概述

`codex-plus-plus.exe`（静默启动器）是 CodexPlusPlus 的核心入口。它通过 CDP（Chrome DevTools Protocol）向 Codex 的 Chromium 渲染器注入增强脚本，**不修改 Codex 原始文件**。

## 启动流程

### 1. 单实例检测

绑定 TCP 端口（`LAUNCHER_GUARD_PORT`）作为单实例锁：
- **绑定成功** → 当前是唯一实例，继续启动
- **端口已占用** → 已有实例在运行，激活已有 Codex 窗口后退出
- **端口被残留进程占用** → 检测残留 launcher 进程，若判定为僵尸进程则强制终止后重试

### 2. 后台检查更新

异步请求 GitHub Release 的 `latest.json`：
- 有新版本 → 拉起管理工具（`codex-plus-plus-manager.exe`）并显示更新提示
- 无新版本 → 静默继续
- 此步骤不阻塞后续启动流程

### 3. 加载设置

从 `~/.codex/` 目录读取配置文件，获取：
- 增强功能开关（enhancementsEnabled）
- Provider 同步开关（providerSyncEnabled）
- Codex 启动额外参数（codexExtraArgs）
- Codex 安装路径（codexAppPath）

### 4. Provider 同步（可选）

仅当 `settings.providerSyncEnabled = true` 时执行：
- 读取 Codex 的 rollout NDJSON 文件
- 更新 SQLite（`state_5.sqlite`）中的 provider 元数据
- 用于在不同 API 供应商之间切换

### 5. 启动 Helper TCP 服务器

监听 `127.0.0.1:57321`，提供本地 HTTP 服务：
- 处理 bridge 请求（会话删除、撤销、导出、timeline 等）
- 作为 Codex 渲染器与 Rust 后端之间的通信桥梁
- 仅当增强功能启用时启动

### 6. 启动 Codex

以子进程方式启动 Codex App：
- 添加 `--remote-debugging-port={port}` 参数暴露 CDP 调试端口
- Windows 下使用 `CREATE_NO_WINDOW` 标志，不显示额外控制台窗口
- macOS 下使用 `open` 命令启动应用

### 7. CDP 连接

通过 CDP 协议发现并连接到 Codex 渲染器：

```
HTTP GET http://127.0.0.1:{debug_port}/json
→ 获取所有页面 target 列表
→ 找到 title 包含 "codex" 的页面 target
→ WebSocket 连接到该 target 的 ws:// 地址
```

### 8. 注入增强脚本

通过 CDP WebSocket 依次执行：

1. **`Runtime.addBinding`** — 创建 `__codexSessionDeleteBridge` 全局函数，供注入脚本调用 Rust 后端
2. **`Page.addScriptToEvaluateOnNewDocument`** — 注入 `renderer-inject.js`，这是 Codex++ 的核心 UI：
   - 添加 Codex++ 菜单面板（主页、用户脚本、请作者喝咖啡）
   - 实现增强功能（会话删除、Markdown 导出、项目迁移、Timeline、滚动恢复等）
   - 管理后端状态检测和连接
3. **注入用户脚本** — 从脚本市场安装的自定义 JS 脚本，合并为一个 bundle 注入

### 9. 启动 Bridge 看门狗

定期检查 CDP WebSocket 连接状态：
- 连接正常 → 继续监控
- 连接断开 → 自动重连并重新注入脚本
- Codex 页面刷新 → 重新注入（`addScriptToEvaluateOnNewDocument` 保证新页面也生效）

### 10. 写入启动状态

将启动结果写入状态文件，供管理工具的"概览"页面读取：
- 状态：`running` / `failed`
- 调试端口、Helper 端口
- Codex 安装路径
- 启动时间

### 11. 等待 Codex 退出

阻塞等待 Codex 进程结束：
- Codex 退出 → 清理 Helper TCP 服务器，launcher 进程退出
- launcher 退出时 Codex 也随之结束（watcher 可选自动重启）

## 数据流总览

```
codex-plus-plus.exe (launcher)
    │
    ├─ 启动 Helper TCP :57321 ─────────────────────────┐
    │                                                    │
    ├─ 启动 Codex (子进程)                              │
    │   └─ --remote-debugging-port=9229                  │
    │                                                    │
    ├─ CDP HTTP GET /json ──→ 发现 renderer target       │
    │                                                    │
    ├─ CDP WebSocket 连接                               │
    │   ├─ Runtime.addBinding ──→ 创建 bridge 函数       │
    │   └─ Page.addScriptToEvaluateOnNewDocument         │
    │       └─ 注入 renderer-inject.js                   │
    │           └─ Codex++ 菜单 + 增强功能               │
    │                                                    │
    └─ Bridge 看门狗（监控连接、自动重连）               │
                                                     │
    Codex 渲染器 ←──bridge 函数──→ Helper TCP :57321 ←┘
```

## 关键文件

| 文件 | 作用 |
|---|---|
| `apps/codex-plus-launcher/src/main.rs` | 启动器入口，单实例检测、参数解析 |
| `crates/codex-plus-core/src/launcher.rs` | 启动流程核心逻辑，launch_and_inject_with_hooks |
| `crates/codex-plus-core/src/cdp.rs` | CDP HTTP target 发现 |
| `crates/codex-plus-core/src/bridge.rs` | CDP WebSocket bridge 连接和通信 |
| `crates/codex-plus-core/src/routes.rs` | Bridge 请求路由分发 |
| `crates/codex-plus-core/src/ports.rs` | 端口管理和单实例锁 |
| `crates/codex-plus-core/src/watcher.rs` | 进程监控和自动重启 |
| `crates/codex-plus-core/src/assets.rs` | 注入脚本生成 |
| `assets/inject/renderer-inject.js` | 注入到 Codex 渲染器的 JS 增强脚本 |
