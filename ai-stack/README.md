# AI stack

There are two layers:

1. **Nix / home-manager** (flake output `*-ai`): `claude`, `opencode`, MCP JSON, skills, agents. No Docker required for this part.
2. **Docker Compose**: Ollama, LobeChat, SearXNG, and an optional vLLM profile (OpenAI-compatible API on port 8000).

To deploy only the Nix side, set `AI_STACK_DOCKER=0` in `ai-stack/.env` or use `./deploy.sh --ai --no-docker`. Use `ai-up` when you want the containers. You can add services in `docker-compose.yml`; the same Docker on/off switch applies to the whole stack from deploy.

## Install

1. **Docker:** `sudo systemctl enable --now docker` and add your user to the `docker` group, then log out and back in (or start a new login session) so `docker compose` works without `sudo`.
2. **GPU (optional):** For NVIDIA in Docker, install the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) and restart Docker. Without it, Ollama may still run on CPU.
3. **Deploy:** From the repo root:

   ```bash
   ./deploy.sh --ai
   ```

   Optional: `--no-docker` or `AI_STACK_DOCKER=0` in `ai-stack/.env` to skip Compose.

   - Needs network (npx / uv installers).
   - Nix only sees git-tracked files in the flake: new files under `ai-stack/` must be committed or home-manager cannot reference them.
   - `stack-models.json` is the source of truth for Ollama tags to pull (`ollama.pull[]`) and which Hugging Face id vLLM serves (`vllm.*`). `scripts/apply-stack-models.sh` writes `models.compose.env` (for `docker compose --env-file`) and sets `provider.vllm` in `mcp/opencode.json` when you use Docker/vLLM. `./deploy.sh --ai` runs apply only when the Docker stack is part of that deploy; with `--no-docker` / `AI_STACK_DOCKER=0`, apply is skipped (no spurious `ollama pull`, no rewriting `opencode.json` for vLLM). `ai-up` always runs apply first so compose stays in sync when you start containers later.
   - After Docker starts Ollama, `sync-opencode-ollama-models.sh` rebuilds `provider.ollama.models` from `/api/tags` (aligned with `ollama list`; drops removed tags; keeps your `name` where tags remain). It does not change `provider.vllm`. If that JSON changes, deploy runs home-manager again so `~/.config/opencode/opencode.json` matches. Requires `jq` on the host; if Ollama is not up yet, sync is skipped without error. Manual: `bash ai-stack/scripts/sync-opencode-ollama-models.sh`

4. **Shell:** `exec zsh` or open a new terminal so `claude`, `opencode`, and `ai-up` are on PATH.

5. **Models:** Edit `stack-models.json`: add Ollama tags to `ollama.pull` and set `vllm.model` (and optional `vllm.image_tag`, `max_model_len`, etc.). Run `bash ai-stack/scripts/apply-stack-models.sh` or use `ai-up` / `./deploy.sh --ai`. Ad-hoc: `ollama-pull <tag>`. Prefer tool-calling coder models for agents; small chat-only weights often skip tools.

After changing `ai-stack/mcp/*` or agents: `./deploy.sh` or `home-manager switch`, then restart Claude Code / OpenCode.

## API keys (optional)

Nothing is required for local Ollama only. Add keys only for the features below.

