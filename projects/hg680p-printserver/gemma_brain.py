#!/usr/bin/env python3
"""
Gemma Brain Module
Self-improving cognitive system for Telegram AI Agent
Ported from brain/AGENTS.md principles
"""

import json
import os
from pathlib import Path
from datetime import datetime

# ==========================
# GEMMA IDENTITY
# ==========================
IDENTITY = {
    "name": "Architect_Dev_Prime",
    "version": "3.1",
    "role": "Senior Civil Engineer | Full-Stack Developer | Electronics Diagnostician",
    "objective": "Never-Ending Improvements"
}

# ==========================
# PERSONA MODES (Dynamic Switching)
# ==========================
PERSONAS = {
    "admin": {
        "trigger": ["rab", "pupr", "kerusakan", "form", "excel", "dapodik", "laporan", "sipil"],
        "role": "Konsultan Pengawas & Admin Proyek",
        "focus": "Integritas data formulir, validasi regulasi"
    },
    "dev": {
        "trigger": ["python", "script", "coding", "error", "api", "library", "debug", "automate"],
        "role": "Senior Software Engineer",
        "focus": "Clean Code, automation, error handling"
    },
    "constructor": {
        "trigger": ["cara pasang", "campuran beton", "denah", "ukuran", "lapangan", "tukang", "material"],
        "role": "Pelaksana Lapangan / Site Manager",
        "focus": "Metode kerja praktis, estimasi material"
    },
    "hardware": {
        "trigger": ["hp mati", "laptop", "solder", "multimeter", "short", "lcd", "baterai", "bootloop", "service"],
        "role": "Teknisi Elektronika & IT",
        "focus": "Signal Flow diagnostic, ESD Safe"
    },
    "armbian": {
        "trigger": ["hg680p", "armbian", "printserver", "tailscale", "cups", "ssh"],
        "role": "System Administrator & DevOps",
        "focus": "High-availability, remote access"
    }
}

# ==========================
# MEMORY TIERS
# ==========================
class GemmaMemory:
    def __init__(self, data_dir):
        self.data_dir = Path(data_dir)
        self.hot_file = self.data_dir / "memory_hot.json"
        self.warm_file = self.data_dir / "memory_warm.json"
        self.corrections_file = self.data_dir / "corrections.json"
        
    def load_hot(self):
        """Load HOT memory (always needed)"""
        if self.hot_file.exists():
            try:
                return json.loads(self.hot_file.read_text())
            except:
                pass
        return {"preferences": {}, "patterns": {}, "session": {}}
    
    def save_hot(self, data):
        """Save HOT memory"""
        self.hot_file.write_text(json.dumps(data, indent=2))
    
    def load_corrections(self):
        """Load corrections log"""
        if self.corrections_file.exists():
            try:
                return json.loads(self.corrections_file.read_text())
            except:
                pass
        return {"corrections": [], "counters": {}}
    
    def save_corrections(self, data):
        """Save corrections"""
        self.corrections_file.write_text(json.dumps(data, indent=2))
    
    def add_correction(self, correction_type, context, correct_answer):
        """Log a correction for learning"""
        data = self.load_corrections()
        entry = {
            "timestamp": datetime.now().isoformat(),
            "type": correction_type,
            "context": context[:100],
            "answer": correct_answer[:200],
            "count": 1
        }
        
        # Check for duplicate
        key = f"{correction_type}:{context[:50]}"
        for c in data["corrections"]:
            if f"{c.get('type')}:{c.get('context','')[:50]}" == key:
                c["count"] = c.get("count", 1) + 1
                c["timestamp"] = entry["timestamp"]
                break
        else:
            data["corrections"].append(entry)
        
        # Keep only last 50
        data["corrections"] = data["corrections"][-50:]
        self.save_corrections(data)
    
    def detect_persona(self, text):
        """Detect persona from text input"""
        text_lower = text.lower()
        for mode, info in PERSONAS.items():
            for trigger in info["trigger"]:
                if trigger in text_lower:
                    return mode, info
        return "default", {"role": "Partner AI", "focus": "General assistance"}
    
    def get_system_prompt_addon(self, persona_mode=None):
        """Get system prompt based on persona"""
        hot = self.load_hot()
        patterns = hot.get("patterns", {})
        
        prompt_parts = []
        
        # Add persona context
        if persona_mode and persona_mode in PERSONAS:
            p = PERSONAS[persona_mode]
            prompt_parts.append(f"\n[PERSONA: {p['role']}]")
            prompt_parts.append(f"Fokus: {p['focus']}")
        
        # Add learned patterns
        if patterns:
            prompt_parts.append("\n[PREFERENCES - JANGAN LUPA:]")
            for k, v in patterns.items():
                prompt_parts.append(f"- {k}: {v}")
        
        return "\n".join(prompt_parts)

# ==========================
# HEARTBEAT SYSTEM
# ==========================
class GemmaHeartbeat:
    def __init__(self, data_dir):
        self.data_dir = Path(data_dir)
        self.state_file = self.data_dir / "heartbeat_state.json"
        
    def load_state(self):
        if self.state_file.exists():
            try:
                return json.loads(self.state_file.read_text())
            except:
                pass
        return {
            "last_heartbeat": "never",
            "last_reviewed_change": "never",
            "msg_count": 0,
            "errors": []
        }
    
    def save_state(self, data):
        self.state_file.write_text(json.dumps(data, indent=2))
    
    def beat(self, msg_count):
        """Perform heartbeat check"""
        state = self.load_state()
        now = datetime.now().isoformat()
        
        # Simple heartbeat - every 50 messages
        if msg_count % 50 == 0:
            state["last_heartbeat"] = now
            state["msg_count"] = msg_count
            self.save_state(state)
            return True
        return False
    
    def log_error(self, error_msg):
        """Log error for self-improvement"""
        state = self.load_state()
        state["errors"].append({
            "timestamp": datetime.now().isoformat(),
            "error": error_msg[:200]
        })
        state["errors"] = state["errors"][-20:]  # Keep last 20
        self.save_state(state)

# ==========================
# SESSION AWARENESS
# ==========================
class GemmaSession:
    def __init__(self, data_dir):
        self.data_dir = Path(data_dir)
        self.session_file = self.data_dir / "session.json"
        
    def load(self):
        if self.session_file.exists():
            try:
                return json.loads(self.session_file.read_text())
            except:
                pass
        return {
            "current_project": None,
            "project_file": None,
            "status": "idle",
            "next_step": None,
            "pending_tasks": []
        }
    
    def save(self, data):
        self.session_file.write_text(json.dumps(data, indent=2))
    
    def update(self, **kwargs):
        """Update session fields"""
        data = self.load()
        data.update(kwargs)
        data["last_update"] = datetime.now().isoformat()
        self.save(data)
        return data
    
    def get_context(self):
        """Get current context for AI"""
        data = self.load()
        if data.get("current_project"):
            return f"[PROJECT: {data['current_project']}] [STATUS: {data.get('status','idle')}] [NEXT: {data.get('next_step','none')}]"
        return ""
