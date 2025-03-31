# Database Disk Space Critical

## Meaning
The database server is running critically low on disk space, approaching the point where it may be unable to write new data or perform essential operations.

## Impact
- Risk of database becoming read-only or completely unavailable
- Failed write operations leading to application errors
- Degraded database performance due to limited working space
- Potential data corruption if the database cannot complete write operations
- Risk of cascading failures across all dependent services

## Diagnosis
1. Check current disk usage:
```bash
# For server hosting the database
ssh <database-server> "df -h"

# For containerized database
kubectl exec -it <database-pod> -n <namespace> -- df -h
```

2. Identify largest database objects:
```bash
# For PostgreSQL
psql -h <host> -U <user> -d <database> -c "SELECT relname, pg_size_pretty(pg_total_relation_size(relid)) AS size FROM pg_catalog.pg_statio_user_tables ORDER BY pg_total_relation_size(relid) DESC LIMIT 10;"

# For MySQL
mysql -h <host> -u <user> -p<password> -e "SELECT table_schema, table_name, ROUND(data_length/1024/1024,2) AS data_size_mb, ROUND(index_length/1024/1024,2) AS index_size_mb FROM information_schema.tables ORDER BY data_length + index_length DESC LIMIT 10;"
```

3. Check for large log files:
```bash
ssh <database-server> "find /var/log -type f -name '*.log' -size +100M | xargs ls -lh"
```

4. Examine disk usage trends:
```bash
# Check disk usage metrics in monitoring dashboard
```

## Mitigation
1. Immediate actions:
   - Free up disk space by removing unnecessary files:
   ```bash
   # Remove old log files
   ssh <database-server> "find /var/log -name '*.log.*' -mtime +7 -delete"
   
   # Clean up temporary files
   ssh <database-server> "rm -rf /tmp/*"
   ```
   
   - Rotate and compress database logs:
   ```bash
   # For PostgreSQL
   psql -h <host> -U <user> -d <database> -c "SELECT pg_rotate_logfile();"
   ```
   
   - If using cloud storage, increase disk size:
   ```bash
   # Depends on cloud provider and database service
   ```

2. Short-term fixes:
   - Archive and remove old data if possible:
   ```sql
   -- Example: Archive and delete old data
   CREATE TABLE archived_data_202X AS SELECT * FROM current_data WHERE created_at < '202X-01-01';
   DELETE FROM current_data WHERE created_at < '202X-01-01';
   ```
   
   - Clean up database bloat:
   ```bash
   # For PostgreSQL
   psql -h <host> -U <user> -d <database> -c "VACUUM FULL;"
   ```
   
   - Add additional storage if possible

3. Long-term solutions:
   - Implement data retention policies
   
   - Set up automated cleanup jobs for old data
   
   - Consider database partitioning for easier management of large tables
   
   - Implement proper monitoring with predictive alerts before space becomes critical
   
   - Develop a data archiving strategy
   
   - Consider horizontal scaling or sharding for very large datasets