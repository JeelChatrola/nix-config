# AI stack

Docker runs **Ollama**, **LobeChat**, and **SearXNG**. Home Manager (`./deploy.sh --ai`) installs **claude** and **opencode**, copies MCP/agents/commands from `ai-stack/` into `~/.config/` and `~/.claude/`.

## Install

1. **Docker:** `sudo systemctl enable --now docker` and add your user to the `docker` group, then **log out and back in** (or new login session) so `docker compose` works without sudo.
2. **GPU (optional):** For NVIDIA in Docker, install the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) and restart Docker. Without it, Ollama may still run on CPU.
3. **Deploy:** From the repo root: `./deploy.sh --ai`  
   - Needs **network** (npx / uv optional installers).  
   - Nix only includes **git-tracked** files in the flake—new files under `ai-stack/` must be committed or `home-manager` will fail to find them.
4. **Shell:** `exec zsh` (or open a new terminal) so `claude`, `opencode`, and `ai-up` are on `PATH`.
5. **Models:** Pull manually, from LobeChat, or use **`scripts/pull-models.sh`** with a YAML list (see below). Use **tool-calling** coder weights for agents (e.g. `qwen3-coder`); tiny chat-only models often never invoke tools.

**After changing** `ai-stack/mcp/*` or agents: `./deploy.sh` or `home-manager switch`, then **restart** Claude Code / OpenCode.

## Pull models from YAML

1. Copy `ai-stack/config/models.example.yaml` → `ai-stack/config/models.yaml` (the latter is gitignored).
2. Edit `models:` — each entry has `source`, `id`, and fields below.
3. Run from repo root or anywhere:

```bash
bash ai-stack/scripts/pull-models.sh
# or: MODEL_CONFIG=/path/to/custom.yaml bash ai-stack/scripts/pull-models.sh
# or: bash ai-stack/scripts/pull-models.sh --dry-run
```

**`source: ollama`** — `pull:` is passed to `ollama pull` (library tag or `hf.co/user/repo` if your Ollama supports it). Optional **`skip_if_present: true`** skips when `ollama list` already shows that name.

**`source: huggingface`** — default **`provider: llmfit`**: `repo:` is `user/GGUF-repo`, optional **`quant:`** (e.g. `Q4_K_M`); runs `llmfit download` (GGUF for llama.cpp — register in Ollama yourself via a Modelfile if needed). With **`provider: ollama`**, builds `hf.co/<repo>[:quant]` and runs `ollama pull`.

Needs **`yq`** and **`jq`** (Home Manager). For Docker Ollama, install the **`ollama`** CLI on the host and **`export OLLAMA_HOST=http://127.0.0.1:11434`**. Set **`HF_TOKEN`** when pulling gated HF content.

## API keys (optional)

Nothing is required for **local Ollama only**. Add keys only for the features below.

| Credential | For | Where to set |
|------------|-----|----------------|
| **`ANTHROPIC_API_KEY`** | Claude Code talking to **Anthropic’s API** instead of local Ollama | Your shell (e.g. Nix `home.sessionVariables`, direnv). This repo’s `ai-stack/mcp/claude-settings.json` sets `ANTHROPIC_BASE_URL` / `ANTHROPIC_AUTH_TOKEN` for Ollama; for cloud you must **override** those (e.g. `~/.config/claude/settings.local.json` merging `env`, or edit the source JSON in git) so traffic goes to Anthropic. See [Claude Code environment](https://code.claude.com/docs). |
| **Provider keys** (e.g. **`OPENAI_API_KEY`**, **`ANTHROPIC_API_KEY`**) | **OpenCode** cloud models | OpenCode `/connect` or provider setup; export in shell if the app reads env. `opencode.json` here only configures **Ollama**; add providers per [OpenCode config](https://opencode.ai/docs/config). |
| **`OPENAI_API_KEY`**, **`ANTHROPIC_API_KEY`**, etc. | **LobeChat** web UI with hosted models | `ai-stack/.env` (copy from `.env.example`), then `docker compose … up -d` again; finish provider setup in the Lobe UI if needed. |
| **`BRAVE_API_KEY`** | **brave-search** MCP (web search) | [Brave Search API](https://brave.com/search/api/) — export in the **same environment** that launches `claude` / `opencode` (MCP is stdio on the host). |
| **`HF_TOKEN`** | **Gated** Hugging Face models pulled into Ollama | `ai-stack/.env` (passed into the `ollama` service). |
| **`ALPHAXIV_API_KEY`** | **alphaxiv** skill (optional assistant features) | Shell env; see `skills/learning/alphaxiv/SKILL.md`. |

**No keys:** `memory`, `sequential-thinking`, `arxiv`, `code-review-graph` MCP servers as configured in this repo (arxiv/code-review-graph need `uv tool install` from `install-optional-agents.sh`, already run by `./deploy.sh --ai`).

## Day-to-day

| Action | Command / URL |
|--------|----------------|
| Start / stop stack | `ai-up` / `ai-down` (or `docker compose -f ai-stack/docker-compose.yml …`) |
| CLI agents | `opencode`, `claude` |
| Chat UI | http://localhost:3210 |
| Ollama API | http://localhost:11434 |
| Batch-pull models | `bash ai-stack/scripts/pull-models.sh` (YAML: `config/models.yaml`) |

OpenCode: **Tab** = primary agents (Build, Plan, ask, debug). **`@docs`** = docs subagent.  
Claude Code: natural language or `/agents` for **ask** / **debug** / **docs**.

## If something breaks

- **Agent ignores tools:** Model likely not tool-capable; try another Ollama tag or a cloud model in OpenCode to confirm the stack.
- **Brave search errors:** Set `BRAVE_API_KEY` or ignore that MCP server.
- **MCP changes not visible:** Redeploy + fully quit and restart the agent.

## Reference

**Configs in git:** `ai-stack/mcp/` → `~/.config/claude/settings.json`, `~/.config/opencode/mcp.toml`, `~/.config/opencode/opencode.json`. Keep Claude and OpenCode MCP lists aligned when you add a server.

**Commands:** `ai-stack/commands/` → `~/.claude/commands/` and `~/.config/opencode/commands/`.

**Agents:** `ai-stack/agents/claude/` and `agents/opencode/` (same roles; format differs per product).

**Skills:** Install into a repo with  
`python3 ~/nix-config/ai-stack/scripts/install-skill.py install <name> .`  
or use `/setup-project`. Categories under `skills/{generic,programming,learning,robotics}/`.

**Optional installers:** `./deploy.sh --ai` runs `install-optional-agents.sh --code-review-graph --arxiv` (uv tools used by this repo’s MCP). **GSD** (Get Shit Done) is **not** part of deploy — run `bash ai-stack/scripts/install-optional-agents.sh --gsd` or `--all` if you want it.

**Formatters:** OpenCode bundles ruff/clang-format. Claude Code: `install-skill.py hooks python .` in a project.

```
ai-stack/
  agents/
  commands/
  config/           models.example.yaml → copy to models.yaml (gitignored)
  mcp/
  scripts/          pull-models.sh, install-optional-agents.sh, install-skill.py
  skills/
  templates/
  docker-compose.yml
```
