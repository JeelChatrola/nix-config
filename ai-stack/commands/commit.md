---
description: Stage, commit, and optionally push changes with a conventional commit message
---

Review the current changes:

!`git status`
!`git diff --staged`
!`git diff`

Write a conventional commit message:
- Format: `type(scope): summary` (max 50 chars for subject)
- Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore
- Body: explain *why*, not *what* (the diff shows what)
- If there are unstaged changes, ask which to include

Stage the relevant files and commit.

If $ARGUMENTS contains "push", also `git push`.
If $ARGUMENTS contains "pr", push and create a PR with `gh pr create --fill`.
