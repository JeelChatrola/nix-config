---
description: Detect project type and install appropriate skills and project config
agent: plan
---

Analyze this project to determine its type:

!`ls -la`
!`find . -maxdepth 2 \( -name "*.py" -o -name "CMakeLists.txt" -o -name "package.xml" -o -name "pyproject.toml" -o -name "requirements.txt" -o -name "Makefile" -o -name "*.cpp" -o -name "*.h" -o -name "Dockerfile" \) 2>/dev/null | head -30`

List available skills:
!`python3 ~/nix-config/ai-stack/scripts/install-skill.py list`

Based on what you find, recommend skills. Always include: tool-awareness, security-review, doc-awareness.
Add language-specific skills based on detected files.
Add robotics skills only if ROS markers are present.

Show what was detected and which skills you recommend. Ask the user to confirm, then install with explicit flags. Skills need **`--to cursor`**, **`--to opencode`**, and/or **`--to claude`** (repeat for multiple; first is the real directory, others symlink unless **`--copy-all`**).

```bash
# Templates + OpenCode agents only + skills (add --to claude if you want .claude/agents too)
python3 ~/nix-config/ai-stack/scripts/install-skill.py bootstrap -y --md --agents --to opencode --to cursor --skills <skill1> <skill2>
# Single skill
python3 ~/nix-config/ai-stack/scripts/install-skill.py i <skill-name> --to opencode
```

If only root docs are missing:

```bash
python3 ~/nix-config/ai-stack/scripts/install-skill.py agents-md .
```
