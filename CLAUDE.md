# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`ticket` is a minimal ticket/issue tracking system implemented as a single bash script. Tickets are stored as markdown files with YAML frontmatter in `.tickets/`. Supports dependency tracking, priority levels, and various listing/query modes.

## Commands

Run the script directly:
```bash
./ticket <command> [args]
```

### Ticket Creation

| Command | Description |
|---------|-------------|
| `create [title] [options]` | Create ticket, prints ID |

Options for `create`:
- `-d, --description` - Description text
- `--design` - Design notes
- `--acceptance` - Acceptance criteria
- `-t, --type` - Type: bug, feature, task, epic, chore (default: task)
- `-p, --priority` - Priority 0-4, 0=highest (default: 2)
- `-a, --assignee` - Assignee (defaults to git user.name)
- `--external-ref` - External reference (e.g., gh-123, JIRA-456)

### Status Management

| Command | Description |
|---------|-------------|
| `start <id>` | Set status to in_progress |
| `close <id>` | Set status to closed |
| `reopen <id>` | Set status to open |
| `status <id> <status>` | Set status (open, in_progress, closed) |

### Dependencies

| Command | Description |
|---------|-------------|
| `dep <id> <dep-id>` | Add dependency (id depends on dep-id) |
| `dep tree [--full] <id>` | Show dependency tree (--full disables dedup) |
| `undep <id> <dep-id>` | Remove dependency |

### Listing & Queries

| Command | Description |
|---------|-------------|
| `ls [--status=X]` | List tickets, optionally filtered by status |
| `ready` | List open/in_progress tickets with all deps closed (sorted by priority) |
| `blocked` | List open/in_progress tickets with unresolved deps |
| `closed [--limit=N]` | List recently closed tickets (default 20, by mtime) |
| `show <id>` | Display ticket content |
| `edit <id>` | Open ticket in $EDITOR |
| `query [jq-filter]` | Output tickets as JSON, optionally filtered |

### Migration

| Command | Description |
|---------|-------------|
| `migrate-beads` | Import tickets from .beads/issues.jsonl |

Partial ID matching is supported (e.g., `./ticket show abc` matches `t-abc1234`).

## Ticket Format

Tickets are markdown files in `.tickets/` with YAML frontmatter:
```yaml
---
id: t-xxxx
status: open
deps: [dep-id-1, dep-id-2]
created: 2025-01-01T00:00:00-05:00
type: task
priority: 2
assignee: username
external-ref: gh-123
---
# Ticket Title

Description...

## Design

Design notes...

## Acceptance Criteria

Acceptance criteria...
```

### Fields

- `status`: open, in_progress, closed
- `type`: bug, feature, task, epic, chore
- `priority`: 0 (highest) to 4 (lowest), default 2
- `deps`: array of ticket IDs this ticket depends on

## Architecture

Single-file bash implementation (~900 lines). Uses awk for performant bulk operations on large ticket sets.

Key functions:
- `generate_id()` - Creates IDs from directory name prefix + timestamp hash
- `ticket_path()` - Resolves partial IDs to full file paths
- `yaml_field()` / `update_yaml_field()` - YAML frontmatter manipulation via sed
- `cmd_*()` - Command handlers
- `cmd_ready()`, `cmd_blocked()`, `cmd_ls()` - awk-based bulk listing with sorting

Dependencies: bash, sed, awk, find. Optional: ripgrep (faster grep), jq (for query command).
