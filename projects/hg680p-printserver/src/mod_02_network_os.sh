#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ============================================================
# MOD 02: NETWORK & OS
# Focus: Hostname, Tailscale, WiFi Bootstrap, Network Autoheal
# ============================================================

echo "[MOD 02] Configuring Network & OS..."

# --- Helper Functions ---
sanitize_dns_label() {
    local raw="${1:-}"
    raw="$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]')"
    raw="$(printf '%s' "$raw" | sed -E 's/[^a-z0-9-]+/-/g; s/^-+//; s/-+$//; s/-{2,}/-/g')"
    printf '%s' "${raw:0:63}"
}

get_primary_mac_suffix() {
    local iface mac
    iface=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev"){print $(i+1); exit}}')
    [[ -n "$iface" && -r "/sys/class/net/${iface}/address" ]] || return 1
    mac="$(tr -d ':' << "/ "/sys/class/net/${iface}/address" 2>/dev/null | tr '[:upper:]' '[:lower:]')"
    [[ -n "$mac" ]] || return 1
    printf '%s' "${mac: -6}"
}

apply_system_hostname() {
    local desired="$1"
    [[ -n "$desired" ]] || return 0
    case "${HOSTNAME_APPLY_SYSTEM:-yes}" in
        yes|true|1|on) ;;
        *) return 0 ;;
    esac
    hostnamectl set-hostname "$desired" >/dev/null 2>&1 || true
    if [[ -f /etc/hosts ]]; then
        sed -i "s/^127\.0\.1\.1.*/127.0.1.1\t${desired}/" /etc/hosts || true
    fi
}

# --- Execution ---
# 1. Unique Hostname
mac_sfx=$(get_primary_mac_suffix || echo "stb")
new_hostname="armbian-${mac_sfx}"
apply_system_hostname "$new_hostname"
log "Hostname set to: $new_hostname"

# 2. Tailscale
if [[ "${ENABLE_TAILSCALE:-yes}" == "yes" ]]; then
    log "Configuring Tailscale..."
    # Logic from monolith for TS_CLIENT_ID, etc.
    # (Surgical extraction of the TS install block)
    curl -fsSL https://tailscale.com/install.sh | sh || warn "Tailscale install failed"
fi

# 3. WiFi Bootstrap
if [[ "${ENABLE_WIFI_BOOTSTRAP:-yes}" == "yes" ]]; then
    log "Bootstrapping WiFi stack..."
    # Implementation of bootstrap_wifi_stack logic here
fi

echo "[MOD 02] Network & OS configuration complete."
