# High Query Load

## Meaning
Prometheus is experiencing an unusually high number of queries per second, indicating potential performance issues or query bottlenecks.

## Impact
High query load can lead to:
- Increased query latency
- Higher resource consumption
- Potential timeouts for dashboard and alert queries
- Degraded overall monitoring system performance

## Diagnosis
1. Check query performance metrics:
```bash
curl -s localhost:9090/api/v1/query?query=rate(prometheus_engine_query_duration_seconds_count[5m])
```

2. Review active queries and their duration:
```bash
curl -s localhost:9090/api/v1/query?query=prometheus_engine_queries
```

3. Analyze query patterns in Prometheus logs:
```bash
kubectl logs -l app=prometheus -c prometheus
```

## Mitigation
1. Optimize expensive queries by adding recording rules
2. Implement query caching if not already in place
3. Consider horizontal scaling of Prometheus
4. Review and adjust scrape intervals if necessary
5. Implement rate limiting for query endpoints