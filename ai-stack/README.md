# AI stack

Docker runs **Ollama**, **LobeChat**, and **SearXNG**. Home Manager (`./deploy.sh --ai`) installs **claude** and **opencode**, copies MCP/agents/commands from `ai-stack/` into `~/.config/` and `~/.claude/`.

## Install

1. **Docker:** `sudo systemctl enable --now docker` and add your user to the `docker` group, then **log out and back in** (or new login session) so `docker compose` works without sudo.
2. **GPU (optional):** For NVIDIA in Docker, install the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) and restart Docker. Without it, Ollama may still run on CPU.
3. **Deploy:** From the repo root: `./deploy.sh --ai`  
   - Needs **network** (npx / uv optional installers).  
   - Nix only includes **git-tracked** files in the flake—new files under `ai-stack/` must be committed or `home-manager` will fail to find them.  
   - With `--ai`, after Docker starts Ollama, **`sync-opencode-ollama-models.sh`** rebuilds **`provider.ollama.models`** from **`/api/tags`** (1:1 with `ollama list`; drops pulled-but-removed models; keeps your `name` for tags that remain). If the file changes, deploy runs **home-manager** a second time so `~/.config/opencode/opencode.json` matches. Requires **`jq`** on the host; if Ollama is not up yet, sync is skipped (no error). Manual sync: `bash ai-stack/scripts/sync-opencode-ollama-models.sh`
4. **Shell:** `exec zsh` (or open a new terminal) so `claude`, `opencode`, and `ai-up` are on `PATH`.
5. **Models:** Install per machine (not scripted in this repo). With Docker Ollama, use **`ollama-pull <tag>`** / **`ai-ollama …`** from your zsh aliases (host CLI optional), **`docker exec ollama ollama pull …`**, or the Lobe UI. Point OpenCode / Claude at tags that exist in **`ollama list`**. Prefer **tool-calling** coder models for agents; small chat-only weights often skip tools.

**After changing** `ai-stack/mcp/*` or agents: `./deploy.sh` or `home-manager switch`, then **restart** Claude Code / OpenCode.

## API keys (optional)

Nothing is required for **local Ollama only**. Add keys only for the features below.

