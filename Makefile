.PHONY: all alertmanager azure-devops grafana kubernetes prometheus microservices database network cascade high-volume mixed-severity api-gateway distributed-tracing

# Default target to show help
help:
	@echo "Available targets:"
	@echo "  make all              - Trigger all alert categories"
	@echo "  make alertmanager     - Trigger AlertManager-related alerts"
	@echo "  make ado              - Trigger Azure DevOps-related alerts"
	@echo "  make grafana          - Trigger Grafana-related alerts"
	@echo "  make kubernetes       - Trigger Kubernetes-related alerts"
	@echo "  make prometheus       - Trigger Prometheus-related alerts"
	@echo "  make microservices    - Trigger microservice-related alerts (API failures, latency issues)"
	@echo "  make database         - Trigger database-related alerts (connection issues, slow queries)"
	@echo "  make network          - Trigger network-related alerts (DNS failures, connectivity issues)"
	@echo "  make cascade          - Simulate a cascading failure across multiple systems"
	@echo "  make high-volume      - Generate a high volume of alerts to test correlation capabilities"
	@echo "  make mixed-severity   - Generate a mix of related alerts with different severity levels"
	@echo "  make api-gateway      - Simulate API gateway failures affecting multiple downstream services"
	@echo "  make distributed-tracing - Simulate tracing-related alerts showing request flow issues"
	@echo "  make real-world       - Simulate a complex real-world incident with multiple related alerts"

# Target to trigger all basic alerts
all: alertmanager azure-devops grafana kubernetes prometheus

# Target to trigger all complex scenarios
complex: microservices database network cascade high-volume mixed-severity api-gateway distributed-tracing real-world

# AlertManager alerts
alertmanager:
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "AlertManagerHighMemory", \
			"severity": "critical", \
			"job": "alertmanager", \
			"instance": "alertmanager-main", \
			"runbook": "http://localhost:3002/#alertmanager/high_memory_usage", \
			"memory_usage": "85", \
			"threshold": "80" \
		}, \
		"annotations": { \
			"description": "AlertManager instance alertmanager-main is using 85% memory, exceeding the 80% threshold. This may impact alert processing and notification delivery.", \
			"runbook_url": "http://localhost:3002/#alertmanager/high_memory_usage" \
		}, \
		"startsAt": "2024-02-12T19:50:00Z" \
	  } \
	]'
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "AlertManagerNotificationFailures", \
			"severity": "warning", \
			"job": "alertmanager", \
			"instance": "alertmanager-main", \
			"runbook": "http://localhost:3002/#alertmanager/notification_failures", \
			"failure_count": "25", \
			"threshold": "10" \
		}, \
		"annotations": { \
			"description": "AlertManager has failed to deliver 25 notifications in the last hour, exceeding the threshold of 10. This indicates issues with notification delivery mechanisms.", \
			"runbook_url": "http://localhost:3002/#alertmanager/notification_failures" \
		}, \
		"startsAt": "2024-02-12T19:50:00Z" \
	  } \
	]'

# Azure DevOps alerts
ado:
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "AzureDevOpsAgentPoolExhaustion", \
			"severity": "critical", \
			"job": "azure-devops", \
			"instance": "azure-devops-pool-1", \
			"runbook": "http://localhost:3002/#azure-devops/agent_pool_exhaustion", \
			"available_agents": "2", \
			"threshold": "5" \
		}, \
		"annotations": { \
			"description": "Azure DevOps agent pool azure-devops-pool-1 has only 2 available agents, below the minimum threshold of 5. This may cause pipeline execution delays.", \
			"runbook_url": "http://localhost:3002/#azure-devops/agent_pool_exhaustion" \
		}, \
		"startsAt": "2024-02-12T19:50:00Z" \
	  } \
	]'
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "AzureDevOpsPipelineFailures", \
			"severity": "warning", \
			"job": "azure-devops", \
			"instance": "project-main", \
			"runbook": "http://localhost:3002/#azure-devops/pipeline_failures", \
			"failure_count": "5", \
			"threshold": "3" \
		}, \
		"annotations": { \
			"description": "5 pipeline failures detected in the last hour for project-main, exceeding the threshold of 3 failures. This may indicate systemic issues in the build or deployment process.", \
			"runbook_url": "http://localhost:3002/#azure-devops/pipeline_failures" \
		}, \
		"startsAt": "2024-02-12T19:50:00Z" \
	  } \
	]'

