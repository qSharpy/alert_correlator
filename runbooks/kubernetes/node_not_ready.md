# Node Not Ready

## Meaning
A Kubernetes node has transitioned to NotReady state, indicating it's unable to accept new pods or properly manage existing ones.

## Impact
- Workloads on affected node may become unavailable
- Reduced cluster capacity
- Potential service degradation if multiple nodes are affected

## Diagnosis
1. Check node status and conditions:
```bash
kubectl get nodes
kubectl describe node <node-name>
```

2. Verify kubelet status on the affected node:
```bash
systemctl status kubelet
journalctl -u kubelet -n 100
```

3. Check node resources:
```bash
kubectl top node <node-name>
```

4. Review node events:
```bash
kubectl get events --field-selector involvedObject.name=<node-name>
```

## Mitigation
1. Ensure kubelet service is running and properly configured
2. Check for system resource exhaustion (disk space, memory, etc.)
3. Verify network connectivity between node and control plane
4. Review kubelet logs for error messages
5. If hardware related, consider cordoning the node and migrating workloads:
```bash
kubectl cordon <node-name>
kubectl drain <node-name> --ignore-daemonsets