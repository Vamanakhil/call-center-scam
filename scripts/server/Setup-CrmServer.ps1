<#
================================================================================
  Setup-CrmServer.ps1  --  CRM-SERVER artefact generator
  "Golden Returns Wealth Management" cyber-forensics training lab.

  Role    : CRM-SERVER -- XAMPP/MySQL CRM back-end
  Hostname: CRM-SERVER
  IP      : 192.168.10.100 (static)
  OS      : Windows Server 2019 (script also works on Windows 10)

  *** SYNTHETIC TRAINING DATA ONLY ***
  All names, phones, accounts, amounts, database records and web application
  content are entirely FICTIONAL and machine-generated for an isolated DSP
  forensics training exercise. The "Golden Returns Wealth Management" scenario
  is a fabricated Ponzi/boiler-room story. None of this data refers to any
  real person, company, account or financial institution.
  Any resemblance to real people or entities is purely coincidental.

  DESIGN PRINCIPLE
  ----------------
  Phase A generates ALL evidence files FIRST, before touching MySQL. This
  guarantees trainees always have rich forensic evidence to analyze even if
  MySQL never starts. The golden_crm_backup_2026-04-15.sql dump (built in
  memory from the fake-data tables) IS the primary forensic artefact.

  Phase B then makes a best-effort, non-fatal attempt to stand up a live
  MySQL instance (3 tiers) and import the dump file already written in Phase A.
  Failure of any/all Phase B tiers never aborts the run.

  Requirements : PowerShell 5.1 (.NET Framework 4.x), Windows Server 2019 /
                 Windows 10.  Must be run As Administrator.
                 Dot-sourced by 00-Master-Setup.ps1 which has already loaded
                 shared\New-FakeData.ps1.
================================================================================
#>

#Requires -RunAsAdministrator

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Dot-source shared library when this script is invoked standalone.
if (-not (Get-Variable -Name 'VictimData' -Scope Global -ErrorAction SilentlyContinue)) {
    . "$PSScriptRoot\..\shared\New-FakeData.ps1"
}

