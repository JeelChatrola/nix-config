---
name: cpp-python-bridge-review
description: Debug and review systems that combine C++ and Python, especially robotics nodes, bindings, inference code, and evaluation scripts. Use when the user mentions pybind, ABI issues, mixed-language crashes, data shape mismatches, or coordination between native and Python layers.
---

# C++ Python Bridge Review

## Quick Start

Use this skill when a robotics system spans:

- C++ runtime components
- Python nodes or scripts
- bindings, serialization, or data conversion layers

## Review Priorities

1. build and link correctness
2. ABI and compiler compatibility
3. ownership and lifetime safety
4. thread boundaries and GIL assumptions
5. schema, shape, and timestamp consistency

## Investigation Pattern

- Separate build-time, link-time, startup-time, and runtime failures.
- Look for changes in compiler, STL, CUDA, Python version, or wheel environment.
- Validate boundaries: memory ownership, frame IDs, units, tensor shapes, and timestamps.
- Suggest the minimum command that proves or disproves each hypothesis.

## Output Template

```markdown
## Likely Root Causes

## Confirming Checks

## Minimal Fix

## Regression Tests
```

## Additional Resources

- For a prompt template, see [../../robotics/prompts/cpp-python-debugger.md](../../robotics/prompts/cpp-python-debugger.md)
