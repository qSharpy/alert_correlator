# 🚨 Alert Fatigue No More: Building an AI-Powered Correlation Engine for Prometheus

A powerful alert correlation system that helps reduce alert fatigue by intelligently grouping and analyzing related alerts from your monitoring stack. Built with Prometheus, AlertManager, Grafana, and Loki.

## 🌟 Features

- Intelligent alert correlation and grouping
- Real-time alert processing
- Beautiful Grafana dashboards for visualization
- Integrated logging with Loki
- Comprehensive runbooks for common scenarios
- Docker-based deployment for easy setup

## 🔧 Prerequisites

- Docker and Docker Compose
- Git
- Python 3.8 or higher (if running locally)
- ~2GB of free RAM for all containers

## 🚀 Quick Start

1. Clone the repository:
```bash
git clone https://github.com/yourusername/alert_correlator.git
cd alert_correlator
```

2. Set up environment configuration:

Create a `.env` file in the root directory with your OpenAI API key:
```bash
OPENAI_API_KEY=your_openai_api_key_here
```

3. Create the logs directory and log file:
```bash
mkdir -p logs
touch logs/alert_correlator.log
```

4. Start the services:
```bash
docker-compose up -d
```

## 📊 Accessing the Services

After starting the containers, you can access the following services:

- Grafana: http://localhost:3000
  - Default credentials: admin/admin
- Prometheus: http://localhost:9090
- AlertManager: http://localhost:9093
- Alert Correlator API: http://localhost:5000
- Loki: http://localhost:3100

## 📈 Grafana Dashboard

1. Login to Grafana at http://localhost:3000
2. Navigate to Dashboards -> Browse
3. Look for "Alert Correlator Dashboard"
4. The dashboard includes:
   - Alert correlation statistics
   - Active alert groups
   - Historical correlation data
   - Alert patterns and trends

## 🛠️ Configuration

### Alert Correlator

The main configuration is done through environment variables and the following files:
- `alert_correlator.py`: Main correlation logic
- `alertmanager.yml`: AlertManager configuration
- `prometheus.yml`: Prometheus configuration
- `loki-config.yaml`: Loki configuration
- `promtail-config.yaml`: Log shipping configuration

### Runbooks

Predefined runbooks are available in the `runbooks/` directory for common scenarios:
- AlertManager related issues
- Prometheus troubleshooting
- High memory usage handling
- Storage issues

## 🔍 Testing

You can test the alert correlation system using the Makefile:

```bash
make help
```

## 📝 Logging

Logs are available in:
- Docker logs: `docker-compose logs -f [service_name]`
- Application logs: `logs/alert_correlator.log`
- Through Loki in Grafana

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## ⚖️ License

This project is licensed under a Custom Attribution-NonCommercial License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

Vasile Bogdan Bujor

## ⚠️ Important Notes

- This is a monitoring tool - please ensure you have proper security measures in place
- Always backup your configuration before making changes
- Test thoroughly in a non-production environment first
- Commercial use requires explicit permission from the author
