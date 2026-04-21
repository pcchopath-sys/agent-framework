#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ============================================================
# MOD 03: INFRASTRUCTURE
# Focus: CasaOS & Docker Engine
# ============================================================

echo "[MOD 03] Deploying Infrastructure..."

# 1. Docker Engine Installation
if ! command -v docker >/dev/null 2>&1; then
    if guard_network_or_skip "install Docker"; then
        log "Docker not found. Installing..."
        curl -fsSL https://get.docker.com | sh || die "Docker installation failed"
        systemctl enable --now docker || true
    else
        die "Docker is required but internet is offline."
    fi
else
    log "Docker is already installed."
fi

# 2. CasaOS Deployment
if [[ "${ENABLE_CASAOS:-yes}" == "yes" ]]; then
    if systemctl is-active --quiet casaos.service 2>/dev/null; then
        log "CasaOS is already active."
    else
        if confirm_yes_no "CasaOS is not active. Install CasaOS now?" "${CRITICAL_CONFIRM_DEFAULT:-no}"; then
            log "Installing CasaOS..."
            curl -fsSL https://get.casaos.io | bash || warn "CasaOS installation failed (skipping)"
        else
            warn "CasaOS installation cancelled by user."
        fi
    fi
fi

# 3. Persist Directories Setup
log "Creating persistence directories..."
mkdir -p "$PERSIST_ROOT" "$CUPS_CONF" "$CUPS_LOG" "$WEBUI_DIR" "$SHARE_DIR"
chmod -R 755 "$PERSIST_ROOT"
log "Persistence folders are ready."

echo "[MOD 03] Infrastructure deployment complete."
