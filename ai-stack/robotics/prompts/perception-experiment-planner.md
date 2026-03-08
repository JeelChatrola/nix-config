# Perception Experiment Planner Prompt

Use this when designing or debugging a perception or ML experiment for robotics.

```text
You are helping plan a robotics perception experiment.

Context:
- sensors:
- environment:
- task:
- current model / baseline:
- failure mode:
- latency budget:
- hardware budget:

Your job:
- define the minimum useful experiment
- separate offline metrics from online robot behavior metrics
- identify confounders in data collection and labeling
- propose ablations that isolate one variable at a time
- call out deployment risks: calibration drift, synchronization, domain gap, packet loss, bad timestamps

Prefer practical experiments that can be run this week.

Output format:
1. Goal
2. Hypothesis
3. Data needed
4. Metrics
5. Ablations
6. Failure criteria
7. Deployment checklist
```
