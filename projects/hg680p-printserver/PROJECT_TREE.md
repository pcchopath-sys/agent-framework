# Project Tree: HG680P PrintServer Deployment

## Root: `agent-framework/projects/hg680p-printserver/`

### 📁 scripts/
Contains modular setup scripts executed by `main_setup.sh`.
- `00_env_config.sh`: Environment variable loading and configuration defaults.
- `01_utils.sh`: Common utility functions (logging, notifications, confirmation).
- `02_system_setup.sh`: OS-level preparations, package installation, and kernel protection.
- `03_network_setup.sh`: WiFi bootstrapping, driver fallbacks, and IP discovery.
- `04_docker_setup.sh`: Docker installation, port scanning, and image management.
- `05_persistence_setup.sh`: Filesystem structure, persistence directories, and runtime env.
- `06_casaos_setup.sh`: CasaOS installation and basic configuration.
- `07_webui_deploy.sh`: Deployment of the Epson WebUI container and `webui.py`.

### 📁 config/
- `.env.example`: Template for required environment variables.
- `runtime.env`: (Generated) Runtime configuration for containers.

### 📁 webui/
Contains the source code for the Maintenance WebUI.
- `webui.py`: The main Flask application for printer maintenance.
- `Dockerfile`: Docker build instructions for the WebUI.

### 📁 agent/
AI Telegram Agent - Multi-Provider Lightweight Agent.
- `agent_telegram.py`: AI assistant via Telegram Bot with Google AI + Groq auto-failover
- Designed for ARM64 STB (2GB RAM), < 50MB memory usage

### 📄 main_setup.sh
The master orchestrator script that executes the modular scripts in the correct sequence.

### 📄 PROJECT_TREE.md
This documentation file.

---

## Execution Flow
`main_setup.sh` $\rightarrow$ `00_env` $\rightarrow$ `01_utils` $\rightarrow$ `02_system` $\rightarrow$ `03_network` $\rightarrow$ `04_docker` $\rightarrow$ `05_persist` $\rightarrow$ `06_casaos` $\rightarrow$ `07_webui`