# ---------------------------------------------------------------------------
# Helper: execute SQL via mysql.exe using a Process-based stdin pipe.
# This avoids the broken "--execute=source" approach which does not reliably
# read external .sql files. The SQL text is fed directly to mysql's stdin.
# ---------------------------------------------------------------------------
function Invoke-MySql {
    param(
        [string]$Sql,
        [string]$Database = '',
        [string]$MysqlExe = "$env:SystemDrive\xampp\mysql\bin\mysql.exe"
    )
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $MysqlExe
    $psi.Arguments = if ($Database) { "-u root -D `"$Database`" --batch --silent" } else { "-u root --batch --silent" }
    $psi.RedirectStandardInput  = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError  = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow  = $true
    $proc = [System.Diagnostics.Process]::Start($psi)
    $proc.StandardInput.WriteLine($Sql)
    $proc.StandardInput.Close()
    $stdout = $proc.StandardOutput.ReadToEnd()
    $stderr = $proc.StandardError.ReadToEnd()
    $proc.WaitForExit()
    if ($proc.ExitCode -ne 0) {
        throw "MySQL error (exit $($proc.ExitCode)): $stderr"
    }
    return $stdout
}

# ---------------------------------------------------------------------------
# Helper: raw TCP probe of 127.0.0.1:3306. Faster and more reliable than
# spawning mysqladmin just to test liveness.
# ---------------------------------------------------------------------------
function Test-Port3306 {
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $tcp.Connect('127.0.0.1', 3306)
        $tcp.Close()
        return $true
    } catch {
        return $false
    }
}

# ---------------------------------------------------------------------------
# Helper: SQL-escape a value for single-quoted INSERT literals.
# Always coerces to string; guards against $null so StrictMode is happy.
# ---------------------------------------------------------------------------
function Get-SqlString {
    param($Value)
    if ($null -eq $Value) { return '' }
    return ([string]$Value) -replace "'", "''"
}

# ---------------------------------------------------------------------------
# Helper: build the complete golden_crm SQL dump as a single string.
# Schema + all victim/lead/transaction/call_log/users INSERTs, batched.
# This is pure in-memory string work with NO external dependency, so it can
# always run in Phase A regardless of MySQL availability.
# ---------------------------------------------------------------------------
function Build-GoldenCrmDump {
    param(
        $Victims,
        $Leads,
        $Transactions,
        $CallLogs
    )

    $sb = [System.Text.StringBuilder]::new()

    # --- Header ---
    [void]$sb.AppendLine('-- Golden Returns CRM database backup')
    [void]$sb.AppendLine('-- MySQL dump 10.13  Distrib 8.2.12, for Win64 (x86_64)')
    [void]$sb.AppendLine('--')
    [void]$sb.AppendLine('-- Host: localhost (CRM-SERVER 192.168.10.100)    Database: golden_crm')
    [void]$sb.AppendLine('-- ------------------------------------------------------')
    [void]$sb.AppendLine('-- Server version 8.2.12 (XAMPP)')
    [void]$sb.AppendLine('-- Backup generated: 2026-04-15 02:00:01')
    [void]$sb.AppendLine('--')
    [void]$sb.AppendLine('-- *** SYNTHETIC TRAINING DATA ONLY -- entirely fictional ***')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;')
    [void]$sb.AppendLine('/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;')
    [void]$sb.AppendLine('/*!40101 SET NAMES utf8mb4 */;')
    [void]$sb.AppendLine('/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;')
    [void]$sb.AppendLine('')

    # --- Schema ---
    [void]$sb.AppendLine('CREATE DATABASE IF NOT EXISTS golden_crm CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;')
    [void]$sb.AppendLine('USE golden_crm;')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('CREATE TABLE IF NOT EXISTS victims (')
    [void]$sb.AppendLine('    id               INT AUTO_INCREMENT PRIMARY KEY,')
    [void]$sb.AppendLine('    victim_id        VARCHAR(20) UNIQUE NOT NULL,')
    [void]$sb.AppendLine('    name             VARCHAR(100),')
    [void]$sb.AppendLine('    phone            VARCHAR(20),')
    [void]$sb.AppendLine('    email            VARCHAR(100),')
    [void]$sb.AppendLine('    city             VARCHAR(50),')
    [void]$sb.AppendLine('    amount_paid      DECIMAL(12,2),')
    [void]$sb.AppendLine('    initial_deposit  DECIMAL(12,2),')
    [void]$sb.AppendLine("    final_outcome    ENUM('BURNED','ACTIVE','REFUNDED') DEFAULT 'ACTIVE',")
    [void]$sb.AppendLine('    assigned_closer  VARCHAR(50),')
    [void]$sb.AppendLine('    date_added       DATE,')
    [void]$sb.AppendLine("    status           ENUM('ACTIVE','CLOSED') DEFAULT 'ACTIVE',")
    [void]$sb.AppendLine('    notes            TEXT')
    [void]$sb.AppendLine(');')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('CREATE TABLE IF NOT EXISTS leads (')
    [void]$sb.AppendLine('    id             INT AUTO_INCREMENT PRIMARY KEY,')
    [void]$sb.AppendLine('    lead_id        INT UNIQUE,')
    [void]$sb.AppendLine('    name           VARCHAR(100),')
    [void]$sb.AppendLine('    phone          VARCHAR(20),')
    [void]$sb.AppendLine('    email          VARCHAR(100),')
    [void]$sb.AppendLine("    source         ENUM('LinkedIn','Facebook','Instagram','Purchased_List','Referral'),")
    [void]$sb.AppendLine('    heat_score     INT,')
    [void]$sb.AppendLine("    status         ENUM('HOT','WARM','COLD','ASSIGNED','DNC'),")
    [void]$sb.AppendLine('    assigned_agent VARCHAR(50),')
    [void]$sb.AppendLine('    date_added     DATE')
    [void]$sb.AppendLine(');')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('CREATE TABLE IF NOT EXISTS transactions (')
    [void]$sb.AppendLine('    id               INT AUTO_INCREMENT PRIMARY KEY,')
    [void]$sb.AppendLine('    txn_id           INT UNIQUE,')
    [void]$sb.AppendLine('    victim_id        VARCHAR(20),')
    [void]$sb.AppendLine('    amount           DECIMAL(12,2),')
    [void]$sb.AppendLine('    upi_id           VARCHAR(100),')
    [void]$sb.AppendLine('    beneficiary_acct VARCHAR(50),')
    [void]$sb.AppendLine('    txn_date         DATE,')
    [void]$sb.AppendLine("    status           ENUM('CONFIRMED','PENDING','FAILED'),")
    [void]$sb.AppendLine('    notes            TEXT')
    [void]$sb.AppendLine(');')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('CREATE TABLE IF NOT EXISTS call_logs (')
    [void]$sb.AppendLine('    id                  INT AUTO_INCREMENT PRIMARY KEY,')
    [void]$sb.AppendLine('    log_id              INT UNIQUE,')
    [void]$sb.AppendLine('    agent_id            VARCHAR(50),')
    [void]$sb.AppendLine('    victim_id           VARCHAR(20),')
    [void]$sb.AppendLine('    duration_seconds    INT,')
    [void]$sb.AppendLine('    recording_filename  VARCHAR(200),')
    [void]$sb.AppendLine('    call_date           DATE,')
    [void]$sb.AppendLine("    call_type           ENUM('OUTBOUND','INBOUND'),")
    [void]$sb.AppendLine("    outcome             ENUM('CONVERTED','FOLLOW_UP','NOT_INTERESTED','INVALID')")
    [void]$sb.AppendLine(');')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('CREATE TABLE IF NOT EXISTS users (')
    [void]$sb.AppendLine('    id            INT AUTO_INCREMENT PRIMARY KEY,')
    [void]$sb.AppendLine('    username      VARCHAR(50) UNIQUE,')
    [void]$sb.AppendLine('    password_hash VARCHAR(255),')
    [void]$sb.AppendLine("    role          ENUM('admin','agent','readonly'),")
    [void]$sb.AppendLine('    created_at    DATETIME DEFAULT NOW()')
    [void]$sb.AppendLine(');')
    [void]$sb.AppendLine('')

    # --- victims (487 rows, batches of 100) ---
    [void]$sb.AppendLine('--')
    [void]$sb.AppendLine('-- Dumping data for table `victims`')
    [void]$sb.AppendLine('--')
    $allVictims = @($Victims)
    $bs = 100; $start = 0
    while ($start -lt $allVictims.Count) {
        $end = [math]::Min($start + $bs, $allVictims.Count)
        $rows = [System.Collections.Generic.List[string]]::new()
        for ($i = $start; $i -lt $end; $i++) {
            $v     = $allVictims[$i]
            $name  = Get-SqlString $v.Name
            $phone = Get-SqlString $v.Phone
            $email = Get-SqlString $v.Email
            $city  = Get-SqlString $v.City
            $notes = Get-SqlString $v.Notes
            $rows.Add(
                "('$($v.VictimId)','$name','$phone','$email','$city'," +
                "$($v.AmountPaid),$($v.InitialDeposit)," +
                "'$($v.FinalOutcome)','$($v.AssignedCloser)'," +
                "'$($v.DateAdded)','$($v.Status)','$notes')"
            )
        }
        [void]$sb.AppendLine('INSERT INTO victims (victim_id,name,phone,email,city,amount_paid,initial_deposit,final_outcome,assigned_closer,date_added,status,notes) VALUES')
        [void]$sb.AppendLine(($rows -join ",`n") + ';')
        $start = $end
    }
    [void]$sb.AppendLine('')

    # --- leads (12,000 rows, batches of 500) ---
    [void]$sb.AppendLine('--')
    [void]$sb.AppendLine('-- Dumping data for table `leads`')
    [void]$sb.AppendLine('--')
    $allLeads = @($Leads)
    $bs = 500; $start = 0
    while ($start -lt $allLeads.Count) {
        $end = [math]::Min($start + $bs, $allLeads.Count)
        $rows = [System.Collections.Generic.List[string]]::new()
        for ($i = $start; $i -lt $end; $i++) {
            $l     = $allLeads[$i]
            $name  = Get-SqlString $l.Name
            $phone = Get-SqlString $l.Phone
            $email = Get-SqlString $l.Email
            $agent = Get-SqlString $l.AssignedAgent
            $rows.Add(
                "($($l.LeadId),'$name','$phone','$email'," +
                "'$($l.Source)',$($l.HeatScore),'$($l.Status)'," +
                "'$agent','$($l.DateAdded)')"
            )
        }
        [void]$sb.AppendLine('INSERT INTO leads (lead_id,name,phone,email,source,heat_score,status,assigned_agent,date_added) VALUES')
        [void]$sb.AppendLine(($rows -join ",`n") + ';')
        $start = $end
    }
    [void]$sb.AppendLine('')

    # --- transactions (2,314 rows, batches of 100) ---
    [void]$sb.AppendLine('--')
    [void]$sb.AppendLine('-- Dumping data for table `transactions`')
    [void]$sb.AppendLine('--')
    $allTxns = @($Transactions)
    $bs = 100; $start = 0
    while ($start -lt $allTxns.Count) {
        $end = [math]::Min($start + $bs, $allTxns.Count)
        $rows = [System.Collections.Generic.List[string]]::new()
        for ($i = $start; $i -lt $end; $i++) {
            $t     = $allTxns[$i]
            $upi   = Get-SqlString $t.UpiId
            $acct  = Get-SqlString $t.BeneficiaryAcct
            $notes = Get-SqlString $t.Notes
            $rows.Add(
                "($($t.TxnId),'$($t.VictimId)',$($t.Amount)," +
                "'$upi','$acct','$($t.TxnDate)'," +
                "'$($t.Status)','$notes')"
            )
        }
        [void]$sb.AppendLine('INSERT INTO transactions (txn_id,victim_id,amount,upi_id,beneficiary_acct,txn_date,status,notes) VALUES')
        [void]$sb.AppendLine(($rows -join ",`n") + ';')
        $start = $end
    }
    [void]$sb.AppendLine('')

    # --- call_logs (891 rows, batches of 100) ---
    [void]$sb.AppendLine('--')
    [void]$sb.AppendLine('-- Dumping data for table `call_logs`')
    [void]$sb.AppendLine('--')
    $allLogs = @($CallLogs)
    $bs = 100; $start = 0
    while ($start -lt $allLogs.Count) {
        $end = [math]::Min($start + $bs, $allLogs.Count)
        $rows = [System.Collections.Generic.List[string]]::new()
        for ($i = $start; $i -lt $end; $i++) {
            $c    = $allLogs[$i]
            $agent = Get-SqlString $c.AgentId
            $recf  = Get-SqlString $c.RecordingFilename
            $rows.Add(
                "($($c.LogId),'$agent','$($c.VictimId)'," +
                "$($c.DurationSeconds),'$recf'," +
                "'$($c.CallDate)','$($c.CallType)','$($c.Outcome)')"
            )
        }
        [void]$sb.AppendLine('INSERT INTO call_logs (log_id,agent_id,victim_id,duration_seconds,recording_filename,call_date,call_type,outcome) VALUES')
        [void]$sb.AppendLine(($rows -join ",`n") + ';')
        $start = $end
    }
    [void]$sb.AppendLine('')

    # --- users (with SHA2-256 password hashes) ---
    [void]$sb.AppendLine('--')
    [void]$sb.AppendLine('-- Dumping data for table `users`')
    [void]$sb.AppendLine('--')
    [void]$sb.AppendLine('INSERT INTO users (username, password_hash, role) VALUES')
    [void]$sb.AppendLine("('admin',    SHA2('Gr@Crm2026!',     256), 'admin'),")
    [void]$sb.AppendLine("('crm_app',  SHA2('Gr@Crm2026!',     256), 'admin'),")
    [void]$sb.AppendLine("('rahul.s',  SHA2('Gr@2026Agent01',  256), 'agent'),")
    [void]$sb.AppendLine("('priya.v',  SHA2('Gr@2026Agent02',  256), 'agent'),")
    [void]$sb.AppendLine("('amit.p',   SHA2('Gr@2026Agent03',  256), 'agent'),")
    [void]$sb.AppendLine("('sneha.i',  SHA2('Gr@2026Agent04',  256), 'agent'),")
    [void]$sb.AppendLine("('vikas.n',  SHA2('Gr@2026Agent05',  256), 'admin');")
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;')
    [void]$sb.AppendLine('/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;')
    [void]$sb.AppendLine('-- Dump completed on 2026-04-15  2:00:14')

    return $sb.ToString()
}

