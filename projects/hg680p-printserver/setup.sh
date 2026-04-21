#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ============================================================
# PRINTSERVER SETUP.SH
# All in One Epson Maintenance Tools
# Target: HG680P / Armbian Noble (Ubuntu 24.04 ARM64)
# ============================================================

# -----------------------------------------------------------------
# 0️⃣ LOAD .env – cari file di lokasi script atau di root
# -----------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${1:-}"
if [[ -z "$ENV_FILE" ]]; then
    [[ -f "$SCRIPT_DIR/.env" ]] && ENV_FILE="$SCRIPT_DIR/.env"
    [[ -f "/.env" ]] && ENV_FILE="/.env"
fi
[[ -f "$ENV_FILE" ]] && source "$ENV_FILE"
HOST_IP="${HOST_IP:-$(hostname -I | awk '{print $1}' | tr -d '[:space:]')}"

# #region agent log
_STB_ENVF="${ENV_FILE:-}"
[[ -n "${_STB_ENVF}" && -f "${_STB_ENVF}" ]] && _STB_ENV_OK=true || _STB_ENV_OK=false
_STB_TS0="$(($(date +%s) * 1000))"
printf '%s\n' "{\"sessionId\":\"9761b3\",\"hypothesisId\":\"H3\",\"location\":\"setup.sh:env\",\"message\":\"after_env_load\",\"data\":{\"env_file\":\"${_STB_ENVF}\",\"env_exists\":${_STB_ENV_OK}},\"timestamp\":${_STB_TS0}}" >> "/Users/pcchopath/.cursor/debug-9761b3.log" 2>/dev/null || printf '%s\n' "{\"sessionId\":\"9761b3\",\"hypothesisId\":\"H3\",\"location\":\"setup.sh:env\",\"message\":\"after_env_load\",\"data\":{\"env_file\":\"${_STB_ENVF}\",\"env_exists\":${_STB_ENV_OK}},\"timestamp\":${_STB_TS0}}" >> "/tmp/stb-debug-9761b3.log" 2>/dev/null || true
unset _STB_ENVF _STB_ENV_OK _STB_TS0
# #endregion

# -------------------------
# USER CONFIG (EDIT HERE)
# -------------------------
ENABLE_CASAOS="${ENABLE_CASAOS:-yes}"
ENABLE_CUPS="${ENABLE_CUPS:-yes}"
ENABLE_SANE="${ENABLE_SANE:-yes}"
ENABLE_TAILSCALE="${ENABLE_TAILSCALE:-yes}"
TS_AUTO_ENABLE_SERVICE="${TS_AUTO_ENABLE_SERVICE:-yes}"
TS_ACCEPT_ROUTES="${TS_ACCEPT_ROUTES:-yes}"
TS_ACCEPT_DNS="${TS_ACCEPT_DNS:-no}"
HOSTNAME_PROMPT_ON_SETUP="${HOSTNAME_PROMPT_ON_SETUP:-yes}"
HOSTNAME_BRAND="${HOSTNAME_BRAND:-}"
HOSTNAME_APPLY_SYSTEM="${HOSTNAME_APPLY_SYSTEM:-yes}"
TS_HOSTNAME="${TS_HOSTNAME:-}"
TS_HOSTNAME_PREFIX="${TS_HOSTNAME_PREFIX:-}"
TS_CLIENT_ID="${TS_CLIENT_ID:-${TS_API_CLIENT_ID:-${TAILSCALE_CLIENT_ID:-${TAILSCALE_OAUTH_CLIENT_ID:-}}}}"
TS_CLIENT_SECRET="${TS_CLIENT_SECRET:-${TS_API_CLIENT_SECRET:-${TAILSCALE_CLIENT_SECRET:-${TAILSCALE_OAUTH_CLIENT_SECRET:-}}}}"
TS_ADVERTISE_EXIT_NODE="${TS_ADVERTISE_EXIT_NODE:-no}"
TS_RESET_ON_UP="${TS_RESET_ON_UP:-no}"
TS_TAG="${TS_TAG:-tag:server}"
TS_BYPASS_SUBNETS="${TS_BYPASS_SUBNETS:-192.168.88.0/24,192.168.99.0/24,192.168.1.0/24}"
NET_AUTOHEAL_ENABLED="${NET_AUTOHEAL_ENABLED:-yes}"
ENABLE_TELEGRAM="${ENABLE_TELEGRAM:-yes}"
ENABLE_WHATSAPP="${ENABLE_WHATSAPP:-no}"
ENABLE_EPSON_WEBUI="${ENABLE_EPSON_WEBUI:-yes}"
ENABLE_SAMBA="${ENABLE_SAMBA:-no}"

FORCE_RESET_CUPS="${FORCE_RESET_CUPS:-no}"
FORCE_RESET_SANE="${FORCE_RESET_SANE:-yes}"
FORCE_RESET_WEBUI="${FORCE_RESET_WEBUI:-yes}"

CUPS_IMG="${CUPS_IMG:-anujdatar/cups:latest}"
CUPS_SOURCE_MODE="${CUPS_SOURCE_MODE:-anujdatar}"   # anujdatar|official-build
CUPS_OPENPRINTING_TAG="${CUPS_OPENPRINTING_TAG:-v2.4.14}"
CUPS_OFFICIAL_IMAGE_REPO="${CUPS_OFFICIAL_IMAGE_REPO:-local/openprinting-cups}"
SANE_IMG="${SANE_IMG:-sbs20/scanservjs:latest}"
CUPS_CONTAINER_NAME="${CUPS_CONTAINER_NAME:-cups}"
CUPS_LEGACY_CONTAINER_NAME="${CUPS_LEGACY_CONTAINER_NAME:-printer-config}"
PRINT_PORTAL_CONTAINER_NAME="${PRINT_PORTAL_CONTAINER_NAME:-epson-unified-hub}"

CUPS_PORT="${CUPS_PORT:-631}"
CUPS_REMOTE_ADMIN="${CUPS_REMOTE_ADMIN:-no}"
CUPS_REMOTE_ADMIN_ALLOW_NET="${CUPS_REMOTE_ADMIN_ALLOW_NET:-}"
CUPS_HOSTNAME_LOOKUPS="${CUPS_HOSTNAME_LOOKUPS:-off}"
CUPS_SERVER_HOST="${CUPS_SERVER_HOST:-host.docker.internal}"
WEBUI_PORT="${WEBUI_PORT:-5000}"
WEBUI_NETWORK_MODE="${WEBUI_NETWORK_MODE:-host}"
WEB_PRINT_PORT="${WEB_PRINT_PORT:-3000}"
WEBUI_DEBUG="${WEBUI_DEBUG:-no}"
SHOW_HOSTNAME_ON_CARDS="${SHOW_HOSTNAME_ON_CARDS:-yes}"
SANE_PORT="${SANE_PORT:-8081}"
WEB_PRINT_ENABLED="${WEB_PRINT_ENABLED:-yes}"
WEB_PRINT_MAX_MB="${WEB_PRINT_MAX_MB:-25}"
WEB_PRINT_ALLOWED_EXTS="${WEB_PRINT_ALLOWED_EXTS:-pdf,png,jpg,jpeg,txt}"
REMOTE_PRINT_HOST_HINT="${REMOTE_PRINT_HOST_HINT:-}"
SNMP_WRITE="EPCF_PASS"
TELEGRAM_TOKEN="${TELEGRAM_TOKEN:-}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"
WA_PROVIDER="${WA_PROVIDER:-meta}"
WA_GRAPH_VERSION="${WA_GRAPH_VERSION:-v23.0}"
WA_TOKEN="${WA_TOKEN:-}"
WA_PHONE_NUMBER_ID="${WA_PHONE_NUMBER_ID:-}"
WA_TO="${WA_TO:-}"
WA_MESSAGE_TYPE="${WA_MESSAGE_TYPE:-text}"
WA_TEMPLATE_NAME="${WA_TEMPLATE_NAME:-stb_print_alert}"
WA_TEMPLATE_LANG="${WA_TEMPLATE_LANG:-id}"
TELEGRAM_ACTIVITY_NOTIFY="${TELEGRAM_ACTIVITY_NOTIFY:-yes}"
REINKPY_NOTIFY_HOURS="${REINKPY_NOTIFY_HOURS:-24}"
REINKPY_AUTO_CHECK_ON_START="${REINKPY_AUTO_CHECK_ON_START:-yes}"
REINKPY_SOURCE_MODE="${REINKPY_SOURCE_MODE:-auto}"   # auto|fix|original
REINKPY_FIX_STALE_DAYS="${REINKPY_FIX_STALE_DAYS:-21}"
WASTE_WARN_THRESHOLD="${WASTE_WARN_THRESHOLD:-80}"
WASTE_ALERT_THRESHOLD="${WASTE_ALERT_THRESHOLD:-90}"
WASTE_RECOVER_THRESHOLD="${WASTE_RECOVER_THRESHOLD:-70}"
INK_WARN_THRESHOLD="${INK_WARN_THRESHOLD:-20}"
INK_CRITICAL_THRESHOLD="${INK_CRITICAL_THRESHOLD:-10}"
INK_RECOVER_THRESHOLD="${INK_RECOVER_THRESHOLD:-30}"
ENABLE_BACKGROUND_MONITOR="${ENABLE_BACKGROUND_MONITOR:-yes}"
MONITOR_INTERVAL_SECONDS="${MONITOR_INTERVAL_SECONDS:-300}"
ENABLE_PREFLIGHT="${ENABLE_PREFLIGHT:-yes}"
PREFLIGHT_NOTIFY_TELEGRAM="${PREFLIGHT_NOTIFY_TELEGRAM:-yes}"
ENABLE_AUTO_REBUILD="${ENABLE_AUTO_REBUILD:-yes}"
ENABLE_HOUSEKEEPING="${ENABLE_HOUSEKEEPING:-yes}"
ENABLE_STORAGE_TRIM="${ENABLE_STORAGE_TRIM:-yes}"
RUN_STORAGE_TRIM_ON_SETUP="${RUN_STORAGE_TRIM_ON_SETUP:-yes}"
HOUSEKEEPING_JOURNAL_MAX="${HOUSEKEEPING_JOURNAL_MAX:-120M}"
HOUSEKEEPING_LOG_KEEP_LINES="${HOUSEKEEPING_LOG_KEEP_LINES:-2000}"
HOUSEKEEPING_TMP_DAYS="${HOUSEKEEPING_TMP_DAYS:-3}"
HOUSEKEEPING_DOCKER_RETENTION_HOURS="${HOUSEKEEPING_DOCKER_RETENTION_HOURS:-240}"
HOUSEKEEPING_RESTART_MAINTENANCE="${HOUSEKEEPING_RESTART_MAINTENANCE:-no}"
BUSINESS_START_HOUR="${BUSINESS_START_HOUR:-7}"
BUSINESS_END_HOUR_WEEKDAY="${BUSINESS_END_HOUR_WEEKDAY:-21}"
BUSINESS_END_HOUR_SATURDAY="${BUSINESS_END_HOUR_SATURDAY:-13}"
HEALTHCHECK_SEND_OK="${HEALTHCHECK_SEND_OK:-no}"
OFFLINE_MODE_GUARD="${OFFLINE_MODE_GUARD:-yes}"
PROTECT_KERNEL_UPDATES="${PROTECT_KERNEL_UPDATES:-yes}"
PRINTER_WATCH_INTERVAL_SECONDS="${PRINTER_WATCH_INTERVAL_SECONDS:-20}"
CUPS_AUTO_QUEUE_NAME="${CUPS_AUTO_QUEUE_NAME:-EPSON_USB}"
CRITICAL_CONFIRMATIONS="${CRITICAL_CONFIRMATIONS:-yes}"
CRITICAL_CONFIRM_DEFAULT="${CRITICAL_CONFIRM_DEFAULT:-no}"
ENABLE_WIFI_BOOTSTRAP="${ENABLE_WIFI_BOOTSTRAP:-yes}"
WIFI_DRIVER_FALLBACK_BUILD="${WIFI_DRIVER_FALLBACK_BUILD:-yes}"
WIFI_FALLBACK_REPO="${WIFI_FALLBACK_REPO:-https://github.com/jwrdegoede/rtl8189ES_linux.git}"
WIFI_FALLBACK_BRANCH="${WIFI_FALLBACK_BRANCH:-rtl8189fs}"
WIFI_FALLBACK_MODULE="${WIFI_FALLBACK_MODULE:-8189fs}"

HOST_IP="${HOST_IP:-}"   # optional override

# -------------------------
# INTERNAL PATHS
# -------------------------
PERSIST_ROOT="/opt/stb_printserver"
CUPS_CONF="${PERSIST_ROOT}/cups/etc"
CUPS_LOG="${PERSIST_ROOT}/cups/log"
WEBUI_DIR="${PERSIST_ROOT}/epson-webui"
SHARE_DIR="${PERSIST_ROOT}/share"

CASAOS_ROOT="/opt/casaos"
CASAOS_APPS="/opt/casaos/apps"

LOGFILE="/var/log/stb_printserver_setup.log"

# -------------------------
# LOGGING
# -------------------------
ts() { date '+%Y-%m-%d %H:%M:%S'; }
log() { echo "[$(ts)] INFO  $*" | tee -a "$LOGFILE"; }
warn() { echo "[$(ts)] WARN  $*" | tee -a "$LOGFILE" >&2; }
err() { echo "[$(ts)] ERROR $*" | tee -a "$LOGFILE" >&2; }

confirm_yes_no() {
    local prompt="$1"
    local default="${2:-yes}"
    local hint answer

    if [[ "${CRITICAL_CONFIRMATIONS:-yes}" != "yes" ]]; then
        return 0
    fi

    case "${default,,}" in
        yes|y|true|1|on) default="yes"; hint="Y/n" ;;
        *) default="no"; hint="y/N" ;;
    esac

    if [[ ! -t 0 || ! -e /dev/tty ]]; then
        warn "Konfirmasi interaktif tidak tersedia. Pakai default '${default}' untuk: ${prompt}"
        [[ "$default" == "yes" ]]
        return
    fi

    while true; do
        printf "%s [%s]: " "$prompt" "$hint" > /dev/tty
        if ! read -r answer < /dev/tty; then
            answer=""
        fi
        answer="$(printf '%s' "$answer" | tr '[:upper:]' '[:lower:]')"
        [[ -z "$answer" ]] && answer="$default"
        case "$answer" in
            y|yes) return 0 ;;
            n|no) return 1 ;;
            *) printf "Jawab yes/no.\n" > /dev/tty ;;
        esac
    done
}

prompt_text() {
    local prompt="$1"
    local default="${2:-}"
    local answer

    if [[ ! -t 0 || ! -e /dev/tty ]]; then
        [[ -n "$default" ]] && warn "Prompt interaktif tidak tersedia. Pakai default '${default}' untuk: ${prompt}"
        printf '%s' "$default"
        return 0
    fi

    while true; do
        if [[ -n "$default" ]]; then
            printf "%s [%s]: " "$prompt" "$default" > /dev/tty
        else
            printf "%s: " "$prompt" > /dev/tty
        fi
        if ! read -r answer < /dev/tty; then
            answer=""
        fi
        [[ -z "$answer" ]] && answer="$default"
        answer="$(printf '%s' "$answer" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
        if [[ -n "$answer" ]]; then
            printf '%s' "$answer"
            return 0
        fi
        printf "Input tidak boleh kosong.\n" > /dev/tty
    done
}

tg_send() {
    local msg="$1"
    if [[ "$ENABLE_TELEGRAM" == "yes" && -n "${TELEGRAM_TOKEN}" && -n "${TELEGRAM_CHAT_ID}" ]]; then
        curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
            -d "chat_id=${TELEGRAM_CHAT_ID}" \
            -d "text=${msg}" >/dev/null 2>&1 || true
    fi
    wa_send "$msg"
}

wa_send() {
    [[ "${ENABLE_WHATSAPP:-no}" != "yes" ]] && return 0
    [[ "${WA_PROVIDER:-meta}" != "meta" ]] && return 0
    [[ -z "${WA_TOKEN:-}" || -z "${WA_PHONE_NUMBER_ID:-}" || -z "${WA_TO:-}" ]] && return 0
    local msg="$1"
    local to="${WA_TO#+}"
    local escaped="${msg//\\/\\\\}"
    escaped="${escaped//\"/\\\"}"
    escaped="${escaped//$'\n'/\\n}"
    local endpoint="https://graph.facebook.com/${WA_GRAPH_VERSION:-v23.0}/${WA_PHONE_NUMBER_ID}/messages"
    local payload
    if [[ "${WA_MESSAGE_TYPE:-text}" == "template" ]]; then
        payload="{\"messaging_product\":\"whatsapp\",\"to\":\"${to}\",\"type\":\"template\",\"template\":{\"name\":\"${WA_TEMPLATE_NAME:-stb_print_alert}\",\"language\":{\"code\":\"${WA_TEMPLATE_LANG:-id}\"},\"components\":[{\"type\":\"body\",\"parameters\":[{\"type\":\"text\",\"text\":\"${escaped}\"}]}]}}"
    else
        payload="{\"messaging_product\":\"whatsapp\",\"to\":\"${to}\",\"type\":\"text\",\"text\":{\"preview_url\":false,\"body\":\"${escaped}\"}}"
    fi
    curl -s -X POST "${endpoint}" \
        -H "Authorization: Bearer ${WA_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "${payload}" >/dev/null 2>&1 || true
}

internet_online() {
    timeout 2 bash -c 'cat < /dev/null > /dev/tcp/1.1.1.1/53' >/dev/null 2>&1 && return 0
    timeout 2 bash -c 'cat < /dev/null > /dev/tcp/8.8.8.8/53' >/dev/null 2>&1 && return 0
    return 1
}

guard_network_or_skip() {
    local feature="$1"
    if [[ "$OFFLINE_MODE_GUARD" == "yes" ]] && ! internet_online; then
        warn "Offline mode guard: internet tidak tersedia, skip ${feature}."
        tg_send "🟡 [STB OFFLINE GUARD] Skip ${feature} karena internet terputus ($(ts))."
        return 1
    fi
    return 0
}

die() {
    err "$*"
    tg_send "🚨 [STB ERROR] $(hostname): $*"
    exit 1
}

# -------------------------
# BASIC UTILS
# -------------------------
protect_kernel_updates() {
    if [[ "${PROTECT_KERNEL_UPDATES:-yes}" != "yes" ]]; then
        warn "Proteksi kernel upgrade dinonaktifkan (PROTECT_KERNEL_UPDATES=${PROTECT_KERNEL_UPDATES})."
        return 0
    fi

    if ! confirm_yes_no "Aktifkan proteksi kernel upgrade (apt pin + hold)?" "${CRITICAL_CONFIRM_DEFAULT:-no}"; then
        warn "Proteksi kernel upgrade dibatalkan oleh user."
        return 0
    fi

    mkdir -p /etc/apt/preferences.d
    cat > /etc/apt/preferences.d/stb-no-kernel-upgrade.pref <<'EOF'
Package: linux-image* linux-headers* linux-dtb* linux-u-boot* armbian-bsp*
Pin: release *
Pin-Priority: -1
EOF

    local kernel_pkgs=()
    mapfile -t kernel_pkgs < <(
        dpkg-query -W -f='${binary:Package}\n' 2>/dev/null \
        | grep -E '^(linux-(image|headers|dtb|u-boot)|armbian-bsp)' || true
    )
    if [[ ${#kernel_pkgs[@]} -gt 0 ]]; then
        apt-mark hold "${kernel_pkgs[@]}" >/dev/null 2>&1 || warn "apt-mark hold kernel packages gagal."
        log "Kernel/boot packages di-hold: ${kernel_pkgs[*]}"
    else
        warn "Tidak menemukan paket kernel/boot yang cocok untuk di-hold."
    fi

    log "Apt pin kernel aktif: /etc/apt/preferences.d/stb-no-kernel-upgrade.pref"
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

get_host_ip() {
    if [[ -n "$HOST_IP" ]]; then
        echo "$HOST_IP"
        return
    fi
    ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src"){print $(i+1); exit}}'
}

sanitize_dns_label() {
    local raw="${1:-}"
    raw="$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]')"
    raw="$(printf '%s' "$raw" | sed -E 's/[^a-z0-9-]+/-/g; s/^-+//; s/-+$//; s/-{2,}/-/g')"
    printf '%s' "${raw:0:63}"
}

sanitize_dns_host_hint() {
    local raw="${1:-}"
    raw="$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]')"
    raw="$(printf '%s' "$raw" | sed -E 's/[^a-z0-9.-]+/-/g; s/^-+//; s/-+$//; s/^\.+//; s/\.+$//; s/-{2,}/-/g; s/\.\.+/./g')"
    printf '%s' "$raw"
}

get_primary_route_iface() {
    ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev"){print $(i+1); exit}}'
}

get_primary_mac_suffix() {
    local iface mac
    iface="$(get_primary_route_iface)"
    [[ -n "$iface" && -r "/sys/class/net/${iface}/address" ]] || return 1
    mac="$(tr -d ':' < "/sys/class/net/${iface}/address" 2>/dev/null | tr '[:upper:]' '[:lower:]')"
    [[ -n "$mac" ]] || return 1
    printf '%s' "${mac: -6}"
}

build_tailscale_hostname_hint() {
    local explicit prefix suffix derived
    explicit="$(sanitize_dns_label "${TS_HOSTNAME:-}")"
    if [[ -n "$explicit" ]]; then
        printf '%s' "$explicit"
        return 0
    fi

    prefix="$(sanitize_dns_label "${HOSTNAME_BRAND_EFFECTIVE:-${HOSTNAME_BRAND:-${TS_HOSTNAME_PREFIX:-}}}")"
    [[ -n "$prefix" ]] || return 1

    suffix="$(sanitize_dns_label "$(get_primary_mac_suffix 2>/dev/null || hostname -s)")"
    [[ -n "$suffix" ]] || suffix="$(date +%s)"

    derived="$(sanitize_dns_label "${prefix}-${suffix}")"
    [[ -n "$derived" ]] || return 1
    printf '%s' "$derived"
}

resolve_hostname_brand_default() {
    local candidate
    for candidate in "${HOSTNAME_BRAND:-}" "${TS_HOSTNAME_PREFIX:-}" "$(hostname -s 2>/dev/null || hostname)" "printer"; do
        candidate="$(sanitize_dns_label "$candidate")"
        if [[ -n "$candidate" ]]; then
            printf '%s' "$candidate"
            return 0
        fi
    done
    return 1
}

resolve_hostname_brand_interactive() {
    local default_brand raw_brand sanitized
    default_brand="$(resolve_hostname_brand_default 2>/dev/null || echo printer)"

    if [[ "${HOSTNAME_PROMPT_ON_SETUP:-yes}" == "yes" && -t 0 && -e /dev/tty ]]; then
        raw_brand="$(prompt_text "Nama branding device untuk hostname (suffix MAC ditambahkan otomatis)" "$default_brand")"
    else
        raw_brand="$default_brand"
    fi

    sanitized="$(sanitize_dns_label "$raw_brand")"
    if [[ -z "$sanitized" ]]; then
        sanitized="$default_brand"
    fi
    printf '%s' "$sanitized"
}

apply_system_hostname() {
    local desired="$1"
    local current

    [[ -n "$desired" ]] || return 0
    case "${HOSTNAME_APPLY_SYSTEM:-yes}" in
        yes|true|1|on) ;;
        *) return 0 ;;
    esac

    current="$(hostname -s 2>/dev/null || hostname)"
    [[ "$desired" != "$current" ]] || return 0

    if command -v hostnamectl >/dev/null 2>&1; then
        hostnamectl set-hostname "$desired" >/dev/null 2>&1 || warn "Gagal set hostname system ke ${desired} via hostnamectl."
    else
        printf '%s\n' "$desired" > /etc/hostname || warn "Gagal menulis /etc/hostname untuk ${desired}."
        hostname "$desired" >/dev/null 2>&1 || true
    fi

    if [[ -f /etc/hosts ]]; then
        if grep -qE '^[[:space:]]*127\.0\.1\.1[[:space:]]+' /etc/hosts; then
            sed -Ei "s#^[[:space:]]*127\.0\.1\.1[[:space:]].*#127.0.1.1\t${desired}#" /etc/hosts || true
        else
            printf '127.0.1.1\t%s\n' "$desired" >> /etc/hosts || true
        fi
    fi
}

wifi_interfaces_present() {
    ip -br link 2>/dev/null | awk '{print $1}' | grep -Eq '^(wl|wlan)'
}

ensure_netplan_armbian_yaml() {
    local netplan_file="/etc/netplan/armbian.yaml"
    mkdir -p /etc/netplan
    if [[ ! -f "$netplan_file" ]]; then
        log "Membuat ${netplan_file} (renderer NetworkManager) ..."
        cat > "$netplan_file" <<'EOF'
network:
  version: 2
  renderer: NetworkManager
EOF
    else
        log "${netplan_file} sudah ada."
    fi
}

build_wifi_driver_fallback_8189fs() {
    local krel build_dir src_root src_dir module_path
    krel="$(uname -r)"
    build_dir="/lib/modules/${krel}/build"
    src_root="${PERSIST_ROOT}/wifi-driver-src"
    src_dir="${src_root}/rtl8189ES_linux"
    module_path="/lib/modules/${krel}/kernel/drivers/net/wireless/rtl8189fs"

    if [[ ! -e "$build_dir" ]]; then
        warn "Kernel headers belum siap di ${build_dir}."
        if confirm_yes_no "Install linux-headers-current-meson64 sekarang?" "${CRITICAL_CONFIRM_DEFAULT:-no}"; then
            apt-get install -y linux-headers-current-meson64 >/dev/null \
                || warn "Install linux-headers-current-meson64 gagal."
        fi
    fi
    [[ -e "$build_dir" ]] || { warn "Skip build fallback karena kernel headers belum tersedia."; return 1; }

    install_pkg git || return 1
    install_pkg build-essential || return 1
    install_pkg dkms || true

    if ! guard_network_or_skip "download source driver fallback ${WIFI_FALLBACK_MODULE}"; then
        warn "Offline guard: skip build fallback ${WIFI_FALLBACK_MODULE}."
        return 1
    fi

    mkdir -p "$src_root"
    if [[ -d "${src_dir}/.git" ]]; then
        log "Update source fallback WiFi: ${src_dir}"
        (
            cd "$src_dir" \
            && git fetch --depth 1 origin "${WIFI_FALLBACK_BRANCH}" >/dev/null \
            && git checkout "${WIFI_FALLBACK_BRANCH}" >/dev/null \
            && git pull --ff-only >/dev/null
        ) || {
            warn "Gagal update repo fallback WiFi; mencoba clone ulang."
            rm -rf "$src_dir"
            git clone --depth 1 --branch "${WIFI_FALLBACK_BRANCH}" "${WIFI_FALLBACK_REPO}" "$src_dir" >/dev/null \
                || { warn "Clone driver fallback gagal."; return 1; }
        }
    else
        log "Clone source fallback WiFi: ${WIFI_FALLBACK_REPO} (${WIFI_FALLBACK_BRANCH})"
        git clone --depth 1 --branch "${WIFI_FALLBACK_BRANCH}" "${WIFI_FALLBACK_REPO}" "$src_dir" >/dev/null \
            || { warn "Clone driver fallback gagal."; return 1; }
    fi

    log "Compile fallback module ${WIFI_FALLBACK_MODULE} untuk ${krel} ..."
    (
        cd "$src_dir" \
        && make ARCH=arm64 KSRC="$build_dir" -j"$(nproc)" >/dev/null
    ) || { warn "Compile fallback ${WIFI_FALLBACK_MODULE} gagal."; return 1; }

    mkdir -p "$module_path"
    cp -f "${src_dir}/${WIFI_FALLBACK_MODULE}.ko" "${module_path}/${WIFI_FALLBACK_MODULE}.ko" \
        || { warn "Copy module fallback gagal."; return 1; }

    depmod -a || true
    modprobe "${WIFI_FALLBACK_MODULE}" >/dev/null 2>&1 \
        || { warn "modprobe ${WIFI_FALLBACK_MODULE} gagal setelah build fallback."; return 1; }
    echo "${WIFI_FALLBACK_MODULE}" > "/etc/modules-load.d/${WIFI_FALLBACK_MODULE}.conf"
    return 0
}

bootstrap_wifi_stack() {
    local alias alias_lc m
    local -a wifi_mod_candidates=()

    if [[ "${ENABLE_WIFI_BOOTSTRAP:-yes}" != "yes" ]]; then
        log "WiFi bootstrap dinonaktifkan (ENABLE_WIFI_BOOTSTRAP=${ENABLE_WIFI_BOOTSTRAP})."
        return 0
    fi

    log "Bootstrap WiFi: netplan + NetworkManager + driver check ..."
    ensure_netplan_armbian_yaml

    if ! command -v nmcli >/dev/null 2>&1; then
        if confirm_yes_no "NetworkManager belum tersedia. Install sekarang?" "${CRITICAL_CONFIRM_DEFAULT:-no}"; then
            install_pkg network-manager || warn "Install network-manager gagal."
        else
            warn "Install network-manager dibatalkan user."
        fi
    fi

    if systemctl list-unit-files NetworkManager.service >/dev/null 2>&1; then
        systemctl enable --now NetworkManager >/dev/null 2>&1 || warn "Gagal enable/start NetworkManager."
    else
        warn "NetworkManager.service tidak ditemukan."
    fi

    if wifi_interfaces_present; then
        log "Interface WiFi sudah terdeteksi sebelum load module."
        return 0
    fi

    alias="$(cat /sys/bus/sdio/devices/*/modalias 2>/dev/null | head -n 1 || true)"
    if [[ -z "$alias" ]]; then
        warn "Tidak menemukan SDIO modalias WiFi."
        return 0
    fi
    alias_lc="${alias,,}"
    log "SDIO alias terdeteksi: ${alias}"

    mapfile -t wifi_mod_candidates < <(modprobe -R "$alias" 2>/dev/null || true)
    if [[ ${#wifi_mod_candidates[@]} -gt 0 ]]; then
        for m in "${wifi_mod_candidates[@]}"; do
            log "Mencoba load module kandidat: ${m}"
            modprobe "$m" >/dev/null 2>&1 || warn "modprobe ${m} gagal."
        done
    fi

    # Safeguard untuk HG680P yang umum memakai Realtek SDIO 024c:f179
    if [[ "$alias_lc" == *"v024cdf179"* ]]; then
        modprobe 8189fs >/dev/null 2>&1 || true
    fi

    sleep 1
    if wifi_interfaces_present; then
        log "WiFi interface berhasil muncul setelah load module."
        return 0
    fi

    if [[ "${WIFI_DRIVER_FALLBACK_BUILD:-yes}" != "yes" ]]; then
        warn "Fallback build WiFi dinonaktifkan (WIFI_DRIVER_FALLBACK_BUILD=${WIFI_DRIVER_FALLBACK_BUILD})."
        return 0
    fi

    if [[ "$alias_lc" != *"v024cdf179"* ]]; then
        warn "Alias SDIO bukan target fallback RTL8189FS (alias=${alias})."
        return 0
    fi

    if confirm_yes_no "Driver WiFi belum aktif. Lanjut build fallback rtl8189fs sekarang?" "no"; then
        if build_wifi_driver_fallback_8189fs; then
            sleep 1
            if wifi_interfaces_present; then
                log "Fallback build rtl8189fs sukses, interface WiFi terdeteksi."
            else
                warn "Fallback build selesai tetapi interface WiFi masih belum terdeteksi."
            fi
        else
            warn "Fallback build rtl8189fs gagal."
        fi
    else
        warn "Build fallback rtl8189fs dibatalkan user."
    fi
}

is_port_used() {
    local port="$1"
    ss -tulpn | grep -q ":$port "
}

docker_container_using_port() {
    local port="$1"
    docker ps --format '{{.ID}} {{.Names}}' | while read -r id name; do
        docker port "$id" 2>/dev/null | grep -q ":$port" && echo "$name"
    done | head -n 1
}

port_pids() {
    local port="$1"
    ss -ltnp 2>/dev/null \
      | awk -v p=":${port}" '$4 ~ p {print}' \
      | sed -nE 's/.*pid=([0-9]+).*/\1/p' \
      | sort -u
}

force_release_port() {
    local port="$1"
    local cname pids pid

    cname="$(docker_container_using_port "$port" || true)"
    if [[ -n "$cname" ]]; then
        warn "Port $port dipakai container: $cname -> remove"
        docker rm -f "$cname" >/dev/null 2>&1 || true
        sleep 1
    fi

    if is_port_used "$port"; then
        pids="$(port_pids "$port" || true)"
        if [[ -n "$pids" ]]; then
            for pid in $pids; do
                warn "Port $port dipakai PID $pid -> kill"
                kill -TERM "$pid" >/dev/null 2>&1 || true
            done
            sleep 1
            for pid in $pids; do
                if kill -0 "$pid" >/dev/null 2>&1; then
                    kill -KILL "$pid" >/dev/null 2>&1 || true
                fi
            done
            sleep 1
        fi
    fi

    ! is_port_used "$port"
}

free_port_or_fallback() {
    local base="$1"
    local port="$base"

    for i in {0..50}; do
        port=$((base+i))

        if ! is_port_used "$port"; then
            echo "$port"
            return 0
        fi

        local cname
        cname=$(docker_container_using_port "$port" || true)
        if [[ -n "$cname" ]]; then
            warn "Port $port dipakai container: $cname → remove"
            docker rm -f "$cname" >/dev/null 2>&1 || true
            sleep 2
            if ! is_port_used "$port"; then
                echo "$port"
                return 0
            fi
        fi
    done

    return 1
}

docker_build_image() {
    local name="$1"
    local dir="$2"

    log "Membangun image $name dari $dir"

    if [[ -z "$name" || -z "$dir" ]]; then
        die "docker_build_image: parameter kurang"
    fi

    docker build -t "$name" "$dir" \
        || die "Build image $name gagal"
}
docker_run_container() {
    local name="$1"
    local image="$2"
    shift 2

    log "Menjalankan container $name (image $image)"

    docker rm -f "$name" >/dev/null 2>&1 || true

docker run -d \
        --name "$name" \
        --restart unless-stopped \
        "$@" \
        "$image" >/dev/null \
        || die "Run container $name gagal"
}

normalize_cups_source_mode() {
    local mode="${1:-anujdatar}"
    mode="$(printf '%s' "$mode" | tr '[:upper:]' '[:lower:]')"

    case "$mode" in
        official|official-build|openprinting)
            echo "official-build"
            ;;
        ""|anujdatar|community|fallback|dockerhub)
            echo "anujdatar"
            ;;
        *)
            echo "anujdatar"
            ;;
    esac
}

prepare_openprinting_cups_build_context() {
    local build_dir="${PERSIST_ROOT}/cups-official-build"
    mkdir -p "$build_dir"

    cat > "${build_dir}/Dockerfile" << 'EOF'
FROM debian:bookworm-slim

ARG CUPS_OPENPRINTING_TAG=v2.4.14

RUN apt-get update && apt-get install -y \
    build-essential autoconf automake libtool pkg-config git ca-certificates curl \
    libavahi-client-dev libavahi-common-dev libgnutls28-dev libssl-dev libkrb5-dev libpam0g-dev \
    libusb-1.0-0-dev zlib1g-dev libsystemd-dev libpaper-dev \
    cups-client cups-filters avahi-daemon \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch "${CUPS_OPENPRINTING_TAG}" https://github.com/OpenPrinting/cups.git /tmp/cups-src && \
    cd /tmp/cups-src && \
    ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var && \
    make -j"$(nproc)" && \
    make install && \
    rm -rf /tmp/cups-src

RUN mkdir -p /etc/cups /var/log/cups /var/run/cups

EXPOSE 631
CMD ["cupsd", "-f"]
EOF
}

smoke_test_cups_image() {
    local image="$1"
    local test_name="cups-smoke-$(date +%s)"

    docker rm -f "$test_name" >/dev/null 2>&1 || true

    if ! docker run -d --name "$test_name" "$image" >/dev/null 2>&1; then
        docker rm -f "$test_name" >/dev/null 2>&1 || true
        return 1
    fi

    sleep 5
    if ! docker ps --format '{{.Names}}' | grep -q "^${test_name}$"; then
        docker rm -f "$test_name" >/dev/null 2>&1 || true
        return 1
    fi

    docker exec "$test_name" lpstat -r >/dev/null 2>&1 || true
    docker rm -f "$test_name" >/dev/null 2>&1 || true
    return 0
}

resolve_cups_image() {
    local fallback_img="$CUPS_IMG"
    local source_mode
    local tag="$CUPS_OPENPRINTING_TAG"
    local official_img="${CUPS_OFFICIAL_IMAGE_REPO}:${tag}"
    local build_dir="${PERSIST_ROOT}/cups-official-build"
    source_mode="$(normalize_cups_source_mode "$CUPS_SOURCE_MODE")"

    if [[ "$source_mode" != "official-build" ]]; then
        log "CUPS mode: anujdatar/community image (${fallback_img})" >&2
        echo "$fallback_img"
        return 0
    fi

    if guard_network_or_skip "build OpenPrinting CUPS ${tag}"; then
        prepare_openprinting_cups_build_context
        log "Membangun CUPS resmi OpenPrinting tag ${tag}..." >&2
        if docker build --build-arg CUPS_OPENPRINTING_TAG="${tag}" -t "$official_img" "$build_dir" >/dev/null; then
            if smoke_test_cups_image "$official_img"; then
                log "CUPS official build sukses dan lulus smoke test: ${official_img}" >&2
                tg_send "🟢 [STB CUPS] Official build OK (${tag})"
                echo "$official_img"
                return 0
            fi
            warn "Smoke test CUPS official gagal, fallback ke ${fallback_img}"
            tg_send "🟡 [STB CUPS] Smoke test official gagal, fallback ke ${fallback_img}"
        else
            warn "Build CUPS official gagal, fallback ke ${fallback_img}"
            tg_send "🟡 [STB CUPS] Build official gagal, fallback ke ${fallback_img}"
        fi
    else
        if docker image inspect "$official_img" >/dev/null 2>&1; then
            log "Offline guard: pakai cached official image ${official_img}" >&2
            echo "$official_img"
            return 0
        fi
        warn "Offline guard: official image belum ada cache, fallback ke ${fallback_img}"
    fi

    echo "$fallback_img"
}

# -------------------------
# PREFLIGHT CHECK
# -------------------------
container_preflight_line() {
    local name="$1"
    local row status image running health icon

    row=$(docker ps -a --filter "name=^/${name}$" --format '{{.Names}}|{{.Status}}|{{.Image}}' | head -n1 || true)
    if [[ -z "$row" ]]; then
        echo "🟡 ${name}: ABSENT"
        return
    fi

    status=$(echo "$row" | cut -d'|' -f2)
    image=$(echo "$row" | cut -d'|' -f3)
    running="no"
    echo "$status" | grep -qi '^Up' && running="yes"

    health=$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$name" 2>/dev/null || echo "unknown")
    icon="🟡"
    if [[ "$running" == "yes" && ( "$health" == "healthy" || "$health" == "none" ) ]]; then
        icon="🟢"
    elif [[ "$running" == "no" || "$health" == "unhealthy" ]]; then
        icon="🔴"
    fi

    echo "${icon} ${name}: running=${running}, health=${health}, status=${status}, image=${image}"
}

port_preflight_line() {
    local port="$1"
    local state owner
    state="free"
    owner="-"

    if ss -tulpn 2>/dev/null | grep -q ":${port} "; then
        state="used"
        owner=$(ss -tulpn 2>/dev/null | awk -v p=":${port} " '$0 ~ p {print $0; exit}' | sed 's/[[:space:]]\+/ /g')
    fi

    if [[ "$state" == "free" ]]; then
        echo "🟢 port ${port}: free"
    else
        echo "🟡 port ${port}: used ${owner}"
    fi
}

run_preflight_checks() {
    local host now_s report has_conflict docker_ok overall_icon overall_txt
    host="$(hostname)"
    now_s="$(ts)"
    has_conflict="no"
    docker_ok="yes"

    log "Pre-flight: memeriksa Docker, container, port, dan potensi conflict..."

    if ! command -v docker >/dev/null 2>&1; then
        docker_ok="no"
    elif ! docker info >/dev/null 2>&1; then
        docker_ok="no"
    fi

    overall_icon="🟢"
    overall_txt="HEALTHY"
    report="[STB PREFLIGHT] ${host}\nTime: ${now_s}\n"
    report+="Feature: CUPS=${ENABLE_CUPS}, WEBUI=${ENABLE_EPSON_WEBUI}, SANE=${ENABLE_SANE}\n"
    report+="Docker: $( [[ "$docker_ok" == "yes" ]] && echo "🟢 ready" || echo "🔴 not-ready" )\n"

    if [[ "$docker_ok" == "no" ]]; then
        warn "Pre-flight: Docker belum siap."
        report+="🔴 Result: Docker not ready\n"
        [[ "$ENABLE_TELEGRAM" == "yes" && "$PREFLIGHT_NOTIFY_TELEGRAM" == "yes" ]] && tg_send "$report"
        return 0
    fi

    report+="Containers:\n"
    report+="$(container_preflight_line "$CUPS_CONTAINER_NAME")\n"
    report+="$(container_preflight_line "$CUPS_LEGACY_CONTAINER_NAME")\n"
    report+="$(container_preflight_line "epson-unified-hub")\n"
    report+="$(container_preflight_line "SCANNER")\n"

    if docker ps -a --format '{{.Names}}' | grep -q "^${CUPS_CONTAINER_NAME}$" && \
       docker ps -a --format '{{.Names}}' | grep -q "^${CUPS_LEGACY_CONTAINER_NAME}$"; then
        has_conflict="yes"
        overall_icon="🟡"
        overall_txt="NEEDS-ATTENTION"
        warn "Pre-flight: ditemukan dua nama container CUPS (${CUPS_CONTAINER_NAME} + ${CUPS_LEGACY_CONTAINER_NAME})."
        report+="🟡 Conflict: dual CUPS container names detected\n"
    fi

    report+="Ports:\n"
    report+="$(port_preflight_line "$CUPS_PORT")\n"
    report+="$(port_preflight_line "$WEBUI_PORT")\n"
    report+="$(port_preflight_line "$SANE_PORT")\n"

    report+="${overall_icon} Result: ${overall_txt} (conflict=${has_conflict})"
    log "Pre-flight selesai (conflict=${has_conflict})."

    if [[ "$ENABLE_TELEGRAM" == "yes" && "$PREFLIGHT_NOTIFY_TELEGRAM" == "yes" ]]; then
        tg_send "$report"
    fi
}

# ============================================================
# START
# ============================================================
touch "$LOGFILE"
log "===== STB PRINTSERVER SETUP FINAL v7 START ====="
protect_kernel_updates

if guard_network_or_skip "apt update"; then
    log "Update package manager..."
    apt-get update >/dev/null || warn "apt update gagal, lanjut mode lokal."
else
    warn "apt update dilewati (offline guard)."
fi

install_pkg curl
install_pkg jq
# #region agent log
agent_debug_log() {
    local hid="$1" loc="$2" msg="$3" data_json="${4:-{}}"
    local ts
    ts="$(($(date +%s) * 1000))"
    jq -nc \
        --arg sid "9761b3" \
        --arg hid "$hid" \
        --arg loc "$loc" \
        --arg msg "$msg" \
        --argjson ts "$ts" \
        --argjson data "$data_json" \
        '{sessionId:$sid,hypothesisId:$hid,location:$loc,message:$msg,data:$data,timestamp:$ts}' \
        >> "/Users/pcchopath/.cursor/debug-9761b3.log" 2>/dev/null \
        || jq -nc \
            --arg sid "9761b3" \
            --arg hid "$hid" \
            --arg loc "$loc" \
            --arg msg "$msg" \
            --argjson ts "$ts" \
            --argjson data "$data_json" \
            '{sessionId:$sid,hypothesisId:$hid,location:$loc,message:$msg,data:$data,timestamp:$ts}' \
            >> "/tmp/stb-debug-9761b3.log" 2>/dev/null \
            || true
}
# #endregion
install_pkg git
install_pkg iproute2
install_pkg ca-certificates
install_pkg net-tools
install_pkg isc-dhcp-client || true

bootstrap_wifi_stack

# #region agent log
agent_debug_log "H4" "setup.sh:wifi" "bootstrap_wifi_stack_returned" "{}"
# #endregion

# ===========================
# HOSTNAME
# ===========================
set_unique_hostname(){   # <-- fungsi yang sudah dijelaskan di atas
    local iface="${1:-eth0}"
    local mac
    if [[ -e "/sys/class/net/${iface}/address" ]]; then
        mac=$(<"/sys/class/net/${iface}/address")
    else
        log "Interface ${iface} tidak ditemukan, mencari interface lain..."
        iface=$(ls -1 /sys/class/net | grep -v '^lo$' | head -n1)
        # #region agent log
        _ec=0
        command -v error >/dev/null 2>&1 && _ec=1 || _ec=0
        _stb_h1_data="$(jq -nc --arg iface "${iface:-}" --argjson ec "$_ec" '{iface:$iface,error_cmd_exists:$ec}' 2>/dev/null || echo '{"iface":"","error_cmd_exists":0}')"
        agent_debug_log "H1" "setup.sh:set_unique_hostname" "before_empty_iface_check" "${_stb_h1_data}"
        unset _ec _stb_h1_data
        # #endregion
        [[ -z "$iface" ]] && error "Tidak ada interface jaringan yang dapat di‑deteksi."
        mac=$(<"/sys/class/net/${iface}/address")
        log "Menggunakan interface ${iface} dengan MAC $mac"
    fi
    mac=$(echo "$mac" | tr -d ':' | cut -c1-6)
    local new_hostname="armbian-${mac}"
    local cur_hostname=$(hostnamectl --static)

    if [[ "$cur_hostname" == "$new_hostname" ]]; then
        log "Hostname sudah unik: $cur_hostname"
        return 0
    fi

    log "Mengubah hostname menjadi: $new_hostname"
    echo "$new_hostname" > /etc/hostname
    if grep -q '^127\.0\.1\.1' /etc/hosts; then
        sed -i "s/^127\.0\.1\.1.*/127.0.1.1\t${new_hostname}/" /etc/hosts
    else
        echo -e "127.0.1.1\t${new_hostname}" >> /etc/hosts
    fi
    hostnamectl set-hostname "$new_hostname"
    log "Hostname berhasil di‑set ke $new_hostname"
}

# Hostname unik
set_unique_hostname   # <-- pakai eth0 (default)

# ============================================================
# Docker
# ============================================================
if ! command -v docker >/dev/null 2>&1; then
    guard_network_or_skip "install Docker" || die "Docker belum ada dan internet terputus."
    if confirm_yes_no "Docker belum terpasang. Install Docker sekarang?" "${CRITICAL_CONFIRM_DEFAULT:-no}"; then
        log "Docker belum ada → install..."
        curl -fsSL https://get.docker.com | sh || die "Install docker gagal"
        systemctl enable --now docker || true
    else
        die "Docker wajib untuk deployment, tetapi instalasi dibatalkan user."
    fi
else
    log "Docker sudah terpasang."
fi

if [[ "$ENABLE_PREFLIGHT" == "yes" ]]; then
    run_preflight_checks
fi

# ============================================================
# Persist dirs
# ============================================================
log "Membuat folder persistensi..."
mkdir -p "$PERSIST_ROOT" "$CUPS_CONF" "$CUPS_LOG" "$WEBUI_DIR" "$SHARE_DIR"
chmod -R 755 "$PERSIST_ROOT"
log "Folder persistensi siap."

_CUPS_SOURCE_MODE_ORIG="$CUPS_SOURCE_MODE"
CUPS_SOURCE_MODE="$(normalize_cups_source_mode "$CUPS_SOURCE_MODE")"
if [[ "${_CUPS_SOURCE_MODE_ORIG,,}" != "${CUPS_SOURCE_MODE,,}" ]]; then
    warn "CUPS_SOURCE_MODE '${_CUPS_SOURCE_MODE_ORIG}' tidak dikenal, fallback ke '${CUPS_SOURCE_MODE}'."
fi

HOSTNAME_BRAND_EFFECTIVE="$(resolve_hostname_brand_interactive 2>/dev/null || resolve_hostname_brand_default 2>/dev/null || echo printer)"
TS_HOSTNAME_EFFECTIVE_HINT="$(build_tailscale_hostname_hint 2>/dev/null || true)"
DEVICE_HOSTNAME_EFFECTIVE="${TS_HOSTNAME_EFFECTIVE_HINT:-$(sanitize_dns_label "$(hostname -s 2>/dev/null || hostname)")}"
if [[ -n "$DEVICE_HOSTNAME_EFFECTIVE" ]]; then
    apply_system_hostname "$DEVICE_HOSTNAME_EFFECTIVE"
fi
log "Hostname branding dipilih: ${HOSTNAME_BRAND_EFFECTIVE} -> ${DEVICE_HOSTNAME_EFFECTIVE}"
DEFAULT_REMOTE_PRINT_HOST_HINT="$(sanitize_dns_host_hint "${DEVICE_HOSTNAME_EFFECTIVE:-$(hostname -s)}")"
REMOTE_PRINT_HOST_HINT="$(sanitize_dns_host_hint "${REMOTE_PRINT_HOST_HINT:-${TS_HOSTNAME_EFFECTIVE_HINT:-${DEFAULT_REMOTE_PRINT_HOST_HINT}}}")"

RUNTIME_ENV_FILE="${PERSIST_ROOT}/runtime.env"
cat > "$RUNTIME_ENV_FILE" << EOF
TELEGRAM_TOKEN=${TELEGRAM_TOKEN}
TELEGRAM_CHAT_ID=${TELEGRAM_CHAT_ID}
ENABLE_WHATSAPP=${ENABLE_WHATSAPP}
WA_PROVIDER=${WA_PROVIDER}
WA_GRAPH_VERSION=${WA_GRAPH_VERSION}
WA_TOKEN=${WA_TOKEN}
WA_PHONE_NUMBER_ID=${WA_PHONE_NUMBER_ID}
WA_TO=${WA_TO}
WA_MESSAGE_TYPE=${WA_MESSAGE_TYPE}
WA_TEMPLATE_NAME=${WA_TEMPLATE_NAME}
WA_TEMPLATE_LANG=${WA_TEMPLATE_LANG}
SNMP_WRITE=${SNMP_WRITE}
TELEGRAM_ACTIVITY_NOTIFY=${TELEGRAM_ACTIVITY_NOTIFY}
REINKPY_NOTIFY_HOURS=${REINKPY_NOTIFY_HOURS}
REINKPY_AUTO_CHECK_ON_START=${REINKPY_AUTO_CHECK_ON_START}
REINKPY_SOURCE_MODE=${REINKPY_SOURCE_MODE}
REINKPY_FIX_STALE_DAYS=${REINKPY_FIX_STALE_DAYS}
WASTE_WARN_THRESHOLD=${WASTE_WARN_THRESHOLD}
WASTE_ALERT_THRESHOLD=${WASTE_ALERT_THRESHOLD}
WASTE_RECOVER_THRESHOLD=${WASTE_RECOVER_THRESHOLD}
INK_WARN_THRESHOLD=${INK_WARN_THRESHOLD}
INK_CRITICAL_THRESHOLD=${INK_CRITICAL_THRESHOLD}
INK_RECOVER_THRESHOLD=${INK_RECOVER_THRESHOLD}
ENABLE_BACKGROUND_MONITOR=${ENABLE_BACKGROUND_MONITOR}
MONITOR_INTERVAL_SECONDS=${MONITOR_INTERVAL_SECONDS}
BUSINESS_START_HOUR=${BUSINESS_START_HOUR}
BUSINESS_END_HOUR_WEEKDAY=${BUSINESS_END_HOUR_WEEKDAY}
BUSINESS_END_HOUR_SATURDAY=${BUSINESS_END_HOUR_SATURDAY}
ENABLE_AUTO_REBUILD=${ENABLE_AUTO_REBUILD}
ENABLE_HOUSEKEEPING=${ENABLE_HOUSEKEEPING}
ENABLE_STORAGE_TRIM=${ENABLE_STORAGE_TRIM}
RUN_STORAGE_TRIM_ON_SETUP=${RUN_STORAGE_TRIM_ON_SETUP}
HOUSEKEEPING_JOURNAL_MAX=${HOUSEKEEPING_JOURNAL_MAX}
HOUSEKEEPING_LOG_KEEP_LINES=${HOUSEKEEPING_LOG_KEEP_LINES}
HOUSEKEEPING_TMP_DAYS=${HOUSEKEEPING_TMP_DAYS}
HOUSEKEEPING_DOCKER_RETENTION_HOURS=${HOUSEKEEPING_DOCKER_RETENTION_HOURS}
HOUSEKEEPING_RESTART_MAINTENANCE=${HOUSEKEEPING_RESTART_MAINTENANCE}
HEALTHCHECK_SEND_OK=${HEALTHCHECK_SEND_OK}
OFFLINE_MODE_GUARD=${OFFLINE_MODE_GUARD}
PROTECT_KERNEL_UPDATES=${PROTECT_KERNEL_UPDATES}
CRITICAL_CONFIRMATIONS=${CRITICAL_CONFIRMATIONS}
CRITICAL_CONFIRM_DEFAULT=${CRITICAL_CONFIRM_DEFAULT}
ENABLE_WIFI_BOOTSTRAP=${ENABLE_WIFI_BOOTSTRAP}
WIFI_DRIVER_FALLBACK_BUILD=${WIFI_DRIVER_FALLBACK_BUILD}
WIFI_FALLBACK_REPO=${WIFI_FALLBACK_REPO}
WIFI_FALLBACK_BRANCH=${WIFI_FALLBACK_BRANCH}
WIFI_FALLBACK_MODULE=${WIFI_FALLBACK_MODULE}
PRINTER_WATCH_INTERVAL_SECONDS=${PRINTER_WATCH_INTERVAL_SECONDS}
CUPS_AUTO_QUEUE_NAME=${CUPS_AUTO_QUEUE_NAME}
HOSTNAME_PROMPT_ON_SETUP=${HOSTNAME_PROMPT_ON_SETUP}
HOSTNAME_BRAND=${HOSTNAME_BRAND_EFFECTIVE}
HOSTNAME_BRAND_EFFECTIVE=${HOSTNAME_BRAND_EFFECTIVE}
HOSTNAME_APPLY_SYSTEM=${HOSTNAME_APPLY_SYSTEM}
DEVICE_HOSTNAME_EFFECTIVE=${DEVICE_HOSTNAME_EFFECTIVE}
TS_AUTO_ENABLE_SERVICE=${TS_AUTO_ENABLE_SERVICE}
TS_ACCEPT_ROUTES=${TS_ACCEPT_ROUTES}
TS_ACCEPT_DNS=${TS_ACCEPT_DNS}
TS_HOSTNAME=${TS_HOSTNAME}
TS_HOSTNAME_PREFIX=${TS_HOSTNAME_PREFIX}
TS_HOSTNAME_EFFECTIVE_HINT=${TS_HOSTNAME_EFFECTIVE_HINT}
TS_ADVERTISE_EXIT_NODE=${TS_ADVERTISE_EXIT_NODE}
TS_RESET_ON_UP=${TS_RESET_ON_UP}
TS_TAG=${TS_TAG}
TS_BYPASS_SUBNETS=${TS_BYPASS_SUBNETS}
NET_AUTOHEAL_ENABLED=${NET_AUTOHEAL_ENABLED}
SHOW_HOSTNAME_ON_CARDS=${SHOW_HOSTNAME_ON_CARDS}
WEBUI_DIR=${WEBUI_DIR}
CUPS_CONTAINER_NAME=${CUPS_CONTAINER_NAME}
PRINT_PORTAL_CONTAINER_NAME=${PRINT_PORTAL_CONTAINER_NAME}
CUPS_SOURCE_MODE=${CUPS_SOURCE_MODE}
CUPS_OPENPRINTING_TAG=${CUPS_OPENPRINTING_TAG}
CUPS_OFFICIAL_IMAGE_REPO=${CUPS_OFFICIAL_IMAGE_REPO}
CUPS_PORT=${CUPS_PORT}
CUPS_REMOTE_ADMIN=${CUPS_REMOTE_ADMIN}
CUPS_REMOTE_ADMIN_ALLOW_NET=${CUPS_REMOTE_ADMIN_ALLOW_NET}
CUPS_HOSTNAME_LOOKUPS=${CUPS_HOSTNAME_LOOKUPS}
CUPS_SERVER_HOST=${CUPS_SERVER_HOST}
WEBUI_NETWORK_MODE=${WEBUI_NETWORK_MODE}
WEB_PRINT_PORT=${WEB_PRINT_PORT}
WEBUI_DEBUG=${WEBUI_DEBUG}
SANE_PORT=${SANE_PORT}
WEBUI_PORT=${WEBUI_PORT}
WEB_PRINT_ENABLED=${WEB_PRINT_ENABLED}
WEB_PRINT_MAX_MB=${WEB_PRINT_MAX_MB}
WEB_PRINT_ALLOWED_EXTS=${WEB_PRINT_ALLOWED_EXTS}
REMOTE_PRINT_HOST_HINT=${REMOTE_PRINT_HOST_HINT}
CASAOS_ROOT=${CASAOS_ROOT}
CASAOS_APPS=${CASAOS_APPS}
EOF
chmod 600 "$RUNTIME_ENV_FILE"
log "Runtime env disimpan: $RUNTIME_ENV_FILE"

# #region agent log
agent_debug_log "H2" "setup.sh:ip" "before_get_host_ip" "{}"
# #endregion
IP_LAN="$(get_host_ip)"
# #region agent log
_stb_h2_data="$(jq -nc --arg ip "${IP_LAN:-}" '{ip:$ip,empty:($ip=="")}' 2>/dev/null || echo '{"ip":"","empty":true}')"
agent_debug_log "H2" "setup.sh:ip" "after_get_host_ip" "${_stb_h2_data}"
unset _stb_h2_data
# #endregion
[[ -z "$IP_LAN" ]] && die "Gagal mendapatkan IP host"
log "IP Host: $IP_LAN"

# ============================================================
# CasaOS
# ============================================================
if [[ "$ENABLE_CASAOS" == "yes" ]]; then
    if systemctl is-active --quiet casaos.service 2>/dev/null; then
        log "CasaOS sudah terinstall."
    else
        if confirm_yes_no "CasaOS belum aktif. Install CasaOS sekarang?" "${CRITICAL_CONFIRM_DEFAULT:-no}"; then
            log "Install CasaOS..."
            curl -fsSL https://get.casaos.io | bash || warn "CasaOS gagal install (skip)"
        else
            warn "Install CasaOS dibatalkan oleh user."
        fi
    fi
fi

mkdir -p "$CASAOS_ROOT" "$CASAOS_APPS"

 # -----------------------------------------------------------------
 # Generate Dockerfile
 # -----------------------------------------------------------------
  cat > "$WEBUI_DIR/Dockerfile" << 'EOF'
FROM python:3.11-slim

ARG REINKPY_SOURCE_MODE=auto
ARG REINKPY_FIX_STALE_DAYS=21
ENV REINKPY_SOURCE_MODE=${REINKPY_SOURCE_MODE}
ENV REINKPY_FIX_STALE_DAYS=${REINKPY_FIX_STALE_DAYS}
ENV REINKPY_ACTIVE_PATH=/app/reinkpy_active

RUN apt-get update && \
    apt-get install -y git usbutils cups-client curl && \
    rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir --upgrade pip wheel && \
    pip install --no-cache-dir "setuptools==79.0.1" && \
    pip install --no-cache-dir \
    "pysnmp>=7.1.20" \
    hexdump2 \
    pyserial \
    pyyaml \
    requests \
    flask \
    pillow && \
    pip install --no-cache-dir --no-build-isolation \
    "pyprintlpr>=1.0.3" \
    "text-console>=2.0.7" \
    "epson-escp2>=1.0.2" \
    "pysnmp_sync_adapter>=1.0.8"

RUN git clone --depth 1 https://github.com/Ircama/epson_print_conf.git /app/epson_print_conf

# clone original and install
RUN git clone --depth 1 https://codeberg.org/atufi/reinkpy.git /app/reinkpy_original && \
    pip install --no-cache-dir "/app/reinkpy_original[ui,usb,net]"

# clone patch (optional, may fail if remote unavailable)
RUN git clone --depth 1 https://github.com/LeFZdev/reinkpy-fix /app/reinkpy_fix || true

# choose active source: auto/fix/original
RUN python3 - <<'PY'
import json
import os
import subprocess
from datetime import datetime, timezone

def sha(path):
    try:
        return subprocess.check_output(["git", "-C", path, "rev-parse", "HEAD"], text=True).strip()
    except Exception:
        return None

def commit_date_iso(path):
    try:
        return subprocess.check_output(["git", "-C", path, "log", "-1", "--format=%cI"], text=True).strip()
    except Exception:
        return None

def parse_iso(v):
    if not v:
        return None
    try:
        if v.endswith("Z"):
            v = v.replace("Z", "+00:00")
        return datetime.fromisoformat(v).astimezone(timezone.utc)
    except Exception:
        return None

def has_pkg(path):
    return os.path.exists(os.path.join(path, "pyproject.toml")) or os.path.exists(os.path.join(path, "setup.py"))

mode = (os.getenv("REINKPY_SOURCE_MODE", "auto") or "auto").strip().lower()
if mode not in {"auto", "fix", "original"}:
    mode = "auto"

try:
    stale_days = int((os.getenv("REINKPY_FIX_STALE_DAYS", "21") or "21").strip())
except Exception:
    stale_days = 21
if stale_days < 0:
    stale_days = 0

orig_exists = os.path.isdir("/app/reinkpy_original")
fix_exists = os.path.isdir("/app/reinkpy_fix")
orig_sha = sha("/app/reinkpy_original")
fix_sha = sha("/app/reinkpy_fix")
orig_date_iso = commit_date_iso("/app/reinkpy_original")
fix_date_iso = commit_date_iso("/app/reinkpy_fix")
orig_dt = parse_iso(orig_date_iso)
fix_dt = parse_iso(fix_date_iso)

active_source = "original"
selection_reason = "default_original"

if mode == "original":
    active_source = "original"
    selection_reason = "forced_original"
elif mode == "fix":
    if fix_exists and has_pkg("/app/reinkpy_fix"):
        active_source = "fix"
        selection_reason = "forced_fix"
    elif fix_exists:
        active_source = "original"
        selection_reason = "forced_fix_but_invalid_package"
    else:
        active_source = "original"
        selection_reason = "forced_fix_but_missing"
else:
    if fix_exists and has_pkg("/app/reinkpy_fix"):
        active_source = "fix"
        selection_reason = "auto_fix_preferred"
        if orig_dt and fix_dt:
            delta_days = (orig_dt - fix_dt).days
            if delta_days >= stale_days:
                active_source = "original"
                selection_reason = f"auto_switch_original_fix_stale_{delta_days}d"
    elif fix_exists:
        active_source = "original"
        selection_reason = "auto_fix_invalid_package"
    else:
        active_source = "original"
        selection_reason = "auto_fix_missing"

active_path = "/app/reinkpy_fix" if active_source == "fix" else "/app/reinkpy_original"
try:
    if os.path.islink("/app/reinkpy_active") or os.path.exists("/app/reinkpy_active"):
        os.unlink("/app/reinkpy_active")
except Exception:
    pass
os.symlink(active_path, "/app/reinkpy_active")

meta = {
    "built_at_utc": subprocess.check_output(["date", "-u", "+%Y-%m-%dT%H:%M:%SZ"], text=True).strip(),
    "source_mode_requested": mode,
    "fix_stale_days": stale_days,
    "active_source": active_source,
    "active_path": active_path,
    "selection_reason": selection_reason,
    "repos": {
        "reinkpy_original": {
            "url": "https://codeberg.org/atufi/reinkpy",
            "exists": orig_exists,
            "commit": orig_sha,
            "commit_date_utc": orig_date_iso
        },
        "reinkpy_fix": {
            "url": "https://github.com/LeFZdev/reinkpy-fix",
            "exists": fix_exists,
            "commit": fix_sha,
            "commit_date_utc": fix_date_iso
        }
    }
}
with open("/app/reinkpy_meta.json", "w") as f:
    json.dump(meta, f, indent=2)
with open("/app/reinkpy_active_source", "w") as f:
    f.write(active_source)
PY

# install fix override only when selected as active source
RUN if [ "$(cat /app/reinkpy_active_source 2>/dev/null || echo original)" = "fix" ] && \
      [ -d /app/reinkpy_fix ] && \
      { [ -f /app/reinkpy_fix/pyproject.toml ] || [ -f /app/reinkpy_fix/setup.py ]; }; then \
      pip install --no-cache-dir -e /app/reinkpy_fix || true; \
    fi

WORKDIR /app

COPY webui.py /app/webui.py

CMD ["python3", "/app/webui.py"]
EOF
# ============================================================
# Epson WebUI Container (Ircama)
# ============================================================
if [[ "$ENABLE_EPSON_WEBUI" == "yes" ]]; then
    log "Deploy Maintenance Tools"

    WEBUI_PORT="$(free_port_or_fallback "$WEBUI_PORT")" || die "Tidak ada port kosong Maintenance Tools"
    log "Maintenance Tools port digunakan: $WEBUI_PORT"
    
mkdir -p "$WEBUI_DIR"

cat > "$WEBUI_DIR/webui.py" << 'EOF'
import os
import sys
ACTIVE_REINKPY_PATH = os.getenv("REINKPY_ACTIVE_PATH", "/app/reinkpy_active").strip()
if ACTIVE_REINKPY_PATH and os.path.isdir(ACTIVE_REINKPY_PATH):
    sys.path.insert(0, ACTIVE_REINKPY_PATH)
import re
import json
import time
import socket
import threading
import subprocess
import tempfile
import requests
from datetime import datetime
from flask import Flask, request, jsonify, render_template_string, abort
from werkzeug.utils import secure_filename

# SNMP SYNC (NO SUBPROCESS)
from pysnmp.hlapi import *

# MAINTENACE MODE
from epson_escp2.epson_encode import EpsonEscp2
from pyprintlpr import LprClient

app = Flask(__name__)

# #region agent log
def _agent_debug_log(hypothesis_id, location, message, data=None):
    import json
    import time
    try:
        payload = {
            "sessionId": "9761b3",
            "hypothesisId": hypothesis_id,
            "location": location,
            "message": message,
            "data": data or {},
            "timestamp": int(time.time() * 1000),
        }
        line = json.dumps(payload, ensure_ascii=False) + "\n"
        for path in ("/Users/pcchopath/.cursor/debug-9761b3.log", "/tmp/stb-debug-9761b3.log"):
            try:
                with open(path, "a", encoding="utf-8") as f:
                    f.write(line)
                break
            except Exception:
                continue
    except Exception:
        pass
# #endregion

PORTAL_ALLOWED_ENDPOINTS = {
    "home",
    "favicon",
    "printers",
    "print_submit",
}

# ==========================
# ENV CONFIG
# ==========================
TELEGRAM_TOKEN = os.getenv("TELEGRAM_TOKEN", "").strip()
TELEGRAM_CHAT_ID = os.getenv("TELEGRAM_CHAT_ID", "").strip()
ENABLE_WHATSAPP = os.getenv("ENABLE_WHATSAPP", "no").strip().lower()
WA_PROVIDER = os.getenv("WA_PROVIDER", "meta").strip().lower()
WA_GRAPH_VERSION = os.getenv("WA_GRAPH_VERSION", "v23.0").strip()
WA_TOKEN = os.getenv("WA_TOKEN", "").strip()
WA_PHONE_NUMBER_ID = os.getenv("WA_PHONE_NUMBER_ID", "").strip()
WA_TO = os.getenv("WA_TO", "").strip()
WA_MESSAGE_TYPE = os.getenv("WA_MESSAGE_TYPE", "text").strip().lower()
WA_TEMPLATE_NAME = os.getenv("WA_TEMPLATE_NAME", "stb_print_alert").strip()
WA_TEMPLATE_LANG = os.getenv("WA_TEMPLATE_LANG", "id").strip()

WASTE_ALERT_THRESHOLD = int(os.getenv("WASTE_ALERT_THRESHOLD", "90"))
WASTE_WARN_THRESHOLD = int(os.getenv("WASTE_WARN_THRESHOLD", "80"))
WASTE_RECOVER_THRESHOLD = int(os.getenv("WASTE_RECOVER_THRESHOLD", "70"))
INK_WARN_THRESHOLD = int(os.getenv("INK_WARN_THRESHOLD", "20"))
INK_CRITICAL_THRESHOLD = int(os.getenv("INK_CRITICAL_THRESHOLD", "10"))
INK_RECOVER_THRESHOLD = int(os.getenv("INK_RECOVER_THRESHOLD", "30"))
STATUS_CACHE_SECONDS = int(os.getenv("STATUS_CACHE_SECONDS", "15"))
ENABLE_BACKGROUND_MONITOR = os.getenv("ENABLE_BACKGROUND_MONITOR", "yes").strip().lower() == "yes"
MONITOR_INTERVAL_SECONDS = int(os.getenv("MONITOR_INTERVAL_SECONDS", "300"))

LOCK_FILE = "/tmp/epson_lock.json"
CACHE_FILE = "/tmp/epson_status_cache.json"
ALERT_FILE = "/tmp/epson_alert_state.json"

IPPUSB_PORT_MIN = int(os.getenv("IPPUSB_PORT_MIN", "60000"))
IPPUSB_PORT_MAX = int(os.getenv("IPPUSB_PORT_MAX", "60150"))

DEFAULT_MODEL = os.getenv("DEFAULT_MODEL", "L3110").strip()
SNMP_COMMUNITY = os.getenv("SNMP_COMMUNITY", "public").strip()
SNMP_TIMEOUT = float(os.getenv("SNMP_TIMEOUT", "1.2"))
SNMP_RETRIES = int(os.getenv("SNMP_RETRIES", "1"))
STATUS_CACHE_SECONDS = int(os.getenv("STATUS_CACHE_SECONDS", "10"))

LOG_FILE = "/tmp/epson_activity_log.json"
LOG_MAX = int(os.getenv("LOG_MAX", "200"))
REINKPY_META_FILE = "/app/reinkpy_meta.json"
REINKPY_UPDATE_STATE_FILE = "/tmp/reinkpy_update_state.json"
UPDATE_STATUS_FILE = "/opt/stb_printserver/reinkpy_update_status.json"
UPDATE_PROGRESS_FILE = "/opt/stb_printserver/reinkpy_update_progress.log"
REINKPY_OVERRIDE_FILE = "/opt/stb_printserver/reinkpy_source_override.json"
REINKPY_ORIGIN_REPO = "https://codeberg.org/atufi/reinkpy"
REINKPY_FIX_REPO = "https://github.com/LeFZdev/reinkpy-fix"
REINKPY_NOTIFY_HOURS = int(os.getenv("REINKPY_NOTIFY_HOURS", "24"))
REINKPY_SOURCE_MODE = os.getenv("REINKPY_SOURCE_MODE", "auto").strip().lower()
try:
    REINKPY_FIX_STALE_DAYS = int(os.getenv("REINKPY_FIX_STALE_DAYS", "21"))
except Exception:
    REINKPY_FIX_STALE_DAYS = 21
TELEGRAM_ACTIVITY_NOTIFY = os.getenv("TELEGRAM_ACTIVITY_NOTIFY", "yes").strip().lower()
UPDATE_REQUEST_FILE = "/opt/stb_printserver/reinkpy_update.request"
REINKPY_RUNTIME_ACTIVE_PATH = "/app/reinkpy_active"
REINKPY_PATH_ORIGINAL = "/app/reinkpy_original"
REINKPY_PATH_FIX = "/app/reinkpy_fix"
CUPS_SERVER_HOST = os.getenv("CUPS_SERVER_HOST", "host.docker.internal").strip() or "host.docker.internal"
CUPS_SERVER_PORT = str(os.getenv("CUPS_SERVER_PORT", "631")).strip() or "631"
WEBUI_NETWORK_MODE = os.getenv("WEBUI_NETWORK_MODE", "bridge").strip().lower() or "bridge"
WEBUI_MODE = os.getenv("WEBUI_MODE", "maintenance").strip().lower() or "maintenance"
if WEBUI_MODE not in {"maintenance", "portal", "unified"}:
    WEBUI_MODE = "maintenance"
WEBUI_DEBUG = os.getenv("WEBUI_DEBUG", "no").strip().lower() == "yes"
try:
    WEB_LISTEN_PORT = max(1, min(65535, int(os.getenv("WEB_LISTEN_PORT", "5000"))))
except Exception:
    WEB_LISTEN_PORT = 5000
LOCAL_SERVICE_HOST = os.getenv("LOCAL_SERVICE_HOST", "").strip()
CUPS_PAGE_LOG_PATH = os.getenv("CUPS_PAGE_LOG_PATH", "/opt/stb_printserver/cups/log/page_log").strip()
PRINT_AUDIT_FILE = os.getenv("PRINT_AUDIT_FILE", "/opt/stb_printserver/print_portal_audit.json").strip()
WEB_PRINT_ENABLED = os.getenv("WEB_PRINT_ENABLED", "yes").strip().lower() == "yes"
try:
    WEB_PRINT_MAX_MB = max(1, int(os.getenv("WEB_PRINT_MAX_MB", "25")))
except Exception:
    WEB_PRINT_MAX_MB = 25
WEB_PRINT_ALLOWED_EXTS = tuple(
    sorted({
        ext.strip().lower().lstrip(".")
        for ext in os.getenv("WEB_PRINT_ALLOWED_EXTS", "pdf,png,jpg,jpeg,txt").split(",")
        if ext.strip()
    })
)
if not WEB_PRINT_ALLOWED_EXTS:
    WEB_PRINT_ALLOWED_EXTS = ("pdf", "png", "jpg", "jpeg", "txt")
REMOTE_PRINT_HOST_HINT = os.getenv("REMOTE_PRINT_HOST_HINT", "").strip()

# ==========================
# UTILS
# ==========================
def now():
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")

def run_cmd(cmd, timeout=30):
    try:
        p = subprocess.run(
            cmd,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=timeout,
            text=True
        )
        return {
            "cmd": cmd,
            "returncode": p.returncode,
            "stdout": p.stdout.strip(),
            "stderr": p.stderr.strip()
        }
    except Exception as e:
        return {
            "cmd": cmd,
            "returncode": 99,
            "stdout": "",
            "stderr": str(e)
        }

def run_cmd_list(cmd, timeout=30):
    try:
        p = subprocess.run(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=timeout,
            text=True
        )
        return {
            "cmd": " ".join(cmd),
            "returncode": p.returncode,
            "stdout": p.stdout.strip(),
            "stderr": p.stderr.strip()
        }
    except Exception as e:
        return {
            "cmd": " ".join(cmd),
            "returncode": 99,
            "stdout": "",
            "stderr": str(e)
        }

def tg_send(text):
    msg = str(text or "")
    try:
        if TELEGRAM_TOKEN and TELEGRAM_CHAT_ID:
            requests.post(
                f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage",
                data={"chat_id": TELEGRAM_CHAT_ID, "text": msg},
                timeout=8
            )
    except Exception:
        pass
    wa_send(msg)

def wa_send(text):
    if ENABLE_WHATSAPP != "yes":
        return
    if WA_PROVIDER != "meta":
        return
    if not WA_TOKEN or not WA_PHONE_NUMBER_ID or not WA_TO:
        return
    try:
        to = WA_TO.lstrip("+")
        url = f"https://graph.facebook.com/{WA_GRAPH_VERSION or 'v23.0'}/{WA_PHONE_NUMBER_ID}/messages"
        msg = str(text or "")
        if WA_MESSAGE_TYPE == "template":
            payload = {
                "messaging_product": "whatsapp",
                "to": to,
                "type": "template",
                "template": {
                    "name": WA_TEMPLATE_NAME or "stb_print_alert",
                    "language": {"code": WA_TEMPLATE_LANG or "id"},
                    "components": [
                        {
                            "type": "body",
                            "parameters": [{"type": "text", "text": msg}]
                        }
                    ]
                }
            }
        else:
            payload = {
                "messaging_product": "whatsapp",
                "to": to,
                "type": "text",
                "text": {"preview_url": False, "body": msg}
            }
        requests.post(
            url,
            headers={
                "Authorization": f"Bearer {WA_TOKEN}",
                "Content-Type": "application/json"
            },
            json=payload,
            timeout=8
        )
    except Exception:
        pass

def read_json_file(path, default):
    try:
        if os.path.exists(path):
            with open(path, "r") as f:
                return json.load(f)
    except:
        pass
    return default

def write_json_file(path, data):
    try:
        d = os.path.dirname(path)
        if d:
            os.makedirs(d, exist_ok=True)
        with open(path, "w") as f:
            json.dump(data, f, indent=2)
    except:
        pass

def default_update_status():
    return {
        "state": "idle",
        "progress": 0,
        "message": "Belum ada update berjalan.",
        "request_id": None,
        "source": None,
        "started_at": None,
        "finished_at": None,
        "updated_at": now()
    }

def read_update_status():
    data = read_json_file(UPDATE_STATUS_FILE, {})
    if not isinstance(data, dict):
        data = {}
    base = default_update_status()
    base.update(data)
    return base

def write_update_status(**kwargs):
    st = read_update_status()
    for k, v in kwargs.items():
        st[k] = v
    st["updated_at"] = now()
    write_json_file(UPDATE_STATUS_FILE, st)
    return st

def append_update_progress(line):
    msg = f"[{now()}] {line}"
    try:
        os.makedirs(os.path.dirname(UPDATE_PROGRESS_FILE), exist_ok=True)
        with open(UPDATE_PROGRESS_FILE, "a") as f:
            f.write(msg + "\\n")
    except:
        pass

def tail_update_progress(lines=120):
    try:
        n = max(20, min(500, int(lines)))
    except:
        n = 120
    try:
        with open(UPDATE_PROGRESS_FILE, "r") as f:
            data = [x.rstrip("\\n") for x in f.readlines()]
        return data[-n:]
    except:
        return []

def short_sha(v):
    if not v:
        return None
    return str(v)[:10]

def tl_icon(level):
    if level == "red":
        return "🔴"
    if level == "yellow":
        return "🟡"
    return "🟢"

def get_repo_head(url):
    res = run_cmd(f"git ls-remote {url} HEAD", timeout=20)
    if res["returncode"] != 0:
        return None, res.get("stderr") or "git ls-remote failed"
    line = (res.get("stdout") or "").strip().splitlines()
    if not line:
        return None, "No data from remote"
    parts = line[0].split()
    if not parts:
        return None, "Invalid git ls-remote format"
    return parts[0], None

def normalize_source_mode(v):
    mode = str(v or "").strip().lower()
    if mode in {"auto", "fix", "original"}:
        return mode
    return "auto"

def source_from_path(path):
    p = os.path.realpath(path) if path else ""
    if "/app/reinkpy_fix" in p:
        return "fix"
    if "/app/reinkpy_original" in p:
        return "original"
    return "unknown"

def read_reinkpy_override():
    data = read_json_file(REINKPY_OVERRIDE_FILE, {})
    if not isinstance(data, dict):
        data = {}
    mode = normalize_source_mode(data.get("mode", "auto"))
    prev = normalize_source_mode(data.get("previous_mode", "auto"))
    return {
        "mode": mode,
        "previous_mode": prev,
        "set_at": data.get("set_at"),
        "set_by": data.get("set_by"),
        "note": data.get("note")
    }

def write_reinkpy_override(mode, previous_mode="auto", set_by="ui", note=None):
    payload = {
        "mode": normalize_source_mode(mode),
        "previous_mode": normalize_source_mode(previous_mode),
        "set_at": now(),
        "set_by": set_by,
        "note": note
    }
    write_json_file(REINKPY_OVERRIDE_FILE, payload)
    return payload

def runtime_link_source():
    try:
        if os.path.islink(REINKPY_RUNTIME_ACTIVE_PATH) or os.path.exists(REINKPY_RUNTIME_ACTIVE_PATH):
            return source_from_path(REINKPY_RUNTIME_ACTIVE_PATH)
    except Exception:
        pass
    return "unknown"

def clear_reinkpy_cache():
    for k in list(sys.modules.keys()):
        if k == "reinkpy" or k.startswith("reinkpy."):
            sys.modules.pop(k, None)

def apply_reinkpy_source(mode, set_by="ui", persist=True):
    mode = normalize_source_mode(mode)
    meta = read_json_file(REINKPY_META_FILE, {})
    build_active = normalize_source_mode(meta.get("active_source", "original"))
    current_link = runtime_link_source()
    current_effective = current_link if current_link != "unknown" else build_active

    target = build_active if mode == "auto" else mode
    target_path = REINKPY_PATH_FIX if target == "fix" else REINKPY_PATH_ORIGINAL
    if not os.path.isdir(target_path):
        return {
            "ok": False,
            "error": f"Source path tidak tersedia: {target_path}",
            "mode": mode,
            "current_effective_source": current_effective
        }

    try:
        if os.path.islink(REINKPY_RUNTIME_ACTIVE_PATH) or os.path.exists(REINKPY_RUNTIME_ACTIVE_PATH):
            os.unlink(REINKPY_RUNTIME_ACTIVE_PATH)
        os.symlink(target_path, REINKPY_RUNTIME_ACTIVE_PATH)
    except Exception as e:
        return {
            "ok": False,
            "error": f"Gagal update symlink active source: {e}",
            "mode": mode,
            "current_effective_source": current_effective
        }

    clear_reinkpy_cache()
    mod_file = None
    resolved_source = runtime_link_source()
    try:
        import reinkpy
        mod_file = getattr(reinkpy, "__file__", None)
        s = source_from_path(mod_file)
        if s in {"fix", "original"}:
            resolved_source = s
    except Exception:
        pass

    ov = read_reinkpy_override()
    if persist:
        ov = write_reinkpy_override(
            mode=mode,
            previous_mode=ov.get("mode", "auto"),
            set_by=set_by,
            note=f"effective={resolved_source}"
        )

    return {
        "ok": True,
        "mode": mode,
        "effective_source": resolved_source,
        "target_path": target_path,
        "module_file": mod_file,
        "build_active_source": build_active,
        "override": ov,
        "previous_effective_source": current_effective
    }

def get_reinkpy_meta():
    meta = read_json_file(REINKPY_META_FILE, {})
    local_file = None
    local_real = None
    fix_loaded = False
    original_loaded = False
    try:
        import reinkpy
        local_file = getattr(reinkpy, "__file__", None)
        local_real = os.path.realpath(local_file) if local_file else None
        if local_real and "/app/reinkpy_fix" in local_real:
            fix_loaded = True
        if local_real and "/app/reinkpy_original" in local_real:
            original_loaded = True
    except Exception:
        pass

    repos = meta.get("repos", {})
    override = read_reinkpy_override()
    runtime_link = runtime_link_source()
    active_source = meta.get("active_source")
    source_mode_requested = meta.get("source_mode_requested", REINKPY_SOURCE_MODE)
    selection_reason = meta.get("selection_reason")
    active_commit = None
    if active_source == "fix":
        active_commit = repos.get("reinkpy_fix", {}).get("commit")
    elif active_source == "original":
        active_commit = repos.get("reinkpy_original", {}).get("commit")

    runtime_effective_source = runtime_link if runtime_link != "unknown" else active_source
    runtime_mode = override.get("mode", "auto")
    if runtime_mode == "auto":
        runtime_mode = source_mode_requested if source_mode_requested in {"auto", "fix", "original"} else "auto"

    return {
        "ok": True,
        "built_at_utc": meta.get("built_at_utc"),
        "origin_commit": repos.get("reinkpy_original", {}).get("commit"),
        "fix_commit": repos.get("reinkpy_fix", {}).get("commit"),
        "active_commit": active_commit,
        "active_source": active_source,
        "source_mode_requested": source_mode_requested,
        "runtime_mode": runtime_mode,
        "runtime_override_mode": override.get("mode"),
        "runtime_override_previous_mode": override.get("previous_mode"),
        "runtime_override_set_at": override.get("set_at"),
        "runtime_override_set_by": override.get("set_by"),
        "runtime_effective_source": runtime_effective_source,
        "selection_reason": selection_reason,
        "fix_stale_days": meta.get("fix_stale_days", REINKPY_FIX_STALE_DAYS),
        "origin_repo": REINKPY_ORIGIN_REPO,
        "fix_repo": REINKPY_FIX_REPO,
        "reinkpy_file": local_file,
        "reinkpy_real_file": local_real,
        "fix_loaded": fix_loaded,
        "original_loaded": original_loaded,
        "fix_available": bool(repos.get("reinkpy_fix", {}).get("exists")) or os.path.isdir(REINKPY_PATH_FIX),
        "original_available": bool(repos.get("reinkpy_original", {}).get("exists")) or os.path.isdir(REINKPY_PATH_ORIGINAL)
    }

def maybe_notify_reinkpy_update(check_result):
    if not check_result.get("has_update"):
        return

    state = read_json_file(REINKPY_UPDATE_STATE_FILE, {"last_notified_ts": 0})
    last_ts = float(state.get("last_notified_ts", 0))
    now_ts = time.time()
    min_gap = max(1, REINKPY_NOTIFY_HOURS) * 3600

    if now_ts - last_ts < min_gap:
        return

    details = check_result.get("details", {})
    msg = (
        "[STB PRINTSERVER]\\n"
        "Update reinkpy terdeteksi\\n"
        f"Original local: {short_sha(details.get('origin_local'))} | remote: {short_sha(details.get('origin_remote'))}\\n"
        f"Patch local: {short_sha(details.get('fix_local'))} | remote: {short_sha(details.get('fix_remote'))}\\n"
        f"Time: {now()}"
    )
    tg_send(msg)
    write_json_file(REINKPY_UPDATE_STATE_FILE, {"last_notified_ts": now_ts, "last_result": check_result})

def check_reinkpy_update(notify=False):
    info = get_reinkpy_meta()
    origin_local = info.get("origin_commit")
    fix_local = info.get("fix_commit")
    active_source = info.get("runtime_effective_source") or info.get("active_source")

    origin_remote, origin_err = get_repo_head(REINKPY_ORIGIN_REPO)
    fix_remote, fix_err = get_repo_head(REINKPY_FIX_REPO)

    origin_update = bool(origin_local and origin_remote and origin_local != origin_remote)
    fix_update = bool(fix_local and fix_remote and fix_local != fix_remote)
    has_update_any = origin_update or fix_update
    if active_source == "original":
        has_update = origin_update
    elif active_source == "fix":
        has_update = fix_update or origin_update
    else:
        has_update = has_update_any

    result = {
        "ok": True,
        "has_update": has_update,
        "has_update_any": has_update_any,
        "details": {
            "active_source": active_source,
            "origin_local": origin_local,
            "origin_remote": origin_remote,
            "origin_update": origin_update,
            "origin_error": origin_err,
            "fix_local": fix_local,
            "fix_remote": fix_remote,
            "fix_update": fix_update,
            "fix_error": fix_err
        },
        "meta": info
    }

    if notify:
        maybe_notify_reinkpy_update(result)

    return result

def port_open(host, port, timeout=0.15):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(timeout)
        r = s.connect_ex((host, port))
        s.close()
        return r == 0
    except:
        return False

def is_ip(host):
    return bool(re.match(r"^\d+\.\d+\.\d+\.\d+$", host.strip()))

def resolve_local_service_host(host):
    normalized = str(host or "").strip()
    if normalized in {"", "127.0.0.1", "localhost"}:
        if LOCAL_SERVICE_HOST:
            return LOCAL_SERVICE_HOST
        if WEBUI_NETWORK_MODE == "host":
            return "127.0.0.1"
        runtime = detect_runtime()
        if runtime in {"docker", "container"}:
            return CUPS_SERVER_HOST or "host.docker.internal"
        return "127.0.0.1"
    return normalized

def build_ipp_uri(host, port, path="/ipp/print"):
    clean_path = str(path or "/ipp/print").strip()
    if not clean_path.startswith("/"):
        clean_path = "/" + clean_path
    return f"ipp://{host}:{int(port)}{clean_path}"

def ippusb_probe_hosts():
    hosts = []
    runtime = detect_runtime()

    if runtime in {"docker", "container"}:
        for host in [LOCAL_SERVICE_HOST, CUPS_SERVER_HOST, "host.docker.internal", "127.0.0.1"]:
            host = str(host or "").strip()
            if host and host not in hosts:
                hosts.append(host)
    else:
        hosts.extend(["127.0.0.1", "localhost"])

    return hosts

def scan_ippusb_targets():
    targets = []
    seen = set()
    for host in ippusb_probe_hosts():
        for p in range(IPPUSB_PORT_MIN, IPPUSB_PORT_MAX):
            if port_open(host, p, timeout=0.1):
                key = f"{host}:{p}"
                if key in seen:
                    continue
                seen.add(key)
                targets.append({
                    "host": host,
                    "port": p,
                    "uri": build_ipp_uri(host, p)
                })
    return targets

def scan_all_ippusb_ports():
    return [t["port"] for t in scan_ippusb_targets()]
    
# =========================
# LOGGER FUNCTION
# =========================
def get_client_ip():
    if request.headers.get("X-Forwarded-For"):
        return request.headers.get("X-Forwarded-For").split(",")[0].strip()
    return request.remote_addr

def log_activity(action, printer=None, result="OK", detail=None):
    logs = read_json_file(LOG_FILE, [])

    entry = {
        "time": now(),
        "ip": get_client_ip(),
        "action": action,
        "printer": printer,
        "result": result,
        "detail": detail
    }

    logs.insert(0, entry)

    # limit size
    logs = logs[:LOG_MAX]

    write_json_file(LOG_FILE, logs)

    if TELEGRAM_ACTIVITY_NOTIFY == "yes":
        important = {"NOZZLE", "CLEAN", "RESET_WASTE", "REINKPY_SWITCH", "REINKPY_RESTORE"}
        if action in important or result != "OK":
            msg = f"[STB ACTIVITY]\\n{action}\\nPrinter: {printer or '-'}\\nResult: {result}\\nDetail: {detail or '-'}\\nTime: {now()}"
            tg_send(msg)

def sanitize_log_token(value, limit=96):
    cleaned = str(value or "").replace("|", "_").replace("\\r", " ").replace("\\n", " ").strip()
    cleaned = re.sub(r"\\s+", "_", cleaned)
    if not cleaned:
        return ""
    return cleaned[:limit]

def parse_int(value, default=0, minimum=None, maximum=None):
    try:
        num = int(value)
    except Exception:
        num = default
    if minimum is not None:
        num = max(minimum, num)
    if maximum is not None:
        num = min(maximum, num)
    return num

def cups_server_endpoint():
    return f"{CUPS_SERVER_HOST}:{CUPS_SERVER_PORT}"

def allowed_upload(filename):
    ext = os.path.splitext(str(filename or ""))[1].lower().lstrip(".")
    return ext in WEB_PRINT_ALLOWED_EXTS

def parse_job_time(value):
    raw = str(value or "").strip()
    if not raw:
        return None
    for fmt in ("%Y-%m-%d %H:%M:%S", "%d/%b/%Y:%H:%M:%S %z"):
        try:
            return datetime.strptime(raw, fmt)
        except Exception:
            pass
    return None

def tail_file_lines(path, limit=120):
    try:
        n = max(20, min(1000, int(limit)))
    except Exception:
        n = 120
    try:
        with open(path, "r", errors="ignore") as f:
            lines = [x.rstrip("\\n") for x in f.readlines()]
        return lines[-n:]
    except Exception:
        return []

def parse_page_log_entry(line):
    raw = str(line or "").strip()
    if not raw:
        return None
    if "|" not in raw:
        return {
            "raw": raw,
            "printer": None,
            "user": None,
            "job_id": None,
            "time": None,
            "page": None,
            "copies": None,
            "billing": None,
            "origin": None,
            "title": raw,
            "media": None,
            "sides": None,
            "raw_only": True
        }

    parts = [p.strip() for p in raw.split("|", 10)]
    if len(parts) != 11:
        return {
            "raw": raw,
            "printer": None,
            "user": None,
            "job_id": None,
            "time": None,
            "page": None,
            "copies": None,
            "billing": None,
            "origin": None,
            "title": raw,
            "media": None,
            "sides": None,
            "raw_only": True
        }

    return {
        "raw": raw,
        "printer": parts[0] or None,
        "user": parts[1] or None,
        "job_id": parts[2] or None,
        "time": parts[3] or None,
        "page": parse_int(parts[4], default=0, minimum=0),
        "copies": parse_int(parts[5], default=1, minimum=1),
        "billing": parts[6] or None,
        "origin": parts[7] or None,
        "title": parts[8] or None,
        "media": parts[9] or None,
        "sides": parts[10] or None,
        "raw_only": False
    }

def read_recent_print_jobs(limit=60):
    raw_lines = tail_file_lines(CUPS_PAGE_LOG_PATH, limit=max(int(limit) * 6, 160))
    grouped = {}

    for raw in reversed(raw_lines):
        entry = parse_page_log_entry(raw)
        if not entry:
            continue
        if entry.get("raw_only"):
            key = f"raw::{raw}"
        else:
            key = f"{entry.get('printer') or '-'}::{entry.get('job_id') or raw}"

        if key not in grouped:
            grouped[key] = {
                "job_id": entry.get("job_id"),
                "printer": entry.get("printer"),
                "user": entry.get("user"),
                "time": entry.get("time"),
                "pages_logged": 0,
                "max_page": 0,
                "copies": entry.get("copies") or 1,
                "billing": entry.get("billing"),
                "origin": entry.get("origin"),
                "title": entry.get("title"),
                "media": entry.get("media"),
                "sides": entry.get("sides"),
                "raw": entry.get("raw"),
                "source": "cups-page-log"
            }

        current = grouped[key]
        if not entry.get("raw_only"):
            current["pages_logged"] += 1
            current["max_page"] = max(current["max_page"], entry.get("page") or 0)
            current["copies"] = max(current["copies"], entry.get("copies") or 1)
            current["billing"] = entry.get("billing") or current.get("billing")
            current["origin"] = entry.get("origin") or current.get("origin")
            current["title"] = entry.get("title") or current.get("title")
            current["media"] = entry.get("media") or current.get("media")
            current["sides"] = entry.get("sides") or current.get("sides")
            current["time"] = entry.get("time") or current.get("time")

    portal_logs = read_json_file(PRINT_AUDIT_FILE, [])
    if not isinstance(portal_logs, list):
        portal_logs = []
    portal_by_job = {
        str(item.get("job_id")): item
        for item in portal_logs
        if isinstance(item, dict) and item.get("job_id")
    }

    jobs = list(grouped.values())
    enriched = []
    seen_job_ids = set()

    for item in jobs:
        job_id = str(item.get("job_id") or "")
        portal = portal_by_job.get(job_id)
        if portal:
            item["portal_request_ip"] = portal.get("request_ip")
            item["portal_requester"] = portal.get("requester")
            item["portal_filename"] = portal.get("filename")
            item["portal_title"] = portal.get("title")
            item["portal_source"] = portal.get("source")
            seen_job_ids.add(job_id)
        item["_sort"] = parse_job_time(item.get("time")) or datetime.min
        enriched.append(item)

    for portal in portal_logs:
        if not isinstance(portal, dict):
            continue
        job_id = str(portal.get("job_id") or "")
        if not job_id or job_id in seen_job_ids:
            continue
        enriched.append({
            "job_id": portal.get("job_id"),
            "printer": portal.get("printer"),
            "user": None,
            "time": portal.get("time"),
            "pages_logged": 0,
            "max_page": 0,
            "copies": portal.get("copies") or 1,
            "billing": portal.get("billing"),
            "origin": portal.get("request_ip"),
            "title": portal.get("title"),
            "media": None,
            "sides": None,
            "raw": None,
            "source": "web-portal",
            "portal_request_ip": portal.get("request_ip"),
            "portal_requester": portal.get("requester"),
            "portal_filename": portal.get("filename"),
            "portal_title": portal.get("title"),
            "portal_source": portal.get("source"),
            "_sort": parse_job_time(portal.get("time")) or datetime.min
        })

    enriched.sort(key=lambda item: item.get("_sort", datetime.min), reverse=True)
    for item in enriched:
        item.pop("_sort", None)
    return enriched[:max(10, min(200, int(limit)))]

def tracked_page_count(job):
    pages_logged = parse_int((job or {}).get("pages_logged"), default=0, minimum=0)
    max_page = parse_int((job or {}).get("max_page"), default=0, minimum=0)
    return max(pages_logged, max_page)

def build_print_job_summary(limit=400):
    entries = read_recent_print_jobs(limit=limit)
    printer_map = {}
    total_jobs = 0
    total_pages = 0
    total_copies = 0
    portal_jobs = 0
    cups_jobs = 0

    for item in entries:
        printer_name = str(item.get("printer") or "Unknown printer")
        pages = tracked_page_count(item)
        copies = parse_int(item.get("copies"), default=1, minimum=1)
        source = str(item.get("portal_source") or item.get("source") or "unknown")
        source_group = "portal" if source == "web-portal" else "cups"

        total_jobs += 1
        total_pages += pages
        total_copies += copies
        if source_group == "portal":
            portal_jobs += 1
        else:
            cups_jobs += 1

        bucket = printer_map.setdefault(printer_name, {
            "printer": printer_name,
            "jobs": 0,
            "pages": 0,
            "copies": 0,
            "portal_jobs": 0,
            "cups_jobs": 0,
            "last_time": None,
            "last_title": None,
            "last_origin": None,
            "last_source": None,
        })
        bucket["jobs"] += 1
        bucket["pages"] += pages
        bucket["copies"] += copies
        if source_group == "portal":
            bucket["portal_jobs"] += 1
        else:
            bucket["cups_jobs"] += 1

        if not bucket["last_time"]:
            bucket["last_time"] = item.get("time")
            bucket["last_title"] = item.get("portal_title") or item.get("title")
            bucket["last_origin"] = item.get("portal_request_ip") or item.get("origin")
            bucket["last_source"] = source

    printers = sorted(
        printer_map.values(),
        key=lambda item: (
            item.get("jobs", 0),
            item.get("pages", 0),
            parse_job_time(item.get("last_time")) or datetime.min,
        ),
        reverse=True,
    )

    top_printer = printers[0] if printers else None
    last_job = entries[0] if entries else None

    return {
        "ok": True,
        "overview": {
            "tracked_jobs": total_jobs,
            "tracked_pages": total_pages,
            "tracked_copies": total_copies,
            "portal_jobs": portal_jobs,
            "cups_jobs": cups_jobs,
            "printers_with_activity": len(printers),
            "top_printer": top_printer,
            "last_job": {
                "printer": last_job.get("printer"),
                "time": last_job.get("time"),
                "title": last_job.get("portal_title") or last_job.get("title"),
                "source": last_job.get("portal_source") or last_job.get("source"),
                "pages": tracked_page_count(last_job),
            } if last_job else None,
        },
        "printers": printers,
        "recent_jobs": entries[:12],
    }

def append_portal_audit(entry):
    logs = read_json_file(PRINT_AUDIT_FILE, [])
    if not isinstance(logs, list):
        logs = []
    logs.insert(0, entry)
    logs = logs[:400]
    write_json_file(PRINT_AUDIT_FILE, logs)
    
# ==========================
# LOCK SYSTEM
# ==========================
def get_lock_state():
    state = read_json_file(LOCK_FILE, {"locked": False})

    if state.get("locked"):
        t = state.get("time")
        if t:
            try:
                dt = datetime.strptime(t, "%Y-%m-%d %H:%M:%S")
                if (datetime.now() - dt).seconds > 300:
                    return {"locked": False}
            except:
                pass

    return state

def set_lock(printer_name):
    state = {"locked": True, "printer": printer_name, "time": now()}
    write_json_file(LOCK_FILE, state)

def clear_lock():
    write_json_file(LOCK_FILE, {"locked": False, "printer": None, "time": None})

# ==========================
# USB DETECTOR (LSUSB)
# ==========================
def get_lsusb_list():
    res = run_cmd("lsusb", timeout=5)
    if res["returncode"] != 0:
        return {"ok": False, "error": res["stderr"], "raw": res["stdout"], "devices": []}

    devices = []
    for line in res["stdout"].splitlines():
        line = line.strip()
        m = re.search(r"Bus\s+(\d+)\s+Device\s+(\d+):\s+ID\s+([0-9a-fA-F]{4}:[0-9a-fA-F]{4})\s+(.*)", line)
        if m:
            devices.append({
                "bus": m.group(1),
                "device": m.group(2),
                "id": m.group(3),
                "desc": m.group(4).strip(),
                "raw": line
            })

    return {"ok": True, "raw": res["stdout"], "devices": devices}
    
# ==========================
# ENV DETECTION
#===========================
def detect_runtime():
    # detect docker
    if os.path.exists("/.dockerenv"):
        return "docker"

    try:
        with open("/proc/1/cgroup", "r") as f:
            data = f.read()
            if "docker" in data or "containerd" in data:
                return "container"
    except:
        pass

    # detect systemctl
    res = run_cmd("which systemctl", timeout=2)
    if res["returncode"] == 0:
        return "host"

    return "unknown"
    
# ==========================
# IPP-USB SERVICE INFO
# ==========================
def get_ippusb_service_info():
    runtime = detect_runtime()

    try:
        targets = scan_ippusb_targets()
        ports = [t["port"] for t in targets]
    except:
        targets = []
        ports = []

    usb = get_lsusb_list()

    epson_detected = False
    if usb.get("ok"):
        for d in usb.get("devices", []):
            if "04b8" in d.get("id", "").lower():
                epson_detected = True
                break

    # CONTAINER MODE
    if runtime in ["docker", "container"]:
        return {
            "mode": "container",
            "active": len(ports) > 0,
            "enabled": True,
            "status": f"Detected via port scan ({len(ports)} port)",
            "recent_log": "",
            "ports": ports,
            "targets": targets,
            "epson_usb": epson_detected,
            "note": "Running inside container (no systemctl)"
        }

    # HOST MODE
    r1 = run_cmd("systemctl is-active ipp-usb", timeout=5)
    r2 = run_cmd("systemctl is-enabled ipp-usb", timeout=5)

    st = run_cmd("systemctl status ipp-usb --no-pager -n 8", timeout=6)
    jl = run_cmd("journalctl -u ipp-usb --no-pager -n 10", timeout=6)

    return {
        "mode": "host",
        "active": (r1["stdout"].strip() == "active"),
        "enabled": (r2["stdout"].strip() == "enabled"),
        "status": st["stdout"] or st["stderr"],
        "recent_log": jl["stdout"] or jl["stderr"],
        "ports": ports,
        "epson_usb": epson_detected,
        "note": "Running on host systemd"
    }
    
# ==========================
# ENGINE ESC/P2 FUNCTION
# ==========================
from epson_escp2.epson_encode import EpsonEscp2
from pyprintlpr import LprClient

def escp2_send(pattern, host="127.0.0.1"):
    try:
        with LprClient(host) as lpr:
            lpr.send(pattern)
        return {"ok": True}
    except Exception as e:
        return {"ok": False, "error": str(e)}

def escp2_nozzle_check(host="127.0.0.1"):
    try:
        escp2 = EpsonEscp2()
        pattern = escp2.check_nozzles()
        return escp2_send(pattern, host)
    except Exception as e:
        return {"ok": False, "error": str(e)}

def escp2_clean(host="127.0.0.1", power=False):
    try:
        escp2 = EpsonEscp2()
        pattern = escp2.clean_nozzles(0, power_clean=power)
        return escp2_send(pattern, host)
    except Exception as e:
        return {"ok": False, "error": str(e)}
        
# ==========================
# ENGINE REINKPY
# ==========================
def prefers_reinkpy_usb(target):
    target_type = str(target.get("type") or "").strip().lower()
    host = str(target.get("host") or "").strip().lower()
    original_host = str(target.get("original_host") or "").strip().lower()
    port = parse_int(target.get("port", 0), default=0, minimum=0)

    if target_type.startswith("usb") or target_type.startswith("ipp-usb"):
        return True
    if original_host in {"127.0.0.1", "localhost"} and IPPUSB_PORT_MIN <= port < IPPUSB_PORT_MAX:
        return True
    if host in {"127.0.0.1", "localhost"} and IPPUSB_PORT_MIN <= port < IPPUSB_PORT_MAX:
        return True
    return False

def payload_to_text(payload):
    if payload is None:
        return ""
    if isinstance(payload, (bytes, bytearray)):
        for encoding in ("utf-8", "latin-1"):
            try:
                return bytes(payload).decode(encoding, errors="ignore").strip()
            except Exception:
                continue
        return repr(payload)
    if isinstance(payload, str):
        return payload
    try:
        return json.dumps(payload, indent=2, default=str)
    except Exception:
        return repr(payload)

def merge_metric_payload(parsed, payload, prefix=""):
    if payload is None:
        return

    if isinstance(payload, dict):
        lowered = {str(k).lower(): v for k, v in payload.items()}
        max_key = None
        for candidate in ("max", "maximum", "capacity", "maxcapacity"):
            if candidate in lowered:
                max_key = candidate
                break
        if "level" in lowered and max_key:
            try:
                level = float(lowered["level"])
                maximum = float(lowered[max_key])
                if maximum > 0:
                    pct = int(max(0, min(100, round((level / maximum) * 100))))
                    assign_metric_value(parsed, prefix, pct)
            except Exception:
                pass
        for key, value in payload.items():
            sub = f"{prefix}.{key}" if prefix else str(key)
            merge_metric_payload(parsed, value, sub)
        return

    if isinstance(payload, (list, tuple, set)):
        for idx, value in enumerate(payload):
            sub = f"{prefix}.{idx}" if prefix else str(idx)
            merge_metric_payload(parsed, value, sub)
        return

    assign_metric_value(parsed, prefix, payload)

def assign_metric_value(parsed, key_path, value):
    key = str(key_path or "").strip().lower()
    tokens = [t for t in re.split(r"[^a-z0-9]+", key) if t]

    pct = None
    if isinstance(value, (int, float)) and not isinstance(value, bool):
        iv = int(round(float(value)))
        if 0 <= iv <= 100:
            pct = iv
    elif isinstance(value, str):
        m = re.search(r"(-?\d+)\s*%", value)
        if m:
            pct = int(m.group(1))
        elif re.fullmatch(r"-?\d+", value.strip()):
            iv = int(value.strip())
            if 0 <= iv <= 100:
                pct = iv

    if pct is None:
        if isinstance(value, str):
            text_metrics = parse_ircama_output(value)
            if text_metrics.get("ink"):
                parsed["ink"].update(text_metrics.get("ink", {}))
            if text_metrics.get("waste") is not None:
                parsed["waste"] = text_metrics.get("waste")
        return

    color = None
    if any(t in {"black", "bk", "k"} for t in tokens):
        color = "black"
    elif any(t in {"cyan", "c"} for t in tokens):
        color = "cyan"
    elif any(t in {"magenta", "m"} for t in tokens):
        color = "magenta"
    elif any(t in {"yellow", "y"} for t in tokens):
        color = "yellow"

    if color:
        parsed["ink"][color] = pct
        return

    if "waste" in tokens or ("maintenance" in tokens and "counter" in tokens) or ("pad" in tokens and "counter" in tokens):
        parsed["waste"] = pct

def open_reinkpy_usb_context():
    import reinkpy

    dev_cls = getattr(reinkpy, "Device", None)
    if dev_cls is None or not hasattr(dev_cls, "from_usb"):
        raise RuntimeError("reinkpy USB backend tidak tersedia")

    errors = []
    usb_dev = None
    attempts = [
        ("manufacturer=EPSON", {"manufacturer": "EPSON"}),
        ("default", {})
    ]
    for label, kwargs in attempts:
        try:
            usb_dev = dev_cls.from_usb(**kwargs) if kwargs else dev_cls.from_usb()
            break
        except Exception as e:
            errors.append(f"{label}: {e}")

    if usb_dev is None:
        detail = "; ".join(errors[-3:]) if errors else "unknown"
        raise RuntimeError(f"Gagal membuka printer USB Epson via reinkpy: {detail}")

    objects = []
    epson_dev = getattr(usb_dev, "epson", None)
    if epson_dev is not None:
        objects.append(("epson", epson_dev))
    get_driver = getattr(reinkpy, "get_driver", None)
    if callable(get_driver):
        try:
            driver = get_driver(usb_dev)
            if driver is not None:
                objects.append(("driver", driver))
        except Exception as e:
            errors.append(f"get_driver: {e}")
    objects.append(("device", usb_dev))

    return reinkpy, usb_dev, objects, errors

def call_reinkpy_candidates(objects, candidates, label):
    errors = []
    tried = []

    for obj_label, obj in objects:
        if obj is None:
            continue
        for name, variants in candidates:
            method = getattr(obj, name, None)
            if not callable(method):
                continue
            variants = variants or [([], {})]
            for args, kwargs in variants:
                tried.append(f"{obj_label}.{name}")
                try:
                    return {
                        "ok": True,
                        "method": f"{obj_label}.{name}",
                        "result": method(*args, **kwargs)
                    }
                except Exception as e:
                    errors.append(f"{obj_label}.{name}: {e}")

    detail = "; ".join(errors[-4:]) if errors else "method tidak ditemukan"
    return {
        "ok": False,
        "error": f"{label} gagal: {detail}",
        "tried": tried
    }

def reink_status_usb(target):
    try:
        _, _, objects, bootstrap_errors = open_reinkpy_usb_context()
        parsed = {
            "ok": True,
            "engine": "reinkpy-usb",
            "raw": "",
            "ink": {},
            "waste": None,
            "errors": [],
            "info": {}
        }
        if bootstrap_errors:
            parsed["errors"].extend(bootstrap_errors[-3:])

        raw_chunks = []
        methods = []

        for label, candidates in (
            ("status", [
                ("do_status", [([], {})]),
                ("status", [([], {})]),
                ("get_status", [([], {})]),
                ("read_status", [([], {})]),
                ("printer_status", [([], {})]),
                ("query_status", [([], {})]),
                ("info", [([], {})]),
                ("get_info", [([], {})]),
            ]),
            ("ink", [
                ("get_ink_levels", [([], {})]),
                ("ink_levels", [([], {})]),
                ("read_ink_levels", [([], {})]),
                ("get_ink_status", [([], {})]),
                ("ink_status", [([], {})]),
            ]),
            ("waste", [
                ("get_waste", [([], {})]),
                ("read_waste", [([], {})]),
                ("waste", [([], {})]),
                ("get_waste_counter", [([], {})]),
                ("maintenance_counter", [([], {})]),
            ]),
        ):
            result = call_reinkpy_candidates(objects, candidates, label)
            if result.get("ok"):
                methods.append(result.get("method"))
                text = payload_to_text(result.get("result"))
                if text:
                    raw_chunks.append(f"[{result.get('method')}]\\n{text}")
                    merge_metric_payload(parsed, result.get("result"), label)
                    merge_metric_payload(parsed, text, label)
            elif label == "status":
                parsed["errors"].append(result.get("error"))

        parsed["raw"] = "\\n\\n".join([chunk for chunk in raw_chunks if chunk]).strip() or "Reinkpy USB native connected"
        if methods:
            parsed["info"]["status_line"] = f"Reinkpy USB native OK via {methods[0]}"
        else:
            parsed["info"]["status_line"] = "Reinkpy USB native connected"
        parsed["has_metrics"] = bool(parsed["ink"]) or parsed["waste"] is not None
        if not parsed["ink"]:
            parsed["info"]["ink_note"] = "Backend USB native tersambung, tetapi level tinta tidak diexpose oleh driver aktif"
        return parsed
    except Exception as e:
        return {"ok": False, "error": f"USB native status gagal: {e}", "engine": "reinkpy-usb"}

def inspect_reinkpy_usb_capabilities():
    try:
        _, _, objects, bootstrap_errors = open_reinkpy_usb_context()
        payload = {
            "ok": True,
            "bootstrap_errors": bootstrap_errors[-5:] if bootstrap_errors else [],
            "objects": {}
        }
        for label, obj in objects:
            names = []
            for attr in dir(obj):
                if attr.startswith("_"):
                    continue
                try:
                    value = getattr(obj, attr)
                except Exception:
                    continue
                if callable(value):
                    names.append(attr)
            payload["objects"][label] = sorted(names)
        return payload
    except Exception as e:
        return {"ok": False, "error": str(e), "objects": {}}

def reink_nozzle_usb():
    try:
        _, _, objects, _ = open_reinkpy_usb_context()
        result = call_reinkpy_candidates(objects, [
            ("check_nozzles", [([], {})]),
            ("nozzle_check", [([], {})]),
            ("check_nozzle", [([], {})]),
            ("read_nozzle_check", [([], {})]),
        ], "USB nozzle check")
        if not result.get("ok"):
            return {
                "ok": False,
                "error": "Backend USB native aktif, tetapi method nozzle check tidak tersedia pada reinkpy/reinkpy-fix ini",
                "engine": "reinkpy-usb",
                "unsupported_usb_method": True
            }
        return {
            "ok": True,
            "engine": "reinkpy-usb",
            "method": result.get("method"),
            "data": result.get("result")
        }
    except Exception as e:
        return {"ok": False, "error": f"USB nozzle gagal: {e}", "engine": "reinkpy-usb"}

def reink_clean_usb(power=False):
    try:
        _, _, objects, _ = open_reinkpy_usb_context()
        candidates = [
            ("clean_nozzles", [
                ([0], {"power_clean": power}),
                ([], {"power_clean": power}),
                ([power], {}),
                ([], {})
            ]),
            ("clean", [
                ([], {"deep": power}),
                ([power], {}),
                ([], {})
            ]),
        ]
        if power:
            candidates.insert(0, ("power_clean", [([], {})]))

        result = call_reinkpy_candidates(objects, candidates, "USB clean")
        if not result.get("ok"):
            action_name = "deep clean" if power else "clean"
            return {
                "ok": False,
                "error": f"Backend USB native aktif, tetapi method {action_name} tidak tersedia pada reinkpy/reinkpy-fix ini",
                "engine": "reinkpy-usb",
                "unsupported_usb_method": True
            }
        return {
            "ok": True,
            "engine": "reinkpy-usb",
            "method": result.get("method"),
            "data": result.get("result")
        }
    except Exception as e:
        return {"ok": False, "error": f"USB clean gagal: {e}", "engine": "reinkpy-usb"}

def reink_nozzle(target):
    try:
        if prefers_reinkpy_usb(target):
            usb_res = reink_nozzle_usb()
            if usb_res.get("ok"):
                return usb_res

        import reinkpy

        host = str(target.get("host") or "").strip()
        if not host or host in {"127.0.0.1", "localhost"}:
            return usb_res if 'usb_res' in locals() else {"ok": False, "error": "No host", "engine": "reinkpy"}

        res = reinkpy.nozzle_check(ip=host)

        return {"ok": True, "engine": "reinkpy-network", "data": res}

    except Exception as e:
        return {"ok": False, "error": str(e), "engine": "reinkpy"}


def reink_clean(target, power=False):
    try:
        if prefers_reinkpy_usb(target):
            usb_res = reink_clean_usb(power=power)
            if usb_res.get("ok"):
                return usb_res

        import reinkpy

        host = str(target.get("host") or "").strip()
        if not host or host in {"127.0.0.1", "localhost"}:
            return usb_res if 'usb_res' in locals() else {"ok": False, "error": "No host", "engine": "reinkpy"}

        res = reinkpy.clean(ip=host, deep=power)

        return {"ok": True, "engine": "reinkpy-network", "data": res}

    except Exception as e:
        return {"ok": False, "error": str(e), "engine": "reinkpy"}   
        
def reink_reset_waste(target):
    try:
        import reinkpy

        host = str(target.get("host") or "").strip()
        if prefers_reinkpy_usb(target) or host in {"", "127.0.0.1", "localhost"}:
            try:
                _, usb_dev, _, _ = open_reinkpy_usb_context()
                epson_dev = getattr(usb_dev, "epson", None)
                if epson_dev is None or not hasattr(epson_dev, "reset_waste"):
                    raise RuntimeError("Printer USB Epson tidak expose method reset_waste()")
                epson_dev.reset_waste()
                return {"ok": True, "engine": "reinkpy-usb"}
            except Exception as usb_error:
                if host in {"", "127.0.0.1", "localhost"}:
                    return {"ok": False, "error": f"USB reset gagal: {usb_error}"}

        if not host or host in {"127.0.0.1", "localhost"}:
            return {"ok": False, "error": "Printer belum punya target network yang valid untuk reset waste"}

        write_community = os.getenv("SNMP_WRITE", "EPCF_PASS")
        dev = reinkpy.NetworkDevice(
            host,
            read_user="public",
            write_user=write_community
        )

        driver = reinkpy.get_driver(dev)
        driver.reset_waste()

        return {"ok": True, "engine": "reinkpy-network"}

    except Exception as e:
        return {"ok": False, "error": str(e)}        
        
        
# ==========================
# SMART FALLBACK
# ==========================
def smart_nozzle(target):
    res = escp2_nozzle_check(target.get("host","127.0.0.1"))
    if res["ok"]:
        res["mode"] = "escp2"
        return res

    # fallback
    fallback = ircama_run(DEFAULT_MODEL, target.get("host"), "status")
    return {"ok": fallback["ok"], "mode": "ircama", "fallback": True}

def smart_clean(target, power=False):
    res = escp2_clean(target.get("host","127.0.0.1"), power)
    if res["ok"]:
        res["mode"] = "escp2"
        return res

    fallback = ircama_run(DEFAULT_MODEL, target.get("host"), "clean")
    return {"ok": fallback["ok"], "mode": "ircama", "fallback": True}
        
# ==========================
# CUPS DETECTION
# ==========================
def get_cups_printers():
    return dedupe_printers(get_cups_printers_raw())

def infer_model_name(text, default=DEFAULT_MODEL):
    raw = str(text or "").upper()
    normalized = re.sub(r"[_\-/]+", " ", raw)
    m = re.search(r"(?:^|[^A-Z0-9])(L[0-9]{4})(?:$|[^A-Z0-9])", f" {normalized} ")
    if not m:
        m = re.search(r"(L[0-9]{4})", raw)
    if m:
        return m.group(1)
    fallback = str(default or "").strip().upper()
    return fallback or str(DEFAULT_MODEL).strip().upper()

def canonical_queue_name(name):
    raw = str(name or "").strip()
    if not raw:
        return ""
    upper = raw.upper()
    upper = re.sub(r"_SERIES$", "", upper)
    upper = re.sub(r"[^A-Z0-9]+", "_", upper)
    upper = re.sub(r"_+", "_", upper).strip("_")
    return upper

def detected_epson_usb_count():
    usb = get_lsusb_list()
    if not usb.get("ok"):
        return 0
    count = 0
    for dev in usb.get("devices", []):
        dev_id = str(dev.get("id") or "").lower()
        desc = str(dev.get("desc") or "").lower()
        if "04b8" in dev_id or "epson" in desc:
            count += 1
    return count

def printer_identity_key(printer):
    uri = str((printer or {}).get("uri") or "").strip()
    name = str((printer or {}).get("name") or "").strip()
    model = infer_model_name(f"{name} {uri}", DEFAULT_MODEL)
    single_local_epson = detected_epson_usb_count() == 1

    if single_local_epson and (
        uri.startswith("usb://EPSON/")
        or re.search(r"ipp://(?:127\.0\.0\.1|localhost):\d+/ipp/print", uri, re.IGNORECASE)
    ):
        return "local-epson:single"

    port_match = re.search(r"ipp://(?:127\.0\.0\.1|localhost):(\d+)/ipp/print", uri, re.IGNORECASE)
    if port_match:
        return f"ippusb:{port_match.group(1)}:{model}"

    serial_match = re.search(r"[?&]serial=([^&]+)", uri, re.IGNORECASE)
    if serial_match:
        return f"usbserial:{serial_match.group(1).lower()}:{model}"

    if uri.startswith("usb://EPSON/"):
        return f"usbmodel:{model}"

    return f"name:{canonical_queue_name(name)}:{model}"

def queue_priority(printer):
    uri = str((printer or {}).get("uri") or "").strip().lower()
    name = str((printer or {}).get("name") or "").strip()
    score = 0
    if uri.startswith("ipp://127.0.0.1:") or uri.startswith("ipp://localhost:"):
        score += 40
    if "/ipp/print" in uri:
        score += 20
    if uri.startswith("usb://"):
        score += 10
    if name and not name.lower().endswith("_series"):
        score += 8
    score -= len(name) / 1000.0
    return score

def dedupe_printers(printers):
    groups = {}
    order = []
    for printer in printers or []:
        item = dict(printer)
        key = printer_identity_key(item)
        item["_identity_key"] = key
        item["_priority"] = queue_priority(item)
        if key not in groups:
            groups[key] = item
            order.append(key)
            continue

        current = groups[key]
        if item["_priority"] > current.get("_priority", -999):
            previous = dict(current)
            item["debug_duplicates"] = [previous.get("name")] + list(previous.get("debug_duplicates", []))
            groups[key] = item
        else:
            current.setdefault("debug_duplicates", [])
            current["debug_duplicates"].append(item.get("name"))

    deduped = []
    for key in order:
        item = groups[key]
        item.pop("_priority", None)
        item["_identity_key"] = key
        deduped.append(item)
    return deduped

def get_cups_printers_raw():
    res = run_cmd_list(["lpstat", "-h", cups_server_endpoint(), "-v"], timeout=10)
    if res["returncode"] != 0:
        res = run_cmd("lpstat -v", timeout=10)
    printers = []
    if res["returncode"] != 0:
        return printers

    for line in res["stdout"].splitlines():
        m = re.match(r"device for (.*?): (.*)", line.strip())
        if m:
            printers.append({"name": m.group(1).strip(), "uri": m.group(2).strip()})
    return printers

def resolve_model_name(requested=None, printer_record=None):
    requested_model = str(requested or "").strip().upper()
    if requested_model:
        return requested_model

    if printer_record:
        for candidate in (
            printer_record.get("model"),
            printer_record.get("desc"),
            printer_record.get("name"),
        ):
            model = infer_model_name(candidate, "")
            if model:
                return model

    return infer_model_name(DEFAULT_MODEL, DEFAULT_MODEL)

def get_usb_fallback_printers():
    usb = get_lsusb_list()
    targets = scan_ippusb_targets()
    printers = []
    if not usb.get("ok"):
        return printers

    idx = 0
    for dev in usb.get("devices", []):
        dev_id = (dev.get("id") or "").lower()
        desc = str(dev.get("desc") or "")
        if "04b8" not in dev_id and "epson" not in desc.lower():
            continue

        idx += 1
        model = infer_model_name(desc, DEFAULT_MODEL)
        name = f"EPSON_{model}_USB"
        if idx > 1:
            name = f"{name}_{idx}"

        target = targets[idx - 1] if idx - 1 < len(targets) else (targets[0] if targets else None)
        port = target.get("port") if target else None
        printers.append({
            "name": name,
            "uri": target.get("uri") if target else f"usb://fallback/{name}",
            "source": "usb-fallback",
            "model": model,
            "desc": desc,
            "port": port,
            "note": "USB Epson terdeteksi via lsusb" + (" | ipp-usb port ready" if target else " | menunggu ipp-usb")
        })

    if not printers and targets:
        model = infer_model_name(DEFAULT_MODEL, DEFAULT_MODEL)
        printers.append({
            "name": f"EPSON_{model}_IPPUSB",
            "uri": targets[0].get("uri"),
            "source": "ipp-usb-fallback",
            "model": model,
            "desc": f"ipp-usb fallback port {targets[0].get('port')}",
            "port": targets[0].get("port"),
            "note": "IPP-USB port terdeteksi tanpa queue CUPS"
        })

    return printers

def get_available_printers():
    cups = []
    for p in get_cups_printers():
        item = dict(p)
        item.setdefault("source", "cups")
        item.setdefault("model", infer_model_name(f"{p.get('name', '')} {p.get('uri', '')}", DEFAULT_MODEL))
        cups.append(item)

    if cups:
        return cups

    return get_usb_fallback_printers()

def get_printer_record(printer_name):
    for printer in get_available_printers():
        if printer.get("name") == printer_name:
            return printer
    return None

def parse_ipp_uri(uri):
    m = re.match(r"ipp://([^/:]+)(?::(\d+))?/(.*)", uri)
    if not m:
        return None
    host = m.group(1)
    port = m.group(2) or "631"
    path = "/" + m.group(3)
    return {"host": host, "port": int(port), "path": path}
                    
# ==========================
# IPPFIND PARSER
# ==========================
def get_ippfind_devices():
    res = run_cmd("ippfind", timeout=10)

    devices = []
    current = {}

    for line in res["stdout"].splitlines():
        line = line.strip()

        if line.startswith("ipp://"):
            if current:
                devices.append(current)
                current = {}

            current["uri"] = line

            # extract port
            m = re.search(r":(\d+)/", line)
            if m:
                current["port"] = int(m.group(1))

        elif "printer-info=" in line:
            current["info"] = line.split("=",1)[1]

        elif "printer-make-and-model=" in line:
            current["model"] = line.split("=",1)[1]

    if current:
        devices.append(current)

    return devices
    
# ==========================
# MAPPING ENGINE
# ==========================
def map_printers_to_ports():
    cups = get_cups_printers()
    ipp = get_ippfind_devices()

    mapped = []

    for p in cups:
        name = p["name"]
        uri = p["uri"]

        match = None

        # try match by model string
        for d in ipp:
            model = (d.get("model") or "").lower()
            info = (d.get("info") or "").lower()

            if name.lower() in model or name.lower() in info:
                match = d
                break

        # fallback: assign sequential
        if not match and len(ipp) > 0:
            match = ipp[0]
            ipp = ipp[1:]

        mapped.append({
            "name": name,
            "uri": uri,
            "mapped_port": match.get("port") if match else None,
            "mapped_uri": match.get("uri") if match else None,
            "model": match.get("model") if match else None
        })

    return mapped
   
# ==========================
# IRCAMA PARSER
# ==========================
def parse_ircama_output(raw_text):
    data = {
        "ok": True,
        "raw": raw_text,
        "ink": {},
        "waste": None,
        "errors": [],
        "info": {}
    }

    for line in raw_text.splitlines():
        line_strip = line.strip()

        mw = re.search(r"(waste.*?)(\d+)\s*%", line_strip, re.IGNORECASE)
        if mw:
            try:
                data["waste"] = int(mw.group(2))
            except:
                pass

        mi = re.search(r"(black|cyan|magenta|yellow).*?(\d+)\s*%", line_strip, re.IGNORECASE)
        if mi:
            color = mi.group(1).lower()
            try:
                data["ink"][color] = int(mi.group(2))
            except:
                pass

        if "error" in line_strip.lower():
            data["errors"].append(line_strip)

        if "model" in line_strip.lower():
            data["info"]["model_line"] = line_strip

        if "status" in line_strip.lower():
            data["info"]["status_line"] = line_strip

    return data

# ==========================
# IRCAMA EXECUTION
# ==========================
def ircama_run(model, host, mode="status"):
    if not host:
        return {"ok": False, "error": "Printer host not resolved", "raw": ""}

    if mode == "status":
        cmd = f"python3 /app/epson_print_conf/epson_print_conf.py -m {model} -a {host} -i"
        res = run_cmd(cmd, timeout=60)
    elif mode == "clean":
        cmd = f"python3 /app/epson_print_conf/epson_print_conf.py -m {model} -a {host} -c"
        res = run_cmd(cmd, timeout=140)
    else:
        return {"ok": False, "error": "Unknown mode", "raw": ""}

    if res["returncode"] != 0:
        stderr = str(res.get("stderr") or "")
        stdout = str(res.get("stdout") or "")
        combined = "\\n".join([x for x in [stderr, stdout] if x]).strip()
        lowered = combined.lower()

        if "no module named 'pysnmp.hlapi.v1arch'" in lowered:
            return {
                "ok": False,
                "error": "Fallback Ircama gagal karena image WebUI masih memakai pysnmp lama. Rebuild image agar memasang pysnmp>=7.1.20 dan pysnmp_sync_adapter.",
                "raw": combined,
                "missing_dependency": "pysnmp_v1arch"
            }
        if "no module named 'pysnmp_sync_adapter'" in lowered:
            return {
                "ok": False,
                "error": "Fallback Ircama gagal karena package pysnmp_sync_adapter belum terpasang di image WebUI.",
                "raw": combined,
                "missing_dependency": "pysnmp_sync_adapter"
            }

        return {"ok": False, "error": stderr or stdout or "Ircama command failed", "raw": stdout}

    return {"ok": True, "raw": res["stdout"]}

# ==========================
# SNMP (SYNC HYBRID)
# ==========================
def snmp_walk(base_oid, ip):
    results = []

    for (errorIndication,
         errorStatus,
         errorIndex,
         varBinds) in nextCmd(
            SnmpEngine(),
            CommunityData(SNMP_COMMUNITY),
            UdpTransportTarget((ip, 161), timeout=SNMP_TIMEOUT, retries=SNMP_RETRIES),
            ContextData(),
            ObjectType(ObjectIdentity(base_oid)),
            lexicographicMode=False):

        if errorIndication:
            return None, str(errorIndication)

        if errorStatus:
            return None, str(errorStatus.prettyPrint())

        for varBind in varBinds:
            oid = str(varBind[0])
            val = varBind[1]

            # 🔥 normalize value
            try:
                val = int(val)
            except:
                val = str(val)

            results.append((oid, val))

    return results, None

def snmp_get_supplies(ip):
    """
    Standard Printer-MIB supplies:
    prtMarkerSuppliesDescription:
      1.3.6.1.2.1.43.11.1.1.6.1.X
    prtMarkerSuppliesLevel:
      1.3.6.1.2.1.43.11.1.1.9.1.X
    prtMarkerSuppliesMaxCapacity:
      1.3.6.1.2.1.43.11.1.1.8.1.X
    """

    OID_DESC = "1.3.6.1.2.1.43.11.1.1.6.1"
    OID_LEVEL = "1.3.6.1.2.1.43.11.1.1.9.1"
    OID_MAX = "1.3.6.1.2.1.43.11.1.1.8.1"

    desc_list, err = snmp_walk(OID_DESC, ip)
    if err:
        return {"ok": False, "error": err}

    lvl_list, err2 = snmp_walk(OID_LEVEL, ip)
    if err2:
        return {"ok": False, "error": err2}

    max_list, err3 = snmp_walk(OID_MAX, ip)
    if err3:
        return {"ok": False, "error": err3}

    desc_map = {}
    lvl_map = {}
    max_map = {}

    # parse index from OID
    for oid, val in desc_list:
        idx = oid.split(".")[-1]
        desc_map[idx] = str(val)

    for oid, val in lvl_list:
        idx = oid.split(".")[-1]
        try:
            lvl_map[idx] = int(val)
        except:
            lvl_map[idx] = None

    for oid, val in max_list:
        idx = oid.split(".")[-1]
        try:
            max_map[idx] = int(val)
        except:
            max_map[idx] = None

# build supplies (robust)
    supplies = []
    all_idx = set(desc_map) | set(lvl_map) | set(max_map)

    for idx in all_idx:
        supplies.append({
            "idx": idx,
            "desc": desc_map.get(idx),
            "level": lvl_map.get(idx),
            "max": max_map.get(idx)
        })

    # detect ink
    ink = {}

    for s in supplies:
        d = (s.get("desc") or "").lower()
        lvl = s.get("level")
        mx = s.get("max")

        if lvl is None:
            continue

        if isinstance(lvl, int) and lvl < 0:
            continue

        pct = None

        if mx and mx > 0:
            try:
                pct = int((lvl / mx) * 100)
            except:
                pass
        else:
            if isinstance(lvl, int) and 0 <= lvl <= 100:
                pct = lvl

        if pct is None:
            continue

        # 🔥 expanded detection
        if any(k in d for k in ["black", "bk", "ink k", "k"]):
            ink["black"] = pct
        elif any(k in d for k in ["cyan", "cyn", "c"]):
            ink["cyan"] = pct
        elif any(k in d for k in ["magenta", "mgn", "m"]):
            ink["magenta"] = pct
        elif any(k in d for k in ["yellow", "ylw", "y"]):
            ink["yellow"] = pct

    return {
        "ok": True,
        "supplies": supplies,
        "ink": ink
    }

def snmp_status(ip):
    data = snmp_get_supplies(ip)

    if not data.get("ok"):
        return {"ok": False, "error": data.get("error", "SNMP failed")}

    ink = data.get("ink", {})

    if len(ink) == 0:
        return {
            "ok": True,
            "raw": "SNMP OK but ink mapping failed",
            "ink": {},
            "waste": None,
            "errors": ["Ink detection failed"],
            "info": {
                "status_line": "SNMP OK (no color mapping)"
            },
            "snmp_supplies": data.get("supplies", [])
        }

    return {
        "ok": True,
        "raw": "SNMP Mode (native)",
        "ink": ink,
        "waste": None,
        "errors": [],
        "info": {
            "status_line": "SNMP Printer-MIB OK"
        },
        "snmp_supplies": data.get("supplies", [])
    }
# ==========================
# ENGINE ROUTER
# ==========================
def ircama_fallback_host(target):
    for key in ("original_host", "host"):
        candidate = str((target or {}).get(key) or "").strip()
        if candidate and candidate.lower() not in {"127.0.0.1", "localhost"} and is_ip(candidate):
            return candidate
    return ""

def run_nozzle(engine, target):
    engine = (engine or "auto").lower()
    fallback_host = ircama_fallback_host(target)

    if engine == "auto":
        if prefers_reinkpy_usb(target):
            res = reink_nozzle(target)
            if res.get("ok"):
                return res
            if fallback_host:
                fallback = ircama_run(DEFAULT_MODEL, fallback_host, "status")
                fallback["engine"] = "ircama-fallback"
                fallback["fallback_from"] = res.get("engine", "reinkpy-usb")
                fallback["fallback_reason"] = res.get("error")
                return fallback
            return res
        if target.get("host") and is_ip(target["host"]):
            return reink_nozzle(target)
        return escp2_nozzle_check(target.get("host", "127.0.0.1"))

    elif engine == "reinkpy":
        return reink_nozzle(target)

    elif engine == "escp2":
        return escp2_nozzle_check(target.get("host", "127.0.0.1"))

    elif engine == "ircama":
        return ircama_run(DEFAULT_MODEL, target.get("host"), "status")

    return {"ok": False, "error": "Unknown engine"}


def run_clean(engine, target, power=False):
    engine = (engine or "auto").lower()
    fallback_host = ircama_fallback_host(target)

    if engine == "auto":
        if prefers_reinkpy_usb(target):
            res = reink_clean(target, power)
            if res.get("ok"):
                return res
            if fallback_host:
                fallback = ircama_run(DEFAULT_MODEL, fallback_host, "clean")
                fallback["engine"] = "ircama-fallback"
                fallback["fallback_from"] = res.get("engine", "reinkpy-usb")
                fallback["fallback_reason"] = res.get("error")
                return fallback
            return res
        if target.get("host") and is_ip(target["host"]):
            return reink_clean(target, power)
        return escp2_clean(target.get("host","127.0.0.1"), power)

    if engine == "reinkpy":
        return reink_clean(target, power)

    if engine == "escp2":
        return escp2_clean(target.get("host","127.0.0.1"), power)

    if engine == "ircama":
        mode = "clean"
        return ircama_run(DEFAULT_MODEL, target.get("host"), mode)

    return {"ok": False, "error": "Unknown engine"}
    
# ==========================
# CACHE + ALERT
# ==========================
def get_alert_state():
    raw = read_json_file(ALERT_FILE, {})
    if not isinstance(raw, dict):
        return {"waste": {}, "ink": {}}

    # backward compatibility with old format: {printer: {"sent": bool, "waste": int}}
    if "waste" in raw or "ink" in raw:
        return {"waste": raw.get("waste", {}), "ink": raw.get("ink", {})}

    legacy_waste = {}
    for k, v in raw.items():
        if isinstance(v, dict) and "sent" in v:
            legacy_waste[k] = {
                "level": "red" if v.get("sent") else "green",
                "last": v.get("waste")
            }
    return {"waste": legacy_waste, "ink": {}}

def save_alert_state(state):
    write_json_file(ALERT_FILE, state)

def waste_level(pct):
    if pct is None:
        return None
    if pct >= WASTE_ALERT_THRESHOLD:
        return "red"
    if pct >= WASTE_WARN_THRESHOLD:
        return "yellow"
    return "green"

def ink_level(pct):
    if pct is None:
        return None
    if pct <= INK_CRITICAL_THRESHOLD:
        return "red"
    if pct <= INK_WARN_THRESHOLD:
        return "yellow"
    return "green"

def try_send_consumable_alerts(printer_name, parsed):
    if not parsed or not parsed.get("ok"):
        return

    state = get_alert_state()
    waste_state = state.get("waste", {})
    ink_state = state.get("ink", {})

    waste = parsed.get("waste")
    if waste is not None:
        lvl = waste_level(waste)
        prev = waste_state.get(printer_name, {"level": "green"})
        prev_lvl = prev.get("level", "green")
        changed = (lvl != prev_lvl)

        # Recover only if value safely below recover threshold
        if prev_lvl in ("yellow", "red") and waste <= WASTE_RECOVER_THRESHOLD:
            changed = True
            lvl = "green"

        if changed:
            if lvl in ("yellow", "red"):
                msg = (
                    f"{tl_icon(lvl)} [STB PRINT ALERT]\\n"
                    f"Waste Ink Pad {lvl.upper()}\\n"
                    f"Printer: {printer_name}\\n"
                    f"Waste: {waste}%\\n"
                    f"Aksi: Segera jadwalkan penggantian/pembersihan pad agar tidak meluber.\\n"
                    f"Time: {now()}"
                )
                tg_send(msg)
            elif prev_lvl in ("yellow", "red"):
                tg_send(
                    f"🟢 [STB PRINT ALERT]\\nWaste Ink Normal\\nPrinter: {printer_name}\\nWaste: {waste}%\\nTime: {now()}"
                )

            waste_state[printer_name] = {"level": lvl, "last": waste, "time": now()}

    ink = parsed.get("ink", {}) or {}
    if printer_name not in ink_state:
        ink_state[printer_name] = {}

    for color, value in ink.items():
        try:
            pct = int(value)
        except Exception:
            continue

        lvl = ink_level(pct)
        prev = ink_state[printer_name].get(color, {"level": "green"})
        prev_lvl = prev.get("level", "green")
        changed = (lvl != prev_lvl)

        if prev_lvl in ("yellow", "red") and pct >= INK_RECOVER_THRESHOLD:
            changed = True
            lvl = "green"

        if changed:
            cname = str(color).upper()
            if lvl in ("yellow", "red"):
                msg = (
                    f"{tl_icon(lvl)} [STB PRINT ALERT]\\n"
                    f"Ink {cname} {lvl.upper()}\\n"
                    f"Printer: {printer_name}\\n"
                    f"Level: {pct}%\\n"
                    f"Aksi: Siapkan isi ulang/penggantian tinta agar operasional kantor tidak terganggu.\\n"
                    f"Time: {now()}"
                )
                tg_send(msg)
            elif prev_lvl in ("yellow", "red"):
                tg_send(
                    f"🟢 [STB PRINT ALERT]\\nInk {cname} Normal\\nPrinter: {printer_name}\\nLevel: {pct}%\\nTime: {now()}"
                )

            ink_state[printer_name][color] = {"level": lvl, "last": pct, "time": now()}

    state["waste"] = waste_state
    state["ink"] = ink_state
    save_alert_state(state)

def cache_key(printer, model):
    return f"{printer}::{model}"

def get_cached_status(printer, model, target):
    cache = read_json_file(CACHE_FILE, {})
    key = cache_key(printer, model)

    # === CACHE HIT ===
    if key in cache:
        entry = cache[key]
        age = time.time() - entry.get("ts", 0)

        if age < STATUS_CACHE_SECONDS:
            return entry.get("data")

    parsed = None

    # === USB NATIVE FIRST (reinkpy/reinkpy-fix) ===
    if prefers_reinkpy_usb(target):
        usb_native = reink_status_usb(target)
        if usb_native.get("ok"):
            target["type"] = "reinkpy-usb-native"
            target["host"] = None
            target["port"] = None
            target["note"] = "USB native via reinkpy/reinkpy-fix"
            usb_native["target"] = target
            usb_native["ts"] = now()
            parsed = usb_native

    # === SNMP FIRST (LAN printer) ===
    if parsed is None and target.get("host") and is_ip(target["host"]) and target["host"] != "127.0.0.1":
        sn = snmp_status(target["host"])
        if sn.get("ok") and len(sn.get("ink", {})) > 0:
            sn["target"] = target
            sn["ts"] = now()
            parsed = sn

    # === FALLBACK IRCAMA ===
    if parsed is None:
        primary_host = resolve_local_service_host(target.get("host"))
        if primary_host and primary_host != target.get("host"):
            target["host"] = primary_host

        res = ircama_run(model, target.get("host"), mode="status")

        fallback_targets = list(target.get("fallback_targets") or [])
        if (not fallback_targets) and target.get("fallback_ports"):
            local_host = resolve_local_service_host("127.0.0.1")
            fallback_targets = [
                {"host": local_host, "port": p, "uri": build_ipp_uri(local_host, p)}
                for p in target["fallback_ports"]
            ]

        # fallback ipp-usb targets
        if (not res["ok"]) and fallback_targets:
            tried = set()
            for candidate in fallback_targets:
                host = resolve_local_service_host(candidate.get("host"))
                port = candidate.get("port")
                if not host:
                    continue
                key = f"{host}:{port}"
                if key in tried:
                    continue
                tried.add(key)
                if port and not port_open(host, port):
                    continue
                res2 = ircama_run(model, host, mode="status")
                if res2["ok"]:
                    res = res2
                    target["host"] = host
                    target["port"] = port
                    target["uri"] = candidate.get("uri") or build_ipp_uri(host, port)
                    target["note"] = f"Fallback success using ipp-usb target {host}:{port}"
                    break

        if not res["ok"]:
            parsed = {"ok": False, "error": res.get("error", ""), "raw": res.get("raw", "")}
        else:
            parsed = parse_ircama_output(res["raw"])

        parsed["target"] = target
        parsed["ts"] = now()

    # === SAVE CACHE ===
    cache[key] = {"ts": time.time(), "data": parsed}
    write_json_file(CACHE_FILE, cache)

    try_send_consumable_alerts(printer, parsed)
    return parsed

# ==========================
# UI (CasaOS Style V7)
# ==========================
HTML = """
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Armbian Printer Maintenance Tools</title>
  <style>
    :root {
      --bg: #0a1220;
      --bg-soft: #121d30;
      --panel: rgba(255, 255, 255, 0.04);
      --panel-2: rgba(255, 255, 255, 0.03);
      --text: #e2e8f0;
      --muted: #9caec9;
      --line: rgba(255, 255, 255, 0.12);
      --accent: #38bdf8;
      --ok: #34d399;
      --warn: #facc15;
      --danger: #fb7185;
      --focus: #67e8f9;
      --shadow: 0 10px 24px rgba(0, 0, 0, 0.3);
    }

    body.light {
      --bg: #f5f7fb;
      --bg-soft: #ffffff;
      --panel: #ffffff;
      --panel-2: #f8fafc;
      --text: #0f172a;
      --muted: #475569;
      --line: #dbe3ef;
      --accent: #0ea5e9;
      --ok: #16a34a;
      --warn: #ca8a04;
      --danger: #dc2626;
      --focus: #0284c7;
      --shadow: 0 8px 18px rgba(2, 6, 23, 0.08);
    }

    * { box-sizing: border-box; }

    body {
      margin: 0;
      color: var(--text);
      font-family: "Segoe UI", "Noto Sans", "Helvetica Neue", Arial, sans-serif;
      background:
        radial-gradient(circle at 10% 0%, #11203a 0%, rgba(17, 32, 58, 0) 40%),
        radial-gradient(circle at 90% 0%, #0e2840 0%, rgba(14, 40, 64, 0) 35%),
        var(--bg);
      min-height: 100vh;
    }

    body.light {
      background:
        radial-gradient(circle at 0% 0%, #e8f2ff 0%, rgba(232, 242, 255, 0) 40%),
        radial-gradient(circle at 100% 0%, #ecfdf5 0%, rgba(236, 253, 245, 0) 35%),
        var(--bg);
    }

    header {
      position: sticky;
      top: 0;
      z-index: 5;
      backdrop-filter: blur(6px);
      background: linear-gradient(135deg, rgba(8, 16, 30, 0.88), rgba(7, 18, 35, 0.72));
      border-bottom: 1px solid var(--line);
      padding: 14px 20px;
    }

    body.light header {
      background: rgba(255, 255, 255, 0.9);
    }

    h1 {
      margin: 0;
      font-size: 18px;
      line-height: 1.2;
      font-weight: 800;
      letter-spacing: 0.2px;
    }

    .sub {
      margin-top: 6px;
      font-size: 12px;
      color: var(--muted);
    }

    .toolbar {
      margin-top: 12px;
      display: grid;
      grid-template-columns: 1fr;
      gap: 10px;
    }

    .toolbar .control {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      gap: 8px;
    }

    .container {
      max-width: 1320px;
      margin: 0 auto;
      padding: 18px;
    }

    .grid {
      display: grid;
      grid-template-columns: 1fr;
      gap: 14px;
    }

    @media(min-width: 920px) {
      .grid.system {
        grid-template-columns: repeat(3, minmax(0, 1fr));
      }
      .grid.printers {
        grid-template-columns: repeat(2, minmax(0, 1fr));
      }
    }

    @media(min-width: 1220px) {
      .grid.printers {
        grid-template-columns: repeat(3, minmax(0, 1fr));
      }
    }

    .card {
      background: var(--panel);
      border: 1px solid var(--line);
      border-radius: 14px;
      padding: 14px;
      box-shadow: var(--shadow);
    }

    .cardTitle {
      font-size: 14px;
      font-weight: 700;
      margin: 0 0 4px;
    }

    .muted, .mini {
      color: var(--muted);
      font-size: 12px;
    }

    .mini { font-size: 11px; }

    .row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: 10px;
      flex-wrap: wrap;
    }

    select, button, input {
      font-size: 13px;
      border-radius: 10px;
      border: 1px solid var(--line);
      color: var(--text);
      background: var(--panel-2);
      padding: 8px 10px;
      outline: none;
      transition: transform .14s ease, border-color .14s ease, box-shadow .14s ease, opacity .14s ease;
    }

    button {
      cursor: pointer;
      font-weight: 600;
    }

    button:hover {
      transform: translateY(-1px);
    }

    button:focus-visible, select:focus-visible, input:focus-visible {
      border-color: var(--focus);
      box-shadow: 0 0 0 2px color-mix(in srgb, var(--focus) 35%, transparent);
    }

    button:disabled {
      opacity: .6;
      cursor: not-allowed;
    }

    .btn-primary { border-color: rgba(56, 189, 248, .45); background: rgba(56, 189, 248, .18); }
    .btn-ok { border-color: rgba(52, 211, 153, .5); background: rgba(52, 211, 153, .18); }
    .btn-warn { border-color: rgba(250, 204, 21, .42); background: rgba(250, 204, 21, .14); }
    .btn-danger { border-color: rgba(251, 113, 133, .52); background: rgba(251, 113, 133, .18); }

    body.light .btn-primary { background: rgba(14, 165, 233, .12); }
    body.light .btn-ok { background: rgba(22, 163, 74, .1); }
    body.light .btn-warn { background: rgba(202, 138, 4, .1); }
    body.light .btn-danger { background: rgba(220, 38, 38, .1); }

    .badge {
      display: inline-flex;
      align-items: center;
      gap: 4px;
      padding: 4px 9px;
      border-radius: 999px;
      font-size: 11px;
      font-weight: 700;
      border: 1px solid var(--line);
      background: var(--panel-2);
      white-space: nowrap;
    }

    .badge.green { border-color: color-mix(in srgb, var(--ok) 35%, var(--line)); color: var(--ok); }
    .badge.yellow { border-color: color-mix(in srgb, var(--warn) 35%, var(--line)); color: var(--warn); }
    .badge.red { border-color: color-mix(in srgb, var(--danger) 45%, var(--line)); color: var(--danger); }
    .badge.blue { border-color: color-mix(in srgb, var(--accent) 40%, var(--line)); color: var(--accent); }

    pre {
      margin: 10px 0 0;
      padding: 10px;
      border: 1px solid var(--line);
      border-radius: 10px;
      background: color-mix(in srgb, var(--panel-2) 60%, #000 8%);
      color: var(--text);
      font-size: 11px;
      line-height: 1.45;
      max-height: 210px;
      overflow: auto;
      white-space: pre-wrap;
      word-break: break-word;
    }

    body.light pre {
      background: #f8fafc;
    }

    .printerCard {
      border: 1px solid var(--line);
      border-radius: 14px;
      padding: 12px;
      background: color-mix(in srgb, var(--panel) 70%, transparent);
      transition: border-color .18s ease, box-shadow .18s ease, transform .18s ease;
    }

    .printerCard:hover {
      border-color: color-mix(in srgb, var(--accent) 35%, var(--line));
      box-shadow: 0 12px 28px rgba(0, 0, 0, 0.22);
      transform: translateY(-1px);
    }

    body.light .printerCard:hover {
      box-shadow: 0 10px 22px rgba(2, 6, 23, 0.1);
    }

    .sectionLabel {
      display: block;
      font-size: 11px;
      font-weight: 800;
      color: var(--muted);
      margin: 10px 0 6px;
      text-transform: uppercase;
      letter-spacing: .4px;
    }

    .actionGrid {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 8px;
    }

    .actionGrid.full {
      grid-template-columns: 1fr;
    }

    .formGrid {
      display: grid;
      grid-template-columns: 1fr;
      gap: 10px;
      margin-top: 12px;
    }

    @media(min-width: 760px) {
      .formGrid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
      }
    }

    .inputGroup {
      display: flex;
      flex-direction: column;
      gap: 6px;
    }

    .inputGroup label {
      font-size: 11px;
      font-weight: 800;
      color: var(--muted);
      text-transform: uppercase;
      letter-spacing: .35px;
    }

    .hintBox {
      margin-top: 10px;
      padding: 10px;
      border-radius: 10px;
      border: 1px solid var(--line);
      background: var(--panel-2);
      font-size: 12px;
      color: var(--muted);
    }

    @media(min-width: 560px) {
      .actionGrid {
        grid-template-columns: repeat(3, minmax(0, 1fr));
      }
      .actionGrid.full {
        grid-template-columns: repeat(2, minmax(0, 1fr));
      }
    }

    .bar {
      height: 9px;
      border-radius: 999px;
      overflow: hidden;
      background: color-mix(in srgb, var(--panel-2) 90%, #000 10%);
      margin-top: 5px;
      border: 1px solid var(--line);
    }

    .fill {
      height: 100%;
      width: 0%;
      background: rgba(56, 189, 248, .7);
    }
    .fill.green { background: color-mix(in srgb, var(--ok) 80%, #fff 8%); }
    .fill.yellow { background: color-mix(in srgb, var(--warn) 80%, #fff 8%); }
    .fill.red { background: color-mix(in srgb, var(--danger) 80%, #fff 8%); }

    details {
      margin-top: 10px;
      padding: 9px;
      border-radius: 10px;
      border: 1px solid var(--line);
      background: var(--panel-2);
    }

    summary {
      cursor: pointer;
      font-size: 12px;
      font-weight: 700;
      color: var(--muted);
    }

    .actionResult {
      margin-top: 10px;
      padding: 10px;
      border-radius: 10px;
      border: 1px solid var(--line);
      background: var(--panel-2);
      font-size: 12px;
      line-height: 1.45;
    }

    .actionResult.green { border-color: color-mix(in srgb, var(--ok) 45%, var(--line)); }
    .actionResult.yellow { border-color: color-mix(in srgb, var(--warn) 45%, var(--line)); }
    .actionResult.red { border-color: color-mix(in srgb, var(--danger) 45%, var(--line)); }
    .actionResult.blue { border-color: color-mix(in srgb, var(--accent) 45%, var(--line)); }

    .heroPanel {
      padding: 18px;
      background:
        linear-gradient(135deg, color-mix(in srgb, var(--panel) 82%, var(--accent) 10%), transparent),
        linear-gradient(135deg, rgba(56, 189, 248, 0.08), rgba(52, 211, 153, 0.06)),
        var(--panel);
    }

    .maintenanceLegend,
    .statusCluster,
    .usageStrip {
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
      align-items: center;
    }

    .statsGrid {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 10px;
      margin-top: 14px;
    }

    @media(min-width: 760px) {
      .statsGrid {
        grid-template-columns: repeat(3, minmax(0, 1fr));
      }
    }

    .statCard {
      padding: 12px;
      border-radius: 14px;
      border: 1px solid var(--line);
      background: color-mix(in srgb, var(--panel-2) 85%, transparent);
    }

    .statLabel {
      font-size: 11px;
      font-weight: 800;
      text-transform: uppercase;
      letter-spacing: .35px;
      color: var(--muted);
    }

    .statValue {
      margin-top: 6px;
      font-size: 28px;
      font-weight: 800;
      line-height: 1;
    }

    .statNote {
      margin-top: 6px;
      font-size: 12px;
      color: var(--muted);
      line-height: 1.45;
    }

    .summarySplit {
      display: grid;
      grid-template-columns: 1fr;
      gap: 12px;
      margin-top: 14px;
    }

    @media(min-width: 980px) {
      .summarySplit {
        grid-template-columns: 1.1fr .9fr;
      }
    }

    .summaryPanel {
      padding: 12px;
      border-radius: 14px;
      border: 1px solid var(--line);
      background: color-mix(in srgb, var(--panel-2) 88%, transparent);
    }

    .metricList,
    .jobFeed {
      display: grid;
      gap: 10px;
      margin-top: 10px;
    }

    .metricItem,
    .jobItem {
      padding: 12px;
      border-radius: 12px;
      border: 1px solid var(--line);
      background: color-mix(in srgb, var(--panel) 70%, transparent);
    }

    .metricItem .row,
    .jobItem .row {
      align-items: flex-start;
    }

    .metricTitle {
      font-size: 13px;
      font-weight: 700;
    }

    .metricMeta {
      margin-top: 6px;
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
    }

    .emptyState {
      padding: 12px;
      border-radius: 12px;
      border: 1px dashed var(--line);
      color: var(--muted);
      font-size: 12px;
      text-align: center;
      background: color-mix(in srgb, var(--panel-2) 80%, transparent);
    }

    .printerHeader {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      gap: 10px;
      flex-wrap: wrap;
    }

    .printerName {
      font-size: 15px;
      font-weight: 800;
    }

    .printerMeta {
      margin-top: 8px;
      display: grid;
      gap: 4px;
    }

    .maintenanceStats {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 10px;
      margin-top: 12px;
    }

    .miniCard {
      padding: 10px;
      border-radius: 12px;
      border: 1px solid var(--line);
      background: color-mix(in srgb, var(--panel-2) 88%, transparent);
    }

    .miniCard .statValue {
      font-size: 20px;
    }

    .summaryExplain {
      margin-top: 10px;
      padding: 10px 12px;
      border-radius: 12px;
      border: 1px dashed var(--line);
      background: color-mix(in srgb, var(--panel-2) 78%, transparent);
      color: var(--muted);
      font-size: 12px;
      line-height: 1.5;
    }

    .utilityList {
      display: grid;
      gap: 8px;
      margin-top: 10px;
    }

    .utilityItem {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      gap: 10px;
      padding: 10px;
      border-radius: 12px;
      border: 1px solid var(--line);
      background: color-mix(in srgb, var(--panel-2) 88%, transparent);
    }

    .utilityName {
      font-size: 12px;
      font-weight: 700;
    }

    .utilityNote {
      margin-top: 4px;
      font-size: 11px;
      color: var(--muted);
      line-height: 1.45;
    }

    .actionGrid button[disabled] {
      opacity: .45;
      filter: saturate(.4);
      transform: none;
      box-shadow: none;
    }

    .disabledHint {
      margin-top: 8px;
      font-size: 11px;
      color: var(--muted);
      line-height: 1.45;
    }

    #toastHost {
      position: fixed;
      right: 18px;
      bottom: 18px;
      z-index: 200;
      display: flex;
      flex-direction: column;
      gap: 8px;
      max-width: min(420px, calc(100vw - 36px));
      pointer-events: none;
    }

    .toast {
      pointer-events: auto;
      background: var(--panel);
      border: 1px solid var(--line);
      border-radius: 12px;
      padding: 12px 14px;
      box-shadow: var(--shadow);
      font-size: 13px;
      line-height: 1.45;
      animation: toastIn 0.2s ease-out;
    }

    @keyframes toastIn {
      from { opacity: 0; transform: translateY(8px); }
      to { opacity: 1; transform: translateY(0); }
    }
  </style>
</head>
<body>
<div id="toastHost" aria-live="polite"></div>
<header>
  <h1>Armbian Printer Maintenance Tools</h1>
  <div class="sub">Optimized by function: monitoring, maintenance actions, and critical actions</div>
  <div class="toolbar">
    <div class="control">
      <button class="btn-primary" onclick="toggleTheme()">Mode</button>
      <select id="engineSelect">
        <option value="auto">Engine: Auto (Smart)</option>
        <option value="reinkpy">Engine: Reinkpy</option>
        <option value="escp2">Engine: ESC/P2</option>
        <option value="ircama">Engine: Ircama</option>
      </select>
      <select id="modelSelect">
        <option value="L3110">Model L3110</option>
        <option value="L3150">Model L3150</option>
        <option value="L3210">Model L3210</option>
        <option value="L3250">Model L3250</option>
        <option value="L5190">Model L5190</option>
      </select>
      <button class="btn-ok" onclick="refreshAll()">Refresh All</button>
    </div>
  </div>
</header>

<div class="container">
  <div class="card heroPanel">
    <div class="row">
      <div>
        <div class="cardTitle">Maintenance Cockpit</div>
        <div class="muted">Panel atas ini khusus ringkasan operasional print. Sumber datanya adalah histori job dari CUPS `page_log` dan portal web, jadi bukan status printer live.</div>
      </div>
      <div class="maintenanceLegend">
        <span class="badge green">Ready</span>
        <span class="badge yellow">Observe</span>
        <span class="badge red">Needs Action</span>
        <span class="badge blue">Telemetry</span>
      </div>
    </div>
    <div class="summaryExplain">Yang dimaksud summary di sini: jumlah job yang tercatat, total halaman, printer paling aktif, dan job terakhir. Jika belum pernah ada print job, angkanya akan kosong walaupun WebUI berjalan normal.</div>
    <div class="statsGrid" id="overviewGrid">
      <div class="emptyState">Memuat ringkasan job print dari CUPS dan portal...</div>
    </div>
    <div class="summarySplit">
      <div class="summaryPanel">
        <div class="cardTitle">Fleet Activity</div>
        <div class="muted">Printer paling aktif, volume job, dan breakdown portal/manual dari histori print.</div>
        <div id="usageLeaderboard" class="metricList">
          <div class="emptyState">Loading printer usage...</div>
        </div>
      </div>
      <div class="summaryPanel">
        <div class="cardTitle">Latest Jobs</div>
        <div class="muted">Snapshot job terakhir yang tercatat dari CUPS page log dan submit portal. Ini tidak berarti printer sedang online.</div>
        <div id="recentJobsFeed" class="jobFeed">
          <div class="emptyState">Loading recent jobs...</div>
        </div>
      </div>
    </div>
  </div>

  <div class="grid system">
    <div class="card">
      <div class="row">
        <div>
          <div class="cardTitle">Lock State</div>
          <div class="muted" id="lockstate">Loading...</div>
        </div>
        <button class="btn-ok" onclick="unlockAll()">Unlock</button>
      </div>
    </div>

    <div class="card">
      <div class="cardTitle">USB Devices (lsusb)</div>
      <pre id="lsusbRaw">Loading...</pre>
    </div>

    <div class="card">
      <div class="cardTitle">ipp-usb Service</div>
      <div class="muted" id="ippusbState">Loading...</div>
      <pre id="ippusbStatus">Loading...</pre>
    </div>

    <div class="card">
      <div class="cardTitle">ipp-usb Port Scan</div>
      <pre id="ippPorts">Loading...</pre>
    </div>

    <div class="card">
      <div class="cardTitle">reinkpy Patch Status</div>
      <div class="muted" id="reinkpyState">Loading...</div>
      <div class="row" style="margin-top:10px;">
        <button onclick="loadReinkpyInfo()">Refresh Local</button>
        <button class="btn-primary" onclick="checkReinkpyUpdate()">Check Update</button>
        <button class="btn-warn" id="applyUpdateBtn" onclick="applyReinkpyUpdate()" disabled>Apply Update</button>
      </div>
      <div class="row" style="margin-top:8px;">
        <button id="srcAutoBtn" onclick="switchReinkpySource('auto')">Use Auto</button>
        <button id="srcFixBtn" class="btn-ok" onclick="switchReinkpySource('fix')">Use Fix</button>
        <button id="srcOrigBtn" class="btn-warn" onclick="switchReinkpySource('original')">Use Original</button>
        <button id="srcRestoreBtn" onclick="restoreReinkpySource()">Restore Previous</button>
      </div>
      <div style="margin-top:10px;">
        <div id="updateJobState"></div>
        <div class="mini" id="updateJobMessage" style="margin-top:6px;">Menunggu status update...</div>
        <div class="bar"><div class="fill" id="updateJobFill" style="width:0%"></div></div>
        <div class="mini" id="updateJobMeta" style="margin-top:6px;">-</div>
      </div>
      <pre id="updateJobLog">No update activity yet.</pre>
      <pre id="reinkpyBox">Loading...</pre>
    </div>
  </div>

  <div class="card">
    <div class="cardTitle">Multi Printer Dashboard</div>
    <div class="muted">Monitoring dipakai untuk membaca kondisi printer. Maintenance menjalankan perintah servis. Critical hanya untuk aksi berisiko tinggi.</div>
    <div id="printerGrid" class="grid printers" style="margin-top:12px"></div>
  </div>

  <div class="card">
    <div class="cardTitle">Print Activity</div>
    <div class="muted">Rekap job CUPS dan portal web, termasuk total halaman, printer tersibuk, dan job per printer.</div>
    <div id="printStatsBoard" class="metricList" style="margin-top:12px;">
      <div class="emptyState">Loading print activity...</div>
    </div>
    <details>
      <summary>Raw Job Audit</summary>
      <pre id="printJobsBox">Loading...</pre>
    </details>
  </div>

  <div class="card">
    <div class="cardTitle">Activity Log</div>
    <div class="muted">Timeline aksi maintenance dan hasil terakhir agar operator tidak harus membaca log mentah dulu.</div>
    <div id="activityFeed" class="jobFeed" style="margin-top:12px;">
      <div class="emptyState">Loading activity log...</div>
    </div>
    <details>
      <summary>Raw Activity Log</summary>
      <pre id="logBox">Loading...</pre>
    </details>
  </div>

  <div class="card" id="debugCard" style="display:none;">
    <div class="row">
      <div>
        <div class="cardTitle">Debug Snapshot</div>
        <div class="muted">Gunakan ini saat ada glitch. Klik load lalu kirim JSON yang muncul ke saya.</div>
      </div>
      <div class="row">
        <button onclick="loadDebugSnapshot()">Load Snapshot</button>
        <button class="btn-primary" onclick="loadDebugUsb()">USB Methods</button>
      </div>
    </div>
    <pre id="debugBox">Debug mode belum aktif.</pre>
  </div>
</div>

<script>
let STATUS_TIMER = null;
let UPDATE_TIMER = null;
let UPDATE_POLL_MS = 0;
let REINKPY_UPDATE_AVAILABLE = false;
let REINKPY_UPDATE_BUSY = false;
let REINKPY_SWITCH_BUSY = false;
let PRINTER_RENDER_SEQ = 0;
let REFRESH_BUSY = false;
let REFRESH_PENDING = false;
let DASHBOARD_SUMMARY = null;
let DASHBOARD_USAGE_MAP = {};
const PRINTER_ACTION_STATE = {};
const REMOTE_PRINT_HOST_HINT = "{{REMOTE_PRINT_HOST_HINT}}";
const WEB_PRINT_ALLOWED_LABEL = "{{WEB_PRINT_ALLOWED_LABEL}}";
const WEB_PRINT_MAX_MB = Number("{{WEB_PRINT_MAX_MB}}") || 25;
const WEB_PRINT_ENABLED = "{{WEB_PRINT_ENABLED}}" === "yes";
const WEBUI_DEBUG_ENABLED = "{{WEBUI_DEBUG_ENABLED}}" === "yes";

function getEngine() {
  return document.getElementById("engineSelect").value;
}

function getSelectedModel() {
  return document.getElementById("modelSelect").value;
}

function badge(text, cls) {
  return `<span class="badge ${cls}">${text}</span>`;
}

function safeText(v) {
  if (v === null || v === undefined) return "-";
  return String(v).replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

function safeAttr(v) {
  if (v === null || v === undefined) return "";
  return String(v)
    .replace(/&/g, "&amp;")
    .replace(/"/g, "&quot;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
}

function nl2br(v) {
  return safeText(v).split("\\n").join("<br/>");
}

function numText(v) {
  const n = Number(v);
  if (!Number.isFinite(n)) return "0";
  return n.toLocaleString("id-ID");
}

function jobSourceTag(job) {
  const source = String((job && (job.portal_source || job.source)) || "unknown").toLowerCase();
  if (source === "web-portal") return {label: "WEB PORTAL", cls: "blue"};
  if (source === "cups-page-log") return {label: "CUPS", cls: "green"};
  return {label: source.toUpperCase() || "UNKNOWN", cls: "yellow"};
}

function trackedPages(job) {
  const pagesLogged = Number((job && job.pages_logged) || 0) || 0;
  const maxPage = Number((job && job.max_page) || 0) || 0;
  return Math.max(pagesLogged, maxPage);
}

function usageForPrinter(printerName) {
  return DASHBOARD_USAGE_MAP[printerName] || null;
}

function printerHealthMeta(statusData) {
  if (!statusData) return {label: "WAITING", cls: "blue", note: "Status belum dimuat"};
  if (!statusData.ok) return {label: "OFFLINE", cls: "red", note: statusData.error || "Backend error"};

  let level = "green";
  let note = "Maintenance ready";
  const waste = Number(statusData.waste);
  const inks = Object.values(statusData.ink || {}).map(v => Number(v)).filter(v => Number.isFinite(v));

  if (Number.isFinite(waste) && waste >= 90) {
    level = "red";
    note = `Waste ink ${waste}%`;
  } else if (inks.some(v => v <= 10)) {
    level = "red";
    note = "Ada tinta kritis";
  } else if ((Number.isFinite(waste) && waste >= 70) || inks.some(v => v <= 20)) {
    level = "yellow";
    note = Number.isFinite(waste) && waste >= 70 ? `Waste ink ${waste}%` : "Ada tinta menipis";
  } else if (!inks.length && !Number.isFinite(waste)) {
    level = "blue";
    note = "Telemetry terbatas";
  }

  return {
    label: level === "green" ? "READY" : (level === "yellow" ? "OBSERVE" : (level === "red" ? "ACTION" : "LIMITED")),
    cls: level,
    note
  };
}

function backendMeta(statusData) {
  if (!statusData || !statusData.ok) return {label: "BACKEND UNKNOWN", cls: "blue"};
  const targetType = String(((statusData.target || {}).type) || "").toLowerCase();
  if (targetType.includes("reinkpy-usb")) return {label: "USB NATIVE", cls: "green"};
  if (targetType.includes("ipp-usb") || targetType.includes("usb")) return {label: "USB / IPP-USB", cls: "blue"};
  if (statusData.snmp_supplies) return {label: "SNMP", cls: "green"};
  if (String(statusData.engine || "").includes("reinkpy")) return {label: "REINKPY", cls: "blue"};
  return {label: "HYBRID", cls: "blue"};
}

function maintenanceCapabilities(printer, statusData) {
  const printerName = String((printer && printer.name) || "printer");
  const statusOk = !!(statusData && statusData.ok);
  const statusError = String((statusData && statusData.error) || "").trim();
  const target = (statusData && statusData.target) || {};
  const targetType = String(target.type || "").toLowerCase();
  const hasHost = !!String(target.host || "").trim();
  const isUsbLike = targetType.includes("usb");
  const telemetryAvailable = statusOk && (
    Object.keys((statusData && statusData.ink) || {}).length > 0 ||
    (statusData && statusData.waste !== null && statusData.waste !== undefined)
  );
  const waitReason = statusOk
    ? `${printerName} sudah live dan siap dicoba.`
    : (statusError || "Printer belum terdeteksi live. Colokkan printer lalu tekan Refresh Status.");

  return {
    summary: statusOk
      ? "Printer terdeteksi live. Utility maintenance aktif sesuai backend saat ini."
      : `Utility maintenance dikunci dulu. Alasan: ${waitReason}`,
    live: {
      enabled: statusOk,
      reason: statusOk ? `Target ${target.type || "unknown"} siap diakses.` : waitReason
    },
    telemetry: {
      enabled: telemetryAvailable,
      reason: telemetryAvailable
        ? "Ink/waste berhasil dibaca dari backend aktif."
        : (statusOk
            ? ((statusData.info && statusData.info.ink_note) || "Printer live, tetapi backend belum mengekspose telemetri tinta.")
            : waitReason)
    },
    refresh: {
      enabled: true,
      reason: "Selalu tersedia untuk memeriksa apakah printer sudah muncul lagi."
    },
    nozzle: {
      enabled: statusOk,
      reason: statusOk ? "Nozzle check siap dicoba pada printer live." : waitReason
    },
    cleanFast: {
      enabled: statusOk,
      reason: statusOk ? "Head cleaning hanya diaktifkan saat koneksi live siap." : waitReason
    },
    cleanDeep: {
      enabled: statusOk,
      reason: statusOk ? "Power cleaning diaktifkan hanya saat printer live." : waitReason
    },
    lock: {
      enabled: statusOk,
      reason: statusOk ? "Lock session siap mencegah tab lain mengirim aksi ganda." : waitReason
    },
    reset: {
      enabled: statusOk && (isUsbLike || hasHost),
      reason: (statusOk && (isUsbLike || hasHost))
        ? "Reset waste counter siap dicoba. Pastikan pad benar-benar sudah dibersihkan."
        : "Resetter dimatikan sampai printer live terdeteksi via USB/native atau target network valid."
    }
  };
}

function renderCapabilityList(caps) {
  const rows = [
    {label: "Live Printer Link", state: caps.live},
    {label: "Ink / Waste Telemetry", state: caps.telemetry},
    {label: "Nozzle Check", state: caps.nozzle},
    {label: "Head Cleaning", state: caps.cleanFast},
    {label: "Waste Resetter", state: caps.reset}
  ];
  return `
    <span class="sectionLabel">Utility Readiness</span>
    <div class="utilityList">
      ${rows.map(item => `
        <div class="utilityItem">
          <div>
            <div class="utilityName">${safeText(item.label)}</div>
            <div class="utilityNote">${safeText(item.state.reason)}</div>
          </div>
          <div>${badge(item.state.enabled ? "READY" : "WAITING", item.state.enabled ? "green" : "yellow")}</div>
        </div>
      `).join("")}
    </div>
  `;
}

function renderActionButton(label, onClick, cls, state) {
  const disabledAttr = state && !state.enabled ? " disabled" : "";
  const titleAttr = state ? ` title="${safeAttr(state.reason)}"` : "";
  return `<button class="${cls || ""}" onclick="${onClick}"${disabledAttr}${titleAttr}>${safeText(label)}</button>`;
}

function printUriForQueue(queue) {
  if (!REMOTE_PRINT_HOST_HINT || !queue) return "";
  return `ipp://${REMOTE_PRINT_HOST_HINT}/printers/${queue}`;
}

function updatePrintPortalMeta() {
  const meta = document.getElementById("printPortalMeta");
  if (!meta) return;
  if (!WEB_PRINT_ENABLED) {
    meta.innerText = "Portal print dinonaktifkan via WEB_PRINT_ENABLED=no.";
    return;
  }
  let text = `Allowed file: ${WEB_PRINT_ALLOWED_LABEL} | Max size: ${WEB_PRINT_MAX_MB} MB.`;
  if (REMOTE_PRINT_HOST_HINT) {
    text += ` Endpoint universal host: ${REMOTE_PRINT_HOST_HINT}.`;
  } else {
    text += " Set TS_HOSTNAME/TS_HOSTNAME_PREFIX atau REMOTE_PRINT_HOST_HINT untuk menampilkan URI IPP universal.";
  }
  meta.innerText = text;
}

function setPrintQueueOptions(printers) {
  const select = document.getElementById("printQueueSelect");
  if (!select) return;
  const current = select.value;
  const cupsQueues = (printers || []).filter(p => String(p.source || "").toLowerCase() === "cups");
  select.innerHTML = "";

  if (!cupsQueues.length) {
    const opt = document.createElement("option");
    opt.value = "";
    opt.textContent = "No CUPS queue available yet";
    select.appendChild(opt);
    select.disabled = true;
    updatePrintUriHint();
    return;
  }

  cupsQueues.forEach(p => {
    const opt = document.createElement("option");
    opt.value = p.name;
    opt.textContent = p.name;
    if (p.name === current) opt.selected = true;
    select.appendChild(opt);
  });
  select.disabled = false;
  if (!select.value && cupsQueues[0]) {
    select.value = cupsQueues[0].name;
  }
  updatePrintUriHint();
}

function updatePrintUriHint() {
  const select = document.getElementById("printQueueSelect");
  const hint = document.getElementById("printUriHint");
  if (!hint || !select) return;
  const queue = select.value;
  if (!queue) {
    hint.innerText = "Queue CUPS belum tersedia. Pastikan auto-connect CUPS sudah membuat queue printer.";
    return;
  }
  const uri = printUriForQueue(queue);
  if (!uri) {
    hint.innerText = `Queue aktif: ${queue}. Host universal belum diset.`;
    return;
  }
  hint.innerText = `Android/desktop manual add: ${uri}`;
}

function toggleTheme() {
  const b = document.body;
  b.classList.toggle("light");
  localStorage.setItem("theme", b.classList.contains("light") ? "light" : "dark");
}

(function () {
  if (localStorage.getItem("theme") === "light") {
    document.body.classList.add("light");
  }
})();

async function api(path, options) {
  const res = await fetch(path, options || {});
  const text = await res.text();
  let data = {};
  if (text) {
    try {
      data = JSON.parse(text);
    } catch (e) {
      throw new Error(`Respons bukan JSON (HTTP ${res.status}): ${text.slice(0, 180)}`);
    }
  }
  if (!res.ok) {
    throw new Error(data.error || `HTTP ${res.status}`);
  }
  return data;
}

function notify(message) {
  const host = document.getElementById("toastHost");
  if (!host) {
    alert(message);
    return;
  }
  const el = document.createElement("div");
  el.className = "toast";
  el.textContent = message;
  host.appendChild(el);
  window.setTimeout(() => { try { el.remove(); } catch (e) {} }, 4200);
}

function initDebugCard() {
  const card = document.getElementById("debugCard");
  const box = document.getElementById("debugBox");
  if (!card || !box) return;
  if (!WEBUI_DEBUG_ENABLED) {
    card.style.display = "none";
    box.innerText = "WEBUI_DEBUG belum aktif.";
    return;
  }
  card.style.display = "";
  box.innerText = "Klik Load Snapshot saat ingin mengirim data debug.";
}

async function loadDebugSnapshot() {
  const box = document.getElementById("debugBox");
  if (!box) return;
  box.innerText = "Loading debug snapshot...";
  try {
    const data = await api("/debug/snapshot");
    box.innerText = JSON.stringify(data, null, 2);
  } catch (err) {
    box.innerText = `Debug snapshot error: ${err.message}`;
  }
}

async function loadDebugUsb() {
  const box = document.getElementById("debugBox");
  if (!box) return;
  box.innerText = "Loading USB method map...";
  try {
    const data = await api("/debug/reink_usb");
    box.innerText = JSON.stringify(data, null, 2);
  } catch (err) {
    box.innerText = `Debug USB error: ${err.message}`;
  }
}

function printerActionMessage(printerName, level, message) {
  PRINTER_ACTION_STATE[printerName] = {
    level: level || "blue",
    message: message || "-",
    time: new Date().toLocaleTimeString()
  };
}

function renderPrinterAction(printerName) {
  const state = PRINTER_ACTION_STATE[printerName];
  if (!state || !state.message) return "";
  return `
    <div class="actionResult ${safeText(state.level || "blue")}">
      <b>Last Action</b><br/>
      ${nl2br(state.message)}<br/>
      <span class="mini">Updated ${safeText(state.time || "-")}</span>
    </div>
  `;
}

function describeTarget(target) {
  if (!target) return "-";
  const parts = [];
  if (target.type) parts.push(String(target.type));
  if (target.note) parts.push(String(target.note));
  return parts.join(" | ") || "-";
}

function summarizeInkValues(ink) {
  const keys = Object.keys(ink || {});
  if (!keys.length) return "";
  return keys.map(k => `${String(k).toUpperCase()} ${Number(ink[k]) || 0}%`).join(", ");
}

function updateApplyButtonState() {
  const btn = document.getElementById("applyUpdateBtn");
  btn.disabled = (!REINKPY_UPDATE_AVAILABLE) || REINKPY_UPDATE_BUSY;
}

function renderOverviewSummary(summary, printers, statuses) {
  const box = document.getElementById("overviewGrid");
  if (!box) return;

  const overview = (summary && summary.overview) || {};
  const printerList = printers || [];
  const statusList = statuses || [];
  let ready = 0;
  let observe = 0;
  let action = 0;

  statusList.forEach(statusData => {
    const health = printerHealthMeta(statusData);
    if (health.cls === "green") ready += 1;
    else if (health.cls === "yellow" || health.cls === "blue") observe += 1;
    else action += 1;
  });

  const lastJob = overview.last_job || {};
  const statCards = [
    {
      label: "Detected Printers",
      value: numText(overview.detected_printers || printerList.length || 0),
      note: `${numText(overview.printers_with_activity || 0)} printer punya histori job`
    },
    {
      label: "Ready / Observe / Action",
      value: `${ready}/${observe}/${action}`,
      note: "Kesehatan fleet dari status maintenance terakhir"
    },
    {
      label: "Tracked Jobs",
      value: numText(overview.tracked_jobs || 0),
      note: `Riwayat job dari CUPS page_log + portal: ${numText(overview.portal_jobs || 0)} portal, ${numText(overview.cups_jobs || 0)} CUPS`
    },
    {
      label: "Tracked Pages",
      value: numText(overview.tracked_pages || 0),
      note: `${numText(overview.tracked_copies || 0)} total copies yang tercatat`
    },
    {
      label: "Top Printer",
      value: safeText((overview.top_printer || {}).printer || "-"),
      note: overview.top_printer
        ? `${numText(overview.top_printer.jobs)} job | ${numText(overview.top_printer.pages)} halaman`
        : "Belum ada printer aktif"
    },
    {
      label: "Last Job",
      value: safeText(lastJob.printer || "-"),
      note: lastJob.time
        ? `${safeText(lastJob.time)} | ${safeText(lastJob.title || "-")}`
        : "Belum ada job terakhir"
    }
  ];

  box.innerHTML = statCards.map(card => `
    <div class="statCard">
      <div class="statLabel">${safeText(card.label)}</div>
      <div class="statValue">${safeText(card.value)}</div>
      <div class="statNote">${safeText(card.note)}</div>
    </div>
  `).join("");
}

function renderUsageLeaderboard(summary) {
  const box = document.getElementById("usageLeaderboard");
  if (!box) return;
  const rows = ((summary && summary.printers) || []).slice(0, 6);
  if (!rows.length) {
    box.innerHTML = `<div class="emptyState">Belum ada histori print yang bisa diringkas. Panel ini baru terisi setelah CUPS/portal mencatat job.</div>`;
    return;
  }

  box.innerHTML = rows.map(item => `
    <div class="metricItem">
      <div class="row">
        <div>
          <div class="metricTitle">${safeText(item.printer)}</div>
          <div class="mini">Last job: ${safeText(item.last_time || "-")}</div>
        </div>
        <div class="statusCluster">
          ${badge(`${numText(item.jobs)} job`, "blue")}
          ${badge(`${numText(item.pages)} halaman`, "green")}
        </div>
      </div>
      <div class="metricMeta">
        ${badge(`${numText(item.portal_jobs || 0)} portal`, "yellow")}
        ${badge(`${numText(item.cups_jobs || 0)} cups`, "green")}
        ${badge(`${numText(item.copies || 0)} copies`, "blue")}
      </div>
    </div>
  `).join("");
}

function renderRecentJobsFeed(summary) {
  const box = document.getElementById("recentJobsFeed");
  if (!box) return;
  const jobs = ((summary && summary.recent_jobs) || []).slice(0, 8);
  if (!jobs.length) {
    box.innerHTML = `<div class="emptyState">Belum ada job pada audit CUPS/portal. Ini normal jika server belum pernah dipakai print.</div>`;
    return;
  }

  box.innerHTML = jobs.map(job => {
    const src = jobSourceTag(job);
    return `
      <div class="jobItem">
        <div class="row">
          <div>
            <div class="metricTitle">${safeText(job.printer || "Unknown printer")}</div>
            <div class="mini">${safeText(job.time || "-")} | ${safeText(job.portal_title || job.title || "-")}</div>
          </div>
          <div class="statusCluster">
            ${badge(src.label, src.cls)}
            ${badge(`${numText(trackedPages(job))} hlm`, "blue")}
          </div>
        </div>
        <div class="metricMeta">
          ${badge(`Origin ${safeText(job.portal_request_ip || job.origin || "-")}`, "blue")}
          ${badge(`Copies ${numText(job.copies || 1)}`, "green")}
        </div>
      </div>
    `;
  }).join("");
}

function renderPrintStatsBoard(summary) {
  const board = document.getElementById("printStatsBoard");
  const rawBox = document.getElementById("printJobsBox");
  if (!board || !rawBox) return;

  const rows = ((summary && summary.printers) || []).slice(0, 10);
  const jobs = (summary && summary.recent_jobs) || [];
  if (!rows.length) {
    board.innerHTML = `<div class="emptyState">Belum ada data print dari CUPS maupun portal. Bagian ini tidak menunjukkan printer online/offline, hanya histori job.</div>`;
    rawBox.innerText = "No print jobs yet";
    return;
  }

  board.innerHTML = rows.map(item => `
    <div class="metricItem">
      <div class="row">
        <div>
          <div class="metricTitle">${safeText(item.printer)}</div>
          <div class="mini">Last title: ${safeText(item.last_title || "-")}</div>
        </div>
        <div class="statusCluster">
          ${badge(`${numText(item.jobs)} job`, "blue")}
          ${badge(`${numText(item.pages)} halaman`, "green")}
        </div>
      </div>
      <div class="metricMeta">
        ${badge(`${numText(item.portal_jobs || 0)} portal`, "yellow")}
        ${badge(`${numText(item.cups_jobs || 0)} cups`, "green")}
        ${badge(`Last ${safeText(item.last_time || "-")}`, "blue")}
      </div>
    </div>
  `).join("");

  const lines = jobs.map(job => {
    const source = safeText(job.portal_source || job.source || "cups");
    const origin = safeText(job.portal_request_ip || job.origin || "-");
    const requester = safeText(job.portal_requester || "-");
    const title = safeText(job.portal_title || job.title || "-");
    return `[${safeText(job.time || "-")}] ${safeText(job.job_id || "-")} | ${safeText(job.printer || "-")} | source=${source} | origin=${origin} | requester=${requester} | copies=${safeText(job.copies || 1)} | pages=${trackedPages(job)} | title=${title}`;
  });
  rawBox.innerText = lines.join("\n") || "No print jobs yet";
}

async function loadDashboardSummary() {
  try {
    const summary = await api("/dashboard/summary?limit=400");
    DASHBOARD_SUMMARY = summary;
    DASHBOARD_USAGE_MAP = {};
    (summary.printers || []).forEach(item => {
      if (item && item.printer) DASHBOARD_USAGE_MAP[item.printer] = item;
    });
    renderOverviewSummary(summary);
    renderUsageLeaderboard(summary);
    renderRecentJobsFeed(summary);
    renderPrintStatsBoard(summary);
  } catch (err) {
    const message = `<div class="emptyState">Summary error: ${safeText(err.message)}</div>`;
    const overview = document.getElementById("overviewGrid");
    const usage = document.getElementById("usageLeaderboard");
    const recent = document.getElementById("recentJobsFeed");
    const printBoard = document.getElementById("printStatsBoard");
    if (overview) overview.innerHTML = message;
    if (usage) usage.innerHTML = message;
    if (recent) recent.innerHTML = message;
    if (printBoard) printBoard.innerHTML = message;
  }
}

function updateSourceButtons(meta) {
  const active = String((meta && meta.runtime_effective_source) || (meta && meta.active_source) || "");
  const mode = String((meta && meta.runtime_mode) || (meta && meta.source_mode_requested) || "auto");
  const busy = REINKPY_SWITCH_BUSY || REINKPY_UPDATE_BUSY;
  const fixAvailable = (meta && Object.prototype.hasOwnProperty.call(meta, "fix_available")) ? !!meta.fix_available : true;
  const origAvailable = (meta && Object.prototype.hasOwnProperty.call(meta, "original_available")) ? !!meta.original_available : true;

  const autoBtn = document.getElementById("srcAutoBtn");
  const fixBtn = document.getElementById("srcFixBtn");
  const origBtn = document.getElementById("srcOrigBtn");
  const restoreBtn = document.getElementById("srcRestoreBtn");

  if (autoBtn) autoBtn.disabled = busy;
  if (fixBtn) fixBtn.disabled = busy || !fixAvailable;
  if (origBtn) origBtn.disabled = busy || !origAvailable;
  if (restoreBtn) restoreBtn.disabled = busy;
  if (autoBtn) autoBtn.innerText = mode === "auto" ? "Use Auto (Active)" : "Use Auto";
  if (fixBtn) fixBtn.innerText = !fixAvailable ? "Use Fix (N/A)" : (active === "fix" ? "Use Fix (Active)" : "Use Fix");
  if (origBtn) origBtn.innerText = !origAvailable ? "Use Original (N/A)" : (active === "original" ? "Use Original (Active)" : "Use Original");
}

function updateBadgeForState(state) {
  if (state === "success") return badge("SUCCESS", "green");
  if (state === "failed") return badge("FAILED", "red");
  if (state === "running") return badge("RUNNING", "blue");
  if (state === "queued") return badge("QUEUED", "yellow");
  return badge("IDLE", "blue");
}

function ensureUpdatePoll(ms) {
  if (UPDATE_TIMER && UPDATE_POLL_MS === ms) return;
  if (UPDATE_TIMER) clearInterval(UPDATE_TIMER);
  UPDATE_POLL_MS = ms;
  UPDATE_TIMER = setInterval(loadUpdateJobStatus, ms);
}

function setUpdateFill(state, progress) {
  const fill = document.getElementById("updateJobFill");
  const pct = Math.max(0, Math.min(100, Number(progress) || 0));
  fill.style.width = `${pct}%`;
  fill.classList.remove("green", "yellow", "red");
  if (state === "success") {
    fill.classList.add("green");
  } else if (state === "failed") {
    fill.classList.add("red");
  } else if (state === "queued" || state === "running") {
    fill.classList.add("yellow");
  }
}

async function refreshLock() {
  const data = await api("/lockstate");
  const div = document.getElementById("lockstate");
  if (!data.locked) {
    div.innerHTML = badge("NOT LOCKED", "green");
    return;
  }
  div.innerHTML = `${badge("LOCKED", "red")} Locked Printer: <b>${safeText(data.printer)}</b> (${safeText(data.time)})`;
}

async function unlockAll() {
  await api("/unlock");
  await refreshLock();
}

async function loadLogs() {
  try {
    const d = await api("/logs");
    const feed = document.getElementById("activityFeed");
    if (!d.ok) {
      document.getElementById("logBox").innerText = "Error loading logs";
      if (feed) feed.innerHTML = `<div class="emptyState">Activity log gagal dimuat.</div>`;
      return;
    }
    let txt = "";
    const items = [];
    (d.logs || []).forEach(l => {
      txt += `[${l.time}] ${l.ip} | ${l.action} | ${l.printer || "-"} | ${l.result}`;
      if (l.detail) txt += ` | ${l.detail}`;
      txt += "\\n";
      items.push(l);
    });
    document.getElementById("logBox").innerText = txt || "No activity yet";
    if (feed) {
      const cards = items.slice(0, 10).map(l => `
        <div class="jobItem">
          <div class="row">
            <div>
              <div class="metricTitle">${safeText(l.action || "-")}</div>
              <div class="mini">${safeText(l.time || "-")} | ${safeText(l.printer || "-")}</div>
            </div>
            <div class="statusCluster">
              ${badge(safeText(l.result || "-"), String(l.result || "").toUpperCase() === "OK" ? "green" : "red")}
            </div>
          </div>
          <div class="mini" style="margin-top:8px;">${safeText(l.ip || "-")} ${l.detail ? `| ${safeText(l.detail)}` : ""}</div>
        </div>
      `);
      feed.innerHTML = cards.join("") || `<div class="emptyState">Belum ada activity log.</div>`;
    }
  } catch (err) {
    document.getElementById("logBox").innerText = `Log error: ${err.message}`;
    const feed = document.getElementById("activityFeed");
    if (feed) feed.innerHTML = `<div class="emptyState">Log error: ${safeText(err.message)}</div>`;
  }
}

async function submitPrintJob() {
  if (!WEB_PRINT_ENABLED) {
    notify("Portal print sedang dinonaktifkan.");
    return;
  }

  const queue = document.getElementById("printQueueSelect").value;
  const fileInput = document.getElementById("printFileInput");
  const title = document.getElementById("printTitleInput").value.trim();
  const requester = document.getElementById("printRequesterInput").value.trim();
  const copies = document.getElementById("printCopiesInput").value || "1";
  const btn = document.getElementById("printSubmitBtn");

  if (!queue) {
    notify("Queue CUPS belum tersedia.");
    return;
  }
  if (!fileInput.files || !fileInput.files.length) {
    notify("Pilih file yang ingin dicetak.");
    return;
  }

  const form = new FormData();
  form.append("printer", queue);
  form.append("title", title);
  form.append("requester", requester);
  form.append("copies", copies);
  form.append("file", fileInput.files[0]);

  btn.disabled = true;
  btn.innerText = "Submitting...";
  try {
    const res = await fetch("/print/submit", {method: "POST", body: form});
    const data = await res.json();
    if (!res.ok || !data.ok) {
      throw new Error(data.error || `HTTP ${res.status}`);
    }
    fileInput.value = "";
    document.getElementById("printTitleInput").value = "";
    document.getElementById("printRequesterInput").value = "";
    document.getElementById("printCopiesInput").value = "1";
    notify(`Job print terkirim${data.job_id ? `: ${data.job_id}` : ""}`);
    await loadDashboardSummary();
    await loadPrintersAndStatus();
    await loadLogs();
  } catch (err) {
    notify(`Print submit gagal: ${err.message}`);
  } finally {
    btn.disabled = false;
    btn.innerText = "Print Now";
  }
}

async function loadUsbInfo() {
  const d = await api("/usb");
  document.getElementById("lsusbRaw").innerText = d.raw || "No data";
}

async function loadIppUsbInfo() {
  const d = await api("/ippusb");
  let stateText = d.active ? badge("ACTIVE", "green") : badge("INACTIVE", "red");
  stateText += " " + badge((d.mode || "unknown").toUpperCase(), "blue");
  if (d.epson_usb) stateText += " " + badge("EPSON DETECTED", "green");
  document.getElementById("ippusbState").innerHTML = stateText;

  let txt = "";
  if (d.mode === "container") {
    txt += "Mode: Container\\n";
    txt += "Detection: Port Scan\\n";
    const targets = (d.targets || []).map(t => `${t.host}:${t.port}`);
    txt += "Open Targets:\\n" + (targets.length ? targets.join("\\n") : (d.ports || []).join("\\n")) + "\\n";
    txt += "\\n" + (d.note || "");
  } else {
    txt += d.status || "";
    txt += "\\n\\n--- Logs ---\\n" + (d.recent_log || "");
  }
  document.getElementById("ippusbStatus").innerText = txt.trim() || "No status";
}

async function loadPortScan() {
  const d = await api("/ipp_ports");
  const targets = (d.targets || []).map(t => `${t.host}:${t.port}`);
  document.getElementById("ippPorts").innerText = targets.join("\\n") || (d.ports || []).join("\\n") || "No open ports detected";
}

function shortSha(sha) {
  if (!sha) return "-";
  return String(sha).slice(0, 10);
}

async function loadUpdateJobStatus() {
  try {
    const d = await api("/reinkpy/update_status?lines=120");
    const s = d.status || {};
    const state = String(s.state || "idle");
    const progress = Number(s.progress || 0);

    REINKPY_UPDATE_BUSY = !!d.busy;
    updateApplyButtonState();

    document.getElementById("updateJobState").innerHTML =
      `${updateBadgeForState(state)} ${badge(`${Math.max(0, Math.min(100, progress))}%`, "blue")}`;
    document.getElementById("updateJobMessage").innerText = s.message || "-";
    setUpdateFill(state, progress);

    const meta = [];
    if (s.request_id) meta.push(`Request: ${s.request_id}`);
    if (s.source) meta.push(`Source: ${s.source}`);
    if (s.started_at) meta.push(`Start: ${s.started_at}`);
    if (s.finished_at) meta.push(`Done: ${s.finished_at}`);
    if (s.updated_at) meta.push(`Updated: ${s.updated_at}`);
    document.getElementById("updateJobMeta").innerText = meta.join(" | ") || "-";

    const lines = d.logs || [];
    document.getElementById("updateJobLog").innerText = lines.length
      ? lines.join("\\n")
      : "No update activity yet.";

    ensureUpdatePoll(REINKPY_UPDATE_BUSY ? 2000 : 15000);
  } catch (err) {
    document.getElementById("updateJobMessage").innerText = `Status error: ${err.message}`;
    ensureUpdatePoll(15000);
  }
}

async function loadReinkpyInfo() {
  const d = await api("/reinkpy/version");
  const state = document.getElementById("reinkpyState");
  const box = document.getElementById("reinkpyBox");
  updateApplyButtonState();
  updateSourceButtons(d);

  let stateTxt = badge("LOCAL META", "blue");
  const runtimeSource = d.runtime_effective_source || d.active_source;
  if (runtimeSource === "fix") {
    stateTxt += " " + badge("ACTIVE: FIX", "green");
  } else if (runtimeSource === "original") {
    stateTxt += " " + badge("ACTIVE: ORIGINAL", "yellow");
  } else {
    stateTxt += " " + badge("ACTIVE: UNKNOWN", "red");
  }
  state.innerHTML = stateTxt;

  const lines = [];
  lines.push(`Source Mode (Build): ${d.source_mode_requested || "-"}`);
  lines.push(`Source Mode (Runtime): ${d.runtime_mode || "-"}`);
  lines.push(`Runtime Effective: ${d.runtime_effective_source || "-"}`);
  lines.push(`Override Mode: ${d.runtime_override_mode || "-"}`);
  lines.push(`Override Set At: ${d.runtime_override_set_at || "-"}`);
  lines.push(`Selection Reason: ${d.selection_reason || "-"}`);
  lines.push(`Fix Stale Days: ${d.fix_stale_days ?? "-"}`);
  lines.push(`Built UTC: ${d.built_at_utc || "-"}`);
  lines.push(`Active Commit: ${shortSha(d.active_commit)}`);
  lines.push(`Original Commit: ${shortSha(d.origin_commit)}`);
  lines.push(`Patch Commit: ${shortSha(d.fix_commit)}`);
  lines.push(`Module File: ${d.reinkpy_file || "-"}`);
  lines.push(`Resolved File: ${d.reinkpy_real_file || "-"}`);
  box.innerText = lines.join("\\n");
}

async function checkReinkpyUpdate() {
  const d = await api("/reinkpy/check_update?notify=1");
  const r = d.details || {};
  const lines = [];

  lines.push(`Active Source : ${r.active_source || "-"}`);
  lines.push(`Original Local : ${shortSha(r.origin_local)}`);
  lines.push(`Original Remote: ${shortSha(r.origin_remote)}`);
  lines.push(`Patch Local    : ${shortSha(r.fix_local)}`);
  lines.push(`Patch Remote   : ${shortSha(r.fix_remote)}`);
  if (r.origin_error) lines.push(`Origin Error   : ${r.origin_error}`);
  if (r.fix_error) lines.push(`Patch Error    : ${r.fix_error}`);

  document.getElementById("reinkpyBox").innerText = lines.join("\\n");
  REINKPY_UPDATE_AVAILABLE = !!d.has_update;
  updateApplyButtonState();
  document.getElementById("reinkpyState").innerHTML = d.has_update
    ? `${badge("UPDATE AVAILABLE", "yellow")} ${badge("CHECKED", "blue")}`
    : `${badge("UP TO DATE", "green")} ${badge("CHECKED", "blue")}`;

  if (d.has_update) {
    notify("Update reinkpy terdeteksi. Disarankan rebuild image webui.");
  } else {
    notify("reinkpy original + patch masih up to date.");
  }
}

async function applyReinkpyUpdate() {
  if (!REINKPY_UPDATE_AVAILABLE) {
    notify("Belum ada update yang perlu diterapkan.");
    return;
  }
  if (!confirm("Jalankan update sekarang? Proses ini akan trigger rebuild Maintenance Tools.")) return;

  const d = await api("/reinkpy/apply_update", {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify({source: "ui"})
  });

  if (d.ok) {
    notify("Update request dikirim. Host daemon sedang memproses rebuild.");
    await loadUpdateJobStatus();
    ensureUpdatePoll(2000);
  } else {
    notify("Gagal mengirim update request: " + (d.error || "Unknown"));
  }
}

async function switchReinkpySource(mode) {
  const label = mode === "fix" ? "FIX" : (mode === "original" ? "ORIGINAL" : "AUTO");
  if (!confirm(`Switch runtime reinkpy source ke ${label}?`)) return;
  REINKPY_SWITCH_BUSY = true;
  updateSourceButtons({});
  try {
    const d = await api("/reinkpy/switch_source", {
      method: "POST",
      headers: {"Content-Type": "application/json"},
      body: JSON.stringify({mode, source: "ui"})
    });
    if (!d.ok) {
      notify("Switch source gagal: " + (d.error || "Unknown"));
      return;
    }
    notify(`Source aktif sekarang: ${d.effective_source || "-"}`);
    REINKPY_UPDATE_AVAILABLE = false;
    updateApplyButtonState();
    await loadReinkpyInfo();
  } catch (err) {
    notify(`Switch source error: ${err.message}`);
  } finally {
    REINKPY_SWITCH_BUSY = false;
    await loadReinkpyInfo();
  }
}

async function restoreReinkpySource() {
  if (!confirm("Restore source ke mode sebelumnya?")) return;
  REINKPY_SWITCH_BUSY = true;
  updateSourceButtons({});
  try {
    const d = await api("/reinkpy/restore_source", {
      method: "POST",
      headers: {"Content-Type": "application/json"},
      body: JSON.stringify({source: "ui"})
    });
    if (!d.ok) {
      notify("Restore source gagal: " + (d.error || "Unknown"));
      return;
    }
    notify(`Restore berhasil. Source aktif: ${d.effective_source || "-"}`);
    REINKPY_UPDATE_AVAILABLE = false;
    updateApplyButtonState();
    await loadReinkpyInfo();
  } catch (err) {
    notify(`Restore source error: ${err.message}`);
  } finally {
    REINKPY_SWITCH_BUSY = false;
    await loadReinkpyInfo();
  }
}

function meterClass(value) {
  if (value >= 90) return "red";
  if (value >= 70) return "yellow";
  return "green";
}

function renderInkBars(ink, statusData) {
  const keys = Object.keys(ink || {});
  if (keys.length === 0) {
    const note = (statusData && statusData.info && statusData.info.ink_note)
      ? statusData.info.ink_note
      : "Ink level belum tersedia dari backend aktif";
    return `<div class="mini" style="margin-top:8px;">${safeText(note)}</div>`;
  }

  let out = `<div class="sectionLabel">Ink Level</div>`;
  keys.forEach(k => {
    const v = Number(ink[k]) || 0;
    const cls = meterClass(v);
    out += `<div class="mini">${safeText(k.toUpperCase())}: ${v}%</div>`;
    out += `<div class="bar"><div class="fill ${cls}" style="width:${Math.max(0, Math.min(100, v))}%"></div></div>`;
  });
  return out;
}

function renderPrinterCard(p, statusData) {
  const usage = usageForPrinter(p.name);
  const health = printerHealthMeta(statusData);
  const backend = backendMeta(statusData);
  const caps = maintenanceCapabilities(p, statusData);
  let html = `<div class="printerCard">`;
  const remoteUri = String(p.source || "").toLowerCase() === "cups" ? printUriForQueue(p.name) : "";
  html += `
    <div class="printerHeader">
      <div>
        <div class="printerName">${safeText(p.name)}</div>
        <div class="mini">${safeText(p.source || "cups")} | ${safeText(health.note)}</div>
      </div>
      <div class="statusCluster">
        ${badge(health.label, health.cls)}
        ${badge(backend.label, backend.cls)}
      </div>
    </div>
  `;
  html += `<div class="printerMeta">`;
  html += `<div class="mini">URI: ${safeText(p.uri)}</div>`;
  if (remoteUri) {
    html += `<div class="mini">Remote IPP: ${safeText(remoteUri)}</div>`;
  }
  if (p.desc) {
    html += `<div class="mini">Detect: ${safeText(p.desc)}</div>`;
  }
  if (p.debug_duplicates && p.debug_duplicates.length) {
    html += `<div class="mini">Hidden duplicate queues: ${safeText(p.debug_duplicates.join(", "))}</div>`;
  }
  html += `</div>`;

  if (usage) {
    html += `
      <div class="usageStrip" style="margin-top:10px;">
        ${badge(`${numText(usage.jobs)} job`, "blue")}
        ${badge(`${numText(usage.pages)} halaman`, "green")}
        ${badge(`${numText(usage.portal_jobs || 0)} portal`, "yellow")}
        ${badge(`Last ${safeText(usage.last_time || "-")}`, "blue")}
      </div>
    `;
  } else {
    html += `<div class="usageStrip" style="margin-top:10px;">${badge("No tracked print stats yet", "blue")}</div>`;
  }

  if (!statusData) {
    html += `<div class="muted" style="margin-top:10px;">Status printer belum dimuat.</div>`;
    html += renderCapabilityList(caps);
    html += renderPrinterAction(p.name);
    html += actionBlocks(p.name, caps);
    html += `</div>`;
    return html;
  }

  if (!statusData.ok) {
    html += `<div style="margin-top:10px;">${badge("ERROR", "red")} ${safeText(statusData.error || "Unknown error")}</div>`;
    if (statusData.target) {
      html += `<div class="mini" style="margin-top:8px;">Target: ${safeText(statusData.target.type)} | ${safeText(statusData.target.note)}</div>`;
    }
    html += `<div class="disabledHint">Maintenance selain Refresh Status sengaja dimatikan sampai printer benar-benar terdeteksi live.</div>`;
    html += renderCapabilityList(caps);
    html += renderPrinterAction(p.name);
    html += actionBlocks(p.name, caps);
    html += `</div>`;
    return html;
  }

  const target = statusData.target || {};
  const statusLine = statusData.info && statusData.info.status_line ? statusData.info.status_line : "Status OK";
  const hostText = target.host ? `${safeText(target.host)}:${safeText(target.port)}` : "direct USB";
  html += `<div style="margin-top:10px;">${badge("STATUS", "green")} ${safeText(statusLine)}</div>`;
  html += `
    <div class="maintenanceStats">
      <div class="miniCard">
        <div class="statLabel">Connection</div>
        <div class="statValue" style="font-size:16px;">${safeText(target.type || "unknown")}</div>
        <div class="statNote">${safeText(target.note || hostText)}</div>
      </div>
      <div class="miniCard">
        <div class="statLabel">Last Refresh</div>
        <div class="statValue" style="font-size:16px;">${safeText(statusData.ts || "-")}</div>
        <div class="statNote">Host ${hostText}</div>
      </div>
    </div>
  `;

  if (statusData.waste !== null && statusData.waste !== undefined) {
    const waste = Number(statusData.waste) || 0;
    const cls = meterClass(waste);
    html += `<div class="sectionLabel">Waste Ink</div>`;
    html += `<div class="mini">${waste}% ${badge(cls.toUpperCase(), cls)}</div>`;
    html += `<div class="bar"><div class="fill ${cls}" style="width:${Math.max(0, Math.min(100, waste))}%"></div></div>`;
  }

  html += renderInkBars(statusData.ink || {}, statusData);
  html += renderCapabilityList(caps);

  if (statusData.raw) {
    html += `<details><summary>Backend Response</summary><pre>${safeText(String(statusData.raw))}</pre></details>`;
  }
  if (statusData.snmp_supplies) {
    html += `<details><summary>SNMP Supplies Raw Table</summary><pre>${safeText(JSON.stringify(statusData.snmp_supplies, null, 2))}</pre></details>`;
  }

  html += renderPrinterAction(p.name);
  html += actionBlocks(p.name, caps);
  html += `</div>`;
  return html;
}

function actionBlocks(printerName, caps) {
  const p = encodeURIComponent(printerName);
  return `
    <span class="sectionLabel">Monitoring</span>
    <div class="actionGrid">
      ${renderActionButton("Refresh Status", `doStatus('${p}', true)`, "btn-primary", caps.refresh)}
      ${renderActionButton("Ink & Waste", `getInkStatus('${p}', true)`, "", caps.telemetry)}
      ${renderActionButton("Nozzle Check", `doNozzle('${p}', true)`, "", caps.nozzle)}
    </div>
    <span class="sectionLabel">Maintenance</span>
    <div class="actionGrid">
      ${renderActionButton("Head Clean", `doCleanFast('${p}', true)`, "btn-warn", caps.cleanFast)}
      ${renderActionButton("Power Cleaning", `doCleanDeep('${p}', true)`, "btn-danger", caps.cleanDeep)}
      ${renderActionButton("Lock Session", `doLock('${p}', true)`, "", caps.lock)}
    </div>
    <span class="sectionLabel">Critical</span>
    <div class="actionGrid full">
      ${renderActionButton("Reset Waste Counter", `resetMaintenance('${p}', true)`, "btn-danger", caps.reset)}
    </div>
    <div class="disabledHint">${safeText(caps.summary)}</div>
  `;
}

function decodePrinterName(encodedName) {
  return decodeURIComponent(encodedName);
}

async function doStatus(encodedName, refresh) {
  const printerName = decodePrinterName(encodedName);
  const model = getSelectedModel();
  try {
    printerActionMessage(printerName, "yellow", "Refreshing status printer...");
    const data = await api(`/status?printer=${encodeURIComponent(printerName)}&model=${encodeURIComponent(model)}`);
    const statusLine = data.info && data.info.status_line ? data.info.status_line : "Status refreshed";
    const detail = `Status OK. ${statusLine}. Conn: ${describeTarget(data.target)}.`;
    printerActionMessage(printerName, "green", detail);
  } catch (err) {
    printerActionMessage(printerName, "red", `Status gagal: ${err.message}`);
  }
  if (refresh) await refreshAll();
}

async function doNozzle(encodedName, refresh) {
  const printerName = decodePrinterName(encodedName);
  const engine = getEngine();
  const model = getSelectedModel();
  try {
    printerActionMessage(printerName, "yellow", `Menjalankan nozzle check via ${engine}...`);
    const r = await api(`/v7/nozzle?printer=${encodeURIComponent(printerName)}&engine=${encodeURIComponent(engine)}&model=${encodeURIComponent(model)}`);
    const level = r.ok ? "green" : (r.unsupported_usb_method ? "blue" : "red");
    const detail = r.ok
      ? `Nozzle check terkirim via ${r.engine || engine}${r.method ? ` (${r.method})` : ""}${r.fallback_reason ? `. Fallback: ${r.fallback_reason}` : ""}.`
      : (r.unsupported_usb_method
          ? `Nozzle check belum tersedia pada backend USB native aktif. ${r.error || ""}`.trim()
          : `Nozzle gagal: ${r.error || "Unknown"}`);
    printerActionMessage(printerName, level, detail);
  } catch (err) {
    printerActionMessage(printerName, "red", `Nozzle gagal: ${err.message}`);
  }
  if (refresh) await refreshAll();
}

async function doCleanFast(encodedName, refresh) {
  const printerName = decodePrinterName(encodedName);
  const engine = getEngine();
  const model = getSelectedModel();
  try {
    printerActionMessage(printerName, "yellow", `Menjalankan head clean via ${engine}...`);
    const r = await api(`/v7/clean?printer=${encodeURIComponent(printerName)}&engine=${encodeURIComponent(engine)}&model=${encodeURIComponent(model)}`);
    const level = r.ok ? "green" : (r.unsupported_usb_method ? "blue" : "red");
    const detail = r.ok
      ? `Head clean terkirim via ${r.engine || engine}${r.method ? ` (${r.method})` : ""}${r.fallback_reason ? `. Fallback: ${r.fallback_reason}` : ""}.`
      : (r.unsupported_usb_method
          ? `Head clean belum tersedia pada backend USB native aktif. ${r.error || ""}`.trim()
          : `Head clean gagal: ${r.error || "Unknown"}`);
    printerActionMessage(printerName, level, detail);
  } catch (err) {
    printerActionMessage(printerName, "red", `Head clean gagal: ${err.message}`);
  }
  if (refresh) await refreshAll();
}

async function doCleanDeep(encodedName, refresh) {
  const printerName = decodePrinterName(encodedName);
  const engine = getEngine();
  const model = getSelectedModel();
  try {
    printerActionMessage(printerName, "yellow", `Menjalankan power cleaning via ${engine}...`);
    const r = await api(`/v7/clean?printer=${encodeURIComponent(printerName)}&engine=${encodeURIComponent(engine)}&model=${encodeURIComponent(model)}&power=1`);
    const level = r.ok ? "green" : (r.unsupported_usb_method ? "blue" : "red");
    const detail = r.ok
      ? `Power cleaning terkirim via ${r.engine || engine}${r.method ? ` (${r.method})` : ""}${r.fallback_reason ? `. Fallback: ${r.fallback_reason}` : ""}.`
      : (r.unsupported_usb_method
          ? `Power cleaning belum tersedia pada backend USB native aktif. ${r.error || ""}`.trim()
          : `Power cleaning gagal: ${r.error || "Unknown"}`);
    printerActionMessage(printerName, level, detail);
  } catch (err) {
    printerActionMessage(printerName, "red", `Power cleaning gagal: ${err.message}`);
  }
  if (refresh) await refreshAll();
}

async function doLock(encodedName, refresh) {
  const printerName = decodePrinterName(encodedName);
  try {
    await api(`/lock?printer=${encodeURIComponent(printerName)}`);
    printerActionMessage(printerName, "blue", "Printer dikunci untuk sesi maintenance ini.");
  } catch (err) {
    printerActionMessage(printerName, "red", `Lock gagal: ${err.message}`);
  }
  if (refresh) await refreshLock();
}

async function getInkStatus(encodedName, refresh) {
  const printerName = decodePrinterName(encodedName);
  try {
    printerActionMessage(printerName, "yellow", "Membaca level tinta dari backend aktif...");
    const data = await api(`/api/ink_status?printer=${encodeURIComponent(printerName)}`);
    if (!data.ok) {
      printerActionMessage(printerName, "red", `Ink status gagal: ${data.error || "Unknown error"}`);
      return;
    }
    const inkSummary = summarizeInkValues(data.ink || {});
    const wasteSummary = data.waste !== null && data.waste !== undefined
      ? ` Waste pad: ${Number(data.waste) || 0}%.`
      : "";
    const detail = inkSummary
      ? `Level tinta: ${inkSummary}.${wasteSummary}`
      : `Backend aktif terhubung, tetapi level tinta belum tersedia untuk model ini.${wasteSummary}`.trim();
    printerActionMessage(printerName, inkSummary ? "green" : "blue", detail);
  } catch (err) {
    printerActionMessage(printerName, "red", `Ink status gagal: ${err.message}`);
  }
  if (refresh) await refreshAll();
}

async function resetMaintenance(encodedName, refresh) {
  const printerName = decodePrinterName(encodedName);
  const model = getSelectedModel();
  if (!confirm("Pastikan waste pad sudah dibersihkan. Lanjut reset counter?")) return;
  try {
    printerActionMessage(printerName, "yellow", "Menjalankan reset waste counter...");
    const data = await api("/v7/reset_waste", {
      method: "POST",
      headers: {"Content-Type": "application/json"},
      body: JSON.stringify({printer: printerName, model, confirm: true})
    });
    if (!data.ok) {
      printerActionMessage(printerName, "red", `Reset gagal: ${data.error || "Unknown error"}`);
      return;
    }
    printerActionMessage(printerName, "green", `Reset waste counter berhasil via ${data.engine || "backend aktif"}.`);
  } catch (err) {
    printerActionMessage(printerName, "red", `Reset gagal: ${err.message}`);
  }
  if (refresh) await refreshAll();
}

async function loadPrintersAndStatus() {
  const renderSeq = ++PRINTER_RENDER_SEQ;
  const data = await api("/printers");
  const printers = data.printers || [];
  const grid = document.getElementById("printerGrid");
  setPrintQueueOptions(printers);

  if (renderSeq !== PRINTER_RENDER_SEQ) return;
  if (!printers.length) {
    grid.innerHTML = `<div class="emptyState">Belum ada printer yang terdeteksi dari CUPS atau USB fallback. Dalam kondisi ini utility maintenance memang tidak akan aktif selain pembacaan status dasar.</div>`;
    return;
  }

  const model = getSelectedModel();
  const statuses = await Promise.all(
    printers.map(p =>
      api(`/status?printer=${encodeURIComponent(p.name)}&model=${encodeURIComponent(model)}`)
        .catch(err => ({ok: false, error: err.message}))
    )
  );

  if (renderSeq !== PRINTER_RENDER_SEQ) return;
  const html = printers.map((p, i) => renderPrinterCard(p, statuses[i])).join("");
  grid.innerHTML = html;
  renderOverviewSummary(DASHBOARD_SUMMARY, printers, statuses);
}

async function refreshAll() {
  if (REFRESH_BUSY) {
    REFRESH_PENDING = true;
    return;
  }
  REFRESH_BUSY = true;
  try {
    await refreshLock();
    updatePrintPortalMeta();
    await loadUsbInfo();
    await loadIppUsbInfo();
    await loadPortScan();
    await loadReinkpyInfo();
    await loadUpdateJobStatus();
    await loadDashboardSummary();
    await loadPrintersAndStatus();
    await loadLogs();
  } catch (err) {
    console.error("Refresh error:", err);
  } finally {
    REFRESH_BUSY = false;
    if (REFRESH_PENDING) {
      REFRESH_PENDING = false;
      setTimeout(refreshAll, 0);
    }
  }
}

async function boot() {
  document.getElementById("modelSelect").value = "{{DEFAULT_MODEL}}";
  initDebugCard();
  updatePrintPortalMeta();
  await refreshAll();
  if (STATUS_TIMER) clearInterval(STATUS_TIMER);
  STATUS_TIMER = setInterval(refreshAll, 30000);
  ensureUpdatePoll(15000);
}

boot();
</script>
</body>
</html>
""".replace("{{DEFAULT_MODEL}}", DEFAULT_MODEL) \
   .replace("{{REMOTE_PRINT_HOST_HINT}}", REMOTE_PRINT_HOST_HINT) \
   .replace("{{WEB_PRINT_ALLOWED_LABEL}}", ", ".join(ext.upper() for ext in WEB_PRINT_ALLOWED_EXTS)) \
   .replace("{{WEB_PRINT_MAX_MB}}", str(WEB_PRINT_MAX_MB)) \
   .replace("{{WEB_PRINT_ENABLED}}", "yes" if WEB_PRINT_ENABLED else "no") \
   .replace("{{WEBUI_DEBUG_ENABLED}}", "yes" if WEBUI_DEBUG else "no")

PORTAL_HTML = """
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Remote Print Portal</title>
  <style>
    :root {
      --bg: #f3f6fb;
      --panel: #ffffff;
      --line: #d9e3f0;
      --text: #102038;
      --muted: #5b6d85;
      --accent: #0f766e;
      --accent-soft: rgba(15, 118, 110, 0.1);
      --ok: #15803d;
      --warn: #a16207;
      --danger: #b91c1c;
      --shadow: 0 14px 34px rgba(15, 23, 42, 0.08);
    }

    * { box-sizing: border-box; }

    body {
      margin: 0;
      font-family: "Segoe UI", "Noto Sans", "Helvetica Neue", Arial, sans-serif;
      color: var(--text);
      background:
        radial-gradient(circle at top left, rgba(15, 118, 110, 0.08), transparent 30%),
        radial-gradient(circle at top right, rgba(14, 116, 144, 0.08), transparent 32%),
        var(--bg);
      min-height: 100vh;
    }

    .wrap {
      max-width: 860px;
      margin: 0 auto;
      padding: 28px 18px 44px;
    }

    .hero {
      background: linear-gradient(135deg, #0f172a, #134e4a);
      color: #ecfeff;
      border-radius: 20px;
      padding: 24px;
      box-shadow: var(--shadow);
    }

    .hero h1 {
      margin: 0;
      font-size: 28px;
      line-height: 1.1;
    }

    .hero p {
      margin: 10px 0 0;
      color: rgba(236, 254, 255, 0.85);
      font-size: 14px;
      line-height: 1.5;
    }

    .card {
      margin-top: 18px;
      background: var(--panel);
      border: 1px solid var(--line);
      border-radius: 18px;
      padding: 18px;
      box-shadow: var(--shadow);
    }

    .cardTitle {
      margin: 0 0 6px;
      font-size: 16px;
      font-weight: 800;
    }

    .muted {
      color: var(--muted);
      font-size: 13px;
      line-height: 1.5;
    }

    .grid {
      display: grid;
      grid-template-columns: 1fr;
      gap: 12px;
      margin-top: 14px;
    }

    @media(min-width: 760px) {
      .grid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
      }
    }

    label {
      display: block;
      margin-bottom: 6px;
      font-size: 11px;
      font-weight: 800;
      letter-spacing: .4px;
      text-transform: uppercase;
      color: var(--muted);
    }

    input, select, button {
      width: 100%;
      border-radius: 12px;
      border: 1px solid var(--line);
      background: #fff;
      color: var(--text);
      padding: 11px 12px;
      font-size: 14px;
    }

    button {
      cursor: pointer;
      font-weight: 700;
      background: linear-gradient(135deg, var(--accent), #0f766e);
      color: #fff;
      border: none;
      box-shadow: 0 10px 24px rgba(15, 118, 110, 0.18);
    }

    button:disabled {
      opacity: .7;
      cursor: wait;
    }

    .hintBox, .resultBox {
      margin-top: 14px;
      padding: 12px 14px;
      border-radius: 14px;
      border: 1px solid var(--line);
      background: #f8fbff;
      font-size: 13px;
      line-height: 1.5;
      color: var(--muted);
    }

    .resultBox.green { border-color: rgba(21, 128, 61, 0.35); color: var(--ok); background: rgba(21, 128, 61, 0.06); }
    .resultBox.yellow { border-color: rgba(161, 98, 7, 0.35); color: var(--warn); background: rgba(161, 98, 7, 0.06); }
    .resultBox.red { border-color: rgba(185, 28, 28, 0.35); color: var(--danger); background: rgba(185, 28, 28, 0.06); }

    .mini {
      margin-top: 10px;
      font-size: 12px;
      color: var(--muted);
    }

    code {
      font-family: "SFMono-Regular", Consolas, "Liberation Mono", monospace;
      font-size: 12px;
      background: var(--accent-soft);
      color: #115e59;
      padding: 2px 6px;
      border-radius: 999px;
    }
  </style>
</head>
<body>
  <div class="wrap">
    <section class="hero">
      <h1>Remote Print Portal</h1>
      <p>Portal ini khusus untuk kirim file ke printer kantor melalui CUPS. Maintenance printer, reset, dan tooling admin berada di ruang terpisah.</p>
    </section>

    <section class="card">
      <h2 class="cardTitle">Kirim Dokumen</h2>
      <div class="muted">Pilih queue printer, unggah dokumen, lalu kirim satu kali. Cocok untuk Android, iPhone, atau user yang tidak ingin add printer manual.</div>
      <div class="hintBox" id="portalMeta">Loading portal info...</div>
      <div class="grid">
        <div>
          <label for="printQueueSelect">Queue CUPS</label>
          <select id="printQueueSelect" onchange="updatePrintUriHint()"></select>
        </div>
        <div>
          <label for="printFileInput">File</label>
          <input id="printFileInput" type="file" accept=".pdf,.png,.jpg,.jpeg,.txt"/>
        </div>
        <div>
          <label for="printTitleInput">Judul Job</label>
          <input id="printTitleInput" type="text" placeholder="Opsional, mis. Invoice-Cabang-A"/>
        </div>
        <div>
          <label for="printRequesterInput">Label User/Cabang</label>
          <input id="printRequesterInput" type="text" placeholder="Opsional, mis. Cabang Surabaya"/>
        </div>
        <div>
          <label for="printCopiesInput">Copies</label>
          <input id="printCopiesInput" type="number" min="1" max="20" value="1"/>
        </div>
      </div>
      <div class="mini" id="printUriHint">Universal IPP URI akan tampil setelah queue dimuat.</div>
      <button id="printSubmitBtn" style="margin-top:14px;" onclick="submitPrintJob()">Print Now</button>
      <div class="resultBox" id="submitResult" style="display:none;"></div>
    </section>
  </div>

<script>
const REMOTE_PRINT_HOST_HINT = "{{REMOTE_PRINT_HOST_HINT}}";
const WEB_PRINT_ALLOWED_LABEL = "{{WEB_PRINT_ALLOWED_LABEL}}";
const WEB_PRINT_MAX_MB = Number("{{WEB_PRINT_MAX_MB}}") || 25;

function safeText(v) {
  if (v === null || v === undefined) return "-";
  return String(v).replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

function api(path, options) {
  return fetch(path, options || {}).then(async res => {
    const data = await res.json();
    if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
    return data;
  });
}

function printUriForQueue(queue) {
  if (!REMOTE_PRINT_HOST_HINT || !queue) return "";
  return `ipp://${REMOTE_PRINT_HOST_HINT}/printers/${queue}`;
}

function setResult(level, message) {
  const box = document.getElementById("submitResult");
  box.style.display = "block";
  box.className = `resultBox ${level || ""}`.trim();
  box.innerHTML = message;
}

function updatePortalMeta() {
  const meta = document.getElementById("portalMeta");
  let text = `Allowed file: ${WEB_PRINT_ALLOWED_LABEL} | Max size: ${WEB_PRINT_MAX_MB} MB.`;
  if (REMOTE_PRINT_HOST_HINT) {
    text += ` Endpoint universal host: ${REMOTE_PRINT_HOST_HINT}.`;
  } else {
    text += " Host universal belum diset. Minta admin untuk mengisi TS_HOSTNAME atau REMOTE_PRINT_HOST_HINT.";
  }
  meta.innerText = text;
}

function updatePrintUriHint() {
  const select = document.getElementById("printQueueSelect");
  const hint = document.getElementById("printUriHint");
  const queue = select.value;
  if (!queue) {
    hint.innerText = "Queue CUPS belum tersedia. Hubungi admin jika printer belum muncul.";
    return;
  }
  const uri = printUriForQueue(queue);
  hint.innerText = uri
    ? `Manual IPP URI: ${uri}`
    : `Queue aktif: ${queue}. Host universal belum diset.`;
}

async function loadQueues() {
  updatePortalMeta();
  try {
    const data = await api("/printers");
    const select = document.getElementById("printQueueSelect");
    const queues = (data.printers || []).filter(p => String(p.source || "").toLowerCase() === "cups");
    select.innerHTML = "";
    if (!queues.length) {
      const opt = document.createElement("option");
      opt.value = "";
      opt.textContent = "No CUPS queue available yet";
      select.appendChild(opt);
      select.disabled = true;
      updatePrintUriHint();
      return;
    }
    queues.forEach(q => {
      const opt = document.createElement("option");
      opt.value = q.name;
      opt.textContent = q.name;
      select.appendChild(opt);
    });
    select.disabled = false;
    updatePrintUriHint();
  } catch (err) {
    setResult("red", `Gagal memuat queue printer: ${safeText(err.message)}`);
  }
}

async function submitPrintJob() {
  const queue = document.getElementById("printQueueSelect").value;
  const fileInput = document.getElementById("printFileInput");
  const title = document.getElementById("printTitleInput").value.trim();
  const requester = document.getElementById("printRequesterInput").value.trim();
  const copies = document.getElementById("printCopiesInput").value || "1";
  const btn = document.getElementById("printSubmitBtn");

  if (!queue) {
    setResult("red", "Queue CUPS belum tersedia.");
    return;
  }
  if (!fileInput.files || !fileInput.files.length) {
    setResult("red", "Pilih file yang ingin dicetak lebih dulu.");
    return;
  }

  const form = new FormData();
  form.append("printer", queue);
  form.append("title", title);
  form.append("requester", requester);
  form.append("copies", copies);
  form.append("file", fileInput.files[0]);

  btn.disabled = true;
  btn.innerText = "Submitting...";
  setResult("yellow", "Mengirim job print ke CUPS...");
  try {
    const data = await api("/print/submit", {method: "POST", body: form});
    fileInput.value = "";
    document.getElementById("printTitleInput").value = "";
    document.getElementById("printRequesterInput").value = "";
    document.getElementById("printCopiesInput").value = "1";
    const jobInfo = data.job_id ? `<br/><b>Job ID:</b> ${safeText(data.job_id)}` : "";
    setResult("green", `Dokumen berhasil dikirim ke queue <b>${safeText(data.printer)}</b>.${jobInfo}`);
  } catch (err) {
    setResult("red", `Print submit gagal: ${safeText(err.message)}`);
  } finally {
    btn.disabled = false;
    btn.innerText = "Print Now";
  }
}

loadQueues();
</script>
</body>
</html>
""".replace("{{REMOTE_PRINT_HOST_HINT}}", REMOTE_PRINT_HOST_HINT) \
   .replace("{{WEB_PRINT_ALLOWED_LABEL}}", ", ".join(ext.upper() for ext in WEB_PRINT_ALLOWED_EXTS)) \
   .replace("{{WEB_PRINT_MAX_MB}}", str(WEB_PRINT_MAX_MB))

# ==========================
# MAPPING / TARGET RESOLVE
# ==========================
def resolve_printer_target(printer_uri, printer_name=None):

    # IPP (LAN printer)
    if printer_uri.startswith("ipp://"):
        info = parse_ipp_uri(printer_uri)
        if info:
            resolved_host = resolve_local_service_host(info["host"])
            return {
                "type": "ipp",
                "host": resolved_host,
                "port": info["port"],
                "uri": printer_uri,
                "note": "IPP printer" if resolved_host == info["host"] else f"IPP printer via {resolved_host}",
                "original_host": info["host"],
                "fallback_ports": []
            }

    # USB → map ke ipp-usb
    if printer_uri.startswith("usb://"):
        mapped = map_printers_to_ports()

        for m in mapped:
            if m["name"] == printer_name and m["mapped_port"]:
                mapped_uri = m.get("mapped_uri") or ""
                mapped_info = parse_ipp_uri(mapped_uri) if mapped_uri else None
                mapped_host = resolve_local_service_host(mapped_info["host"] if mapped_info else "127.0.0.1")
                return {
                    "type": "ipp-usb-mapped",
                    "host": mapped_host,
                    "port": m["mapped_port"],
                    "uri": build_ipp_uri(mapped_host, m["mapped_port"], mapped_info["path"] if mapped_info else "/ipp/print"),
                    "note": f"Mapped via ippfind ({m['model']})",
                    "fallback_targets": scan_ippusb_targets(),
                    "fallback_ports": scan_all_ippusb_ports()
                }

        targets = scan_ippusb_targets()
        if targets:
            primary = targets[0]
            return {
                "type": "ipp-usb-fallback",
                "host": primary["host"],
                "port": primary["port"],
                "uri": primary["uri"],
                "note": "Fallback (no mapping match)",
                "fallback_targets": targets,
                "fallback_ports": [t["port"] for t in targets]
            }
        return {
            "type": "usb-waiting-ippusb",
            "host": None,
            "port": None,
            "uri": printer_uri,
            "note": "USB Epson terdeteksi, menunggu ipp-usb siap",
            "fallback_targets": [],
            "fallback_ports": []
        }

    return {
        "type": "unknown",
        "host": None,
        "port": None,
        "uri": printer_uri,
        "note": "Unknown",
        "fallback_ports": []
    }

def build_printer_context(printer_name, requested_model=None):
    record = get_printer_record(printer_name)
    if not record:
        return None

    target = resolve_printer_target(record.get("uri", ""), printer_name)
    if record.get("source") and record.get("source") != "cups":
        extra_note = record.get("note") or record.get("source")
        target["note"] = " | ".join([x for x in [target.get("note"), extra_note] if x])

    return {
        "record": record,
        "model": resolve_model_name(requested_model, record),
        "target": target
    }

def build_debug_snapshot():
    raw_cups = get_cups_printers_raw()
    deduped_cups = get_cups_printers()
    available = get_available_printers()
    printer_states = []

    for record in available[:10]:
        name = record.get("name")
        ctx = build_printer_context(name)
        if not ctx:
            continue
        status = get_cached_status(name, ctx["model"], dict(ctx["target"]))
        printer_states.append({
            "name": name,
            "model": ctx["model"],
            "record": record,
            "target": ctx["target"],
            "status": status
        })

    return {
        "ok": True,
        "generated_at": now(),
        "webui_mode": WEBUI_MODE,
        "webui_debug": WEBUI_DEBUG,
        "runtime": detect_runtime(),
        "cups_server": cups_server_endpoint(),
        "cups_raw": raw_cups,
        "cups_deduped": deduped_cups,
        "available_printers": available,
        "usb_devices": get_lsusb_list(),
        "ippusb": get_ippusb_service_info(),
        "reinkpy_meta": get_reinkpy_meta(),
        "reinkpy_usb_capabilities": inspect_reinkpy_usb_capabilities(),
        "recent_activity_log": read_json_file(LOG_FILE, [])[:40],
        "recent_print_portal_log": read_json_file(PRINT_AUDIT_FILE, [])[:20],
        "printer_states": printer_states,
    }

@app.before_request
def enforce_webui_mode():
    endpoint = request.endpoint or ""
    if WEBUI_MODE == "portal" and endpoint not in PORTAL_ALLOWED_ENDPOINTS:
        abort(404)

# ==========================
# ROUTES
# ==========================
@app.route("/")
def home():
    page = PORTAL_HTML if WEBUI_MODE == "portal" else HTML
    return render_template_string(page)

@app.route("/favicon.ico")
def favicon():
    # Return an empty favicon response to keep browser console clean during local debugging.
    return "", 204

@app.route("/printers")
def printers():
    return jsonify({"printers": get_available_printers()})

@app.route("/usb")
def usb():
    return jsonify(get_lsusb_list())

@app.route("/ippusb")
def ippusb():
    return jsonify(get_ippusb_service_info())

@app.route("/ipp_ports")
def ipp_ports():
    targets = scan_ippusb_targets()
    return jsonify({
        "ok": True,
        "ports": [t["port"] for t in targets],
        "targets": targets
    })

@app.route("/logs")
def logs():
    return jsonify({
        "ok": True,
        "logs": read_json_file(LOG_FILE, [])
    })

@app.route("/debug/snapshot")
def debug_snapshot():
    if not WEBUI_DEBUG:
        return jsonify({"ok": False, "error": "WEBUI_DEBUG belum aktif"}), 404
    return jsonify(build_debug_snapshot())

@app.route("/debug/reink_usb")
def debug_reink_usb():
    if not WEBUI_DEBUG:
        return jsonify({"ok": False, "error": "WEBUI_DEBUG belum aktif"}), 404
    return jsonify(inspect_reinkpy_usb_capabilities())

@app.route("/print_jobs")
def print_jobs():
    return jsonify({
        "ok": True,
        "entries": read_recent_print_jobs(limit=request.args.get("limit", "60"))
    })

@app.route("/dashboard/summary")
def dashboard_summary():
    try:
        limit = max(40, min(800, int(request.args.get("limit", "400"))))
    except Exception:
        limit = 400

    payload = build_print_job_summary(limit=limit)
    payload["overview"]["detected_printers"] = len(get_available_printers())
    return jsonify(payload)

@app.route("/print/submit", methods=["POST"])
def print_submit():
    if not WEB_PRINT_ENABLED:
        return jsonify({"ok": False, "error": "Web print portal dinonaktifkan"}), 404

    printer = str(request.form.get("printer", "")).strip()
    title_input = str(request.form.get("title", "")).strip()
    requester = sanitize_log_token(request.form.get("requester", ""), limit=48)
    copies = parse_int(request.form.get("copies", "1"), default=1, minimum=1, maximum=20)
    upload = request.files.get("file")

    if not printer:
        return jsonify({"ok": False, "error": "Printer wajib dipilih"}), 400
    if upload is None or not getattr(upload, "filename", ""):
        return jsonify({"ok": False, "error": "File belum dipilih"}), 400
    if not allowed_upload(upload.filename):
        allowed = ", ".join(ext.upper() for ext in WEB_PRINT_ALLOWED_EXTS)
        return jsonify({"ok": False, "error": f"Format file tidak didukung. Gunakan: {allowed}"}), 400

    max_bytes = WEB_PRINT_MAX_MB * 1024 * 1024
    if request.content_length and request.content_length > max_bytes + (512 * 1024):
        return jsonify({"ok": False, "error": f"Ukuran file melebihi {WEB_PRINT_MAX_MB} MB"}), 413

    cupsd_printers = {p.get("name") for p in get_cups_printers() if p.get("name")}
    if printer not in cupsd_printers:
        return jsonify({"ok": False, "error": f"Queue CUPS '{printer}' tidak ditemukan"}), 404

    tmp_dir = tempfile.mkdtemp(prefix="stb-web-print-")
    saved_path = None

    try:
        original_name = upload.filename or "upload.bin"
        safe_name = secure_filename(original_name) or f"print-upload-{int(time.time())}"
        saved_path = os.path.join(tmp_dir, safe_name)
        upload.save(saved_path)

        actual_size = os.path.getsize(saved_path)
        if actual_size > max_bytes:
            return jsonify({"ok": False, "error": f"Ukuran file melebihi {WEB_PRINT_MAX_MB} MB"}), 413

        request_ip = get_client_ip()
        title = sanitize_log_token(title_input or os.path.splitext(original_name)[0], limit=72) or "web_print"
        billing = sanitize_log_token(f"{requester}@{request_ip}" if requester else request_ip, limit=72) or "web_print"

        cmd = [
            "lp",
            "-h", cups_server_endpoint(),
            "-d", printer,
            "-n", str(copies),
            "-t", title,
            "-o", f"job-billing={billing}",
            saved_path,
        ]
        res = run_cmd_list(cmd, timeout=90)
        if res["returncode"] != 0:
            err_detail = res.get("stderr") or res.get("stdout") or "lp submit failed"
            log_activity(action="PRINT_SUBMIT", printer=printer, result="FAIL", detail=err_detail)
            return jsonify({"ok": False, "error": err_detail}), 500

        lp_output = " ".join([res.get("stdout") or "", res.get("stderr") or ""]).strip()
        match = re.search(r"request id is\\s+([^\\s]+)", lp_output, re.IGNORECASE)
        job_id = match.group(1) if match else None

        audit_entry = {
            "time": now(),
            "job_id": job_id,
            "printer": printer,
            "request_ip": request_ip,
            "requester": requester or None,
            "filename": original_name,
            "title": title,
            "copies": copies,
            "billing": billing,
            "source": "web-portal"
        }
        append_portal_audit(audit_entry)
        log_activity(
            action="PRINT_SUBMIT",
            printer=printer,
            result="OK",
            detail=f"job={job_id or '-'} file={original_name} copies={copies} via={request_ip}"
        )
        return jsonify({
            "ok": True,
            "printer": printer,
            "job_id": job_id,
            "title": title,
            "copies": copies,
            "request_ip": request_ip,
            "output": lp_output
        })
    finally:
        try:
            if saved_path and os.path.exists(saved_path):
                os.remove(saved_path)
        except Exception:
            pass
        try:
            if os.path.isdir(tmp_dir):
                os.rmdir(tmp_dir)
        except Exception:
            pass

@app.route("/reinkpy/version")
def reinkpy_version():
    return jsonify(get_reinkpy_meta())

@app.route("/reinkpy/check_update")
def reinkpy_check_update():
    notify = request.args.get("notify", "1") == "1"
    return jsonify(check_reinkpy_update(notify=notify))

@app.route("/reinkpy/sources")
def reinkpy_sources():
    return jsonify(get_reinkpy_meta())

@app.route("/reinkpy/switch_source", methods=["POST"])
def reinkpy_switch_source():
    try:
        body = request.get_json(silent=True) or {}
        mode = normalize_source_mode(body.get("mode", "auto"))
        source = str(body.get("source", "ui"))[:40]
        res = apply_reinkpy_source(mode, set_by=source, persist=True)
        if not res.get("ok"):
            log_activity(action="REINKPY_SWITCH", result="FAIL", detail=str(res.get("error")))
            return jsonify(res), 400
        msg = (
            f"🔧 [STB REINKPY] Source switch\\n"
            f"Mode: {mode}\\n"
            f"Effective: {res.get('effective_source')}\\n"
            f"By: {source}\\n"
            f"Time: {now()}"
        )
        tg_send(msg)
        log_activity(action="REINKPY_SWITCH", result="OK", detail=f"{mode}->{res.get('effective_source')}")
        return jsonify(res)
    except Exception as e:
        log_activity(action="REINKPY_SWITCH", result="FAIL", detail=str(e))
        return jsonify({"ok": False, "error": str(e)}), 500

@app.route("/reinkpy/restore_source", methods=["POST"])
def reinkpy_restore_source():
    try:
        ov = read_reinkpy_override()
        restore_mode = normalize_source_mode(ov.get("previous_mode", "auto"))
        body = request.get_json(silent=True) or {}
        source = str(body.get("source", "ui"))[:40]
        res = apply_reinkpy_source(restore_mode, set_by=f"{source}-restore", persist=True)
        if not res.get("ok"):
            log_activity(action="REINKPY_RESTORE", result="FAIL", detail=str(res.get("error")))
            return jsonify(res), 400
        tg_send(
            f"↩️ [STB REINKPY] Restore source\\n"
            f"Mode: {restore_mode}\\n"
            f"Effective: {res.get('effective_source')}\\n"
            f"Time: {now()}"
        )
        log_activity(action="REINKPY_RESTORE", result="OK", detail=f"restore->{restore_mode}")
        return jsonify(res)
    except Exception as e:
        log_activity(action="REINKPY_RESTORE", result="FAIL", detail=str(e))
        return jsonify({"ok": False, "error": str(e)}), 500

@app.route("/reinkpy/update_status")
def reinkpy_update_status():
    lines = request.args.get("lines", "120")
    status = read_update_status()
    logs = tail_update_progress(lines)
    busy = status.get("state") in {"queued", "running"}
    return jsonify({
        "ok": True,
        "busy": busy,
        "status": status,
        "logs": logs
    })

@app.route("/reinkpy/apply_update", methods=["POST"])
def reinkpy_apply_update():
    try:
        body = request.get_json(silent=True) or {}
        source = str(body.get("source", "ui"))[:40]
        req_id = datetime.now().strftime("%Y%m%d%H%M%S")
        payload = {
            "requested_at": now(),
            "requested_ip": request.remote_addr,
            "source": source,
            "request_id": req_id
        }
        write_json_file(UPDATE_REQUEST_FILE, payload)
        write_update_status(
            state="queued",
            progress=10,
            message="Update request diterima. Menunggu daemon host...",
            request_id=req_id,
            source=source,
            started_at=None,
            finished_at=None
        )
        append_update_progress(f"Request queued from {request.remote_addr} via {source} (req={req_id})")
        tg_send(f"🛠 [STB UPDATE] Manual update request diterima dari {request.remote_addr} ({now()})")
        log_activity(action="MANUAL_REINKPY_UPDATE", result="OK", detail=str(payload))
        return jsonify({
            "ok": True,
            "queued": True,
            "request_id": req_id,
            "message": "Update request queued on host automation daemon"
        })
    except Exception as e:
        write_update_status(state="failed", progress=100, message=f"Gagal queue update: {e}", finished_at=now())
        append_update_progress(f"Failed to queue update: {e}")
        log_activity(action="MANUAL_REINKPY_UPDATE", result="FAIL", detail=str(e))
        return jsonify({"ok": False, "error": str(e)}), 500

@app.route("/lockstate")
def lockstate():
    return jsonify(get_lock_state())

@app.route("/lock")
def lock():
    printer = request.args.get("printer", "")
    if not printer:
        return jsonify({"ok": False, "error": "Missing printer"}), 400
    set_lock(printer)
    return jsonify({"ok": True, "locked": True, "printer": printer})

@app.route("/unlock")
def unlock():
    clear_lock()
    return jsonify({"ok": True, "locked": False})
    
@app.route("/status")
def status():
    printer = request.args.get("printer", "")

    if not printer:
        return jsonify({"ok": False, "error": "Missing printer"}), 400

    lock = get_lock_state()
    if lock["locked"] and lock["printer"] != printer:
        return jsonify({"ok": False, "error": f"LOCKED by {lock['printer']}"}), 403

    ctx = build_printer_context(printer, request.args.get("model"))
    if not ctx:
        return jsonify({"ok": False, "error": "Printer not found in CUPS/USB"}), 404

    target = ctx["target"]
    parsed = get_cached_status(printer, ctx["model"], target)
    return jsonify(parsed)

@app.route("/clean")
def clean():
    printer = request.args.get("printer", "")
    engine = request.args.get("engine", "auto")
    power = request.args.get("power", "0") == "1"

    if not printer:
        return jsonify({"ok": False, "error": "Missing printer"}), 400

    lock = get_lock_state()
    if lock["locked"] and lock["printer"] != printer:
        return jsonify({"ok": False, "error": f"LOCKED by {lock['printer']}"}), 403

    ctx = build_printer_context(printer, request.args.get("model"))
    if not ctx:
        return jsonify({"ok": False, "error": "Printer not found"}), 404

    target = ctx["target"]
    res = run_clean(engine, target, power)

    if not res["ok"]:
        return jsonify({"ok": False, "error": res.get("error", "")})

    return jsonify({"ok": True, "engine": res.get("engine"), "power": power})
        
@app.route("/api/ink_status")
def api_ink_status():
    printer = request.args.get("printer","")
    ctx = build_printer_context(printer, request.args.get("model"))
    if not ctx:
        return jsonify({"ok": False, "error": "Printer not found"})

    target = ctx["target"]

    if target.get("host") and is_ip(target["host"]) and target["host"] not in {"127.0.0.1", "localhost"}:
        sn = snmp_status(target["host"])
        return jsonify(sn)

    parsed = get_cached_status(printer, ctx["model"], target)
    if not parsed.get("ok"):
        return jsonify({"ok": False, "error": parsed.get("error", "Ink status unavailable"), "target": target})
    return jsonify({
        "ok": True,
        "mode": "status-fallback",
        "ink": parsed.get("ink", {}),
        "waste": parsed.get("waste"),
        "raw": parsed.get("raw"),
        "target": target
    }) 
    
@app.route("/api/reset_waste", methods=["POST"])
def api_reset_waste():
    data = request.get_json()
    printer = data.get("printer","")

    lock = get_lock_state()
    if lock["locked"] and lock["printer"] != printer:
        return jsonify({"ok": False, "error": "LOCKED"})

    set_lock(printer)

    ctx = build_printer_context(printer, data.get("model"))
    if not ctx:
        clear_lock()
        return jsonify({"ok": False, "error": "Printer not found"})

    target = ctx["target"]
    res = reink_reset_waste(target)

    clear_lock()

    return jsonify({"ok": res.get("ok"), "engine": res.get("engine"), "error": res.get("error")})   
    
@app.route("/v7/nozzle")
def v7_nozzle():
    printer = request.args.get("printer", "")
    engine = request.args.get("engine", "reinkpy")
    _agent_debug_log("H1", "v7_nozzle", "entry", {"printer": printer, "engine": engine, "model": request.args.get("model")})

    ctx = build_printer_context(printer, request.args.get("model"))
    if not ctx:
        return jsonify({"ok": False, "error": "Printer not found"})

    target = ctx["target"]

    res = run_nozzle(engine, target)
    _agent_debug_log("H1", "v7_nozzle", "result", {"ok": bool(res.get("ok")), "engine": res.get("engine"), "error": res.get("error")})
    log_activity(
        action="NOZZLE",
        printer=printer,
        result="OK" if res.get("ok") else "FAIL",
        detail=res.get("error")
    )
    return jsonify({
        "printer": printer,
        "engine": engine,
        "target": target,
        **res
    })

@app.route("/v7/clean")
def v7_clean():
    printer = request.args.get("printer", "")
    engine = request.args.get("engine", "reinkpy")
    power = request.args.get("power", "0") == "1"
    _agent_debug_log("H2", "v7_clean", "entry", {"printer": printer, "engine": engine, "power": power, "model": request.args.get("model")})

    ctx = build_printer_context(printer, request.args.get("model"))
    if not ctx:
        return jsonify({"ok": False, "error": "Printer not found"})

    target = ctx["target"]

    res = run_clean(engine, target, power)
    _agent_debug_log("H2", "v7_clean", "result", {"ok": bool(res.get("ok")), "engine": res.get("engine"), "error": res.get("error")})
    log_activity(
        action="CLEAN",
        printer=printer,
        result="OK" if res.get("ok") else "FAIL",
        detail=res.get("error")
    )
    return jsonify({
        "printer": printer,
        "engine": engine,
        "power": power,
        "target": target,
        **res
    })       
    
@app.route("/v7/reset_waste", methods=["POST"])
def v7_reset_waste():
    data = request.get_json() or {}
    printer = data.get("printer", "")
    confirm = data.get("confirm", False)
    _agent_debug_log("H3", "v7_reset_waste", "entry", {"printer": printer, "confirm": bool(confirm), "model": data.get("model")})

    if not confirm:
        return jsonify({
            "ok": False,
            "error": "Confirmation required"
        })

    ctx = build_printer_context(printer, data.get("model"))
    if not ctx:
        return jsonify({"ok": False, "error": "Printer not found"})

    target = ctx["target"]

    res = reink_reset_waste(target)
    _agent_debug_log("H3", "v7_reset_waste", "result", {"ok": bool(res.get("ok")), "engine": res.get("engine"), "error": res.get("error")})
    log_activity(
        action="RESET_WASTE",
        printer=printer,
        result="OK" if res.get("ok") else "FAIL"
    )
    return jsonify({
        "printer": printer,
        **res
    })

def monitor_printers_once():
    printers = get_available_printers()
    if len(printers) == 0:
        return

    for p in printers:
        pname = p.get("name")
        puri = p.get("uri")
        if not pname or not puri:
            continue
        try:
            ctx = build_printer_context(pname)
            if not ctx:
                continue
            get_cached_status(pname, ctx["model"], ctx["target"])
        except Exception as e:
            tg_send(f"🟡 [STB MONITOR]\\nMonitor gagal untuk {pname}: {e}\\nTime: {now()}")

def background_monitor_loop():
    interval = max(60, int(MONITOR_INTERVAL_SECONDS))
    while True:
        try:
            monitor_printers_once()
        except Exception as e:
            tg_send(f"🟡 [STB MONITOR]\\nBackground monitor error: {e}\\nTime: {now()}")
        time.sleep(interval)
    
# ==========================
# MAIN
# ==========================
if __name__ == "__main__":
    try:
        boot_mode = read_reinkpy_override().get("mode", "auto")
        apply_reinkpy_source(boot_mode, set_by="boot", persist=False)
    except Exception:
        pass
    if os.getenv("REINKPY_AUTO_CHECK_ON_START", "yes").strip().lower() == "yes":
        try:
            check_reinkpy_update(notify=True)
        except Exception:
            pass
    if ENABLE_BACKGROUND_MONITOR:
        try:
            t = threading.Thread(target=background_monitor_loop, daemon=True)
            t.start()
        except Exception:
            pass
    app.run(host="0.0.0.0", port=WEB_LISTEN_PORT)
EOF

  if [[ "$ENABLE_EPSON_WEBUI" == "yes" ]]; then

    IMAGE_NAME="epson-unified-hub"

    if [[ "$FORCE_RESET_WEBUI" == "yes" ]]; then
        if confirm_yes_no "FORCE_RESET_WEBUI aktif. Hapus container/image epson-unified-hub?" "no"; then
            docker rm -f epson-unified-hub >/dev/null 2>&1 || true
            docker rm -f "$PRINT_PORTAL_CONTAINER_NAME" >/dev/null 2>&1 || true
            docker rmi -f "$IMAGE_NAME" >/dev/null 2>&1 || true
        else
            warn "Skip reset WebUI karena dibatalkan user."
        fi
    fi

    if guard_network_or_skip "build Maintenance Tools image"; then
        log "Build Maintenance Tools image..."
        if ! docker build \
          --build-arg REINKPY_SOURCE_MODE="${REINKPY_SOURCE_MODE}" \
          --build-arg REINKPY_FIX_STALE_DAYS="${REINKPY_FIX_STALE_DAYS}" \
          -t "$IMAGE_NAME" "$WEBUI_DIR" >/dev/null; then
            warn "Build Maintenance Tools gagal (kemungkinan registry atau dependency Python). Mencoba pre-pull base image..."
            docker pull python:3.11-slim >/dev/null 2>&1 || true
            if ! docker build \
              --build-arg REINKPY_SOURCE_MODE="${REINKPY_SOURCE_MODE}" \
              --build-arg REINKPY_FIX_STALE_DAYS="${REINKPY_FIX_STALE_DAYS}" \
              -t "$IMAGE_NAME" "$WEBUI_DIR" >/dev/null; then
                if docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
                    warn "Build tetap gagal, tapi image ${IMAGE_NAME} cache lokal tersedia. Lanjut deploy pakai cache."
                else
                    die "Build Maintenance Tools gagal dan image cache tidak ada. Cek koneksi registry dan dependency Python pada Dockerfile."
                fi
            fi
        fi
    else
        warn "Offline guard: build image WebUI dilewati."
    fi

    if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
        warn "Image $IMAGE_NAME belum tersedia. Skip deploy WebUI sampai internet kembali."
    else

    WEBUI_PORT="${WEBUI_PORT:-5000}"
    WEBUI_NETWORK_MODE_EFFECTIVE="$(printf '%s' "${WEBUI_NETWORK_MODE:-host}" | tr '[:upper:]' '[:lower:]')"
    [[ "$WEBUI_NETWORK_MODE_EFFECTIVE" != "host" ]] && WEBUI_NETWORK_MODE_EFFECTIVE="bridge"
    WEBUI_CUPS_HOST="$CUPS_SERVER_HOST"
    WEBUI_LOCAL_SERVICE_HOST="$CUPS_SERVER_HOST"
    WEBUI_NET_ARGS=(--add-host host.docker.internal:host-gateway -p "${WEBUI_PORT}:5000")
    if [[ "$WEBUI_NETWORK_MODE_EFFECTIVE" == "host" ]]; then
      WEBUI_CUPS_HOST="127.0.0.1"
      WEBUI_LOCAL_SERVICE_HOST="127.0.0.1"
      WEBUI_NET_ARGS=(--network host)
      log "Maintenance Tools network mode: host"
    else
      log "Maintenance Tools network mode: bridge (${WEBUI_CUPS_HOST})"
    fi
    if is_port_used "$WEBUI_PORT"; then
      warn "Port ${WEBUI_PORT} terpakai sebelum deploy. Bersihkan sisa instalasi lama..."
      force_release_port "$WEBUI_PORT" || die "Port ${WEBUI_PORT} tidak bisa dibebaskan"
    fi

    docker rm -f epson-unified-hub >/dev/null 2>&1 || true

    WEBUI_RUN_OK="no"
    for _try in $(seq 1 8); do
      RUN_ERR="$(
    docker run -d \
          --name epson-unified-hub \
          --restart unless-stopped \
          "${WEBUI_NET_ARGS[@]}" \
          -e SNMP_WRITE="$SNMP_WRITE" \
          -e TELEGRAM_TOKEN="$TELEGRAM_TOKEN" \
          -e TELEGRAM_CHAT_ID="$TELEGRAM_CHAT_ID" \
          -e CUPS_SERVER_HOST="$WEBUI_CUPS_HOST" \
          -e CUPS_SERVER_PORT="$CUPS_PORT" \
          -e WEBUI_MODE="unified" \
          -e WEB_LISTEN_PORT="$WEBUI_PORT" \
          -e WEBUI_DEBUG="$WEBUI_DEBUG" \
          -e WEBUI_NETWORK_MODE="$WEBUI_NETWORK_MODE_EFFECTIVE" \
          -e LOCAL_SERVICE_HOST="$WEBUI_LOCAL_SERVICE_HOST" \
          -e WEB_PRINT_ENABLED="yes" \
          -e WEB_PRINT_MAX_MB="$WEB_PRINT_MAX_MB" \
          -e WEB_PRINT_ALLOWED_EXTS="$WEB_PRINT_ALLOWED_EXTS" \
          -e REMOTE_PRINT_HOST_HINT="$REMOTE_PRINT_HOST_HINT" \
          -e CUPS_PAGE_LOG_PATH="${PERSIST_ROOT}/cups/log/page_log" \
          -e PRINT_AUDIT_FILE="${PERSIST_ROOT}/print_portal_audit.json" \
          -e ENABLE_WHATSAPP="$ENABLE_WHATSAPP" \
          -e WA_PROVIDER="$WA_PROVIDER" \
          -e WA_GRAPH_VERSION="$WA_GRAPH_VERSION" \
          -e WA_TOKEN="$WA_TOKEN" \
          -e WA_PHONE_NUMBER_ID="$WA_PHONE_NUMBER_ID" \
          -e WA_TO="$WA_TO" \
          -e WA_MESSAGE_TYPE="$WA_MESSAGE_TYPE" \
          -e WA_TEMPLATE_NAME="$WA_TEMPLATE_NAME" \
          -e WA_TEMPLATE_LANG="$WA_TEMPLATE_LANG" \
          -e TELEGRAM_ACTIVITY_NOTIFY="$TELEGRAM_ACTIVITY_NOTIFY" \
          -e REINKPY_NOTIFY_HOURS="$REINKPY_NOTIFY_HOURS" \
          -e REINKPY_AUTO_CHECK_ON_START="$REINKPY_AUTO_CHECK_ON_START" \
          -e REINKPY_SOURCE_MODE="$REINKPY_SOURCE_MODE" \
          -e REINKPY_FIX_STALE_DAYS="$REINKPY_FIX_STALE_DAYS" \
          -e WASTE_WARN_THRESHOLD="$WASTE_WARN_THRESHOLD" \
          -e WASTE_ALERT_THRESHOLD="$WASTE_ALERT_THRESHOLD" \
          -e WASTE_RECOVER_THRESHOLD="$WASTE_RECOVER_THRESHOLD" \
          -e INK_WARN_THRESHOLD="$INK_WARN_THRESHOLD" \
          -e INK_CRITICAL_THRESHOLD="$INK_CRITICAL_THRESHOLD" \
          -e INK_RECOVER_THRESHOLD="$INK_RECOVER_THRESHOLD" \
          -e ENABLE_BACKGROUND_MONITOR="$ENABLE_BACKGROUND_MONITOR" \
          -e MONITOR_INTERVAL_SECONDS="$MONITOR_INTERVAL_SECONDS" \
          -v "${PERSIST_ROOT}:${PERSIST_ROOT}" \
          -v /dev/bus/usb:/dev/bus/usb \
          --privileged \
          "$IMAGE_NAME" 2>&1
      )"
      if [[ $? -eq 0 ]]; then
        WEBUI_RUN_OK="yes"
        break
      fi
      if echo "$RUN_ERR" | grep -qi "port is already allocated"; then
        warn "Port ${WEBUI_PORT} bentrok saat deploy. Force cleanup lalu retry..."
        docker rm -f epson-unified-hub >/dev/null 2>&1 || true
        force_release_port "$WEBUI_PORT" || true
        sleep 1
        continue
      fi
      err "$RUN_ERR"
      break
    done

    [[ "$WEBUI_RUN_OK" == "yes" ]] || die "Run Maintenance Tools gagal"

   if ! docker ps --format '{{.Names}}' | grep -q '^epson-unified-hub$'; then
    die "Container gagal jalan"
   fi

    echo "http://${IP_LAN}:${WEBUI_PORT}" > "${CASAOS_ROOT}/epson_webui_url.txt"
    log "Maintenance Tools URL: http://${IP_LAN}:${WEBUI_PORT}"
    log "WebUI Patch V7 aktif."

    if [[ "$WEB_PRINT_ENABLED" == "yes" ]]; then
      WEB_PRINT_PORT="${WEB_PRINT_PORT:-3000}"
      if is_port_used "$WEB_PRINT_PORT"; then
        warn "Port ${WEB_PRINT_PORT} terpakai sebelum deploy Remote Print Portal. Bersihkan sisa instalasi lama..."
        force_release_port "$WEB_PRINT_PORT" || die "Port ${WEB_PRINT_PORT} tidak bisa dibebaskan"
      fi

      docker rm -f "$PRINT_PORTAL_CONTAINER_NAME" >/dev/null 2>&1 || true

      WEB_PRINT_CUPS_HOST="$CUPS_SERVER_HOST"
      WEB_PRINT_LOCAL_SERVICE_HOST="$CUPS_SERVER_HOST"
      WEB_PRINT_NET_ARGS=(--add-host host.docker.internal:host-gateway -p "${WEB_PRINT_PORT}:${WEB_PRINT_PORT}")
      if [[ "$WEBUI_NETWORK_MODE_EFFECTIVE" == "host" ]]; then
        WEB_PRINT_CUPS_HOST="127.0.0.1"
        WEB_PRINT_LOCAL_SERVICE_HOST="127.0.0.1"
        WEB_PRINT_NET_ARGS=(--network host)
      fi

      PORTAL_RUN_ERR="$(
        docker run -d \
          --name "$PRINT_PORTAL_CONTAINER_NAME" \
          --restart unless-stopped \
          "${WEB_PRINT_NET_ARGS[@]}" \
          -e CUPS_SERVER_HOST="$WEB_PRINT_CUPS_HOST" \
          -e CUPS_SERVER_PORT="$CUPS_PORT" \
          -e WEBUI_MODE="portal" \
          -e WEB_LISTEN_PORT="$WEB_PRINT_PORT" \
          -e WEBUI_DEBUG="no" \
          -e WEBUI_NETWORK_MODE="$WEBUI_NETWORK_MODE_EFFECTIVE" \
          -e LOCAL_SERVICE_HOST="$WEB_PRINT_LOCAL_SERVICE_HOST" \
          -e WEB_PRINT_ENABLED="yes" \
          -e WEB_PRINT_MAX_MB="$WEB_PRINT_MAX_MB" \
          -e WEB_PRINT_ALLOWED_EXTS="$WEB_PRINT_ALLOWED_EXTS" \
          -e REMOTE_PRINT_HOST_HINT="$REMOTE_PRINT_HOST_HINT" \
          -e CUPS_PAGE_LOG_PATH="${PERSIST_ROOT}/cups/log/page_log" \
          -e PRINT_AUDIT_FILE="${PERSIST_ROOT}/print_portal_audit.json" \
          -e ENABLE_BACKGROUND_MONITOR="no" \
          -e TELEGRAM_ACTIVITY_NOTIFY="no" \
          -v "${PERSIST_ROOT}:${PERSIST_ROOT}" \
          "$IMAGE_NAME" 2>&1
      )"
      [[ $? -eq 0 ]] || die "Run Remote Print Portal gagal: ${PORTAL_RUN_ERR}"

      if ! docker ps --format '{{.Names}}' | grep -q "^${PRINT_PORTAL_CONTAINER_NAME}$"; then
        die "Container Remote Print Portal gagal jalan"
      fi

      echo "http://${IP_LAN}:${WEB_PRINT_PORT}" > "${CASAOS_ROOT}/print_portal_url.txt"
      log "Remote Print Portal URL: http://${IP_LAN}:${WEB_PRINT_PORT}"
    else
      docker rm -f "$PRINT_PORTAL_CONTAINER_NAME" >/dev/null 2>&1 || true
      rm -f "${CASAOS_ROOT}/print_portal_url.txt" >/dev/null 2>&1 || true
    fi
    fi
   fi
fi
# -----------------------------------------------------------------
# IPP-USB (USB Printer -> IPP Network Emulation)
# -----------------------------------------------------------------
if [[ "${ENABLE_IPP_USB:-yes}" == "yes" ]]; then
    log "Menginstall ipp-usb untuk expose printer USB sebagai IPP..."

    if guard_network_or_skip "install ipp-usb package"; then
        apt-get update -y || warn "apt update ipp-usb gagal (lanjut)."
        apt-get install -y ipp-usb avahi-daemon cups-client || {
            err "Gagal install ipp-usb"
            tg_send "🚨 [STB ALERT] $(hostname): Gagal install ipp-usb"
            exit 1
        }
    else
        warn "Offline guard: install ipp-usb dilewati. Pakai package existing."
    fi

    systemctl enable --now avahi-daemon >/dev/null 2>&1 || true
    systemctl enable --now ipp-usb >/dev/null 2>&1 || true

    log "ipp-usb aktif. Printer USB akan diexpose sebagai IPP endpoint."
fi

# -----------------------------------------------------------------
# Deteksi IPP Enpoint
# -----------------------------------------------------------------
log "Mendeteksi IPP endpoint dari ipp-usb..."

IPP_ENDPOINT=$(timeout 5 ippfind 2>/dev/null | head -n 1 || true)

if [[ -n "$IPP_ENDPOINT" ]]; then
    log "IPP printer ditemukan: $IPP_ENDPOINT"
else
    warn "Belum ada printer IPP terdeteksi via ipp-usb (mungkin printer belum dicolok)."
fi

configure_cups_remote_access() {
    local cname="$1"
    local remote_admin_enabled="false"

    case "${CUPS_REMOTE_ADMIN:-no}" in
        yes|true|1|on) remote_admin_enabled="true" ;;
    esac

    docker exec "$cname" cupsctl --remote-any --share-printers >/dev/null 2>&1 \
        || warn "Gagal set cupsctl --remote-any --share-printers pada ${cname}."

    if [[ "$remote_admin_enabled" == "true" ]]; then
        docker exec "$cname" cupsctl --remote-admin >/dev/null 2>&1 \
            || warn "Gagal set cupsctl --remote-admin pada ${cname}."

        if [[ -n "${CUPS_REMOTE_ADMIN_ALLOW_NET:-}" ]]; then
            docker exec "$cname" sh -lc '
                conf="/etc/cups/cupsd.conf"
                allow_net="'"${CUPS_REMOTE_ADMIN_ALLOW_NET}"'"
                tmp="$(mktemp)"
                awk -v allow_net="$allow_net" '"'"'
                    function tracked_location(path) {
                        return path == "/" || path == "/admin" || path == "/admin/conf"
                    }
                    $1 == "<Location" {
                        in_location = 1
                        location_path = $2
                        gsub(">", "", location_path)
                        found_allow = 0
                    }
                    in_location && index($0, "Allow " allow_net) > 0 {
                        found_allow = 1
                    }
                    $1 == "</Location>" && in_location {
                        if (tracked_location(location_path) && !found_allow) {
                            print "  Allow " allow_net
                        }
                        print
                        in_location = 0
                        location_path = ""
                        found_allow = 0
                        next
                    }
                    { print }
                '"'"' "$conf" > "$tmp" && mv "$tmp" "$conf"
                cupsd_pid="$(cat /run/cups/cupsd.pid 2>/dev/null || pgrep cupsd | head -n1)"
                if [ -n "$cupsd_pid" ]; then
                    kill -HUP "$cupsd_pid"
                fi
            ' >/dev/null 2>&1 || warn "Gagal membatasi admin CUPS ke subnet ${CUPS_REMOTE_ADMIN_ALLOW_NET} pada ${cname}."
        fi
    else
        docker exec "$cname" cupsctl --no-remote-admin >/dev/null 2>&1 \
            || warn "Gagal set cupsctl --no-remote-admin pada ${cname}."
    fi
}

configure_cups_logging() {
    local cname="$1"
    local lookup_mode="Off"
    local page_log_format="PageLogFormat %p|%u|%j|%T|%P|%C|%{job-billing}|%{job-originating-host-name}|%{job-name}|%{media}|%{sides}"

    case "${CUPS_HOSTNAME_LOOKUPS:-off}" in
        yes|true|1|on) lookup_mode="On" ;;
        double) lookup_mode="Double" ;;
        *) lookup_mode="Off" ;;
    esac

    docker exec "$cname" sh -lc "
        conf='/etc/cups/cupsd.conf'
        grep -Eq '^[[:space:]]*AccessLogLevel[[:space:]]+' \"\$conf\" \
            && sed -Ei 's#^[[:space:]]*AccessLogLevel[[:space:]].*#AccessLogLevel all#' \"\$conf\" \
            || printf '%s\n' 'AccessLogLevel all' >> \"\$conf\"
        grep -Eq '^[[:space:]]*HostNameLookups[[:space:]]+' \"\$conf\" \
            && sed -Ei 's#^[[:space:]]*HostNameLookups[[:space:]].*#HostNameLookups ${lookup_mode}#' \"\$conf\" \
            || printf '%s\n' 'HostNameLookups ${lookup_mode}' >> \"\$conf\"
        grep -Eq '^[[:space:]]*PageLogFormat[[:space:]]+' \"\$conf\" \
            && sed -Ei 's#^[[:space:]]*PageLogFormat[[:space:]].*#${page_log_format//\#/\\#}#' \"\$conf\" \
            || printf '%s\n' '${page_log_format}' >> \"\$conf\"
        cupsd -t >/dev/null 2>&1
        cupsd_pid=\$(cat /run/cups/cupsd.pid 2>/dev/null || pgrep cupsd | head -n1)
        if [ -n \"\$cupsd_pid\" ]; then
            kill -HUP \"\$cupsd_pid\"
        fi
    " >/dev/null 2>&1 || warn "Gagal mengaktifkan audit log CUPS pada ${cname}."
}


# ============================================================
# CUPS Container
# ============================================================
if [[ "$ENABLE_CUPS" == "yes" ]]; then
    log "Menyiapkan CUPS..."
    ACTIVE_CUPS_IMG="$(resolve_cups_image | awk 'NF{last=$0} END{print last}')"
    [[ -n "${ACTIVE_CUPS_IMG}" ]] || die "Resolve CUPS image gagal (kosong)."
    log "CUPS image aktif: ${ACTIVE_CUPS_IMG}"

    if [[ "$FORCE_RESET_CUPS" == "yes" ]]; then
        if confirm_yes_no "FORCE_RESET_CUPS aktif. Hapus container CUPS existing?" "no"; then
            docker rm -f "$CUPS_CONTAINER_NAME" >/dev/null 2>&1 || true
            docker rm -f "$CUPS_LEGACY_CONTAINER_NAME" >/dev/null 2>&1 || true
            sleep 2
        else
            warn "Skip reset CUPS karena dibatalkan user."
        fi
    fi

    # migrasi nama lama -> nama resmi agar idempotent
    if docker ps -a --format '{{.Names}}' | grep -q "^${CUPS_LEGACY_CONTAINER_NAME}$"; then
        if ! docker ps -a --format '{{.Names}}' | grep -q "^${CUPS_CONTAINER_NAME}$"; then
            log "Migrasi container CUPS: ${CUPS_LEGACY_CONTAINER_NAME} -> ${CUPS_CONTAINER_NAME}"
            docker rename "$CUPS_LEGACY_CONTAINER_NAME" "$CUPS_CONTAINER_NAME" >/dev/null 2>&1 \
                || warn "Gagal rename container legacy CUPS, lanjut pakai existing state."
        fi
    fi

    if docker ps -a --format '{{.Names}}' | grep -q "^${CUPS_CONTAINER_NAME}$"; then
        docker start "$CUPS_CONTAINER_NAME" >/dev/null 2>&1 || true
    else
        docker run -d \
            -e TELEGRAM_TOKEN="${TELEGRAM_TOKEN}" \
            -e TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID}" \
            --name "$CUPS_CONTAINER_NAME" \
            --restart unless-stopped \
            -p ${CUPS_PORT}:631 \
            -v /var/run/dbus:/var/run/dbus \
            -v /dev/bus/usb:/dev/bus/usb \
            -v "${CUPS_CONF}:/etc/cups" \
            -v "${CUPS_LOG}:/var/log/cups" \
            --privileged \
            "${ACTIVE_CUPS_IMG}" >/dev/null || die "Run CUPS gagal"
    fi

    echo "http://${IP_LAN}:${CUPS_PORT}" > "${CASAOS_ROOT}/cups_url.txt"
    log "CUPS URL: http://${IP_LAN}:${CUPS_PORT}"
fi

if docker inspect -f '{{.State.Running}}' "$CUPS_CONTAINER_NAME" 2>/dev/null | grep -q '^true$'; then
    configure_cups_remote_access "$CUPS_CONTAINER_NAME"
    configure_cups_logging "$CUPS_CONTAINER_NAME"
elif docker ps -a --format '{{.Names}}' | grep -q "^${CUPS_CONTAINER_NAME}$"; then
    warn "Container ${CUPS_CONTAINER_NAME} terdeteksi namun tidak running; skip konfigurasi cupsctl."
fi

# ============================================================
# SANE / Scanservjs
# ============================================================
if [[ "$ENABLE_SANE" == "yes" ]]; then
    log "Menyiapkan SANE Scanservjs..."

    if [[ "$FORCE_RESET_SANE" == "yes" ]]; then
        if confirm_yes_no "FORCE_RESET_SANE aktif. Hapus container SCANNER existing?" "no"; then
            docker rm -f SCANNER >/dev/null 2>&1 || true
            sleep 2
        else
            warn "Skip reset SANE karena dibatalkan user."
        fi
    fi

    SANE_PORT="$(free_port_or_fallback "$SANE_PORT")" || die "Tidak ada port kosong untuk SANE"
    log "SANE port digunakan: $SANE_PORT"

    if docker ps -a --format '{{.Names}}' | grep -q '^SCANNER$'; then
        docker start SCANNER >/dev/null 2>&1 || true
    else
        docker run -d \
            --name SCANNER \
            --restart unless-stopped \
            -p ${SANE_PORT}:8080 \
            -v /var/run/dbus:/var/run/dbus \
            -v /dev/bus/usb:/dev/bus/usb \
            --privileged \
            "$SANE_IMG" >/dev/null || die "Run SCANNER gagal"
    fi

    echo "http://${IP_LAN}:${SANE_PORT}" > "${CASAOS_ROOT}/sane_url.txt"
    log "SANE URL: http://${IP_LAN}:${SANE_PORT}"
fi

# -----------------------------------------------------------------
# Reset CasaOS (reset password & DB)
# -----------------------------------------------------------------
if command -v casaos >/dev/null 2>&1; then
    log "CasaOS terdeteksi – menyiapkan reset password & DB …"
    if confirm_yes_no "Reset CasaOS user DB sekarang? (akan minta buat akun baru lagi)" "no"; then
        warn "⚠️  Reset password CasaOS – Anda harus membuat akun baru setelah ini."
        rm -f /var/lib/casaos/db/user.db
        rm -rf /var/log/casaos/*.log 2>/dev/null || true
        log "Restarting CasaOS services …"
        systemctl restart casaos-gateway.service casaos-user-service.service casaos.service &
        sleep 3
    else
        warn "Skip reset CasaOS DB karena dibatalkan user."
    fi
else
    if guard_network_or_skip "install CasaOS"; then
        if confirm_yes_no "CasaOS belum terpasang. Install sekarang?" "${CRITICAL_CONFIRM_DEFAULT:-no}"; then
            log "CasaOS belum terpasang – menginstall …"
            curl -fsSL https://get.casaos.io | sudo bash || warn "Install CasaOS gagal (skip)."
        else
            warn "Install CasaOS dibatalkan oleh user."
        fi
    else
        warn "CasaOS belum terpasang dan internet down. Skip install CasaOS."
    fi
fi

log "Sinkronisasi Docker state dengan CasaOS …"
systemctl reload docker &

# -------------------------------------------------
# (Optional) Tailscale (OAuth Edition)
# -------------------------------------------------
if [[ "${ENABLE_TAILSCALE:-no}" == "yes" ]]; then
    if ! guard_network_or_skip "setup Tailscale"; then
        warn "Skip setup Tailscale karena offline."
    else
        # 1. Cek & Install Tailscale
        if command -v tailscale >/dev/null 2>&1; then
            log "Tailscale sudah terinstall. Melewati langkah instalasi."
        else
            if confirm_yes_no "Tailscale belum terpasang. Install Tailscale sekarang?" "${CRITICAL_CONFIRM_DEFAULT:-no}"; then
                log "Tailscale tidak ditemukan. Memulai instalasi..."
                curl -fsSL https://tailscale.com/install.sh | sh
            else
                warn "Install Tailscale dibatalkan oleh user."
            fi
        fi

        if ! command -v tailscale >/dev/null 2>&1; then
            warn "Binary tailscale tidak tersedia. Skip konfigurasi Tailscale."
        else

            # 2. Pastikan daemon aktif saat boot (termasuk kasus sudah terinstall)
            if systemctl list-unit-files tailscaled.service >/dev/null 2>&1; then
                if [[ "${TS_AUTO_ENABLE_SERVICE:-yes}" == "yes" ]]; then
                    systemctl enable --now tailscaled >/dev/null 2>&1 || warn "Gagal enable/start tailscaled."
                else
                    systemctl start tailscaled >/dev/null 2>&1 || warn "Gagal start tailscaled."
                fi
                sleep 3
            else
                warn "Unit tailscaled.service tidak ditemukan. Skip enable service."
            fi

            # 3. Cek status koneksi (butuh jq)
            if ! command -v jq >/dev/null 2>&1; then
                log "Instal jq (dependency) ..."
                apt-get update -y || true
                apt-get install -y jq || true
            fi

            TS_STATUS=$(tailscale status --json 2>/dev/null \
                         | jq -r '.BackendState' 2>/dev/null || echo "NeedsLogin")

            case "${TS_ACCEPT_ROUTES:-yes}" in
                yes|true|1|on) TS_ACCEPT_ROUTES_BOOL="true" ;;
                *) TS_ACCEPT_ROUTES_BOOL="false" ;;
            esac
            case "${TS_ACCEPT_DNS:-no}" in
                yes|true|1|on) TS_ACCEPT_DNS_BOOL="true" ;;
                *) TS_ACCEPT_DNS_BOOL="false" ;;
            esac
            TS_HOSTNAME_FINAL="${TS_HOSTNAME_EFFECTIVE_HINT:-}"
            case "${TS_ADVERTISE_EXIT_NODE:-no}" in
                yes|true|1|on) TS_ADVERTISE_EXIT_NODE_BOOL="true" ;;
                *) TS_ADVERTISE_EXIT_NODE_BOOL="false" ;;
            esac
            case "${TS_RESET_ON_UP:-no}" in
                yes|true|1|on) TS_RESET_ON_UP_BOOL="true" ;;
                *) TS_RESET_ON_UP_BOOL="false" ;;
            esac

            # 4. tailscale up selalu dipanggil untuk sinkronisasi flags
            ts_up_args=(
                --advertise-tags "${TS_TAG:-tag:server}"
                "--accept-routes=${TS_ACCEPT_ROUTES_BOOL}"
                "--accept-dns=${TS_ACCEPT_DNS_BOOL}"
            )
            if [[ -n "$TS_HOSTNAME_FINAL" ]]; then
                ts_up_args+=(--hostname "$TS_HOSTNAME_FINAL")
            fi
            if [[ "$TS_ADVERTISE_EXIT_NODE_BOOL" == "true" ]]; then
                ts_up_args+=(--advertise-exit-node)
            fi
            if [[ "$TS_RESET_ON_UP_BOOL" == "true" ]]; then
                ts_up_args+=(--reset)
            fi

            tailscale_up_sync() {
                local action_label="$1"
                shift
                local -a up_args=("$@")
                local -a retry_args=()
                local arg output
                local has_reset="false"

                if output=$(tailscale up "${up_args[@]}" 2>&1); then
                    [[ -n "$output" ]] && log "$output"
                    return 0
                fi

                for arg in "${up_args[@]}"; do
                    if [[ "$arg" == "--reset" ]]; then
                        has_reset="true"
                        break
                    fi
                done

                if [[ "$has_reset" != "true" && "$output" == *"requires mentioning all"* ]]; then
                    warn "Tailscale mendeteksi flag non-default existing. Mencoba ulang dengan --reset agar sinkronisasi tetap jalan."
                    retry_args=(--reset "${up_args[@]}")
                    if output=$(tailscale up "${retry_args[@]}" 2>&1); then
                        [[ -n "$output" ]] && log "$output"
                        return 0
                    fi
                fi

                err "${action_label}. Detail tailscale up:"
                err "$output"
                return 1
            }

            if [[ "$TS_STATUS" == "Running" ]]; then
                log "Tailscale sudah aktif ($TS_STATUS). Sinkronisasi konfigurasi up..."
                tailscale_up_sync "Gagal sinkronisasi konfigurasi tailscale up" "${ts_up_args[@]}" || true
            else
                log "Tailscale status: $TS_STATUS. Menyiapkan autentikasi..."

                # Tentukan Key (OAuth secret > AuthKey).
                # Tailscale menerima OAuth client secret langsung via --auth-key.
                if [[ -n "${TS_CLIENT_SECRET:-}" ]]; then
                    if [[ -n "${TS_CLIENT_ID:-}" ]]; then
                        log "Menggunakan OAuth Client Secret untuk pendaftaran..."
                    else
                        log "Menggunakan OAuth Client Secret untuk pendaftaran (tanpa client ID eksplisit)..."
                    fi
                    FINAL_KEY="${TS_CLIENT_SECRET}"
                elif [[ -n "${TAILSCALE_AUTHKEY:-}" ]]; then
                    log "Menggunakan metode AuthKey lama..."
                    FINAL_KEY="${TAILSCALE_AUTHKEY}"
                elif [[ -n "${TS_CLIENT_ID:-}" ]]; then
                    die "TS_CLIENT_ID terisi tetapi TS_CLIENT_SECRET kosong. Isi secret OAuth client atau gunakan TAILSCALE_AUTHKEY."
                else
                    die "Tidak ada OAuth Client Secret atau AuthKey yang ditemukan!"
                fi

                log "Menghubungkan ke Tailnet..."
                tailscale_up_sync "Gagal menjalankan 'tailscale up'. Cek koneksi atau Key Anda." --authkey "$FINAL_KEY" "${ts_up_args[@]}" || true
            fi
        fi
    fi
fi   # <-- penutup outer if ENABLE_TAILSCALE

# ============================================================
# Samba Share (optional)
# ============================================================
if [[ "$ENABLE_SAMBA" == "yes" ]]; then
    log "Menyiapkan Samba share..."
    install_pkg samba

    mkdir -p "$SHARE_DIR"
    chmod -R 777 "$SHARE_DIR"

    if ! grep -q "\[STB-SHARE\]" /etc/samba/smb.conf; then
        cat >> /etc/samba/smb.conf << 'EOF'

[STB-SHARE]
path = ${SHARE_DIR}
browseable = yes
writable = yes
guest ok = yes
read only = no
force user = root
EOF
        systemctl restart smbd || true
    fi

    log "Samba share aktif: \\\\${IP_LAN}\\STB-SHARE"
fi

# ============================================================
# CasaOS Dashboard App Injection
# ============================================================
log "Membuat CasaOS App metadata..."

cat > /usr/local/bin/stb_refresh_casaos_apps.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

RUNTIME_ENV_FILE="/opt/stb_printserver/runtime.env"
[[ -f "$RUNTIME_ENV_FILE" ]] && source "$RUNTIME_ENV_FILE"

CASAOS_ROOT="${CASAOS_ROOT:-/opt/casaos}"
CASAOS_APPS="${CASAOS_APPS:-/opt/casaos/apps}"
CUPS_CONTAINER_NAME="${CUPS_CONTAINER_NAME:-cups}"
PRINT_PORTAL_CONTAINER_NAME="${PRINT_PORTAL_CONTAINER_NAME:-epson-unified-hub}"
CUPS_PORT="${CUPS_PORT:-631}"
SANE_PORT="${SANE_PORT:-8081}"
WEBUI_PORT="${WEBUI_PORT:-5000}"
WEB_PRINT_PORT="${WEB_PRINT_PORT:-3000}"

get_host_ip() {
  ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src"){print $(i+1); exit}}'
}

read_port_from_url_file() {
  local file="$1"
  [[ -f "$file" ]] || return 1
  sed -nE 's#.*:([0-9]+)/?.*#\1#p' "$file" | head -n1
}

read_port_from_container() {
  local cname="$1"
  local cport="$2"
  docker inspect -f "{{(index (index .NetworkSettings.Ports \"${cport}\") 0).HostPort}}" "$cname" 2>/dev/null || true
}

HOST_IP_NOW="$(get_host_ip)"
[[ -z "${HOST_IP_NOW}" ]] && HOST_IP_NOW="$(hostname -I | awk '{print $1}')"
[[ -z "${HOST_IP_NOW}" ]] && exit 0
HOST_TAG="$(hostname)"
CARD_SUFFIX=""
if [[ "${SHOW_HOSTNAME_ON_CARDS}" == "yes" ]]; then
  CARD_SUFFIX=" (${HOST_TAG})"
fi

CUPS_PORT_NOW="$(read_port_from_url_file "${CASAOS_ROOT}/cups_url.txt" || true)"
[[ -z "${CUPS_PORT_NOW}" ]] && CUPS_PORT_NOW="$(read_port_from_container "${CUPS_CONTAINER_NAME}" "631/tcp")"
[[ -z "${CUPS_PORT_NOW}" ]] && CUPS_PORT_NOW="${CUPS_PORT}"

SANE_PORT_NOW="$(read_port_from_url_file "${CASAOS_ROOT}/sane_url.txt" || true)"
[[ -z "${SANE_PORT_NOW}" ]] && SANE_PORT_NOW="$(read_port_from_container "SCANNER" "8080/tcp")"
[[ -z "${SANE_PORT_NOW}" ]] && SANE_PORT_NOW="${SANE_PORT}"

WEBUI_PORT_NOW="$(read_port_from_url_file "${CASAOS_ROOT}/epson_webui_url.txt" || true)"
[[ -z "${WEBUI_PORT_NOW}" ]] && WEBUI_PORT_NOW="$(read_port_from_container "epson-unified-hub" "5000/tcp")"
[[ -z "${WEBUI_PORT_NOW}" ]] && WEBUI_PORT_NOW="${WEBUI_PORT}"

WEB_PRINT_PORT_NOW="$(read_port_from_url_file "${CASAOS_ROOT}/print_portal_url.txt" || true)"
[[ -z "${WEB_PRINT_PORT_NOW}" ]] && WEB_PRINT_PORT_NOW="$(read_port_from_container "${PRINT_PORTAL_CONTAINER_NAME}" "${WEB_PRINT_PORT}/tcp")"
[[ -z "${WEB_PRINT_PORT_NOW}" ]] && WEB_PRINT_PORT_NOW="${WEB_PRINT_PORT}"

mkdir -p "${CASAOS_APPS}/printer-configuration"
cat > "${CASAOS_APPS}/printer-configuration/app.json" <<JSON
{
  "name": "Printer Configuration${CARD_SUFFIX}",
  "appid": "printer-configuration",
  "version": "1.0",
  "description": "Pengaturan dasar printer (CUPS) - ${HOST_TAG}",
  "icon": "https://raw.githubusercontent.com/twbs/icons/main/icons/printer.svg",
  "web_ui": "http://${HOST_IP_NOW}:${CUPS_PORT_NOW}",
  "web_ui_port": "${CUPS_PORT_NOW}",
  "web_ui_path": "/",
  "web_ui_https": false
}
JSON

mkdir -p "${CASAOS_APPS}/scanner"
cat > "${CASAOS_APPS}/scanner/app.json" <<JSON
{
  "name": "Scanner${CARD_SUFFIX}",
  "appid": "scanner-utility",
  "version": "1.0",
  "description": "Scanner utility (Scanservjs) - ${HOST_TAG}",
  "icon": "https://raw.githubusercontent.com/twbs/icons/main/icons/upc-scan.svg",
  "web_ui": "http://${HOST_IP_NOW}:${SANE_PORT_NOW}",
  "web_ui_port": "${SANE_PORT_NOW}",
  "web_ui_path": "/",
  "web_ui_https": false
}
JSON

mkdir -p "${CASAOS_APPS}/epson-unified-hub"
cat > "${CASAOS_APPS}/epson-unified-hub/app.json" <<JSON
{
  "name": "Epson Maintenance${CARD_SUFFIX}",
  "appid": "epson-unified-hub",
  "version": "1.0",
  "description": "Maintenance Tools - ${HOST_TAG}",
  "icon": "https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/epson.svg",
  "web_ui": "http://${HOST_IP_NOW}:${WEBUI_PORT_NOW}",
  "web_ui_port": "${WEBUI_PORT_NOW}",
  "web_ui_path": "/",
  "web_ui_https": false
}
JSON

if [[ "${WEB_PRINT_ENABLED}" == "yes" ]]; then
mkdir -p "${CASAOS_APPS}/remote-print-portal"
cat > "${CASAOS_APPS}/remote-print-portal/app.json" <<JSON
{
  "name": "Remote Print Portal${CARD_SUFFIX}",
  "appid": "remote-print-portal",
  "version": "1.0",
  "description": "Portal print jarak jauh - ${HOST_TAG}",
  "icon": "https://raw.githubusercontent.com/twbs/icons/main/icons/cloud-arrow-up.svg",
  "web_ui": "http://${HOST_IP_NOW}:${WEB_PRINT_PORT_NOW}",
  "web_ui_port": "${WEB_PRINT_PORT_NOW}",
  "web_ui_path": "/",
  "web_ui_https": false
}
JSON
else
  rm -rf "${CASAOS_APPS}/remote-print-portal" 2>/dev/null || true
fi

# Cleanup legacy folders so CasaOS does not keep showing old labels.
for base in "${CASAOS_APPS}" "/var/lib/casaos/apps"; do
  rm -rf "${base}/cups" "${base}/SCANNER" "${base}/epson-webui" 2>/dev/null || true
done

systemctl restart casaos.service >/dev/null 2>&1 || true
systemctl restart casaos-app-management.service >/dev/null 2>&1 || true
EOF
chmod +x /usr/local/bin/stb_refresh_casaos_apps.sh
/usr/local/bin/stb_refresh_casaos_apps.sh || true

log "CasaOS apps injected."

# Tailscale IP (fallback ke Offline)
TS_IP=$(tailscale ip -4 2>/dev/null || echo "Offline")
TS_SELF_DNS_NAME="$(tailscale status --json 2>/dev/null | jq -r '.Self.DNSName // empty' 2>/dev/null | sed 's/\.$//' || true)"
TS_SELF_HOSTNAME="$(tailscale status --json 2>/dev/null | jq -r '.Self.HostName // empty' 2>/dev/null || true)"
TS_REMOTE_PRINT_HOST="${REMOTE_PRINT_HOST_HINT:-${TS_SELF_HOSTNAME:-}}"
if [[ -z "$TS_REMOTE_PRINT_HOST" && "$TS_IP" != "Offline" ]]; then
  TS_REMOTE_PRINT_HOST="$TS_IP"
fi
TS_REMOTE_PRINT_URI=""
if [[ -n "$TS_REMOTE_PRINT_HOST" ]]; then
  TS_REMOTE_PRINT_URI="ipp://${TS_REMOTE_PRINT_HOST}/printers/${CUPS_AUTO_QUEUE_NAME}"
fi

# -------------------------------------------------------------------------
# 1️⃣4️⃣  Health‑check service (systemd timer)
# -------------------------------------------------------------------------
log "Membuat health-check + auto-maintenance scripts…"

cat > /usr/local/bin/stb_healthcheck.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

RUNTIME_ENV_FILE="/opt/stb_printserver/runtime.env"
[[ -f "$RUNTIME_ENV_FILE" ]] && source "$RUNTIME_ENV_FILE"

TELEGRAM_TOKEN="${TELEGRAM_TOKEN:-}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"
ENABLE_WHATSAPP="${ENABLE_WHATSAPP:-no}"
WA_PROVIDER="${WA_PROVIDER:-meta}"
WA_GRAPH_VERSION="${WA_GRAPH_VERSION:-v23.0}"
WA_TOKEN="${WA_TOKEN:-}"
WA_PHONE_NUMBER_ID="${WA_PHONE_NUMBER_ID:-}"
WA_TO="${WA_TO:-}"
WA_MESSAGE_TYPE="${WA_MESSAGE_TYPE:-text}"
WA_TEMPLATE_NAME="${WA_TEMPLATE_NAME:-stb_print_alert}"
WA_TEMPLATE_LANG="${WA_TEMPLATE_LANG:-id}"
HEALTHCHECK_SEND_OK="${HEALTHCHECK_SEND_OK:-no}"
CUPS_CONTAINER_NAME="${CUPS_CONTAINER_NAME:-cups}"
INTERNET_STABLE_SECONDS="${INTERNET_STABLE_SECONDS:-180}"
NET_STATE_FILE="/tmp/stb_net_state.env"

tg_send() {
  local msg="$1"
  if [[ -n "${TELEGRAM_TOKEN}" && -n "${TELEGRAM_CHAT_ID}" ]]; then
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
        -d "chat_id=${TELEGRAM_CHAT_ID}" \
        -d "text=${msg}" >/dev/null 2>&1 || true
  fi
  wa_send "$msg"
}

wa_send() {
  [[ "${ENABLE_WHATSAPP:-no}" != "yes" ]] && return 0
  [[ "${WA_PROVIDER:-meta}" != "meta" ]] && return 0
  [[ -z "${WA_TOKEN:-}" || -z "${WA_PHONE_NUMBER_ID:-}" || -z "${WA_TO:-}" ]] && return 0
  local msg="$1"
  local to="${WA_TO#+}"
  local escaped="${msg//\\/\\\\}"
  escaped="${escaped//\"/\\\"}"
  escaped="${escaped//$'\n'/\\n}"
  local endpoint="https://graph.facebook.com/${WA_GRAPH_VERSION:-v23.0}/${WA_PHONE_NUMBER_ID}/messages"
  local payload
  if [[ "${WA_MESSAGE_TYPE:-text}" == "template" ]]; then
    payload="{\"messaging_product\":\"whatsapp\",\"to\":\"${to}\",\"type\":\"template\",\"template\":{\"name\":\"${WA_TEMPLATE_NAME:-stb_print_alert}\",\"language\":{\"code\":\"${WA_TEMPLATE_LANG:-id}\"},\"components\":[{\"type\":\"body\",\"parameters\":[{\"type\":\"text\",\"text\":\"${escaped}\"}]}]}}"
  else
    payload="{\"messaging_product\":\"whatsapp\",\"to\":\"${to}\",\"type\":\"text\",\"text\":{\"preview_url\":false,\"body\":\"${escaped}\"}}"
  fi
  curl -s -X POST "${endpoint}" \
      -H "Authorization: Bearer ${WA_TOKEN}" \
      -H "Content-Type: application/json" \
      -d "${payload}" >/dev/null 2>&1 || true
}

internet_online() {
  timeout 2 bash -c 'cat < /dev/null > /dev/tcp/1.1.1.1/53' >/dev/null 2>&1 && return 0
  timeout 2 bash -c 'cat < /dev/null > /dev/tcp/8.8.8.8/53' >/dev/null 2>&1 && return 0
  return 1
}

status_line() {
  local name="$1"
  local row st health icon
  row=$(docker ps -a --filter "name=^/${name}$" --format '{{.Names}}|{{.Status}}' | head -n1 || true)
  if [[ -z "$row" ]]; then
    echo "🟡 ${name}: ABSENT"
    return
  fi
  st=$(echo "$row" | cut -d'|' -f2)
  health=$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$name" 2>/dev/null || echo "unknown")
  icon="🟡"
  echo "$st" | grep -qi '^Up' && icon="🟢"
  [[ "$health" == "unhealthy" || "$st" == Exited* ]] && icon="🔴"
  echo "${icon} ${name}: ${st}, health=${health}"
}

overall="🟢"
lines=()
lines+=("$(status_line "${CUPS_CONTAINER_NAME}")")
lines+=("$(status_line "epson-unified-hub")")
lines+=("$(status_line "SCANNER")")

if printf '%s\n' "${lines[@]}" | grep -q '🔴'; then
  overall="🔴"
elif printf '%s\n' "${lines[@]}" | grep -q '🟡'; then
  overall="🟡"
fi

disk_pct=$(df / | awk 'NR==2{gsub("%","",$5); print $5}')
if [[ "${disk_pct:-0}" -ge 92 ]]; then
  overall="🔴"
  lines+=("🔴 disk: ${disk_pct}%")
elif [[ "${disk_pct:-0}" -ge 85 ]]; then
  [[ "$overall" == "🟢" ]] && overall="🟡"
  lines+=("🟡 disk: ${disk_pct}%")
else
  lines+=("🟢 disk: ${disk_pct}%")
fi

msg="${overall} [STB HEALTH] $(hostname)\nTime: $(date '+%Y-%m-%d %H:%M:%S')\n$(printf '%s\n' "${lines[@]}")"

if [[ "$overall" != "🟢" || "${HEALTHCHECK_SEND_OK}" == "yes" ]]; then
  tg_send "$msg"
fi

# --- internet outage duration + recovery stability notification ---
now_ts="$(date +%s)"
last_status="unknown"
down_since="0"
stable_since="0"
stable_notified="0"
if [[ -f "$NET_STATE_FILE" ]]; then
  source "$NET_STATE_FILE" || true
fi

if internet_online; then
  current_status="up"
else
  current_status="down"
fi

if [[ "$current_status" == "down" ]]; then
  if [[ "$last_status" != "down" ]]; then
    down_since="$now_ts"
    stable_since="0"
    stable_notified="0"
    tg_send "🟡 [STB NETWORK] Internet terputus.\nTime: $(date '+%Y-%m-%d %H:%M:%S')\nPrint lokal tetap berjalan via LAN/USB."
  fi
else
  if [[ "$last_status" == "down" && "$down_since" -gt 0 ]]; then
    outage_sec=$((now_ts - down_since))
    hrs=$((outage_sec / 3600))
    mins=$(((outage_sec % 3600) / 60))
    secs=$((outage_sec % 60))
    stable_since="$now_ts"
    stable_notified="0"
    tg_send "🟢 [STB NETWORK] Internet kembali terhubung.\nDurasi outage: ${hrs}j ${mins}m ${secs}d.\nTime: $(date '+%Y-%m-%d %H:%M:%S')"
  fi

  if [[ "$stable_since" -eq 0 ]]; then
    stable_since="$now_ts"
  fi

  if [[ "$stable_notified" != "1" && $((now_ts - stable_since)) -ge "$INTERNET_STABLE_SECONDS" ]]; then
    usb_state="OFF"
    lsusb 2>/dev/null | grep -qi '04b8' && usb_state="ON"
    ipp_state="$(systemctl is-active ipp-usb 2>/dev/null || echo unknown)"
    cups_state="$(docker inspect -f '{{.State.Status}}' "${CUPS_CONTAINER_NAME}" 2>/dev/null || echo unknown)"
    webui_state="$(docker inspect -f '{{.State.Status}}' epson-unified-hub 2>/dev/null || echo unknown)"
    tg_send "🟢 [STB NETWORK] Koneksi internet stabil ${INTERNET_STABLE_SECONDS}s.\nUSB Epson: ${usb_state}\nipp-usb: ${ipp_state}\nCUPS: ${cups_state}\nWebUI: ${webui_state}\nTime: $(date '+%Y-%m-%d %H:%M:%S')"
    stable_notified="1"
  fi
fi

cat > "$NET_STATE_FILE" <<STATE
last_status=${current_status}
down_since=${down_since}
stable_since=${stable_since}
stable_notified=${stable_notified}
STATE
EOF
chmod +x /usr/local/bin/stb_healthcheck.sh

cat > /usr/local/bin/stb_maint_automation.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

MODE="${1:-check-rebuild}"
RUNTIME_ENV_FILE="/opt/stb_printserver/runtime.env"
[[ -f "$RUNTIME_ENV_FILE" ]] && source "$RUNTIME_ENV_FILE"

TELEGRAM_TOKEN="${TELEGRAM_TOKEN:-}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"
ENABLE_WHATSAPP="${ENABLE_WHATSAPP:-no}"
WA_PROVIDER="${WA_PROVIDER:-meta}"
WA_GRAPH_VERSION="${WA_GRAPH_VERSION:-v23.0}"
WA_TOKEN="${WA_TOKEN:-}"
WA_PHONE_NUMBER_ID="${WA_PHONE_NUMBER_ID:-}"
WA_TO="${WA_TO:-}"
WA_MESSAGE_TYPE="${WA_MESSAGE_TYPE:-text}"
WA_TEMPLATE_NAME="${WA_TEMPLATE_NAME:-stb_print_alert}"
WA_TEMPLATE_LANG="${WA_TEMPLATE_LANG:-id}"
SNMP_WRITE="${SNMP_WRITE:-EPCF_PASS}"
WEBUI_DIR="${WEBUI_DIR:-/opt/stb_printserver/epson-webui}"
PERSIST_ROOT="${PERSIST_ROOT:-/opt/stb_printserver}"

BUSINESS_START_HOUR="${BUSINESS_START_HOUR:-7}"
BUSINESS_END_HOUR_WEEKDAY="${BUSINESS_END_HOUR_WEEKDAY:-21}"
BUSINESS_END_HOUR_SATURDAY="${BUSINESS_END_HOUR_SATURDAY:-13}"

ENABLE_AUTO_REBUILD="${ENABLE_AUTO_REBUILD:-yes}"
ENABLE_HOUSEKEEPING="${ENABLE_HOUSEKEEPING:-yes}"

TELEGRAM_ACTIVITY_NOTIFY="${TELEGRAM_ACTIVITY_NOTIFY:-yes}"
REINKPY_NOTIFY_HOURS="${REINKPY_NOTIFY_HOURS:-24}"
REINKPY_AUTO_CHECK_ON_START="${REINKPY_AUTO_CHECK_ON_START:-yes}"
REINKPY_SOURCE_MODE="${REINKPY_SOURCE_MODE:-auto}"
REINKPY_FIX_STALE_DAYS="${REINKPY_FIX_STALE_DAYS:-21}"
WASTE_WARN_THRESHOLD="${WASTE_WARN_THRESHOLD:-80}"
WASTE_ALERT_THRESHOLD="${WASTE_ALERT_THRESHOLD:-90}"
WASTE_RECOVER_THRESHOLD="${WASTE_RECOVER_THRESHOLD:-70}"
INK_WARN_THRESHOLD="${INK_WARN_THRESHOLD:-20}"
INK_CRITICAL_THRESHOLD="${INK_CRITICAL_THRESHOLD:-10}"
INK_RECOVER_THRESHOLD="${INK_RECOVER_THRESHOLD:-30}"
ENABLE_BACKGROUND_MONITOR="${ENABLE_BACKGROUND_MONITOR:-yes}"
MONITOR_INTERVAL_SECONDS="${MONITOR_INTERVAL_SECONDS:-300}"
UPDATE_STATUS_FILE="${PERSIST_ROOT}/reinkpy_update_status.json"
UPDATE_PROGRESS_FILE="${PERSIST_ROOT}/reinkpy_update_progress.log"
UPDATE_REQUEST_FILE="${PERSIST_ROOT}/reinkpy_update.request"
TRACK_UPDATE_STATUS="no"
UPDATE_REQUEST_ID=""
UPDATE_SOURCE="dashboard"
UPDATE_STARTED_AT=""

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

tg_send() {
  local msg="$1"
  if [[ -n "${TELEGRAM_TOKEN}" && -n "${TELEGRAM_CHAT_ID}" ]]; then
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
        -d "chat_id=${TELEGRAM_CHAT_ID}" \
        -d "text=${msg}" >/dev/null 2>&1 || true
  fi
  wa_send "$msg"
}

wa_send() {
  [[ "${ENABLE_WHATSAPP:-no}" != "yes" ]] && return 0
  [[ "${WA_PROVIDER:-meta}" != "meta" ]] && return 0
  [[ -z "${WA_TOKEN:-}" || -z "${WA_PHONE_NUMBER_ID:-}" || -z "${WA_TO:-}" ]] && return 0
  local msg="$1"
  local to="${WA_TO#+}"
  local escaped="${msg//\\/\\\\}"
  escaped="${escaped//\"/\\\"}"
  escaped="${escaped//$'\n'/\\n}"
  local endpoint="https://graph.facebook.com/${WA_GRAPH_VERSION:-v23.0}/${WA_PHONE_NUMBER_ID}/messages"
  local payload
  if [[ "${WA_MESSAGE_TYPE:-text}" == "template" ]]; then
    payload="{\"messaging_product\":\"whatsapp\",\"to\":\"${to}\",\"type\":\"template\",\"template\":{\"name\":\"${WA_TEMPLATE_NAME:-stb_print_alert}\",\"language\":{\"code\":\"${WA_TEMPLATE_LANG:-id}\"},\"components\":[{\"type\":\"body\",\"parameters\":[{\"type\":\"text\",\"text\":\"${escaped}\"}]}]}}"
  else
    payload="{\"messaging_product\":\"whatsapp\",\"to\":\"${to}\",\"type\":\"text\",\"text\":{\"preview_url\":false,\"body\":\"${escaped}\"}}"
  fi
  curl -s -X POST "${endpoint}" \
      -H "Authorization: Bearer ${WA_TOKEN}" \
      -H "Content-Type: application/json" \
      -d "${payload}" >/dev/null 2>&1 || true
}

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

json_quote_or_null() {
  local v="${1:-}"
  if [[ -z "$v" ]]; then
    echo "null"
  else
    printf '"%s"' "$(json_escape "$v")"
  fi
}

append_update_progress() {
  local msg="$1"
  [[ "$TRACK_UPDATE_STATUS" == "yes" ]] || return 0
  mkdir -p "$(dirname "$UPDATE_PROGRESS_FILE")"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ${msg}" >> "$UPDATE_PROGRESS_FILE"
  if [[ -f "$UPDATE_PROGRESS_FILE" ]]; then
    tail -n 400 "$UPDATE_PROGRESS_FILE" > "${UPDATE_PROGRESS_FILE}.tmp" && \
      mv "${UPDATE_PROGRESS_FILE}.tmp" "$UPDATE_PROGRESS_FILE"
  fi
}

write_update_status() {
  local state="$1"
  local progress="$2"
  local message="$3"
  local finished="${4:-no}"
  local finished_at=""
  local now_ts
  now_ts="$(date '+%Y-%m-%d %H:%M:%S')"
  [[ "$TRACK_UPDATE_STATUS" == "yes" ]] || return 0
  [[ "$finished" == "yes" ]] && finished_at="$now_ts"

  mkdir -p "$(dirname "$UPDATE_STATUS_FILE")"
  cat > "$UPDATE_STATUS_FILE" <<JSON
{
  "state": "$(json_escape "$state")",
  "progress": ${progress},
  "message": "$(json_escape "$message")",
  "request_id": $(json_quote_or_null "${UPDATE_REQUEST_ID}"),
  "source": $(json_quote_or_null "${UPDATE_SOURCE}"),
  "started_at": $(json_quote_or_null "${UPDATE_STARTED_AT}"),
  "finished_at": $(json_quote_or_null "${finished_at}"),
  "updated_at": "$(json_escape "$now_ts")"
}
JSON
}

begin_manual_update_tracking() {
  TRACK_UPDATE_STATUS="yes"
  UPDATE_STARTED_AT="$(date '+%Y-%m-%d %H:%M:%S')"
  UPDATE_REQUEST_ID=""
  UPDATE_SOURCE="dashboard"

  if [[ -f "$UPDATE_REQUEST_FILE" ]]; then
    UPDATE_REQUEST_ID="$(sed -nE 's/.*"request_id"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' "$UPDATE_REQUEST_FILE" | head -n1 || true)"
    UPDATE_SOURCE="$(sed -nE 's/.*"source"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' "$UPDATE_REQUEST_FILE" | head -n1 || true)"
    [[ -z "$UPDATE_SOURCE" ]] && UPDATE_SOURCE="dashboard"
  fi

  : > "$UPDATE_PROGRESS_FILE"
  append_update_progress "Manual update job started (req=${UPDATE_REQUEST_ID:-n/a}, source=${UPDATE_SOURCE})"
  write_update_status "running" 15 "Menyiapkan proses rebuild Maintenance Tools..."
}

internet_online() {
  timeout 2 bash -c 'cat < /dev/null > /dev/tcp/1.1.1.1/53' >/dev/null 2>&1 && return 0
  timeout 2 bash -c 'cat < /dev/null > /dev/tcp/8.8.8.8/53' >/dev/null 2>&1 && return 0
  return 1
}

is_business_hours() {
  local dow h
  dow="$(date +%u)"   # 1-7 (Mon-Sun)
  h="$(date +%H)"

  if [[ "$dow" -ge 1 && "$dow" -le 5 ]]; then
    [[ "$h" -ge "$BUSINESS_START_HOUR" && "$h" -lt "$BUSINESS_END_HOUR_WEEKDAY" ]] && return 0
    return 1
  fi

  if [[ "$dow" -eq 6 ]]; then
    [[ "$h" -ge "$BUSINESS_START_HOUR" && "$h" -lt "$BUSINESS_END_HOUR_SATURDAY" ]] && return 0
    return 1
  fi

  return 1
}

port_in_use() {
  local p="$1"
  ss -ltn 2>/dev/null | awk 'NR>1 {print $4}' | grep -qE "[:.]${p}$"
}

container_using_port() {
  local p="$1"
  docker ps --format '{{.ID}} {{.Names}}' | while read -r id name; do
    docker port "$id" 2>/dev/null | grep -q ":${p}" && echo "$name"
  done | head -n 1
}

port_pids() {
  local p="$1"
  ss -ltnp 2>/dev/null \
    | awk -v pp=":${p}" '$4 ~ pp {print}' \
    | sed -nE 's/.*pid=([0-9]+).*/\1/p' \
    | sort -u
}

force_release_port() {
  local p="$1" cname pid pids

  cname="$(container_using_port "${p}" || true)"
  if [[ -n "${cname}" ]]; then
    log "Port ${p} dipakai container ${cname}, remove..."
    docker rm -f "${cname}" >/dev/null 2>&1 || true
    sleep 1
  fi

  if port_in_use "${p}"; then
    pids="$(port_pids "${p}" || true)"
    if [[ -n "${pids}" ]]; then
      for pid in ${pids}; do
        kill -TERM "${pid}" >/dev/null 2>&1 || true
      done
      sleep 1
      for pid in ${pids}; do
        if kill -0 "${pid}" >/dev/null 2>&1; then
          kill -KILL "${pid}" >/dev/null 2>&1 || true
        fi
      done
      sleep 1
    fi
  fi

  ! port_in_use "${p}"
}

safe_rebuild_webui() {
  local target_port host_ip
  target_port="${WEBUI_PORT:-5000}"
  log "Rebuild epson-unified-hub (target port ${target_port})"
  append_update_progress "Build image epson-unified-hub..."
  write_update_status "running" 25 "Build image epson-unified-hub..."

  if ! docker build \
    --build-arg REINKPY_SOURCE_MODE="${REINKPY_SOURCE_MODE}" \
    --build-arg REINKPY_FIX_STALE_DAYS="${REINKPY_FIX_STALE_DAYS}" \
    -t epson-unified-hub "$WEBUI_DIR" >/dev/null; then
    append_update_progress "Build image gagal."
    return 1
  fi
  append_update_progress "Build image selesai."
  write_update_status "running" 45 "Build image selesai. Menutup container lama..."

  docker rm -f epson-unified-hub >/dev/null 2>&1 || true

  append_update_progress "Membebaskan port ${target_port}..."
  if ! force_release_port "${target_port}"; then
    append_update_progress "Gagal membebaskan port ${target_port}."
    return 1
  fi
  write_update_status "running" 60 "Port siap. Menjalankan container baru..."

  if ! docker run -d \
    --name epson-unified-hub \
    --restart unless-stopped \
    -p "${target_port}:5000" \
    -e SNMP_WRITE="${SNMP_WRITE}" \
    -e TELEGRAM_TOKEN="${TELEGRAM_TOKEN}" \
    -e TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID}" \
    -e ENABLE_WHATSAPP="${ENABLE_WHATSAPP}" \
    -e WA_PROVIDER="${WA_PROVIDER}" \
    -e WA_GRAPH_VERSION="${WA_GRAPH_VERSION}" \
    -e WA_TOKEN="${WA_TOKEN}" \
    -e WA_PHONE_NUMBER_ID="${WA_PHONE_NUMBER_ID}" \
    -e WA_TO="${WA_TO}" \
    -e WA_MESSAGE_TYPE="${WA_MESSAGE_TYPE}" \
    -e WA_TEMPLATE_NAME="${WA_TEMPLATE_NAME}" \
    -e WA_TEMPLATE_LANG="${WA_TEMPLATE_LANG}" \
    -e TELEGRAM_ACTIVITY_NOTIFY="${TELEGRAM_ACTIVITY_NOTIFY}" \
    -e REINKPY_NOTIFY_HOURS="${REINKPY_NOTIFY_HOURS}" \
    -e REINKPY_AUTO_CHECK_ON_START="${REINKPY_AUTO_CHECK_ON_START}" \
    -e REINKPY_SOURCE_MODE="${REINKPY_SOURCE_MODE}" \
    -e REINKPY_FIX_STALE_DAYS="${REINKPY_FIX_STALE_DAYS}" \
    -e WASTE_WARN_THRESHOLD="${WASTE_WARN_THRESHOLD}" \
    -e WASTE_ALERT_THRESHOLD="${WASTE_ALERT_THRESHOLD}" \
    -e WASTE_RECOVER_THRESHOLD="${WASTE_RECOVER_THRESHOLD}" \
    -e INK_WARN_THRESHOLD="${INK_WARN_THRESHOLD}" \
    -e INK_CRITICAL_THRESHOLD="${INK_CRITICAL_THRESHOLD}" \
    -e INK_RECOVER_THRESHOLD="${INK_RECOVER_THRESHOLD}" \
    -e ENABLE_BACKGROUND_MONITOR="${ENABLE_BACKGROUND_MONITOR}" \
    -e MONITOR_INTERVAL_SECONDS="${MONITOR_INTERVAL_SECONDS}" \
    -v "${PERSIST_ROOT}:${PERSIST_ROOT}" \
    -v /dev/bus/usb:/dev/bus/usb \
    --privileged \
    epson-unified-hub >/dev/null; then
    append_update_progress "Docker run gagal di port ${target_port}."
    return 1
  fi

  append_update_progress "Container epson-unified-hub berhasil dijalankan."
  write_update_status "running" 80 "Sinkronisasi URL dan metadata CasaOS..."

  host_ip="$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src"){print $(i+1); exit}}')"
  [[ -z "${host_ip}" ]] && host_ip="$(hostname -I | awk '{print $1}')"
  [[ -n "${host_ip}" ]] && echo "http://${host_ip}:${target_port}" > /opt/casaos/epson_webui_url.txt
  /usr/local/bin/stb_refresh_casaos_apps.sh >/dev/null 2>&1 || true
  append_update_progress "Sinkronisasi URL/CasaOS selesai."
  write_update_status "running" 95 "Finalisasi update..."
  return 0
}

mode_check_rebuild() {
  [[ "$ENABLE_AUTO_REBUILD" != "yes" ]] && exit 0
  if is_business_hours; then
    log "Skip auto-rebuild: jam operasional."
    exit 0
  fi

  if ! internet_online; then
    log "Skip auto-rebuild: internet down (offline guard)."
    exit 0
  fi

  local port data has_update
  port="${WEBUI_PORT:-5000}"
  has_update="unknown"
  data=$(curl -fsS "http://127.0.0.1:${port}/reinkpy/check_update?notify=0" 2>/dev/null || true)
  if [[ -n "$data" ]]; then
    has_update=$(echo "$data" | jq -r '.has_update // "unknown"' 2>/dev/null || echo "unknown")
  fi

  if [[ "$has_update" == "false" ]]; then
    log "Auto-rebuild: tidak ada update."
    exit 0
  fi

  if safe_rebuild_webui; then
    tg_send "🟢 [STB MAINTENANCE]\\nAuto rebuild epson-unified-hub sukses\\nTime: $(date '+%Y-%m-%d %H:%M:%S')"
  else
    tg_send "🔴 [STB MAINTENANCE]\\nAuto rebuild epson-unified-hub gagal\\nTime: $(date '+%Y-%m-%d %H:%M:%S')"
    exit 1
  fi
}

disk_avail_kb() {
  df -Pk / | awk 'NR==2 {print $4+0}'
}

trim_log_file_keep_lines() {
  local f="$1"
  local keep="${2:-2000}"
  [[ -f "$f" ]] || return 0
  tail -n "$keep" "$f" > "${f}.tmp" 2>/dev/null || return 0
  cat "${f}.tmp" > "$f" 2>/dev/null || true
  rm -f "${f}.tmp" >/dev/null 2>&1 || true
}

zram_state_line() {
  local z
  z="$(awk '$1 ~ /^\/dev\/zram/ {print $1 ":" $3 "KiB"}' /proc/swaps 2>/dev/null | paste -sd',' - || true)"
  [[ -n "$z" ]] && echo "$z" || echo "not-detected"
}

housekeeping_core() {
  local before_kb after_kb freed_mb
  local keep_lines tmp_days docker_ret_hours zram_state

  keep_lines="${HOUSEKEEPING_LOG_KEEP_LINES:-2000}"
  tmp_days="${HOUSEKEEPING_TMP_DAYS:-3}"
  docker_ret_hours="${HOUSEKEEPING_DOCKER_RETENTION_HOURS:-240}"
  [[ "$keep_lines" =~ ^[0-9]+$ ]] || keep_lines=2000
  [[ "$tmp_days" =~ ^[0-9]+$ ]] || tmp_days=3
  [[ "$docker_ret_hours" =~ ^[0-9]+$ ]] || docker_ret_hours=240

  before_kb="$(disk_avail_kb)"
  zram_state="$(zram_state_line)"
  log "Housekeeping start: zram=${zram_state} (tidak diubah)"

  find /tmp /var/tmp -xdev -type f -mtime +"${tmp_days}" -delete 2>/dev/null || true
  find /tmp /var/tmp -xdev -type d -empty -mtime +1 -delete 2>/dev/null || true

  trim_log_file_keep_lines /var/log/stb_printserver_setup.log "$keep_lines"
  trim_log_file_keep_lines /var/log/syslog "$keep_lines"
  trim_log_file_keep_lines /var/log/messages "$keep_lines"
  trim_log_file_keep_lines /var/log/kern.log "$keep_lines"
  trim_log_file_keep_lines /var/log/daemon.log "$keep_lines"
  trim_log_file_keep_lines /var/log/dpkg.log "$keep_lines"
  trim_log_file_keep_lines /var/log/apt/history.log "$keep_lines"
  trim_log_file_keep_lines /var/log/apt/term.log "$keep_lines"

  find /var/log -type f \( -name '*.gz' -o -name '*.1' -o -name '*.2' -o -name '*.3' -o -name '*.old' \) -mtime +2 -delete 2>/dev/null || true

  if command -v journalctl >/dev/null 2>&1; then
    journalctl --rotate >/dev/null 2>&1 || true
    journalctl --vacuum-time=14d >/dev/null 2>&1 || true
    journalctl --vacuum-size="${HOUSEKEEPING_JOURNAL_MAX:-120M}" >/dev/null 2>&1 || true
  fi

  if [[ "${ENABLE_STORAGE_TRIM:-yes}" == "yes" ]]; then
    apt-get clean >/dev/null 2>&1 || true
    find /var/cache/apt/archives -type f -name '*.deb' -delete 2>/dev/null || true
    rm -rf /var/lib/apt/lists/* >/dev/null 2>&1 || true
    rm -rf /var/crash/* >/dev/null 2>&1 || true
    rm -rf /root/.cache/pip >/dev/null 2>&1 || true
  fi

  if command -v docker >/dev/null 2>&1; then
    docker container prune -f >/dev/null 2>&1 || true
    docker image prune -a -f --filter "until=${docker_ret_hours}h" >/dev/null 2>&1 || true
    docker builder prune -af --filter "until=${docker_ret_hours}h" >/dev/null 2>&1 || true
    docker network prune -f >/dev/null 2>&1 || true
  fi

  if [[ "${HOUSEKEEPING_RESTART_MAINTENANCE:-no}" == "yes" ]]; then
    docker restart epson-unified-hub >/dev/null 2>&1 || true
  fi

  after_kb="$(disk_avail_kb)"
  freed_mb=$(( (after_kb - before_kb) / 1024 ))
  log "Housekeeping done: free_root_before=${before_kb}KiB free_root_after=${after_kb}KiB delta=${freed_mb}MB"
  tg_send "🟢 [STB HOUSEKEEPING]\\nStorage trim selesai. Delta free root: ${freed_mb}MB\\nZRAM: ${zram_state} (tetap aman)\\nTime: $(date '+%Y-%m-%d %H:%M:%S')"
}

mode_housekeeping() {
  [[ "$ENABLE_HOUSEKEEPING" != "yes" ]] && exit 0
  if is_business_hours; then
    log "Skip housekeeping: jam operasional."
    exit 0
  fi
  housekeeping_core
}

mode_housekeeping_force() {
  [[ "$ENABLE_HOUSEKEEPING" != "yes" ]] && exit 0
  housekeeping_core
}

mode_manual_rebuild() {
  begin_manual_update_tracking

  if ! internet_online; then
    append_update_progress "Internet down. Manual rebuild dibatalkan."
    write_update_status "failed" 100 "Manual rebuild ditolak: internet down." "yes"
    tg_send "🟡 [STB MAINTENANCE]\\nManual rebuild ditolak: internet down."
    exit 1
  fi

  if safe_rebuild_webui; then
    append_update_progress "Manual rebuild selesai sukses."
    write_update_status "success" 100 "Manual rebuild selesai sukses." "yes"
    tg_send "🟢 [STB MAINTENANCE]\\nManual rebuild dari dashboard sukses\\nTime: $(date '+%Y-%m-%d %H:%M:%S')"
  else
    append_update_progress "Manual rebuild gagal."
    write_update_status "failed" 100 "Manual rebuild gagal. Periksa log update." "yes"
    tg_send "🔴 [STB MAINTENANCE]\\nManual rebuild dari dashboard gagal\\nTime: $(date '+%Y-%m-%d %H:%M:%S')"
    exit 1
  fi
}

case "$MODE" in
  check-rebuild) mode_check_rebuild ;;
  housekeeping) mode_housekeeping ;;
  housekeeping-force) mode_housekeeping_force ;;
  manual-rebuild) mode_manual_rebuild ;;
  *) echo "Unknown mode: $MODE" >&2; exit 2 ;;
esac
EOF
chmod +x /usr/local/bin/stb_maint_automation.sh

cat > /usr/local/bin/stb_printer_watchdog.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

RUNTIME_ENV_FILE="/opt/stb_printserver/runtime.env"
[[ -f "$RUNTIME_ENV_FILE" ]] && source "$RUNTIME_ENV_FILE"

TELEGRAM_TOKEN="${TELEGRAM_TOKEN:-}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"
ENABLE_WHATSAPP="${ENABLE_WHATSAPP:-no}"
WA_PROVIDER="${WA_PROVIDER:-meta}"
WA_GRAPH_VERSION="${WA_GRAPH_VERSION:-v23.0}"
WA_TOKEN="${WA_TOKEN:-}"
WA_PHONE_NUMBER_ID="${WA_PHONE_NUMBER_ID:-}"
WA_TO="${WA_TO:-}"
WA_MESSAGE_TYPE="${WA_MESSAGE_TYPE:-text}"
WA_TEMPLATE_NAME="${WA_TEMPLATE_NAME:-stb_print_alert}"
WA_TEMPLATE_LANG="${WA_TEMPLATE_LANG:-id}"
CUPS_CONTAINER_NAME="${CUPS_CONTAINER_NAME:-cups}"
PRINTER_WATCH_INTERVAL_SECONDS="${PRINTER_WATCH_INTERVAL_SECONDS:-20}"
STATE_FILE="/tmp/stb_printer_watchdog_state.env"

tg_send() {
  local msg="$1"
  if [[ -n "${TELEGRAM_TOKEN}" && -n "${TELEGRAM_CHAT_ID}" ]]; then
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
        -d "chat_id=${TELEGRAM_CHAT_ID}" \
        -d "text=${msg}" >/dev/null 2>&1 || true
  fi
  wa_send "$msg"
}

wa_send() {
  [[ "${ENABLE_WHATSAPP:-no}" != "yes" ]] && return 0
  [[ "${WA_PROVIDER:-meta}" != "meta" ]] && return 0
  [[ -z "${WA_TOKEN:-}" || -z "${WA_PHONE_NUMBER_ID:-}" || -z "${WA_TO:-}" ]] && return 0
  local msg="$1"
  local to="${WA_TO#+}"
  local escaped="${msg//\\/\\\\}"
  escaped="${escaped//\"/\\\"}"
  escaped="${escaped//$'\n'/\\n}"
  local endpoint="https://graph.facebook.com/${WA_GRAPH_VERSION:-v23.0}/${WA_PHONE_NUMBER_ID}/messages"
  local payload
  if [[ "${WA_MESSAGE_TYPE:-text}" == "template" ]]; then
    payload="{\"messaging_product\":\"whatsapp\",\"to\":\"${to}\",\"type\":\"template\",\"template\":{\"name\":\"${WA_TEMPLATE_NAME:-stb_print_alert}\",\"language\":{\"code\":\"${WA_TEMPLATE_LANG:-id}\"},\"components\":[{\"type\":\"body\",\"parameters\":[{\"type\":\"text\",\"text\":\"${escaped}\"}]}]}}"
  else
    payload="{\"messaging_product\":\"whatsapp\",\"to\":\"${to}\",\"type\":\"text\",\"text\":{\"preview_url\":false,\"body\":\"${escaped}\"}}"
  fi
  curl -s -X POST "${endpoint}" \
      -H "Authorization: Bearer ${WA_TOKEN}" \
      -H "Content-Type: application/json" \
      -d "${payload}" >/dev/null 2>&1 || true
}

usb_state="unknown"
if [[ -f "$STATE_FILE" ]]; then
  source "$STATE_FILE" || true
fi

while true; do
  current="off"
  lsusb 2>/dev/null | grep -qi '04b8' && current="on"

  # printer baru dinyalakan
  if [[ "$usb_state" != "on" && "$current" == "on" ]]; then
    systemctl restart ipp-usb >/dev/null 2>&1 || true
    systemctl start stb-cups-autoconnect.service >/dev/null 2>&1 || true
    docker start "${CUPS_CONTAINER_NAME}" >/dev/null 2>&1 || true
    docker start epson-unified-hub >/dev/null 2>&1 || true
    /usr/local/bin/stb_cups_autoconnect.sh >/dev/null 2>&1 || true
    tg_send "🟢 [STB PRINTER] Epson USB terdeteksi ON kembali.\nDaemon aktif dan service direfresh.\nTime: $(date '+%Y-%m-%d %H:%M:%S')"
  fi

  # printer dimatikan / hub power off
  if [[ "$usb_state" == "on" && "$current" != "on" ]]; then
    tg_send "🟡 [STB PRINTER] Epson USB terdeteksi OFF.\nMenunggu printer dinyalakan kembali.\nTime: $(date '+%Y-%m-%d %H:%M:%S')"
  fi

  # self-heal ringan
  if [[ "$current" == "on" ]]; then
    systemctl is-active --quiet ipp-usb || systemctl restart ipp-usb >/dev/null 2>&1 || true
  fi

  usb_state="$current"
  cat > "$STATE_FILE" <<STATE
usb_state=${usb_state}
STATE
  sleep "${PRINTER_WATCH_INTERVAL_SECONDS}"
done
EOF
chmod +x /usr/local/bin/stb_printer_watchdog.sh

cat > /usr/local/bin/stb_cups_autoconnect.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

RUNTIME_ENV_FILE="/opt/stb_printserver/runtime.env"
[[ -f "$RUNTIME_ENV_FILE" ]] && source "$RUNTIME_ENV_FILE"

CUPS_CONTAINER_NAME="${CUPS_CONTAINER_NAME:-cups}"
CUPS_AUTO_QUEUE_NAME="${CUPS_AUTO_QUEUE_NAME:-EPSON_USB}"
IPPUSB_PORT_MIN="${IPPUSB_PORT_MIN:-60000}"
IPPUSB_PORT_MAX="${IPPUSB_PORT_MAX:-60150}"

container_up() {
  docker ps --format '{{.Names}}' | grep -q "^${CUPS_CONTAINER_NAME}$"
}

detect_ipp_uri() {
  local uri=""
  uri="$(timeout 4 ippfind 2>/dev/null | awk '/^ipp:\/\//{print $1; exit}' || true)"
  if [[ -n "$uri" ]]; then
    echo "$uri"
    return 0
  fi

  local p
  for p in $(seq "${IPPUSB_PORT_MIN}" "${IPPUSB_PORT_MAX}"); do
    if timeout 1 bash -c "cat < /dev/null > /dev/tcp/127.0.0.1/${p}" >/dev/null 2>&1; then
      echo "ipp://127.0.0.1:${p}/ipp/print"
      return 0
    fi
  done
  return 1
}

detect_queue_name() {
  local usb_line model
  usb_line="$(lsusb 2>/dev/null | grep -Ei 'epson|04b8' | head -n1 || true)"
  model="${CUPS_AUTO_QUEUE_NAME}"
  if [[ "$usb_line" =~ (L[0-9]{4}) ]]; then
    model="EPSON_${BASH_REMATCH[1]}"
  fi
  echo "$model"
}

container_up || exit 0
uri="$(detect_ipp_uri || true)"
[[ -z "${uri}" ]] && exit 0
queue="$(detect_queue_name)"

docker exec "${CUPS_CONTAINER_NAME}" lpadmin -p "${queue}" -E -v "${uri}" -m everywhere >/dev/null 2>&1 || exit 0
docker exec "${CUPS_CONTAINER_NAME}" lpadmin -p "${queue}" -o printer-is-shared=true >/dev/null 2>&1 || true
docker exec "${CUPS_CONTAINER_NAME}" lpoptions -d "${queue}" >/dev/null 2>&1 || true
docker exec "${CUPS_CONTAINER_NAME}" cupsctl --remote-any --share-printers >/dev/null 2>&1 || true
EOF
chmod +x /usr/local/bin/stb_cups_autoconnect.sh

cat > /usr/local/bin/stb_net_autoheal.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

RUNTIME_ENV_FILE="/opt/stb_printserver/runtime.env"
[[ -f "$RUNTIME_ENV_FILE" ]] && source "$RUNTIME_ENV_FILE"

NET_AUTOHEAL_ENABLED="${NET_AUTOHEAL_ENABLED:-yes}"
TS_BYPASS_SUBNETS="${TS_BYPASS_SUBNETS:-192.168.88.0/24,192.168.99.0/24,192.168.1.0/24}"

is_true() {
  case "${1:-}" in
    yes|true|1|on) return 0 ;;
    *) return 1 ;;
  esac
}

detect_lan_iface() {
  local dev
  dev="$(ip -o route show default 2>/dev/null | awk '!/dev tailscale0/ {for(i=1;i<=NF;i++) if($i=="dev"){print $(i+1); exit}}')"
  if [[ -n "$dev" ]]; then
    echo "$dev"
    return 0
  fi
  ip -o link show 2>/dev/null \
    | awk -F': ' '{print $2}' \
    | grep -Ev '^(lo|tailscale0|docker0|br-|veth|virbr|zt|wg)' \
    | head -n1
}

has_global_ipv4() {
  local iface="$1"
  ip -o -4 addr show dev "$iface" scope global 2>/dev/null | grep -q 'inet '
}

renew_dhcp() {
  local iface="$1"
  local active_conn=""

  if command -v nmcli >/dev/null 2>&1 && systemctl is-active --quiet NetworkManager 2>/dev/null; then
    nmcli device connect "$iface" >/dev/null 2>&1 || true
    active_conn="$(nmcli -t -f NAME,DEVICE connection show --active 2>/dev/null | awk -F: -v d="$iface" '$2==d{print $1; exit}')"
    [[ -n "$active_conn" ]] && nmcli connection up "$active_conn" >/dev/null 2>&1 || true
  fi

  if command -v networkctl >/dev/null 2>&1 && systemctl is-active --quiet systemd-networkd 2>/dev/null; then
    networkctl renew "$iface" >/dev/null 2>&1 || true
  fi

  if command -v dhclient >/dev/null 2>&1; then
    timeout 20 dhclient -r "$iface" >/dev/null 2>&1 || true
    timeout 25 dhclient "$iface" >/dev/null 2>&1 || true
  fi

  if command -v udhcpc >/dev/null 2>&1; then
    timeout 20 udhcpc -i "$iface" -q -n -t 5 >/dev/null 2>&1 || true
  fi
}

enforce_bypass_routes() {
  local iface="$1"
  local current_gw route_line subnet
  current_gw="$(ip route show default dev "$iface" 2>/dev/null | awk '/^default / {print $3; exit}')"

  IFS=',' read -r -a subnets <<< "${TS_BYPASS_SUBNETS}"
  for subnet in "${subnets[@]}"; do
    subnet="${subnet//[[:space:]]/}"
    [[ -z "$subnet" ]] && continue

    route_line="$(ip route show "$subnet" 2>/dev/null | head -n1 || true)"

    if [[ "$route_line" == *"dev ${iface}"* && "$route_line" != *"dev tailscale0"* ]]; then
      continue
    fi

    if [[ -n "$current_gw" ]]; then
      ip route replace "$subnet" via "$current_gw" dev "$iface" metric 5 proto static >/dev/null 2>&1 || true
    else
      ip route replace "$subnet" dev "$iface" scope link metric 5 proto static >/dev/null 2>&1 || true
    fi
  done
}

main() {
  is_true "${NET_AUTOHEAL_ENABLED}" || exit 0

  local iface
  iface="$(detect_lan_iface || true)"
  [[ -z "$iface" ]] && exit 0

  ip link set "$iface" up >/dev/null 2>&1 || true

  if ! has_global_ipv4 "$iface"; then
    renew_dhcp "$iface"
  fi

  enforce_bypass_routes "$iface"
}

main "$@"
EOF
chmod +x /usr/local/bin/stb_net_autoheal.sh

cat > /etc/systemd/system/stb-healthcheck.service << 'EOF'
[Unit]
Description=STB PrintServer Healthcheck

[Service]
Type=oneshot
ExecStart=/usr/local/bin/stb_healthcheck.sh
EOF

cat > /etc/systemd/system/stb-healthcheck.timer << 'EOF'
[Unit]
Description=Run STB Healthcheck every 15 minutes

[Timer]
OnBootSec=2min
OnUnitActiveSec=15min
Unit=stb-healthcheck.service

[Install]
WantedBy=timers.target
EOF

cat > /etc/systemd/system/stb-auto-rebuild.service << 'EOF'
[Unit]
Description=STB Auto Check and Safe Rebuild (off-hours)

[Service]
Type=oneshot
ExecStart=/usr/local/bin/stb_maint_automation.sh check-rebuild
EOF

cat > /etc/systemd/system/stb-auto-rebuild.timer << 'EOF'
[Unit]
Description=Run STB auto-rebuild only outside work hours

[Timer]
OnCalendar=Mon..Fri *-*-* 22:15:00
OnCalendar=Sat *-*-* 14:15:00
OnCalendar=Sun *-*-* 10:30:00
Persistent=true
Unit=stb-auto-rebuild.service

[Install]
WantedBy=timers.target
EOF

cat > /etc/systemd/system/stb-housekeeping.service << 'EOF'
[Unit]
Description=STB Housekeeping and Light Refresh

[Service]
Type=oneshot
ExecStart=/usr/local/bin/stb_maint_automation.sh housekeeping
EOF

cat > /etc/systemd/system/stb-housekeeping.timer << 'EOF'
[Unit]
Description=Run STB housekeeping daily (off-hours)

[Timer]
OnCalendar=*-*-* 03:30:00
Persistent=true
Unit=stb-housekeeping.service

[Install]
WantedBy=timers.target
EOF

cat > /etc/systemd/system/stb-printer-watchdog.service << 'EOF'
[Unit]
Description=STB USB Printer Watchdog Daemon
After=docker.service network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/stb_printer_watchdog.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/stb-cups-autoconnect.service << 'EOF'
[Unit]
Description=STB CUPS Driverless Auto-Provision for USB Epson
After=docker.service network-online.target ipp-usb.service
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/stb_cups_autoconnect.sh
EOF

cat > /etc/systemd/system/stb-cups-autoconnect.timer << 'EOF'
[Unit]
Description=Retry CUPS auto-provision queue every 2 minutes

[Timer]
OnBootSec=90s
OnUnitActiveSec=2min
Persistent=true
Unit=stb-cups-autoconnect.service

[Install]
WantedBy=timers.target
EOF

cat > /etc/systemd/system/stb-net-autoheal.service << 'EOF'
[Unit]
Description=STB LAN DHCP Auto-Heal and Tailscale Route Bypass
After=network-online.target tailscaled.service
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/stb_net_autoheal.sh
EOF

cat > /etc/systemd/system/stb-net-autoheal.timer << 'EOF'
[Unit]
Description=Run STB LAN auto-heal every 2 minutes

[Timer]
OnBootSec=45s
OnUnitActiveSec=2min
Persistent=true
Unit=stb-net-autoheal.service

[Install]
WantedBy=timers.target
EOF

cat > /etc/systemd/system/stb-casaos-refresh.service << 'EOF'
[Unit]
Description=Refresh CasaOS Legacy App metadata with current host IP/ports
After=network-online.target docker.service
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/stb_refresh_casaos_apps.sh
EOF

cat > /etc/systemd/system/stb-casaos-refresh.timer << 'EOF'
[Unit]
Description=Auto refresh CasaOS app cards every 10 minutes

[Timer]
OnBootSec=3min
OnUnitActiveSec=10min
Persistent=true
Unit=stb-casaos-refresh.service

[Install]
WantedBy=timers.target
EOF

cat > /etc/systemd/system/stb-manual-update.service << 'EOF'
[Unit]
Description=Apply manual Maintenance Tools update requested from dashboard
After=docker.service network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/stb_maint_automation.sh manual-rebuild
ExecStartPost=/bin/rm -f /opt/stb_printserver/reinkpy_update.request
EOF

cat > /etc/systemd/system/stb-manual-update.path << 'EOF'
[Unit]
Description=Watch dashboard manual update request file

[Path]
PathExists=/opt/stb_printserver/reinkpy_update.request
Unit=stb-manual-update.service

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now stb-healthcheck.timer >/dev/null 2>&1 || warn "Enable health-check timer gagal"
systemctl enable --now stb-auto-rebuild.timer >/dev/null 2>&1 || warn "Enable auto-rebuild timer gagal"
systemctl enable --now stb-housekeeping.timer >/dev/null 2>&1 || warn "Enable housekeeping timer gagal"
systemctl enable --now stb-printer-watchdog.service >/dev/null 2>&1 || warn "Enable printer-watchdog gagal"
systemctl enable --now stb-cups-autoconnect.timer >/dev/null 2>&1 || warn "Enable cups-autoconnect timer gagal"
systemctl start stb-cups-autoconnect.service >/dev/null 2>&1 || true
systemctl enable --now stb-net-autoheal.timer >/dev/null 2>&1 || warn "Enable net-autoheal timer gagal"
systemctl start stb-net-autoheal.service >/dev/null 2>&1 || true
systemctl enable --now stb-casaos-refresh.timer >/dev/null 2>&1 || warn "Enable casaos-refresh timer gagal"
systemctl enable --now stb-manual-update.path >/dev/null 2>&1 || warn "Enable manual-update path gagal"
if [[ "${RUN_STORAGE_TRIM_ON_SETUP:-yes}" == "yes" ]]; then
  /usr/local/bin/stb_maint_automation.sh housekeeping-force >/dev/null 2>&1 || warn "Storage trim on setup gagal."
fi

# ============================================================
# FINAL SUMMARY
# ============================================================
log "===================================================="
log "SETUP COMPLETE"
log "===================================================="
log "CUPS        : http://${IP_LAN}:${CUPS_PORT}"
log "SANE        : http://${IP_LAN}:${SANE_PORT}"
log "Maintenance Tools : http://${IP_LAN}:${WEBUI_PORT}"
[[ "$WEB_PRINT_ENABLED" == "yes" ]] && log "Remote Print Portal : http://${IP_LAN}:${WEB_PRINT_PORT}"
log "CasaOS      : http://${IP_LAN}:80"
log "Hostname    : ${DEVICE_HOSTNAME_EFFECTIVE}"
log "Brand       : ${HOSTNAME_BRAND_EFFECTIVE}"
log "Tailscale IP: ${TS_IP}"
[[ -n "${TS_SELF_DNS_NAME}" ]] && log "Tailscale DNS: ${TS_SELF_DNS_NAME}"
[[ -n "${TS_REMOTE_PRINT_URI}" ]] && log "Remote IPP  : ${TS_REMOTE_PRINT_URI}"
log "Log file    : ${LOGFILE}"
log "CUPS mode   : ${CUPS_SOURCE_MODE} (image: ${CUPS_IMG}, tag: ${CUPS_OPENPRINTING_TAG})"
log "CUPS audit  : ${PERSIST_ROOT}/cups/log/page_log (lookup=${CUPS_HOSTNAME_LOOKUPS})"
log "WebUI net   : ${WEBUI_NETWORK_MODE}"
log "WebUI debug : ${WEBUI_DEBUG}"
log "Web print   : ${WEB_PRINT_ENABLED} (types=${WEB_PRINT_ALLOWED_EXTS}, max=${WEB_PRINT_MAX_MB}MB)"
log "reinkpy mode: ${REINKPY_SOURCE_MODE} (fix stale: ${REINKPY_FIX_STALE_DAYS} days)"
log "Kernel lock : ${PROTECT_KERNEL_UPDATES} (apt pin + hold)"
log "Storage trim: ${ENABLE_STORAGE_TRIM} (on-setup=${RUN_STORAGE_TRIM_ON_SETUP})"
log "Trim policy : journal<=${HOUSEKEEPING_JOURNAL_MAX}, tmp>${HOUSEKEEPING_TMP_DAYS}d, docker>${HOUSEKEEPING_DOCKER_RETENTION_HOURS}h"
log "Timer       : stb-healthcheck.timer (15m)"
log "Timer       : stb-auto-rebuild.timer (off-hours)"
log "Timer       : stb-housekeeping.timer (daily)"
log "Timer       : stb-cups-autoconnect.timer (2m)"
log "Timer       : stb-net-autoheal.timer (2m DHCP+route heal)"
log "Timer       : stb-casaos-refresh.timer (10m)"
log "Path        : stb-manual-update.path (dashboard 1-click update)"
log "Service     : stb-printer-watchdog.service (always on)"
log "===================================================="

tg_send "✅ [STB READY] $(hostname) deployed. CUPS:${CUPS_PORT} SANE:${SANE_PORT} tailscale:${TS_IP} WEBUI:${WEBUI_PORT}"
exit 0
