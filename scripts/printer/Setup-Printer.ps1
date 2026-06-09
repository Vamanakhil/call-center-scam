<#
================================================================================
  Setup-Printer.ps1  --  PRINTER artefact generator
  "Golden Returns Wealth Management" cyber-forensics training lab.

  Role    : HP LaserJet Pro M428fdw shared network printer
  IP      : 192.168.10.30
  Share   : \\<server>\Spool

  *** SYNTHETIC TRAINING DATA ONLY ***
  All names, document names, and content are entirely fictional and
  machine-generated for an isolated DSP forensics training exercise.
  Any resemblance to real persons or entities is purely coincidental.

  Requirements : PowerShell 5.1, .NET 4.x, Windows 10.
                 No external modules. No internet required.
                 Dot-sourced by 00-Master-Setup.ps1 which may have already
                 loaded shared\New-FakeData.ps1.
================================================================================
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Guard: dot-source shared library only when running standalone.
if (-not (Get-Variable -Name 'VictimData' -Scope Global -ErrorAction SilentlyContinue)) {
    . "$PSScriptRoot\..\shared\New-FakeData.ps1"
}

# ---------------------------------------------------------------------------
# Helper: build a minimal valid PDF-1.4 file with computed xref offsets.
# Uses ASCII encoding throughout so byte offsets are predictable.
# ---------------------------------------------------------------------------
function New-TrainingPdf {
    param(
        [string]$OutPath,
        [string]$Content
    )

    # Strip any non-ASCII-printable characters so the PDF stream stays clean.
    $safe = ($Content -replace '[^\x20-\x7E]', '?')

    # Escape PDF literal-string special characters: backslash, open/close paren.
    $pdfEscaped = $safe -replace '\\', '\\' -replace '\(', '\(' -replace '\)', '\)'

    # Content stream placed inside obj 4.
    $stream    = "BT /F1 9 Tf 40 750 Td ($pdfEscaped) Tj ET"
    $streamLen = [System.Text.Encoding]::ASCII.GetByteCount($stream)

    # Build each object using CRLF line endings (native on Windows).
    $NL   = "`r`n"
    $enc  = [System.Text.Encoding]::ASCII

    $hdr  = "%PDF-1.4$NL"
    $o1   = "1 0 obj$NL<< /Type /Catalog /Pages 2 0 R >>$NL" + "endobj$NL"
    $o2   = "2 0 obj$NL<< /Type /Pages /Kids [3 0 R] /Count 1 >>$NL" + "endobj$NL"
    $o3   = "3 0 obj$NL" +
            "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792]$NL" +
            "   /Contents 4 0 R$NL" +
            "   /Resources << /Font << /F1 << /Type /Font /Subtype /Type1 /BaseFont /Helvetica >> >> >> >>$NL" +
            "endobj$NL"
    $o4   = "4 0 obj$NL<< /Length $streamLen >>$NL" +
            "stream$NL" +
            "$stream$NL" +
            "endstream$NL" +
            "endobj$NL"

    # Compute byte offsets for the cross-reference table.
    $off1    = $enc.GetByteCount($hdr)
    $off2    = $off1 + $enc.GetByteCount($o1)
    $off3    = $off2 + $enc.GetByteCount($o2)
    $off4    = $off3 + $enc.GetByteCount($o3)
    $xrefPos = $off4 + $enc.GetByteCount($o4)

    $xref = "xref$NL" +
            "0 5$NL" +
            "0000000000 65535 f $NL" +
            ('{0:D10} 00000 n ' -f $off1) + $NL +
            ('{0:D10} 00000 n ' -f $off2) + $NL +
            ('{0:D10} 00000 n ' -f $off3) + $NL +
            ('{0:D10} 00000 n ' -f $off4) + $NL

    $trailer = "trailer$NL<< /Size 5 /Root 1 0 R >>$NL" +
               "startxref$NL$xrefPos$NL%%EOF$NL"

    $pdfText = $hdr + $o1 + $o2 + $o3 + $o4 + $xref + $trailer

    $outDir = Split-Path -Parent $OutPath
    if ($outDir -and -not (Test-Path -LiteralPath $outDir)) {
        New-Item -ItemType Directory -Path $outDir -Force | Out-Null
    }

    [System.IO.File]::WriteAllBytes($OutPath, $enc.GetBytes($pdfText))
}

