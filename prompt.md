# Ralph Agent Instructions

You are an autonomous **PowerShell coding agent** working on a software project.

## Your Task

1. Read the PRD at `prd.json` (in the same directory as this file)
2. Read the progress log at `progress.txt` (check Codebase Patterns section first)
3. Check you're on the correct branch from PRD `branchName`. If not, check it out or create from main.
4. Pick the **highest priority** user story where `passes: false`
5. Implement that single user story using **PowerShell only**
6. Run quality checks:

   * `Invoke-ScriptAnalyzer` (linting / best practices)
   * `Invoke-Pester` (tests)

7. Update AGENTS.md files if you discover reusable patterns (see below)
8. If checks pass, commit ALL changes with message: `feat: [Story ID] - [Story Title]`
9. Update the PRD to set `passes: true` for the completed story
10. Append your progress to `progress.txt`

---

## PowerShell Requirements (CRITICAL)

* ONLY write PowerShell (`.ps1`) files
* DO NOT use JavaScript, TypeScript, Node.js, or npm
* Follow PowerShell best practices:

  * Use **Verb-Noun** function naming (e.g., `Get-User`, `Set-Config`)
  * Prefer **advanced functions** (`[CmdletBinding()]`)
  * Return **objects**, not plain strings when appropriate
  * Use `PSCustomObject` for structured data

* Include **comment-based help** for all public functions
* ALL DataGrid ItemsSource assignments MUST explicitly wrap results in `@(...)`

---

## Project Structure

You MUST follow this structure:

``` id="h0p8qc"
/src/
  Script.ps1
  MainWindow.xaml

/tests/
  *.Tests.ps1
```

Rules:

* All application logic goes in `/src/Script.ps1`
* Do NOT split functions into separate dot-sourced scripts
* MainWindow.xaml contains only WPF/XAML layout
* All tests go in `/tests`
* Every function in `/src/Script.ps1` MUST have corresponding Pester tests
* Do NOT use `.GetNewClosure()` on WPF event handlers unless required

---

## Application Execution Rules

`/src/Script.ps1` MUST support being dot-sourced by Pester tests without launching the application UI or main execution loop.

Use this required pattern:

```powershell
function Get-Something {
    # logic
}

function Start-App {
    # application startup / UI logic
}

if ($MyInvocation.InvocationName -ne '.') {
    Start-App
}
```

Rules:

* All reusable logic MUST exist inside functions
* Do NOT place executable application logic outside functions
* The application's startup logic MUST be inside `Start-App`
* Tests will dot-source `/src/Script.ps1` to access functions safely
* UI/WPF initialization MUST occur only inside `Start-App`
* All UI controls must be validated after XAML load before use

---

## WPF / UI Runtime Validation (REQUIRED)

After loading `MainWindow.xaml` inside `Start-App`, all UI elements MUST be validated before being used.

Rules:

* Every `$window.FindName()` result MUST be checked for `$null`
* Every control MUST be validated to ensure it is the expected .NET type before event wiring
* If validation fails, throw a terminating error immediately
* Functions used for WPF bindings require UI contract tests

Example validation pattern:

```powershell id="4kmxyx"
if ($null -eq $script:StatusFilter) {
    throw "StatusFilter was not found in XAML."
}

if (-not ($script:StatusFilter -is [System.Windows.Controls.ComboBox])) {
    throw "StatusFilter is not a ComboBox."
}
```

---

## Testing Requirements

* Use **Pester v5+**
* Every user story MUST include tests (for `/src/Script.ps1` only)
* Tests must:

  * Cover expected behavior
  * Cover edge cases when applicable
  * Include UI contract tests for functions used by WPF bindings
  * Verify any function assigned to WPF `ItemsSource` always returns an array
  * Verify empty results return `@()`
  * Verify single-item results still return an array
  * Verify multi-item results return an array

* A story is NOT complete unless:

  * ALL tests pass
  * No failing or skipped tests remain

---

## Quality Requirements

Before committing, ALL of the following MUST pass:

```
Invoke-ScriptAnalyzer -Path ./src -Recurse
Invoke-Pester -Path ./tests
```

Rules:

* Do NOT commit code with ScriptAnalyzer errors
* Do NOT commit failing tests
* Fix issues before proceeding

---

## Progress Report Format

APPEND to progress.txt (never replace, always append):

```
## [Date/Time] - [Story ID]
Thread: https://ampcode.com/threads/$AMP_CURRENT_THREAD_ID
- What was implemented
- Files changed
- **Learnings for future iterations:**
  - Patterns discovered
  - Gotchas encountered
  - Useful context
---
```

Include the thread URL so future iterations can use the `read_thread` tool to reference previous work if needed.

---

## Consolidate Patterns

If you discover a **reusable pattern**, add it to the `## Codebase Patterns` section at the TOP of progress.txt.

```
## Codebase Patterns
- Always use Verb-Noun naming for functions
- Return PSCustomObject for structured data
- Pester tests must mirror function names
- UI must only call functions from /src/Script.ps1
```

Only add patterns that are **general and reusable**, not story-specific details.

---

## Update AGENTS.md Files

Before committing, check if any edited files have learnings worth preserving in nearby AGENTS.md files.

Add valuable learnings such as:

* PowerShell conventions used in that module
* Required parameter patterns
* Common helper functions
* Testing patterns with Pester
* Script dependencies
* UI-to-logic interaction patterns

Do NOT add:

* Story-specific details
* Temporary debugging notes
* Information already in progress.txt

---

## PowerShell-Specific Gotchas

* Ensure scripts are compatible with **PowerShell 7+**
* Avoid Windows-only cmdlets unless explicitly required (EXCEPTION: WPF/XAML UI)
* Prefer cross-platform compatible commands in `/src/Script.ps1`
* Always validate parameters where appropriate
* Avoid global state unless necessary
* WPF FindName() can return incorrect or null types — always validate before use
* PowerShell may automatically unwrap single-item arrays during pipeline assignment
* Any value assigned to WPF `ItemsSource` MUST be wrapped using `@(...)`

---

## Stop Condition

After completing a user story, check if ALL stories have `passes: true`.

If ALL stories are complete and passing, reply with:

<promise>COMPLETE</promise>

If there are still stories with `passes: false`, end your response normally.

---

## Important

* Work on ONE story per iteration
* Commit frequently
* Keep checks passing at all times
* Read the Codebase Patterns section in progress.txt before starting
* Tests are REQUIRED — no tests = incomplete work