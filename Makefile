.PHONY: all alertmanager azure-devops grafana kubernetes prometheus

# Default target to show help
help:
	@echo "Available targets:"
	@echo "  make all              - Trigger all alert categories"
	@echo "  make alertmanager     - Trigger AlertManager-related alerts"
	@echo "  make ado              - Trigger Azure DevOps-related alerts"
	@echo "  make grafana          - Trigger Grafana-related alerts"
	@echo "  make kubernetes       - Trigger Kubernetes-related alerts"
	@echo "  make prometheus       - Trigger Prometheus-related alerts"

# Target to trigger all alerts
all: alertmanager azure-devops grafana kubernetes prometheus

# AlertManager alerts
alertmanager:
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[{ \
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
	}]'
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[{ \
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
	}]'

# Azure DevOps alerts
ado:
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[{ \
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
	}]'
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[{ \
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
	}]'

# Grafana alerts
grafana:
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[{ \
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
	}]'
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[{ \
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
	}]'

# Kubernetes alerts
kubernetes:
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[{ \
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
	}]'
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[{ \
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
	}]'

# Prometheus alerts
prometheus:
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[{ \
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
	}]'
	curl -X POST -H "Content-Type: application/json" http://localhost:9093/api/v2/alerts -d '[{ \
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
	}]'