# ---------------------------------------------------------------------------
# Invoke-RoleSetup  --  creates all PRINTER evidence artefacts.
# ---------------------------------------------------------------------------
function Invoke-RoleSetup {
    <#
        Returns @{ Role='PRINTER'; FilesCreated=N; Errors=@() }
    #>

    $role         = 'PRINTER'
    $spoolDir     = "$env:SystemDrive\GR_LabAssets\PrinterSpool"
    $filesCreated = 0
    $errors       = [System.Collections.Generic.List[string]]::new()

    Write-SetupLog "[$role] Invoke-RoleSetup starting — spool dir: $spoolDir"

    # ------------------------------------------------------------------
    # Artefact 1: Spool directory + SMB share
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] Artefact 1: Create spool directory and SMB share"
    try {
        New-DirectoryIfMissing $spoolDir

        # Create (or replace) the Windows SMB share.
        # net share returns non-zero if the share already exists; handle silently.
        $shareArgs = "share `"Spool=$spoolDir`" /REMARK:`"Printer Spool`" /GRANT:Everyone,FULL"
        & cmd.exe /c "net $shareArgs 2>nul" | Out-Null
        if ($LASTEXITCODE -ne 0) {
            # Share already exists — delete and recreate.
            & cmd.exe /c "net share Spool /DELETE /YES 2>nul" | Out-Null
            & cmd.exe /c "net $shareArgs 2>nul" | Out-Null
        }
        Write-SetupLog "[$role] SMB share 'Spool' created/verified for $spoolDir"
    } catch {
        $msg = "[$role] Artefact 1 FAILED (SMB share): $($_.Exception.Message)"
        Write-SetupLog $msg 'WARN'
        $errors.Add($msg)
        # Non-fatal: the directory itself is sufficient for evidence collection.
    }

    # ------------------------------------------------------------------
    # Artefact 2: 18 PDF files
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] Artefact 2: Creating 18 PDF files in $spoolDir"

    $pdfFiles = @(
        @{ Name = 'Daily_Collection_2026-04-17.pdf'
           Text = 'Daily Collection Report - Apr 17 2026 - Total: Rs 4,53,500 - CONFIDENTIAL' },
        @{ Name = 'Daily_Collection_2026-04-16.pdf'
           Text = 'Daily Collection Report - Apr 16 2026 - Total: Rs 3,87,200 - CONFIDENTIAL' },
        @{ Name = 'Daily_Collection_2026-04-15.pdf'
           Text = 'Daily Collection Report - Apr 15 2026 - Total: Rs 5,12,000 - CONFIDENTIAL' },
        @{ Name = 'Mule_Accounts_Q4.pdf'
           Text = 'Mule Account Rotation Q4 2026 - CONFIDENTIAL - HDFC XXXXXX4242 ICICI XXXXXX9191 Axis XXXXXX7720' },
        @{ Name = 'Victim_List_Top100.pdf'
           Text = 'Golden Returns - Top 100 Victims by Amount - April 2026 - INTERNAL USE ONLY' },
        @{ Name = 'Bonus_Structure_Apr2026.pdf'
           Text = 'Agent Bonus Structure April 2026 - Rahul 5pct closing bonus - Amit 3pct call bonus' },
        @{ Name = 'Script_v3_Final.pdf'
           Text = 'Approved Call Script Version 3 - SEBI Objection Handling - For Agent Use Only' },
        @{ Name = 'UPI_Summary_Apr1_15.pdf'
           Text = 'UPI Transaction Summary Apr 1-15 2026 - Total Received: Rs 2,14,50,000 - 6 accounts' },
        @{ Name = 'Investor_Presentation_2026.pdf'
           Text = 'Golden Returns Wealth Management - Investor Presentation 2026 - 8pct guaranteed weekly returns' },
        @{ Name = 'Daily_Collection_2026-04-14.pdf'
           Text = 'Daily Collection Report - Apr 14 2026 - Total: Rs 4,21,800' },
        @{ Name = 'Daily_Collection_2026-04-13.pdf'
           Text = 'Daily Collection Report - Apr 13 2026 - Total: Rs 3,95,400' },
        @{ Name = 'Daily_Collection_2026-04-12.pdf'
           Text = 'Daily Collection Report - Apr 12 2026 - Total: Rs 4,67,100' },
        @{ Name = 'Lead_Assignment_Apr17.pdf'
           Text = 'Lead Assignment Sheet April 17 2026 - 47 new HOT leads assigned' },
        @{ Name = 'Mule_Account_Usage_Apr.pdf'
           Text = 'Mule Account Usage Report April 2026 - Transactions per account' },
        @{ Name = 'Call_Recordings_Upload_Log.pdf'
           Text = 'Call Recording Upload Log - CRM-SERVER uploads - 891 files - Last: 2026-04-17' },
        @{ Name = 'Weekly_Target_Apr14_20.pdf'
           Text = 'Weekly Targets Apr 14-20 2026 - Floor target: Rs 25L per week per agent' },
        @{ Name = 'Telegram_Channel_Guide.pdf'
           Text = 'Telegram Channel Setup Guide - t.me/gr_daily_collect - Daily report format - DO NOT SHARE' },
        @{ Name = 'VeraCrypt_Password_Note.pdf'
           Text = 'VeraCrypt vault password: Gr@Vault2026! - Change monthly - Arjun only' }
    )

    foreach ($pdf in $pdfFiles) {
        $pdfPath = Join-Path $spoolDir $pdf.Name
        try {
            Write-SetupLog "[$role] Creating PDF: $($pdf.Name)"
            New-TrainingPdf -OutPath $pdfPath -Content $pdf.Text
            Add-HashRecord -FilePath $pdfPath -Role $role
            $filesCreated++
            Write-SetupLog "[$role] Created PDF: $($pdf.Name)"
        } catch {
            $msg = "[$role] Artefact 2 FAILED ($($pdf.Name)): $($_.Exception.Message)"
            Write-SetupLog $msg 'ERROR'
            $errors.Add($msg)
        }
    }

    # ------------------------------------------------------------------
    # Artefact 3: Printer job log
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] Artefact 3: printer_job_log.txt"
    try {
        $logPath = Join-Path $spoolDir 'printer_job_log.txt'
        New-DirectoryIfMissing (Split-Path -Parent $logPath)

        $logContent = @'
HP LaserJet Pro MFP M428fdw - Job History
IP: 192.168.10.30 | Model: HP LaserJet Pro M428fdw | Serial: VNB3J23456

Job | Date       | Time  | User     | Document                           | Pages | Status
----|------------|-------|----------|------------------------------------|-------|-------
032 | 2026-04-17 | 18:44 | arjun.m  | Mule_Accounts_Q4.pdf               | 2     | Printed
031 | 2026-04-17 | 17:22 | arjun.m  | Daily_Collection_2026-04-17.pdf    | 1     | Printed
030 | 2026-04-17 | 14:11 | sneha.i  | Pending_Payments_Apr17.txt         | 1     | Printed
029 | 2026-04-17 | 11:05 | rahul.s  | hot_leads_today.txt                | 1     | Printed
028 | 2026-04-16 | 19:33 | arjun.m  | Daily_Collection_2026-04-16.pdf    | 1     | Printed
027 | 2026-04-16 | 16:44 | rahul.s  | Script_v3_Final.pdf                | 5     | Printed
026 | 2026-04-16 | 14:22 | arjun.m  | Victim_List_Top100.pdf             | 8     | Printed
025 | 2026-04-15 | 20:11 | arjun.m  | Daily_Collection_2026-04-15.pdf    | 1     | Printed
024 | 2026-04-15 | 17:55 | arjun.m  | UPI_Summary_Apr1_15.pdf            | 3     | Printed
023 | 2026-04-15 | 15:30 | sneha.i  | UPI_Screenshots_Summary.docx       | 4     | Printed
022 | 2026-04-15 | 11:22 | vikas.n  | Network_Diagram.pdf                | 1     | Printed
021 | 2026-04-14 | 19:45 | arjun.m  | Daily_Collection_2026-04-14.pdf    | 1     | Printed
020 | 2026-04-14 | 17:11 | rahul.s  | Bonus_Structure_Apr2026.pdf        | 2     | Printed
019 | 2026-04-14 | 14:00 | arjun.m  | Mule_Account_Usage_Apr.pdf         | 2     | Printed
018 | 2026-04-13 | 20:02 | arjun.m  | Daily_Collection_2026-04-13.pdf    | 1     | Printed
017 | 2026-04-13 | 16:33 | priya.v  | leads_apr2026_summary.xlsx         | 3     | Printed
016 | 2026-04-13 | 13:11 | rahul.s  | closer_script_v3.docx              | 12    | Printed
015 | 2026-04-12 | 19:44 | arjun.m  | Daily_Collection_2026-04-12.pdf    | 1     | Printed
014 | 2026-04-12 | 16:55 | arjun.m  | Telegram_Channel_Guide.pdf         | 1     | Printed
013 | 2026-04-12 | 14:22 | vikas.n  | server_config_notes.txt            | 2     | Printed
012 | 2026-04-11 | 19:30 | arjun.m  | Weekly_Target_Apr14_20.pdf         | 1     | Printed
011 | 2026-04-11 | 17:00 | sneha.i  | payment_followup_template.docx     | 1     | Printed
010 | 2026-04-11 | 14:11 | amit.p   | Call_Recordings_Upload_Log.pdf     | 1     | Printed
009 | 2026-04-10 | 20:22 | arjun.m  | Investor_Presentation_2026.pdf     | 12    | Printed
008 | 2026-04-10 | 17:33 | arjun.m  | Lead_Assignment_Apr17.pdf          | 2     | Printed
007 | 2026-04-09 | 19:11 | arjun.m  | VeraCrypt_Password_Note.pdf        | 1     | Printed
006 | 2026-04-09 | 15:44 | rahul.s  | victim_call_notes_week14.docx      | 3     | Printed
005 | 2026-04-08 | 20:00 | arjun.m  | Mule_Accounts_Q4.pdf               | 2     | Printed
004 | 2026-04-08 | 16:22 | priya.v  | fb_audience_export_summary.pdf     | 2     | Printed
003 | 2026-04-07 | 19:55 | arjun.m  | Daily_Collection_2026-04-07.pdf    | 1     | Printed
002 | 2026-04-07 | 14:11 | vikas.n  | stub_ps1_documentation.pdf         | 2     | Printed
001 | 2026-04-06 | 11:00 | arjun.m  | Bonus_Structure_Apr2026.pdf        | 2     | Printed
'@

        [System.IO.File]::WriteAllText($logPath, $logContent, [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $logPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: printer_job_log.txt"
    } catch {
        $msg = "[$role] Artefact 3 FAILED (printer_job_log.txt): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # Summary
    # ------------------------------------------------------------------
    $status = if ($errors.Count -eq 0) { 'DONE' } elseif ($errors.Count -le 2) { 'DONE_WITH_CONCERNS' } else { 'NEEDS_CONTEXT' }
    Write-SetupLog ("[$role] Invoke-RoleSetup complete — files created: $filesCreated, errors: $($errors.Count) — status: $status")

    return @{
        Role         = $role
        FilesCreated = $filesCreated
        Errors       = $errors.ToArray()
    }
}
