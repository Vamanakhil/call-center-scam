<#
================================================================================
  New-FakeData.ps1  --  Shared data library for the
  "Golden Returns Wealth Management" cyber-forensics training lab.

  *** SYNTHETIC TRAINING DATA ONLY ***
  Every name, phone number, email, UPI handle, bank account, IFSC code and
  transaction in this file is entirely FICTIONAL and machine-generated for an
  isolated DSP forensics training exercise. The "Golden Returns Wealth
  Management" scenario is a fabricated Ponzi/boiler-room story. None of this
  data refers to any real person, company, account or financial institution.
  Any resemblance to real people or entities is purely coincidental.

  Requirements : PowerShell 5.1 (.NET Framework 4.x), Windows 10.
                 No external modules. No internet required (except the
                 OPTIONAL sqlite3.exe download inside New-SqliteDb).

  Usage        : Dot-source from a role setup script:
                     . .\shared\New-FakeData.ps1
================================================================================
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ------------------------------------------------------------------------------
# 1. Constants
# ------------------------------------------------------------------------------
$LAB_BASE_DIR = "$env:SystemDrive\GR_LabSetup"
$LAB_LOG_FILE = "$LAB_BASE_DIR\setup.log"
$LAB_HASH_CSV = "$LAB_BASE_DIR\hashes.csv"

# $PSScriptRoot is empty when a script is run line-by-line; guard for that so
# dot-sourcing the file always resolves a sane location for sqlite3.exe.
if ($PSScriptRoot) {
    $SCRIPT_DIR = $PSScriptRoot
} elseif ($MyInvocation.MyCommand.Path) {
    $SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
} else {
    $SCRIPT_DIR = (Get-Location).Path
}
$SQLITE3_PATH = Join-Path $SCRIPT_DIR 'sqlite3.exe'

# Tracks whether sqlite3.exe is usable. Updated by New-SqliteDb.
$Script:SQLITE3_AVAILABLE = $true

# Tracks whether the log file is writable. Set to $false when directory
# creation fails so that Write-SetupLog falls back to console-only output.
$Script:LOG_FILE_AVAILABLE = $true

# ------------------------------------------------------------------------------
# 2. Functions
# ------------------------------------------------------------------------------

function Write-SetupLog {
    <#
        Writes a timestamped "[LEVEL] Message" line to both the lab log file and
        the console. INFO = green, WARN = yellow, ERROR = red.
    #>
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )

    $timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    $line = "$timestamp [$Level] $Message"

    # Make sure the log directory exists before writing.
    if ($Script:LOG_FILE_AVAILABLE) {
        $logDir = Split-Path -Parent $LAB_LOG_FILE
        if ($logDir -and -not (Test-Path -LiteralPath $logDir)) {
            try {
                New-Item -ItemType Directory -Path $logDir -Force | Out-Null
            } catch {
                # Directory creation failed; fall back to console-only logging
                # so that a permission or path error here does not abort the
                # entire dot-source.
                $Script:LOG_FILE_AVAILABLE = $false
                Write-Host "Write-SetupLog: could not create log directory '$logDir': $($_.Exception.Message). Switching to console-only logging." -ForegroundColor Magenta
            }
        }
    }

    if ($Script:LOG_FILE_AVAILABLE) {
        try {
            Add-Content -LiteralPath $LAB_LOG_FILE -Value $line -Encoding UTF8
        } catch {
            # Logging must never abort a setup run.
            $Script:LOG_FILE_AVAILABLE = $false
            Write-Host "Could not write to log file '$LAB_LOG_FILE': $($_.Exception.Message). Switching to console-only logging." -ForegroundColor Magenta
        }
    }

    switch ($Level.ToUpperInvariant()) {
        'INFO'  { Write-Host $line -ForegroundColor Green  }
        'WARN'  { Write-Host $line -ForegroundColor Yellow }
        'ERROR' { Write-Host $line -ForegroundColor Red    }
        default { Write-Host $line }
    }
}

function New-DirectoryIfMissing {
    <#
        Creates the directory (and any missing parents) if it does not exist.
        No-ops if it already exists.
    #>
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        throw "New-DirectoryIfMissing: -Path is required."
    }

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-SetupLog "Created directory: $Path"
    }
}

function Add-HashRecord {
    <#
        Computes MD5 + SHA256 of $FilePath and appends a row to $LAB_HASH_CSV:
        Role, FilePath, SizeBytes, MD5, SHA256, Timestamp.
        Creates the CSV (with header) on first use.
    #>
    param(
        [string]$FilePath,
        [string]$Role
    )

    if (-not (Test-Path -LiteralPath $FilePath)) {
        Write-SetupLog "Add-HashRecord: file not found, skipping: $FilePath" 'WARN'
        return
    }

    try {
        $md5    = (Get-FileHash -LiteralPath $FilePath -Algorithm MD5).Hash
        $sha256 = (Get-FileHash -LiteralPath $FilePath -Algorithm SHA256).Hash
        $size   = (Get-Item -LiteralPath $FilePath).Length
        $ts     = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')

        # Make sure the hash directory exists.
        $hashDir = Split-Path -Parent $LAB_HASH_CSV
        if ($hashDir -and -not (Test-Path -LiteralPath $hashDir)) {
            New-Item -ItemType Directory -Path $hashDir -Force | Out-Null
        }

        if (-not (Test-Path -LiteralPath $LAB_HASH_CSV)) {
            Add-Content -LiteralPath $LAB_HASH_CSV -Value 'Role,FilePath,SizeBytes,MD5,SHA256,Timestamp' -Encoding UTF8
        }

        # Quote fields and escape embedded quotes for CSV safety.
        $row = ('"{0}","{1}","{2}","{3}","{4}","{5}"' -f `
            ($Role     -replace '"','""'), `
            ($FilePath -replace '"','""'), `
            $size, `
            $md5, `
            $sha256, `
            $ts)

        Add-Content -LiteralPath $LAB_HASH_CSV -Value $row -Encoding UTF8
    } catch {
        Write-SetupLog "Add-HashRecord failed for '$FilePath': $($_.Exception.Message)" 'ERROR'
    }
}

