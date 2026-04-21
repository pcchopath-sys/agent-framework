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
