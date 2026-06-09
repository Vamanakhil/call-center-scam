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
# Helper: probe whether a MySQL instance is responding to ping.
# ---------------------------------------------------------------------------
function Test-MySqlAlive {
    param([string]$MysqladminExe)
    try {
        $r = & $MysqladminExe -u root --connect-timeout=3 ping 2>&1
        return ($r -match 'alive')
    } catch { return $false }
}

# ---------------------------------------------------------------------------
# Helper: bring up MySQL using a 3-tier strategy.
#   Tier 0 : already alive (existing service or PATH instance) -> reuse
#   Tier 1 : XAMPP MySQL as a Windows service (with data-dir init)
#   Tier 2 : standalone mysqld.exe process (no service)
#   Tier 3 : file-only fallback (returns $null)
# Returns the path to mysql.exe if MySQL is available, $null otherwise.
# ---------------------------------------------------------------------------
function Start-LabMySQL {
    param([string]$XamppDir)

    $mysql      = "$XamppDir\mysql\bin\mysql.exe"
    $mysqladmin = "$XamppDir\mysql\bin\mysqladmin.exe"
    $mysqld     = "$XamppDir\mysql\bin\mysqld.exe"
    $myIni      = "$XamppDir\mysql\bin\my.ini"
    $dataDir    = "$XamppDir\mysql\data"
    $svcName    = 'GR_MySQL_Lab'

    # --- Tier 0: Is MySQL already alive? ---
    Write-SetupLog "[CRM-SERVER] MySQL Tier 0: checking if MySQL already responding..."
    if (Test-Path $mysqladmin) {
        if (Test-MySqlAlive -MysqladminExe $mysqladmin) {
            Write-SetupLog "[CRM-SERVER] MySQL already alive -- using existing instance"
            return $mysql
        }
    }
    # Also check if any mysql.exe is in PATH (PowerShell 5.1 compatible -- no null-conditional).
    $mysqlCmd = Get-Command 'mysql.exe' -ErrorAction SilentlyContinue
    $mysqlInPath = if ($mysqlCmd) { $mysqlCmd.Source } else { $null }
    if ($mysqlInPath) {
        $adminInPath = Join-Path (Split-Path $mysqlInPath) 'mysqladmin.exe'
        if ((Test-Path $adminInPath) -and (Test-MySqlAlive -MysqladminExe $adminInPath)) {
            Write-SetupLog "[CRM-SERVER] MySQL found in PATH and alive: $mysqlInPath"
            return $mysqlInPath
        }
    }

    # --- Tier 1: XAMPP MySQL ---
    Write-SetupLog "[CRM-SERVER] MySQL Tier 1: XAMPP MySQL at $XamppDir..."
    if (-not (Test-Path $mysql)) {
        Write-SetupLog "[CRM-SERVER] XAMPP mysql.exe not found -- skipping Tier 1" 'WARN'
    } else {
        try {
            # Stop + unregister any old conflicting service to avoid port conflicts.
            @('GR_MySQL_Lab', 'MySQLForTraining', 'mysql', 'MySQL80', 'MySQL57') | ForEach-Object {
                $svc = Get-Service -Name $_ -ErrorAction SilentlyContinue
                if ($svc) {
                    if ($svc.Status -eq 'Running') {
                        Stop-Service -Name $_ -Force -ErrorAction SilentlyContinue
                        Start-Sleep -Seconds 2
                    }
                    & $mysqld '--remove' $_ 2>$null | Out-Null
                    Start-Sleep -Seconds 1
                }
            }

            # Initialize data directory if this is a fresh install.
            if (-not (Test-Path "$dataDir\ibdata1")) {
                Write-SetupLog "[CRM-SERVER] Initializing MySQL data directory..."
                $initArgs = @('--initialize-insecure', "--datadir=$dataDir")
                if (Test-Path $myIni) { $initArgs += "--defaults-file=$myIni" }
                $initProc = Start-Process -FilePath $mysqld -ArgumentList $initArgs -Wait -PassThru -NoNewWindow -ErrorAction Stop
                if ($initProc.ExitCode -ne 0) { throw "mysqld --initialize-insecure failed (exit $($initProc.ExitCode))" }
                Start-Sleep -Seconds 2
                Write-SetupLog "[CRM-SERVER] Data directory initialized"
            }

            # Register as Windows service.
            Write-SetupLog "[CRM-SERVER] Installing MySQL service '$svcName'..."
            $installArgs = @('--install', $svcName)
            if (Test-Path $myIni) { $installArgs += "--defaults-file=$myIni" }
            & $mysqld @installArgs 2>$null | Out-Null
            Start-Sleep -Seconds 2

            # Start the service.
            Write-SetupLog "[CRM-SERVER] Starting service '$svcName'..."
            Start-Service -Name $svcName -ErrorAction Stop

            # Wait up to 60s for MySQL to respond.
            Write-SetupLog "[CRM-SERVER] Waiting for MySQL to accept connections (up to 60s)..."
            $alive = $false
            for ($i = 0; $i -lt 60; $i++) {
                if (Test-MySqlAlive -MysqladminExe $mysqladmin) {
                    $alive = $true
                    break
                }
                Start-Sleep -Seconds 1
            }
            if ($alive) {
                Write-SetupLog "[CRM-SERVER] MySQL Tier 1 alive -- XAMPP service running"
                return $mysql
            } else {
                throw "MySQL service started but did not respond within 60 seconds"
            }
        } catch {
            Write-SetupLog "[CRM-SERVER] Tier 1 failed: $($_.Exception.Message) -- trying Tier 2" 'WARN'
        }
    }

    # --- Tier 2: Direct mysqld.exe (no service, standalone process) ---
    Write-SetupLog "[CRM-SERVER] MySQL Tier 2: launching mysqld.exe standalone..."
    if (Test-Path $mysqld) {
        try {
            # Kill any leftover mysqld processes.
            Get-Process -Name 'mysqld' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2

            # Initialize if needed.
            if (-not (Test-Path "$dataDir\ibdata1")) {
                $initArgs = @('--initialize-insecure', "--datadir=$dataDir")
                $initProc = Start-Process -FilePath $mysqld -ArgumentList $initArgs -Wait -PassThru -NoNewWindow
                Start-Sleep -Seconds 3
            }

            # Launch standalone (background).
            $standArgs = @("--datadir=$dataDir", '--skip-networking=0', '--port=3306', '--skip-grant-tables')
            if (Test-Path $myIni) { $standArgs = @("--defaults-file=$myIni") + $standArgs }
            Start-Process -FilePath $mysqld -ArgumentList $standArgs -NoNewWindow -PassThru | Out-Null

            # Wait up to 30s.
            $alive = $false
            for ($i = 0; $i -lt 30; $i++) {
                Start-Sleep -Seconds 1
                if (Test-MySqlAlive -MysqladminExe $mysqladmin) { $alive = $true; break }
            }
            if ($alive) {
                Write-SetupLog "[CRM-SERVER] MySQL Tier 2 alive -- standalone process running"
                return $mysql
            } else {
                throw "Standalone mysqld did not respond within 30 seconds"
            }
        } catch {
            Write-SetupLog "[CRM-SERVER] Tier 2 failed: $($_.Exception.Message) -- falling back to file-only mode" 'WARN'
        }
    }

    # --- Tier 3: File-only fallback ---
    Write-SetupLog "[CRM-SERVER] All MySQL tiers failed -- running in file-only mode. SQL will be saved to $env:SystemDrive\GR_LabSetup\golden_crm_inserts.sql" 'WARN'
    return $null
}

