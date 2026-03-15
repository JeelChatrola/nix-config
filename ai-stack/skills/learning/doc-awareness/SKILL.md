---
name: doc-awareness
description: Check installed library and tool versions before writing code to avoid wrong API usage. Use when working with versioned libraries (PyTorch, TensorFlow, ROS, OpenCV, CMake, etc.) or when the user reports syntax errors in generated code.
---

# Doc Awareness

## Problem

AI models are trained on mixed documentation from multiple versions. They generate
code using APIs that may not exist in the version actually installed. This skill
forces version checking before writing code.

## Before writing code that uses a library

1. **Check the installed version:**

```bash
# Python packages
python -c "import torch; print(torch.__version__)"
python -c "import cv2; print(cv2.__version__)"
pip show <package> | grep Version
uv pip show <package> | grep Version

# System tools
cmake --version
gcc --version
clang --version
ninja --version
docker --version

# ROS
printenv ROS_DISTRO
ros2 --version
```

2. **If the version matters for the API you're about to use**, note it and write code for that specific version.

3. **If you're unsure whether an API exists in the installed version**, check before using it:

```bash
# Check if a Python attribute/function exists
python -c "import torch; print(hasattr(torch, 'compile'))"
python -c "import torch.nn; print(dir(torch.nn))" | grep <function>

# Check CMake module availability
cmake --help-module <ModuleName>
cmake --help-command <CommandName>
```

## Common version traps

| Library | Trap | Since version |
|---|---|---|
| PyTorch | `torch.compile()` | 2.0+ |
| PyTorch | `torch.inference_mode` | 1.9+ |
| OpenCV | `cv2.dnn.readNetFromONNX` | 4.5+ |
| CMake | `FetchContent` | 3.11+ |
| CMake | `target_sources(FILE_SET)` | 3.23+ |
| Python | `match` statement | 3.10+ |
| Python | `str | None` union syntax | 3.10+ |
| Python | `from __future__ import annotations` | 3.7+ |
| ROS 2 | Lifecycle nodes stable | Humble+ |
| NumPy | `np.bool` removed | 1.24+ |

## Rules

- Never assume the latest version. Check first.
- If a project has `pyproject.toml`, `requirements.txt`, or `CMakeLists.txt` with version pins, respect those versions.
- When suggesting a new dependency, mention which version you're targeting and why.
- If you use a web search to find docs, verify the doc URL matches the installed version (e.g., `pytorch.org/docs/2.1/` not `pytorch.org/docs/stable/`).
