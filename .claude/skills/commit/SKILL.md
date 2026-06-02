---
name: commit
description: Create a well-formatted git commit following project conventions
disable-model-invocation: true
---

Create a git commit for the current changes following CodexPlusPlus conventions.

## Steps

1. Run `git status` and `git diff --staged` to understand what changed
2. If nothing is staged, run `git add` on the relevant files (never `git add -A`)
3. Draft a commit message using this format: `<type>: <short description>`
   - Types: `fix`, `feat`, `docs`, `refactor`, `test`, `chore`, `perf`
   - Keep the subject line under 72 characters
   - If the change is non-trivial, add a blank line then a body explaining WHY (not what)
4. Create the commit with `git commit -m "$(cat <<'EOF'
<message>
EOF
)"`
5. Show the result with `git log --oneline -1`

## Rules

- Never commit `.env`, credentials, secrets, or `target/`
- Never use `git add -A` or `git add .` — stage specific files only
- Never amend existing commits unless explicitly asked
- Never push unless explicitly asked
- If there are no changes, say so and stop
