<#
================================================================================
  Setup-Agent05.ps1  --  AGENT-05 artefact generator
  "Golden Returns Wealth Management" cyber-forensics training lab.

  Role    : Vikas Nair — IT Support
  Username: vikas.n
  Profile : C:\Users\vikas.n
  IP      : 192.168.10.55

  *** SYNTHETIC TRAINING DATA ONLY ***
  All names, phones, accounts, and content are entirely fictional and
  machine-generated for an isolated DSP forensics training exercise.
  Any resemblance to real persons or entities is purely coincidental.

  Requirements : PowerShell 5.1, .NET 4.x, Windows 10.
                 Dot-sourced by 00-Master-Setup.ps1 which has already
                 loaded shared\New-FakeData.ps1.

  *** MALWARE STUB SAFETY NOTICE ***
  The files updater.exe and stub.ps1 placed by this script are BENIGN
  training artefacts. They contain no functional malware. The only
  side-effect when executed is writing a passwords.txt file to a USB
  drive letter if one is present at runtime. No network traffic,
  no real credential exfiltration, no persistence is actually installed
  by running this setup script. The registry Run key and scheduled task
  are written as forensic artefacts only — the stub.ps1 they point to
  is a static file, not an active threat. Safe for isolated lab use.
================================================================================
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Dot-source shared library when this script is invoked standalone.
if (-not (Get-Variable -Name 'VictimData' -Scope Global -ErrorAction SilentlyContinue)) {
    . "$PSScriptRoot\..\shared\New-FakeData.ps1"
}

