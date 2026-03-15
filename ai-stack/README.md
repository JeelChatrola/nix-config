# AI Stack

Local LLM services in Docker, AI coding agents on the host via Home Manager.

## Services

| Service | URL | Purpose |
|---|---|---|
| **ollama** | http://localhost:11434 | Local LLM runner (GPU) |
| **lobechat** | http://localhost:3210 | Chat UI with search |
| **searxng** | internal | Search backend for Lobe |

## Setup

```bash
# Docker daemon
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# NVIDIA Container Toolkit (Ubuntu/Debian)
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker && sudo systemctl restart docker

# Deploy
./deploy.sh --ai
```

## Usage

```bash
ai-up                              # start services
ai-down                            # stop
ollama-pull qwen2.5-coder:14b      # pull a model
opencode                           # recommended CLI agent
claude                             # if using Anthropic cloud API
```

LobeChat: http://localhost:3210

## MCP

Only servers that add capabilities beyond built-in agent tools:

| Server | Purpose |
|---|---|
| **memory** | Persistent knowledge graph across sessions |
| **brave-search** | Web search (`BRAVE_API_KEY` required) |
| **sequential-thinking** | Multi-step reasoning |

## Commands

Single set of commands, deployed to both `~/.claude/commands/` and
`~/.config/opencode/commands/` by Home Manager. Source in `commands/`.

| Command | Purpose |
|---|---|
| `/commit` | Conventional commit, optionally push/PR |
| `/review` | Review changes for bugs, security, style |
| `/setup-project` | Detect project type, install skills |

## Skills

18 skills organized by category. Installed to `.cursor/skills/`
(read by Cursor, OpenCode, and Claude Code).

```
skills/
  generic/          tool-awareness, security-review, repo-documenter, skill-selector
  programming/      python-standards, cpp-standards
  learning/         learning-mode, doc-awareness
  robotics/         ros2, ros1, robot-perception, robotics-testing, ... (submodule)
```

Robotics skills from [arpitg1304/robotics-agent-skills](https://github.com/arpitg1304/robotics-agent-skills) (git submodule).

### Install

```bash
python3 ~/nix-config/ai-stack/scripts/install-skill.py list
python3 ~/nix-config/ai-stack/scripts/install-skill.py install python-standards .
python3 ~/nix-config/ai-stack/scripts/install-skill.py install ros2 .
python3 ~/nix-config/ai-stack/scripts/install-skill.py agents-md .
```

Or run `/setup-project` in Claude Code or OpenCode.

## Formatters

**OpenCode**: Built-in ruff + clang-format (auto-detects from project config).

**Claude Code**: Per-repo hooks:
```bash
python3 ~/nix-config/ai-stack/scripts/install-skill.py hooks python .
```

## File Structure

```
ai-stack/
  commands/             Unified commands (deployed to both agents)
  mcp/                  MCP + permissions configs
  scripts/              install-skill.py
  skills/
    generic/            Always-useful skills
    programming/        Language-specific standards
    learning/           Teaching and doc-awareness
    robotics/           Submodule: robotics-agent-skills
  templates/            AGENTS.md, CLAUDE.md, claude-hooks/
  docker-compose.yml    Ollama + LobeChat + SearXNG
```