# Grafana alerts
grafana:
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "GrafanaDashboardLoadFailures", \
			"severity": "warning", \
			"job": "grafana", \
			"instance": "grafana-main", \
			"runbook": "http://localhost:3002/#grafana/dashboard_loading_failures", \
			"failure_count": "15", \
			"threshold": "10" \
		}, \
		"annotations": { \
			"description": "15 dashboard loading failures detected in Grafana instance grafana-main in the last 10 minutes. This may indicate issues with data sources or dashboard configurations.", \
			"runbook_url": "http://localhost:3002/#grafana/dashboard_loading_failures" \
		}, \
		"startsAt": "2024-02-12T19:50:00Z" \
	  } \
	]'
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "GrafanaHighQueryLatency", \
			"severity": "warning", \
			"job": "grafana", \
			"instance": "grafana-main", \
			"runbook": "http://localhost:3002/#grafana/high_query_latency", \
			"latency": "5000", \
			"threshold": "3000" \
		}, \
		"annotations": { \
			"description": "Grafana queries are taking 5000ms on average, exceeding the threshold of 3000ms. This is causing slow dashboard loading times.", \
			"runbook_url": "http://localhost:3002/#grafana/high_query_latency" \
		}, \
		"startsAt": "2024-02-12T19:50:00Z" \
	  } \
	]'

# Kubernetes alerts
kubernetes:
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "KubernetesNodeNotReady", \
			"severity": "critical", \
			"job": "kubernetes", \
			"instance": "node-1", \
			"runbook": "http://localhost:3002/#kubernetes/node_not_ready", \
			"duration": "300", \
			"threshold": "180" \
		}, \
		"annotations": { \
			"description": "Node node-1 has been in NotReady state for 300 seconds, exceeding the threshold of 180 seconds. This may impact workload availability.", \
			"runbook_url": "http://localhost:3002/#kubernetes/node_not_ready" \
		}, \
		"startsAt": "2024-02-12T19:50:00Z" \
	  } \
	]'
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "KubernetesPodCrashLooping", \
			"severity": "critical", \
			"job": "kubernetes", \
			"instance": "app-pod-1", \
			"runbook": "http://localhost:3002/#kubernetes/pod_crashlooping", \
			"restart_count": "5", \
			"threshold": "3" \
		}, \
		"annotations": { \
			"description": "Pod app-pod-1 has restarted 5 times in the last 10 minutes, exceeding the threshold of 3 restarts. This indicates application stability issues.", \
			"runbook_url": "http://localhost:3002/#kubernetes/pod_crashlooping" \
		}, \
		"startsAt": "2024-02-12T19:50:00Z" \
	  } \
	]'

# Prometheus alerts
prometheus:
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "PrometheusHighQueryLoad", \
			"severity": "warning", \
			"job": "prometheus", \
			"instance": "prometheus-k8s-0", \
			"runbook": "http://localhost:3002/#prometheus/high_query_load", \
			"query_rate": "1250", \
			"threshold": "1000", \
			"metric": "prometheus_engine_queries" \
		}, \
		"annotations": { \
			"description": "Prometheus instance prometheus-k8s-0 is experiencing high query load with 1250 queries/sec exceeding the threshold of 1000 queries/sec. This may impact monitoring system performance and query response times.", \
			"runbook_url": "http://localhost:3002/#prometheus/high_query_load" \
		}, \
		"startsAt": "2024-02-12T19:50:00Z" \
	  } \
	]'
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "PrometheusStorageFillingUp", \
			"severity": "critical", \
			"job": "prometheus", \
			"instance": "prometheus-k8s-0", \
			"runbook": "http://localhost:3002/#prometheus/storage_filling_up", \
			"storage_used": "85", \
			"threshold": "80" \
		}, \
		"annotations": { \
			"description": "Prometheus instance prometheus-k8s-0 storage is 85% full, exceeding the threshold of 80%. This may lead to data retention issues if not addressed.", \
			"runbook_url": "http://localhost:3002/#prometheus/storage_filling_up" \
		}, \
		"startsAt": "2024-02-12T19:50:00Z" \
	  } \
	]'

