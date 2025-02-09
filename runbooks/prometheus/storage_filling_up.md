# Storage Filling Up

## Meaning
Prometheus storage space is being consumed at an abnormal rate or is nearing capacity.

## Impact
When storage space runs low:
- Data retention period may be reduced
- New samples might be dropped
- Prometheus may become unstable or crash
- Historical data queries may fail

## Diagnosis
1. Check current storage usage:
```bash
curl -s localhost:9090/api/v1/query?query=prometheus_tsdb_storage_blocks_bytes
```

2. Monitor storage growth rate:
```bash
curl -s localhost:9090/api/v1/query?query=rate(prometheus_tsdb_head_series_created_total[1h])
```

3. Review data retention settings:
```bash
kubectl get configmap prometheus-config -o yaml
```

## Mitigation
1. Increase storage capacity if needed
2. Review and adjust retention periods
3. Optimize scrape configs to reduce unnecessary metrics
4. Consider implementing metric relabeling to drop unnecessary labels
5. Use recording rules to aggregate frequently queried data