# ---------------------------------------------------------------------------
# Helper: bring up MySQL using a 3-tier strategy. NON-FATAL. Returns the path
# to mysql.exe if MySQL becomes available, $null otherwise.
#   Tier 0 : already alive on 127.0.0.1:3306 -> reuse
#   Tier 1 : XAMPP MySQL as a Windows service (with data-dir init)
#   Tier 2 : standalone mysqld.exe process (no service)
# ---------------------------------------------------------------------------
function Start-LabMySQL {
    param([string]$XamppDir)

    $mysql   = "$XamppDir\mysql\bin\mysql.exe"
    $mysqld  = "$XamppDir\mysql\bin\mysqld.exe"
    $myIni   = "$XamppDir\mysql\bin\my.ini"
    $dataDir = "$XamppDir\mysql\data"
    $svcName = 'GR_MySQL_Lab'

    # --- Tier 0: Is MySQL already alive (TCP 127.0.0.1:3306)? ---
    Write-SetupLog "[CRM-SERVER] MySQL Tier 0: TCP check 127.0.0.1:3306..."
    if (Test-Port3306) {
        Write-SetupLog "[CRM-SERVER] MySQL already alive on port 3306 -- reusing instance"
        if (Test-Path $mysql) { return $mysql }
        $mysqlCmd = Get-Command 'mysql.exe' -ErrorAction SilentlyContinue
        if ($mysqlCmd) { return $mysqlCmd.Source }
        return $mysql
    }

    # --- Tier 1: XAMPP MySQL as a Windows service ---
    Write-SetupLog "[CRM-SERVER] MySQL Tier 1: XAMPP service at $XamppDir..."
    if (-not (Test-Path $mysqld)) {
        Write-SetupLog "[CRM-SERVER] XAMPP mysqld.exe not found -- skipping Tier 1" 'WARN'
    } else {
        try {
            # Initialize data dir if fresh.
            if (-not (Test-Path "$dataDir\ibdata1")) {
                Write-SetupLog "[CRM-SERVER] Initializing MySQL data directory..."
                & $mysqld '--initialize-insecure' "--datadir=$dataDir" 2>&1 | Out-Null
                Start-Sleep -Seconds 5
            }

            # Remove any conflicting old service to avoid port conflicts.
            foreach ($svc in @('GR_MySQL_Lab','MySQLForTraining','mysql','MySQL80','MySQL57')) {
                if (Get-Service $svc -ErrorAction SilentlyContinue) {
                    Stop-Service $svc -Force -ErrorAction SilentlyContinue
                    Start-Sleep 1
                    & $mysqld '--remove' $svc 2>&1 | Out-Null
                }
            }

            # Register service (THREE separate args) then start.
            if (Test-Path $myIni) {
                & $mysqld '--install' $svcName "--defaults-file=$myIni" 2>&1 | Out-Null
            } else {
                & $mysqld '--install' $svcName 2>&1 | Out-Null
            }
            Start-Sleep -Seconds 2
            Start-Service $svcName -ErrorAction Stop

            # Wait up to 60s for port 3306.
            Write-SetupLog "[CRM-SERVER] Waiting for MySQL port 3306 (up to 60s)..."
            $alive = $false
            for ($i = 0; $i -lt 60; $i++) {
                if (Test-Port3306) { $alive = $true; break }
                Start-Sleep -Seconds 1
            }
            if ($alive) {
                Write-SetupLog "[CRM-SERVER] MySQL Tier 1 alive -- XAMPP service running"
                return $mysql
            }
            throw "MySQL service started but port 3306 never opened within 60 seconds"
        } catch {
            Write-SetupLog "[CRM-SERVER] Tier 1 failed: $($_.Exception.Message) -- trying Tier 2" 'WARN'
        }
    }

    # --- Tier 2: standalone mysqld.exe process (no service) ---
    Write-SetupLog "[CRM-SERVER] MySQL Tier 2: launching mysqld.exe standalone..."
    if (Test-Path $mysqld) {
        try {
            Get-Process -Name 'mysqld' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2

            if (-not (Test-Path "$dataDir\ibdata1")) {
                & $mysqld '--initialize-insecure' "--datadir=$dataDir" 2>&1 | Out-Null
                Start-Sleep -Seconds 3
            }

            $standArgs = @("--datadir=$dataDir", '--port=3306', '--skip-grant-tables')
            if (Test-Path $myIni) { $standArgs = @("--defaults-file=$myIni") + $standArgs }
            Start-Process -FilePath $mysqld -ArgumentList $standArgs -NoNewWindow -PassThru | Out-Null

            $alive = $false
            for ($i = 0; $i -lt 30; $i++) {
                Start-Sleep -Seconds 1
                if (Test-Port3306) { $alive = $true; break }
            }
            if ($alive) {
                Write-SetupLog "[CRM-SERVER] MySQL Tier 2 alive -- standalone process running"
                return $mysql
            }
            throw "Standalone mysqld port 3306 never opened within 30 seconds"
        } catch {
            Write-SetupLog "[CRM-SERVER] Tier 2 failed: $($_.Exception.Message) -- continuing file-only" 'WARN'
        }
    }

    Write-SetupLog "[CRM-SERVER] All MySQL tiers failed -- Phase A artefacts already written; continuing" 'WARN'
    return $null
}

