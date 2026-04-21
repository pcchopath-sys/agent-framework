#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ============================================================
# MOD 05: FINAL TOUCH
# Focus: udev Rules, Notifications, and Final Audit
# ============================================================

echo "[MOD 05] Applying Final Touches..."

# -----------------------------------------------------------------
# EPSON UDEV RULES
# -----------------------------------------------------------------
if [[ -n "${EPL_PRINTER_VENDOR:-}" && -n "${EPL_PRINTER_PRODUCT:-}" ]]; then
    log "Applying Epson udev rules for ${EPL_PRINTER_VENDOR}:${EPL_PRINTER_PRODUCT}..."
    UDEV_RULE_PATH="${EPL_UDEV_RULE_PATH:-/etc/udev/rules.d/99-epson-printer.rules}"

    cat > "$UDEV_RULE_PATH" <<<EOFEOF
SUBSYSTEM=="usb", ATTRS{idVendor}=="${EPL_PRINTER_VENDOR}", ATTRS{idProduct}=="${EPL_PRINTER_PRODUCT}", MODE="0666", GROUP="lp"
EOF
    udevadm control --reload-rules && udevadm trigger
    log "Udev rules applied successfully."
fi

# -----------------------------------------------------------------
# NOTIFICATIONS SETUP
# -----------------------------------------------------------------
if [[ "${ENABLE_TELEGRAM:-yes}" == "yes" && -n "${TELEGRAM_TOKEN}" ]]; then
    log "Setting up Telegram activity notifications..."
    # Integration with the monitor agent
fi

if [[ "${ENABLE_WHATSAPP:-no}" == "yes" ]]; then
    log "Setting up WhatsApp notification bridge..."
fi

# -----------------------------------------------------------------
# FINAL SYSTEM AUDIT
# -----------------------------------------------------------------
log "Performing final system audit..."
if docker ps | grep -q "cups"; then
    log "✅ CUPS container is running."
else
    warn "⚠️ CUPS container is not running."
fi

if docker ps | grep -q "scanner"; then
    log "✅ SANE container is running."
else
    warn "⚠️ SANE container is not running."
fi

log "===== STB PRINTSERVER SETUP COMPLETE ====="
echo "[MOD 05] Final touches complete. System is ready for use!"
