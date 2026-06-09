<#
================================================================================
  00-Master-Setup.ps1  --  Master orchestrator for the
  "Golden Returns Wealth Management" cyber-forensics training lab.

  *** SYNTHETIC TRAINING DATA ONLY ***
  Generates fictional evidence artefacts for an isolated DSP forensics
  training exercise.  No real persons, accounts, or institutions are
  represented.

  Requirements : PowerShell 5.1, .NET Framework 4.x, Windows 10.
                 Must be run As Administrator.
                 No external modules or internet access required
                 (except CRM-SERVER which optionally downloads XAMPP).

  Usage:
    powershell -ExecutionPolicy Bypass -File 00-Master-Setup.ps1 -Role AGENT-01
    powershell -ExecutionPolicy Bypass -File 00-Master-Setup.ps1 -Role ALL
================================================================================
#>

#Requires -RunAsAdministrator
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('AGENT-01','AGENT-02','AGENT-03','AGENT-04','AGENT-05','MANAGER','CRM-SERVER','PRINTER','ROUTER','ALL')]
    [string]$Role,

    [switch]$Force,

    [switch]$NoHash
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---- Banner ------------------------------------------------------------------
$startTime = Get-Date
$bannerWidth = 72
$bannerLine  = '=' * $bannerWidth

function Write-Banner {
    param([string]$Title, [string]$Subtitle = '')
    Write-Host ''
    Write-Host $bannerLine -ForegroundColor Cyan
    $pad = [math]::Max(0, [math]::Floor(($bannerWidth - $Title.Length) / 2))
    Write-Host (' ' * $pad + $Title) -ForegroundColor Cyan
    if ($Subtitle) {
        $pad2 = [math]::Max(0, [math]::Floor(($bannerWidth - $Subtitle.Length) / 2))
        Write-Host (' ' * $pad2 + $Subtitle) -ForegroundColor Cyan
    }
    Write-Host $bannerLine -ForegroundColor Cyan
    Write-Host ''
}

Write-Banner `
    'Golden Returns Wealth Management -- Lab Setup' `
    ("Role: $Role   |   Started: $($startTime.ToString('yyyy-MM-dd HH:mm:ss'))")

# ---- Admin check (friendly message -- #Requires handles the hard stop) --------
$identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host '[OK] Running as Administrator.' -ForegroundColor Green
} else {
    # Should never reach here because of #Requires -RunAsAdministrator,
    # but emit a clear message just in case the check is ever bypassed.
    Write-Host '[WARN] Not running as Administrator -- some artefacts may fail to create.' -ForegroundColor Yellow
}

# ---- Lab base directory ------------------------------------------------------
$labBase = "$env:SystemDrive\GR_LabSetup"
if (-not (Test-Path -LiteralPath $labBase)) {
    New-Item -ItemType Directory -Path $labBase -Force | Out-Null
    Write-Host "[OK] Created lab directory: $labBase" -ForegroundColor Green
} else {
    Write-Host "[OK] Lab directory exists:  $labBase" -ForegroundColor Green
}