# ---------------------------------------------------------------------------
# Main role function
# ---------------------------------------------------------------------------
function Invoke-RoleSetup {
    <#
        Creates all CRM-SERVER evidence artefacts.
        Returns @{ Role='CRM-SERVER'; FilesCreated=N; Errors=@() }
    #>

    $role         = 'CRM-SERVER'
    $filesCreated = 0
    $errors       = [System.Collections.Generic.List[string]]::new()

    $xamppDir     = "$env:SystemDrive\xampp"
    $mysql        = "$xamppDir\mysql\bin\mysql.exe"
    $mysqladmin   = "$xamppDir\mysql\bin\mysqladmin.exe"
    $mysqldump    = "$xamppDir\mysql\bin\mysqldump.exe"

    # Track whether MySQL is actually available for population steps.
    # When MySQL is brought up, $mysql is updated to the path returned by
    # Start-LabMySQL (which may differ from the XAMPP path if a PATH instance
    # was reused).
    $mysqlAvailable = $false

    # Fallback SQL dump path for graceful degradation.
    $fallbackSqlDir  = "$env:SystemDrive\GR_LabSetup"
    $fallbackSqlFile = "$fallbackSqlDir\golden_crm_inserts.sql"

    Write-SetupLog "[$role] Invoke-RoleSetup starting"

    # ==================================================================
    # Step 1: Download and install XAMPP 8.2.12, then bring up MySQL
    # ==================================================================
    Write-SetupLog "[$role] Step 1: XAMPP download and install"
    $xamppInstalled = $false
    try {
        if (Test-Path "$xamppDir\mysql\bin\mysql.exe") {
            Write-SetupLog "[$role] XAMPP already installed at $xamppDir -- skipping download"
            $xamppInstalled = $true
        } else {
            $xamppInstaller = "$env:TEMP\xampp-installer.exe"
            $xamppUrl = 'https://sourceforge.net/projects/xampp/files/XAMPP%20Windows/8.2.12/xampp-windows-x64-8.2.12-0-VS16-installer.exe/download'

            Write-SetupLog "[$role] Downloading XAMPP 8.2.12 (~170 MB)... this will take a few minutes"
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

            $oldProgress    = $ProgressPreference
            $ProgressPreference = 'SilentlyContinue'
            try {
                Invoke-WebRequest -Uri $xamppUrl -OutFile $xamppInstaller -UseBasicParsing -TimeoutSec 600
            } finally {
                $ProgressPreference = $oldProgress
            }

            Write-SetupLog "[$role] Installing XAMPP silently..."
            $proc = Start-Process -FilePath $xamppInstaller `
                -ArgumentList '--mode unattended --disable-components xampp_php,xampp_perl,xampp_phpmyadmin,xampp_filezilla,xampp_mercury,xampp_tomcat' `
                -Wait -PassThru
            if ($proc.ExitCode -ne 0) {
                throw "XAMPP installer exited with code $($proc.ExitCode)"
            }
            $xamppInstalled = $true
            Write-SetupLog "[$role] XAMPP installed successfully"
        }
    } catch {
        $msg = "[$role] Step 1 WARN -- XAMPP download/install failed: $($_.Exception.Message) -- will create file artefacts only"
        Write-SetupLog $msg 'WARN'
        $errors.Add($msg)
        $xamppInstalled = $false
    }

    # VC++ 2019 redistributable check -- XAMPP MySQL/PHP depend on it.
    try {
        $vcRedistKey = 'HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64'
        if (-not (Test-Path $vcRedistKey)) {
            $msg = "[$role] Step 1 WARN -- VC++ 2019 x64 redistributable not detected ($vcRedistKey missing). MySQL/PHP may fail to start; install vc_redist.x64.exe if so."
            Write-SetupLog $msg 'WARN'
            $errors.Add($msg)
        } else {
            Write-SetupLog "[$role] VC++ 2019 x64 redistributable present"
        }
    } catch {
        Write-SetupLog "[$role] Step 1 WARN -- VC++ redist check failed: $($_.Exception.Message)" 'WARN'
    }

    # ==================================================================
    # Step 2: Start MySQL (3-tier strategy via Start-LabMySQL)
    # ==================================================================
    Write-SetupLog "[$role] Step 2: Start MySQL"
    try {
        $resolvedMysql = Start-LabMySQL -XamppDir $xamppDir
        if ($resolvedMysql) {
            $mysql = $resolvedMysql
            # Resolve the matching mysqladmin/mysqldump next to the chosen mysql.exe.
            $binDir = Split-Path $mysql
            $candidateAdmin = Join-Path $binDir 'mysqladmin.exe'
            $candidateDump  = Join-Path $binDir 'mysqldump.exe'
            if (Test-Path $candidateAdmin) { $mysqladmin = $candidateAdmin }
            if (Test-Path $candidateDump)  { $mysqldump  = $candidateDump }
            $mysqlAvailable = $true
            Write-SetupLog "[$role] MySQL available -- using $mysql"
        } else {
            $msg = "[$role] Step 2 WARN -- MySQL could not be started (all tiers failed); file-only mode"
            Write-SetupLog $msg 'WARN'
            $errors.Add($msg)
        }
    } catch {
        $msg = "[$role] Step 2 WARN -- MySQL start failed: $($_.Exception.Message)"
        Write-SetupLog $msg 'WARN'
        $errors.Add($msg)
    }

    # ==================================================================
    # Step 3: Create golden_crm database and tables
    # ==================================================================
    Write-SetupLog "[$role] Step 3: Create golden_crm database and tables"

    $schemaSql = @'
CREATE DATABASE IF NOT EXISTS golden_crm CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE golden_crm;

CREATE TABLE IF NOT EXISTS victims (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    victim_id        VARCHAR(20) UNIQUE NOT NULL,
    name             VARCHAR(100),
    phone            VARCHAR(20),
    email            VARCHAR(100),
    city             VARCHAR(50),
    amount_paid      DECIMAL(12,2),
    initial_deposit  DECIMAL(12,2),
    final_outcome    ENUM('BURNED','ACTIVE','REFUNDED') DEFAULT 'ACTIVE',
    assigned_closer  VARCHAR(50),
    date_added       DATE,
    status           ENUM('ACTIVE','CLOSED') DEFAULT 'ACTIVE',
    notes            TEXT
);

CREATE TABLE IF NOT EXISTS leads (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    lead_id        INT UNIQUE,
    name           VARCHAR(100),
    phone          VARCHAR(20),
    email          VARCHAR(100),
    source         ENUM('LinkedIn','Facebook','Instagram','Purchased_List','Referral'),
    heat_score     INT,
    status         ENUM('HOT','WARM','COLD','ASSIGNED','DNC'),
    assigned_agent VARCHAR(50),
    date_added     DATE
);

CREATE TABLE IF NOT EXISTS transactions (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    txn_id           INT UNIQUE,
    victim_id        VARCHAR(20),
    amount           DECIMAL(12,2),
    upi_id           VARCHAR(100),
    beneficiary_acct VARCHAR(50),
    txn_date         DATE,
    status           ENUM('CONFIRMED','PENDING','FAILED'),
    notes            TEXT
);

CREATE TABLE IF NOT EXISTS call_logs (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    log_id              INT UNIQUE,
    agent_id            VARCHAR(50),
    victim_id           VARCHAR(20),
    duration_seconds    INT,
    recording_filename  VARCHAR(200),
    call_date           DATE,
    call_type           ENUM('OUTBOUND','INBOUND'),
    outcome             ENUM('CONVERTED','FOLLOW_UP','NOT_INTERESTED','INVALID')
);

CREATE TABLE IF NOT EXISTS users (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(50) UNIQUE,
    password_hash VARCHAR(255),
    role          ENUM('admin','agent','readonly'),
    created_at    DATETIME DEFAULT NOW()
);
'@

    if ($mysqlAvailable) {
        try {
            Invoke-MySql -Sql $schemaSql -MysqlExe $mysql
            Write-SetupLog "[$role] golden_crm schema created"
        } catch {
            $msg = "[$role] Step 3 WARN -- schema creation failed: $($_.Exception.Message)"
            Write-SetupLog $msg 'WARN'
            $errors.Add($msg)
            $mysqlAvailable = $false
        }
    } else {
        Write-SetupLog "[$role] Step 3 SKIP -- MySQL not available; schema will be written to fallback file" 'WARN'
    }

    # ==================================================================
    # Step 4: Populate tables (or save fallback SQL)
    # ==================================================================
    Write-SetupLog "[$role] Step 4: Populate tables"

    # We always build the SQL batches; if MySQL is live we execute them via the
    # new stdin-pipe Invoke-MySql, otherwise we accumulate them into
    # $fallbackSqlLines for the graceful-degradation file.
    $fallbackSqlLines = [System.Collections.Generic.List[string]]::new()
    if (-not $mysqlAvailable) {
        # Include schema in fallback so it is self-contained.
        $fallbackSqlLines.Add($schemaSql)
        $fallbackSqlLines.Add('')
    }

    # ------------------------------------------------------------------
    # 4a. Victims (487 rows, batches of 100)
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] Step 4a: victims (487 rows)"
    try {
        $batchSize  = 100
        $batchStart = 0
        $allVictims = @($VictimData)

        while ($batchStart -lt $allVictims.Count) {
            $batchEnd = [math]::Min($batchStart + $batchSize, $allVictims.Count)
            $rows     = [System.Collections.Generic.List[string]]::new()

            for ($i = $batchStart; $i -lt $batchEnd; $i++) {
                $v       = $allVictims[$i]
                $name    = $v.Name    -replace "'", "''"
                $phone   = $v.Phone   -replace "'", "''"
                $email   = $v.Email   -replace "'", "''"
                $city    = $v.City    -replace "'", "''"
                $notes   = $v.Notes   -replace "'", "''"
                $rows.Add(
                    "('$($v.VictimId)','$name','$phone','$email','$city'," +
                    "$($v.AmountPaid),$($v.InitialDeposit)," +
                    "'$($v.FinalOutcome)','$($v.AssignedCloser)'," +
                    "'$($v.DateAdded)','$($v.Status)','$notes')"
                )
            }

            $batchSql  = "INSERT INTO victims (victim_id,name,phone,email,city,amount_paid,initial_deposit,final_outcome,assigned_closer,date_added,status,notes) VALUES`n"
            $batchSql += ($rows -join ",`n") + ";"

            if ($mysqlAvailable) {
                Invoke-MySql -Sql $batchSql -Database 'golden_crm' -MysqlExe $mysql
            } else {
                $fallbackSqlLines.Add($batchSql)
                $fallbackSqlLines.Add('')
            }

            $batchStart = $batchEnd
        }
        Write-SetupLog "[$role] Step 4a: victims inserted"
    } catch {
        $msg = "[$role] Step 4a WARN -- victims insert failed: $($_.Exception.Message)"
        Write-SetupLog $msg 'WARN'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # 4b. Leads (12,000 rows, batches of 500)
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] Step 4b: leads (12,000 rows)"
    try {
        $batchSize  = 500
        $batchStart = 0
        $allLeads   = @($LeadData)

        while ($batchStart -lt $allLeads.Count) {
            $batchEnd = [math]::Min($batchStart + $batchSize, $allLeads.Count)
            $rows     = [System.Collections.Generic.List[string]]::new()

            for ($i = $batchStart; $i -lt $batchEnd; $i++) {
                $l     = $allLeads[$i]
                $name  = $l.Name          -replace "'", "''"
                $phone = $l.Phone         -replace "'", "''"
                $email = $l.Email         -replace "'", "''"
                $agent = $l.AssignedAgent -replace "'", "''"
                $rows.Add(
                    "($($l.LeadId),'$name','$phone','$email'," +
                    "'$($l.Source)',$($l.HeatScore),'$($l.Status)'," +
                    "'$agent','$($l.DateAdded)')"
                )
            }

            $batchSql  = "INSERT INTO leads (lead_id,name,phone,email,source,heat_score,status,assigned_agent,date_added) VALUES`n"
            $batchSql += ($rows -join ",`n") + ";"

            if ($mysqlAvailable) {
                Invoke-MySql -Sql $batchSql -Database 'golden_crm' -MysqlExe $mysql
            } else {
                $fallbackSqlLines.Add($batchSql)
                $fallbackSqlLines.Add('')
            }

            $batchStart = $batchEnd
        }
        Write-SetupLog "[$role] Step 4b: leads inserted"
    } catch {
        $msg = "[$role] Step 4b WARN -- leads insert failed: $($_.Exception.Message)"
        Write-SetupLog $msg 'WARN'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # 4c. Transactions (2,314 rows, batches of 100)
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] Step 4c: transactions (2,314 rows)"
    try {
        $batchSize   = 100
        $batchStart  = 0
        $allTxns     = @($TransactionData)

        while ($batchStart -lt $allTxns.Count) {
            $batchEnd = [math]::Min($batchStart + $batchSize, $allTxns.Count)
            $rows     = [System.Collections.Generic.List[string]]::new()

            for ($i = $batchStart; $i -lt $batchEnd; $i++) {
                $t     = $allTxns[$i]
                $upi   = $t.UpiId           -replace "'", "''"
                $acct  = $t.BeneficiaryAcct -replace "'", "''"
                $notes = $t.Notes           -replace "'", "''"
                $rows.Add(
                    "($($t.TxnId),'$($t.VictimId)',$($t.Amount)," +
                    "'$upi','$acct','$($t.TxnDate)'," +
                    "'$($t.Status)','$notes')"
                )
            }

            $batchSql  = "INSERT INTO transactions (txn_id,victim_id,amount,upi_id,beneficiary_acct,txn_date,status,notes) VALUES`n"
            $batchSql += ($rows -join ",`n") + ";"

            if ($mysqlAvailable) {
                Invoke-MySql -Sql $batchSql -Database 'golden_crm' -MysqlExe $mysql
            } else {
                $fallbackSqlLines.Add($batchSql)
                $fallbackSqlLines.Add('')
            }

            $batchStart = $batchEnd
        }
        Write-SetupLog "[$role] Step 4c: transactions inserted"
    } catch {
        $msg = "[$role] Step 4c WARN -- transactions insert failed: $($_.Exception.Message)"
        Write-SetupLog $msg 'WARN'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # 4d. Call logs (891 rows, batches of 100)
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] Step 4d: call_logs (891 rows)"
    try {
        $batchSize   = 100
        $batchStart  = 0
        $allLogs     = @($CallLogData)

        while ($batchStart -lt $allLogs.Count) {
            $batchEnd = [math]::Min($batchStart + $batchSize, $allLogs.Count)
            $rows     = [System.Collections.Generic.List[string]]::new()

            for ($i = $batchStart; $i -lt $batchEnd; $i++) {
                $c    = $allLogs[$i]
                $agent = $c.AgentId           -replace "'", "''"
                $recf  = $c.RecordingFilename -replace "'", "''"
                $rows.Add(
                    "($($c.LogId),'$agent','$($c.VictimId)'," +
                    "$($c.DurationSeconds),'$recf'," +
                    "'$($c.CallDate)','$($c.CallType)','$($c.Outcome)')"
                )
            }

            $batchSql  = "INSERT INTO call_logs (log_id,agent_id,victim_id,duration_seconds,recording_filename,call_date,call_type,outcome) VALUES`n"
            $batchSql += ($rows -join ",`n") + ";"

            if ($mysqlAvailable) {
                Invoke-MySql -Sql $batchSql -Database 'golden_crm' -MysqlExe $mysql
            } else {
                $fallbackSqlLines.Add($batchSql)
                $fallbackSqlLines.Add('')
            }

            $batchStart = $batchEnd
        }
        Write-SetupLog "[$role] Step 4d: call_logs inserted"
    } catch {
        $msg = "[$role] Step 4d WARN -- call_logs insert failed: $($_.Exception.Message)"
        Write-SetupLog $msg 'WARN'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # 4e. Users
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] Step 4e: users"
    $usersSql = @"
