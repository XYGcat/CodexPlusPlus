---
name: pr-check
description: Run pre-PR validation checks (build, test, lint, clippy)
disable-model-invocation: true
---

Run all validation checks before opening a pull request. Reports pass/fail for each step.

## Steps

1. **Type check**: `cargo xcheck` — must pass
2. **Clippy lint**: `cargo clippy --workspace -- -D warnings` — must pass
3. **Tests**: `cargo xtest` — must pass
4. **Frontend build**: `cd apps/codex-plus-manager && npm run build` — must pass
5. **Diff summary**: Run `git diff main...HEAD --stat` and summarize what changed

## Output Format

Report each step as a checklist:

```
- [x] cargo xcheck — passed
- [x] cargo clippy — passed
- [ ] cargo xtest — FAILED (3 tests in codex-plus-core)
- [x] frontend build — passed
```

Then provide a 2-3 sentence summary of the changes suitable for a PR description.

## Rules

- Run all checks even if one fails — report the full picture
- Do NOT auto-fix failures — just report them
- If the branch has no changes vs main, say so and stop
