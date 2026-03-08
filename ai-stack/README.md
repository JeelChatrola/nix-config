# AI Stack

Docker-isolated local LLM services and web UIs, with AI coding agents running on
the host through Home Manager-managed wrappers.

## Services

| Service | URL | Purpose |
|---|---|---|
| **ollama** | http://localhost:11434 | Local LLM runner (GPU-accelerated) |
| **lobechat** | http://localhost:3210 | Chat UI with online search (client mode, data in browser) |
| **searxng** | internal only | Search backend for Lobe online search |

## Prerequisites

### 1. Docker daemon

Docker CLI is already in your Nix Home Manager config. The daemon must be
running on the host (managed by systemd, not Nix HM):

```bash
sudo systemctl enable --now docker
sudo usermod -aG docker jeel  # log out and back in after this
```

### 2. NVIDIA Container Toolkit (GPU access)

This is a **system-level** requirement (not Home Manager). On Ubuntu/Debian:

```bash
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

On **NixOS**, add to `configuration.nix`:
```nix
virtualisation.docker.enable = true;
hardware.nvidia-container-toolkit.enable = true;
```

## Usage

### Start the stack

```bash
ai-up
```

No bootstrap or secret generation needed. LobeChat runs in client mode: your
conversations and settings live in your browser's IndexedDB.

### Stop the stack

```bash
ai-down
```

### Pull a local model

```bash
ollama-pull llama3.2          # ~2 GB, fast
ollama-pull deepseek-coder-v2 # code-focused
ollama-run llama3.2           # quick interactive check
ollama-show llama3.2          # inspect model metadata
ollama-rm llama3.2            # remove a downloaded model
ollama-list                   # list downloaded models
```

The alias calls the running Ollama service from the host with `docker exec`.
Models persist in the `ollama-models` Docker volume.

If you prefer HTTP instead of `docker exec`, Ollama also exposes its API on
the host:

```bash
curl http://localhost:11434/api/pull -d '{"name":"qwen2.5-coder:14b"}'
curl http://localhost:11434/api/tags
```

### Use CLI agents on the host

```bash
home-manager switch --flake ~/nix-config#jeel

aider --model ollama/llama3.2
claude
opencode
```

### Use LobeChat with Ollama

Open `http://localhost:3210`. Ollama is pre-wired via `OLLAMA_PROXY_URL`.
Your local models appear automatically.

If you also add cloud provider keys to `ai-stack/.env`, Lobe can expose those
providers alongside your local models.

### Web search

SearXNG is bundled as the search backend. Lobe's online search works out of
the box with no API keys.

If you prefer a hosted provider later, override in `.env`:

```env
SEARCH_PROVIDERS=brave
BRAVE_API_KEY=BSA...
```

### View logs

```bash
ai-logs          # all services
ai-logs ollama   # single service
```

## Why agents run on the host

- agents can run your real compilers, debuggers, Python envs, and build tools
- no duplicated host-vs-container toolchain confusion
- file paths, SSH auth, git signing, and hardware tooling behave normally
- Docker is kept only for the parts that benefit most from isolation: models and web UIs

## MCP (Model Context Protocol)

MCP lets agents call external tools: read files, search the web, query databases, etc.

### How it's wired today

```
Claude Code / opencode (on the host)
    │
    │  model backend: Ollama @ http://localhost:11434
    │
    ├── stdio ──► npx @modelcontextprotocol/server-filesystem
    ├── stdio ──► npx @modelcontextprotocol/server-git
    ├── stdio ──► npx @modelcontextprotocol/server-fetch
    ├── stdio ──► npx @modelcontextprotocol/server-memory
    ├── stdio ──► npx @modelcontextprotocol/server-sequential-thinking
    ├── stdio ──► npx @modelcontextprotocol/server-brave-search
    ├── stdio ──► npx @modelcontextprotocol/server-github
    └── stdio ──► npx @modelcontextprotocol/server-time
```

Config files in `mcp/` and what Home Manager links them to:

| File | Destination | Purpose |
|---|---|---|
| `claude-settings.json` | `~/.config/claude/settings.json` | Claude Code MCP servers + Ollama env |
| `opencode.toml` | `~/.config/opencode/mcp.toml` | OpenCode MCP servers |
| `opencode.json` | `~/.config/opencode/opencode.json` | OpenCode Ollama provider + models |

### Switching between Ollama and Anthropic cloud

By default both Claude Code and OpenCode point at your local Ollama instance.
To use Anthropic's cloud API instead, override the env vars:

```bash
export ANTHROPIC_BASE_URL=https://api.anthropic.com
export ANTHROPIC_AUTH_TOKEN=sk-ant-...
claude
```

### Enable Brave Search / GitHub

```bash
# For host-side agents:
export BRAVE_API_KEY=BSA...
export GITHUB_TOKEN=ghp_...

# For Docker-side Lobe search:
# add BRAVE_API_KEY=BSA... to ai-stack/.env
# add SEARCH_PROVIDERS=brave to ai-stack/.env
```

## Robotics Layer

Robotics-focused guidance pack under `robotics/` without turning your AI setup
into a ROS image.

### What's included

- `robotics/README.md`: model and workflow guidance for ROS, C++, Python, and ML work
- `robotics/prompts/`: ready-to-paste prompts for workspace review, perception planning, and mixed C++ / Python debugging
- `skills/`: reference Cursor skill templates for robotics work
- `scripts/install-skill-template.sh`: copies a chosen template into a repo's `.cursor/skills/`

### Activate a skill in a real repo

```bash
~/nix-config/ai-stack/scripts/install-skill-template.sh ros-workspace-review ~/work/my-robot
```
