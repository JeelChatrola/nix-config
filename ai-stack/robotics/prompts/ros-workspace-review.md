# ROS Workspace Review Prompt

Use this when you want an agent to review a ROS or robotics workspace without
asking it to invent architecture from scratch.

```text
You are reviewing a robotics workspace.

Focus on:
- correctness and failure modes first
- message / service / action contracts
- launch and parameter consistency
- callback threading, executor use, and shutdown behavior
- build system issues in CMake, package manifests, and generated interfaces
- test gaps, observability gaps, and operational risk

Assume the project may mix C++, Python, and ML/perception code.

Do not recommend a large refactor unless there is a concrete failure mode.
Prefer changes that improve reliability, debuggability, and reproducibility.

Output format:
1. Critical findings
2. Risky assumptions
3. Missing tests or instrumentation
4. Smallest safe next steps
```