# Microservice alerts - simulates issues across multiple API services
microservices:
	@echo "Generating microservice alerts for multiple APIs..."
	# User Service API failures
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "APIHighErrorRate", \
			"severity": "critical", \
			"job": "api-monitoring", \
			"instance": "user-service", \
			"service": "user-api", \
			"endpoint": "/api/v2/users", \
			"error_rate": "15.5", \
			"threshold": "5", \
			"environment": "production" \
		}, \
		"annotations": { \
			"description": "User Service API is experiencing a 15.5% error rate on endpoint /api/v2/users, exceeding the threshold of 5%. This is affecting user authentication flows.", \
			"summary": "High error rate on User Service API" \
		}, \
		"startsAt": "2024-02-12T19:50:00Z" \
	  } \
	]'
	# Payment Service API latency
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "APIHighLatency", \
			"severity": "warning", \
			"job": "api-monitoring", \
			"instance": "payment-service", \
			"service": "payment-api", \
			"endpoint": "/api/v1/transactions", \
			"latency": "2500", \
			"threshold": "1000", \
			"environment": "production" \
		}, \
		"annotations": { \
			"description": "Payment Service API is experiencing high latency (2500ms) on endpoint /api/v1/transactions, exceeding the threshold of 1000ms. This is causing payment processing delays.", \
			"summary": "High latency on Payment Service API" \
		}, \
		"startsAt": "2024-02-12T19:50:30Z" \
	  } \
	]'
	# Inventory Service API failures
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "APIHighErrorRate", \
			"severity": "critical", \
			"job": "api-monitoring", \
			"instance": "inventory-service", \
			"service": "inventory-api", \
			"endpoint": "/api/v1/products/availability", \
			"error_rate": "25.3", \
			"threshold": "5", \
			"environment": "production" \
		}, \
		"annotations": { \
			"description": "Inventory Service API is experiencing a 25.3% error rate on endpoint /api/v1/products/availability, exceeding the threshold of 5%. This is affecting product availability checks.", \
			"summary": "High error rate on Inventory Service API" \
		}, \
		"startsAt": "2024-02-12T19:51:00Z" \
	  } \
	]'
	# Recommendation Service API high CPU
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "APIHighCPUUsage", \
			"severity": "warning", \
			"job": "api-monitoring", \
			"instance": "recommendation-service", \
			"service": "recommendation-api", \
			"cpu_usage": "92.5", \
			"threshold": "80", \
			"environment": "production" \
		}, \
		"annotations": { \
			"description": "Recommendation Service API is experiencing high CPU usage (92.5%), exceeding the threshold of 80%. This may impact recommendation quality and response times.", \
			"summary": "High CPU usage on Recommendation Service API" \
		}, \
		"startsAt": "2024-02-12T19:51:30Z" \
	  } \
	]'
	# Notification Service API circuit breaker
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "APICircuitBreakerOpen", \
			"severity": "critical", \
			"job": "api-monitoring", \
			"instance": "notification-service", \
			"service": "notification-api", \
			"circuit": "email-sender", \
			"failure_rate": "65.8", \
			"threshold": "50", \
			"environment": "production" \
		}, \
		"annotations": { \
			"description": "Notification Service API circuit breaker for email-sender is open due to 65.8% failure rate, exceeding the threshold of 50%. Email notifications are not being delivered.", \
			"summary": "Circuit breaker open on Notification Service API" \
		}, \
		"startsAt": "2024-02-12T19:52:00Z" \
	  } \
	]'

# Database alerts - simulates database issues affecting APIs
database:
	@echo "Generating database alerts affecting multiple services..."
	# Primary database connection issues
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "DatabaseConnectionPoolExhaustion", \
			"severity": "critical", \
			"job": "database-monitoring", \
			"instance": "postgres-primary", \
			"database": "user_db", \
			"connection_usage": "95", \
			"threshold": "80", \
			"environment": "production" \
		}, \
		"annotations": { \
			"description": "Primary PostgreSQL database connection pool is 95% exhausted, exceeding the threshold of 80%. This is causing connection timeouts for multiple services.", \
			"summary": "Database connection pool exhaustion" \
		}, \
		"startsAt": "2024-02-12T19:50:00Z" \
	  } \
	]'
	# Slow queries affecting multiple services
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "DatabaseSlowQueries", \
			"severity": "warning", \
			"job": "database-monitoring", \
			"instance": "postgres-primary", \
			"database": "transaction_db", \
			"query_count": "35", \
			"threshold": "10", \
			"environment": "production" \
		}, \
		"annotations": { \
			"description": "35 slow queries detected on transaction_db in the last 5 minutes, exceeding the threshold of 10. This is affecting payment and order processing APIs.", \
			"summary": "High number of slow database queries" \
		}, \
		"startsAt": "2024-02-12T19:50:30Z" \
	  } \
	]'
	# Database replication lag
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "DatabaseReplicationLag", \
			"severity": "warning", \
			"job": "database-monitoring", \
			"instance": "postgres-replica-2", \
			"database": "product_db", \
			"lag_seconds": "120", \
			"threshold": "30", \
			"environment": "production" \
		}, \
		"annotations": { \
			"description": "Database replica postgres-replica-2 is lagging 120 seconds behind primary, exceeding the threshold of 30 seconds. This may cause stale data in read-heavy APIs.", \
			"summary": "Database replication lag detected" \
		}, \
		"startsAt": "2024-02-12T19:51:00Z" \
	  } \
	]'
	# Database disk space
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "DatabaseDiskSpaceCritical", \
			"severity": "critical", \
			"job": "database-monitoring", \
			"instance": "postgres-primary", \
			"database": "all", \
			"disk_usage": "92", \
			"threshold": "85", \
			"environment": "production" \
		}, \
		"annotations": { \
			"description": "Primary database server disk usage is at 92%, exceeding the critical threshold of 85%. This may lead to database outage affecting all services.", \
			"summary": "Critical database disk space" \
		}, \
		"startsAt": "2024-02-12T19:51:30Z" \
	  } \
	]'

