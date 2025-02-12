# Data Source Connection Issues

## Meaning
Grafana is experiencing problems connecting to one or more configured data sources (Prometheus, Loki, etc.), resulting in panel errors or missing data.

## Impact
- Missing or incomplete metrics data
- Dashboard visualization errors
- False positive alerts
- Reduced monitoring capability

## Diagnosis
1. Check data source health:
```bash
# Via Grafana UI:
Configuration > Data Sources > Test connection
```

2. Verify data source endpoint accessibility:
```bash
# For Prometheus
curl -I http://prometheus:9090/-/healthy

# For Loki
curl -I http://loki:3100/ready
```

3. Review Grafana logs for connection errors:
```bash
# Container logs
kubectl logs -n monitoring -l app=grafana | grep "data source error"

# Or system logs
journalctl -u grafana-server | grep "data source error"
```

4. Check network connectivity:
```bash
# Test network reachability
nc -zv <datasource-host> <port>
```

## Mitigation
1. Immediate actions:
   - Verify data source credentials
   - Check network connectivity
   - Restart data source proxy if needed
   - Validate TLS certificates if used

2. Configuration checks:
   - Review data source URL configuration
   - Verify authentication settings
   - Check network policies/firewall rules
   - Validate proxy settings if applicable

3. Long-term prevention:
   - Implement data source health monitoring
   - Set up alerts for connection issues
   - Regular credential rotation
   - Document data source configurations
   - Maintain backup data source configurations