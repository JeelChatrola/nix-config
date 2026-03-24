---
name: skill-selector
description: Detect project type and recommend which skills to install. Use when setting up AI assistance for a new project, or when the user asks which skills apply.
---

# Skill Selector

## Available Skills

### generic/ (always consider)
- **tool-awareness** -- what CLI tools are installed
- **security-review** -- secrets, injection, unsafe patterns
- **repo-documenter** -- auto-detect build system, generate docs

### programming/
- **python-standards** -- ruff, typing, pytest, uv
- **cpp-standards** -- clang-format, clang-tidy, CMake, modern C++

### learning/
- **learning-mode** -- AI explains and teaches instead of just writing
- **doc-awareness** -- check library versions before writing code
- **alphaxiv** -- arXiv / alphaXiv paper URLs and metadata (ML, robotics papers)

### robotics/ (from robotics-agent-skills submodule)
- **ros2** -- rclpy, rclcpp, DDS, QoS, lifecycle nodes
- **ros1** -- catkin, rospy, roscpp, nodelets
- **robotics-software-principles** -- SOLID for robotics
- **robotics-design-patterns** -- behavior trees, FSMs, sim-to-real
- **robot-perception** -- cameras, LiDAR, calibration
- **robotics-testing** -- pytest + ROS, launch_testing
- **docker-ros2-development** -- Docker + ROS 2
- **ros2-web-integration** -- rosbridge, REST, WebSocket
- **robot-bringup** -- systemd, udev, watchdogs
- **robotics-security** -- SROS2, DDS encryption

## Detection Logic

```
always:
    → tool-awareness, security-review, doc-awareness

if *.py or pyproject.toml or requirements.txt:
    → python-standards

if *.cpp or *.h or CMakeLists.txt:
    → cpp-standards

if package.xml or colcon.meta:
    → ros2 (or ros1 if catkin)
    → robotics-software-principles, robotics-testing

if no README.md:
    → repo-documenter
```

## Install

```bash
python3 ~/nix-config/ai-stack/scripts/install-skill.py list
python3 ~/nix-config/ai-stack/scripts/install-skill.py i <name> --to cursor   # or opencode / claude; repeat --to for symlinks
python3 ~/nix-config/ai-stack/scripts/install-skill.py bootstrap -h          # bootstrap needs explicit --md / --agents / --skills / …
```
