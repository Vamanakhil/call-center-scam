<#
================================================================================
  Setup-Manager.ps1  --  MANAGER artefact generator
  "Golden Returns Wealth Management" cyber-forensics training lab.

  Role    : Arjun Mehta -- Ringleader
  Username: arjun.m
  Profile : $env:SystemDrive\Users\arjun.m
  IP      : 192.168.10.50

  *** SYNTHETIC TRAINING DATA ONLY ***
  All names, phones, accounts, and content are entirely fictional and
  machine-generated for an isolated DSP forensics training exercise.
  Any resemblance to real persons or entities is purely coincidental.

  Requirements : PowerShell 5.1, .NET 4.x, Windows 10.
                 Dot-sourced by 00-Master-Setup.ps1 which has already
                 loaded shared\New-FakeData.ps1. Can also be invoked
                 standalone; will dot-source the shared library itself.
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
        Creates all MANAGER artefacts for Arjun Mehta (arjun.m).
        Returns @{ Role='MANAGER'; FilesCreated=N; Errors=@() }
    #>

    $role        = 'MANAGER'
    $profileBase = "$env:SystemDrive\Users\arjun.m"
    $filesCreated = 0
    $errors       = [System.Collections.Generic.List[string]]::new()

    # D: drive check -- used for all D:\Manager\ artefacts.
    $managerDir = if (Test-Path 'D:\') { 'D:\Manager' } else { "$env:SystemDrive\Manager" }

    Write-SetupLog "[$role] Invoke-RoleSetup starting -- profile: $profileBase, managerDir: $managerDir"

    # ------------------------------------------------------------------
    # Helper: convert a UTC DateTime to Chrome/Edge timestamp
    # (microseconds since 1601-01-01 00:00:00 UTC).
    # Defined here so it is available to all steps inside this function.
    # ------------------------------------------------------------------
    $chromEpoch = [datetime]::new(1601, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc)

    function ConvertTo-ChromeTime {
        param([string]$DateStr)
        try {
            $dt = [datetime]::Parse($DateStr, $null, [System.Globalization.DateTimeStyles]::AssumeLocal)
            $dt = $dt.ToUniversalTime()
            return [long](($dt - $chromEpoch).TotalSeconds * 1000000)
        } catch {
            return 13300000000000000   # fallback: approx Apr 2026
        }
    }

    # ==================================================================
    # 1. D:\Manager\victims_master.xlsx  (487-row master victim list)
    # ==================================================================
    Write-SetupLog "[$role] Step 1: victims_master.xlsx"
    try {
        New-DirectoryIfMissing $managerDir

        # Build a text table of all 487 victims.
        $sb = [System.Text.StringBuilder]::new()
        [void]$sb.AppendLine('GOLDEN RETURNS WEALTH MANAGEMENT - MASTER VICTIM LIST')
        [void]$sb.AppendLine('Generated: 2026-04-17 | CONFIDENTIAL - DO NOT SHARE')
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine('VictimId  | Name                          | Phone      | City        | AmountPaid    | Status | CloserId | DateAdded')
        [void]$sb.AppendLine('----------|-------------------------------|------------|-------------|---------------|--------|----------|----------')

        foreach ($v in $VictimData) {
            $line = '{0,-9} | {1,-29} | {2,-10} | {3,-11} | Rs {4,10:N0} | {5,-6} | {6,-8} | {7}' -f `
                $v.VictimId,
                $v.Name,
                $v.Phone,
                $v.City,
                $v.AmountPaid,
                $v.FinalOutcome,
                $v.AssignedCloser,
                $v.DateAdded
            [void]$sb.AppendLine($line)
        }

        $vmPath = Join-Path $managerDir 'victims_master.xlsx'
        New-MinimalDocx -OutPath $vmPath -BodyText $sb.ToString()
        Add-HashRecord -FilePath $vmPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $vmPath ($($VictimData.Count) victims)"
    } catch {
        $msg = "[$role] Step 1 FAILED (victims_master.xlsx): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 2. D:\Manager\Mule_Accounts_Q4.xlsx  (6 mule account rows)
    # ==================================================================
    Write-SetupLog "[$role] Step 2: Mule_Accounts_Q4.xlsx"
    try {
        New-DirectoryIfMissing $managerDir

        $sb = [System.Text.StringBuilder]::new()
        [void]$sb.AppendLine('GOLDEN RETURNS - MULE ACCOUNT ROTATION SCHEDULE Q4')
        [void]$sb.AppendLine('STRICTLY CONFIDENTIAL')
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine('Bank     | Account    | IFSC          | UPI                     | Name                      | Active From | Active To')
        [void]$sb.AppendLine('---------|------------|---------------|-------------------------|---------------------------|-------------|----------')

        foreach ($m in $MuleAccounts) {
            $line = '{0,-8} | {1,-10} | {2,-13} | {3,-23} | {4,-25} | {5}  | {6}' -f `
                $m.Bank,
                $m.Account,
                $m.IFSC,
                $m.UPI,
                $m.Name,
                $m.ActiveFrom,
                $m.ActiveTo
            [void]$sb.AppendLine($line)
        }

        $mulePath = Join-Path $managerDir 'Mule_Accounts_Q4.xlsx'
        New-MinimalDocx -OutPath $mulePath -BodyText $sb.ToString()
        Add-HashRecord -FilePath $mulePath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $mulePath ($($MuleAccounts.Count) accounts)"
    } catch {
        $msg = "[$role] Step 2 FAILED (Mule_Accounts_Q4.xlsx): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 3. D:\Manager\Daily_Collection_2026-04-17.xlsx
    # ==================================================================
    Write-SetupLog "[$role] Step 3: Daily_Collection_2026-04-17.xlsx"
    try {
        New-DirectoryIfMissing $managerDir

        $dailyBody = @'
GOLDEN RETURNS - DAILY COLLECTION REPORT
Date: 17-Apr-2026 | Prepared by: Arjun Mehta

Agent    | Collections | Amount       | Status
---------|-------------|--------------|-------------
rahul.s  | 5           | Rs 1,42,000  | ON TARGET
amit.p   | 3           | Rs 87,500    | BELOW TARGET
sneha.i  | 7           | Rs 2,14,000  | EXCEEDED
vikas.n  | 1           | Rs 10,000    | (IT - exempt)

TOTAL: Rs 4,53,500
MULE ACCOUNT ACTIVE: Axis XXXXXX7720 (compliance.gr@upi)
NEXT ROTATION: 22-Apr (Kotak XXXXXX3344)

SEND TO: t.me/gr_daily_collect at 23:00
'@

        $dailyPath = Join-Path $managerDir 'Daily_Collection_2026-04-17.xlsx'
        New-MinimalDocx -OutPath $dailyPath -BodyText $dailyBody
        Add-HashRecord -FilePath $dailyPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $dailyPath"
    } catch {
        $msg = "[$role] Step 3 FAILED (Daily_Collection_2026-04-17.xlsx): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 4. D:\Manager\vault.veracrypt  (10 MB high-entropy random bytes)
    # ==================================================================
    Write-SetupLog "[$role] Step 4: vault.veracrypt"
    try {
        New-DirectoryIfMissing $managerDir

        $vcPath = Join-Path $managerDir 'vault.veracrypt'
        $rng    = [System.Security.Cryptography.RandomNumberGenerator]::Create()
        $buf    = New-Object byte[] (10 * 1024 * 1024)
        $rng.GetBytes($buf)
        [System.IO.File]::WriteAllBytes($vcPath, $buf)
        $rng.Dispose()

        Add-HashRecord -FilePath $vcPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $vcPath (10 MB random)"
    } catch {
        $msg = "[$role] Step 4 FAILED (vault.veracrypt): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 5. AnyDesk session log  (14 days, Apr 4-17 2026)
    # ==================================================================
    Write-SetupLog "[$role] Step 5: AnyDesk ad_sessions.log"
    try {
        $anyDeskDir = "$profileBase\AppData\Roaming\AnyDesk"
        New-DirectoryIfMissing $anyDeskDir

        # Session parameters: connect to ID 823411902 at 103.41.218.91.
        # Generate 1-3 sessions per day for Apr 4..Apr 17 deterministically.
        # Use a local seeded RNG (independent of the global GR_Rng) so the
        # log content is stable across reruns.
        $adRng = New-Object System.Random(2026)

        # Start/end times and durations are computed per session.
        # Each session: connect line, connected line, session-ended line.
        $sessionLines = [System.Collections.Generic.List[string]]::new()

        $startDate = [datetime]::new(2026, 4, 4)
        $endDate   = [datetime]::new(2026, 4, 17)

        # Force the final entry on Apr 17 to match the spec exactly.
        $forcedFinalAdded = $false

        for ($d = 0; $d -le ($endDate - $startDate).Days; $d++) {
            $day = $startDate.AddDays($d)

            # Last day: add forced final session FIRST (chronological), then
            # any random earlier sessions for that day.
            $isLastDay = ($d -eq ($endDate - $startDate).Days)

            # 1-3 sessions per day; last day always gets at least 1 (the forced one).
            $numSessions = $adRng.Next(1, 4)

            # Generate random sessions for this day (skip if they'd collide with 23:xx).
            for ($s = 0; $s -lt $numSessions; $s++) {

                if ($isLastDay -and -not $forcedFinalAdded) {
                    # Insert the spec-mandated final session at 23:14.
                    $connTime  = $day.Date.AddHours(23).AddMinutes(14).AddSeconds(18)
                    $connedTime = $connTime.AddSeconds(4)
                    $endTime    = $connTime.AddMinutes(32).AddSeconds(47)
                    $duration   = '32m 47s'

                    $sessionLines.Add('[{0}] [client] Connecting to 823411902 (103.41.218.91)' -f $connTime.ToString('yyyy-MM-dd HH:mm:ss'))
                    $sessionLines.Add('[{0}] [client] Connected to 823411902 (103.41.218.91) -- session started' -f $connedTime.ToString('yyyy-MM-dd HH:mm:ss'))
                    $sessionLines.Add('[{0}] [client] Session ended (duration: {1})' -f $endTime.ToString('yyyy-MM-dd HH:mm:ss'), $duration)

                    $sessionLines.Add('[2026-04-17 23:47:33] [client] Connecting to 823411902 (103.41.218.91)')
                    $sessionLines.Add('[2026-04-17 23:47:38] [client] Connected to 823411902 (103.41.218.91) -- session started')
                    $sessionLines.Add('[2026-04-17 23:52:14] [client] Session ended (duration: 4m 36s)')

                    $forcedFinalAdded = $true

                    # Only one session on the last day (the forced one) to avoid
                    # an additional random session after 23:xx.
                    break
                }

                # Random session: start between 09:00 and 20:00 to stay clear
                # of the 23:xx forced slot on the last day.
                $maxHour = if ($isLastDay) { 18 } else { 21 }
                $hh      = $adRng.Next(9, $maxHour)
                $mm      = $adRng.Next(0, 60)
                $ss      = $adRng.Next(0, 60)

                $connTime   = $day.Date.AddHours($hh).AddMinutes($mm).AddSeconds($ss)
                # Connection establishment: 3-6 seconds.
                $connedTime = $connTime.AddSeconds($adRng.Next(3, 7))

                # Session duration: 8-45 minutes.
                $durationMin = $adRng.Next(8, 46)
                $durationSec = $adRng.Next(0, 60)
                $endTime     = $connedTime.AddMinutes($durationMin).AddSeconds($durationSec)
                $durationStr = '{0}m {1:00}s' -f $durationMin, $durationSec

                $sessionLines.Add('[{0}] [client] Connecting to 823411902 (103.41.218.91)' -f $connTime.ToString('yyyy-MM-dd HH:mm:ss'))
                $sessionLines.Add('[{0}] [client] Connected to 823411902 (103.41.218.91) -- session started' -f $connedTime.ToString('yyyy-MM-dd HH:mm:ss'))
                $sessionLines.Add('[{0}] [client] Session ended (duration: {1})' -f $endTime.ToString('yyyy-MM-dd HH:mm:ss'), $durationStr)
            }
        }

        $logPath    = "$anyDeskDir\ad_sessions.log"
        $logContent = $sessionLines -join "`r`n"
        [System.IO.File]::WriteAllText($logPath, $logContent, [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $logPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $logPath ($($sessionLines.Count) lines)"
    } catch {
        $msg = "[$role] Step 5 FAILED (AnyDesk log): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 6. Edge History SQLite  (same schema as Chrome)
    # ==================================================================
    Write-SetupLog "[$role] Step 6: Edge History"
    try {
        $edgeDir = "$profileBase\AppData\Local\Microsoft\Edge\User Data\Default"
        New-DirectoryIfMissing $edgeDir

        $sqlStatements = [System.Collections.Generic.List[string]]::new()
        $sqlStatements.Add("CREATE TABLE urls (id INTEGER PRIMARY KEY, url TEXT, title TEXT, visit_count INTEGER, typed_count INTEGER, last_visit_time INTEGER, hidden INTEGER);")
        $sqlStatements.Add("CREATE TABLE visits (id INTEGER PRIMARY KEY, url INTEGER, visit_time INTEGER, from_visit INTEGER, transition INTEGER, segment_id INTEGER, visit_duration INTEGER);")
        $sqlStatements.Add("CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT);")
        $sqlStatements.Add("INSERT INTO meta VALUES ('version','58');")
        $sqlStatements.Add("INSERT INTO meta VALUES ('last_compatible_version','58');")

        $visitId = 1
        for ($u = 0; $u -lt $ChromeUrlHistory_Manager.Count; $u++) {
            $row      = $ChromeUrlHistory_Manager[$u]
            $urlId    = $u + 1
            $edgeTs   = ConvertTo-ChromeTime -DateStr $row.LastVisit
            $urlEsc   = $row.Url   -replace "'", "''"
            $titleEsc = $row.Title -replace "'", "''"
            $sqlStatements.Add("INSERT INTO urls VALUES ($urlId,'$urlEsc','$titleEsc',$($row.VisitCount),0,$edgeTs,0);")
            $sqlStatements.Add("INSERT INTO visits VALUES ($visitId,$urlId,$edgeTs,0,805306368,0,0);")
            $visitId++
        }

        $historyPath = "$edgeDir\History"
        $ok = New-SqliteDb -DbPath $historyPath -SqlStatements $sqlStatements.ToArray()
        if ($ok) {
            Add-HashRecord -FilePath $historyPath -Role $role
            $filesCreated++
            Write-SetupLog "[$role] Created: $historyPath ($($ChromeUrlHistory_Manager.Count) URLs)"
        } else {
            $errors.Add("[$role] Step 6: New-SqliteDb returned false for Edge History (sqlite3 unavailable?)")
        }
    } catch {
        $msg = "[$role] Step 6 FAILED (Edge History): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 7. Recycle Bin: complaints_to_ignore.xlsx
    # ==================================================================
    Write-SetupLog "[$role] Step 7: Recycle Bin -- complaints_to_ignore.xlsx"
    try {
        # Temp location to build the docx before moving it.
        $tmpDir = "$profileBase\AppData\Local\Temp"
        New-DirectoryIfMissing $tmpDir

        $complaintsBody = @'
GOLDEN RETURNS - DO NOT RESPOND LIST
(Complainants who have been identified as potential law enforcement contacts)

Name                              | Phone      | Date of Last Contact | Action
----------------------------------|------------|---------------------|-------------------
Inspector Sharma                  | 9811000001 | 2026-03-12          | BLOCKED
Cyber Cell Andheri - Officer K    | 9822000002 | 2026-04-01          | DO NOT CALL
Mrs Kavita Singh (complainant)    | 9833000003 | 2026-04-10          | BURNED - lawyer threatened

STATUS: 3 active complaints known. Legal says ignore unless formal notice served.
'@

        $tmpDocxPath = "$tmpDir\complaints_to_ignore_temp.xlsx"
        New-MinimalDocx -OutPath $tmpDocxPath -BodyText $complaintsBody

        # Locate or create the Recycle Bin SID directory.
        $recycleBinBase = "$env:SystemDrive" + '\$Recycle.Bin'
        $sidDir = $null

        if (Test-Path -LiteralPath $recycleBinBase) {
            $sidDir = Get-ChildItem -LiteralPath $recycleBinBase -Directory -ErrorAction SilentlyContinue |
                      Where-Object { $_.Name -match '^S-1-5-21-' } |
                      Select-Object -First 1 -ExpandProperty FullName
        }

        if (-not $sidDir) {
            $sidDir = "$env:SystemDrive" + '\$Recycle.Bin\S-1-5-21-1234567890-123456789-1234567890-1001'
            New-DirectoryIfMissing $sidDir
        }

        # Use unique stub names to avoid collisions with other role scripts.
        $recycledXlsx    = Join-Path $sidDir '$RMGRCMPL1.xlsx'
        $recycleInfoFile = Join-Path $sidDir '$IMGRCMPL1.xlsx'

        # Copy to Recycle Bin and remove the temp file.
        Copy-Item -LiteralPath $tmpDocxPath -Destination $recycledXlsx -Force
        Remove-Item -LiteralPath $tmpDocxPath -Force -ErrorAction SilentlyContinue

        Add-HashRecord -FilePath $recycledXlsx -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created recycled file: $recycledXlsx"

        # Build the Windows 10 $I (Recycle Bin info) binary -- 548 bytes.
        # Layout: magic(8) | fileSize(8) | deletionTime(8) | charCount(4) | path(520)
        $originalPath = "$profileBase\Documents\complaints_to_ignore.xlsx"
        $pathUtf16    = [System.Text.Encoding]::Unicode.GetBytes($originalPath + "`0")
        $charCount    = [int]($pathUtf16.Length / 2)

        $fileSize = (Get-Item -LiteralPath $recycledXlsx).Length

        $ftEpoch  = [datetime]::new(1601, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc)
        $nowFt    = [long](([datetime]::UtcNow - $ftEpoch).TotalSeconds * 10000000)

        $infoBytes     = New-Object byte[] 548
        $infoBytes[0]  = 0x01   # magic
        $infoBytes[1]  = 0xFF
        $infoBytes[2]  = 0xFF
        $infoBytes[3]  = 0xFF
        $infoBytes[4]  = 0xFF
        $infoBytes[5]  = 0xFF
        $infoBytes[6]  = 0xFF
        $infoBytes[7]  = 0xFF
        [System.BitConverter]::GetBytes([long]$fileSize).CopyTo($infoBytes,  8)
        [System.BitConverter]::GetBytes($nowFt).CopyTo($infoBytes,           16)
        [System.BitConverter]::GetBytes($charCount).CopyTo($infoBytes,       24)
        $copyLen = [math]::Min($pathUtf16.Length, 548 - 28)
        [System.Array]::Copy($pathUtf16, 0, $infoBytes, 28, $copyLen)

        [System.IO.File]::WriteAllBytes($recycleInfoFile, $infoBytes)
        Add-HashRecord -FilePath $recycleInfoFile -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created recycle info file: $recycleInfoFile"
    } catch {
        $msg = "[$role] Step 7 FAILED (Recycle Bin complaints_to_ignore.xlsx): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 8. Scheduled Tasks: DailyCollectionReport + DNSFlush
    # ==================================================================
    Write-SetupLog "[$role] Step 8: Scheduled tasks"

    # --- 8a: save the send_report.ps1 helper script ---
    try {
        New-DirectoryIfMissing $managerDir

        $sendReportScript = @'
# Daily Collection Report Sender
# Sends daily report to Telegram channel at 23:00
$reportFile = "D:\Manager\Daily_Collection_$(Get-Date -Format 'yyyy-MM-dd').xlsx"
$botToken   = "5123456789:AAGrBot_TokenHere123456789"
$chatId     = "-100123456789"
$msg        = "Daily collection complete. Report attached. $(Get-Date -Format 'HH:mm')"
# Invoke-RestMethod (disabled - use manual send)
Write-Host "Report ready: $reportFile"
'@

        $sendReportPath = Join-Path $managerDir 'send_report.ps1'
        [System.IO.File]::WriteAllText($sendReportPath, $sendReportScript, [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $sendReportPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $sendReportPath"
    } catch {
        $msg = "[$role] Step 8a FAILED (send_report.ps1): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # --- 8b: DailyCollectionReport scheduled task ---
    try {
        $schtasksArgs = @(
            '/Create',
            '/TN', '\DailyCollectionReport',
            '/SC', 'DAILY',
            '/ST', '23:00',
            '/TR', "powershell.exe -WindowStyle Hidden -File '$managerDir\send_report.ps1'",
            '/F'
        )
        $output = & schtasks.exe @schtasksArgs 2>&1
        $exit   = $LASTEXITCODE
        if ($exit -ne 0) {
            $msg = "[$role] Step 8b: schtasks DailyCollectionReport returned exit $exit -- $output"
            Write-SetupLog $msg 'WARN'
            $errors.Add($msg)
        } else {
            $filesCreated++
            Write-SetupLog "[$role] Scheduled task created: \DailyCollectionReport"
        }
    } catch {
        $msg = "[$role] Step 8b FAILED (DailyCollectionReport task): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # --- 8c: DNSFlush scheduled task ---
    try {
        $dnsFlushArgs = @(
            '/Create',
            '/TN', '\DNSFlush',
            '/SC', 'DAILY',
            '/ST', '02:00',
            '/TR', 'ipconfig /flushdns',
            '/F'
        )
        $output = & schtasks.exe @dnsFlushArgs 2>&1
        $exit   = $LASTEXITCODE
        if ($exit -ne 0) {
            $msg = "[$role] Step 8c: schtasks DNSFlush returned exit $exit -- $output"
            Write-SetupLog $msg 'WARN'
            $errors.Add($msg)
        } else {
            $filesCreated++
            Write-SetupLog "[$role] Scheduled task created: \DNSFlush"
        }
    } catch {
        $msg = "[$role] Step 8c FAILED (DNSFlush task): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 9. OneDrive sync folder + Sync_Status.txt
    # ==================================================================
    Write-SetupLog "[$role] Step 9: OneDrive GoldenReturns_Backup"
    try {
        $oneDriveBase  = "$profileBase\OneDrive"
        $oneDriveBackup = "$oneDriveBase\GoldenReturns_Backup"
        New-DirectoryIfMissing $oneDriveBase
        New-DirectoryIfMissing $oneDriveBackup

        $syncStatusPath    = "$oneDriveBackup\Sync_Status.txt"
        $syncStatusContent = "OneDrive sync active for $managerDir\ -- last sync: 2026-04-17 22:41:09 | Files: 47 | Size: 23.4 MB"
        [System.IO.File]::WriteAllText($syncStatusPath, $syncStatusContent, [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $syncStatusPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $syncStatusPath"
    } catch {
        $msg = "[$role] Step 9 FAILED (OneDrive Sync_Status.txt): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 10. USBSTOR registry entries (4 pen drives)
    # ==================================================================
    Write-SetupLog "[$role] Step 10: USBSTOR registry entries"
    try {
        $usbStorBase = 'HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR'

        $usbDevices = @(
            @{
                Key          = 'Disk&Ven_SanDisk&Prod_Ultra&Rev_1.00\7&mgr00001&0&001'
                FriendlyName = 'SanDisk Ultra 32GB'
                DeviceDesc   = 'USB Mass Storage Device'
            },
            @{
                Key          = 'Disk&Ven_Kingston&Prod_DataTraveler&Rev_1.00\7&mgr00002&0&001'
                FriendlyName = 'Kingston DataTraveler 64GB'
                DeviceDesc   = 'USB Mass Storage Device'
            },
            @{
                Key          = 'Disk&Ven_Samsung&Prod_Bar_Plus&Rev_1.00\7&mgr00003&0&001'
                FriendlyName = 'Samsung BAR Plus 128GB'
                DeviceDesc   = 'USB Mass Storage Device'
            },
            @{
                Key          = 'Disk&Ven_WD&Prod_My_Passport&Rev_1.00\7&mgr00004&0&001'
                FriendlyName = 'WD My Passport 1TB'
                DeviceDesc   = 'USB Mass Storage Device'
            }
        )

        foreach ($dev in $usbDevices) {
            $fullKey = Join-Path $usbStorBase $dev.Key
            try {
                New-Item -Path $fullKey -Force -ErrorAction Stop | Out-Null
                Set-ItemProperty -LiteralPath $fullKey -Name 'FriendlyName' -Value $dev.FriendlyName -Force
                Set-ItemProperty -LiteralPath $fullKey -Name 'DeviceDesc'   -Value $dev.DeviceDesc   -Force
                $filesCreated++
                Write-SetupLog "[$role] Created USBSTOR key: $($dev.Key) -- $($dev.FriendlyName)"
            } catch {
                $msg = "[$role] Step 10: Failed to create USBSTOR key '$($dev.Key)': $($_.Exception.Message)"
                Write-SetupLog $msg 'WARN'
                $errors.Add($msg)
            }
        }
    } catch {
        $msg = "[$role] Step 10 FAILED (USBSTOR outer block): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 11. Recent LNK stubs (3 files, 76-byte minimal shell link header)
    # ==================================================================
    Write-SetupLog "[$role] Step 11: Recent LNK stubs"
    try {
        $recentDir = "$profileBase\AppData\Roaming\Microsoft\Windows\Recent"
        New-DirectoryIfMissing $recentDir

        # LinkCLSID: {00021401-0000-0000-C000-000000000006}
        $clsid = [byte[]]@(
            0x01, 0x14, 0x02, 0x00,
            0x00, 0x00,
            0x00, 0x00,
            0xC0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06
        )

        # Shared FILETIME values.
        $ftEpochLnk  = [datetime]::new(1601, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc)
        $creationUtc = [datetime]::new(2026, 4, 15,  9,  0,  0, [System.DateTimeKind]::Utc)
        $accessUtc   = [datetime]::new(2026, 4, 17, 11, 22,  0, [System.DateTimeKind]::Utc)
        $creationFt  = [long](($creationUtc - $ftEpochLnk).TotalSeconds * 10000000)
        $accessFt    = [long](($accessUtc   - $ftEpochLnk).TotalSeconds * 10000000)

        $lnkTargets = @(
            @{ Name = 'victims_master.xlsx.lnk';   Target = "$managerDir\victims_master.xlsx" },
            @{ Name = 'Mule_Accounts_Q4.xlsx.lnk'; Target = "$managerDir\Mule_Accounts_Q4.xlsx" },
            @{ Name = 'vault.veracrypt.lnk';        Target = "$managerDir\vault.veracrypt" }
        )

        foreach ($lnk in $lnkTargets) {
            try {
                $lnkBytes = New-Object byte[] 76

                # HeaderSize: 0x4C
                [System.BitConverter]::GetBytes([uint32]0x4C).CopyTo($lnkBytes, 0)
                # LinkCLSID
                [System.Array]::Copy($clsid, 0, $lnkBytes, 4, 16)
                # LinkFlags: HasLinkTargetIDList | HasLinkInfo
                [System.BitConverter]::GetBytes([uint32]0x00000009).CopyTo($lnkBytes, 20)
                # FileAttributes: FILE_ATTRIBUTE_ARCHIVE
                [System.BitConverter]::GetBytes([uint32]0x00000020).CopyTo($lnkBytes, 24)
                # CreationTime
                [System.BitConverter]::GetBytes($creationFt).CopyTo($lnkBytes, 28)
                # AccessTime
                [System.BitConverter]::GetBytes($accessFt).CopyTo($lnkBytes, 36)
                # WriteTime (same as access)
                [System.BitConverter]::GetBytes($accessFt).CopyTo($lnkBytes, 44)
                # FileSize: 0x00045678
                [System.BitConverter]::GetBytes([uint32]0x00045678).CopyTo($lnkBytes, 52)
                # IconIndex: 0
                [System.BitConverter]::GetBytes([uint32]0).CopyTo($lnkBytes, 56)
                # ShowCommand: SW_SHOWNORMAL = 1
                [System.BitConverter]::GetBytes([uint32]0x01).CopyTo($lnkBytes, 60)
                # HotKey, Reserved1, Reserved2, Reserved3 -- all zero (already zero-initialised)

                $lnkPath = "$recentDir\$($lnk.Name)"
                [System.IO.File]::WriteAllBytes($lnkPath, $lnkBytes)
                Add-HashRecord -FilePath $lnkPath -Role $role
                $filesCreated++
                Write-SetupLog "[$role] Created LNK: $lnkPath (-> $($lnk.Target))"
            } catch {
                $msg = "[$role] Step 11: Failed to create LNK '$($lnk.Name)': $($_.Exception.Message)"
                Write-SetupLog $msg 'WARN'
                $errors.Add($msg)
            }
        }
    } catch {
        $msg = "[$role] Step 11 FAILED (LNK stubs outer block): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 12. D:\Manager\GR_LabAssets\ManagerHiddenUSB\victims_old.xlsx
    #     (50-victim older list)
    # ==================================================================
    Write-SetupLog "[$role] Step 12: ManagerHiddenUSB\victims_old.xlsx"
    try {
        $hiddenUsbDir = Join-Path $managerDir 'GR_LabAssets\ManagerHiddenUSB'
        New-DirectoryIfMissing $hiddenUsbDir

        $sb = [System.Text.StringBuilder]::new()
        [void]$sb.AppendLine('VICTIMS - OLD LIST (superseded) - Created 2025-12-01')
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine('VictimId  | Name                          | Phone      | City        | AmountPaid    | Status')
        [void]$sb.AppendLine('----------|-------------------------------|------------|-------------|---------------|-------')

        for ($i = 0; $i -lt 50 -and $i -lt $VictimData.Count; $i++) {
            $v    = $VictimData[$i]
            $line = '{0,-9} | {1,-29} | {2,-10} | {3,-11} | Rs {4,10:N0} | {5}' -f `
                $v.VictimId,
                $v.Name,
                $v.Phone,
                $v.City,
                $v.AmountPaid,
                $v.FinalOutcome
            [void]$sb.AppendLine($line)
        }

        $oldVictimsPath = Join-Path $hiddenUsbDir 'victims_old.xlsx'
        New-MinimalDocx -OutPath $oldVictimsPath -BodyText $sb.ToString()
        Add-HashRecord -FilePath $oldVictimsPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $oldVictimsPath (50 victims)"
    } catch {
        $msg = "[$role] Step 12 FAILED (victims_old.xlsx): $($_.Exception.Message)"
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

    $status = if ($errors.Count -eq 0) {
        'DONE'
    } elseif ($filesCreated -gt 0) {
        'DONE_WITH_CONCERNS'
    } else {
        'BLOCKED'
    }

    Write-SetupLog ("[$role] Invoke-RoleSetup complete -- files created: $filesCreated, errors: $($errors.Count) -- status: $status")
    return $summary
}
