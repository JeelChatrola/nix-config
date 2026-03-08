---
name: perception-experiment-planner
description: Plan and critique robotics perception or ML experiments with emphasis on metrics, ablations, deployment risk, calibration, synchronization, latency, and domain shift. Use when the user is designing experiments, evaluating perception models, or debugging data or inference quality.
---

# Perception Experiment Planner

## Quick Start

Use this skill for perception, ML, sensor fusion, or inference pipeline work.

Always ask or infer:

- task and operating environment
- sensors and synchronization assumptions
- latency and hardware constraints
- current baseline
- failure mode

## Planning Rules

- Prefer the smallest experiment that can disprove the current assumption.
- Separate offline metrics from on-robot behavior.
- Call out confounders like timestamp drift, calibration drift, label noise, and domain gap.
- Propose ablations that change one variable at a time.
- Include deployment and rollback criteria.

## Output Template

```markdown
## Goal

## Hypothesis

## Data Needed

## Metrics

## Ablations

## Risks

## Next Experiment
```

## Additional Resources

- For a prompt template, see [../../robotics/prompts/perception-experiment-planner.md](../../robotics/prompts/perception-experiment-planner.md)