function New-SqliteDb {
    <#
        Creates (or overwrites) a SQLite3 database at $DbPath and executes each
        SQL statement in order.

        sqlite3.exe resolution order:
          1. $SQLITE3_PATH
          2. sqlite3.exe found in PATH
          3. download + extract from sqlite.org into $SQLITE3_PATH
        If none succeed, logs a WARN and returns $false.

        Returns $true on success, $false on failure.
    #>
    param(
        [string]$DbPath,
        [string[]]$SqlStatements
    )

    # ---- Resolve a usable sqlite3.exe ----------------------------------------
    $sqliteExe = $null

    if (Test-Path -LiteralPath $SQLITE3_PATH) {
        $sqliteExe = $SQLITE3_PATH
    } else {
        $inPath = Get-Command 'sqlite3.exe' -ErrorAction SilentlyContinue
        if ($inPath) {
            $sqliteExe = $inPath.Source
        }
    }

    if (-not $sqliteExe) {
        # Last resort: optional download.
        $downloadUrl = 'https://www.sqlite.org/2024/sqlite-tools-win32-x86-3460100.zip'
        $tmpZip      = Join-Path $env:TEMP ("sqlite-tools-{0}.zip" -f ([guid]::NewGuid().ToString('N')))
        $tmpDir      = Join-Path $env:TEMP ("sqlite-tools-{0}"     -f ([guid]::NewGuid().ToString('N')))

        try {
            Write-SetupLog "sqlite3.exe not found locally or in PATH; attempting download from $downloadUrl" 'WARN'

            # Prefer TLS 1.2 for sqlite.org.
            try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch { }

            $oldProgress = $ProgressPreference
            $ProgressPreference = 'SilentlyContinue'
            Invoke-WebRequest -Uri $downloadUrl -OutFile $tmpZip -UseBasicParsing -TimeoutSec 30
            $ProgressPreference = $oldProgress

            Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
            if (Test-Path -LiteralPath $tmpDir) { Remove-Item -LiteralPath $tmpDir -Recurse -Force }
            [System.IO.Compression.ZipFile]::ExtractToDirectory($tmpZip, $tmpDir)

            $found = Get-ChildItem -LiteralPath $tmpDir -Recurse -Filter 'sqlite3.exe' -ErrorAction SilentlyContinue |
                     Select-Object -First 1
            if ($found) {
                Copy-Item -LiteralPath $found.FullName -Destination $SQLITE3_PATH -Force
                $sqliteExe = $SQLITE3_PATH
                Write-SetupLog "Downloaded and installed sqlite3.exe to $SQLITE3_PATH"
            }
        } catch {
            Write-SetupLog "sqlite3.exe download/extract failed: $($_.Exception.Message)" 'WARN'
        } finally {
            if (Test-Path -LiteralPath $tmpZip) { Remove-Item -LiteralPath $tmpZip -Force -ErrorAction SilentlyContinue }
            if (Test-Path -LiteralPath $tmpDir) { Remove-Item -LiteralPath $tmpDir -Recurse -Force -ErrorAction SilentlyContinue }
        }
    }

    if (-not $sqliteExe) {
        $Script:SQLITE3_AVAILABLE = $false
        Write-SetupLog "New-SqliteDb: no sqlite3.exe available; cannot build '$DbPath'." 'WARN'
        return $false
    }

    $Script:SQLITE3_AVAILABLE = $true

    # ---- Build the database --------------------------------------------------
    try {
        # Overwrite any existing DB.
        if (Test-Path -LiteralPath $DbPath) {
            Remove-Item -LiteralPath $DbPath -Force
        }
        $dbDir = Split-Path -Parent $DbPath
        if ($dbDir -and -not (Test-Path -LiteralPath $dbDir)) {
            New-Item -ItemType Directory -Path $dbDir -Force | Out-Null
        }

        # Concatenate statements into one script piped via a temp .sql file.
        $sqlText = ($SqlStatements -join "`n")
        $tmpSql  = Join-Path $env:TEMP ("gr-sqlite-{0}.sql" -f ([guid]::NewGuid().ToString('N')))
        Set-Content -LiteralPath $tmpSql -Value $sqlText -Encoding UTF8

        try {
            # Feed the SQL script on stdin: sqlite3.exe <db>  < script.sql
            $output = & cmd.exe /c "`"$sqliteExe`" `"$DbPath`" < `"$tmpSql`"" 2>&1
            $exit   = $LASTEXITCODE
        } finally {
            if (Test-Path -LiteralPath $tmpSql) { Remove-Item -LiteralPath $tmpSql -Force -ErrorAction SilentlyContinue }
        }

        if ($exit -ne 0) {
            Write-SetupLog "New-SqliteDb: sqlite3 returned exit code $exit building '$DbPath'. Output: $output" 'ERROR'
            return $false
        }

        Write-SetupLog "Created SQLite database: $DbPath"
        return $true
    } catch {
        Write-SetupLog "New-SqliteDb failed for '$DbPath': $($_.Exception.Message)" 'ERROR'
        return $false
    }
}

