#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Golden Returns -- Single interactive lab setup script.
    Run this on any lab machine. It auto-detects the role,
    sets the static IP, creates the user account, and
    populates all evidence files in one step.

.EXAMPLE
    .\Deploy.ps1
    .\Deploy.ps1 -Role AGENT-01          # skip the menu
    .\Deploy.ps1 -Role ALL               # solo study (all roles on one machine)
#>
[CmdletBinding()]
param(
    [ValidateSet('AGENT-01','AGENT-02','AGENT-03','AGENT-04','AGENT-05',
                 'MANAGER','CRM-SERVER','PRINTER','ROUTER','ALL')]
    [string]$Role = '',
    [switch]$SkipIPConfig,
    [switch]$SkipUserCreate,
    [switch]$NoHash
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'   # faster Invoke-WebRequest

# -----------------------------------------------------------------------------
#  ROLE TABLE  -- IP, username, password for every role
# -----------------------------------------------------------------------------
$ROLE_TABLE = [ordered]@{
    'AGENT-01'   = @{ Label='Rahul -- Senior Closer';    IP='192.168.10.11';  User='rahul.s';       Pwd='Gr@2026Agent01';  Script='agents\Setup-Agent01.ps1' }
    'AGENT-02'   = @{ Label='Priya -- Lead Generator';   IP='192.168.10.22';  User='priya.v';       Pwd='Gr@2026Agent02';  Script='agents\Setup-Agent02.ps1' }
    'AGENT-03'   = @{ Label='Amit -- VoIP Caller';       IP='192.168.10.33';  User='amit.p';        Pwd='Gr@2026Agent03';  Script='agents\Setup-Agent03.ps1' }
    'AGENT-04'   = @{ Label='Sneha -- Payment Chaser';   IP='192.168.10.44';  User='sneha.i';       Pwd='Gr@2026Agent04';  Script='agents\Setup-Agent04.ps1' }
    'AGENT-05'   = @{ Label='Vikas -- IT Support';       IP='192.168.10.55';  User='vikas.n';       Pwd='Gr@2026Agent05';  Script='agents\Setup-Agent05.ps1' }
    'MANAGER'    = @{ Label='Arjun -- Ringleader';        IP='192.168.10.50';  User='arjun.m';       Pwd='Arjun@MGR#2026';  Script='manager\Setup-Manager.ps1' }
    'CRM-SERVER' = @{ Label='CRM Server (XAMPP+MySQL)'; IP='192.168.10.100'; User='Administrator'; Pwd='Gr@Server2026!';  Script='server\Setup-CrmServer.ps1' }
    'PRINTER'    = @{ Label='Printer Evidence';          IP='192.168.10.30';  User=$null;           Pwd=$null;             Script='printer\Setup-Printer.ps1' }
    'ROUTER'     = @{ Label='Router Evidence';           IP='192.168.10.1';   User=$null;           Pwd=$null;             Script='router\Setup-Router.ps1' }
}

$SCRIPTS_DIR = Join-Path $PSScriptRoot 'scripts'
$SHARED_LIB  = Join-Path $SCRIPTS_DIR 'shared\New-FakeData.ps1'

# -----------------------------------------------------------------------------
#  HELPERS
# -----------------------------------------------------------------------------
function Write-Banner {
    $w = 70
    $line = '-' * $w
    Write-Host ""
    Write-Host "  $line" -ForegroundColor DarkCyan
    Write-Host "   GOLDEN RETURNS  --  Cyber Crime Training Lab Setup" -ForegroundColor Cyan
    Write-Host "   v1.1  -  Law Enforcement Training Use Only" -ForegroundColor DarkGray
    Write-Host "  $line" -ForegroundColor DarkCyan
    Write-Host ""
}

function Write-Step {
    param([string]$Msg, [string]$Color = 'Cyan')
    Write-Host "  --> $Msg" -ForegroundColor $Color
}

function Write-OK   { param([string]$M) Write-Host "  [OK]    $M" -ForegroundColor Green  }
function Write-Warn { param([string]$M) Write-Host "  [WARN]  $M" -ForegroundColor Yellow }
function Write-Fail { param([string]$M) Write-Host "  [FAIL]  $M" -ForegroundColor Red    }

function Read-Input {
    param([string]$Prompt, [string]$Default = '')
    if ($Default) {
        $result = Read-Host "  $Prompt [$Default]"
        if ([string]::IsNullOrWhiteSpace($result)) { return $Default }
        return $result.Trim()
    }
    return (Read-Host "  $Prompt").Trim()
}

# -----------------------------------------------------------------------------
#  AUTO-DETECT ROLE
# -----------------------------------------------------------------------------
function Get-AutoDetectedRole {
    $hostname    = $env:COMPUTERNAME.ToUpper()
    $username    = $env:USERNAME.ToLower()
    $currentIPs  = @(Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty IPAddress)

    # Match by hostname
    $hostnameMap = @{
        'AGENT-01'   = @('AGENT-01','AGENT01','RAHUL')
        'AGENT-02'   = @('AGENT-02','AGENT02','PRIYA')
        'AGENT-03'   = @('AGENT-03','AGENT03','AMIT')
        'AGENT-04'   = @('AGENT-04','AGENT04','SNEHA')
        'AGENT-05'   = @('AGENT-05','AGENT05','VIKAS')
        'MANAGER'    = @('MANAGER-PC','MANAGERPC','ARJUN','MANAGER')
        'CRM-SERVER' = @('CRM-SERVER','CRMSERVER','CRM')
        'PRINTER'    = @('PRINTER','HP-PRINTER','HPPRINTER')
        'ROUTER'     = @('ROUTER','GR-ROUTER','GRROUTER')
    }
    foreach ($role in $hostnameMap.Keys) {
        foreach ($pattern in $hostnameMap[$role]) {
            if ($hostname -like "*$pattern*") { return $role }
        }
    }

    # Match by current IP
    foreach ($role in $ROLE_TABLE.Keys) {
        if ($ROLE_TABLE[$role].IP -in $currentIPs) { return $role }
    }

    # Match by username
    $userMap = @{
        'rahul.s'       = 'AGENT-01'
        'priya.v'       = 'AGENT-02'
        'amit.p'        = 'AGENT-03'
        'sneha.i'       = 'AGENT-04'
        'vikas.n'       = 'AGENT-05'
        'arjun.m'       = 'MANAGER'
    }
    if ($userMap.ContainsKey($username)) { return $userMap[$username] }

    return $null
}

# -----------------------------------------------------------------------------
#  INTERACTIVE ROLE MENU
# -----------------------------------------------------------------------------
function Show-RoleMenu {
    Write-Host "  +-----------------------------------------------------+" -ForegroundColor DarkCyan
    Write-Host "  |           Select this machine's role                |" -ForegroundColor Cyan
    Write-Host "  +-----------------------------------------------------+" -ForegroundColor DarkCyan
    Write-Host ""

    for ($i = 0; $i -lt $ROLE_TABLE.Count; $i++) {
        $k = @($ROLE_TABLE.Keys)[$i]
        $ip = $ROLE_TABLE[$k].IP
        Write-Host ("  [{0}] {1,-12} {2,-30} {3}" -f ($i+1), $k, $ROLE_TABLE[$k].Label, $ip) -ForegroundColor White
    }
    Write-Host "  [0] ALL          Solo study -- every role on this machine" -ForegroundColor DarkGray
    Write-Host ""

    do {
        $raw = Read-Host "  Enter number"
        $num = 0
        $valid = [int]::TryParse($raw, [ref]$num) -and $num -ge 0 -and $num -le $ROLE_TABLE.Count
        if (-not $valid) { Write-Warn "Invalid -- enter 0 to $($ROLE_TABLE.Count)" }
    } while (-not $valid)

    if ($num -eq 0) { return 'ALL' }
    return @($ROLE_TABLE.Keys)[$num - 1]
}

# -----------------------------------------------------------------------------
#  COLLECT NETWORK INPUTS
# -----------------------------------------------------------------------------
function Get-LabNetworkConfig {
    param([string]$SelectedRole)

    Write-Host ""
    Write-Host "  +-----------------------------------------------------+" -ForegroundColor DarkCyan
    Write-Host "  |             Network Configuration                   |" -ForegroundColor Cyan
    Write-Host "  +-----------------------------------------------------+" -ForegroundColor DarkCyan
    Write-Host "  Press ENTER to accept defaults" -ForegroundColor DarkGray
    Write-Host ""

    $thisIP  = if ($SelectedRole -ne 'ALL') { $ROLE_TABLE[$SelectedRole].IP } else { '192.168.10.11' }
    $gateway = '192.168.10.1'
    $crmIP   = '192.168.10.100'
    $mgrIP   = '192.168.10.50'

    $thisIP  = Read-Input "This machine IP" $thisIP
    $gateway = Read-Input "Gateway IP     " $gateway
    $crmIP   = Read-Input "CRM Server IP  " $crmIP
    $mgrIP   = Read-Input "Manager PC IP  " $mgrIP

    return @{ ThisIP=$thisIP; Gateway=$gateway; CrmIP=$crmIP; ManagerIP=$mgrIP }
}

# -----------------------------------------------------------------------------
#  SET STATIC IP
# -----------------------------------------------------------------------------
function Set-LabStaticIP {
    param([string]$IP, [string]$Gateway)

    Write-Step "Configuring static IP -> $IP / 24 via $Gateway"

    try {
        # Find the right adapter (skip virtual, loopback, VPN)
        $adapter = Get-NetAdapter | Where-Object {
            $_.Status -eq 'Up' -and
            $_.InterfaceDescription -notmatch 'Loopback|Virtual|VMware|VirtualBox|Hyper-V|WAN Miniport|TAP|Bluetooth'
        } | Sort-Object Speed -Descending | Select-Object -First 1

        if (-not $adapter) {
            Write-Warn "No physical adapter found -- skipping IP config (configure manually)"
            return
        }

        Write-Step "Using adapter: $($adapter.Name) [$($adapter.InterfaceDescription)]" -Color DarkGray

        # Remove current IP config
        $existing = Get-NetIPAddress -InterfaceAlias $adapter.Name -AddressFamily IPv4 -ErrorAction SilentlyContinue
        if ($existing) {
            $existing | Remove-NetIPAddress -Confirm:$false -ErrorAction SilentlyContinue
        }
        Get-NetRoute -InterfaceAlias $adapter.Name -AddressFamily IPv4 -ErrorAction SilentlyContinue |
            Remove-NetRoute -Confirm:$false -ErrorAction SilentlyContinue

        # Apply new config
        New-NetIPAddress -InterfaceAlias $adapter.Name -IPAddress $IP `
            -PrefixLength 24 -DefaultGateway $Gateway -ErrorAction Stop | Out-Null
        Set-DnsClientServerAddress -InterfaceAlias $adapter.Name `
            -ServerAddresses @('8.8.8.8','1.1.1.1') -ErrorAction SilentlyContinue

        Write-OK "Static IP set: $IP / 24  GW: $Gateway  DNS: 8.8.8.8"

    } catch {
        Write-Warn "IP config failed: $($_.Exception.Message)"
        Write-Warn "Set IP manually: $IP / 255.255.255.0  GW: $Gateway"
    }
}

# -----------------------------------------------------------------------------
#  CREATE USER ACCOUNT
# -----------------------------------------------------------------------------
function New-LabUser {
    param([string]$Username, [string]$Password)
    if ([string]::IsNullOrEmpty($Username)) { return }

    Write-Step "Setting up user account: $Username"

    # The Microsoft.PowerShell.LocalAccounts module is 64-bit only. When this
    # script is launched from a 32-bit PowerShell on a 64-bit OS, the *-LocalUser
    # cmdlets are missing. Fall back to the legacy "net" commands in that case.
    if (-not (Get-Command 'New-LocalUser' -ErrorAction SilentlyContinue)) {
        Write-Warn "LocalAccounts cmdlets unavailable (32-bit PowerShell?) -- using 'net user' fallback"
        try {
            & net user $Username $Password /add /passwordchg:no /expires:never /active:yes 2>$null | Out-Null
            & net localgroup Administrators $Username /add 2>$null | Out-Null
            Write-OK "User '$Username' configured via 'net' commands"
        } catch {
            Write-Warn "User setup issue (net fallback): $($_.Exception.Message)"
        }
        return
    }

    try {
        $existing = Get-LocalUser -Name $Username -ErrorAction SilentlyContinue
        if ($existing) {
            # Update password to make sure it's correct
            $existing | Set-LocalUser -Password (ConvertTo-SecureString $Password -AsPlainText -Force) -ErrorAction SilentlyContinue
            Write-OK "User '$Username' already exists -- password confirmed"
        } else {
            $secPwd = ConvertTo-SecureString $Password -AsPlainText -Force
            New-LocalUser -Name $Username -Password $secPwd `
                -PasswordNeverExpires -UserMayNotChangePassword -ErrorAction Stop | Out-Null
            Write-OK "User '$Username' created"
        }

        # Ensure admin
        $admins = Get-LocalGroupMember -Group 'Administrators' -ErrorAction SilentlyContinue |
                  Select-Object -ExpandProperty Name
        if ($admins -notcontains "$env:COMPUTERNAME\$Username" -and $admins -notcontains $Username) {
            Add-LocalGroupMember -Group 'Administrators' -Member $Username -ErrorAction SilentlyContinue
            Write-OK "Added '$Username' to Administrators"
        }

        # Create the user profile directory so the role script can write there immediately
        $profilePath = "$env:SystemDrive\Users\$Username"
        if (-not (Test-Path $profilePath)) {
            try {
                # Force profile creation by running a quick command as that user
                $cred = New-Object System.Management.Automation.PSCredential(
                    $Username,
                    (ConvertTo-SecureString $Password -AsPlainText -Force)
                )
                Start-Process 'cmd.exe' -ArgumentList '/c', 'exit' -Credential $cred `
                    -WorkingDirectory ($env:SystemDrive + '\') -WindowStyle Hidden -Wait -ErrorAction Stop
                Start-Sleep -Seconds 2
                Write-OK "Profile directory created: $profilePath"
            } catch {
                # Manual fallback -- build the standard profile folder structure ourselves.
                $folders = @('Desktop','Documents','Downloads','AppData\Local','AppData\Roaming','AppData\LocalLow')
                foreach ($f in $folders) {
                    $fp = Join-Path $profilePath $f
                    if (-not (Test-Path $fp)) { New-Item -ItemType Directory -Path $fp -Force | Out-Null }
                }
                Write-OK "Profile directories created manually: $profilePath"
            }
        }
    } catch {
        Write-Warn "User setup issue: $($_.Exception.Message) -- setup will use current user profile as fallback"
    }
}

# -----------------------------------------------------------------------------
#  RUN ONE ROLE
# -----------------------------------------------------------------------------
function Invoke-OneRole {
    param([string]$RoleName)

    $info       = $ROLE_TABLE[$RoleName]
    $scriptPath = Join-Path $SCRIPTS_DIR $info.Script

    Write-Host ""
    Write-Host "  ======================================================" -ForegroundColor DarkCyan
    Write-Step "Setting up: $RoleName -- $($info.Label)" -Color Cyan
    Write-Host "  ======================================================" -ForegroundColor DarkCyan

    if (-not (Test-Path $scriptPath)) {
        Write-Fail "Script not found: $scriptPath"
        return @{ Role=$RoleName; FilesCreated=0; Errors=@("Script not found: $scriptPath") }
    }

    # Load shared lib once
    if (-not (Get-Variable -Name 'VictimData' -Scope Global -ErrorAction SilentlyContinue)) {
        Write-Step "Loading shared data library..."
        try {
            . $SHARED_LIB
            Write-OK "Shared library loaded (487 victims, 12k leads)"
        } catch {
            Write-Fail "Failed to load shared library: $($_.Exception.Message)"
            return @{ Role=$RoleName; FilesCreated=0; Errors=@("Shared lib load failed") }
        }
    }

    # Dot-source role script and call its setup function
    try {
        . $scriptPath
        if (-not (Get-Command 'Invoke-RoleSetup' -ErrorAction SilentlyContinue)) {
            throw "Invoke-RoleSetup function not found in $scriptPath"
        }
        $result = Invoke-RoleSetup
        Remove-Item -Path Function:\Invoke-RoleSetup -ErrorAction SilentlyContinue

        # Guard every key access -- a role script might return a hashtable that
        # is missing a key, which throws under Set-StrictMode -Version Latest.
        $isHashtable = $result -is [System.Collections.IDictionary]
        $errList  = if ($isHashtable -and $result.Contains('Errors') -and $result['Errors']) { $result['Errors'] } else { @() }
        $fileNum  = if ($isHashtable -and $result.Contains('FilesCreated') -and $null -ne $result['FilesCreated']) { $result['FilesCreated'] } else { 0 }
        $errCount = @($errList).Count
        if ($errCount -eq 0) {
            Write-OK "$RoleName complete -- $fileNum files created"
        } else {
            Write-Warn "$RoleName complete with $errCount warning(s) -- $fileNum files created"
            foreach ($e in $errList) { Write-Warn "  - $e" }
        }
        return $result

    } catch {
        Write-Fail "$RoleName failed: $($_.Exception.Message)"
        Remove-Item -Path Function:\Invoke-RoleSetup -ErrorAction SilentlyContinue
        return @{ Role=$RoleName; FilesCreated=0; Errors=@($_.Exception.Message) }
    }
}

# -----------------------------------------------------------------------------
#  PRINT SUMMARY TABLE
# -----------------------------------------------------------------------------
function Write-Summary {
    param([hashtable[]]$Results, [timespan]$Elapsed)

    Write-Host ""
    Write-Host "  ========================================================" -ForegroundColor Cyan
    Write-Host "  =                  SETUP COMPLETE                      =" -ForegroundColor Cyan
    Write-Host "  ========================================================" -ForegroundColor Cyan
    Write-Host ""

    $totalFiles  = 0
    $totalErrors = 0
    foreach ($r in $Results) {
        if ($null -eq $r) { continue }
        $isHashtable = $r -is [System.Collections.IDictionary]
        $fc       = if ($isHashtable -and $r.Contains('FilesCreated') -and $null -ne $r['FilesCreated']) { $r['FilesCreated'] } else { 0 }
        $ec       = if ($isHashtable -and $r.Contains('Errors')       -and $r['Errors'])                 { @($r['Errors']).Count } else { 0 }
        $roleName = if ($isHashtable -and $r.Contains('Role')         -and $r['Role'])                   { $r['Role'] } else { '(unknown)' }
        $totalFiles  += $fc
        $totalErrors += $ec
        $status = if ($ec -eq 0) { '[DONE]' } else { "[WARN] $ec warn" }
        $color  = if ($ec -eq 0) { 'Green'  } else { 'Yellow'     }
        Write-Host ("  {0,-14} {1,5} files   {2}" -f $roleName, $fc, $status) -ForegroundColor $color
    }

    Write-Host ""
    Write-Host "  Total files created : $totalFiles" -ForegroundColor White
    Write-Host "  Total warnings      : $totalErrors" -ForegroundColor $(if ($totalErrors -eq 0) { 'Green' } else { 'Yellow' })
    Write-Host "  Time elapsed        : $([math]::Round($Elapsed.TotalSeconds, 1)) seconds" -ForegroundColor White
    Write-Host ""
    Write-Host "  Hash manifest -> $env:SystemDrive\GR_LabSetup\hashes.csv" -ForegroundColor DarkGray
    Write-Host "  Setup log     -> $env:SystemDrive\GR_LabSetup\setup.log"  -ForegroundColor DarkGray
    Write-Host ""

    if ($totalErrors -eq 0) {
        Write-Host "  [OK]    All green. Lab machine is ready." -ForegroundColor Green
    } else {
        Write-Host "  [WARN]  Setup finished with warnings -- review the log." -ForegroundColor Yellow
    }
    Write-Host ""
}

# -----------------------------------------------------------------------------
#  VERIFY SCRIPTS DIRECTORY EXISTS
# -----------------------------------------------------------------------------
if (-not (Test-Path $SCRIPTS_DIR)) {
    Write-Host ""
    Write-Host "  ERROR: scripts/ folder not found at: $SCRIPTS_DIR" -ForegroundColor Red
    Write-Host "  Make sure Deploy.ps1 is in the repo root (same folder as scripts/)." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}
if (-not (Test-Path $SHARED_LIB)) {
    Write-Host ""
    Write-Host "  ERROR: shared library not found at: $SHARED_LIB" -ForegroundColor Red
    exit 1
}

# -----------------------------------------------------------------------------
#  MAIN FLOW
# -----------------------------------------------------------------------------
$startTime = Get-Date
Write-Banner

# 1. Determine role ----------------------------------------------------------
$selectedRole = $Role   # may be empty if not passed as param

if (-not $selectedRole) {
    # Try auto-detect
    $detected = Get-AutoDetectedRole
    if ($detected) {
        Write-Host "  Auto-detected role: " -NoNewline -ForegroundColor DarkGray
        Write-Host $detected -ForegroundColor Green -NoNewline
        Write-Host " -- $($ROLE_TABLE[$detected].Label)" -ForegroundColor White
        Write-Host ""
        $confirm = Read-Input "Use this role? (Y/n)" 'Y'
        if ($confirm -match '^[Nn]') {
            $selectedRole = Show-RoleMenu
        } else {
            $selectedRole = $detected
        }
    } else {
        Write-Host "  Could not auto-detect role from hostname/IP/username." -ForegroundColor Yellow
        $selectedRole = Show-RoleMenu
    }
}

$rolesToRun = if ($selectedRole -eq 'ALL') { @($ROLE_TABLE.Keys) } else { @($selectedRole) }

# 2. Show plan ---------------------------------------------------------------
Write-Host ""
Write-Host "  +-----------------------------------------------------+" -ForegroundColor DarkCyan
Write-Host "  |                    Setup Plan                       |" -ForegroundColor Cyan
Write-Host "  +-----------------------------------------------------+" -ForegroundColor DarkCyan
Write-Host ""
foreach ($r in $rolesToRun) {
    $info = $ROLE_TABLE[$r]
    Write-Host "  Role  : $r -- $($info.Label)" -ForegroundColor White
    Write-Host "  IP    : $($info.IP)"          -ForegroundColor DarkGray
    if ($info.User) {
    Write-Host "  User  : $($info.User)"         -ForegroundColor DarkGray
    }
    Write-Host ""
}

# 3. Collect network config --------------------------------------------------
if (-not $SkipIPConfig) {
    $netCfg = Get-LabNetworkConfig -SelectedRole $selectedRole
} else {
    $netCfg = @{ ThisIP=$ROLE_TABLE[$rolesToRun[0]].IP; Gateway='192.168.10.1'; CrmIP='192.168.10.100'; ManagerIP='192.168.10.50' }
}

# 4. Final confirm -----------------------------------------------------------
Write-Host ""
$go = Read-Input "Ready to deploy? (Y/n)" 'Y'
if ($go -match '^[Nn]') {
    Write-Host "  Cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
$labSetupDir = "$env:SystemDrive\GR_LabSetup"
if (-not (Test-Path $labSetupDir)) { New-Item -ItemType Directory -Path $labSetupDir -Force | Out-Null }

# 5. Set static IP (only for primary role, not ALL) --------------------------
if (-not $SkipIPConfig -and $selectedRole -ne 'ALL') {
    try {
        Set-LabStaticIP -IP $netCfg.ThisIP -Gateway $netCfg.Gateway
    } catch {
        Write-Warn "IP configuration step skipped: $($_.Exception.Message)"
        Write-Warn "Set IP manually: $($netCfg.ThisIP) / 255.255.255.0  GW: $($netCfg.Gateway)"
    }
}

# 6. Create user accounts ----------------------------------------------------
if (-not $SkipUserCreate) {
    Write-Host ""
    Write-Step "Creating user accounts..."
    foreach ($r in $rolesToRun) {
        $info = $ROLE_TABLE[$r]
        if ($info.User -and $info.Pwd) {
            New-LabUser -Username $info.User -Password $info.Pwd
        }
    }
}

# 7. Run role setups ---------------------------------------------------------
$allResults = @()
foreach ($r in $rolesToRun) {
    $allResults += Invoke-OneRole -RoleName $r
}

# 8. Print hash summary (unless -NoHash) -------------------------------------
if (-not $NoHash) {
    $hashCsv = "$labSetupDir\hashes.csv"
    if (Test-Path $hashCsv) {
        $hashes = Import-Csv $hashCsv
        Write-Host "  Hash manifest: $($hashes.Count) files recorded -> $hashCsv" -ForegroundColor DarkGray
    }
}

# 9. Final summary -----------------------------------------------------------
Write-Summary -Results $allResults -Elapsed ((Get-Date) - $startTime)

# Pause if running from Explorer double-click (no interactive terminal)
try {
    if ($Host.Name -eq 'ConsoleHost' -and -not [System.Console]::IsInputRedirected) {
        Write-Host "  Press any key to exit..." -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    }
} catch {
    # ReadKey can throw when stdin is redirected or the host has no raw UI.
    # Pausing is best-effort only -- never let it crash a completed run.
}
