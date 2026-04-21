#!/usr/bin/env python3
"""
Universal AI Partner - Gemma Brain Edition
With Self-Improving Cognitive System
Optimized for HG680P ARM SOC (minimal RAM/CPU)
"""

import os
import json
import time
import hashlib
import requests
from pathlib import Path
from datetime import datetime
from dotenv import load_dotenv

# Import Gemma Brain
from gemma_brain import GemmaMemory, GemmaHeartbeat, GemmaSession, IDENTITY, PERSONAS

# ==========================
# CONFIG (Lazy Load)
# ==========================
SCRIPT_DIR = Path("/opt/stb_printserver")
load_dotenv(str(SCRIPT_DIR / ".env"), override=True)

TOKEN = os.getenv("TELEGRAM_BOT_TOKEN", "").strip()
GROQ_KEY = os.getenv("GROQ_API_KEY", "").strip()
GEMINI_KEY = os.getenv("GEMINI_API_KEY", "") or os.getenv("GOOGLE_API_KEY", "")

DATA_DIR = Path("/opt/stb_printserver")
STATE_FILE = DATA_DIR / "state.json"

# ==========================
# OPTIMIZATIONS
# ==========================
MAX_HISTORY = 5        # Local context window (cloud handles the rest)
MAX_CACHE = 5          # Simple LRU cache (avoid duplicate API calls)
CACHE_TTL = 300       # Cache TTL 5 minutes
WRITE_INTERVAL = 10    # Lazy write state every N messages

# ==========================
# STATE (Simple Dict)
# ==========================
state = {
    "model": "groq",                    # Current active model
    "memory": {},                       # chat_id -> history
    "cache": [],                       # Simple LRU cache
    "counters": {},                    # Per-chat counters for lazy write
    "msg_count": 0,                     # Global message counter
    "last_offset": 0,                  # Telegram update offset
    "persona": "default",              # Current active persona
    "brain_initialized": True          # Gemma brain active
}

# Initialize Gemma Brain
gemma_memory = GemmaMemory(str(DATA_DIR))
gemma_heartbeat = GemmaHeartbeat(str(DATA_DIR))
gemma_session = GemmaSession(str(DATA_DIR))

# ==========================
# HELPERS
# ==========================
def log(msg):
    ts = datetime.now().strftime("%H:%M:%S")
    print(f"[{ts}] {msg}")

def load_state():
    global state
    if STATE_FILE.exists():
        try:
            data = json.loads(STATE_FILE.read_text())
            state.update(data)
        except:
            pass

def save_state():
    """Lazy write - only every WRITE_INTERVAL messages"""
    if state["msg_count"] % WRITE_INTERVAL == 0:
        STATE_FILE.write_text(json.dumps({
            "model": state["model"],
            "memory": {k: {"history": v["history"][-MAX_HISTORY:]} for k, v in state["memory"].items()},
            "last_offset": state.get("last_offset", 0)
        }, indent=2))

def get_cache_key(prompt, model):
    """Generate cache key for LRU"""
    data = f"{model}:{prompt}"
    return hashlib.md5(data.encode()).hexdigest()[:16]

def cache_get(key):
    """Check cache (simple list scan)"""
    for item in state["cache"]:
        if item["key"] == key and (time.time() - item["time"]) < CACHE_TTL:
            return item["response"]
    return None

def cache_set(key, response):
    """Simple LRU cache (FIFO when full)"""
    state["cache"].append({"key": key, "response": response, "time": time.time()})
    if len(state["cache"]) > MAX_CACHE:
        state["cache"].pop(0)

def send_msg(chat_id, text):
    """Send Telegram message"""
    try:
        requests.post(
            f"https://api.telegram.org/bot{TOKEN}/sendMessage",
            json={"chat_id": chat_id, "text": text[:4000]},  # Truncate to avoid Telegram limit
            timeout=15
        )
    except Exception as e:
        log(f"Send error: {e}")

# ==========================
# AI MODELS
# ==========================
MODELS = {
    "groq": {
        "name": "Groq Llama",
        "url": "https://api.groq.com/openai/v1/chat/completions",
        "model_id": "llama-3.1-8b-instant",
        "enabled": bool(GROQ_KEY)
    },
    "gemini": {
        "name": "Google Gemini",
        "url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent",
        "enabled": bool(GEMINI_KEY)
    }
}

