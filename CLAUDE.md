# CodexPlusPlus

Rust workspace (edition 2024) + Tauri 2.x desktop manager app. Enhancement launcher for the Codex App — injects scripts via CDP without modifying Codex's original files.

## Quick Commands

- `cargo xcheck` — type-check all crates
- `cargo xtest` — run all tests (workspace)
- `cargo clippy --workspace` — lint
- `cd apps/codex-plus-manager && npm run dev` — manager frontend dev server
- `cd apps/codex-plus-manager && npm run build` — build manager frontend

## Architecture

| Crate/Path | Role |
|---|---|
| `crates/codex-plus-core` | Platform-agnostic business logic: CDP bridge, updater, script market, worktree, zed remote |
| `crates/codex-plus-data` | SQLite data layer — reads/writes Codex's `state_5.sqlite` |
| `apps/codex-plus-launcher` | Headless launcher binary (`codex-plus-plus`). Single-instance guard, CDP injection, provider sync |
| `apps/codex-plus-manager/src-tauri` | Tauri manager app — 50+ commands in `commands.rs` |
| `apps/codex-plus-manager/` (frontend) | React 19 + Tailwind CSS 4 + Vite 6 + TypeScript |
| `assets/inject/renderer-inject.js` | JS injected into Codex renderer via CDP `Page.addScriptToEvaluateOnNewDocument` |

## Key Data Flow

1. Launcher starts Codex with `--remote-debugging-port`
2. CDP HTTP `GET /json` discovers renderer targets
3. CDP WebSocket connects, calls `Runtime.addBinding` → creates bridge
4. Bridge routes requests (session delete, undo, export, etc.) via local TCP HTTP on port 57321
5. Direct SQLite access to `~/.codex/state_5.sqlite` for session data

## Conventions

- All async code uses tokio (multi-thread runtime)
- HTTP via reqwest with rustls-tls — no OpenSSL
- SQLite via rusqlite with `bundled` feature
- External requests MUST go through `codex_plus_core::http_client::proxied_client()` to respect system proxy
- Commit messages: `fix`/`feat`/`docs`/`refactor` + short description
- Cross-platform: Windows (x64) + macOS (x64/arm64) — avoid platform-specific code outside `windows_integration.rs` and `install/`

## Platform Notes

- Windows: uses `winapi` for window activation, `CREATE_NO_WINDOW`, NSIS installer
- macOS: uses `open` command, DMG packaging, app bundle creation
- System proxy: Windows registry + macOS `scutil --proxy`

## Testing

- ~250 tests across workspace members
- Integration tests in each crate's `tests/` directory
- Inline `#[cfg(test)]` modules in source files
- Run `cargo xtest` for full suite, `cargo test -p <crate-name>` for a single crate
