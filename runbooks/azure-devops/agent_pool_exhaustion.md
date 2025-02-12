# Agent Pool Exhaustion

## Meaning
The Azure DevOps agent pool is running at or near capacity, causing pipeline queuing and delays.

## Impact
- Increased pipeline wait times
- Delayed builds and deployments
- Reduced team productivity
- Potential deployment SLA breaches

## Diagnosis
1. Check agent pool utilization:
```bash
# Via Azure DevOps UI:
Project Settings > Agent Pools > Select pool > View metrics
```

2. Review current queue status:
```bash
# Via Azure DevOps UI:
Pipelines > Jobs > Check queued jobs
```

3. Analyze agent health:
- Check agent status (online/offline)
- Review agent capabilities
- Monitor agent job history

4. Review concurrent pipeline patterns:
- Peak usage times
- Long-running jobs
- Resource-intensive pipelines

## Mitigation
1. Immediate actions:
   - Cancel unnecessary queued jobs
   - Prioritize critical pipelines
   - Temporarily increase agent count if possible

2. Short-term solutions:
   - Add more agents to the pool
   - Optimize pipeline concurrent job limits
   - Review and adjust job timeouts

3. Long-term prevention:
   - Implement auto-scaling for agent pools
   - Monitor agent pool metrics
   - Optimize pipeline execution times
   - Consider separate pools for different job types
   - Set up alerts for pool utilization thresholds