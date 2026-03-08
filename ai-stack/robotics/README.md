# Robotics AI Layer

This directory adds robotics-focused guidance on top of the base `ai-stack/`.
It does not install ROS or build a ROS image. The goal is to make local and
cloud AI tools more useful when working on robotics codebases that already use
ROS, C++, Python, CUDA, perception, controls, and simulation.

## What To Use

### Best local models for robotics development

- `deepseek-coder-v2` or `qwen2.5-coder`: strongest default for C++, Python, build fixes, and code editing.
- `llama3.1` / `llama3.2`: good general reasoning and docs/chat tasks.
- small models like `qwen2.5-coder:7b`: useful for fast refactors, grep-like code help, and local iteration.

### Best interfaces by task

- `Claude Code` or `opencode`: best when the model must edit code, inspect repos, run tests, and use MCP tools.
- `LobeChat`: best for design thinking, architecture discussions, postmortems, and side-by-side model comparison.
- `AnythingLLM` or `LibreChat`: worth adding later if you want document RAG over specs, papers, calibration docs, or logs.

## Recommended Robotics Workflows

### 1. ROS workspace review

Use an agent for:

- package structure review
- launch file sanity checks
- message / service / action API review
- callback threading and executor issues
- build breakage triage

Useful context to provide:

- package tree
- `compile_commands.json` if available
- failing build or test logs
- launch files, params, and message definitions

### 2. C++ node debugging

Use agents for:

- race condition hunting
- ownership / lifetime issues
- callback queue and threading analysis
- template and linker error explanation
- ABI mismatch triage

Helpful host-side tools managed via Home Manager:

- `cmake`, `ninja`, `bear`
- `clang`, `clangd`, `gdb`, `lldb`
- `ccache`, `pkg-config`

### 3. Python node and ML pipeline work

Use agents for:

- data loader and preprocessing review
- training / eval script cleanup
- model export and inference integration
- sensor log parsing and validation
- experiment planning and metrics design

Helpful host-side tools managed via Home Manager:

- `uv`
- `ruff`
- `pytest`
- `mypy`

## Recommended MCP Additions For Robotics

These are the most useful next MCP servers for robotics projects:

- `filesystem`: inspect workspaces, bags, configs, launch files, params
- `git`: review changes across many packages
- `fetch`: pull package docs, API references, papers, issue threads
- `memory`: keep long-running project context like frame names, topic contracts, and hardware caveats
- `sequential-thinking`: useful for debugging multi-stage failures

Potential future additions:

- database MCP for experiment tracking or telemetry
- custom MCP wrapper that summarizes `colcon test-result`, topic graphs, or bag metadata
- simulator-specific MCP tools if you standardize Gazebo / Isaac / Mujoco workflows

## How To Get Better Answers

When asking an agent for robotics help, provide:

1. the subsystem: perception, planning, controls, SLAM, manipulation, infra
2. the runtime symptom: crash, latency spike, drift, missed deadline, bad detection
3. the safety or realtime constraint
4. the relevant files, logs, and build errors
5. what "correct" means: deterministic, realtime-safe, numerically stable, etc.

## Included Templates

- `prompts/ros-workspace-review.md`
- `prompts/perception-experiment-planner.md`
- `prompts/cpp-python-debugger.md`

## Included Skill Templates

These are reference skill packs, not auto-enabled Cursor skills:

- `../skills/ros-workspace-review/`
- `../skills/perception-experiment-planner/`
- `../skills/cpp-python-bridge-review/`

Copy one of them into a project's `.cursor/skills/` directory if you want it
to become an actual project skill.
