#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ============================================================
# MOD 04: SERVICES DEPLOY
# Focus: CUPS, SANE, and Epson WebUI Containers
# ============================================================

echo "[MOD 04] Deploying Services..."

# --- Helper: Docker Run Wrapper ---
docker_run_container() {
    local name="$1"
    local image="$2"
    shift 2
    log "Launching container $name (image: $image)..."
    docker rm -f "$name" >/dev/null 2>&1 || true
    docker run -d --name "$name" --restart unless-stopped "$@" "$image" >/dev/null \
        || die "Failed to launch container $name"
}

# --- CUPS Deployment ---
if [[ "${ENABLE_CUPS:-yes}" == "yes" ]]; then
    local cups_img="${CUPS_IMG:-anujdatar/cups:latest}"
    log "Deploying CUPS: $cups_img"

    # Port management and conflict check would go here (from monolith)
    docker_run_container "$CUPS_CONTAINER_NAME" "$cups_img" \
        -p "${CUPS_PORT:-631}:631" \
        -v "${CUPS_CONF}:/etc/cups" \
        -v "${CUPS_LOG}:/var/log/cups" \
        --network host
fi

# --- SANE Deployment ---
if [[ "${ENABLE_SANE:-yes}" == "yes" ]]; then
    local sane_img="${SANE_IMG:-sbs20/scanservjs:latest}"
    log "Deploying SANE: $sane_img"

    docker_run_container "scanner" "$sane_img" \
        -p "${SANE_PORT:-8081}:8081" \
        -v "${HOST_SANE_CONF}:/etc/sane" \
        --device /dev/bus/usb:/dev/bus/usb \
        --network host
fi

# --- Epson WebUI (Maintenance Tools) ---
if [[ "${ENABLE_EPSON_WEBUI:-yes}" == "yes" ]]; then
    log "Deploying Epson WebUI Maintenance Tools..."
    # This requires the Dockerfile generation logic from monolith
    # We assume the Dockerfile is built via the bridge/builder
    docker_run_container "epson-unified-hub" "epson-webui:latest" \
        -p "${WEBUI_PORT:-5000}:5000" \
        -v "${WEBUI_DIR}:/app" \
        --network host
fi

echo "[MOD 04] Services deployment complete."