# Network alerts - simulates network issues affecting API connectivity
network:
	@echo "Generating network-related alerts..."
	# DNS resolution failures
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "DNSResolutionFailures", \
			"severity": "critical", \
			"job": "network-monitoring", \
			"instance": "dns-cluster-1", \
			"failure_count": "156", \
			"threshold": "50", \
			"environment": "production" \
		}, \
		"annotations": { \
			"description": "156 DNS resolution failures detected in the last 5 minutes, exceeding the threshold of 50. This is affecting service discovery and API connectivity.", \
			"summary": "DNS resolution failures detected" \
		}, \
		"startsAt": "2024-02-12T19:50:00Z" \
	  } \
	]'
	# Load balancer health check failures
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "LoadBalancerHealthCheckFailures", \
			"severity": "critical", \
			"job": "network-monitoring", \
			"instance": "lb-api-cluster", \
			"failed_nodes": "3", \
			"total_nodes": "5", \
			"environment": "production" \
		}, \
		"annotations": { \
			"description": "3 out of 5 nodes failing health checks on API load balancer cluster. This is causing reduced capacity and potential API timeouts.", \
			"summary": "Load balancer health check failures" \
		}, \
		"startsAt": "2024-02-12T19:50:30Z" \
	  } \
	]'
	# Network latency between services
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "NetworkLatencyHigh", \
			"severity": "warning", \
			"job": "network-monitoring", \
			"source": "api-zone", \
			"destination": "database-zone", \
			"latency_ms": "25", \
			"threshold": "10", \
			"environment": "production" \
		}, \
		"annotations": { \
			"description": "High network latency (25ms) detected between API zone and database zone, exceeding the threshold of 10ms. This is affecting database query performance across multiple services.", \
			"summary": "High network latency between zones" \
		}, \
		"startsAt": "2024-02-12T19:51:00Z" \
	  } \
	]'
	# Network packet loss
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "NetworkPacketLoss", \
			"severity": "critical", \
			"job": "network-monitoring", \
			"instance": "edge-router-1", \
			"packet_loss": "5.8", \
			"threshold": "1", \
			"environment": "production" \
		}, \
		"annotations": { \
			"description": "5.8% packet loss detected at edge-router-1, exceeding the threshold of 1%. This is causing intermittent API failures and timeouts.", \
			"summary": "Network packet loss detected" \
		}, \
		"startsAt": "2024-02-12T19:51:30Z" \
	  } \
	]'

