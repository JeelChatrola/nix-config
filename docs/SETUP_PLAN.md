# Personal setup and AI tool ownership

## Direction

Keep the three repositories independently usable. Ubuntu is the current deployment target. A future Linux laptop or server can adopt the pieces it needs when its requirements become concrete. The office Mac requires no deployment changes.

The main maintenance problem is unclear ownership and surprising command behavior. Replacing Nix would not by itself remove the custom agent installers, generated configurations, or service lifecycle scripts. Retain Nix for the non-AI environment and move AI client installation into ai-stack. Introduce further abstractions only when an actual second use requires them.

Local inference and other Docker services are optional. Default AI deployment installs clients and configures them without starting Docker, downloading model weights, or restarting a gateway. Existing running services are not stopped by a change to the default deployment path.

## Ownership

| Repository | Responsibilities | Independent use |
|---|---|---|
| system-setup | Host packages and services, OS prerequisites, hardware integration | Prepare an Ubuntu machine without requiring AI software |
| nix-config | Non-AI CLI tools, shell/editor configuration, existing desktop user configuration | Apply the personal tools environment without ai-stack |
| ai-stack | AI client versions, profiles, skills, MCP configuration, optional services | Run with Node, uv, and documented prerequisites supplied by any suitable package manager |

Nix can install Node and uv without owning the applications those tools install. An AI client has one installation owner even when its runtime has a different owner. Updates must target that installation. Installing another Codex globally with npm would introduce a second copy; it would not update the ai-stack copy.

The initial audit found documented ownership boundaries that disagreed with the implementation. AI stack instructions still referenced a removed `deploy.sh --ai` option. System-setup described GUI applications as outside Nix, while Nix installed Firefox and Obsidian. The AI handoff fixes the first issue. Desktop ownership remains a separate decision; existing application choices are retained for now.

## Everyday operations

The following commands describe the proposed repository implementation. They become the live workflow after the migration steps below.

| Intent | Entry point | Scope |
|---|---|---|
| Apply existing non-AI configuration | `nix-refresh --host main-workstation` | Existing flake inputs |
| Upgrade the non-AI environment | `nix-upgrade --host main-workstation` | Flake inputs, then Home Manager activation |
| Install the recorded AI client versions | `ai-stack deploy` | npm clients, Hermes, agent configuration, executable links |
| Upgrade Codex | `ai-stack update codex` | Its npm package and affected dependency lock entries |
| Upgrade Hermes | `ai-stack update hermes` | Latest published GitHub release resolved to a commit |
| Select an AI client version | `ai-stack update NAME --version VERSION` | One named client |
| Add an npm AI tool | `ai-stack add PACKAGE` | New direct dependency and its exposed commands |
| Start optional local services | `ai-stack up` | Existing Docker stack and model reconciliation |

The shared CLI delegates installation to npm and uv. The underlying commands remain usable directly. npm supports saving an exact package version, and `npm ci` installs a matching lockfile without rewriting it.[^1][^2] These operations give Node AI clients a separate update lifecycle from the Nix package collection.

Python tooling needs a narrower promise. Hermes is installed into an ai-stack virtual environment and its source commit is recorded. Its transitive dependencies are not fully locked by that manifest. A future requirement for identical Python dependency graphs would justify an additional uv project lock; it is not claimed by this first handoff. uv distinguishes project environments from independently installed tool environments, so using the correct environment remains necessary.[^3]

OpenAI documents an independent Codex installation and update path. Keeping Codex in Nix is therefore a local ownership choice, rather than a requirement of Codex itself.[^4] The initial ai-stack npm versions match the executables observed on the Ubuntu machine, separating the ownership migration from a software upgrade.

## What to borrow from Omarchy

Omarchy documents a coordinated update operation that includes package changes, migrations, and snapshots.[^5] It also identifies personal dotfiles separately from distribution-managed files.[^6] Those are useful operating conventions: a known entry point, explicit editable locations, and a documented recovery path.

This personal setup spans independent repositories and package managers. It does not have Omarchy's coordinated release process or system snapshot boundary. A single command could call all three repositories, but it could not honestly promise a transaction that rolls everything back together. Keep each component's result visible and make failures attributable to its owner.

A future convenience menu is reasonable if it invokes these existing operations. It should not become the only way to understand or run the setup. First establish trustworthy commands; then decide whether remembering them is still a problem.

## Alternatives considered

Keeping AI clients in the shared Nix package set preserves one package source, but updating a fast-moving client remains tied to that set or requires a dedicated override. That does not fit the requested independent update workflow.

Dropping Nix entirely would require replacing working shell, editor, and package management behavior. There is no evidence that this migration would improve the immediate AI update problem enough to justify its cost. Nix remains useful for installing the personal environment independently of ai-stack; Home Manager supports standalone operation.[^7]

