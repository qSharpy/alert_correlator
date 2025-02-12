# High Query Latency

## Meaning
Grafana queries are taking longer than expected to execute, causing slow dashboard loading times and potential timeouts.

## Impact
- Degraded user experience
- Delayed access to critical metrics
- Increased system resource usage
- Potential dashboard timeouts
- Slower incident response times

## Diagnosis
1. Check query performance metrics:
```bash
# Via Grafana UI:
Dashboard > Panel > Query Inspector > Query Time
```

2. Monitor data source performance:
```bash
# For Prometheus
curl -s http://prometheus:9090/api/v1/query_range?query=rate(prometheus_engine_query_duration_seconds_sum[5m])

# For general database metrics
kubectl top pod -l app=grafana-datasource
```

3. Review system resources:
```bash
# Check CPU and Memory usage
kubectl top pod -l app=grafana

# Check storage IOPS (if applicable)
iostat -x 1
```

4. Analyze slow queries:
- Enable slow query logging
- Review query complexity
- Check time range and resolution

## Mitigation
1. Immediate optimization:
   - Reduce time range if possible
   - Optimize complex queries
   - Adjust panel refresh intervals
   - Clear dashboard cache

2. Query improvements:
   - Use appropriate time aggregations
   - Implement query caching
   - Break down complex queries
   - Use recording rules for expensive queries

3. Long-term solutions:
   - Scale data source resources
   - Implement query optimization guidelines
   - Set up query performance monitoring
   - Regular dashboard optimization reviews
   - Consider horizontal scaling for data sources