# Cascading failure scenario - simulates a complex incident with cascading effects
cascade:
	@echo "Simulating cascading failure across multiple systems..."
	# Initial database CPU spike
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "DatabaseHighCPU", \
			"severity": "warning", \
			"job": "database-monitoring", \
			"instance": "postgres-primary", \
			"database": "all", \
			"cpu_usage": "85", \
			"threshold": "75", \
			"environment": "production", \
			"incident_id": "INC-2024-03-28-001" \
		}, \
		"annotations": { \
			"description": "Primary database server CPU usage at 85%, exceeding the warning threshold of 75%. Investigating cause.", \
			"summary": "High CPU usage on primary database" \
		}, \
		"startsAt": "2024-02-12T19:50:00Z" \
	  } \
	]'
	sleep 2
	# Database connection pool exhaustion follows
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "DatabaseConnectionPoolExhaustion", \
			"severity": "critical", \
			"job": "database-monitoring", \
			"instance": "postgres-primary", \
			"database": "all", \
			"connection_usage": "98", \
			"threshold": "80", \
			"environment": "production", \
			"incident_id": "INC-2024-03-28-001" \
		}, \
		"annotations": { \
			"description": "Primary database connection pool is 98% exhausted, exceeding the critical threshold of 80%. This is causing connection timeouts.", \
			"summary": "Database connection pool exhaustion" \
		}, \
		"startsAt": "2024-02-12T19:50:30Z" \
	  } \
	]'
	sleep 2
	# API services start failing due to DB issues
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "APIHighErrorRate", \
			"severity": "critical", \
			"job": "api-monitoring", \
			"instance": "user-service", \
			"service": "user-api", \
			"endpoint": "/api/v2/users", \
			"error_rate": "75.5", \
			"threshold": "5", \
			"environment": "production", \
			"incident_id": "INC-2024-03-28-001" \
		}, \
		"annotations": { \
			"description": "User Service API is experiencing a 75.5% error rate on endpoint /api/v2/users, exceeding the threshold of 5%. Database connection failures detected.", \
			"summary": "Critical error rate on User Service API" \
		}, \
		"startsAt": "2024-02-12T19:51:00Z" \
	  } \
	]'
	sleep 2
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "APIHighErrorRate", \
			"severity": "critical", \
			"job": "api-monitoring", \
			"instance": "payment-service", \
			"service": "payment-api", \
			"endpoint": "/api/v1/transactions", \
			"error_rate": "82.3", \
			"threshold": "5", \
			"environment": "production", \
			"incident_id": "INC-2024-03-28-001" \
		}, \
		"annotations": { \
			"description": "Payment Service API is experiencing a 82.3% error rate on endpoint /api/v1/transactions, exceeding the threshold of 5%. Database connection failures detected.", \
			"summary": "Critical error rate on Payment Service API" \
		}, \
		"startsAt": "2024-02-12T19:51:15Z" \
	  } \
	]'
	sleep 2
	# Frontend application errors due to API failures
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "FrontendErrorRate", \
			"severity": "critical", \
			"job": "frontend-monitoring", \
			"instance": "web-app", \
			"error_rate": "65.2", \
			"threshold": "10", \
			"environment": "production", \
			"incident_id": "INC-2024-03-28-001" \
		}, \
		"annotations": { \
			"description": "Frontend web application is experiencing a 65.2% error rate, exceeding the threshold of 10%. Multiple API dependencies are failing.", \
			"summary": "Critical error rate on frontend application" \
		}, \
		"startsAt": "2024-02-12T19:51:45Z" \
	  } \
	]'
	sleep 2
	# Customer impact alert
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "CustomerImpact", \
			"severity": "critical", \
			"job": "business-monitoring", \
			"instance": "customer-experience", \
			"affected_users": "15000", \
			"threshold": "1000", \
			"environment": "production", \
			"incident_id": "INC-2024-03-28-001" \
		}, \
		"annotations": { \
			"description": "Approximately 15,000 users are experiencing service disruption, exceeding the threshold of 1,000. Multiple core services are unavailable.", \
			"summary": "Critical customer impact detected" \
		}, \
		"startsAt": "2024-02-12T19:52:00Z" \
	  } \
	]'

# High volume alert scenario - generates many alerts in a short time
high-volume:
	@echo "Generating high volume of alerts to test correlation capabilities..."
	for i in $$(seq 1 20); do \
		curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d "[ \
		  { \
			\"labels\": { \
				\"alertname\": \"APIHighErrorRate\", \
				\"severity\": \"warning\", \
				\"job\": \"api-monitoring\", \
				\"instance\": \"api-service-$${i}\", \
				\"service\": \"api-$${i}\", \
				\"endpoint\": \"/api/v1/endpoint-$${i}\", \
				\"error_rate\": \"$$(( 10 + RANDOM % 20 ))\", \
				\"threshold\": \"5\", \
				\"environment\": \"production\", \
				\"region\": \"$$([ $$((i % 3)) -eq 0 ] && echo 'us-east' || ([ $$((i % 3)) -eq 1 ] && echo 'us-west' || echo 'eu-central'))\", \
				\"cluster\": \"$$([ $$((i % 2)) -eq 0 ] && echo 'cluster-a' || echo 'cluster-b')\" \
			}, \
			\"annotations\": { \
				\"description\": \"API service api-service-$${i} is experiencing high error rate on endpoint /api/v1/endpoint-$${i}.\", \
				\"summary\": \"High error rate on API service $${i}\" \
			}, \
			\"startsAt\": \"2024-02-12T19:50:00Z\" \
		  } \
		]"; \
	done

