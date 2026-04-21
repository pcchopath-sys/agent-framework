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

# Updated allowed endpoints for Unified Hub
PORTAL_ALLOWED_ENDPOINTS = {
    "home",
    "favicon",
    "printers",
    "print_submit",
    "maintenance",
    "status",
    "reinkpy_update",
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
# Unified Hub Mode (Default)
WEBUI_MODE = "unified"
if WEBUI_MODE not in {"maintenance", "portal", "unified"}:
    WEBUI_MODE = "unified"
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
