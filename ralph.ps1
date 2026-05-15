param(
    [string]$Tool = "amp",
    [int]$MaxIterations = 10
)

$ErrorActionPreference = "Stop"

# Validate tool
if ($Tool -ne "amp" -and $Tool -ne "claude") {
    Write-Error "Invalid tool '$Tool'. Must be 'amp' or 'claude'."
    exit 1
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PrdFile = Join-Path $ScriptDir "prd.json"
$ProgressFile = Join-Path $ScriptDir "progress.txt"
$ArchiveDir = Join-Path $ScriptDir "archive"
$LastBranchFile = Join-Path $ScriptDir ".last-branch"

function Get-JsonValue($Path, $Property) {
    if (Test-Path $Path) {
        try {
            return (Get-Content $Path -Raw | ConvertFrom-Json).$Property
        } catch {
            return ""
        }
    }
    return ""
}

# Archive previous run if branch changed
if ((Test-Path $PrdFile) -and (Test-Path $LastBranchFile)) {
    $CurrentBranch = Get-JsonValue $PrdFile "branchName"
    $LastBranch = Get-Content $LastBranchFile -ErrorAction SilentlyContinue

    if ($CurrentBranch -and $LastBranch -and $CurrentBranch -ne $LastBranch) {
        $Date = Get-Date -Format "yyyy-MM-dd"
        $FolderName = $LastBranch -replace "^ralph/", ""
        $ArchiveFolder = Join-Path $ArchiveDir "$Date-$FolderName"

        Write-Host "Archiving previous run: $LastBranch"
        New-Item -ItemType Directory -Force -Path $ArchiveFolder | Out-Null

        if (Test-Path $PrdFile) { Copy-Item $PrdFile $ArchiveFolder }
        if (Test-Path $ProgressFile) { Copy-Item $ProgressFile $ArchiveFolder }

        Write-Host "Archived to: $ArchiveFolder"

        "# Ralph Progress Log" | Set-Content $ProgressFile
        "Started: $(Get-Date)" | Add-Content $ProgressFile
        "---" | Add-Content $ProgressFile
    }
}

# Track current branch
if (Test-Path $PrdFile) {
    $CurrentBranch = Get-JsonValue $PrdFile "branchName"
    if ($CurrentBranch) {
        $CurrentBranch | Set-Content $LastBranchFile
    }
}

# Initialize progress file
if (!(Test-Path $ProgressFile)) {
    "# Ralph Progress Log" | Set-Content $ProgressFile
    "Started: $(Get-Date)" | Add-Content $ProgressFile
    "---" | Add-Content $ProgressFile
}

Write-Host "Starting Ralph - Tool: $Tool - Max iterations: $MaxIterations"

for ($i = 1; $i -le $MaxIterations; $i++) {
    Write-Host ""
    Write-Host "==============================================================="
    Write-Host "  Ralph Iteration $i of $MaxIterations ($Tool)"
    Write-Host "==============================================================="

    try {
        if ($Tool -eq "amp") {
            $Prompt = Get-Content (Join-Path $ScriptDir "prompt.md") -Raw
            $Output = $Prompt | amp --dangerously-allow-all 2>&1
        }
        else {
            $ClaudeFile = Join-Path $ScriptDir "CLAUDE.md"
            $Output = Get-Content $ClaudeFile -Raw | claude --dangerously-skip-permissions --print 2>&1
        }
    }
    catch {
        $Output = $_.Exception.Message
    }

    $Output | Tee-Object -Variable FullOutput | Out-Host

    if ($FullOutput -match "<promise>COMPLETE</promise>") {
        Write-Host ""
        Write-Host "Ralph completed all tasks!"
        Write-Host "Completed at iteration $i of $MaxIterations"
        exit 0
    }

    Write-Host "Iteration $i complete. Continuing..."
    Start-Sleep -Seconds 2
}

Write-Host ""
Write-Host "Ralph reached max iterations ($MaxIterations) without completing all tasks."
Write-Host "Check $ProgressFile for status."
exit 1
