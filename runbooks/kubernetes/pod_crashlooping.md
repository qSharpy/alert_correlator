# Pod CrashLooping

## Meaning
Pods are repeatedly crashing and restarting, indicating a critical issue with the application or its configuration.

## Impact
- Service disruption for affected applications
- Increased load on the cluster due to continuous restart attempts
- Potential cascade effects on dependent services

## Diagnosis
1. Check pod status and recent events:
```bash
kubectl get pods -n <namespace>
kubectl describe pod <pod-name> -n <namespace>
```

2. Review pod logs for error messages:
```bash
kubectl logs <pod-name> -n <namespace> --previous
```

3. Check resource usage:
```bash
kubectl top pod <pod-name> -n <namespace>
```

## Mitigation
1. Review application logs to identify the root cause
2. Verify resource limits and requests are properly set
3. Check for configuration issues in the deployment manifest
4. Ensure all required dependencies (ConfigMaps, Secrets, etc.) are available
5. Consider rolling back to the last known good deployment if necessary