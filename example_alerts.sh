#!/bin/bash

# Alertmanager High Memory Usage Alert
curl -X POST http://localhost:9093/api/v1/alerts -H "Content-Type: application/json" -d '[{
  "labels": {
    "alertname": "AlertmanagerHighMemoryUsage",
    "severity": "warning",
    "instance": "alertmanager-main-0",
    "job": "alertmanager"
  },
  "annotations": {
    "summary": "Alertmanager high memory usage",
    "description": "Alertmanager instance alertmanager-main-0 is using more than 85% of its memory.",
    "runbook_url": "http://localhost:3000/#alertmanager/high_memory_usage"
  }
}]'

# Prometheus High Query Load Alert
curl -X POST http://localhost:9093/api/v1/alerts -H "Content-Type: application/json" -d '[{
  "labels": {
    "alertname": "PrometheusHighQueryLoad",
    "severity": "warning",
    "instance": "prometheus-k8s-0",
    "job": "prometheus"
  },
  "annotations": {
    "summary": "Prometheus high query load",
    "description": "Prometheus instance prometheus-k8s-0 is experiencing high query load.",
    "runbook_url": "http://localhost:3000/#prometheus/high_query_load"
  }
}]'