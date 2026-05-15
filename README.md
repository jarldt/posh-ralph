# Ralph

![Ralph](ralph.webp)

Ralph is an autonomous AI agent loop that runs AI coding tools ([Amp](https://ampcode.com?utm_source=chatgpt.com) or [Claude Code](https://docs.anthropic.com/en/docs/claude-code?utm_source=chatgpt.com)) repeatedly until all PRD items are complete. Each iteration is a fresh instance with clean context. Memory persists via git history, `progress.txt`, and `prd.json`.

Based on [Geoffrey Huntley's Ralph pattern](https://ghuntley.com/ralph/?utm_source=chatgpt.com).

[Read my in-depth article on how I use Ralph](https://x.com/ryancarson/status/2008548371712135632?utm_source=chatgpt.com)

## Prerequisites

### Required

- A git repository for your project
- One of the following AI coding tools installed and authenticated:
  - [Amp CLI](https://ampcode.com) (default)
  - [Claude Code](https://docs.anthropic.com/en/docs/claude-code)

### Windows / PowerShell Requirements

If using Ralph for PowerShell projects on Windows:

Install with:

```powershell
Install-Module Pester -Force -Scope CurrentUser
Install-Module PSScriptAnalyzer -Force -Scope CurrentUser
```

Verify:

```powershell
Get-Module Pester -ListAvailable
Get-Module PSScriptAnalyzer -ListAvailable
```

## Setup

### Option 1: Copy to your project

Copy the Ralph files into your project:

```powershell
# From your project root
New-Item -ItemType Directory -Force -Path .\scripts\ralph | Out-Null
Copy-Item C:\path\to\ralph\ralph.ps1 .\scripts\ralph\

# Copy the prompt template for your AI tool of choice:
Copy-Item C:\path\to\ralph\prompt.md .\scripts\ralph\prompt.md    # For Amp
# OR
Copy-Item C:\path\to\ralph\CLAUDE.md .\scripts\ralph\CLAUDE.md    # For Claude Code
```

### Option 2: Install skills globally (Amp)

Copy the skills into your Amp configuration so they are available across all projects.

For AMP:

```powershell
New-Item -ItemType Directory -Force -Path "$HOME\.config\amp\skills" | Out-Null

Copy-Item -Recurse .\skills\prd "$HOME\.config\amp\skills\"
Copy-Item -Recurse .\skills\ralph "$HOME\.config\amp\skills\"
```

For Claude Code (manual):

```powershell
New-Item -ItemType Directory -Force -Path "$HOME\.claude\skills" | Out-Null

Copy-Item -Recurse .\skills\prd "$HOME\.claude\skills\"
Copy-Item -Recurse .\skills\ralph "$HOME\.claude\skills\"
```

---

### Option 3: Use as Claude Code Marketplace

Add the Ralph marketplace to Claude Code:

```text
/plugin marketplace add snarktank/ralph
```

Then install the skills:

```text
/plugin install ralph-skills@ralph-marketplace
```

Available skills after installation:

- `/prd` — Generate Product Requirements Documents
- `/ralph` — Convert PRDs to `prd.json` format

Skills are automatically invoked when you ask Claude to:

- "create a prd"
- "write prd for"
- "plan this feature"
- "convert this prd"
- "turn into ralph format"
- "create prd.json"

---

### Configure Amp auto-handoff (recommended)

Create or edit:

```text
%USERPROFILE%\.config\amp\settings.json
```

Add:

```json
{
  "amp.experimental.autoHandoff": {
    "context": 90
  }
}
```

This allows Amp to automatically hand off context when a story exceeds a single context window.

## Workflow

### 1. Create a PRD

Use the PRD skill to generate a detailed requirements document:

```text
Load the prd skill and create a PRD for [your feature description]
```

Answer the clarifying questions. The skill saves output to `tasks/prd-[feature-name].md`.

### 2. Convert PRD to Ralph format

Use the Ralph skill to convert the markdown PRD to JSON:

```text
Load the ralph skill and convert tasks/prd-[feature-name].md to prd.json
```

This creates `prd.json` with user stories structured for autonomous execution.

### 3. Run Ralph

#### Windows

```cmd
powershell.exe -ExecutionPolicy Bypass -File .\scripts\ralph\ralph.ps1 -Tool amp
powershell.exe -ExecutionPolicy Bypass -File .\scripts\ralph\ralph.ps1 -Tool claude
```

Default is 10 iterations.

Ralph will:

1. Create a feature branch (from PRD `branchName`)
2. Pick the highest priority story where `passes: false`
3. Implement that single story
4. Run quality checks
5. Commit if checks pass
6. Update `prd.json` to mark story as `passes: true`
7. Append learnings to `progress.txt`
8. Repeat until all stories pass or max iterations reached

## Key Files

| File | Purpose |
|------|---------|
| `ralph.ps1` | PowerShell loop for Windows |
| `prompt.md` | Prompt template for Amp |
| `CLAUDE.md` | Prompt template for Claude Code |
| `prd.json` | User stories with `passes` status |
| `prd.json.example` | Example PRD format |
| `progress.txt` | Append-only learnings |
| `skills/prd/` | Skill for generating PRDs |
| `skills/ralph/` | Skill for converting PRDs to JSON |
| `.claude-plugin/` | Marketplace manifest |
| `flowchart/` | Interactive visualization |

## Flowchart

[![Ralph Flowchart](ralph-flowchart.png)](https://snarktank.github.io/ralph/)

**[View Interactive Flowchart](https://snarktank.github.io/ralph/?utm_source=chatgpt.com)** - Click through to see each step.

## Critical Concepts

### Each Iteration = Fresh Context

Each iteration spawns a new AI instance. Memory between iterations:

- Git history
- `progress.txt`
- `prd.json`

### Small Tasks

Each PRD item should be small enough to complete in one context window.

Good:

- Add a database column
- Add a UI component
- Add a dropdown
- Update one service

Too large:

- Build entire dashboard
- Add auth
- Refactor API

### AGENTS.md Updates Are Critical

After each iteration, Ralph updates relevant `AGENTS.md` files so future runs inherit project learnings automatically.

### Feedback Loops

Ralph only works if there are feedback loops:

- Lint
- Tests
- Git commits
- Human review

### PowerShell Projects

For PowerShell projects, quality checks should include:

```powershell
Invoke-ScriptAnalyzer -Path ./src -Recurse
Invoke-Pester -Path ./tests
```

These checks are critical for catching runtime regressions before they compound across iterations.

### Stop Condition

When all stories have `passes: true`, Ralph outputs:

```xml
<promise>COMPLETE</promise>
```

## Debugging

Check current state:

```bash
# See which stories are done
cat prd.json

# See learnings
cat progress.txt

# Check git history
git log --oneline -10
```

## Customizing the Prompt

After copying `prompt.md` or `CLAUDE.md`, customize it for your project:

- Add project-specific checks
- Add codebase conventions
- Add known gotchas

## Archiving

Ralph automatically archives previous runs when you start a new feature branch.

Archives are saved to:

```text
archive/YYYY-MM-DD-feature-name/
```

## References

- [Geoffrey Huntley's Ralph article](https://ghuntley.com/ralph/?utm_source=chatgpt.com)
- [Amp documentation](https://ampcode.com/manual?utm_source=chatgpt.com)
- [Claude Code documentation](https://docs.anthropic.com/en/docs/claude-code?utm_source=chatgpt.com)