| Credential | For | Where to set |
|------------|-----|--------------|
| `ANTHROPIC_API_KEY` | Claude Code via Anthropic API instead of local Ollama | Shell (e.g. `home.sessionVariables`, direnv). This repo’s `ai-stack/mcp/claude-settings.json` sets `ANTHROPIC_BASE_URL` / `ANTHROPIC_AUTH_TOKEN` for Ollama; for cloud you must override (e.g. `~/.config/claude/settings.local.json`, or edit source JSON) so traffic goes to Anthropic. See [Claude Code environment](https://code.claude.com/docs). |
| Provider keys (`OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, …) | OpenCode cloud models | OpenCode `/connect` or provider setup; export in shell if needed. `opencode.json` here configures Ollama and optional vLLM (`http://localhost:8000/v1`); add more per [OpenCode config](https://opencode.ai/docs/config). |
| `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, … | LobeChat web UI with hosted models | `ai-stack/.env` (copy from `.env.example`), then `docker compose … up -d` again; finish provider setup in Lobe if needed. |
| — | searxng MCP | SearXNG must be running (`ai-up`). Default URL `http://127.0.0.1:8080` (`SEARXNG_PORT` in `ai-stack/.env`). If you change the port, update `--searxng-url` in `ai-stack/mcp/claude-settings.json`, `opencode.json` (`mcp.searxng.command`), and `mcpo-config.json`. Install with `./deploy.sh --ai` or `install-optional-agents.sh --searxng-mcp`. |
| `HF_TOKEN` | Gated Hugging Face weights (Ollama pulls, vLLM download) | `ai-stack/.env` (passed into `ollama` and `vllm` services). |
| `stack-models.json` | vLLM HF id, image tag, port, context, GPU util; Ollama pull list | `stack-models.json` → `apply-stack-models.sh` → `models.compose.env`. Used with `docker compose --env-file models.compose.env` (`ai-up`, `ai-up-vllm`). |
| `ALPHAXIV_API_KEY` | alphaxiv skill | Shell env; see `skills/learning/alphaxiv/SKILL.md`. |

Web search for agents uses SearXNG plus PyPI `searxng-mcp-server` (same script path as arxiv/code-review-graph). MCP entries for `memory`, `sequential-thinking`, `arxiv`, `code-review-graph`, `searxng` live under `ai-stack/mcp/`.

## Day-to-day

| Action | Command / URL |
|--------|----------------|
| Start / stop stack | `ai-up` / `ai-down` (or `docker compose -f ai-stack/docker-compose.yml …`) |
| Start stack including vLLM | `ai-up-vllm` (compose `--profile vllm`) |
| CLI agents | `opencode`, `claude` |
| Chat UI | http://localhost:3210 |
| Ollama API | http://localhost:11434 |
| vLLM OpenAI API (optional) | http://localhost:8000/v1 (`VLLM_PORT` in `ai-stack/.env`) |
| SearXNG | http://localhost:8080 (`SEARXNG_PORT` in `ai-stack/.env`) |

OpenCode: Tab = primary agents (Build, Plan, ask, debug). `@docs` = docs subagent. Pick provider Ollama (default) or vLLM (HF) after `ai-up-vllm`; the vLLM picker entry comes from `stack-models.json` via `apply-stack-models.sh`.

Claude Code: natural language or `/agents` for ask / debug / docs. This repo points Claude at Ollama via Anthropic-shaped URLs in `claude-settings.json`. vLLM speaks OpenAI `/v1` only, so use OpenCode (or another OpenAI-base-URL client) for vLLM unless you add a bridge.

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
- MCP changes not visible: redeploy and fully quit/restart the agent.
- vLLM exits or OOM: reduce `vllm.max_model_len` / `vllm.gpu_memory_utilization`, pick a smaller `vllm.model`, or bump `vllm.image_tag` in `stack-models.json`, run `apply-stack-models.sh`, then `ai-up-vllm`. Check `docker logs vllm-openai`.

## Scripts: machine-wide vs per repo

Machine-wide scripts change your user environment or this nix-config tree. Per-repo scripts copy into a project directory (last argument, usually `.`).

| Script | Scope | Role |
|--------|--------|------|
| `install-skill.py` | Per repo | Skills via `--to`. `--agents` follows `--to`; only `opencode` / `claude` install agent markdown dirs. |
| `install-optional-agents.sh` | User / global | Third-party CLIs (uv) and GSD via npx into `~/.claude/` and `~/.config/opencode/`. |
| `apply-stack-models.sh` | This flake | Reads `stack-models.json` → `models.compose.env` + `provider.vllm` in `opencode.json`; `ollama pull` when ollama container exists (skipped with `SKIP_OLLAMA_PULL=1` or `--no-pull`). `./deploy.sh --ai --no-docker` skips this script entirely. |
| `ai-stack-docker-wanted.sh` | `./deploy.sh --ai` | Exit 0 if Docker compose should start; respects `AI_STACK_DOCKER` in `ai-stack/.env` and `--no-docker`. |
| `sync-opencode-ollama-models.sh` | This flake | Rewrites `provider.ollama.models` in `opencode.json` from local Ollama; then redeploy / home-manager to refresh `~/.config/opencode/`. |

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

Run from `ai-stack/` or with the script path. `./deploy.sh --ai` runs `--code-review-graph`, `--arxiv`, and `--searxng-mcp` (uv tools expected by MCP entries). `--gsd` installs [Get Shit Done](https://github.com/gsd-build/get-shit-done) via npx; `--all` for everything. See `--help`.

### apply-stack-models.sh (nix-config tree)

Reads `ai-stack/stack-models.json`. Writes `ai-stack/models.compose.env`. Patches `provider.vllm` in `mcp/opencode.json`. Runs `docker exec ollama ollama pull …` for each `ollama.pull[]` when the ollama container exists, unless `--no-pull` or `SKIP_OLLAMA_PULL=1`. Run manually after editing `stack-models.json`, or rely on `ai-up` / `./deploy.sh --ai`.

### sync-opencode-ollama-models.sh (nix-config tree)

Updates `provider.ollama.models` in `ai-stack/mcp/opencode.json` only. Invoked after Docker Ollama starts when using `./deploy.sh --ai`, or run manually when Ollama is up.

## Reference

Configs in git: `ai-stack/mcp/` → `~/.config/claude/settings.json`, `~/.config/opencode/opencode.json`. OpenCode reads MCP from `opencode.json` (`mcp` + `type: "local"` + `command` array); see [OpenCode MCP docs](https://opencode.ai/docs/mcp-servers). Keep Claude (`mcpServers` in `claude-settings.json`) and OpenCode (`mcp` in `opencode.json`) aligned when you add a server.

Commands: `ai-stack/commands/` → `~/.claude/commands/` and `~/.config/opencode/commands/`.

Agents: `ai-stack/agents/claude/` and `agents/opencode/` (same roles; format differs per product).

Skills (source): `ai-stack/skills/{generic,programming,learning,robotics}/` — install into a project with `install-skill.py` or your agent’s `/setup-project` flow.

Robotics skills use a git submodule under `skills/robotics/robotics-agent-skills`; initialize only if needed (`git submodule update --init …`).

```
ai-stack/
  agents/
  commands/
  mcp/
  scripts/          install-skill.py, install-optional-agents.sh, apply-stack-models.sh, sync-opencode-ollama-models.sh, ai-stack-docker-wanted.sh
  skills/
  templates/        AGENTS.md, CLAUDE.md, claude-hooks/
  stack-models.json   Ollama pull list + vLLM model / runtime (source of truth)
  models.compose.env  generated for docker compose --env-file (keep in sync via apply-stack-models.sh)
  docker-compose.yml
```
