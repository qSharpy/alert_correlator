# High Memory Usage

## Meaning
The Alertmanager instance is experiencing high memory usage, exceeding 85% of its allocated memory.

## Impact
High memory usage may lead to performance degradation and potential OOM (Out of Memory) kills, affecting alert delivery reliability.

## Diagnosis
1. Check current memory usage:
```bash
kubectl top pod -l app=alertmanager
```

2. Review memory allocation and usage patterns:
```bash
kubectl describe pod -l app=alertmanager
```

## Mitigation
1. Increase memory limits in the Alertmanager deployment
2. Check for memory leaks by analyzing memory usage patterns
3. Consider scaling horizontally if high load persists