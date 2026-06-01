#!/usr/bin/env bash
# Auto-format hook: runs after Edit/Write tool use
# Formats .rs files with cargo fmt, .ts/.tsx with prettier
set -euo pipefail

input=$(cat)
file=$(echo "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)

if [[ -z "$file" ]]; then exit 0; fi

case "$file" in
  *.rs)
    cd "$CLAUDE_CWD" && cargo fmt --quiet 2>/dev/null || true
    ;;
  *.ts|*.tsx)
    manager_dir="$CLAUDE_CWD/apps/codex-plus-manager"
    if [[ -f "$manager_dir/package.json" ]]; then
      cd "$manager_dir" && npx prettier --write "$file" 2>/dev/null || true
    fi
    ;;
esac
