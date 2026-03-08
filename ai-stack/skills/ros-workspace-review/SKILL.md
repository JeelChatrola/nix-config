---
name: ros-workspace-review
description: Review robotics and ROS-style workspaces for correctness, reliability, launch/config drift, message contract issues, executor and callback risks, and missing tests. Use when the user asks for a workspace review, launch review, package review, or debugging help across C++, Python, and robotics infrastructure.
---

# ROS Workspace Review

## Quick Start

Use this skill when analyzing a robotics repository with multiple packages,
launch files, parameters, interfaces, and mixed C++ / Python code.

Default priorities:

1. correctness and failure modes
2. interface and config consistency
3. concurrency, shutdown, and observability
4. smallest safe fix

## Review Checklist

- Verify message, service, and action definitions match actual runtime assumptions.
- Check launch files, params, and default values for drift.
- Look for executor misuse, callback starvation, deadlocks, or unsafe shared state.
- Check startup / shutdown behavior and error propagation.
- Prefer concrete bugs over style comments.

## Output Format

Use this structure:

```markdown
## Findings
- Severity: issue, impact, and why it matters

## Assumptions
- Unknowns that may change the recommendation

## Missing Tests
- Small tests or instrumentation that would reduce risk

## Next Steps
- Minimal, high-value follow-up actions
```

## Additional Resources

- For ready-to-paste review wording, see [../../robotics/prompts/ros-workspace-review.md](../../robotics/prompts/ros-workspace-review.md)
