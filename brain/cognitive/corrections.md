# Corrections Log — Template

> This file is created in `brain/cognitive/corrections.md` when you first use the skill.
> Keeps the last 50 corrections. Older entries are evaluated for promotion or archived.

## Example Entries

```markdown
## 2026-02-19

### 14:32 — Code style
- **Correction:** "Use 2-space indentation, not 4"
- **Context:** Editing TypeScript file
- **Count:** 1 (first occurrence)

### 16:15 — Communication
- **Correction:** "Don't start responses with 'Great question!'"
- **Context:** Chat response
- **Count:** 3 → **PROMOTED to memory.md**

## 2026-02-18

### 09:00 — Project: website
- **Correction:** "For this project, always use Tailwind"
- **Context:** CSS discussion
- **Action:** Added to projects/website.md
```

## 2026-04-21

### 12:05 — Memory
- **Correction:** "Apa kamu ingat state terakhir? Kita tadi sedang mendiskusikan... berarti ga ada memory yang kamu ingat"
- **Context:** Session state mismatch - project agent.py tidak tercatat
- **Action:** Updated session_state.json with project_file reference

---

## Log Format

Each entry includes:
- **Timestamp** — When the correction happened
- **Correction** — What the user said
- **Context** — What triggered it
- **Count** — How many times (for promotion tracking)
- **Action** — Where it was stored (if promoted)
