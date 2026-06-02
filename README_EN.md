# Codex++

<p align="center">
  <img src="docs/images/codex-plus-plus.png" alt="Codex++ Icon" width="160">
</p>

<p align="center">
  <a href="README.md">中文</a> | English
</p>

<p align="center">
  <img alt="Release" src="https://img.shields.io/github/v/release/BigPizzaV3/CodexPlusPlus">
  <img alt="Stars" src="https://img.shields.io/github/stars/BigPizzaV3/CodexPlusPlus">
  <img alt="License" src="https://img.shields.io/github/license/BigPizzaV3/CodexPlusPlus">
  <img alt="Rust" src="https://img.shields.io/badge/rust-1.85%2B-orange">
  <img alt="Tauri" src="https://img.shields.io/badge/tauri-2.x-24C8DB">
</p>

Codex++ is an external enhancement launcher and management tool for the Codex App. It does not modify Codex's original files — instead, it injects enhancement scripts via Chromium DevTools Protocol to add features that Codex does not natively support.

## Installation

Download the latest installer from [GitHub Releases](https://github.com/XYGcat/CodexPlusPlus/releases):

- Windows: `CodexPlusPlus-*-windows-x64-setup.exe`
- macOS Intel: `CodexPlusPlus-*-macos-x64.dmg`
- macOS Apple Silicon: `CodexPlusPlus-*-macos-arm64.dmg`

Two entry points are created after installation:

- **Codex++** — Silent launcher that starts Codex and injects enhancements, no UI
- **Codex++ Manager** — Tauri control panel for configuring enhancements, managing scripts, and checking updates

## Features

### Enhancements

Controlled via the "Page Enhancements" menu in the manager. Enabled by default; disabling stops all Codex++ menu and script injection.

| Feature | Description |
|---|---|
| Plugin Entry Unlock | Removes Codex's restriction on third-party plugin installation |
| Force Plugin Install | Auto-installs unsigned or unverified plugins |
| Session Delete | Adds delete support for local sessions (with undo) |
| Markdown Export | Exports conversations as Markdown files |
| Project Move | Migrates session working directories to other paths |
| Conversation Timeline | Adds a timeline navigation bar on the right side of conversations |
| Conversation View | Conversation view enhancements |
| Thread Scroll Restore | Restores scroll position when switching sessions |
| Zed Remote Open | Opens files in Zed editor from remote SSH contexts |
| Upstream Worktree | Creates git worktrees from upstream branches with auto-fetch |
| Native Menu Placement | Adjusts the Codex++ menu display position |
| Service Tier Controls | Controls Codex service tier options |

### Script Market

Browse, install, enable, and disable community JavaScript scripts from a GitHub repository. Scripts are injected into the Codex renderer via CDP to extend the UI and add custom features.

### Session Management

List and delete Codex local SQLite sessions, with provider sync support.

### Install & Maintenance

Detect/repair entry points and shortcuts, Watcher (auto-restart Codex on crash), manual launch with custom ports.

### Auto Update

GitHub Release update detection. The manager can download and install updates. The silent launcher automatically opens the manager when a new version is available.

## Codex++ Menu

After launching Codex, a `Codex++` menu appears in the top bar with two tabs:

- **Home** — Backend connection status, enhancement toggles, diagnostics
- **User Scripts** — Manage installed user scripts (enable/disable/reload)

## How It Works

```
codex-plus-plus.exe (launcher)
  ├─ Starts Helper TCP server (:57321)
  ├─ Starts Codex (with --remote-debugging-port)
  ├─ Connects to Codex renderer via CDP
  ├─ Runtime.addBinding → creates bridge function
  └─ Page.addScriptToEvaluateOnNewDocument → injects renderer-inject.js
```

Codex++ injects JavaScript into Codex's Chromium renderer via CDP to implement enhancements. No original Codex files are modified. See [docs/startup-flow.md](docs/startup-flow.md) for details.

## Data Locations

| Path | Content |
|---|---|
| `~/.codex/config.toml` | Codex configuration |
| `~/.codex/auth.json` | Codex login state |
| `~/.codex/state_5.sqlite` | Codex local session database |
| `~/.codex-session-delete/` | Codex++ status and logs |

## FAQ

### Codex++ menu not appearing

Make sure you launched from the `Codex++` entry point, not the original Codex. Check the manager's "About" page for logs.

### Plugin shows backend connection failure

Test the backend endpoint first:

```powershell
Invoke-RestMethod -Method Post -Uri http://127.0.0.1:57321/backend/status -Body "{}" -ContentType "application/json"
```

If the endpoint works but the plugin still times out, it's usually a CDP bridge or script cache issue. Restart Codex++ or check the manager logs.

### macOS says "cannot be opened" or "is damaged"

Unsigned/notarized installers are blocked by Gatekeeper. Run in terminal:

```bash
sudo xattr -rd com.apple.quarantine /Applications/Codex++\ Manager.app
sudo xattr -rd com.apple.quarantine /Applications/Codex++.app
```

## Development

```bash
# Frontend
cd apps/codex-plus-manager
npm install
npm run check       # TypeScript check
npm run vite:build   # Build frontend

# Rust
cargo xcheck         # Type check
cargo xtest          # Run tests
cargo build --release # Build release
```

Project structure:

```text
apps/
  codex-plus-launcher/          Silent launcher entry
  codex-plus-manager/           Tauri manager app
assets/inject/
  renderer-inject.js            JS injected into Codex renderer
crates/
  codex-plus-core/              Core logic: launch, inject, config, update, bridge
  codex-plus-data/              Session data, export, provider sync
scripts/installer/
  windows/CodexPlusPlus.nsi     Windows NSIS installer
  macos/package-dmg.sh          macOS DMG packaging
```

## Notes

Codex++ is an external enhancement tool that does not modify Codex App's original files. After a Codex App update, the injection script may need to be updated if the page structure changes.