# ---- Dot-source shared library -----------------------------------------------
$sharedLib = Join-Path $PSScriptRoot 'shared\New-FakeData.ps1'
if (-not (Test-Path -LiteralPath $sharedLib)) {
    Write-Host "[ERROR] Shared library not found: $sharedLib" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Loading shared library: $sharedLib" -ForegroundColor Green
. $sharedLib   # exposes Write-SetupLog, Add-HashRecord, $VictimData, etc.

# ---- Role -> script file mapping ----------------------------------------------
$roleMap = [ordered]@{
    'AGENT-01'   = Join-Path $PSScriptRoot 'agents\Setup-Agent01.ps1'
    'AGENT-02'   = Join-Path $PSScriptRoot 'agents\Setup-Agent02.ps1'
    'AGENT-03'   = Join-Path $PSScriptRoot 'agents\Setup-Agent03.ps1'
    'AGENT-04'   = Join-Path $PSScriptRoot 'agents\Setup-Agent04.ps1'
    'AGENT-05'   = Join-Path $PSScriptRoot 'agents\Setup-Agent05.ps1'
    'MANAGER'    = Join-Path $PSScriptRoot 'manager\Setup-Manager.ps1'
    'CRM-SERVER' = Join-Path $PSScriptRoot 'server\Setup-CrmServer.ps1'
    'PRINTER'    = Join-Path $PSScriptRoot 'printer\Setup-Printer.ps1'
    'ROUTER'     = Join-Path $PSScriptRoot 'router\Setup-Router.ps1'
}

# Build list of roles to run.
if ($Role -eq 'ALL') {
    $rolesToRun = $roleMap.Keys | ForEach-Object { $_ }
} else {
    $rolesToRun = @($Role)
}

# ---- Execute each role -------------------------------------------------------
$allSummaries   = @()
$globalErrors   = @()

foreach ($currentRole in $rolesToRun) {
    $scriptPath = $roleMap[$currentRole]

    Write-SetupLog "======== Starting role: $currentRole ========"

    if (-not (Test-Path -LiteralPath $scriptPath)) {
        $msg = "Role script not found: $scriptPath"
        Write-SetupLog $msg 'ERROR'
        $globalErrors += $msg
        continue
    }

    try {
        # Dot-source the role script (defines Invoke-RoleSetup in this scope).
        Write-SetupLog "Dot-sourcing: $scriptPath"
        . $scriptPath

        # Every role script must export Invoke-RoleSetup.
        if (-not (Get-Command 'Invoke-RoleSetup' -ErrorAction SilentlyContinue)) {
            throw "Invoke-RoleSetup not defined after dot-sourcing $scriptPath"
        }

        Write-SetupLog "Invoking Invoke-RoleSetup for $currentRole"
        $summary = Invoke-RoleSetup

        $allSummaries += $summary

        if ($summary -and $summary.Errors -and $summary.Errors.Count -gt 0) {
            Write-SetupLog ("$currentRole completed with {0} error(s)." -f $summary.Errors.Count) 'WARN'
        } else {
            Write-SetupLog "$currentRole completed successfully."
        }

        # Remove the function between roles so the next role's dot-source
        # redefines it cleanly (avoids stale definitions when running ALL).
        Remove-Item -Path Function:\Invoke-RoleSetup -ErrorAction SilentlyContinue

    } catch {
        $msg = "Role $currentRole FAILED: $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $globalErrors += $msg
        # Remove stale function if it exists.
        Remove-Item -Path Function:\Invoke-RoleSetup -ErrorAction SilentlyContinue
    }
}

# ---- Hash summary ------------------------------------------------------------
if (-not $NoHash) {
    Write-SetupLog "======== Hash summary ========"

    $hashCsv = "$labBase\hashes.csv"
    if (Test-Path -LiteralPath $hashCsv) {
        try {
            # Import-Csv handles quoted fields correctly.
            $rows = Import-Csv -LiteralPath $hashCsv -ErrorAction Stop
            $count = @($rows).Count
            Write-SetupLog ("Hash CSV: {0} file(s) recorded at {1}" -f $count, $hashCsv)
            Write-Host ''
            Write-Host ("  Hash report: $hashCsv") -ForegroundColor Cyan
            Write-Host ("  Files hashed: $count") -ForegroundColor Cyan
        } catch {
            Write-SetupLog "Could not read hash CSV: $($_.Exception.Message)" 'WARN'
            Write-Host "  Hash CSV: $hashCsv" -ForegroundColor Cyan
        }
    } else {
        Write-SetupLog "Hash CSV not found (no files were hashed or -NoHash was not specified)." 'WARN'
    }
}

# ---- Completion banner -------------------------------------------------------
$elapsed = (Get-Date) - $startTime
$elapsedStr = '{0:mm\:ss}' -f $elapsed

$totalFiles  = ($allSummaries | ForEach-Object { if ($_.FilesCreated) { $_.FilesCreated } else { 0 } } | Measure-Object -Sum).Sum
$totalErrors = $globalErrors.Count + ($allSummaries | ForEach-Object { if ($_.Errors) { $_.Errors.Count } else { 0 } } | Measure-Object -Sum).Sum

if ($totalErrors -eq 0) {
    $status = 'DONE'
    $statusColor = 'Green'
} elseif ($totalErrors -le 3) {
    $status = 'DONE_WITH_CONCERNS'
    $statusColor = 'Yellow'
} else {
    $status = 'DONE_WITH_ERRORS'
    $statusColor = 'Red'
}

Write-Host ''
Write-Host $bannerLine -ForegroundColor $statusColor
Write-Host ("  Status     : $status") -ForegroundColor $statusColor
Write-Host ("  Role(s)    : $($rolesToRun -join ', ')") -ForegroundColor $statusColor
Write-Host ("  Files      : $totalFiles created") -ForegroundColor $statusColor
Write-Host ("  Errors     : $totalErrors") -ForegroundColor $statusColor
Write-Host ("  Elapsed    : $elapsedStr") -ForegroundColor $statusColor
Write-Host ("  Log        : $labBase\setup.log") -ForegroundColor $statusColor
Write-Host $bannerLine -ForegroundColor $statusColor
Write-Host ''

if ($globalErrors.Count -gt 0) {
    Write-Host 'Global errors:' -ForegroundColor Red
    $globalErrors | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
}