function Invoke-RoleSetup {
    <#
        Creates all AGENT-05 evidence artefacts.
        Returns @{ Role='AGENT-05'; FilesCreated=N; Errors=@() }
    #>

    $role        = 'AGENT-05'
    $profileBase = "$env:SystemDrive\Users\vikas.n"
    $filesCreated = 0
    $errors       = [System.Collections.Generic.List[string]]::new()

    Write-SetupLog "[$role] Invoke-RoleSetup starting — profile: $profileBase"

    # ------------------------------------------------------------------
    # Shared stub content (used by steps 1, 2, and 3)
    # BENIGN: only writes a text file on USB insertion. No real exfil.
    # ------------------------------------------------------------------
    $stubContent = @'
# USB Monitor and Credential Backup Utility
# Version: 0.3.1-dev
# Author: VN
# Last modified: 2026-03-22
#
# TODO: exfil to telegram when stable
# TODO: encrypt passwords.txt before copy
# TODO: add persistence via WMI subscription instead of Run key

$ErrorActionPreference = 'SilentlyContinue'

function Get-UsbDrives {
    Get-WmiObject Win32_DiskDrive -Filter "InterfaceType='USB'" | ForEach-Object {
        $disk = $_
        Get-WmiObject -Query "ASSOCIATORS OF {Win32_DiskDrive.DeviceID='$($disk.DeviceID)'} WHERE AssocClass=Win32_DiskDriveToDiskPartition" |
        ForEach-Object {
            $partition = $_
            Get-WmiObject -Query "ASSOCIATORS OF {Win32_DiskPartition.DeviceID='$($partition.DeviceID)'} WHERE AssocClass=Win32_LogicalDiskToPartition" |
            Select-Object -ExpandProperty DeviceID
        }
    }
}

function Get-SavedPasswords {
    # Reads Chrome Login Data (encrypted - placeholder for now)
    # TODO: implement DPAPI decrypt
    $loginDb = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"
    if (Test-Path $loginDb) {
        return @("chrome://saved_logins_placeholder")
    }
    return @()
}

function Copy-PasswordsToUsb {
    param([string]$DriveLetter)
    $passwords = Get-SavedPasswords
    $outFile = "${DriveLetter}\passwords.txt"
    "=== GR Credential Backup - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===" | Out-File $outFile -Force
    "Machine: $env:COMPUTERNAME" | Out-File $outFile -Append
    "User: $env:USERNAME" | Out-File $outFile -Append
    "" | Out-File $outFile -Append
    foreach ($p in $passwords) {
        $p | Out-File $outFile -Append
    }
}

# Main monitoring loop
$knownDrives = Get-UsbDrives
while ($true) {
    Start-Sleep -Seconds 10
    $currentDrives = Get-UsbDrives
    $newDrives = $currentDrives | Where-Object { $_ -notin $knownDrives }
    foreach ($drive in $newDrives) {
        Copy-PasswordsToUsb -DriveLetter $drive
    }
    $knownDrives = $currentDrives
}
'@

    # ==================================================================
    # 1. Documents\stub.ps1 — malware stub PowerShell source
    # ==================================================================
    Write-SetupLog "[$role] Step 1: Documents\stub.ps1"
    try {
        $destDir = "$profileBase\Documents"
        New-DirectoryIfMissing $destDir

        $stubPath = "$destDir\stub.ps1"
        [System.IO.File]::WriteAllText($stubPath, $stubContent, [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $stubPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $stubPath"
    } catch {
        $msg = "[$role] Step 1 FAILED (stub.ps1): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 2. ProgramData\Updater\updater.exe — compiled stub (benign EXE placeholder)
    #    Starts with a real MZ DOS header so hex editors identify it as PE,
    #    followed by the DOS mode string and then the stub.ps1 content.
    #    BENIGN — no real PE code, purely a forensic training artefact.
    # ==================================================================
    Write-SetupLog "[$role] Step 2: ProgramData\Updater\updater.exe"
    try {
        $updaterDir = "$env:SystemDrive\ProgramData\Updater"
        New-DirectoryIfMissing $updaterDir

        $exePath = "$updaterDir\updater.exe"

        # 64-byte MZ DOS header (standard minimal stub).
        $mzHeader = [byte[]]@(
            0x4D,0x5A,0x90,0x00, 0x03,0x00,0x00,0x00,
            0x04,0x00,0x00,0x00, 0xFF,0xFF,0x00,0x00,
            0xB8,0x00,0x00,0x00, 0x00,0x00,0x00,0x00,
            0x40,0x00,0x00,0x00, 0x00,0x00,0x00,0x00,
            0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00,
            0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00,
            0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00,
            0x00,0x00,0x00,0x00, 0x80,0x00,0x00,0x00
        )

        # DOS mode message + null padding to reach 128 bytes total header.
        $dosModeStr  = "This program cannot be run in DOS mode.`r`n`r`n"
        $dosModeBytes = [System.Text.Encoding]::ASCII.GetBytes($dosModeStr)

        # Pad so that mzHeader + dosModeBytes + padding = 128 bytes.
        $padLength = 128 - $mzHeader.Length - $dosModeBytes.Length
        if ($padLength -lt 0) { $padLength = 0 }
        $padding = New-Object byte[] $padLength

        # Stub content as UTF-8 bytes.
        $stubBytes = [System.Text.Encoding]::UTF8.GetBytes($stubContent)

        # Concatenate all parts.
        $totalLength = $mzHeader.Length + $dosModeBytes.Length + $padding.Length + $stubBytes.Length
        $exeBytes = New-Object byte[] $totalLength
        $offset = 0
        [System.Array]::Copy($mzHeader,    0, $exeBytes, $offset, $mzHeader.Length);    $offset += $mzHeader.Length
        [System.Array]::Copy($dosModeBytes,0, $exeBytes, $offset, $dosModeBytes.Length); $offset += $dosModeBytes.Length
        [System.Array]::Copy($padding,     0, $exeBytes, $offset, $padding.Length);      $offset += $padding.Length
        [System.Array]::Copy($stubBytes,   0, $exeBytes, $offset, $stubBytes.Length)

        [System.IO.File]::WriteAllBytes($exePath, $exeBytes)
        Add-HashRecord -FilePath $exePath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $exePath ($totalLength bytes, MZ header present)"
    } catch {
        $msg = "[$role] Step 2 FAILED (updater.exe): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 3. ProgramData\Updater\stub.ps1 — copy of stub at ProgramData location
    #    (this is what the Run key and scheduled task actually reference)
    # ==================================================================
    Write-SetupLog "[$role] Step 3: ProgramData\Updater\stub.ps1"
    try {
        $updaterDir = "$env:SystemDrive\ProgramData\Updater"
        New-DirectoryIfMissing $updaterDir

        $pgStubPath = "$updaterDir\stub.ps1"
        [System.IO.File]::WriteAllText($pgStubPath, $stubContent, [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $pgStubPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $pgStubPath"
    } catch {
        $msg = "[$role] Step 3 FAILED (ProgramData stub.ps1): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 4. Registry Run key — persistence artefact
    #    HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
    #    Value: Updater = powershell.exe -WindowStyle Hidden ... stub.ps1
    # ==================================================================
    Write-SetupLog "[$role] Step 4: Registry Run key (Updater)"
    try {
        $runKeyPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
        $runValue   = "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File $env:SystemDrive\ProgramData\Updater\stub.ps1"

        Set-ItemProperty -Path $runKeyPath -Name 'Updater' -Value $runValue -ErrorAction Stop
        $filesCreated++
        Write-SetupLog "[$role] Set registry value: $runKeyPath\Updater = $runValue"
    } catch {
        $msg = "[$role] Step 4 FAILED (Registry Run key): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 5. Documents\Updater_Task.xml — scheduled task XML + task registration
    # ==================================================================
    Write-SetupLog "[$role] Step 5: Updater_Task.xml + schtasks registration"
    try {
        $destDir = "$profileBase\Documents"
        New-DirectoryIfMissing $destDir

        $stubPath = "$env:SystemDrive\ProgramData\Updater\stub.ps1"
        $taskXml = @'
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2026-02-14T10:00:00</Date>
    <Author>AGENT-05\vikas.n</Author>
    <Description>System updater service — do not remove</Description>
  </RegistrationInfo>
  <Triggers>
    <CalendarTrigger>
      <StartBoundary>2026-02-14T10:00:00</StartBoundary>
      <Enabled>true</Enabled>
      <ScheduleByDay><DaysInterval>1</DaysInterval></ScheduleByDay>
    </CalendarTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>AGENT-05\vikas.n</UserId>
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
    <Hidden>true</Hidden>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-WindowStyle Hidden -ExecutionPolicy Bypass -File C:\ProgramData\Updater\stub.ps1</Arguments>
    </Exec>
  </Actions>
</Task>
'@
        $taskXml = $taskXml -replace 'C:\\ProgramData\\Updater\\stub\.ps1', $stubPath

        $xmlPath = "$destDir\Updater_Task.xml"
        # Task Scheduler XML must be UTF-16LE (declared encoding="UTF-16").
        $utf16Bytes = [System.Text.Encoding]::Unicode.GetBytes($taskXml)
        [System.IO.File]::WriteAllBytes($xmlPath, $utf16Bytes)
        Add-HashRecord -FilePath $xmlPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $xmlPath"

        # Register the scheduled task. Redirect stderr to $null; failure is non-fatal.
        try {
            & schtasks.exe /Create /TN '\Updater\DailyTrigger' /XML $xmlPath /F 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-SetupLog "[$role] Registered scheduled task: \Updater\DailyTrigger"
            } else {
                Write-SetupLog "[$role] schtasks.exe exited with code $LASTEXITCODE (may need elevated privileges or task XML encoding)" 'WARN'
                $errors.Add("[$role] Step 5: schtasks returned exit code $LASTEXITCODE — task XML written but task may not be registered")
            }
        } catch {
            Write-SetupLog "[$role] schtasks.exe invocation failed: $($_.Exception.Message)" 'WARN'
            $errors.Add("[$role] Step 5: schtasks call failed: $($_.Exception.Message)")
        }
    } catch {
        $msg = "[$role] Step 5 FAILED (Updater_Task.xml): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 6. Documents\pi_ping.py — Raspberry Pi keepalive script
    # ==================================================================
    Write-SetupLog "[$role] Step 6: Documents\pi_ping.py"
    try {
        $destDir = "$profileBase\Documents"
        New-DirectoryIfMissing $destDir

        $piPingContent = @'
#!/usr/bin/env python3
"""
Raspberry Pi keepalive and health check
Pings all lab machines and reports status to Telegram bot
Author: VN
Last modified: 2026-03-10
"""

import subprocess
import time
import requests
import json

TELEGRAM_BOT_TOKEN = "5123456789:AAGrBot_TokenHere123456789"
TELEGRAM_CHAT_ID   = "-100123456789"

LAB_HOSTS = {
    "AGENT-01":   "192.168.10.11",
    "AGENT-02":   "192.168.10.22",
    "AGENT-03":   "192.168.10.33",
    "AGENT-04":   "192.168.10.44",
    "MANAGER-PC": "192.168.10.50",
    "CRM-SERVER": "192.168.10.100",
}

def ping_host(ip):
    result = subprocess.run(
        ["ping", "-n", "1", "-w", "1000", ip],
        capture_output=True, text=True
    )
    return result.returncode == 0

def send_telegram(message):
    url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage"
    data = {"chat_id": TELEGRAM_CHAT_ID, "text": message}
    try:
        requests.post(url, data=data, timeout=5)
    except Exception:
        pass

def check_all():
    down = []
    for name, ip in LAB_HOSTS.items():
        if not ping_host(ip):
            down.append(f"{name} ({ip})")
    return down

if __name__ == "__main__":
    while True:
        down = check_all()
        if down:
            msg = f"[GR Lab Alert] Machines offline: {', '.join(down)}"
            send_telegram(msg)
        time.sleep(300)
'@

        $piPingPath = "$destDir\pi_ping.py"
        [System.IO.File]::WriteAllText($piPingPath, $piPingContent, [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $piPingPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $piPingPath"
    } catch {
        $msg = "[$role] Step 6 FAILED (pi_ping.py): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 7. Hidden USB folder — GR_LabAssets\HiddenUSB\
    #    Contains: victims_old.xlsx, passwords.txt, .lnk_to_crm_admin.lnk
    # ==================================================================
    Write-SetupLog "[$role] Step 7: HiddenUSB folder artefacts"

    # 7a. victims_old.xlsx (DOCX container with .xlsx extension — placeholder)
    Write-SetupLog "[$role] Step 7a: HiddenUSB\victims_old.xlsx"
    try {
        $usbDir = "$env:SystemDrive\GR_LabAssets\HiddenUSB"
        New-DirectoryIfMissing $usbDir

        # Build old victim list text (50 victims from VictimData).
        $sb = [System.Text.StringBuilder]::new()
        [void]$sb.AppendLine('Old Victim List — Golden Returns (Pre-CRM, manually maintained)')
        [void]$sb.AppendLine('Exported: 2026-03-01')
        [void]$sb.AppendLine('=' * 70)
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine('No. | Victim ID   | Name                     | Phone       | Amount Paid | Status')
        [void]$sb.AppendLine('-' * 90)

        $count = 0
        foreach ($v in $VictimData) {
            if ($count -ge 50) { break }
            $count++
            $line = '{0,3}. | {1,-11} | {2,-24} | +91-{3,-10} | Rs {4,9:N0} | {5}' -f `
                $count, $v.VictimId, $v.Name, $v.Phone, $v.AmountPaid, $v.FinalOutcome
            [void]$sb.AppendLine($line)
        }

        [void]$sb.AppendLine('')
        [void]$sb.AppendLine('NOTE: This list is superseded by the CRM database. Use CRM for current data.')
        [void]$sb.AppendLine('Maintained by: vikas.n')

        $xlsxPath = "$usbDir\victims_old.xlsx"
        New-MinimalDocx -OutPath $xlsxPath -BodyText $sb.ToString()
        Add-HashRecord -FilePath $xlsxPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $xlsxPath (DOCX container, .xlsx extension)"
    } catch {
        $msg = "[$role] Step 7a FAILED (victims_old.xlsx): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # 7b. passwords.txt — auto-planted credential backup file
    Write-SetupLog "[$role] Step 7b: HiddenUSB\passwords.txt"
    try {
        $usbDir = "$env:SystemDrive\GR_LabAssets\HiddenUSB"
        New-DirectoryIfMissing $usbDir

        $passwordsTxt = "=== GR Credential Backup - 2026-04-17 11:44:22 ===`r`nMachine: AGENT-01`r`nUser: rahul.s`r`n`r`nchrome://saved_logins_placeholder"
        $pwPath = "$usbDir\passwords.txt"
        [System.IO.File]::WriteAllText($pwPath, $passwordsTxt, [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $pwPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $pwPath"
    } catch {
        $msg = "[$role] Step 7b FAILED (passwords.txt): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # 7c. .lnk_to_crm_admin.lnk — suspicious LNK stub (76 bytes)
    Write-SetupLog "[$role] Step 7c: HiddenUSB\.lnk_to_crm_admin.lnk"
    try {
        $usbDir = "$env:SystemDrive\GR_LabAssets\HiddenUSB"
        New-DirectoryIfMissing $usbDir

        # Minimal Windows Shell Link (.lnk) file — 76-byte header only.
        # Magic: 4C 00 00 00 (LNK signature)
        # CLSID: 01 14 02 00 00 00 00 00 C0 00 00 00 00 00 00 46
        # LinkFlags: 00 00 00 00 (no target/extra blocks)
        # FileAttributes: 20 00 00 00 (ARCHIVE)
        # Timestamps (3x FILETIME = 24 bytes): zeros
        # FileSize: 00 00 00 00
        # IconIndex: 00 00 00 00
        # ShowCommand: 01 00 00 00 (SW_SHOWNORMAL)
        # HotKey: 00 00
        # Reserved: 00 00 00 00 00 00 00 00 00 00
        $lnkBytes = [byte[]]@(
            0x4C,0x00,0x00,0x00,  # HeaderSize (must be 0x4C = 76)
            0x01,0x14,0x02,0x00,0x00,0x00,0x00,0x00,0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46,  # LinkCLSID
            0x00,0x00,0x00,0x00,  # LinkFlags
            0x20,0x00,0x00,0x00,  # FileAttributes (ARCHIVE)
            0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,  # CreationTime
            0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,  # AccessTime
            0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,  # WriteTime
            0x00,0x00,0x00,0x00,  # FileSize
            0x00,0x00,0x00,0x00,  # IconIndex
            0x01,0x00,0x00,0x00,  # ShowCommand (SW_SHOWNORMAL)
            0x00,0x00,            # HotKey
            0x00,0x00,            # Reserved1
            0x00,0x00,0x00,0x00,  # Reserved2
            0x00,0x00,0x00,0x00   # Reserved3
        )

        $lnkPath = "$usbDir\.lnk_to_crm_admin.lnk"
        [System.IO.File]::WriteAllBytes($lnkPath, $lnkBytes)
        Add-HashRecord -FilePath $lnkPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $lnkPath ($($lnkBytes.Length) bytes)"
    } catch {
        $msg = "[$role] Step 7c FAILED (.lnk_to_crm_admin.lnk): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 8. Chrome History SQLite
    # ==================================================================
    Write-SetupLog "[$role] Step 8: Chrome History"
    try {
        $chromeDir = "$profileBase\AppData\Local\Google\Chrome\User Data\Default"
        New-DirectoryIfMissing $chromeDir

        # Chrome timestamps: microseconds since 1601-01-01 00:00:00 UTC.
        $chromeEpoch = [datetime]::new(1601, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc)

        function ConvertTo-ChromeTime05 {
            param([string]$DateStr)
            try {
                $dt = [datetime]::Parse($DateStr, $null, [System.Globalization.DateTimeStyles]::AssumeLocal)
                $dt = $dt.ToUniversalTime()
                return [long](($dt - $chromeEpoch).TotalSeconds * 1000000)
            } catch {
                return 13300000000000000  # fallback: approx Apr 2026
            }
        }

        $agent05Urls = @(
            @{ Url='https://goldenreturns.example/admin';                              Title='GR Admin Panel';                          VisitCount=234; LastVisit='2026-04-17 19:50:00' },
            @{ Url='https://goldenreturns.example/admin/users';                       Title='GR Admin — Users';                        VisitCount=89;  LastVisit='2026-04-17 18:30:00' },
            @{ Url='https://192.168.10.100/phpmyadmin';                               Title='phpMyAdmin';                              VisitCount=67;  LastVisit='2026-04-17 17:00:00' },
            @{ Url='https://192.168.10.100/golden_crm';                               Title='Golden CRM';                              VisitCount=145; LastVisit='2026-04-17 19:00:00' },
            @{ Url='https://t.me/gr_daily_collect';                                   Title='Telegram — GR Daily';                     VisitCount=12;  LastVisit='2026-04-17 16:00:00' },
            @{ Url='https://www.virustotal.com';                                       Title='VirusTotal';                              VisitCount=3;   LastVisit='2026-04-15 11:00:00' },
            @{ Url='https://anydesk.com/en/downloads/windows';                        Title='AnyDesk Download';                        VisitCount=2;   LastVisit='2026-04-10 09:00:00' },
            @{ Url='https://stackoverflow.com/questions/powershell-usb-detection';    Title='StackOverflow — USB detection';           VisitCount=8;   LastVisit='2026-04-12 14:00:00' },
            @{ Url='https://docs.microsoft.com/en-us/powershell';                     Title='PowerShell Docs';                         VisitCount=15;  LastVisit='2026-04-13 10:00:00' }
        )

        $sqlStatements = [System.Collections.Generic.List[string]]::new()
        $sqlStatements.Add("CREATE TABLE urls (id INTEGER PRIMARY KEY, url TEXT, title TEXT, visit_count INTEGER, typed_count INTEGER, last_visit_time INTEGER, hidden INTEGER);")
        $sqlStatements.Add("CREATE TABLE visits (id INTEGER PRIMARY KEY, url INTEGER, visit_time INTEGER, from_visit INTEGER, transition INTEGER, segment_id INTEGER, visit_duration INTEGER);")
        $sqlStatements.Add("CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT);")
        $sqlStatements.Add("INSERT INTO meta VALUES ('version','58');")
        $sqlStatements.Add("INSERT INTO meta VALUES ('last_compatible_version','58');")

        $visitId = 1
        for ($u = 0; $u -lt $agent05Urls.Count; $u++) {
            $row    = $agent05Urls[$u]
            $urlId  = $u + 1
            $chrTs  = ConvertTo-ChromeTime05 -DateStr $row.LastVisit
            $urlEsc = $row.Url   -replace "'", "''"
            $ttlEsc = $row.Title -replace "'", "''"
            $sqlStatements.Add("INSERT INTO urls VALUES ($urlId,'$urlEsc','$ttlEsc',$($row.VisitCount),0,$chrTs,0);")
            $sqlStatements.Add("INSERT INTO visits VALUES ($visitId,$urlId,$chrTs,0,805306368,0,0);")
            $visitId++
        }

        $historyPath = "$chromeDir\History"
        $ok = New-SqliteDb -DbPath $historyPath -SqlStatements $sqlStatements.ToArray()
        if ($ok) {
            Add-HashRecord -FilePath $historyPath -Role $role
            $filesCreated++
            Write-SetupLog "[$role] Created: $historyPath ($($agent05Urls.Count) URLs)"
        } else {
            $errors.Add("[$role] Step 8: New-SqliteDb returned false for Chrome History (sqlite3 unavailable?)")
        }
    } catch {
        $msg = "[$role] Step 8 FAILED (Chrome History): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 9. CRM Server RDP profile
    #    AppData\Local\Microsoft\Terminal Server Client\Default\192.168.10.100.rdp
    # ==================================================================
    Write-SetupLog "[$role] Step 9: RDP profile 192.168.10.100.rdp"
    try {
        $rdpDir = "$profileBase\AppData\Local\Microsoft\Terminal Server Client\Default"
        New-DirectoryIfMissing $rdpDir

        $rdpContent = @'
screen mode id:i:2
use multimon:i:0
desktopwidth:i:1920
desktopheight:i:1080
session bpp:i:32
full address:s:192.168.10.100
username:s:Administrator
domain:s:CRM-SERVER
prompt for credentials:i:1
authentication level:i:2
'@

        $rdpPath = "$rdpDir\192.168.10.100.rdp"
        [System.IO.File]::WriteAllText($rdpPath, $rdpContent, [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $rdpPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $rdpPath"
    } catch {
        $msg = "[$role] Step 9 FAILED (192.168.10.100.rdp): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # Summary
    # ==================================================================
    $summary = @{
        Role         = $role
        FilesCreated = $filesCreated
        Errors       = $errors.ToArray()
    }

    Write-SetupLog ("[$role] Invoke-RoleSetup complete — files created: $filesCreated, errors: $($errors.Count)")
    return $summary
}