def get_system_prompt(persona_mode="default"):
    """Build system prompt with Gemma brain context"""
    identity = IDENTITY
    session_context = gemma_session.get_context()
    persona_addon = gemma_memory.get_system_prompt_addon(persona_mode)
    
    return f"""Kamu GEMMA - Partner AI Senior yang serba bisa.

IDENTITAS:
- Nama: {identity['name']} v{identity['version']}
- Role: {identity['role']}
- Filosofi: {identity['objective']}

Gaya: Natural, suportif, kadang jokes. Bisa bantu konstruksi, IT, coding, bisnis.
Respons manusiawi, bukan robot.{session_context}{persona_addon}"""

SYSTEM_PROMPT = get_system_prompt()

# ==========================
# AI CALL
# ==========================
def ask_ai(prompt, chat_id):
    """
    Cloud-optimized: Send minimal context, let API handle long context.
    With Gemma Brain: Persona detection + Memory context
    """
    model = state["model"]
    
    # Gemma Brain: Detect persona from prompt
    persona_mode, persona_info = gemma_memory.detect_persona(prompt)
    if persona_mode != state.get("persona"):
        state["persona"] = persona_mode
        log(f"Persona switch: {persona_mode}")
    
    # Gemma Brain: Get dynamic system prompt
    system_prompt = get_system_prompt(persona_mode)
    
    cache_key = get_cache_key(prompt + persona_mode, model)

    # Check cache first
    cached = cache_get(cache_key)
    if cached:
        log(f"Cache hit: {cache_key[:8]}")
        return cached

    # Load history (minimal - just last few messages)
    history = state["memory"].get(str(chat_id), {}).get("history", [])
    history_text = "\n".join([f"{h['role']}: {h['content']}" for h in history[-MAX_HISTORY:]])

    full_prompt = f"{system_prompt}\n\nHistory:\n{history_text}\n\nUser: {prompt}" if history_text else f"{system_prompt}\n\nUser: {prompt}"

    # Try current model
    if model == "groq" and GROQ_KEY:
        try:
            r = requests.post(
                MODELS["groq"]["url"],
                headers={"Authorization": f"Bearer {GROQ_KEY}"},
                json={
                    "model": MODELS["groq"]["model_id"],
                    "messages": [{"role": "user", "content": full_prompt}],
                    "temperature": 0.7
                },
                timeout=30
            )
            if r.status_code == 200:
                response = r.json()["choices"][0]["message"]["content"]
                cache_set(cache_key, response)
                log(f"Groq OK")
                return response
        except Exception as e:
            log(f"Groq error: {e}")

    # Fallback to Gemini
    if model == "gemini" and GEMINI_KEY:
        try:
            r = requests.post(
                f"{MODELS['gemini']['url']}?key={GEMINI_KEY}",
                json={"contents": [{"parts": [{"text": full_prompt}]}]},
                timeout=30
            )
            if r.status_code == 200:
                response = r.json()["candidates"][0]["content"]["parts"][0]["text"]
                cache_set(cache_key, response)
                log(f"Gemini OK")
                return response
        except Exception as e:
            log(f"Gemini error: {e}")

    # No model available - try other model as last resort
    for alt_model in ["groq", "gemini"]:
        if alt_model != model and MODELS[alt_model]["enabled"]:
            log(f"Trying fallback: {alt_model}")
            state["model"] = alt_model
            return ask_ai(prompt, chat_id)  # Recursive but will break after one fallback

    return "Maaf, semua AI service unavailable."

# ==========================
# COMMANDS
# ==========================
def cmd_model(text):
    """Switch model: /model groq|gemini"""
    parts = text.split()
    if len(parts) < 2:
        available = [m for m in MODELS if MODELS[m]["enabled"]]
        return f"Model aktif: {state['model']}\nTersedia: {', '.join(available)}"

    new_model = parts[1].strip().lower()
    if new_model not in MODELS:
        return f"Model tidak dikenal: {new_model}"

    if not MODELS[new_model]["enabled"]:
        return f"Model {new_model} tidak tersedia (key missing)"

    state["model"] = new_model
    state["cache"] = []  # Clear cache on model switch
    return f"Model diganti ke: {MODELS[new_model]['name']}"