# Mixed severity alerts - generates related alerts with different severity levels
mixed-severity:
	@echo "Generating mixed severity alerts for the same underlying issue..."
	# Info level - initial observation
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "StorageUtilizationIncreasing", \
			"severity": "info", \
			"job": "storage-monitoring", \
			"instance": "storage-cluster-1", \
			"growth_rate": "5", \
			"threshold": "10", \
			"environment": "production", \
			"incident_id": "INC-2024-03-28-002" \
		}, \
		"annotations": { \
			"description": "Storage utilization growth rate is 5% per hour, approaching the warning threshold of 10% per hour.", \
			"summary": "Storage utilization increasing" \
		}, \
		"startsAt": "2024-02-12T19:50:00Z" \
	  } \
	]'
	sleep 2
	# Warning level - situation worsening
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "StorageUtilizationHigh", \
			"severity": "warning", \
			"job": "storage-monitoring", \
			"instance": "storage-cluster-1", \
			"utilization": "75", \
			"threshold": "70", \
			"environment": "production", \
			"incident_id": "INC-2024-03-28-002" \
		}, \
		"annotations": { \
			"description": "Storage cluster utilization is at 75%, exceeding the warning threshold of 70%.", \
			"summary": "High storage utilization" \
		}, \
		"startsAt": "2024-02-12T19:51:00Z" \
	  } \
	]'
	sleep 2
	# Critical level - full impact
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "StorageUtilizationCritical", \
			"severity": "critical", \
			"job": "storage-monitoring", \
			"instance": "storage-cluster-1", \
			"utilization": "92", \
			"threshold": "85", \
			"environment": "production", \
			"incident_id": "INC-2024-03-28-002" \
		}, \
		"annotations": { \
			"description": "Storage cluster utilization is at 92%, exceeding the critical threshold of 85%. Service disruption imminent.", \
			"summary": "Critical storage utilization" \
		}, \
		"startsAt": "2024-02-12T19:52:00Z" \
	  } \
	]'
	sleep 2
	# Related service impact
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "APISlowResponses", \
			"severity": "warning", \
			"job": "api-monitoring", \
			"instance": "content-delivery-api", \
			"service": "media-service", \
			"latency": "1500", \
			"threshold": "1000", \
			"environment": "production", \
			"incident_id": "INC-2024-03-28-002" \
		}, \
		"annotations": { \
			"description": "Content Delivery API is experiencing slow responses (1500ms) due to storage subsystem issues.", \
			"summary": "Slow API responses due to storage issues" \
		}, \
		"startsAt": "2024-02-12T19:52:30Z" \
	  } \
	]'

# API Gateway scenario - simulates API gateway issues affecting multiple downstream services
api-gateway:
	@echo "Simulating API gateway issues affecting multiple downstream services..."
	# Initial gateway high CPU
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "APIGatewayHighCPU", \
			"severity": "warning", \
			"job": "api-gateway-monitoring", \
			"instance": "gateway-prod-1", \
			"cpu_usage": "85", \
			"threshold": "75", \
			"environment": "production", \
			"incident_id": "INC-2024-03-28-003" \
		}, \
		"annotations": { \
			"description": "API Gateway instance gateway-prod-1 is experiencing high CPU usage (85%), exceeding the warning threshold of 75%.", \
			"summary": "High CPU usage on API Gateway" \
		}, \
		"startsAt": "2024-02-12T19:50:00Z" \
	  } \
	]'
	sleep 2
	# Gateway request throttling
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "APIGatewayThrottling", \
			"severity": "critical", \
			"job": "api-gateway-monitoring", \
			"instance": "gateway-prod-1", \
			"throttled_requests": "1250", \
			"threshold": "500", \
			"environment": "production", \
			"incident_id": "INC-2024-03-28-003" \
		}, \
		"annotations": { \
			"description": "API Gateway is throttling 1250 requests per minute, exceeding the threshold of 500. This is affecting multiple downstream services.", \
			"summary": "API Gateway request throttling" \
		}, \
		"startsAt": "2024-02-12T19:50:30Z" \
	  } \
	]'
	sleep 2
	# Multiple downstream service impacts
	for service in "user" "payment" "inventory" "order" "notification"; do \
		curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d "[ \
		  { \
			\"labels\": { \
				\"alertname\": \"APIGatewayDependencyFailure\", \
				\"severity\": \"critical\", \
				\"job\": \"api-monitoring\", \
				\"instance\": \"$${service}-service\", \
				\"service\": \"$${service}-api\", \
				\"dependency\": \"api-gateway\", \
				\"error_rate\": \"$$(( 70 + RANDOM % 25 ))\", \
				\"threshold\": \"10\", \
				\"environment\": \"production\", \
				\"incident_id\": \"INC-2024-03-28-003\" \
			}, \
			\"annotations\": { \
				\"description\": \"$${service}-service is experiencing high error rates due to API Gateway dependency failures.\", \
				\"summary\": \"$${service} service affected by API Gateway issues\" \
			}, \
			\"startsAt\": \"2024-02-12T19:51:00Z\" \
		  } \
		]"; \
		sleep 1; \
	done

