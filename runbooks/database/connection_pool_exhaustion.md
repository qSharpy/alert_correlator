# Database Connection Pool Exhaustion

## Meaning
The database connection pool is nearing or has reached its maximum capacity, preventing new connections from being established.

## Impact
- API services unable to connect to the database, resulting in errors
- Increased latency for database operations as connections are queued
- Potential application timeouts waiting for available connections
- Degraded user experience across multiple services

## Diagnosis
1. Check current connection pool usage:
```bash
# For PostgreSQL
psql -h <host> -U <user> -d <database> -c "SELECT count(*) FROM pg_stat_activity;"

# For MySQL
mysql -h <host> -u <user> -p<password> -e "SHOW STATUS LIKE 'Threads_connected';"
```

2. Identify which applications or services are consuming connections:
```bash
# For PostgreSQL
psql -h <host> -U <user> -d <database> -c "SELECT client_addr, usename, count(*) FROM pg_stat_activity GROUP BY client_addr, usename ORDER BY count(*) DESC;"
```

3. Check for connection leaks in application logs:
```bash
kubectl logs -l app=<service-name> -n <namespace> | grep -i "connection\|pool\|database"
```

4. Monitor connection time metrics:
```bash
# Check database connection metrics in monitoring dashboard
```

## Mitigation
1. Immediate actions:
   - Restart problematic services that may be leaking connections:
   ```bash
   kubectl rollout restart deployment/<service-name> -n <namespace>
   ```
   
   - Terminate idle connections if necessary:
   ```bash
   # For PostgreSQL
   psql -h <host> -U <user> -d <database> -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE state = 'idle' AND state_change < NOW() - INTERVAL '30 minutes';"
   ```

2. Short-term fixes:
   - Increase connection pool size temporarily:
   ```bash
   # Update the configuration in your application deployment
   kubectl edit deployment/<service-name> -n <namespace>
   ```
   
   - Implement connection pooling at the application level if not already in place

3. Long-term solutions:
   - Review and optimize application connection management:
     - Ensure connections are properly closed after use
     - Implement connection pooling best practices
     - Consider using a connection proxy (e.g., PgBouncer, ProxySQL)
   
   - Adjust connection pool sizes based on actual needs
   
   - Implement proper monitoring and alerting for connection pool metrics
   
   - Consider database read replicas to distribute query load