| Credential | For | Where to set |
|------------|-----|----------------|
| **`ANTHROPIC_API_KEY`** | Claude Code talking to **Anthropic’s API** instead of local Ollama | Your shell (e.g. Nix `home.sessionVariables`, direnv). This repo’s `ai-stack/mcp/claude-settings.json` sets `ANTHROPIC_BASE_URL` / `ANTHROPIC_AUTH_TOKEN` for Ollama; for cloud you must **override** those (e.g. `~/.config/claude/settings.local.json` merging `env`, or edit the source JSON in git) so traffic goes to Anthropic. See [Claude Code environment](https://code.claude.com/docs). |
| **Provider keys** (e.g. **`OPENAI_API_KEY`**, **`ANTHROPIC_API_KEY`**) | **OpenCode** cloud models | OpenCode `/connect` or provider setup; export in shell if the app reads env. `opencode.json` here only configures **Ollama**; add providers per [OpenCode config](https://opencode.ai/docs/config). |
| **`OPENAI_API_KEY`**, **`ANTHROPIC_API_KEY`**, etc. | **LobeChat** web UI with hosted models | `ai-stack/.env` (copy from `.env.example`), then `docker compose … up -d` again; finish provider setup in the Lobe UI if needed. |
| **—** | **searxng** MCP (web search + fetch) | **SearXNG** must be running (**`ai-up`**). Default host URL `http://127.0.0.1:8080` (**`SEARXNG_PORT`** in `ai-stack/.env`). If you change the port, update **`--searxng-url`** in `ai-stack/mcp/claude-settings.json`, **`opencode.json`** (`mcp.searxng.command`), and `mcpo-config.json`. **`uv tool install searxng-mcp-server`**: **`./deploy.sh --ai`** or **`install-optional-agents.sh --searxng-mcp`**. |
| **`HF_TOKEN`** | **Gated** Hugging Face models pulled into Ollama | `ai-stack/.env` (passed into the `ollama` service). |
| **`ALPHAXIV_API_KEY`** | **alphaxiv** skill (optional assistant features) | Shell env; see `skills/learning/alphaxiv/SKILL.md`. |

**No paid search API:** Web search for agents uses **SearXNG** + PyPI **`searxng-mcp-server`** (`uv tool install`, same script as arxiv/code-review-graph). **`memory`**, **`sequential-thinking`**, **`arxiv`**, **`code-review-graph`**, **`searxng`** MCP entries are declared in `ai-stack/mcp/*`.

## Day-to-day

| Action | Command / URL |
|--------|----------------|
| Start / stop stack | `ai-up` / `ai-down` (or `docker compose -f ai-stack/docker-compose.yml …`) |
| CLI agents | `opencode`, `claude` |
| Chat UI | http://localhost:3210 |
| Ollama API | http://localhost:11434 |
| SearXNG (MCP + browser) | http://localhost:8080 (override with `SEARXNG_PORT` in `ai-stack/.env`) |

OpenCode: **Tab** = primary agents (Build, Plan, ask, debug). **`@docs`** = docs subagent.  
Claude Code: natural language or `/agents` for **ask** / **debug** / **docs**.

## If something breaks

- **Agent ignores tools:** Model likely not tool-capable; try another Ollama tag or a cloud model in OpenCode to confirm the stack.
- **SearXNG / search MCP errors:** Ensure **`ai-up`** (or compose) is running, **`searxng-mcp-server`** is installed (`uv tool install searxng-mcp-server` or `./deploy.sh --ai`), and the URL in MCP configs matches **`SEARXNG_PORT`** (default **8080** on the host).
- **MCP changes not visible:** Redeploy + fully quit and restart the agent.

## Scripts: machine-wide vs per repo

**Machine-wide** scripts change your **user environment** (home directory, global agent config) or this **nix-config** tree. **Per-repo** scripts copy files into a **project directory** you pass as the last argument (usually `.` for the current repo).

| Script | Scope | Role |
|--------|--------|------|
| `install-skill.py` | **Per repo** | Skills under `.cursor/skills/`, templates (`AGENTS.md`, `CLAUDE.md`), Claude Code hooks in that project’s `.claude/settings.json`. |
| `install-optional-agents.sh` | **User / global** | Third-party CLIs (uv) and GSD via npx into `~/.claude/` and `~/.config/opencode/`. |
| `sync-opencode-ollama-models.sh` | **This flake** | Rewrites `ai-stack/mcp/opencode.json` from local Ollama; then redeploy / `home-manager` to refresh `~/.config/opencode/`. |

### `install-skill.py` (per project)

Run from anywhere; point at your nix-config checkout (examples use `~/nix-config`). The **target** is the **repository root** you want to equip (often `.`).

- **`list`** — Skills under `ai-stack/skills/{generic,programming,learning,robotics}/` (each folder with `SKILL.md`), plus hook template names.
- **`install <skill> <target>`** — Copies that skill into `<target>/.cursor/skills/<skill>/`. Cursor, OpenCode, and Claude Code can read `.cursor/skills/`. Re-running replaces the skill directory.
- **`agents-md <target>`** — Installs `templates/AGENTS.md` as `<target>/AGENTS.md` (prompts before overwrite).
- **`claude-md <target>`** — Same for `templates/CLAUDE.md` → `<target>/CLAUDE.md`.
- **`hooks <type> <target>`** — `type` is `python`, `cpp`, or `mixed`. Merges the matching JSON from `templates/claude-hooks/` into **`<target>/.claude/settings.json`** (creates or updates; replaces the `hooks` key). OpenCode does not need this; it ships formatters.

Example for a project at `/path/to/myapp`:

```bash
python3 ~/nix-config/ai-stack/scripts/install-skill.py list
python3 ~/nix-config/ai-stack/scripts/install-skill.py install alphaxiv /path/to/myapp
python3 ~/nix-config/ai-stack/scripts/install-skill.py agents-md /path/to/myapp
python3 ~/nix-config/ai-stack/scripts/install-skill.py hooks python /path/to/myapp
```

Commit the new `.cursor/`, `AGENTS.md`, `CLAUDE.md`, or `.claude/` files in **that** repo if you want teammates or CI to see them.

### `install-optional-agents.sh` (user / global)

Not tied to a project directory. Run from `ai-stack/` or with the path to the script. **`./deploy.sh --ai`** runs **`--code-review-graph`**, **`--arxiv`**, and **`--searxng-mcp`** (uv tools expected by MCP entries in `ai-stack/mcp/`). **`--gsd`** installs [Get Shit Done](https://github.com/gsd-build/get-shit-done) into global Claude/OpenCode config via npx; use **`--all`** for everything. See `--help` / script header for flags.

### `sync-opencode-ollama-models.sh` (nix-config file)

Updates **`ai-stack/mcp/opencode.json`** only. Invoked automatically after Docker Ollama starts when using **`./deploy.sh --ai`**, or run manually when Ollama is up. Does not write into arbitrary repos.

## Reference

**Configs in git:** `ai-stack/mcp/` → `~/.config/claude/settings.json`, `~/.config/opencode/opencode.json`. OpenCode reads MCP only from **`opencode.json`** (`mcp` + `type: "local"` + `command` array); see [OpenCode MCP docs](https://opencode.ai/docs/mcp-servers). Keep Claude (`mcpServers` in `claude-settings.json`) and OpenCode (`mcp` in `opencode.json`) aligned when you add a server.

**Commands:** `ai-stack/commands/` → `~/.claude/commands/` and `~/.config/opencode/commands/`.

**Agents:** `ai-stack/agents/claude/` and `agents/opencode/` (same roles; format differs per product).

**Skills (source):** `ai-stack/skills/{generic,programming,learning,robotics}/` — install into a project with `install-skill.py` (see above) or your agent’s `/setup-project` flow if you use it.

```
ai-stack/
  agents/
  commands/
  mcp/
  scripts/          install-skill.py, install-optional-agents.sh, sync-opencode-ollama-models.sh
  skills/
  templates/        AGENTS.md, CLAUDE.md, claude-hooks/
  docker-compose.yml
```
