#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ============================================================
# MOD 01: ENV & CORE (Preflight)
# Focus: .env Loading, Variable Validation, and System Health
# ============================================================

echo "[MOD 01] Starting Environment & Core Validation..."

# -----------------------------------------------------------------
# LOGGING UTILS
# -----------------------------------------------------------------
LOGFILE="/var/log/stb_printserver_setup.log"
touch "$LOGFILE"
ts() { date '+%Y-%m-%d %H:%M:%S'; }
log() { echo "[$(ts)] INFO  $*" | tee -a "$LOGFILE"; }
warn() { echo "[$(ts)] WARN  $*" | tee -a "$LOGFILE" >&2; }
err() { echo "[$(ts)] ERROR $*" | tee -a "$LOGFILE" >&2; }

# -----------------------------------------------------------------
# LOAD .env
# -----------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${1:-}"
if [[ -z "$ENV_FILE" ]]; then
    [[ -f "$SCRIPT_DIR/.env" ]] && ENV_FILE="$SCRIPT_DIR/.env"
    [[ -f "/.env" ]] && ENV_FILE="/.env"
fi

if [[ -f "$ENV_FILE" ]]; then
    source "$ENV_FILE"
    log "✅ Loaded environment from: $ENV_FILE"
else
    err "❌ Error: Environment file not found!"
    exit 1
fi

HOST_IP="${HOST_IP:-$(hostname -I | awk '{print $1}' | tr -d '[:space:]')}"
log "🌐 Host IP detected: $HOST_IP"

# -----------------------------------------------------------------
# CORE UTILS
# -----------------------------------------------------------------
confirm_yes_no() {
    local prompt="$1"
    local default="${2:-yes}"
    local hint answer
    if [[ "${CRITICAL_CONFIRMATIONS:-yes}" != "yes" ]]; then return 0; fi
    case "${default,,}" in
        yes|y|true|1|on) default="yes"; hint="Y/n" ;;
        *) default="no"; hint="y/N" ;;
    esac
    if [[ ! -t 0 || ! -e /dev/tty ]]; then
        warn "Konfirmasi interaktif tidak tersedia. Pakai default '${default}' untuk: ${prompt}"
        [[ "$default" == "yes" ]] && return 0 || return 1
    fi
    while true; do
        printf "%s [%s]: " "$prompt" "$hint" > /dev/tty
        if ! read -r answer << / /dev/tty; then answer=""; fi
        answer="$(printf '%s' "$answer" | tr '[:upper:]' '[:lower:]')"
        [[ -z "$answer" ]] && answer="$default"
        case "$answer" in
            y|yes) return 0 ;;
            n|no) return 1 ;;
            *) printf "Jawab yes/no.\n" > /dev/tty ;;
        esac
    done
}

internet_online() {
    timeout 2 bash -c 'cat << / /dev/null > /dev/tcp/1.1.1.1/53' >/dev/null 2>&1 && return 0
    timeout 2 bash -c 'cat << / /dev/null > /dev/tcp/8.8.8.8/53' >/dev/null 2>&1 && return 0
    return 1
}

guard_network_or_skip() {
    local feature="$1"
    if [[ "$OFFLINE_MODE_GUARD" == "yes" ]] && ! internet_online; then
        warn "Offline mode guard: internet tidak tersedia, skip ${feature}."
        return 1
    fi
    return 0
}

die() {
    err "$*"
    exit 1
}

install_pkg() {
    local pkg="$1"
    if dpkg -s "$pkg" >/dev/null 2>&1; then
        log "Paket $pkg sudah terpasang."
    else
        if [[ "$OFFLINE_MODE_GUARD" == "yes" ]] && ! internet_online; then
            warn "Offline guard: package $pkg belum terpasang, tetapi internet down. Skip install."
            return 1
        fi
        log "Menginstall paket: $pkg"
        apt-get install -y "$pkg" >/dev/null || die "Gagal install $pkg"
    fi
}

# -----------------------------------------------------------------
# VALIDATION
# -----------------------------------------------------------------
REQUIRED_VARS=("CUPS_IMG" "SANE_IMG" "TARGET_ROOT" "SOURCE_ROOT")
for var in "${REQUIRED_VARS[@]}"; do
    if [[ -z "${!var}" ]]; then
        err "❌ Missing critical variable: $var"
        exit 1
    fi
done

log "✅ Core variables validated."
echo "[MOD 01] Core validation complete."
