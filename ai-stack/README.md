# AI stack

You can use this directory **without Nix**: install [Docker](https://docs.docker.com/engine/install/), `jq`, `yq`, `curl`, `uv`, Node/`npx`, Python 3, then run `bin/ai-stack doctor`, `bin/ai-stack sync`, and `bin/ai-stack up`. For user-level symlinks into `~/.config`, run `bin/ai-stack install`.

There are two layers:

1. **Agents / MCP / commands** (portable): templates in `config/*.template.json` and `config/hermes-mcp.template.yaml` render to `generated/` (gitignored). `bin/ai-stack sync` applies `stack-models.json`, merges generated Hermes MCP servers into `~/.hermes/config.yaml`, and syncs live Ollama tags. Optional: **Nix / home-manager** (flake output `*-ai`) installs `claude` / `opencode` / `hermes` wrappers, copies commands and agents from the flake, runs `ai-stack sync` on switch, and symlinks `~/.config/...` to `generated/*.json` under your checkout (`AI_STACK_DIR`). **Hermes** is `bin/hermes` (`nix run` from repo root `#hermes`, includes `messaging` for Discord/Telegram) or `install-optional-agents.sh --hermes` (`nix profile install` from the same flake output).
2. **Docker Compose**: Ollama, LobeChat, SearXNG, and an optional vLLM profile (OpenAI-compatible API on port 8000).

To deploy only the Home Manager side, set `AI_STACK_DOCKER=0` in `ai-stack/.env` or use `./deploy.sh --ai --no-docker`. `./deploy.sh --ai` still runs `bin/ai-stack sync` first so `generated/` exists before `home-manager switch`. Use `ai-up` when you want the containers. You can add services in `docker-compose.yml`; the same Docker on/off switch applies to the whole stack from deploy.

## Install

1. **Docker:** `sudo systemctl enable --now docker` and add your user to the `docker` group, then log out and back in (or start a new login session) so `docker compose` works without `sudo`.
2. **GPU (optional):** For NVIDIA in Docker, install the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) and restart Docker. Without it, Ollama may still run on CPU.
3. **Deploy:** From the repo root:

   ```bash
   ./deploy.sh --ai
   ```

   Optional: `--no-docker` or `AI_STACK_DOCKER=0` in `ai-stack/.env` to skip Compose (Home Manager + `bin/ai-stack sync` still run).

   - Needs network (npx / uv installers).
   - Nix only sees git-tracked files in the flake: new files under `ai-stack/` must be committed or home-manager cannot reference them for commands/agents.
   - `stack-models.json` is the source of truth for Ollama tags to pull (`ollama.pull[]`) and optional Hugging Face id for vLLM (`vllm.*`). `scripts/apply-stack-models.sh` writes `models.compose.env` (gitignored; for `docker compose --env-file`) and updates `provider.vllm` in `generated/opencode.json` when `vllm.model` is set. Omit the whole `vllm` object for Ollama-only. `bin/ai-stack sync` / `./deploy.sh --ai` refresh `generated/`; `ai-up` runs `bin/ai-stack up` (sync, compose, apply with pull when Ollama is up, then Ollama tag sync).
   - After Docker starts Ollama, `sync-opencode-ollama-models.sh` rebuilds `provider.ollama.models` in `generated/opencode.json` from `/api/tags`. If that file changes, `./deploy.sh --ai` runs `home-manager switch` again. Requires `jq` on the host; if Ollama is not up yet, sync is skipped without error.

4. **Shell:** `exec zsh` or open a new terminal so `claude`, `opencode`, and `ai-up` are on PATH.

5. **Models:** Edit `stack-models.json`: add Ollama tags to `ollama.pull` and optionally set `vllm.model` (and `vllm.image_tag`, `max_model_len`, etc.). Run `bin/ai-stack sync` or `bash ai-stack/scripts/apply-stack-models.sh` or use `ai-up` / `./deploy.sh --ai`. Ad-hoc: `ollama-pull <tag>`. Prefer tool-calling coder models for agents; small chat-only weights often skip tools.