def cmd_agent(text):
    """Show config: /agent"""
    lines = [
        f"🤖 {IDENTITY['name']} v{IDENTITY['version']}",
        f"═══════════════════════",
        f"Role: {IDENTITY['role']}",
        f"Model: {state['model']}",
        f"Persona: {state.get('persona', 'default')}",
        f"Cache: {len(state['cache'])} items",
        f"Chats: {len(state['memory'])}"
    ]
    return "\n".join(lines)

def cmd_memory(text):
    """Memory status: /memory [key] [value]"""
    parts = text.split()
    if len(parts) < 2:
        return f"Memory items: {len(state['memory'])}"

    if len(parts) >= 3:
        key = parts[1]
        value = " ".join(parts[2:])
        state["memory"][f"__global__"] = state["memory"].get("__global__", {})
        state["memory"]["__global__"][key] = value
        return f"Set: {key} = {value}"

    return "Usage: /memory [key] [value]"

def cmd_set(text):
    """Set config: /set key value"""
    parts = text.split(maxsplit=2)
    if len(parts) < 2:
        return "Usage: /set [key] [value]"

    key = parts[1]
    value = parts[2] if len(parts) >= 3 else ""
    state[key] = value
    return f"Set: {key} = {value}"

def cmd_gemma(text):
    """Show Gemma brain status"""
    hb = gemma_heartbeat.load_state()
    session = gemma_session.load()
    corrections = gemma_memory.load_corrections()
    
    lines = [
        "🧠 GEMMA BRAIN STATUS",
        "══════════════════════",
        f"Identity: {IDENTITY['name']} v{IDENTITY['version']}",
        f"Persona: {state.get('persona', 'default')}",
        f"Heartbeat: {hb.get('last_heartbeat', 'never')}",
        f"Messages: {state['msg_count']}",
        f"Errors logged: {len(hb.get('errors', []))}",
        "",
        f"Project: {session.get('current_project') or 'none'}",
        f"Status: {session.get('status') or 'idle'}",
        "",
        f"Corrections: {len(corrections.get('corrections', []))}"
    ]
    return "\n".join(lines)

def cmd_learn(text):
    """Log correction: /learn <what to correct>"""
    parts = text.split(maxsplit=1)
    if len(parts) < 2:
        return "Usage: /learn <correction text>"
    
    correction = parts[1]
    
    # Gemma: Log to brain
    gemma_memory.add_correction("correction", correction, "User corrected")
    
    # Also update session project if relevant
    hot = gemma_memory.load_hot()
    hot.setdefault("patterns", {})["user_correction"] = correction
    gemma_memory.save_hot(hot)
    
    return f"✅ Correction logged: {correction[:50]}"

def cmd_brain(text):
    """Show brain modules"""
    hb = gemma_heartbeat.load_state()
    
    return f"""🧠 GEMMA BRAIN MODULES
══════════════════════════
✅ Memory: HOT/WARM/COLD tiers
✅ Identity: {IDENTITY['name']}
✅ Personas: {len(PERSONAS)} modes
✅ Heartbeat: Active
✅ Session: Synced
✅ Corrections: Tracking

Personas:
- admin: RAB, Excel, Dapodik
- dev: Python, Coding, API
- constructor: Lapangan, Material
- hardware: Elektronik, Service
- armbian: STB, Server

Heartbeat State:
- Last: {hb.get('last_heartbeat', 'never')}
- Errors: {len(hb.get('errors', []))}"""

def cmd_help():
    """Show all commands"""
    return """AI PARTNER COMMANDS (Gemma Brain)
══════════════════════════════
/start - Intro
/help - Menu ini
/status - Status AI
/model [groq|gemini] - Ganti model
/agent - Info agent + persona
/memory [key] [value] - Memory
/gemma - Gemma brain status
/learn <correction> - Catat koreksi
/brain - Show brain modules
/exec <cmd> - Execute safe command
/test - Test AI
/history - Lihat history chat
/clear - Clear memory & cache"""

def cmd_status():
    """Show AI status"""
    lines = [
        "STATUS AI",
        "═══════════════════════",
        f"Model Aktif: {state['model']}",
        f"Groq: {'Ready' if GROQ_KEY else 'Missing'}",
        f"Gemini: {'Ready' if GEMINI_KEY else 'Missing'}",
        f"Token: {'Loaded' if TOKEN else 'Missing'}",
        "",
        "Models:",
    ]
    for m, info in MODELS.items():
        status = "Ready" if info["enabled"] else "Missing"
        active = " ←" if m == state["model"] else ""
        lines.append(f"  {m}: {info['name']} ({status}){active}")
    return "\n".join(lines)