Moving everything to mise could consolidate language runtimes and some tool installation. Its upgrade operation can update configured version requests, including explicit version bumps.[^8] Adding it solely to mediate the npm and uv installations would introduce another component now. Reconsider it if runtime selection becomes a recurring problem across development projects.

The chosen first change is narrower: preserve the repository boundaries, use existing package managers, record AI versions in ai-stack, and make service startup explicit.

## Migration and recovery

Install the ai-stack client versions before activating the Nix configuration that removes their old launchers. Make sure `~/.local/bin` is on PATH. The ai-stack linker should reject unrelated existing files rather than replace them.

After Home Manager activation, open a new shell and check `command -v codex`, `command -v hermes`, and the reported client versions. Both commands should resolve through ai-stack's links. Keep authentication, conversations, and other mutable agent state in their existing directories. Existing settings should be reviewed where the normal configuration synchronization writes managed values.

For an npm rollback, restore the selected `package.json` and `package-lock.json` revisions and run `npm ci`. For Hermes, request the previous recorded commit. These operations restore application code; they do not undo data migrations performed by the applications. Update failures can leave a runtime environment partially modified even when the requested version file remains unchanged.

Nix profile recovery covers the Nix-managed environment. It does not restore npm packages, uv environments, Docker volumes, or agent conversations. Retain known-good version files and back up valuable mutable data separately.

## Next simplifications

Review the next recurring task before adding more machinery. Good candidates are installing one non-AI CLI, editing shell configuration, and preparing a second Linux machine. Each should identify the file to edit, the command to run, and the expected result.

Decide desktop ownership separately. Ubuntu, an Omarchy laptop, and a headless server need different desktop behavior. Shared CLI configuration can remain common while each host keeps its desktop integration under an explicit owner.

Keep optional experiments inexpensive to remove. DeepTutor, local model services, and gateway integrations should have distinct activation steps. The current service path still assumes NVIDIA-backed Ollama; CPU or Apple GPU support is future work triggered by an actual need.

The retained Nix base is not yet a minimal package list. Existing shell, editor, and desktop tools remain installed. Prune those based on use, rather than deleting working tools during an ownership migration.

## Acceptance criteria and limits

Default AI deployment must avoid Docker startup, model downloads, and gateway restarts. An individual client update must select only the requested top-level package or agent, record the chosen version, and leave other top-level pins intact. Adding an npm tool must expose its own command without overwriting an unrelated local executable.

Nix evaluation should confirm that the workstation configuration contains no Codex, OpenCode, Agent Browser, Hermes, DeepTutor, ai-stack launcher, or llmfit package. Existing non-AI configuration remains valid. Tests must exercise failed updates and command-link conflicts, in addition to successful command dispatch.

Package launch checks establish that the pinned executables start on the current Ubuntu host. They do not establish authenticated end-to-end agent behavior, a successful Hermes release upgrade, or compatibility with a future laptop. Those checks belong to the actual migration or new-host adoption.

## Sources

[^1]: npm, [npm install](https://docs.npmjs.com/cli/v11/commands/npm-install/), exact-version saving and lockfile behavior; accessed September 10, 2026.
[^2]: npm, [npm ci](https://docs.npmjs.com/cli/v11/commands/npm-ci/), locked installation; accessed September 10, 2026.
[^3]: Astral, [Tools](https://docs.astral.sh/uv/concepts/tools/), tool environments and upgrade constraints; accessed September 10, 2026.
[^4]: OpenAI, [Codex CLI](https://learn.chatgpt.com/docs/codex/cli), installation and update guidance; accessed September 10, 2026.
[^5]: Omarchy, [Updates](https://omarchy.org/manual/updates/), coordinated updates and snapshot recovery; accessed September 10, 2026.
[^6]: Omarchy, [Dotfiles](https://omarchy.org/manual/dotfiles/), personal and maintained configuration; accessed September 10, 2026.
[^7]: Home Manager, [Standalone setup](https://nix-community.github.io/home-manager/nix-flakes/standalone.html); accessed September 10, 2026.
[^8]: mise, [mise upgrade](https://mise.jdx.dev/cli/upgrade.html), configured version updates; accessed September 10, 2026.

Local evidence: nix-config `flake.nix`, `deploy.sh`, capability modules, and the initial AI wrappers; ai-stack `src/aistack/services.py`, `scripts/uv-install-agents.sh`, `agents/uv-apps.yaml`, and the Docker Compose file; system-setup `README.md` and `install.sh`. These are private working-tree sources inspected for this decision. Observations about installed launchers refer to the Ubuntu shell examined during the audit.
