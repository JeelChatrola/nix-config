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

Show what was detected and which skills you recommend. Ask the user to confirm, then install each with:

```bash
python3 ~/nix-config/ai-stack/scripts/install-skill.py install <skill-name> .
```

Also check if an AGENTS.md or CLAUDE.md exists. If not, offer to create one:
```bash
python3 ~/nix-config/ai-stack/scripts/install-skill.py agents-md .
```