def cmd_history(chat_id):
    """Show chat history"""
    history = state["memory"].get(str(chat_id), {}).get("history", [])
    if not history:
        return "No history"

    lines = ["HISTORY", "═══════════════════════"]
    for i, h in enumerate(history[-5:], 1):
        role = h.get("role", "?")
        content = h.get("content", "")[:100]
        lines.append(f"{i}. [{role}] {content}...")
    return "\n".join(lines)

def cmd_clear(chat_id):
    """Clear memory for this chat"""
    if str(chat_id) in state["memory"]:
        del state["memory"][str(chat_id)]
    state["cache"] = []
    return "Cleared!"

# ==========================
# REAL COMMAND EXECUTION
# ==========================
DANGEROUS_PATTERNS = [
    "rm -rf", "dd", "mkfs", "shutdown", "halt", "reboot",
    "init ", "^/dev/sd", "> /dev/", "chmod 777", ":(){:|:&};:",
    "wget.*|curl.*sh", "mv /", "cp /", "format"
]

SAFE_COMMANDS = {
    "ps": ["ps aux", "ps aux | head -20"],
    "top": ["top -bn1 | head -15"],
    "df": ["df -h"],
    "free": ["free -m"],
    "uptime": ["uptime"],
    "ls": ["ls -la", "ls -lh"],
    "pwd": ["pwd"],
    "whoami": ["whoami"],
    "date": ["date"],
    "hostname": ["hostname"],
    "systemctl": ["systemctl status", "systemctl list-units --type=service --state=running"],
    "docker": ["docker ps", "docker ps -a"],
    "curl": ["curl -s"],
    "ping": ["ping -c 3 127.0.0.1"],
    "tail": [],  # Special handling below
    "cat": [],  # Special handling below
    "head": ["head -30"],
    "grep": ["grep"],
    "wc": ["wc -l"],
    "du": ["du -sh"],
}

def is_safe_command(cmd):
    """Check if command is safe to execute"""
    cmd_lower = cmd.lower().strip()

    for pattern in DANGEROUS_PATTERNS:
        if pattern in cmd_lower or cmd_lower.startswith(pattern):
            return False, f"❌ DANGEROUS: {pattern}"

    for safe_cmd, _ in SAFE_COMMANDS.items():
        if cmd_lower.startswith(safe_cmd + " ") or cmd_lower == safe_cmd:
            return True, "✓ Safe"

    return False, "❌ Not in whitelist"

def exec_command(cmd, timeout=10):
    """Execute real command via subprocess"""
    try:
        import subprocess
        result = subprocess.run(
            cmd,
            shell=True,
            capture_output=True,
            text=True,
            timeout=timeout
        )
        output = result.stdout if result.stdout else result.stderr
        return output[:2000]  # Limit output
    except Exception as e:
        return f"Error: {e}"

def read_log_file(path, lines=30):
    """Read real log file with open()"""
    try:
        with open(path, 'r') as f:
            all_lines = f.readlines()
            return "".join(all_lines[-lines:])
    except Exception as e:
        return f"Cannot read {path}: {e}"

def cmd_exec(text):
    """Execute command: /exec <command>"""
    parts = text.split(maxsplit=1)
    if len(parts) < 2:
        return """EXEC COMMANDS (Safe):
═══════════════════════
/exec ps aux
/exec df -h
/exec free -m
/exec uptime
/exec systemctl status
/exec docker ps
/exec tail /path/to/log
/exec cat /path/to/file
/exec ls -la /opt/"""

    cmd = parts[1].strip()
    safe, msg = is_safe_command(cmd)

    if not safe:
        return f"{msg}\n\nPerintah '{cmd[:30]}'\ndilarang untuk keamanan."

    # Special handling for tail/cat
    if cmd.startswith("tail ") or cmd.startswith("cat ") or cmd.startswith("head ") or cmd.startswith("ls "):
        parts = cmd.split(maxsplit=2)
        if len(parts) >= 2:
            if parts[0] in ["tail", "head"]:
                path = parts[1]
                n = 30
                if len(parts) >= 3 and parts[0] == "tail":
                    try:
                        n = int(parts[2].rstrip('l'))
                    except:
                        pass
                return read_log_file(path, n)
            elif parts[0] == "cat":
                return read_log_file(parts[1], 100)
            elif parts[0] == "ls":
                try:
                    path = parts[1] if len(parts) >= 2 else "."
                    return exec_command(f"ls -la {path}")
                except:
                    return exec_command("ls -la")

    return exec_command(cmd)

