#!/usr/bin/env bash
# Auto-test hook: runs relevant crate tests after Rust file edits
set -euo pipefail

input=$(cat)
file=$(echo "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)

if [[ -z "$file" || "$file" != *.rs ]]; then exit 0; fi

cd "$CLAUDE_CWD"

# Extract crate name from path (crates/codex-plus-core/src/foo.rs → codex-plus-core)
crate=""
if [[ "$file" =~ crates/([^/]+)/ ]]; then
  crate="${BASH_REMATCH[1]}"
elif [[ "$file" =~ apps/([^/]+)/ ]]; then
  crate="${BASH_REMATCH[1]}"
fi

if [[ -n "$crate" ]]; then
  cargo test -p "$crate" --quiet 2>&1 | tail -3
else
  cargo xcheck --quiet 2>&1 | tail -3
fi
