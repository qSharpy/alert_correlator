# Database Slow Queries

## Meaning
A high number of database queries are taking longer than expected to execute, exceeding the defined performance thresholds.

## Impact
- Increased API response times and latency
- Degraded user experience across affected services
- Increased database resource utilization
- Potential database connection pool exhaustion as connections are held longer
- Risk of query timeouts leading to application errors

## Diagnosis
1. Identify slow queries in the database:
```bash
# For PostgreSQL
psql -h <host> -U <user> -d <database> -c "SELECT query, calls, total_time, mean_time, max_time FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;"

# For MySQL
mysql -h <host> -u <user> -p<password> -e "SELECT * FROM performance_schema.events_statements_summary_by_digest ORDER BY avg_timer_wait DESC LIMIT 10;"
```

2. Check for missing indexes:
```bash
# For PostgreSQL
psql -h <host> -U <user> -d <database> -c "SELECT relname, seq_scan, seq_tup_read, idx_scan, idx_tup_fetch FROM pg_stat_user_tables ORDER BY seq_scan DESC LIMIT 10;"
```

3. Examine database resource utilization:
```bash
# Check CPU, memory, disk I/O in monitoring dashboard
```

4. Review recent schema or query changes:
```bash
# Check application deployment history or database change logs
```

## Mitigation
1. Immediate actions:
   - Identify and optimize the most problematic queries:
   ```bash
   # For PostgreSQL
   psql -h <host> -U <user> -d <database> -c "EXPLAIN ANALYZE <problematic-query>;"
   ```
   
   - Kill long-running queries if they're impacting service:
   ```bash
   # For PostgreSQL
   psql -h <host> -U <user> -d <database> -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE state = 'active' AND now() - query_start > '5 minutes'::interval;"
   ```

2. Short-term fixes:
   - Add missing indexes for frequently queried columns:
   ```sql
   CREATE INDEX idx_table_column ON table_name(column_name);
   ```
   
   - Optimize existing queries in application code
   
   - Implement query timeouts in application code

3. Long-term solutions:
   - Implement database query monitoring and performance analysis
   
   - Consider database read replicas to distribute query load
   
   - Implement caching strategies for frequently accessed data
   
   - Review and optimize database schema design
   
   - Consider database partitioning for large tables
   
   - Implement regular database maintenance (VACUUM, ANALYZE, etc.)
   
   - Establish query performance standards and review processes