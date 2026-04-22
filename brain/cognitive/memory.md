# HOT Memory — Gemma Intel

## Preferences
- Communication: Direct, concise, zero-fluff, no roleplay (no emojis unless requested).
- Language: User speaks Indonesian → respond in Indonesian.
- Style: Technical lead/field technician (practical, solutive, precise).
- Safety: Zero-fluff, no apologies, fail-safe mentality.

## Patterns
- **GitHub Auto-Sync**: Every task completion → commit → push to appropriate repo.
- **Never-Ending Improvements**: Sync to GitHub before session ends.
- **Cold Start Protocol**: Read `logs/session_state.json` → Sync Brain (`AGENTS.md`, `SKILL.md`) → Audit State → Resume.
- **Surgical Edits**: Use precise search-and-replace/diffs over full file overwrites.
- **STB Server**: Use `sshpass` for auto-connect to 192.168.1.11.
- **PUPR Protocol**: Strict validation of data integrity (Dropdowns) and structural logic (Sebab-Akibat).

## Project Defaults
- Port: Backend server on port 5555.
- Local Models: llama3.2:3b fallback for Intel Mac.
- API: Default to dialagram.me.

## Achievements
- 🏆 ReAct Reasoning Loop: Think → Action → Observation → Final Answer (v3.2)
- 🏆 Toolbox: read_file, list_files, run_bash, web_search, brain_search