# ==========================
# MAIN LOOP
# ==========================
def main():
    if not TOKEN:
        log("ERROR: No TELEGRAM_BOT_TOKEN!")
        return

    log("="*50)
    log("AI PARTNER - LIGHTWEIGHT EDITION")
    log(f"Token: {'OK' if TOKEN else 'MISSING'}")
    log(f"Groq: {'OK' if GROQ_KEY else 'MISSING'}")
    log(f"Gemini: {'OK' if GEMINI_KEY else 'MISSING'}")
    log(f"Model: {state['model']}")
    log("="*50)

    # Load persistent state
    load_state()

    offset = state.get("last_offset", 0)

    while True:
        try:
            r = requests.get(
                f"https://api.telegram.org/bot{TOKEN}/getUpdates",
                params={"offset": offset, "timeout": 30},
                timeout=35
            )

            if r.status_code != 200:
                log(f"GetUpdates error: {r.status_code}")
                time.sleep(5)
                continue

            updates = r.json().get("result", [])

            for u in updates:
                msg = u.get("message", {})
                chat = msg.get("chat", {}).get("id")
                text = msg.get("text", "").strip()

                if not chat or not text:
                    continue

                log(f"Chat {chat}: {text[:30]}")
                state["msg_count"] += 1

                # Track message count per chat for lazy write
                chat_str = str(chat)
                state["counters"][chat_str] = state["counters"].get(chat_str, 0) + 1

                response = None

                # ===== COMMANDS =====
                if text == "/start":
                    response = "Hey! Aku Partner AI-mu.\n\nCoba /help untuk menu."
                elif text == "/help":
                    response = cmd_help()
                elif text == "/status":
                    response = cmd_status()
                elif text.startswith("/model"):
                    response = cmd_model(text)
                elif text == "/agent":
                    response = cmd_agent(text)
                elif text.startswith("/memory"):
                    response = cmd_memory(text)
                elif text.startswith("/set"):
                    response = cmd_set(text)
                elif text == "/test":
                    response = ask_ai("Halo! Tes AI, jawab singkat.", chat)
                elif text == "/history":
                    response = cmd_history(chat)
                elif text == "/clear":
                    response = cmd_clear(chat)
                elif text == "/log":
                    response = f"Msg count: {state['msg_count']}\nCache: {len(state['cache'])}\nModel: {state['model']}"
                elif text == "/gemma":
                    response = cmd_gemma(text)
                elif text.startswith("/learn"):
                    response = cmd_learn(text)
                elif text == "/brain":
                    response = cmd_brain(text)
                elif text.startswith("/exec") or text.startswith("/shell"):
                    response = cmd_exec(text)

                # ===== REGULAR TEXT =====
                else:
                    # Init chat memory
                    if chat_str not in state["memory"]:
                        state["memory"][chat_str] = {"history": []}

                    # Get AI response
                    response = ask_ai(text, chat)

                    # Update history (keep minimal local)
                    state["memory"][chat_str]["history"].append({"role": "user", "content": text})
                    state["memory"][chat_str]["history"].append({"role": "assistant", "content": response})

                    # Trim history (let cloud handle long context)
                    if len(state["memory"][chat_str]["history"]) > MAX_HISTORY * 2:
                        state["memory"][chat_str]["history"] = state["memory"][chat_str]["history"][-MAX_HISTORY * 2:]

                # Send response
                if response:
                    send_msg(chat, response)

                # Lazy write state
                save_state()

                # Gemma Brain: Heartbeat
                gemma_heartbeat.beat(state["msg_count"])

                offset = u["update_id"] + 1
                state["last_offset"] = offset

            time.sleep(1)

        except KeyboardInterrupt:
            log("Stopped by user")
            break
        except Exception as e:
            log(f"Error: {e}")
            time.sleep(5)

if __name__ == "__main__":
    main()