# ---------------------------------------------------------------------------
# Main role function
# ---------------------------------------------------------------------------
function Invoke-RoleSetup {
    <#
        Creates all CRM-SERVER evidence artefacts.
        Phase A (file artefacts) always succeeds; Phase B (MySQL) is best-effort.
        Returns @{ Role='CRM-SERVER'; FilesCreated=N; Errors=@() }
    #>

    $role         = 'CRM-SERVER'
    $filesCreated = 0
    $errors       = [System.Collections.Generic.List[string]]::new()

    $xamppDir   = "$env:SystemDrive\xampp"
    $mysql      = "$xamppDir\mysql\bin\mysql.exe"

    # Resolve backup dir once (D: preferred, else system drive).
    $backupDir  = if (Test-Path 'D:\') { 'D:\Backups\old' } else { "$env:SystemDrive\CRM_Backups\old" }
    $sqlDumpFile = Join-Path $backupDir 'golden_crm_backup_2026-04-15.sql'

    Write-SetupLog "[$role] Invoke-RoleSetup starting"

    # ##################################################################
    # PHASE A -- File artefacts (no MySQL needed, always succeed)
    # ##################################################################
    Write-SetupLog "[$role] ===== PHASE A: file artefacts (always succeed) ====="

    # ------------------------------------------------------------------
    # A1. Build the complete SQL dump string in memory.
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] A1: building golden_crm SQL dump in memory"
    $dumpSql = $null
    try {
        $dumpSql = Build-GoldenCrmDump `
            -Victims      $VictimData `
            -Leads        $LeadData `
            -Transactions $TransactionData `
            -CallLogs     $CallLogData
        Write-SetupLog "[$role] A1 complete: dump built ($($dumpSql.Length) chars)"
    } catch {
        $msg = "[$role] A1 FAILED (build dump): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # A2. Write golden_crm_backup_2026-04-15.sql (THE forensic artefact).
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] A2: writing $sqlDumpFile"
    try {
        New-DirectoryIfMissing $backupDir
        if ($null -ne $dumpSql) {
            [System.IO.File]::WriteAllText($sqlDumpFile, $dumpSql, [System.Text.Encoding]::UTF8)
            Add-HashRecord -FilePath $sqlDumpFile -Role $role
            $filesCreated++
            Write-SetupLog "[$role] A2 complete: $sqlDumpFile"
        } else {
            $msg = "[$role] A2 SKIP -- dump string was not built"
            Write-SetupLog $msg 'WARN'
            $errors.Add($msg)
        }
    } catch {
        $msg = "[$role] A2 FAILED (write SQL dump): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # A3. CSV exports (forensic analysis + agent reference).
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] A3: CSV exports to $backupDir"

    # A3a. victims_export.csv
    try {
        $csvPath = Join-Path $backupDir 'victims_export.csv'
        $sb = [System.Text.StringBuilder]::new()
        [void]$sb.AppendLine('VictimId,Name,Phone,City,AmountPaid,FinalOutcome,AssignedCloser,DateAdded')
        foreach ($v in @($VictimData)) {
            $name = (Get-SqlString $v.Name)  -replace ',', ' '
            $city = (Get-SqlString $v.City)  -replace ',', ' '
            [void]$sb.AppendLine(
                ('{0},{1},{2},{3},{4},{5},{6},{7}' -f `
                    $v.VictimId, $name, $v.Phone, $city, $v.AmountPaid, `
                    $v.FinalOutcome, $v.AssignedCloser, $v.DateAdded)
            )
        }
        [System.IO.File]::WriteAllText($csvPath, $sb.ToString(), [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $csvPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] A3a complete: $csvPath"
    } catch {
        $msg = "[$role] A3a FAILED (victims_export.csv): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # A3b. leads_sample.csv (first 1000 leads for reference)
    try {
        $csvPath = Join-Path $backupDir 'leads_sample.csv'
        $sb = [System.Text.StringBuilder]::new()
        [void]$sb.AppendLine('LeadId,Name,Phone,Source,HeatScore,Status,AssignedAgent,DateAdded')
        $allLeads = @($LeadData)
        $limit = [math]::Min(1000, $allLeads.Count)
        for ($i = 0; $i -lt $limit; $i++) {
            $l    = $allLeads[$i]
            $name = (Get-SqlString $l.Name) -replace ',', ' '
            [void]$sb.AppendLine(
                ('{0},{1},{2},{3},{4},{5},{6},{7}' -f `
                    $l.LeadId, $name, $l.Phone, $l.Source, $l.HeatScore, `
                    $l.Status, $l.AssignedAgent, $l.DateAdded)
            )
        }
        [System.IO.File]::WriteAllText($csvPath, $sb.ToString(), [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $csvPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] A3b complete: $csvPath"
    } catch {
        $msg = "[$role] A3b FAILED (leads_sample.csv): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # A3c. transactions_export.csv
    try {
        $csvPath = Join-Path $backupDir 'transactions_export.csv'
        $sb = [System.Text.StringBuilder]::new()
        [void]$sb.AppendLine('TxnId,VictimId,Amount,UpiId,BeneficiaryAcct,TxnDate,Status')
        foreach ($t in @($TransactionData)) {
            $upi  = (Get-SqlString $t.UpiId)           -replace ',', ' '
            $acct = (Get-SqlString $t.BeneficiaryAcct) -replace ',', ' '
            [void]$sb.AppendLine(
                ('{0},{1},{2},{3},{4},{5},{6}' -f `
                    $t.TxnId, $t.VictimId, $t.Amount, $upi, $acct, $t.TxnDate, $t.Status)
            )
        }
        [System.IO.File]::WriteAllText($csvPath, $sb.ToString(), [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $csvPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] A3c complete: $csvPath"
    } catch {
        $msg = "[$role] A3c FAILED (transactions_export.csv): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # A4. CRM web application files under C:\xampp\htdocs\golden_crm\
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] A4: CRM web application files"
    $htdocsDir = "$xamppDir\htdocs\golden_crm"
    try {
        New-DirectoryIfMissing $htdocsDir
    } catch {
        $msg = "[$role] A4 WARN -- could not create htdocs dir: $($_.Exception.Message)"
        Write-SetupLog $msg 'WARN'
        $errors.Add($msg)
    }

    # A4a. index.php -- CRM login page
    Write-SetupLog "[$role] A4a: index.php"
    try {
        $indexPhp = @'
<?php
// Golden Returns CRM - Admin Panel
// Version 2.3.1
session_start();
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $user = $_POST['username'] ?? '';
    $pass = $_POST['password'] ?? '';
    // TODO: replace with proper auth
    if ($user === 'admin' && $pass === 'Gr@Crm2026!') {
        $_SESSION['user'] = $user;
        header('Location: dashboard.php');
        exit;
    }
}
?>
<!DOCTYPE html>
<html><head><title>Golden Returns CRM</title></head>
<body style="font-family:sans-serif;text-align:center;margin-top:100px">
<h2>Golden Returns Wealth Management</h2>
<h3>Staff Portal Login</h3>
<form method="POST">
Username: <input name="username"><br><br>
Password: <input type="password" name="password"><br><br>
<input type="submit" value="Login">
</form>
</body></html>
'@
        $indexPath = "$htdocsDir\index.php"
        [System.IO.File]::WriteAllText($indexPath, $indexPhp, [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $indexPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $indexPath"
    } catch {
        $msg = "[$role] A4a FAILED (index.php): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # A4b. dashboard.php -- main dashboard
    Write-SetupLog "[$role] A4b: dashboard.php"
    try {
        $dashboardPhp = @'
<?php
session_start();
if (!isset($_SESSION['user'])) { header('Location: index.php'); exit; }
$conn = new mysqli('localhost', 'crm_app', 'Gr@Crm2026!', 'golden_crm');
$victimCount = $conn->query("SELECT COUNT(*) as c FROM victims")->fetch_assoc()['c'];
$activeCount = $conn->query("SELECT COUNT(*) as c FROM victims WHERE status='ACTIVE'")->fetch_assoc()['c'];
$totalAmount = $conn->query("SELECT SUM(amount_paid) as s FROM victims")->fetch_assoc()['s'];
?>
<!DOCTYPE html>
<html><head><title>GR CRM Dashboard</title></head>
<body style="font-family:sans-serif;padding:20px">
<h2>Golden Returns CRM &mdash; Admin Dashboard</h2>
<p>Total Victims: <?= $victimCount ?> | Active: <?= $activeCount ?> | Total Collected: Rs <?= number_format($totalAmount) ?></p>
<ul>
<li><a href="victims.php">Victim Management</a></li>
<li><a href="leads.php">Lead Pipeline</a></li>
<li><a href="transactions.php">Transactions</a></li>
<li><a href="calls.php">Call Logs</a></li>
</ul>
</body></html>
'@
        $dashPath = "$htdocsDir\dashboard.php"
        [System.IO.File]::WriteAllText($dashPath, $dashboardPhp, [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $dashPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $dashPath"
    } catch {
        $msg = "[$role] A4b FAILED (dashboard.php): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # A4c. victims.php -- victim list page
    Write-SetupLog "[$role] A4c: victims.php"
    try {
        $victimsPhp = @'
<?php
session_start();
if (!isset($_SESSION['user'])) { header('Location: index.php'); exit; }
$conn = new mysqli('localhost', 'crm_app', 'Gr@Crm2026!', 'golden_crm');
$result = $conn->query("SELECT victim_id,name,phone,city,amount_paid,final_outcome,assigned_closer,status FROM victims ORDER BY id LIMIT 200");
?>
<!DOCTYPE html>
<html><head><title>GR CRM - Victims</title></head>
<body style="font-family:sans-serif;padding:20px">
<h2>Victim Management</h2>
<a href="dashboard.php">Back</a><br><br>
<table border="1" cellpadding="4" cellspacing="0">
<tr><th>ID</th><th>Name</th><th>Phone</th><th>City</th><th>Amount (Rs)</th><th>Outcome</th><th>Closer</th><th>Status</th></tr>
<?php while($row = $result->fetch_assoc()): ?>
<tr>
  <td><?= htmlspecialchars($row['victim_id']) ?></td>
  <td><?= htmlspecialchars($row['name']) ?></td>
  <td><?= htmlspecialchars($row['phone']) ?></td>
  <td><?= htmlspecialchars($row['city']) ?></td>
  <td><?= number_format($row['amount_paid']) ?></td>
  <td><?= htmlspecialchars($row['final_outcome']) ?></td>
  <td><?= htmlspecialchars($row['assigned_closer']) ?></td>
  <td><?= htmlspecialchars($row['status']) ?></td>
</tr>
<?php endwhile; ?>
</table>
</body></html>
'@
        $victimsPath = "$htdocsDir\victims.php"
        [System.IO.File]::WriteAllText($victimsPath, $victimsPhp, [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $victimsPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $victimsPath"
    } catch {
        $msg = "[$role] A4c FAILED (victims.php): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # A4d. leads.php -- lead pipeline page
    Write-SetupLog "[$role] A4d: leads.php"
    try {
        $leadsPhp = @'
<?php
session_start();
if (!isset($_SESSION['user'])) { header('Location: index.php'); exit; }
$conn = new mysqli('localhost', 'crm_app', 'Gr@Crm2026!', 'golden_crm');
$result = $conn->query("SELECT lead_id,name,phone,source,heat_score,status,assigned_agent FROM leads WHERE status IN ('HOT','ASSIGNED') ORDER BY heat_score DESC LIMIT 200");
?>
<!DOCTYPE html>
<html><head><title>GR CRM - Leads</title></head>
<body style="font-family:sans-serif;padding:20px">
<h2>Lead Pipeline</h2>
<a href="dashboard.php">Back</a><br><br>
<table border="1" cellpadding="4" cellspacing="0">
<tr><th>Lead ID</th><th>Name</th><th>Phone</th><th>Source</th><th>Heat Score</th><th>Status</th><th>Agent</th></tr>
<?php while($row = $result->fetch_assoc()): ?>
<tr>
  <td><?= htmlspecialchars($row['lead_id']) ?></td>
  <td><?= htmlspecialchars($row['name']) ?></td>
  <td><?= htmlspecialchars($row['phone']) ?></td>
  <td><?= htmlspecialchars($row['source']) ?></td>
  <td><?= htmlspecialchars($row['heat_score']) ?></td>
  <td><?= htmlspecialchars($row['status']) ?></td>
  <td><?= htmlspecialchars($row['assigned_agent']) ?></td>
</tr>
<?php endwhile; ?>
</table>
</body></html>
'@
        $leadsPath = "$htdocsDir\leads.php"
        [System.IO.File]::WriteAllText($leadsPath, $leadsPhp, [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $leadsPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $leadsPath"
    } catch {
        $msg = "[$role] A4d FAILED (leads.php): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # A4e. transactions.php -- transaction list page
    Write-SetupLog "[$role] A4e: transactions.php"
    try {
        $transactionsPhp = @'
<?php
session_start();
if (!isset($_SESSION['user'])) { header('Location: index.php'); exit; }
$conn = new mysqli('localhost', 'crm_app', 'Gr@Crm2026!', 'golden_crm');
$result = $conn->query("SELECT txn_id,victim_id,amount,upi_id,beneficiary_acct,txn_date,status FROM transactions ORDER BY id DESC LIMIT 200");
?>
<!DOCTYPE html>
<html><head><title>GR CRM - Transactions</title></head>
<body style="font-family:sans-serif;padding:20px">
<h2>Transactions</h2>
<a href="dashboard.php">Back</a><br><br>
<table border="1" cellpadding="4" cellspacing="0">
<tr><th>TXN ID</th><th>Victim</th><th>Amount (Rs)</th><th>UPI ID</th><th>Beneficiary Acct</th><th>Date</th><th>Status</th></tr>
<?php while($row = $result->fetch_assoc()): ?>
<tr>
  <td><?= htmlspecialchars($row['txn_id']) ?></td>
  <td><?= htmlspecialchars($row['victim_id']) ?></td>
  <td><?= number_format($row['amount']) ?></td>
  <td><?= htmlspecialchars($row['upi_id']) ?></td>
  <td><?= htmlspecialchars($row['beneficiary_acct']) ?></td>
  <td><?= htmlspecialchars($row['txn_date']) ?></td>
  <td><?= htmlspecialchars($row['status']) ?></td>
</tr>
<?php endwhile; ?>
</table>
</body></html>
'@
        $txnPath = "$htdocsDir\transactions.php"
        [System.IO.File]::WriteAllText($txnPath, $transactionsPhp, [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $txnPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $txnPath"
    } catch {
        $msg = "[$role] A4e FAILED (transactions.php): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # A4f. calls.php -- call log page
    Write-SetupLog "[$role] A4f: calls.php"
    try {
        $callsPhp = @'
<?php
session_start();
if (!isset($_SESSION['user'])) { header('Location: index.php'); exit; }
$conn = new mysqli('localhost', 'crm_app', 'Gr@Crm2026!', 'golden_crm');
$result = $conn->query("SELECT log_id,agent_id,victim_id,duration_seconds,recording_filename,call_date,call_type,outcome FROM call_logs ORDER BY id DESC LIMIT 200");
?>
<!DOCTYPE html>
<html><head><title>GR CRM - Call Logs</title></head>
<body style="font-family:sans-serif;padding:20px">
<h2>Call Logs</h2>
<a href="dashboard.php">Back</a><br><br>
<table border="1" cellpadding="4" cellspacing="0">
<tr><th>Log ID</th><th>Agent</th><th>Victim</th><th>Duration (s)</th><th>Recording</th><th>Date</th><th>Type</th><th>Outcome</th></tr>
<?php while($row = $result->fetch_assoc()): ?>
<tr>
  <td><?= htmlspecialchars($row['log_id']) ?></td>
  <td><?= htmlspecialchars($row['agent_id']) ?></td>
  <td><?= htmlspecialchars($row['victim_id']) ?></td>
  <td><?= htmlspecialchars($row['duration_seconds']) ?></td>
  <td><?= htmlspecialchars($row['recording_filename']) ?></td>
  <td><?= htmlspecialchars($row['call_date']) ?></td>
  <td><?= htmlspecialchars($row['call_type']) ?></td>
  <td><?= htmlspecialchars($row['outcome']) ?></td>
</tr>
<?php endwhile; ?>
</table>
</body></html>
'@
        $callsPath = "$htdocsDir\calls.php"
        [System.IO.File]::WriteAllText($callsPath, $callsPhp, [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $callsPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $callsPath"
    } catch {
        $msg = "[$role] A4f FAILED (calls.php): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # A5. Windows Firewall log with brute-force RDP artefact (47 DROP + 1 ALLOW)
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] A5: Firewall log pfirewall.log"
    try {
        $fwLogDir = "$env:SystemDrive\Windows\System32\LogFiles\Firewall"
        New-DirectoryIfMissing $fwLogDir

        $fwLogPath  = "$fwLogDir\pfirewall.log"
        $attackerIp = '103.41.218.91'
        $victimIp   = '192.168.10.100'

        $sb = [System.Text.StringBuilder]::new()
        [void]$sb.AppendLine('#Version: 1.5')
        [void]$sb.AppendLine('#Software: Microsoft Windows Firewall')
        [void]$sb.AppendLine('#Time Format: Local')
        [void]$sb.AppendLine('#Fields: date time action protocol src-ip dst-ip src-port dst-port size tcpflags tcpsyn tcpack tcpwin icmptype icmpcode info path')
        [void]$sb.AppendLine('')

        # 47 DROP entries spread from 23:08:11 to 23:13:55 (344 s window).
        # Entry 48 is the ALLOW (successful brute-force entry) at 23:14:22.
        $baseTime   = [datetime]'2026-04-17 23:08:11'
        $totalDrop  = 47
        $windowSecs = 344

        for ($n = 0; $n -lt $totalDrop; $n++) {
            if ($totalDrop -gt 1) {
                $offsetSecs = [int][math]::Round(($n / ($totalDrop - 1)) * $windowSecs)
            } else {
                $offsetSecs = 0
            }
            $entryTime  = $baseTime.AddSeconds($offsetSecs)
            $srcPort    = 54221 + $n
            $entryLine  = '{0} {1} DROP TCP {2} {3} {4} 3389 48 S 0 0 65535 - - - RECEIVE' -f `
                $entryTime.ToString('yyyy-MM-dd'), $entryTime.ToString('HH:mm:ss'), `
                $attackerIp, $victimIp, $srcPort
            [void]$sb.AppendLine($entryLine)
        }

        $allowTime = [datetime]'2026-04-17 23:14:22'
        $allowLine = '{0} {1} ALLOW TCP {2} {3} 54268 3389 48 S 0 0 65535 - - - RECEIVE' -f `
            $allowTime.ToString('yyyy-MM-dd'), $allowTime.ToString('HH:mm:ss'), `
            $attackerIp, $victimIp
        [void]$sb.AppendLine($allowLine)

        [System.IO.File]::WriteAllText($fwLogPath, $sb.ToString(), [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $fwLogPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] A5 complete: $fwLogPath (47 DROPs + 1 ALLOW from $attackerIp)"
    } catch {
        $msg = "[$role] A5 FAILED (pfirewall.log): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # A6. Apache access.log + MySQL general query log (connection traces)
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] A6: connection traces (access.log + mysql-general.log)"

    # A6a. Apache access.log
    try {
        $apacheLogDir = "$xamppDir\apache\logs"
        New-DirectoryIfMissing $apacheLogDir
        $accessLogPath = Join-Path $apacheLogDir 'access.log'

        $agents = @(
            @{ Ip='192.168.10.11'; User='rahul.s'; Page='dashboard.php' },
            @{ Ip='192.168.10.22'; User='priya.v'; Page='leads.php' },
            @{ Ip='192.168.10.33'; User='amit.p';  Page='calls.php' },
            @{ Ip='192.168.10.44'; User='sneha.i'; Page='transactions.php' },
            @{ Ip='192.168.10.55'; User='vikas.n'; Page='victims.php' }
        )
        $months = @('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec')

        $sb = [System.Text.StringBuilder]::new()
        # ~50 routine entries over the last 14 days (Apr 4 - Apr 16).
        $rng = New-Object System.Random 4172026
        for ($d = 0; $d -lt 14; $d++) {
            $day = (([datetime]'2026-04-04').AddDays($d))
            $perDay = $rng.Next(3, 5)
            for ($e = 0; $e -lt $perDay; $e++) {
                $a  = $agents[$rng.Next(0, $agents.Count)]
                $hh = $rng.Next(9, 19)
                $mm = $rng.Next(0, 60)
                $ss = $rng.Next(0, 60)
                $sz = $rng.Next(3000, 9000)
                $ts = ('{0:00}/{1}/{2}:{3:00}:{4:00}:{5:00} +0530' -f `
                    $day.Day, $months[$day.Month - 1], $day.Year, $hh, $mm, $ss)
                [void]$sb.AppendLine(
                    ('{0} - {1} [{2}] "GET /golden_crm/{3} HTTP/1.1" 200 {4}' -f `
                        $a.Ip, $a.User, $ts, $a.Page, $sz)
                )
            }
        }

        # Real connection evidence entries at the end (Apr 17).
        [void]$sb.AppendLine('192.168.10.11 - rahul.s [17/Apr/2026:09:14:22 +0530] "GET /golden_crm/dashboard.php HTTP/1.1" 200 4521')
        [void]$sb.AppendLine('192.168.10.22 - priya.v [17/Apr/2026:09:31:07 +0530] "GET /golden_crm/leads.php HTTP/1.1" 200 8934')
        [void]$sb.AppendLine('192.168.10.33 - amit.p  [17/Apr/2026:09:45:33 +0530] "GET /golden_crm/calls.php HTTP/1.1" 200 6211')
        [void]$sb.AppendLine('192.168.10.44 - sneha.i [17/Apr/2026:10:02:18 +0530] "GET /golden_crm/transactions.php HTTP/1.1" 200 7843')
        [void]$sb.AppendLine('192.168.10.55 - vikas.n [17/Apr/2026:02:14:09 +0530] "GET /golden_crm/admin/users.php HTTP/1.1" 200 3102')
        [void]$sb.AppendLine('192.168.10.50 - arjun.m [17/Apr/2026:08:47:55 +0530] "GET /golden_crm/victims.php?export=csv HTTP/1.1" 200 94521')

        [System.IO.File]::WriteAllText($accessLogPath, $sb.ToString(), [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $accessLogPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] A6a complete: $accessLogPath"
    } catch {
        $msg = "[$role] A6a FAILED (access.log): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # A6b. MySQL general query log
    try {
        $mysqlDataDir = "$xamppDir\mysql\data"
        New-DirectoryIfMissing $mysqlDataDir
        $genLogPath = Join-Path $mysqlDataDir 'mysql-general.log'

        $sb = [System.Text.StringBuilder]::new()
        [void]$sb.AppendLine('mysqld, Version: 8.2.12 (MySQL Community Server). started with:')
        [void]$sb.AppendLine('Time                 Id Command    Argument')
        [void]$sb.AppendLine("2026-04-17T09:14:22.000000Z   50 Query SELECT * FROM victims WHERE assigned_closer='rahul.s'")
        [void]$sb.AppendLine("2026-04-17T09:31:07.000000Z   51 Query SELECT * FROM leads WHERE status='HOT' LIMIT 500")
        [void]$sb.AppendLine("2026-04-17T09:45:33.000000Z   52 Query SELECT * FROM call_logs WHERE agent_id='amit.p'")
        [void]$sb.AppendLine("2026-04-17T10:02:18.000000Z   53 Query SELECT txn_id,amount,upi_id FROM transactions ORDER BY id DESC")
        [void]$sb.AppendLine("2026-04-17T23:14:09.000000Z   54 Query SELECT COUNT(*) FROM transactions WHERE status='CONFIRMED'")
        [void]$sb.AppendLine("2026-04-17T23:42:11.000000Z   55 Query SELECT * FROM users")
        [void]$sb.AppendLine("2026-04-17T23:47:00.000000Z   56 Query DELETE FROM victims WHERE final_outcome='REFUNDED'")
        [void]$sb.AppendLine("2026-04-17T23:52:34.000000Z   57 Query DROP TABLE IF EXISTS call_logs")

        [System.IO.File]::WriteAllText($genLogPath, $sb.ToString(), [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $genLogPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] A6b complete: $genLogPath"
    } catch {
        $msg = "[$role] A6b FAILED (mysql-general.log): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # A7. Call recording WAV stubs under D:\CRM\uploads\
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] A7: Call recording WAV stubs"
    try {
        $uploadsDir = if (Test-Path 'D:\') { 'D:\CRM\uploads' } else { "$env:SystemDrive\CRM\uploads" }
        New-DirectoryIfMissing $uploadsDir

        $emptyBytes   = [byte[]]@()
        $stubsCreated = 0

        foreach ($log in ($CallLogData | Where-Object { $_.RecordingFilename })) {
            try {
                $wavPath = Join-Path $uploadsDir $log.RecordingFilename
                if (-not (Test-Path $wavPath)) {
                    [System.IO.File]::WriteAllBytes($wavPath, $emptyBytes)
                    Add-HashRecord -FilePath $wavPath -Role $role
                    $stubsCreated++
                }
            } catch {
                Write-SetupLog "[$role] WAV stub WARN (skipping $($log.RecordingFilename)): $($_.Exception.Message)" 'WARN'
            }
        }

        $filesCreated += $stubsCreated
        Write-SetupLog "[$role] A7 complete: $stubsCreated WAV stubs created in $uploadsDir"
    } catch {
        $msg = "[$role] A7 FAILED (WAV stubs): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # A8. SMB shares 'old' (backup) and 'Victims', plus victims_export copy.
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] A8: SMB shares 'old' + 'Victims'"

    # A8a. Share the backup dir as 'old' (Everyone:FULL for training realism).
    try {
        New-DirectoryIfMissing $backupDir
        & cmd /c "net share old /delete" 2>&1 | Out-Null
        $shareResult = & cmd /c "net share old=`"$backupDir`" /REMARK:`"Backup archive`" /GRANT:Everyone,FULL" 2>&1
        Write-SetupLog "[$role] SMB share 'old' result: $shareResult"
        Write-SetupLog "[$role] A8a complete: SMB share 'old' -> $backupDir"
    } catch {
        $msg = "[$role] A8a WARN -- SMB share 'old' failed: $($_.Exception.Message)"
        Write-SetupLog $msg 'WARN'
        $errors.Add($msg)
    }

    # A8b. Share the Victims dir (read-only) and copy victims_export.csv into it.
    try {
        $victimsDir = if (Test-Path 'D:\') { 'D:\Victims' } else { "$env:SystemDrive\Victims" }
        New-DirectoryIfMissing $victimsDir

        # Copy victims_master.xlsx if present on the manager drive.
        $vmSource = if (Test-Path 'D:\Manager\victims_master.xlsx') {
            'D:\Manager\victims_master.xlsx'
        } else {
            "$env:SystemDrive\Manager\victims_master.xlsx"
        }
        if (Test-Path $vmSource) {
            Copy-Item $vmSource $victimsDir -Force
            $copiedXlsx = Join-Path $victimsDir 'victims_master.xlsx'
            Add-HashRecord -FilePath $copiedXlsx -Role $role
            $filesCreated++
            Write-SetupLog "[$role] Copied victims_master.xlsx to $victimsDir"
        } else {
            Write-SetupLog "[$role] victims_master.xlsx not found at $vmSource -- skipping copy" 'WARN'
        }

        # Copy the victims_export.csv evidence file into the Victims share.
        $vmExportSrc = Join-Path $backupDir 'victims_export.csv'
        if (Test-Path $vmExportSrc) {
            Copy-Item $vmExportSrc $victimsDir -Force
            Write-SetupLog "[$role] Copied victims_export.csv to $victimsDir"
        }

        & cmd /c "net share Victims /delete" 2>&1 | Out-Null
        $shareResult2 = & cmd /c "net share Victims=`"$victimsDir`" /REMARK:`"Victim data`" /GRANT:Everyone,READ" 2>&1
        Write-SetupLog "[$role] SMB share 'Victims' result: $shareResult2"
        Write-SetupLog "[$role] A8b complete: SMB share 'Victims' -> $victimsDir"
    } catch {
        $msg = "[$role] A8b WARN -- Victims share failed: $($_.Exception.Message)"
        Write-SetupLog $msg 'WARN'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # A9. Firewall rules + disable SMB signing (training realism).
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] A9: firewall rules + SMB-signing registry"

    # A9a. Firewall rules for all lab service ports.
    try {
        $fwRules = @(
            @{ Name='GR-Lab-HTTP';  Port=80   },
            @{ Name='GR-Lab-HTTPS'; Port=443  },
            @{ Name='GR-Lab-RDP';   Port=3389 },
            @{ Name='GR-Lab-SMB';   Port=445  },
            @{ Name='GR-Lab-MySQL'; Port=3306 }
        )
        foreach ($rule in $fwRules) {
            & netsh advfirewall firewall add rule `
                "name=$($rule.Name)" protocol=TCP dir=in `
                "localport=$($rule.Port)" action=allow profile=any 2>&1 | Out-Null
            Write-SetupLog "[$role] Firewall rule added: $($rule.Name) -> TCP $($rule.Port)"
        }
        Write-SetupLog "[$role] A9a complete: firewall rules"
    } catch {
        $msg = "[$role] A9a WARN -- firewall rules failed: $($_.Exception.Message)"
        Write-SetupLog $msg 'WARN'
        $errors.Add($msg)
    }

    # A9b. Disable SMB signing.
    try {
        $smbRegPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
        Set-ItemProperty -Path $smbRegPath -Name 'RequireSecuritySignature' -Value 0
        Set-ItemProperty -Path $smbRegPath -Name 'EnableSecuritySignature'  -Value 0
        Write-SetupLog "[$role] A9b complete: SMB signing disabled"
    } catch {
        $msg = "[$role] A9b WARN -- SMB signing registry update failed: $($_.Exception.Message)"
        Write-SetupLog $msg 'WARN'
        $errors.Add($msg)
    }

    Write-SetupLog "[$role] ===== PHASE A complete: $filesCreated file artefacts written ====="

    # ##################################################################
    # PHASE B -- MySQL (best-effort, 3 tiers, non-fatal if all fail)
    # ##################################################################
    Write-SetupLog "[$role] ===== PHASE B: MySQL best-effort (non-fatal) ====="

    # ------------------------------------------------------------------
    # B1. Optionally install XAMPP (only if not already present).
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] B1: XAMPP presence check / install"
    try {
        if (Test-Path "$xamppDir\mysql\bin\mysqld.exe") {
            Write-SetupLog "[$role] XAMPP already present at $xamppDir -- skipping download"
        } else {
            $xamppInstaller = "$env:TEMP\xampp-installer.exe"
            # Try ApacheFriends direct URL first, SourceForge as fallback
            $xamppUrls = @(
                'https://www.apachefriends.org/xampp-files/8.2.12/xampp-windows-x64-8.2.12-0-VS16-installer.exe',
                'https://sourceforge.net/projects/xampp/files/XAMPP%20Windows/8.2.12/xampp-windows-x64-8.2.12-0-VS16-installer.exe/download',
                'https://github.com/nicktacular/xampp-installer-helper/releases/download/v8.2.12/xampp-windows-x64-8.2.12-installer.exe'
            )
            $downloaded = $false
            foreach ($xamppUrl in $xamppUrls) {
                try {
                    Write-SetupLog "[$role] Trying: $xamppUrl"
                    Invoke-WebRequest -Uri $xamppUrl -OutFile $xamppInstaller -UseBasicParsing -TimeoutSec 300
                    if ((Test-Path $xamppInstaller) -and (Get-Item $xamppInstaller).Length -gt 10MB) {
                        $downloaded = $true
                        break
                    }
                } catch {
                    Write-SetupLog "[$role] URL failed: $($_.Exception.Message)" 'WARN'
                }
            }
            if (-not $downloaded) { throw "All XAMPP download URLs failed" }

            Write-SetupLog "[$role] Downloading XAMPP 8.2.12 (~170 MB)..."
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $oldProgress = $ProgressPreference
            $ProgressPreference = 'SilentlyContinue'
            try {
                Invoke-WebRequest -Uri $xamppUrl -OutFile $xamppInstaller -UseBasicParsing -TimeoutSec 600
            } finally {
                $ProgressPreference = $oldProgress
            }

            Write-SetupLog "[$role] Installing XAMPP silently..."
            $proc = Start-Process -FilePath $xamppInstaller `
                -ArgumentList '--mode unattended --disable-components xampp_perl,xampp_phpmyadmin,xampp_filezilla,xampp_mercury,xampp_tomcat' `
                -Wait -PassThru
            if ($proc.ExitCode -ne 0) {
                throw "XAMPP installer exited with code $($proc.ExitCode)"
            }
            Write-SetupLog "[$role] XAMPP installed"
        }
    } catch {
        $msg = "[$role] B1 WARN -- XAMPP install failed (non-fatal): $($_.Exception.Message)"
        Write-SetupLog $msg 'WARN'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # B2. Start MySQL (3-tier) and import the already-written dump file.
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] B2: start MySQL (3-tier) + import dump"
    $mysqlAvailable = $false
    try {
        $resolvedMysql = Start-LabMySQL -XamppDir $xamppDir
        if ($resolvedMysql) {
            $mysql = $resolvedMysql
            $mysqlAvailable = $true
            Write-SetupLog "[$role] MySQL available -- using $mysql"
        } else {
            $msg = "[$role] B2 WARN -- MySQL could not be started (all tiers failed); Phase A artefacts already present"
            Write-SetupLog $msg 'WARN'
            $errors.Add($msg)
        }
    } catch {
        $msg = "[$role] B2 WARN -- MySQL start failed (non-fatal): $($_.Exception.Message)"
        Write-SetupLog $msg 'WARN'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # B3. Import the dump file we already wrote in Phase A (A2).
    # ------------------------------------------------------------------
    if ($mysqlAvailable -and (Test-Path $sqlDumpFile)) {
        Write-SetupLog "[$role] B3: importing $sqlDumpFile into MySQL"
        try {
            # Preferred path: pipe the dump file through cmd to mysql stdin.
            $importCmd = "cmd /c `"`"$mysql`" -u root < `"$sqlDumpFile`"`" 2>&1"
            $result = Invoke-Expression $importCmd
            if ($LASTEXITCODE -ne 0) {
                throw "cmd import returned exit $LASTEXITCODE : $result"
            }
            Write-SetupLog "[$role] B3 complete: dump imported via cmd redirect"
        } catch {
            Write-SetupLog "[$role] B3 cmd-redirect import failed: $($_.Exception.Message) -- retrying via Invoke-MySql" 'WARN'
            try {
                $sqlContent = Get-Content $sqlDumpFile -Raw
                Invoke-MySql -Sql $sqlContent -MysqlExe $mysql
                Write-SetupLog "[$role] B3 complete: dump imported via Invoke-MySql"
            } catch {
                $msg = "[$role] B3 WARN -- dump import failed (non-fatal): $($_.Exception.Message)"
                Write-SetupLog $msg 'WARN'
                $errors.Add($msg)
            }
        }
    } else {
        Write-SetupLog "[$role] B3 SKIP -- MySQL unavailable; trainees use the SQL dump + CSV exports in $backupDir" 'WARN'
    }

    Write-SetupLog "[$role] ===== PHASE B complete (mysqlAvailable=$mysqlAvailable) ====="

    # ##################################################################
    # Final status
    # ##################################################################
    $status = if ($errors.Count -eq 0) { 'DONE' }
              elseif ($filesCreated -gt 0) { 'DONE_WITH_CONCERNS' }
              else { 'BLOCKED' }

    Write-SetupLog "[$role] Invoke-RoleSetup finished -- FilesCreated=$filesCreated Errors=$($errors.Count) Status=$status"

    return @{
        Role         = $role
        FilesCreated = $filesCreated
        Errors       = $errors
        Status       = $status
    }
}