After changing `ai-stack/config/*.template.json`, `ai-stack/config/hermes-mcp.template.yaml`, or agents: `bin/ai-stack sync` and restart Claude Code / OpenCode. In Hermes, run `/reload-mcp` or restart the chat.

## API keys (optional)

Nothing is required for local Ollama only. Add keys only for the features below.

| Credential | For | Where to set |
|------------|-----|--------------|
| `ANTHROPIC_API_KEY` | Claude Code via Anthropic API instead of local Ollama | Shell (e.g. `home.sessionVariables`, direnv). Templates set `ANTHROPIC_BASE_URL` / `ANTHROPIC_AUTH_TOKEN` for Ollama in `generated/claude-settings.json`; for cloud override (e.g. `~/.config/claude/settings.local.json`). See [Claude Code environment](https://code.claude.com/docs). |
| Provider keys (`OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, …) | OpenCode cloud models | OpenCode `/connect` or provider setup; export in shell if needed. `generated/opencode.json` configures Ollama and optional vLLM (`http://localhost:8000/v1`); add more per [OpenCode config](https://opencode.ai/docs/config). |
| `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, … | LobeChat web UI with hosted models | `ai-stack/.env` (copy from `.env.example`), then `docker compose … up -d` again; finish provider setup in Lobe if needed. |
| — | searxng MCP | SearXNG must be running (`ai-up`). Set `SEARXNG_PORT` in `ai-stack/.env`; `bin/ai-stack sync` injects the URL into `generated/*.json`. Install with `./deploy.sh --ai` or `install-optional-agents.sh --searxng-mcp`. |
| `CONTEXT7_API_KEY` | Higher Context7 rate limits | Optional. Export in the shell before starting Claude/OpenCode, or put it in `~/.hermes/.env` for Hermes. Context7 works without it for basic usage. |
| `HF_TOKEN` | Gated Hugging Face weights (Ollama pulls, vLLM download) | `ai-stack/.env` (passed into `ollama` and `vllm` services). |
| `stack-models.json` | vLLM HF id, image tag, port, context, GPU util; Ollama pull list | `stack-models.json` → `apply-stack-models.sh` → `models.compose.env`. Used with `docker compose --env-file models.compose.env` (`ai-up`, `ai-up-vllm`). |
| `ALPHAXIV_API_KEY` | alphaxiv skill | Shell env; see `skills/learning/alphaxiv/SKILL.md`. |

Web search for agents uses SearXNG plus PyPI `searxng-mcp-server` (same script path as arxiv/code-review-graph). MCP entries live in `config/*.template.json` and `config/hermes-mcp.template.yaml`; after `bin/ai-stack sync`, they appear in generated Claude/OpenCode/MCPO JSON and are merged into Hermes config.

## Day-to-day

| Action | Command / URL |
|--------|----------------|
| Start / stop stack | `ai-up` / `ai-down` (or `docker compose -f ai-stack/docker-compose.yml …`) |
| Start stack including vLLM | `ai-up-vllm` (compose `--profile vllm`) |
| CLI agents | `opencode`, `claude`, `hermes` ([Hermes Agent](https://github.com/NousResearch/hermes-agent) via Nix; `hermes setup` once) |
| Chat UI | http://localhost:3210 |
| Ollama API | http://localhost:11434 |
| vLLM OpenAI API (optional) | http://localhost:8000/v1 (`VLLM_PORT` in `ai-stack/.env`) |
| SearXNG | http://localhost:8080 (`SEARXNG_PORT` in `ai-stack/.env`) |

OpenCode: Tab = primary agents (Build, Plan, ask, debug). `@docs` = docs subagent. Pick provider Ollama (default) or vLLM (HF) after `ai-up-vllm`; the vLLM picker entry comes from `stack-models.json` via `apply-stack-models.sh`.

Claude Code: natural language or `/agents` for ask / debug / docs. This stack points Claude at Ollama via Anthropic-shaped URLs in `generated/claude-settings.json`. vLLM speaks OpenAI `/v1` only, so use OpenCode (or another OpenAI-base-URL client) for vLLM unless you add a bridge.

## vLLM (optional)

The `vllm` Compose service uses image `vllm/vllm-openai`. Model id, image tag, port, and tuning come from `stack-models.json` → `models.compose.env` (not from `docker-compose.yml`). Always run compose with `--env-file models.compose.env` (`ai-up`, `ai-up-vllm`, `./deploy.sh --ai`). Hub cache lives in the `vllm-hf-cache` volume.

- First run: `ai-up-vllm` (large image pull). NVIDIA Container Toolkit required for GPU, same as Ollama.
- Smoke test from repo root: `curl -s "http://localhost:$(jq -r .vllm.port ai-stack/stack-models.json)/v1/models"`.
- Blackwell / very new GPUs (e.g. sm_120): if the container fails or errors on CUDA arch, bump `vllm.image_tag` in `stack-models.json`, run `apply-stack-models.sh`, then `ai-up-vllm` again ([Docker Hub tags](https://hub.docker.com/r/vllm/vllm-openai/tags)).

LobeChat is wired to Ollama inside Compose (`OLLAMA_PROXY_URL`). Using vLLM from the Lobe UI would need an OpenAI-compatible custom provider pointing at `http://host.docker.internal:8000/v1` (or host IP); that is not pre-configured here.

## Gemma 4 and other new Hub models

When a new family (e.g. Gemma 4) ships:

1. Ollama: wait for official `ollama pull` tags or community GGUF parity; new architectures can lag llama.cpp briefly.
2. vLLM: use a vLLM release and `vllm.image_tag` that support the architecture; set `vllm.model` in `stack-models.json` to the exact Hub id; run `apply-stack-models.sh`; use `HF_TOKEN` if gated.
3. Agents: prefer instruct or tool-calling variants for MCP-heavy workflows; set `opencode.vllm_display_name` in `stack-models.json` for a custom picker label (otherwise the Hub id is used).

VRAM limits still apply: on a 16 GiB class GPU, prefer smaller checkpoints, supported quantization, or lower `vllm.max_model_len` / `vllm.gpu_memory_utilization` in `stack-models.json`, then re-run `apply-stack-models.sh`.

## If something breaks

- Agent ignores tools: model may not be tool-capable; try another Ollama tag or a cloud model in OpenCode.
- SearXNG / search MCP errors: ensure `ai-up` (or compose) is running, `searxng-mcp-server` is installed (`uv tool install searxng-mcp-server` or `./deploy.sh --ai`), and MCP URLs match `SEARXNG_PORT` (default 8080 on host).
- MCP changes not visible: redeploy and fully quit/restart Claude/OpenCode. In Hermes, run `/reload-mcp` or restart the chat.
- vLLM exits or OOM: reduce `vllm.max_model_len` / `vllm.gpu_memory_utilization`, pick a smaller `vllm.model`, or bump `vllm.image_tag` in `stack-models.json`, run `apply-stack-models.sh`, then `ai-up-vllm`. Check `docker logs vllm-openai`.
- Hermes gateway: `No adapter available for discord` — Nix bundles platform plugins outside the inner venv; Hermes's systemd unit omits `HERMES_BUNDLED_PLUGINS`. Run `bash ai-stack/scripts/fix-hermes-gateway-service.sh` once (installs a systemd drop-in). Use `ai-stack/bin/hermes` for `gateway install` / `gateway restart` so the drop-in is refreshed automatically. Confirm `~/.hermes/logs/gateway.log` shows `✓ discord connected`.

## Scripts: machine-wide vs per repo

Machine-wide scripts change your user environment or this nix-config tree. Per-repo scripts copy into a project directory (last argument, usually `.`).

| Script | Scope | Role |
|--------|--------|------|
| `install-skill.py` | Per repo | Skills via `--to`. `--agents` follows `--to`; only `opencode` / `claude` install agent markdown dirs. |
| `install-optional-agents.sh` | User / global | Third-party CLIs (uv), GSD via npx, Hermes via `nix profile install`. |
| `apply-stack-models.sh` | This checkout | Reads `stack-models.json` → `models.compose.env` + `provider.vllm` in `generated/opencode.json`; `ollama pull` when ollama container exists (skipped with `SKIP_OLLAMA_PULL=1` or `--no-pull`). Prefer `bin/ai-stack sync` (no pull) or `bin/ai-stack up` (full). |
| `ai-stack-docker-wanted.sh` | `./deploy.sh --ai` | Exit 0 if Docker compose should start; respects `AI_STACK_DOCKER` in `ai-stack/.env` and `--no-docker`. |
| `sync-opencode-ollama-models.sh` | This checkout | Rewrites `provider.ollama.models` in `generated/opencode.json` from local Ollama; `./deploy.sh --ai` may re-run `home-manager switch` if that file changes. |

### install-skill.py (per project)

Run `install-skill.py -h` and `install-skill.py bootstrap -h` for full usage (examples in the `--help` epilog).

- `target` defaults to `.`. `-y` / `--yes` skips overwrite prompts.
- Skills: `--to cursor` / `--to opencode` / `--to claude` — required for `install` and for `bootstrap` when using `--skills`, `--all-skills`, or `--all`.
- Pass `--to` more than once: first gets a full copy; later get symlinks into the first (relative). Use `--copy-all` to duplicate full trees.

`bootstrap` (aliases `b`, `init`) does nothing unless you pass at least one of:

- `--md` — `AGENTS.md` + `CLAUDE.md`
- `--agents` — agent `*.md` only for `opencode` and/or `claude` in `--to` (not `cursor`). Example: `--to opencode --agents` does not create `.claude/agents/`.
- `--skills n1 n2 …` — listed skills (needs `--to`)
- `--all-skills` — every skill (needs `--to`)
- `--hooks TYPE` — `python` | `cpp` | `mixed` (Claude Code only)
- `--all` — `--md` + `--agents` + `--all-skills` (still requires `--to` for skill trees; does not add hooks)

Other subcommands: `list`; `install` (`i`); `agents` (`a`); `agents-md`; `claude-md`; `hooks`.

Zsh (`AI_STACK_DIR` in `zsh-aliases.sh`):

- `ai-proj` — forwards to this script (`ai-proj list`, `ai-proj i x --to opencode`).
- `ai-boot` — `bootstrap -y --all --to cursor --to opencode --to claude` (templates + both agent dirs + skills). Narrower: `ai-proj bootstrap …`.

Examples:

```bash
cd /path/to/myapp
python3 "$AI_STACK_DIR/scripts/install-skill.py" i cpp-standards --to opencode --to cursor -y
python3 "$AI_STACK_DIR/scripts/install-skill.py" b -y --md --agents --to opencode --to cursor --skills tool-awareness security-review
python3 "$AI_STACK_DIR/scripts/install-skill.py" b -y --hooks python
ai-boot   # --all with --to cursor opencode claude
```

Use `$AI_STACK_DIR` (set by home-manager) instead of a hardcoded `~/nix-config/ai-stack` path.

Commit `.cursor/`, `.opencode/`, `.claude/`, `AGENTS.md`, and `CLAUDE.md` in that project repo if you want them shared.

### install-optional-agents.sh (user / global)

Run from `ai-stack/` or with the script path. `./deploy.sh --ai` runs `--code-review-graph`, `--arxiv`, `--searxng-mcp`, and `--hermes`. `--hermes` installs [Hermes Agent](https://github.com/NousResearch/hermes-agent) from its Nix flake (`hermes setup` for `~/.hermes/`). Context7 runs through pinned `npx`; DeepWiki is a remote MCP, so neither needs a local installer. You can also run `bin/hermes` without profile install (`nix run` each time). `--gsd` installs [Get Shit Done](https://github.com/gsd-build/get-shit-done) via npx; `--all` for everything. See `--help`.

### apply-stack-models.sh

Reads `ai-stack/stack-models.json`. Writes `ai-stack/models.compose.env` (gitignored). Patches `provider.vllm` in `generated/opencode.json` when `vllm.model` is set; removes `provider.vllm` for Ollama-only configs. Runs `docker exec ollama ollama pull …` for each `ollama.pull[]` when the ollama container exists, unless `--no-pull` or `SKIP_OLLAMA_PULL=1`. Usually invoked via `bin/ai-stack sync` / `bin/ai-stack up` / `./deploy.sh --ai`.

### sync-opencode-ollama-models.sh

Updates `provider.ollama.models` in `generated/opencode.json` only. Invoked after Docker Ollama starts when using `./deploy.sh --ai` or `bin/ai-stack up`, or run manually when Ollama is up.

### sync-hermes-mcp.sh

Merges `generated/hermes-mcp.yaml` into `~/.hermes/config.yaml` under `mcp_servers`. It keeps a first-run backup at `~/.hermes/config.yaml.ai-stack.bak` and is invoked by `bin/ai-stack sync`.

## Reference

Templates in git: `ai-stack/config/*.template.json` and `ai-stack/config/hermes-mcp.template.yaml`. Runtime output: `ai-stack/generated/` (JSON is symlinked from `~/.config/opencode/opencode.json` and `~/.config/claude/settings.json` when using Nix, or via `bin/ai-stack install`; Hermes YAML is merged into `~/.hermes/config.yaml`). OpenCode reads MCP from `opencode.json` (`mcp` + `type: "local"` / `"remote"`); Claude reads `mcpServers`; Hermes reads `mcp_servers`. Keep these aligned when you add a server.

**Bash permissions:** OpenCode `permission.bash` and Claude `permissions.allow` both use an ask-by-default policy for arbitrary commands; only common dev tools are pre-approved. Network-heavy tools (`curl`, `wget`, `nix`) are not allow-listed in OpenCode to match Claude’s narrower stance.

**MCP `npx` packages** in templates use pinned versions (`@modelcontextprotocol/server-memory@0.6.3`, etc.); `claude` / `opencode` CLI wrappers from Nix still use floating `npx -y` for the agent runtimes (documented as mutable runtime tools).

**Docker images:** `docker-compose.yml` pins `lobehub/lobe-chat` and `searxng/searxng` to explicit tags (not `:latest`). Bump tags deliberately when you upgrade.

Commands: `ai-stack/commands/` → deployed by Home Manager to `~/.claude/commands/` and `~/.config/opencode/commands/`, or linked by `bin/ai-stack install`.

Agents: `ai-stack/agents/claude/` and `agents/opencode/` (same roles; format differs per product).

Skills (source): `ai-stack/skills/{generic,programming,learning,robotics}/` — install into a project with `install-skill.py` or your agent’s `/setup-project` flow.

Robotics skills use a git submodule under `skills/robotics/robotics-agent-skills`; initialize only if needed (`git submodule update --init …`).

```
ai-stack/
  bin/ai-stack
  config/           *.template.json → generated/
  generated/        gitignored runtime MCP JSON + (see .gitignore)
  agents/
  commands/
  mcp/README.md     notes only; no canonical JSON here
  scripts/          render-mcp-templates.sh, install-skill.py, …
  skills/
  templates/        AGENTS.md, CLAUDE.md, claude-hooks/
  stack-models.json
  docker-compose.yml
```

## Splitting `ai-stack` into its own repository (optional)

To extract only `ai-stack/` with history: from the parent repo, `git subtree split --prefix=ai-stack -b split/ai-stack`, then push that branch to a new remote as `main`. Move the robotics submodule entry into the new repo’s `.gitmodules`. In `nix-config`, drop the embedded `ai-stack/` directory and set `AI_STACK_DIR` (e.g. `$HOME/ai-stack`) so zsh aliases and `bin/ai-stack` point at the clone; optionally add a flake input for read-only command sources vs a mutable checkout (document drift between `nix flake update` and local edits).
