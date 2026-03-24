# AI stack

Docker runs **Ollama**, **LobeChat**, and **SearXNG**. Home Manager (`./deploy.sh --ai`) installs **claude** and **opencode**, copies MCP/agents/commands from `ai-stack/` into `~/.config/` and `~/.claude/`.

## Install

1. **Docker:** `sudo systemctl enable --now docker` and add your user to the `docker` group, then **log out and back in** (or new login session) so `docker compose` works without sudo.
2. **GPU (optional):** For NVIDIA in Docker, install the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) and restart Docker. Without it, Ollama may still run on CPU.
3. **Deploy:** From the repo root: `./deploy.sh --ai`  
   - Needs **network** (npx / uv optional installers).  
   - Nix only includes **git-tracked** files in the flake—new files under `ai-stack/` must be committed or `home-manager` will fail to find them.
4. **Shell:** `exec zsh` (or open a new terminal) so `claude`, `opencode`, and `ai-up` are on `PATH`.
5. **Model:** `ollama-pull <name>` (or pull from LobeChat). Use a **tool-calling** coder model (e.g. `qwen2.5-coder`, `qwen3-coder`); tiny chat models often never invoke tools.

**After changing** `ai-stack/mcp/*` or agents: `./deploy.sh` or `home-manager switch`, then **restart** Claude Code / OpenCode.

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

**Optional installers:** `./deploy.sh --ai` runs `scripts/install-optional-agents.sh --all` (GSD, `code-review-graph`, `arxiv` CLI). Run that script alone with `--gsd` / `--code-review-graph` / `--arxiv` if you deploy without `--ai`.

**Formatters:** OpenCode bundles ruff/clang-format. Claude Code: `install-skill.py hooks python .` in a project.

```
ai-stack/
  agents/           claude/ + opencode/
  commands/
  mcp/
  scripts/
  skills/
  templates/
  docker-compose.yml
```