# Distributed tracing scenario - simulates issues visible through distributed tracing
distributed-tracing:
	@echo "Simulating distributed tracing alerts showing request flow issues..."
	# High latency in service chain
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "HighServiceChainLatency", \
			"severity": "warning", \
			"job": "tracing-monitoring", \
			"trace_id": "8a7b6c5d4e3f2a1b", \
			"service_chain": "gateway->auth->user->payment", \
			"latency_ms": "2500", \
			"threshold": "1000", \
			"environment": "production", \
			"incident_id": "INC-2024-03-28-004" \
		}, \
		"annotations": { \
			"description": "Service chain gateway->auth->user->payment is experiencing high end-to-end latency (2500ms), exceeding the threshold of 1000ms.", \
			"summary": "High latency in service request chain" \
		}, \
		"startsAt": "2024-02-12T19:50:00Z" \
	  } \
	]'
	sleep 2
	# Specific service in chain causing bottleneck
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "ServiceLatencySpike", \
			"severity": "warning", \
			"job": "tracing-monitoring", \
			"service": "auth-service", \
			"operation": "validate_token", \
			"p95_latency_ms": "1850", \
			"baseline_ms": "200", \
			"environment": "production", \
			"incident_id": "INC-2024-03-28-004" \
		}, \
		"annotations": { \
			"description": "Auth service operation validate_token is experiencing p95 latency of 1850ms, significantly higher than the baseline of 200ms. This is affecting all downstream services.", \
			"summary": "Auth service latency spike" \
		}, \
		"startsAt": "2024-02-12T19:50:30Z" \
	  } \
	]'
	sleep 2
	# Error rate in specific service
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "ServiceErrorRate", \
			"severity": "critical", \
			"job": "tracing-monitoring", \
			"service": "payment-service", \
			"operation": "process_transaction", \
			"error_rate": "35.5", \
			"threshold": "5", \
			"environment": "production", \
			"incident_id": "INC-2024-03-28-004" \
		}, \
		"annotations": { \
			"description": "Payment service operation process_transaction is experiencing 35.5% error rate, exceeding the threshold of 5%. This is causing transaction failures.", \
			"summary": "Payment service high error rate" \
		}, \
		"startsAt": "2024-02-12T19:51:00Z" \
	  } \
	]'
	sleep 2
	# Trace sampling rate drop
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "TraceSamplingRateDrop", \
			"severity": "warning", \
			"job": "tracing-monitoring", \
			"instance": "tracing-collector", \
			"sampling_rate": "15", \
			"target_rate": "50", \
			"environment": "production", \
			"incident_id": "INC-2024-03-28-004" \
		}, \
		"annotations": { \
			"description": "Trace sampling rate has dropped to 15%, below the target of 50%. This may affect observability and issue detection.", \
			"summary": "Trace sampling rate drop" \
		}, \
		"startsAt": "2024-02-12T19:51:30Z" \
	  } \
	]'

