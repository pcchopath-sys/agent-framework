#!/usr/bin/env python3
"""
GitHub Auto-Sync Tool
Auto-commit and push changes to appropriate GitHub repository
"""

import os
import json
import subprocess
import sys
from pathlib import Path
from datetime import datetime
from dotenv import load_dotenv

# Load environment variables
SCRIPT_DIR = Path(__file__).parent.parent
load_dotenv(SCRIPT_DIR / ".env")

# ==========================
# CONFIG from .env
# ==========================
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN", "").strip()
GITHUB_USER = os.getenv("GITHUB_USER", "pcchopath-sys")

REPOS = {
    "brain": "agent-framework",
    "tools": "agent-framework", 
    "scripts": "agent-framework",
    "deploy": "agent-framework",
    "hg680p-printserver": "hg680p-printserver",
    "claude-local-ui": "claude-local-ui"
}

# Use HTTPS with token for better portability (no SSH key needed)
GITHUB_BASE = f"https://{GITHUB_USER}:{GITHUB_TOKEN}@github.com" if GITHUB_TOKEN else "git@github.com:pcchopath-sys"

LOG_FILE = SCRIPT_DIR / "logs" / "github_sync.json"

# ==========================
# HELPERS
# ==========================
def log(msg):
    print(f"[GitHub-Sync] {msg}")

def get_changed_files():
    """Get list of changed files"""
    try:
        result = subprocess.run(
            ["git", "status", "--porcelain"],
            capture_output=True, text=True, timeout=10
        )
        return [line[3:] for line in result.stdout.strip().split('\n') if line]
    except Exception as e:
        log(f"Error getting changes: {e}")
        return []

def determine_repo(changed_files):
    """Determine which repo to push to based on changed files"""
    for file_path in changed_files:
        for key, repo in REPOS.items():
            if key in file_path:
                return repo
    return "agent-framework"  # default

def get_remote_url(repo_name):
    """Get remote URL - use HTTPS with token if available, else SSH"""
    if GITHUB_TOKEN:
        return f"https://{GITHUB_USER}:{GITHUB_TOKEN}@github.com/{GITHUB_USER}/{repo_name}.git"
    else:
        return f"git@github.com:{GITHUB_USER}/{repo_name}.git"

def commit_and_push(repo_name, message):
    """Commit and push to specified repo"""
    log(f"Syncing to: {repo_name}")
    
    try:
        # Add all changes
        subprocess.run(["git", "add", "-A"], check=True, timeout=10)
        
        # Check if there are changes to commit
        result = subprocess.run(
            ["git", "status", "--porcelain"],
            capture_output=True, text=True, timeout=10
        )
        
        if not result.stdout.strip():
            log("No changes to commit")
            return True
        
        # Commit
        commit_msg = f"[AUTO] {message} - {datetime.now().strftime('%Y-%m-%d')}"
        subprocess.run(["git", "commit", "-m", commit_msg], check=True, timeout=10)
        log(f"Committed: {commit_msg}")
        
        # Push
        subprocess.run(["git", "push", "origin", "main"], check=True, timeout=60)
        log(f"✅ Pushed to {repo_name}")
        
        return True
        
    except subprocess.CalledProcessError as e:
        log(f"❌ Error: {e}")
        return False
    except Exception as e:
        log(f"❌ Exception: {e}")
        return False

def log_sync(repo_name, status, message):
    """Log sync attempt"""
    LOG_FILE.parent.mkdir(parents=True, exist_ok=True)
    
    try:
        if LOG_FILE.exists():
            data = json.loads(LOG_FILE.read_text())
        else:
            data = {"syncs": []}
        
        data["syncs"].append({
            "timestamp": datetime.now().isoformat(),
            "repo": repo_name,
            "status": status,
            "message": message
        })
        
        # Keep last 50 syncs
        data["syncs"] = data["syncs"][-50:]
        
        LOG_FILE.write_text(json.dumps(data, indent=2))
    except:
        pass

# ==========================
# MAIN
# ==========================
def main():
    import argparse
    
    parser = argparse.ArgumentParser(description="GitHub Auto-Sync")
    parser.add_argument("-m", "--message", default="Task completed", help="Commit message")
    parser.add_argument("-r", "--repo", help="Force specific repo")
    args = parser.parse_args()
    
    # Check if in a git repo
    if not Path(".git").exists():
        log("Not in a git repository")
        sys.exit(1)
    
    # Get changed files
    changed = get_changed_files()
    
    if not changed:
        log("No changes detected")
        sys.exit(0)
    
    log(f"Changed files: {len(changed)}")
    
    # Determine repo
    repo = args.repo or determine_repo(changed)
    log(f"Target repo: {repo}")
    
    # Set remote if needed
    remote_url = get_remote_url(repo)
    
    try:
        result = subprocess.run(
            ["git", "remote", "get-url", "origin"],
            capture_output=True, text=True, timeout=5
        )
        current_remote = result.stdout.strip()
    except:
        current_remote = None
    
    if not current_remote:
        log(f"Setting remote to {remote_url}")
        subprocess.run(["git", "remote", "add", "origin", remote_url], check=True)
    elif remote_url not in current_remote:
        log(f"Updating remote to {remote_url}")
        subprocess.run(["git", "remote", "set-url", "origin", remote_url], check=True)
    
    # Commit and push
    success = commit_and_push(repo, args.message)
    
    # Log result
    log_sync(repo, "success" if success else "failed", args.message)
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
