# HOT Memory — Template

> This file is created in `brain/cognitive/memory.md` when you first use the skill.
> Keep it ≤100 lines. Most-used patterns live here.

## Example Entries

```markdown
## Preferences
- Code style: Prefer explicit over implicit
- Communication: Direct, no fluff
- Time zone: Europe/Madrid

## Patterns (promoted from corrections)
- Always use TypeScript strict mode
- Prefer pnpm over npm
- Format: ISO 8601 for dates
- Session state WAJIB include project_file path saat berdiskusi tentang file spesifik
- STB Server: Use sshpass dengan password tersimpan untuk auto-connect ke 192.168.1.11

## Project defaults
- Tests: Jest with coverage >80%
- Commits: Conventional commits format

## Achievements (2026-04-21)
- 🏆 Gemma Brain: Self-improving cognitive system untuk Telegram AI Agent
  - Implemented 5 persona modes, memory tiers, heartbeat, corrections
  - Deployed ke STB 192.168.1.11
  - /gemma, /brain, /learn commands active
```

## Usage

The agent will:
1. Load this file on every session
2. Add entries when patterns are used 3x in 7 days
3. Demote unused entries to WARM after 30 days
4. Never exceed 100 lines (compacts automatically)
