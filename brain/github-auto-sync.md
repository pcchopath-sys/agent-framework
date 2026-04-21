---
name: github-auto-sync
description: Automatic GitHub sync after task completion. Auto-commit and push changes to the appropriate repository.
---

# GitHub Auto-Sync Skill

## Trigger Conditions

Automatically sync to GitHub when:
1. Task completed successfully (debug fix, new feature, new project)
2. New file created in projects/
3. Brain files updated (AGENTS.md, SKILL.md, memory.md)
4. Before session ends
5. User requests `/sync`

## Repository Mapping

| Local Path | GitHub Repo |
|------------|-------------|
| brain/ | pcchopath-sys/agent-framework |
| tools/ | pcchopath-sys/agent-framework |
| scripts/ | pcchopath-sys/agent-framework |
| projects/hg680p-printserver/ | pcchopath-sys/hg680p-printserver |
| projects/*/ | pcchopath-sys/agent-framework (fallback) |
| claude-local-ui/ | pcchopath-sys/claude-local-ui |

## Workflow

### 1. Detect Changes
```bash
git status
git diff --stat
```

### 2. Determine Repo
Based on changed files, determine target repository.

### 3. Auto-Commit
```bash
git add <changed-files>
git commit -m "[AUTO] <task-description> - $(date +%Y-%m-%d)"
```

### 4. Push
```bash
git push origin main
```

## Commit Message Format

```
[TYPE] Description - YYYY-MM-DD

Types:
- [FIX] - Bug fix
- [FEAT] - New feature
- [UPDATE] - Update existing
- [NEW] - New project/file
- [AUTO] - Auto-generated sync
```

## Error Handling

If push fails:
1. Log error to session_state.json
2. Notify user: "Sync failed, manual push required"
3. Save push queue for retry

## Never-Ending Improvements

Track sync history:
- Last sync timestamp
- Success/failure count
- Queue for retry

Store in: `logs/github_sync.json`

## Configuration

```json
{
  "repos": {
    "agent-framework": "pcchopath-sys/agent-framework",
    "hg680p-printserver": "pcchopath-sys/hg680p-printserver",
    "claude-local-ui": "pcchopath-sys/claude-local-ui"
  },
  "auto_sync": true,
  "sync_before_end": true
}
```
