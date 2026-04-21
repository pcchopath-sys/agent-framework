---
name: self-improvement
description: "Captures learnings, errors, and corrections to enable continuous improvement. Use when: (1) A command or operation fails unexpectedly, (2) User corrects Claude, (3) User requests a capability that doesn't exist, (4) An external API or tool fails, (5) Knowledge is outdated, (6) A better approach is discovered."
---

# Self-Improvement Skill

Log learnings and errors to `.learnings/` directory for continuous improvement.

## Workflow
1. **Log**: Append to `.learnings/LEARNINGS.md`, `ERRORS.md`, or `FEATURE_REQUESTS.md`.
2. **Review**: Analyze recurring patterns during session breakpoints.
3. **Promote**: Elevate broadly applicable insights to `CLAUDE.md` or `AGENTS.md`.

## Logging Format
- **Learning [LRN-YYYYMMDD-XXX]**: category | Priority | Status | Area | Summary | Details | Suggested Action.
- **Error [ERR-YYYYMMDD-XXX]**: skill/command | Priority | Status | Area | Summary | Error | Context | Suggested Fix.
- **Feature [FEAT-YYYYMMDD-XXX]**: capability | Priority | Status | Area | Requested Capability | Context | Complexity | Implementation.

## Promotion Targets
- `CLAUDE.md`: Project facts, conventions, and critical gotchas.
- `AGENTS.md`: Agent workflows, automation rules, and tool usage patterns.

## Recurring Pattern Detection
If a pattern occurs >= 3 times across 2+ tasks, promote it immediately to permanent project memory.