INSERT INTO users (username, password_hash, role) VALUES
('admin',    SHA2('Gr@Crm2026!',     256), 'admin'),
('crm_app',  SHA2('Gr@Crm2026!',     256), 'admin'),
('rahul.s',  SHA2('Gr@2026Agent01',  256), 'agent'),
('priya.v',  SHA2('Gr@2026Agent02',  256), 'agent'),
('amit.p',   SHA2('Gr@2026Agent03',  256), 'agent'),
('sneha.i',  SHA2('Gr@2026Agent04',  256), 'agent'),
('vikas.n',  SHA2('Gr@2026Agent05',  256), 'admin');
"@
    try {
        if ($mysqlAvailable) {
            Invoke-MySql -Sql $usersSql -Database 'golden_crm' -MysqlExe $mysql
            Write-SetupLog "[$role] Step 4e: users inserted"
        } else {
            $fallbackSqlLines.Add($usersSql)
            $fallbackSqlLines.Add('')
        }
    } catch {
        $msg = "[$role] Step 4e WARN -- users insert failed: $($_.Exception.Message)"
        Write-SetupLog $msg 'WARN'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # Graceful-degradation: write fallback SQL file if MySQL was not used.
    # ------------------------------------------------------------------
    if (-not $mysqlAvailable) {
        try {
            New-DirectoryIfMissing $fallbackSqlDir
            $fallbackSqlLines | Set-Content -Path $fallbackSqlFile -Encoding UTF8
            Add-HashRecord -FilePath $fallbackSqlFile -Role $role
            $filesCreated++
            Write-SetupLog "[$role] MySQL population skipped -- inserts saved to $fallbackSqlFile" 'WARN'
        } catch {
            $msg = "[$role] Fallback SQL write FAILED: $($_.Exception.Message)"
            Write-SetupLog $msg 'ERROR'
            $errors.Add($msg)
        }
    }

    # ==================================================================
    # Step 5: mysqldump backup ("the hidden backup")
    # ==================================================================
    Write-SetupLog "[$role] Step 5: mysqldump backup"
    try {
        $backupDir = if (Test-Path 'D:\') { 'D:\Backups\old' } else { "$env:SystemDrive\CRM_Backups\old" }
        New-DirectoryIfMissing $backupDir

        $backupFile = Join-Path $backupDir 'golden_crm_backup_2026-04-15.sql'

        if ($mysqlAvailable -and (Test-Path $mysqldump)) {
            & $mysqldump -u root golden_crm | Set-Content -Path $backupFile -Encoding UTF8
            Write-SetupLog "[$role] Created mysqldump backup: $backupFile"
        } else {
            # Write a stub backup file so the artefact still exists.
            $stubContent = @"
-- Golden Returns CRM database backup
-- Generated: 2026-04-15 02:00:01
-- Host: CRM-SERVER  Database: golden_crm
-- XAMPP MySQL 8.2.12
-- NOTE: This is a stub backup. MySQL was not available during lab setup.
--       Import $fallbackSqlFile to recreate full data.

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!50503 SET NAMES utf8mb4 */;

USE `golden_crm`;
"@
            $stubContent | Set-Content -Path $backupFile -Encoding UTF8
            Write-SetupLog "[$role] Created stub backup file (MySQL unavailable): $backupFile" 'WARN'
        }

        Add-HashRecord -FilePath $backupFile -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Step 5 complete: $backupFile"
    } catch {
        $msg = "[$role] Step 5 FAILED (mysqldump backup): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # Step 6: SMB share "old" for the backup directory
    # ==================================================================
    Write-SetupLog "[$role] Step 6: SMB share 'old'"
    try {
        $backupDir = if (Test-Path 'D:\') { 'D:\Backups\old' } else { "$env:SystemDrive\CRM_Backups\old" }
        New-DirectoryIfMissing $backupDir

        $shareName = 'old'
        $shareDesc = 'Backup archive'

        # Remove existing share if present (ignore errors if it doesn't exist).
        & net share $shareName /delete 2>$null | Out-Null

        # Create the share with Everyone:FULL for training realism.
        $result = & net share "${shareName}=${backupDir}" "/REMARK:$shareDesc" '/GRANT:Everyone,FULL' 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "net share returned exit $LASTEXITCODE : $result"
        }
        Write-SetupLog "[$role] Step 6 complete: SMB share '$shareName' -> $backupDir"
    } catch {
        $msg = "[$role] Step 6 WARN -- SMB share 'old' failed: $($_.Exception.Message)"
        Write-SetupLog $msg 'WARN'
        $errors.Add($msg)
    }

    # ==================================================================
    # Step 7: CRM web application files under C:\xampp\htdocs\golden_crm\
    # ==================================================================
    Write-SetupLog "[$role] Step 7: CRM web application files"

    $htdocsDir = "$xamppDir\htdocs\golden_crm"
    New-DirectoryIfMissing $htdocsDir

    # ------------------------------------------------------------------
    # 7a. index.php -- CRM login page
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] Step 7a: index.php"
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
        $msg = "[$role] Step 7a FAILED (index.php): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # 7b. dashboard.php -- main dashboard
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] Step 7b: dashboard.php"
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
        $msg = "[$role] Step 7b FAILED (dashboard.php): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # 7c. victims.php -- victim list page
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] Step 7c: victims.php"
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
        $msg = "[$role] Step 7c FAILED (victims.php): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # 7d. leads.php -- lead pipeline page
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] Step 7d: leads.php"
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
        $msg = "[$role] Step 7d FAILED (leads.php): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # 7e. transactions.php -- transaction list page
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] Step 7e: transactions.php"
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
        $msg = "[$role] Step 7e FAILED (transactions.php): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # 7f. calls.php -- call log page
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] Step 7f: calls.php"
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
        $msg = "[$role] Step 7f FAILED (calls.php): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # Step 8: Firewall rules
    # ==================================================================
    Write-SetupLog "[$role] Step 8: Firewall rules"
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
                "localport=$($rule.Port)" action=allow 2>&1 | Out-Null
            Write-SetupLog "[$role] Firewall rule added: $($rule.Name) -> TCP $($rule.Port)"
        }
        Write-SetupLog "[$role] Step 8 complete: firewall rules"
    } catch {
        $msg = "[$role] Step 8 WARN -- firewall rules failed: $($_.Exception.Message)"
        Write-SetupLog $msg 'WARN'
        $errors.Add($msg)
    }

    # ==================================================================
    # Step 9: Disable SMB signing (training realism)
    # ==================================================================
    Write-SetupLog "[$role] Step 9: Disable SMB signing"
    try {
        $smbRegPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
        Set-ItemProperty -Path $smbRegPath -Name 'RequireSecuritySignature' -Value 0
        Set-ItemProperty -Path $smbRegPath -Name 'EnableSecuritySignature'  -Value 0
        Write-SetupLog "[$role] Step 9 complete: SMB signing disabled"
    } catch {
        $msg = "[$role] Step 9 WARN -- SMB signing registry update failed: $($_.Exception.Message)"
        Write-SetupLog $msg 'WARN'
        $errors.Add($msg)
    }

    # ==================================================================
    # Step 10: Windows Firewall log with brute-force RDP artefact
    # ==================================================================
    Write-SetupLog "[$role] Step 10: Firewall log pfirewall.log"
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

        # Generate 47 DROP entries spread from 23:08:11 to 23:13:55 (345 s window).
        # Entry 48 is the ALLOW (successful brute-force entry) at 23:14:22.
        $baseTime   = [datetime]'2026-04-17 23:08:11'
        $totalDrop  = 47
        $windowSecs = 344   # 23:13:55 - 23:08:11 = 344 s

        for ($n = 0; $n -lt $totalDrop; $n++) {
            # Spread drops roughly evenly; last drop at exactly 344 s offset.
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

        # The successful connection.
        $allowTime = [datetime]'2026-04-17 23:14:22'
        $allowLine = '{0} {1} ALLOW TCP {2} {3} 54268 3389 48 S 0 0 65535 - - - RECEIVE' -f `
            $allowTime.ToString('yyyy-MM-dd'), $allowTime.ToString('HH:mm:ss'), `
            $attackerIp, $victimIp
        [void]$sb.AppendLine($allowLine)

        [System.IO.File]::WriteAllText($fwLogPath, $sb.ToString(), [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $fwLogPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $fwLogPath (47 DROPs + 1 ALLOW from $attackerIp)"
    } catch {
        $msg = "[$role] Step 10 FAILED (pfirewall.log): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # Step 11: D:\Victims share + victims_master.xlsx copy
    # ==================================================================
    Write-SetupLog "[$role] Step 11: Victims share"
    try {
        $victimsDir = if (Test-Path 'D:\') { 'D:\Victims' } else { "$env:SystemDrive\Victims" }
        New-DirectoryIfMissing $victimsDir

        # Copy victims_master.xlsx if it exists on the manager drive.
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

        # Create the SMB share (read-only).
        & net share "Victims=${victimsDir}" '/GRANT:Everyone,READ' 2>&1 | Out-Null
        Write-SetupLog "[$role] Step 11 complete: SMB share Victims -> $victimsDir"
    } catch {
        $msg = "[$role] Step 11 WARN -- Victims share failed: $($_.Exception.Message)"
        Write-SetupLog $msg 'WARN'
        $errors.Add($msg)
    }

    # ==================================================================
    # Step 12: D:\CRM\uploads\ -- WAV recording stubs
    # ==================================================================
    Write-SetupLog "[$role] Step 12: Call recording WAV stubs"
    try {
        $uploadsDir = if (Test-Path 'D:\') { 'D:\CRM\uploads' } else { "$env:SystemDrive\CRM\uploads" }
        New-DirectoryIfMissing $uploadsDir

        $emptyBytes  = [byte[]]@()
        $stubsCreated = 0

        foreach ($log in ($CallLogData | Where-Object { $_.RecordingFilename })) {
            try {
                $wavPath = Join-Path $uploadsDir $log.RecordingFilename
                if (-not (Test-Path $wavPath)) {
                    [System.IO.File]::WriteAllBytes($wavPath, $emptyBytes)
                    Add-HashRecord -FilePath $wavPath -Role 'CRM-SERVER'
                    $stubsCreated++
                }
            } catch {
                # Skip individual stub failures quietly; report summary.
                Write-SetupLog "[$role] WAV stub WARN (skipping $($log.RecordingFilename)): $($_.Exception.Message)" 'WARN'
            }
        }

        Write-SetupLog "[$role] Step 12 complete: $stubsCreated WAV stubs created in $uploadsDir"
        $filesCreated += $stubsCreated
    } catch {
        $msg = "[$role] Step 12 FAILED (WAV stubs): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # Final status
    # ==================================================================
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