# Real-world complex scenario - simulates a realistic multi-component failure
real-world:
	@echo "Simulating a complex real-world incident with multiple related alerts..."
	# Initial network issue
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "NetworkPartition", \
			"severity": "critical", \
			"job": "network-monitoring", \
			"instance": "datacenter-east-1", \
			"affected_zones": "3", \
			"total_zones": "5", \
			"environment": "production", \
			"incident_id": "INC-2024-03-28-005" \
		}, \
		"annotations": { \
			"description": "Network partition detected affecting 3 out of 5 availability zones in datacenter-east-1. This is causing service communication failures.", \
			"summary": "Critical network partition" \
		}, \
		"startsAt": "2024-02-12T19:50:00Z" \
	  } \
	]'
	sleep 1
	# Database cluster quorum loss
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "DatabaseClusterQuorumLoss", \
			"severity": "critical", \
			"job": "database-monitoring", \
			"instance": "user-db-cluster", \
			"available_nodes": "2", \
			"required_nodes": "3", \
			"total_nodes": "5", \
			"environment": "production", \
			"incident_id": "INC-2024-03-28-005" \
		}, \
		"annotations": { \
			"description": "User database cluster has lost quorum with only 2 available nodes out of 5 (3 required). This is causing write operations to fail.", \
			"summary": "Database cluster quorum loss" \
		}, \
		"startsAt": "2024-02-12T19:50:15Z" \
	  } \
	]'
	sleep 1
	# Authentication service failures
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "AuthServiceHighErrorRate", \
			"severity": "critical", \
			"job": "api-monitoring", \
			"instance": "auth-service", \
			"error_rate": "95.8", \
			"threshold": "5", \
			"environment": "production", \
			"incident_id": "INC-2024-03-28-005" \
		}, \
		"annotations": { \
			"description": "Authentication service is experiencing 95.8% error rate, exceeding the threshold of 5%. Users are unable to log in.", \
			"summary": "Authentication service failure" \
		}, \
		"startsAt": "2024-02-12T19:50:30Z" \
	  } \
	]'
	sleep 1
	# Session service failures
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "SessionServiceHighErrorRate", \
			"severity": "critical", \
			"job": "api-monitoring", \
			"instance": "session-service", \
			"error_rate": "87.3", \
			"threshold": "5", \
			"environment": "production", \
			"incident_id": "INC-2024-03-28-005" \
		}, \
		"annotations": { \
			"description": "Session service is experiencing 87.3% error rate, exceeding the threshold of 5%. Users are being logged out unexpectedly.", \
			"summary": "Session service failure" \
		}, \
		"startsAt": "2024-02-12T19:50:45Z" \
	  } \
	]'
	sleep 1
	# Multiple API failures
	for api in "user" "account" "profile" "payment" "order" "cart" "product" "search" "recommendation" "notification"; do \
		curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d "[ \
		  { \
			\"labels\": { \
				\"alertname\": \"APIHighErrorRate\", \
				\"severity\": \"critical\", \
				\"job\": \"api-monitoring\", \
				\"instance\": \"$${api}-service\", \
				\"service\": \"$${api}-api\", \
				\"error_rate\": \"$$(( 80 + RANDOM % 20 ))\", \
				\"threshold\": \"5\", \
				\"environment\": \"production\", \
				\"incident_id\": \"INC-2024-03-28-005\" \
			}, \
			\"annotations\": { \
				\"description\": \"$${api} API is experiencing high error rates due to authentication and database dependencies.\", \
				\"summary\": \"$${api} API failure\" \
			}, \
			\"startsAt\": \"2024-02-12T19:51:00Z\" \
		  } \
		]"; \
		sleep 0.5; \
	done
	sleep 1
	# Frontend application impact
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
	  { \
		"labels": { \
			"alertname": "FrontendApplicationFailure", \
			"severity": "critical", \
			"job": "frontend-monitoring", \
			"instance": "web-app", \
			"error_rate": "98.2", \
			"threshold": "10", \
			"environment": "production", \
			"incident_id": "INC-2024-03-28-005" \
		}, \
		"annotations": { \
			"description": "Frontend web application is experiencing 98.2% error rate due to multiple API dependencies failing.", \
			"summary": "Frontend application failure" \
		}, \
		"startsAt": "2024-02-12T19:51:30Z" \
		 } \
	]'
	sleep 1
	# Mobile app impact
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
		 { \
		"labels": { \
			"alertname": "MobileAppFailure", \
			"severity": "critical", \
			"job": "mobile-monitoring", \
			"instance": "mobile-app", \
			"error_rate": "96.5", \
			"threshold": "10", \
			"environment": "production", \
			"incident_id": "INC-2024-03-28-005" \
		}, \
		"annotations": { \
			"description": "Mobile application is experiencing 96.5% error rate due to multiple API dependencies failing.", \
			"summary": "Mobile application failure" \
		}, \
		"startsAt": "2024-02-12T19:51:45Z" \
		 } \
	]'
	sleep 1
	# Customer impact
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
		 { \
		"labels": { \
			"alertname": "CustomerImpact", \
			"severity": "critical", \
			"job": "business-monitoring", \
			"instance": "customer-experience", \
			"affected_users": "250000", \
			"threshold": "1000", \
			"environment": "production", \
			"incident_id": "INC-2024-03-28-005" \
		}, \
		"annotations": { \
			"description": "Approximately 250,000 users are experiencing complete service outage. All core services are unavailable.", \
			"summary": "Major customer impact detected" \
		}, \
		"startsAt": "2024-02-12T19:52:00Z" \
		 } \
	]'
	sleep 1
	# Revenue impact
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[ \
		 { \
		"labels": { \
			"alertname": "RevenueImpact", \
			"severity": "critical", \
			"job": "business-monitoring", \
			"instance": "revenue-tracking", \
			"lost_revenue_per_minute": "25000", \
			"threshold": "5000", \
			"environment": "production", \
			"incident_id": "INC-2024-03-28-005" \
		}, \
		"annotations": { \
			"description": "Estimated revenue loss of $25,000 per minute due to service outage, exceeding the threshold of $5,000 per minute.", \
			"summary": "Critical revenue impact" \
		}, \
		"startsAt": "2024-02-12T19:52:15Z" \
		 } \
	]'