function New-MinimalDocx {
    <#
        Creates a valid .docx (Open XML WordprocessingML) at $OutPath using
        System.IO.Packaging (WindowsBase.dll). $BodyText is plain text; each
        newline becomes a separate paragraph (<w:p>). Pure .NET, no Word needed.
    #>
    param(
        [string]$OutPath,
        [string]$BodyText
    )

    Add-Type -AssemblyName WindowsBase -ErrorAction SilentlyContinue

    if ($null -eq $BodyText) { $BodyText = '' }

    $outDir = Split-Path -Parent $OutPath
    if ($outDir -and -not (Test-Path -LiteralPath $outDir)) {
        New-Item -ItemType Directory -Path $outDir -Force | Out-Null
    }
    if (Test-Path -LiteralPath $OutPath) { Remove-Item -LiteralPath $OutPath -Force }

    $wordMlNs = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
    $relNs    = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument'
    $ctType   = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml'

    # XML-escape and split into paragraphs.
    $escape = {
        param($s)
        $s -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;' -replace '"','&quot;'
    }

    $paras = $BodyText -split "`r?`n"
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
    [void]$sb.Append("<w:document xmlns:w=`"$wordMlNs`"><w:body>")
    foreach ($p in $paras) {
        $safe = & $escape $p
        # xml:space="preserve" keeps leading/trailing spaces intact.
        [void]$sb.Append('<w:p><w:r><w:t xml:space="preserve">' + $safe + '</w:t></w:r></w:p>')
    }
    # Final section properties (optional but tidy).
    [void]$sb.Append('<w:sectPr><w:pgSz w:w="12240" w:h="15840"/></w:sectPr>')
    [void]$sb.Append('</w:body></w:document>')
    $documentXml = $sb.ToString()

    $package = $null
    try {
        $package = [System.IO.Packaging.Package]::Open(
            $OutPath,
            [System.IO.FileMode]::Create,
            [System.IO.FileAccess]::ReadWrite)

        $partUri = New-Object System.Uri('/word/document.xml', [System.UriKind]::Relative)
        $part = $package.CreatePart($partUri, $ctType, [System.IO.Packaging.CompressionOption]::Maximum)

        $bytes = [System.Text.Encoding]::UTF8.GetBytes($documentXml)
        $stream = $part.GetStream([System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
        try {
            $stream.Write($bytes, 0, $bytes.Length)
        } finally {
            $stream.Dispose()
        }

        # Relationship making document.xml the main document.
        [void]$package.CreateRelationship($partUri, [System.IO.Packaging.TargetMode]::Internal, $relNs, 'rId1')
    } finally {
        if ($package) { $package.Close() }
    }

    Write-SetupLog "Created DOCX: $OutPath"
}

function New-ZipWithContent {
    <#
        Creates a ZIP archive at $OutPath. $Files hashtable: keys = entry names
        inside the ZIP, values = string content. Uses System.IO.Compression.
    #>
    param(
        [string]$OutPath,
        [hashtable]$Files
    )

    Add-Type -AssemblyName System.IO.Compression -ErrorAction SilentlyContinue
    Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue

    $outDir = Split-Path -Parent $OutPath
    if ($outDir -and -not (Test-Path -LiteralPath $outDir)) {
        New-Item -ItemType Directory -Path $outDir -Force | Out-Null
    }
    if (Test-Path -LiteralPath $OutPath) { Remove-Item -LiteralPath $OutPath -Force }

    $fs = $null
    $archive = $null
    try {
        $fs = New-Object System.IO.FileStream($OutPath, [System.IO.FileMode]::Create)
        $archive = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)

        if ($Files) {
            foreach ($key in $Files.Keys) {
                $entry = $archive.CreateEntry([string]$key, [System.IO.Compression.CompressionLevel]::Optimal)
                $writer = New-Object System.IO.StreamWriter($entry.Open(), [System.Text.Encoding]::UTF8)
                try {
                    $content = $Files[$key]
                    if ($null -eq $content) { $content = '' }
                    $writer.Write([string]$content)
                } finally {
                    $writer.Dispose()
                }
            }
        }
    } finally {
        if ($archive) { $archive.Dispose() }
        if ($fs)      { $fs.Dispose() }
    }

    Write-SetupLog "Created ZIP: $OutPath"
}

function New-UpiPngStub {
    <#
        Writes a minimal valid 1x1 transparent PNG (the UPI screenshot
        placeholder) to $OutPath.
    #>
    param([string]$OutPath)

    $outDir = Split-Path -Parent $OutPath
    if ($outDir -and -not (Test-Path -LiteralPath $outDir)) {
        New-Item -ItemType Directory -Path $outDir -Force | Out-Null
    }

    # 67-byte 1x1 transparent PNG.
    $pngBytes = [byte[]]@(
        0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A,
        0x00,0x00,0x00,0x0D,0x49,0x48,0x44,0x52,
        0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,
        0x08,0x06,0x00,0x00,0x00,0x1F,0x15,0xC4,
        0x89,0x00,0x00,0x00,0x0A,0x49,0x44,0x41,
        0x54,0x78,0x9C,0x63,0x00,0x01,0x00,0x00,
        0x05,0x00,0x01,0x0D,0x0A,0x2D,0xB4,0x00,
        0x00,0x00,0x00,0x49,0x45,0x4E,0x44,0xAE,
        0x42,0x60,0x82
    )

    [System.IO.File]::WriteAllBytes($OutPath, $pngBytes)
    Write-SetupLog "Created UPI PNG stub: $OutPath"
}

# ------------------------------------------------------------------------------
# 3. Fake data arrays
# ------------------------------------------------------------------------------

# --- Reproducible randomness --------------------------------------------------
$RANDOM_SEED = 42
$Script:GR_Rng = New-Object System.Random($RANDOM_SEED)

# Deterministic integer in [min, max) using the seeded RNG (matches Get-Random
# semantics: Max is exclusive).
function Get-GrRandom {
    param(
        [int]$Min = 0,
        [int]$Max = 2147483647
    )
    return $Script:GR_Rng.Next($Min, $Max)
}

# Deterministic weighted pick. -Items and -Weights are parallel arrays.
function Get-GrWeighted {
    param(
        [object[]]$Items,
        [int[]]$Weights
    )
    $total = 0
    foreach ($w in $Weights) { $total += $w }
    $roll = $Script:GR_Rng.Next(0, $total)
    $acc = 0
    for ($k = 0; $k -lt $Items.Count; $k++) {
        $acc += $Weights[$k]
        if ($roll -lt $acc) { return $Items[$k] }
    }
    return $Items[$Items.Count - 1]
}

$IndianFirstNames = @(
    'Rahul','Priya','Amit','Sneha','Vikas','Arjun','Deepak','Sunita','Kavita','Mohan',
    'Raj','Neha','Sanjay','Pooja','Ravi','Anita','Vikram','Meena','Suresh','Geeta',
    'Arun','Nisha','Manoj','Rekha','Dinesh','Savita','Ramesh','Usha','Vinod','Sharda',
    'Naresh','Lata','Prakash','Asha','Ajay','Preeti','Krishnan','Meera','Satish','Vandana',
    'Mukesh','Hemant','Pushpa','Rajesh','Mamta','Ashok','Kiran','Sunil','Radha','Harish',
    'Madhuri','Naveen','Pallavi','Yogesh','Swati','Nitin','Jyoti','Rohit','Shruti','Shyam',
    'Divya','Girish','Ritu','Kapil','Suman','Anu','Lalit','Poonam','Bharat','Seema',
    'Vinay','Sulekha','Kamal','Nirmala','Devendra','Sarla','Bhupesh','Kamla','Tarun','Anjali',
    'Manish','Renu','Gaurav','Shalini'
)

$IndianLastNames = @(
    'Sharma','Verma','Patel','Iyer','Nair','Mehta','Gupta','Singh','Joshi','Mishra',
    'Tiwari','Pandey','Yadav','Shah','Jain','Agarwal','Bose','Banerjee','Chatterjee','Mukherjee',
    'Das','Reddy','Rao','Pillai','Menon','Nambiar','Thomas','George','Mathew','Naidu',
    'Gowda','Hegde','Kamath','Shetty','Pawar','Desai','Kulkarni','Deshpande','Patil','More',
    'Jadhav','Sawant','Gaikwad','Bhosale','Mane','Kadam','Wagh','Shinde','Chavan','Thakur',
    'Rawat','Bisht','Negi','Chauhan','Rajput','Dixit','Tripathi','Srivastava','Misra','Dubey',
    'Shukla','Bajpai','Saxena','Awasthi','Asthana','Lal','Sinha','Kumar'
)

$MuleAccounts = @(
    @{ Bank='HDFC';     Account='XXXXXX4242'; IFSC='HDFC0ANDHERI'; UPI='arjun.collect@upi'; Name='Arjun Mehta';            ActiveFrom='2026-04-01'; ActiveTo='2026-04-07' },
    @{ Bank='ICICI';    Account='XXXXXX9191'; IFSC='ICIC0001234';  UPI='gr.deposit@upi';    Name='Rahul Finance Services'; ActiveFrom='2026-04-08'; ActiveTo='2026-04-14' },
    @{ Bank='Axis';     Account='XXXXXX7720'; IFSC='UTIB0000123';  UPI='compliance.gr@upi'; Name='GR Compliance Pvt Ltd';   ActiveFrom='2026-04-15'; ActiveTo='2026-04-21' },
    @{ Bank='Kotak';    Account='XXXXXX3344'; IFSC='KKBK0001234';  UPI='kotakgr@upi';       Name='Kotak Acc Services';     ActiveFrom='2026-04-22'; ActiveTo='2026-04-28' },
    @{ Bank='SBI';      Account='XXXXXX1008'; IFSC='SBIN0011234';  UPI='sbigr.pay@upi';     Name='SBI Holdings';           ActiveFrom='2026-04-29'; ActiveTo='2026-05-05' },
    @{ Bank='Yes Bank'; Account='XXXXXX5500'; IFSC='YESB0001234';  UPI='yesgr@upi';         Name='Yes Pay Services';       ActiveFrom='2026-05-06'; ActiveTo='2026-05-12' }
)

$LabCities = @('Mumbai','Delhi','Bangalore','Hyderabad','Chennai','Kolkata','Pune','Ahmedabad','Jaipur','Lucknow','Surat','Kanpur','Nagpur','Indore','Patna')
$LeadSources = @('LinkedIn','Facebook','Instagram','Purchased_List','Referral')
$LabAgents = @('rahul.s','vikas.n','amit.p','priya.k','deepak.r')

# Helper: deterministic Indian mobile number "9XXXXXXXXXX".
function New-GrPhone {
    return ('9{0}' -f (Get-GrRandom -Min 10000000 -Max 99999999))
}

# Helper: deterministic date string between two dates (inclusive).
function New-GrDate {
    param([datetime]$Start, [datetime]$End)
    $span = ($End - $Start).Days
    if ($span -lt 0) { $span = 0 }
    $offset = Get-GrRandom -Min 0 -Max ($span + 1)
    return $Start.AddDays($offset)
}

# Victim IDs that MUST be assigned to rahul.s (appear in hot_leads_today.txt).
$RahulHotVictimNums = @(1,23,47,52,88,101,122,145,167,189,202,234)

# --- $VictimData : 487 records ------------------------------------------------
$amountChoices = @(5000,10000,15000,25000,50000,75000,100000,150000,200000,300000,500000)
$amountWeights = @(   180,  170,  140,  110,   90,   55,    45,    35,    20,    10,     5)

$VictimData = New-Object System.Collections.Generic.List[object]
for ($i = 1; $i -le 487; $i++) {
    $first = $IndianFirstNames[(Get-GrRandom -Min 0 -Max $IndianFirstNames.Count)]
    $last  = $IndianLastNames[(Get-GrRandom -Min 0 -Max $IndianLastNames.Count)]

    $amount = Get-GrWeighted -Items $amountChoices -Weights $amountWeights

    # FinalOutcome: 90% BURNED, 8% ACTIVE, 2% REFUNDED.
    $outcome = Get-GrWeighted -Items @('BURNED','ACTIVE','REFUNDED') -Weights @(90,8,2)

    # Closer: first 150 -> rahul.s, rest -> vikas.n; plus forced rahul.s victims.
    if ($i -le 150 -or $RahulHotVictimNums -contains $i) {
        $closer = 'rahul.s'
    } else {
        $closer = 'vikas.n'
    }

    $status = if ($outcome -eq 'BURNED') { 'CLOSED' } else { 'ACTIVE' }

    $dateAdded = New-GrDate -Start ([datetime]'2026-01-01') -End ([datetime]'2026-04-15')

    $VictimData.Add([PSCustomObject]@{
        VictimId       = "VICTIM-$($i.ToString('000'))"
        Name           = "$first $last"
        Phone          = (New-GrPhone)
        Email          = ('{0}.{1}{2}@gmail.com' -f $first.ToLower(), $last.ToLower(), (Get-GrRandom -Min 1 -Max 99))
        City           = $LabCities[(Get-GrRandom -Min 0 -Max $LabCities.Count)]
        AmountPaid     = $amount
        InitialDeposit = $amount
        FinalOutcome   = $outcome
        AssignedCloser = $closer
        DateAdded      = $dateAdded.ToString('yyyy-MM-dd')
        Status         = $status
        Notes          = ''
    })
}
# Fast lookup of victim IDs by number.
$VictimIds = @($VictimData | ForEach-Object { $_.VictimId })

# --- $LeadData : 12,000 records ----------------------------------------------
# First 487 = HOT and map 1:1 to the victim IDs; rest get weighted statuses.
$LeadData = New-Object System.Collections.Generic.List[object]
for ($i = 1; $i -le 12000; $i++) {
    $first = $IndianFirstNames[(Get-GrRandom -Min 0 -Max $IndianFirstNames.Count)]
    $last  = $IndianLastNames[(Get-GrRandom -Min 0 -Max $IndianLastNames.Count)]

    if ($i -le 487) {
        $status = 'HOT'
        # Map this lead to the matching victim (keeps name in sync with CRM).
        $v = $VictimData[$i - 1]
        $name  = $v.Name
        $phone = $v.Phone
        $email = $v.Email
    } else {
        $status = Get-GrWeighted -Items @('COLD','WARM','ASSIGNED','DNC') -Weights @(60,25,10,5)
        $name  = "$first $last"
        $phone = (New-GrPhone)
        $email = ('{0}.{1}{2}@gmail.com' -f $first.ToLower(), $last.ToLower(), (Get-GrRandom -Min 1 -Max 99))
    }

    if ($status -eq 'HOT' -or $status -eq 'ASSIGNED') {
        $agent = $LabAgents[(Get-GrRandom -Min 0 -Max $LabAgents.Count)]
    } else {
        $agent = ''
    }

    $dateAdded = New-GrDate -Start ([datetime]'2025-10-01') -End ([datetime]'2026-04-17')

    $LeadData.Add([PSCustomObject]@{
        LeadId        = $i
        Name          = $name
        Phone         = $phone
        Email         = $email
        Source        = $LeadSources[(Get-GrRandom -Min 0 -Max $LeadSources.Count)]
        HeatScore     = (Get-GrRandom -Min 1 -Max 11)
        Status        = $status
        AssignedAgent = $agent
        DateAdded     = $dateAdded.ToString('yyyy-MM-dd')
    })
}

# --- $TransactionData : 2,314 records ----------------------------------------
# Weighted victim selection so some victims have many payments. We weight by
# victim index (lower-numbered "early" victims pay more often) plus a base.
$TXN_TARGET_SUM = 43782500   # Rs 4,37,82,500 across all CONFIRMED transactions.

$muleUpis  = @($MuleAccounts | ForEach-Object { $_.UPI })
$muleAccts = @($MuleAccounts | ForEach-Object { $_.Account })

# Precompute cumulative weights for weighted victim picking.
$victimWeights = New-Object int[] 487
for ($v = 0; $v -lt 487; $v++) {
    # Base weight 1; early victims get a boost so payment counts vary.
    $victimWeights[$v] = 1 + [math]::Floor((487 - $v) / 40)
}
$victimWeightTotal = 0
foreach ($w in $victimWeights) { $victimWeightTotal += $w }

function Get-GrWeightedVictimIndex {
    $roll = $Script:GR_Rng.Next(0, $victimWeightTotal)
    $acc = 0
    for ($k = 0; $k -lt 487; $k++) {
        $acc += $victimWeights[$k]
        if ($roll -lt $acc) { return $k }
    }
    return 486
}

$TransactionData = New-Object System.Collections.Generic.List[object]
$confirmedIndexes = New-Object System.Collections.Generic.List[int]

for ($i = 1; $i -le 2314; $i++) {

    # Forced inject row 1842.
    if ($i -eq 1842) {
        $rec = [PSCustomObject]@{
            TxnId           = $i
            VictimId        = 'VICTIM-047'
            Amount          = 50000
            UpiId           = $muleUpis[(Get-GrRandom -Min 0 -Max $muleUpis.Count)]
            BeneficiaryAcct = $muleAccts[(Get-GrRandom -Min 0 -Max $muleAccts.Count)]
            TxnDate         = (New-GrDate -Start ([datetime]'2026-01-01') -End ([datetime]'2026-04-17')).ToString('yyyy-MM-dd')
            Status          = 'CONFIRMED'
            Notes           = ''
        }
        $TransactionData.Add($rec)
        $confirmedIndexes.Add($TransactionData.Count - 1)
        continue
    }

    $vIdx = Get-GrWeightedVictimIndex
    $victimId = $VictimIds[$vIdx]

    # Amount 5000..500000 in 5000 steps.
    $amount = (Get-GrRandom -Min 1 -Max 101) * 5000

    $status = Get-GrWeighted -Items @('CONFIRMED','PENDING','FAILED') -Weights @(95,3,2)

    $rec = [PSCustomObject]@{
        TxnId           = $i
        VictimId        = $victimId
        Amount          = $amount
        UpiId           = $muleUpis[(Get-GrRandom -Min 0 -Max $muleUpis.Count)]
        BeneficiaryAcct = $muleAccts[(Get-GrRandom -Min 0 -Max $muleAccts.Count)]
        TxnDate         = (New-GrDate -Start ([datetime]'2026-01-01') -End ([datetime]'2026-04-17')).ToString('yyyy-MM-dd')
        Status          = $status
        Notes           = ''
    }
    $TransactionData.Add($rec)
    if ($status -eq 'CONFIRMED') { $confirmedIndexes.Add($TransactionData.Count - 1) }
}

# Scale CONFIRMED amounts so their sum is exactly $TXN_TARGET_SUM.
# Inject row 1842 (VICTIM-047, 50000) must stay fixed, so we adjust the others.
$currentConfirmedSum = 0
foreach ($ci in $confirmedIndexes) { $currentConfirmedSum += $TransactionData[$ci].Amount }

$delta = $TXN_TARGET_SUM - $currentConfirmedSum
# Distribute the delta across the trailing CONFIRMED rows (excluding row 1842).
$adjustable = @($confirmedIndexes | Where-Object { $TransactionData[$_].TxnId -ne 1842 })

if ($adjustable.Count -gt 0) {
    # Apply the bulk of the delta to the very last confirmed row, but spread it
    # over the trailing rows in 5000-ish chunks so no single amount goes absurd
    # or negative. We work from the end backwards.
    $remaining = $delta
    $idxList = @($adjustable | Sort-Object -Descending)
    foreach ($ci in $idxList) {
        if ($remaining -eq 0) { break }
        $cur = $TransactionData[$ci].Amount
        # Keep amounts within [5000, 5000000].
        $minAdj = 5000 - $cur          # most we can subtract (negative)
        $maxAdj = 5000000 - $cur       # most we can add (positive)
        if ($remaining -gt 0) {
            $apply = [math]::Min($remaining, $maxAdj)
        } else {
            $apply = [math]::Max($remaining, $minAdj)
        }
        $TransactionData[$ci].Amount = $cur + $apply
        $remaining -= $apply
    }
    # If anything is still left (extremely unlikely), dump it on the last row.
    if ($remaining -ne 0 -and $idxList.Count -gt 0) {
        $TransactionData[$idxList[0]].Amount += $remaining
        $remaining = 0
    }
}

# --- $CallLogData : 891 records ----------------------------------------------
$callAgents = @('rahul.s','amit.p')
$CallLogData = New-Object System.Collections.Generic.List[object]
for ($i = 1; $i -le 891; $i++) {

    # Forced inject row 202.
    if ($i -eq 202) {
        $CallLogData.Add([PSCustomObject]@{
            LogId             = $i
            AgentId           = 'amit.p'
            VictimId          = 'VICTIM-202'
            DurationSeconds   = (Get-GrRandom -Min 120 -Max 1801)
            RecordingFilename = '2026-04-17_1822_V202.wav'
            CallDate          = '2026-04-17'
            CallType          = (Get-GrWeighted -Items @('OUTBOUND','INBOUND') -Weights @(80,20))
            Outcome           = (Get-GrWeighted -Items @('CONVERTED','FOLLOW_UP','NOT_INTERESTED','INVALID') -Weights @(30,40,20,10))
        })
        continue
    }

    $vIdx = Get-GrRandom -Min 0 -Max 487
    $victimId  = $VictimIds[$vIdx]
    $victimNum = ($vIdx + 1)

    $callDate = New-GrDate -Start ([datetime]'2026-03-01') -End ([datetime]'2026-04-17')
    $hh = (Get-GrRandom -Min 8 -Max 21)
    $mm = (Get-GrRandom -Min 0 -Max 60)
    $recName = ('{0}_{1:00}{2:00}_V{3}.wav' -f $callDate.ToString('yyyy-MM-dd'), $hh, $mm, $victimNum)

    $CallLogData.Add([PSCustomObject]@{
        LogId             = $i
        AgentId           = $callAgents[(Get-GrRandom -Min 0 -Max $callAgents.Count)]
        VictimId          = $victimId
        DurationSeconds   = (Get-GrRandom -Min 120 -Max 1801)
        RecordingFilename = $recName
        CallDate          = $callDate.ToString('yyyy-MM-dd')
        CallType          = (Get-GrWeighted -Items @('OUTBOUND','INBOUND') -Weights @(80,20))
        Outcome           = (Get-GrWeighted -Items @('CONVERTED','FOLLOW_UP','NOT_INTERESTED','INVALID') -Weights @(30,40,20,10))
    })
}

# --- Browser history arrays ---------------------------------------------------

$ChromeUrlHistory = @(
    @{ Url='https://t.me/goldsupport_real';                          Title='Gold Support (Telegram)';        VisitCount=44; LastVisit='2026-04-17 19:42:11' },
    @{ Url='https://t.me/gr_daily_collect';                          Title='GR Daily Collect (Telegram)';     VisitCount=37; LastVisit='2026-04-17 18:05:50' },
    @{ Url='https://goldenreturns.example/admin';                    Title='Golden Returns | Admin';          VisitCount=61; LastVisit='2026-04-17 19:55:03' },
    @{ Url='https://goldenreturns.example/customer';                 Title='Golden Returns | Customer Portal'; VisitCount=29; LastVisit='2026-04-17 17:31:22' },
    @{ Url='https://drive.google.com/drive/u/0/folders/1AB_GRcollect'; Title='GR Collections - Google Drive'; VisitCount=18; LastVisit='2026-04-17 16:12:08' },
    @{ Url='https://web.whatsapp.com/';                              Title='WhatsApp';                        VisitCount=210; LastVisit='2026-04-17 19:58:40' },
    @{ Url='https://web.whatsapp.com/send?phone=919812345678';       Title='WhatsApp';                        VisitCount=15; LastVisit='2026-04-17 14:10:00' },
    @{ Url='https://web.whatsapp.com/send?phone=919823456789';       Title='WhatsApp';                        VisitCount=12; LastVisit='2026-04-16 11:22:33' },
    @{ Url='https://web.whatsapp.com/send?phone=919834567890';       Title='WhatsApp';                        VisitCount=9;  LastVisit='2026-04-16 09:45:10' },
    @{ Url='https://web.whatsapp.com/send?phone=919845678901';       Title='WhatsApp';                        VisitCount=7;  LastVisit='2026-04-15 16:20:55' },
    @{ Url='https://web.whatsapp.com/send?phone=919856789012';       Title='WhatsApp';                        VisitCount=6;  LastVisit='2026-04-15 13:09:41' },
    @{ Url='https://web.whatsapp.com/send?phone=919867890123';       Title='WhatsApp';                        VisitCount=5;  LastVisit='2026-04-14 18:30:00' },
    @{ Url='https://web.whatsapp.com/send?phone=919878901234';       Title='WhatsApp';                        VisitCount=8;  LastVisit='2026-04-14 12:11:11' },
    @{ Url='https://web.whatsapp.com/send?phone=919889012345';       Title='WhatsApp';                        VisitCount=4;  LastVisit='2026-04-13 15:42:22' },
    @{ Url='https://web.whatsapp.com/send?phone=919890123456';       Title='WhatsApp';                        VisitCount=11; LastVisit='2026-04-13 10:05:30' },
    @{ Url='https://web.whatsapp.com/send?phone=919801234567';       Title='WhatsApp';                        VisitCount=3;  LastVisit='2026-04-12 17:55:44' },
    @{ Url='https://web.whatsapp.com/send?phone=919812340987';       Title='WhatsApp';                        VisitCount=6;  LastVisit='2026-04-12 09:33:21' },
    @{ Url='https://www.linkedin.com/feed/';                         Title='LinkedIn';                        VisitCount=33; LastVisit='2026-04-17 10:15:00' },
    @{ Url='https://www.facebook.com/';                              Title='Facebook';                        VisitCount=27; LastVisit='2026-04-16 21:40:12' },
    @{ Url='https://goldenreturns.example/admin/payouts';            Title='Golden Returns | Payouts';        VisitCount=22; LastVisit='2026-04-17 19:50:00' },
    @{ Url='https://goldenreturns.example/admin/leads';             Title='Golden Returns | Leads';          VisitCount=19; LastVisit='2026-04-17 15:21:09' },
    @{ Url='https://goldenreturns.example/admin/closers';           Title='Golden Returns | Closers';        VisitCount=14; LastVisit='2026-04-17 13:02:44' },
    @{ Url='https://t.me/';                                          Title='Telegram Web';                    VisitCount=88; LastVisit='2026-04-17 19:59:01' },
    @{ Url='https://drive.google.com/drive/u/0/my-drive';           Title='My Drive - Google Drive';         VisitCount=16; LastVisit='2026-04-17 11:30:00' },
    @{ Url='https://mail.google.com/mail/u/0/';                     Title='Gmail';                           VisitCount=54; LastVisit='2026-04-17 18:44:30' },
    @{ Url='https://www.google.com/search?q=upi+chargeback+reverse'; Title='upi chargeback reverse - Google'; VisitCount=4; LastVisit='2026-04-16 22:05:00' },
    @{ Url='https://www.google.com/search?q=how+to+avoid+cyber+cell+trace'; Title='Google Search';           VisitCount=2;  LastVisit='2026-04-15 23:10:00' },
    @{ Url='https://razorpay.example/dashboard';                    Title='Payments Dashboard';              VisitCount=13; LastVisit='2026-04-17 12:00:00' },
    @{ Url='https://goldenreturns.example/admin/reports';          Title='Golden Returns | Reports';        VisitCount=10; LastVisit='2026-04-17 16:45:00' },
    @{ Url='https://www.youtube.com/';                              Title='YouTube';                         VisitCount=40; LastVisit='2026-04-16 23:30:00' },
    @{ Url='https://translate.google.com/';                        Title='Google Translate';               VisitCount=6;  LastVisit='2026-04-14 14:14:14' },
    @{ Url='https://goldenreturns.example/customer/login';         Title='Golden Returns | Login';          VisitCount=17; LastVisit='2026-04-17 09:00:00' },
    @{ Url='https://t.me/goldsupport_real/1023';                   Title='Gold Support (Telegram)';         VisitCount=8;  LastVisit='2026-04-17 19:10:00' },
    @{ Url='https://t.me/gr_daily_collect/4502';                   Title='GR Daily Collect (Telegram)';     VisitCount=6;  LastVisit='2026-04-17 18:00:00' },
    @{ Url='https://www.icicibank.com/';                           Title='ICICI Bank';                      VisitCount=9;  LastVisit='2026-04-16 10:00:00' },
    @{ Url='https://www.hdfcbank.com/';                            Title='HDFC Bank';                       VisitCount=7;  LastVisit='2026-04-16 10:05:00' },
    @{ Url='https://www.whatsapp.com/download';                    Title='Download WhatsApp';               VisitCount=2;  LastVisit='2026-04-10 08:00:00' },
    @{ Url='https://drive.google.com/file/d/1ZZ_voicebackup/view'; Title='voice_backup - Google Drive';     VisitCount=5;  LastVisit='2026-04-15 20:00:00' },
    @{ Url='https://goldenreturns.example/admin/victim/047';       Title='Golden Returns | Victim 047';     VisitCount=4;  LastVisit='2026-04-17 17:00:00' },
    @{ Url='https://goldenreturns.example/admin/victim/202';       Title='Golden Returns | Victim 202';     VisitCount=3;  LastVisit='2026-04-17 18:25:00' },
    @{ Url='https://web.whatsapp.com/send?phone=919811223344';     Title='WhatsApp';                        VisitCount=5;  LastVisit='2026-04-13 19:00:00' },
    @{ Url='https://www.google.com/';                              Title='Google';                          VisitCount=120; LastVisit='2026-04-17 19:59:30' },
    @{ Url='https://t.me/s/gr_daily_collect';                      Title='GR Daily Collect Preview';        VisitCount=3;  LastVisit='2026-04-12 12:00:00' },
    @{ Url='https://goldenreturns.example/admin/settings';         Title='Golden Returns | Settings';       VisitCount=6;  LastVisit='2026-04-17 08:30:00' },
    @{ Url='https://accounts.google.com/';                         Title='Sign in - Google Accounts';       VisitCount=15; LastVisit='2026-04-17 07:55:00' },
    @{ Url='https://goldenreturns.example/admin/export?type=victims'; Title='Golden Returns | Export';      VisitCount=2;  LastVisit='2026-04-17 19:48:00' },
    @{ Url='https://www.bing.com/search?q=delete+chat+history+telegram'; Title='Bing';                      VisitCount=2;  LastVisit='2026-04-16 23:55:00' }
)

# Agent-02: prospecting-heavy (Sales Navigator, social), plus CRM admin.
$ChromeUrlHistory_Agent02 = New-Object System.Collections.Generic.List[object]
$ChromeUrlHistory_Agent02.Add(@{ Url='https://www.linkedin.com/sales/home';                 Title='LinkedIn Sales Navigator';       VisitCount=140; LastVisit='2026-04-17 18:30:00' })
$ChromeUrlHistory_Agent02.Add(@{ Url='https://goldenreturns.example/admin';                 Title='Golden Returns | Admin';         VisitCount=44;  LastVisit='2026-04-17 17:00:00' })
$ChromeUrlHistory_Agent02.Add(@{ Url='https://goldenreturns.example/admin/leads';           Title='Golden Returns | Leads';         VisitCount=38;  LastVisit='2026-04-17 16:10:00' })
$ChromeUrlHistory_Agent02.Add(@{ Url='https://www.facebook.com/';                           Title='Facebook';                       VisitCount=66;  LastVisit='2026-04-17 19:00:00' })
$ChromeUrlHistory_Agent02.Add(@{ Url='https://www.instagram.com/';                          Title='Instagram';                      VisitCount=70;  LastVisit='2026-04-17 19:20:00' })
# Generated LinkedIn Sales Navigator lead/search pages.
for ($n = 1; $n -le 40; $n++) {
    $profId = 100000 + ($n * 137)
    $ChromeUrlHistory_Agent02.Add(@{
        Url        = "https://www.linkedin.com/sales/lead/$profId,NAME_SEARCH"
        Title      = "Lead $n | LinkedIn Sales Navigator"
        VisitCount = (Get-GrRandom -Min 1 -Max 12)
        LastVisit  = (New-GrDate -Start ([datetime]'2026-03-15') -End ([datetime]'2026-04-17')).ToString('yyyy-MM-dd') + (' {0:00}:{1:00}:00' -f (Get-GrRandom -Min 9 -Max 20), (Get-GrRandom -Min 0 -Max 60))
    })
}
# Generated Facebook + Instagram prospect pages.
for ($n = 1; $n -le 20; $n++) {
    $ChromeUrlHistory_Agent02.Add(@{
        Url        = "https://www.facebook.com/profile.php?id=$((61550000000 + $n))"
        Title      = "Facebook Profile $n"
        VisitCount = (Get-GrRandom -Min 1 -Max 8)
        LastVisit  = (New-GrDate -Start ([datetime]'2026-03-15') -End ([datetime]'2026-04-17')).ToString('yyyy-MM-dd') + (' {0:00}:{1:00}:00' -f (Get-GrRandom -Min 9 -Max 20), (Get-GrRandom -Min 0 -Max 60))
    })
}
for ($n = 1; $n -le 15; $n++) {
    $ChromeUrlHistory_Agent02.Add(@{
        Url        = "https://www.instagram.com/gr_prospect_$n/"
        Title      = "(@gr_prospect_$n) Instagram"
        VisitCount = (Get-GrRandom -Min 1 -Max 9)
        LastVisit  = (New-GrDate -Start ([datetime]'2026-03-15') -End ([datetime]'2026-04-17')).ToString('yyyy-MM-dd') + (' {0:00}:{1:00}:00' -f (Get-GrRandom -Min 9 -Max 20), (Get-GrRandom -Min 0 -Max 60))
    })
}
$ChromeUrlHistory_Agent02 = $ChromeUrlHistory_Agent02.ToArray()

# Manager (Edge): banking, Telegram web, admin, remote access.
$ChromeUrlHistory_Manager = @(
    @{ Url='https://web.telegram.org/';                          Title='Telegram Web';                   VisitCount=95; LastVisit='2026-04-17 19:50:00' },
    @{ Url='https://netbanking.hdfcbank.com/netbanking/';        Title='HDFC NetBanking';                VisitCount=41; LastVisit='2026-04-17 18:00:00' },
    @{ Url='https://infinity.icicibank.com/';                    Title='ICICI Internet Banking';         VisitCount=33; LastVisit='2026-04-17 17:30:00' },
    @{ Url='https://www.axisbank.com/netbanking';                Title='Axis Bank NetBanking';           VisitCount=22; LastVisit='2026-04-16 16:20:00' },
    @{ Url='https://netbanking.kotak.com/';                      Title='Kotak NetBanking';               VisitCount=18; LastVisit='2026-04-16 15:10:00' },
    @{ Url='https://retail.onlinesbi.sbi/';                      Title='SBI Internet Banking';           VisitCount=20; LastVisit='2026-04-16 14:00:00' },
    @{ Url='https://www.yesbank.in/';                            Title='Yes Bank';                       VisitCount=12; LastVisit='2026-04-15 13:00:00' },
    @{ Url='https://goldenreturns.example/admin';               Title='Golden Returns | Admin';         VisitCount=77; LastVisit='2026-04-17 19:55:00' },
    @{ Url='https://goldenreturns.example/admin/payouts';       Title='Golden Returns | Payouts';       VisitCount=49; LastVisit='2026-04-17 19:40:00' },
    @{ Url='https://goldenreturns.example/admin/reports';       Title='Golden Returns | Reports';       VisitCount=31; LastVisit='2026-04-17 18:45:00' },
    @{ Url='https://anydesk.com/en';                            Title='AnyDesk';                        VisitCount=15; LastVisit='2026-04-17 11:00:00' },
    @{ Url='https://download.anydesk.com/';                     Title='AnyDesk Download';               VisitCount=4;  LastVisit='2026-04-10 09:00:00' },
    @{ Url='https://web.telegram.org/a/#-100123456789';         Title='GR Ops (Telegram)';              VisitCount=58; LastVisit='2026-04-17 19:52:00' },
    @{ Url='https://t.me/gr_daily_collect';                     Title='GR Daily Collect (Telegram)';    VisitCount=26; LastVisit='2026-04-17 18:10:00' },
    @{ Url='https://mail.google.com/mail/u/0/';                 Title='Gmail';                          VisitCount=44; LastVisit='2026-04-17 17:15:00' },
    @{ Url='https://drive.google.com/drive/u/0/folders/1AB_GRcollect'; Title='GR Collections - Google Drive'; VisitCount=21; LastVisit='2026-04-17 16:00:00' },
    @{ Url='https://www.google.com/search?q=hawala+transfer+limit';     Title='Google Search';          VisitCount=3;  LastVisit='2026-04-15 22:00:00' },
    @{ Url='https://www.google.com/search?q=shell+company+registration+india'; Title='Google Search';   VisitCount=2;  LastVisit='2026-04-14 21:30:00' },
    @{ Url='https://goldenreturns.example/admin/closers';      Title='Golden Returns | Closers';       VisitCount=28; LastVisit='2026-04-17 15:00:00' },
    @{ Url='https://goldenreturns.example/admin/export?type=ledger'; Title='Golden Returns | Export';  VisitCount=6;  LastVisit='2026-04-17 19:45:00' }
)

# ------------------------------------------------------------------------------
# Final library load log line.
# ------------------------------------------------------------------------------
Write-SetupLog ("New-FakeData.ps1 loaded: {0} victims, {1} leads, {2} transactions, {3} call logs (seed={4})." -f `
    $VictimData.Count, $LeadData.Count, $TransactionData.Count, $CallLogData.Count, $RANDOM_SEED)
