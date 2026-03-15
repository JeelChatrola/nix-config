---
description: Review staged or recent changes for bugs, style, and security issues
agent: plan
---

Review the current changes:

!`git diff --staged 2>/dev/null || git diff HEAD~1`

Check for:
1. **Bugs**: logic errors, off-by-ones, null/None handling, race conditions
2. **Security**: hardcoded secrets, injection, unsafe deserialization, shell=True
3. **Style**: run `ruff check` on changed .py files, `clang-tidy` on changed .cpp files
4. **Tests**: are changed functions covered? suggest test cases if not

Output:
- List issues by severity (critical > style)
- Include file:line for each
- Suggest minimal fix
- If clean, say so briefly
