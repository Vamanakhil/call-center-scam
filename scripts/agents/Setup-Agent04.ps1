<#
================================================================================
  Setup-Agent04.ps1  --  AGENT-04 artefact generator
  "Golden Returns Wealth Management" cyber-forensics training lab.

  Role    : Sneha Iyer -- Payment Chaser
  Username: sneha.i
  Profile : $env:SystemDrive\Users\sneha.i
  IP      : 192.168.10.44

  *** SYNTHETIC TRAINING DATA ONLY ***
  All names, phones, accounts, and content are entirely fictional and
  machine-generated for an isolated DSP forensics training exercise.
  Any resemblance to real persons or entities is purely coincidental.

  Requirements : PowerShell 5.1, .NET 4.x, Windows 10.
                 Dot-sourced by 00-Master-Setup.ps1 which has already
                 loaded shared\New-FakeData.ps1.
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
        Creates all AGENT-04 evidence artefacts.
        Returns @{ Role='AGENT-04'; FilesCreated=N; Errors=@() }
    #>

    $role        = 'AGENT-04'
    $profileBase = "$env:SystemDrive\Users\sneha.i"
    $filesCreated = 0
    $errors       = [System.Collections.Generic.List[string]]::new()

    Write-SetupLog "[$role] Invoke-RoleSetup starting -- profile: $profileBase"

    # ==================================================================
    # 1. UPI Screenshots folder (312 PNG stubs)
    # ==================================================================
    Write-SetupLog "[$role] Step 1: UPI_Screenshots PNGs"
    try {
        $upiDir = "$profileBase\Desktop\UPI_Screenshots"
        New-DirectoryIfMissing $upiDir

        # Collect CONFIRMED transactions.
        $confirmedTxns = @($TransactionData | Where-Object { $_.Status -eq 'CONFIRMED' })

        $pngPaths = [System.Collections.Generic.List[string]]::new()

        foreach ($txn in $confirmedTxns) {
            if ($pngPaths.Count -ge 312) { break }
            $dateStr = ($txn.TxnDate -replace '-', '')
            $fname   = "upi_${dateStr}_$($txn.TxnId).png"
            $pngPaths.Add((Join-Path $upiDir $fname))
        }

        # Pad to 312 with random-looking filenames if needed.
        while ($pngPaths.Count -lt 312) {
            $randDay  = Get-Random -Minimum 0 -Maximum 9
            $randId   = Get-Random -Minimum 1000 -Maximum 9999
            $fname    = "upi_2026041${randDay}_${randId}.png"
            $pngPaths.Add((Join-Path $upiDir $fname))
        }

        $firstPng = $true
        foreach ($pngPath in $pngPaths) {
            try {
                New-UpiPngStub -OutPath $pngPath
                if ($firstPng) {
                    Add-HashRecord -FilePath $pngPath -Role $role
                    Write-SetupLog "[$role] Hash recorded for first PNG: $pngPath (total 312 PNGs being created)"
                    $firstPng = $false
                }
                $filesCreated++
            } catch {
                $msg = "[$role] Step 1: Failed to create PNG '$pngPath': $($_.Exception.Message)"
                Write-SetupLog $msg 'WARN'
                $errors.Add($msg)
            }
        }

        Write-SetupLog "[$role] Step 1 complete: $($pngPaths.Count) UPI PNG stubs created in $upiDir"
    } catch {
        $msg = "[$role] Step 1 FAILED (UPI_Screenshots): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 2. Documents\payment_followup_template.docx
    # ==================================================================
    Write-SetupLog "[$role] Step 2: payment_followup_template.docx"
    try {
        $docsDir = "$profileBase\Documents"
        New-DirectoryIfMissing $docsDir

        $followupBody = @'
Golden Returns Wealth Management -- Payment Follow-Up Template

Dear [VICTIM NAME],

We noticed your investment of Rs [AMOUNT] is still showing as "pending" in our system.

To confirm your position and lock in today's 6.5% weekly return, kindly complete the payment via:

UPI ID: [MULE_UPI_ID]
Account Name: [MULE_NAME]
Amount: Rs [AMOUNT]

IMPORTANT: Please complete within 2 hours to avoid losing your slot. Our SEBI compliance window closes at 6 PM today.

Once payment is confirmed, your Golden Returns dashboard will show your position within 30 minutes.

For any issues, message us on Telegram: @goldsupport_real

Regards,
Compliance Team
Golden Returns Wealth Management
'@

        $docxPath = "$docsDir\payment_followup_template.docx"
        New-MinimalDocx -OutPath $docxPath -BodyText $followupBody
        Add-HashRecord -FilePath $docxPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $docxPath"
    } catch {
        $msg = "[$role] Step 2 FAILED (payment_followup_template.docx): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 3. Telegram Desktop tdata folder (zeroed-out deleted session)
    # ==================================================================
    Write-SetupLog "[$role] Step 3: Telegram Desktop tdata"
    try {
        $tdataBase = "$profileBase\AppData\Roaming\Telegram Desktop\tdata"
        New-DirectoryIfMissing $tdataBase

        # Helper: write zero-filled file of given size.
        function New-ZeroFile {
            param([string]$Path, [int]$SizeBytes)
            $dir = Split-Path -Parent $Path
            if ($dir -and -not (Test-Path -LiteralPath $dir)) {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
            }
            $zeroBytes = New-Object byte[] $SizeBytes
            [System.IO.File]::WriteAllBytes($Path, $zeroBytes)
        }

        # D877F783D5D3EF8C subfolder -- 4096-byte zero files.
        $subDir1 = "$tdataBase\D877F783D5D3EF8C"
        New-DirectoryIfMissing $subDir1
        foreach ($fname in @('0', '1', 's', 'maps')) {
            $fpath = Join-Path $subDir1 $fname
            try {
                New-ZeroFile -Path $fpath -SizeBytes 4096
                $filesCreated++
                Write-SetupLog "[$role] Created zeroed tdata file: $fpath"
            } catch {
                $msg = "[$role] Step 3: Failed to create '$fpath': $($_.Exception.Message)"
                Write-SetupLog $msg 'WARN'
                $errors.Add($msg)
            }
        }

        # D877F783D5D3EF8C1 subfolder -- 4096-byte zero files.
        $subDir2 = "$tdataBase\D877F783D5D3EF8C1"
        New-DirectoryIfMissing $subDir2
        foreach ($fname in @('0', '1')) {
            $fpath = Join-Path $subDir2 $fname
            try {
                New-ZeroFile -Path $fpath -SizeBytes 4096
                $filesCreated++
                Write-SetupLog "[$role] Created zeroed tdata file: $fpath"
            } catch {
                $msg = "[$role] Step 3: Failed to create '$fpath': $($_.Exception.Message)"
                Write-SetupLog $msg 'WARN'
                $errors.Add($msg)
            }
        }

        # Root tdata files.
        $rootFiles = @(
            @{ Name = 'settings';   Size = 1024 },
            @{ Name = 'settings0';  Size = 1024 },
            @{ Name = 'key_datas';  Size = 256  }
        )
        foreach ($rf in $rootFiles) {
            $fpath = Join-Path $tdataBase $rf.Name
            try {
                New-ZeroFile -Path $fpath -SizeBytes $rf.Size
                $filesCreated++
                Write-SetupLog "[$role] Created zeroed tdata file: $fpath"
            } catch {
                $msg = "[$role] Step 3: Failed to create '$fpath': $($_.Exception.Message)"
                Write-SetupLog $msg 'WARN'
                $errors.Add($msg)
            }
        }

        # media_cache subfolder -- empty directory.
        $mediaCacheDir = "$tdataBase\media_cache"
        New-DirectoryIfMissing $mediaCacheDir
        Write-SetupLog "[$role] Created empty media_cache dir: $mediaCacheDir"

        # Hash the first zero file as representative artefact.
        $firstZeroFile = Join-Path $subDir1 '0'
        if (Test-Path -LiteralPath $firstZeroFile) {
            Add-HashRecord -FilePath $firstZeroFile -Role $role
        }

        Write-SetupLog "[$role] Step 3 complete: Telegram tdata structure created under $tdataBase"
    } catch {
        $msg = "[$role] Step 3 FAILED (Telegram tdata): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 4. Recycle Bin entry: support_chat_export.html
    # ==================================================================
    Write-SetupLog "[$role] Step 4: Recycle Bin support_chat_export.html"
    try {
        $docsDir = "$profileBase\Documents"
        New-DirectoryIfMissing $docsDir

        # Pull three victim records for the support chat scenario.
        $chatVictims = @($VictimData | Select-Object -First 3)

        $v1 = $chatVictims[0]
        $v2 = $chatVictims[1]
        $v3 = $chatVictims[2]

        $v1Name = if ($v1) { $v1.Name } else { 'Rajesh Kumar' }
        $v2Name = if ($v2) { $v2.Name } else { 'Priya Singh' }
        $v3Name = if ($v3) { $v3.Name } else { 'Mohan Patel' }

        $v1Amt = if ($v1) { '{0:N0}' -f $v1.AmountPaid } else { '50,000' }
        $v2Amt = if ($v2) { '{0:N0}' -f $v2.AmountPaid } else { '25,000' }
        $v3Amt = if ($v3) { '{0:N0}' -f $v3.AmountPaid } else { '75,000' }

        $chatHtml = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Support Chat Export -- Golden Returns</title>
<style>
  body { font-family: Arial, sans-serif; background: #e5ddd5; margin: 0; padding: 0; }
  h1 { background: #075E54; color: white; margin: 0; padding: 14px 20px; font-size: 18px; }
  .section-header { background: #128C7E; color: white; padding: 8px 16px; font-size: 14px; font-weight: bold; margin-top: 0; }
  .chat-container { max-width: 720px; margin: 0 auto; padding: 12px 16px; }
  .msg { margin: 6px 0; display: flex; }
  .msg.sent { justify-content: flex-end; }
  .msg.received { justify-content: flex-start; }
  .bubble { max-width: 68%; padding: 7px 11px; border-radius: 7px; font-size: 13px; line-height: 1.45; }
  .sent .bubble { background: #dcf8c6; }
  .received .bubble { background: #ffffff; }
  .meta { font-size: 11px; color: #888; margin-top: 3px; text-align: right; }
  .sender { font-weight: bold; font-size: 12px; color: #128C7E; margin-bottom: 2px; }
  .date-divider { text-align: center; margin: 12px 0; }
  .date-divider span { background: #e1f3fb; padding: 3px 10px; border-radius: 7px; font-size: 11px; color: #555; }
  hr { border: none; border-top: 3px solid #ccc; margin: 24px 0; }
</style>
</head>
<body>
<h1>Golden Returns Wealth Management -- Support Chat Export</h1>
<p style="padding:8px 20px;background:#fffbe6;font-size:12px;color:#555;">
  Exported: 2026-04-17 19:45 IST &nbsp;|&nbsp; Agent: Sneha Iyer (sneha.i) &nbsp;|&nbsp;
  Channels: Telegram / WhatsApp &nbsp;|&nbsp; 3 conversations
</p>

<!-- ============================================================ -->
<div class="section-header">Conversation 1 -- $v1Name (VICTIM-001)</div>
<div class="chat-container">

  <div class="date-divider"><span>14 April 2026</span></div>

  <div class="msg received">
    <div class="bubble">
      <div class="sender">$v1Name</div>
      Hello, I transferred Rs $v1Amt last week. When will I get my returns? The dashboard is not showing anything.
      <div class="meta">11:03 [v]</div>
    </div>
  </div>

  <div class="msg sent">
    <div class="bubble">
      <div class="sender">Sneha (GR Support)</div>
      Hello sir! Thank you for your patience. Your payment is under compliance review as per SEBI guidelines. This is a standard process that takes 5-7 working days. Your dashboard will update automatically once the compliance check is complete.
      <div class="meta">11:15 [v][v]</div>
    </div>
  </div>

  <div class="date-divider"><span>15 April 2026</span></div>

  <div class="msg received">
    <div class="bubble">
      <div class="sender">$v1Name</div>
      It has been more than a week now. I want my refund of Rs $v1Amt. Please process it immediately.
      <div class="meta">09:42 [v]</div>
    </div>
  </div>

  <div class="msg sent">
    <div class="bubble">
      <div class="sender">Sneha (GR Support)</div>
      Sir, I completely understand your concern. Your case has been escalated to our Senior Compliance Officer. Refunds require a 10-working-day cooling period as mandated by our fund structure. I assure you this will be processed by 25th April. Please do not worry.
      <div class="meta">10:08 [v][v]</div>
    </div>
  </div>

  <div class="msg received">
    <div class="bubble">
      <div class="sender">$v1Name</div>
      This is fraud! I am going to file a complaint with cyber cell if I don't get my money by tomorrow.
      <div class="meta">10:22 [v]</div>
    </div>
  </div>

  <div class="msg sent">
    <div class="bubble">
      <div class="sender">Sneha (GR Support)</div>
      Sir, please do not take any hasty steps. Filing a complaint during the compliance window will freeze your account and delay your refund further -- it is a known issue with SEBI's system. Our legal team will call you by 6 PM today to explain the process. Please stay calm and trust us.
      <div class="meta">10:35 [v][v]</div>
    </div>
  </div>

  <div class="date-divider"><span>17 April 2026</span></div>

  <div class="msg received">
    <div class="bubble">
      <div class="sender">$v1Name</div>
      Nobody called me. I want my Rs $v1Amt back NOW. This is cheating.
      <div class="meta">15:10 [v]</div>
    </div>
  </div>

  <div class="msg sent">
    <div class="bubble">
      <div class="sender">Sneha (GR Support)</div>
      Sir, I sincerely apologise. There was an internal escalation and your case is now marked PRIORITY. Our accounts team will process the transfer by end of business today. Please share your bank account details again so we can initiate the NEFT.
      <div class="meta">15:28 [v][v]</div>
    </div>
  </div>

</div>
<hr>

<!-- ============================================================ -->
<div class="section-header">Conversation 2 -- $v2Name (VICTIM-002)</div>
<div class="chat-container">

  <div class="date-divider"><span>13 April 2026</span></div>

  <div class="msg received">
    <div class="bubble">
      <div class="sender">$v2Name</div>
      Hi, I paid Rs $v2Amt as instructed. My portfolio still shows zero. Can you help?
      <div class="meta">14:55 [v]</div>
    </div>
  </div>

  <div class="msg sent">
    <div class="bubble">
      <div class="sender">Sneha (GR Support)</div>
      Hello ma'am! Your payment has been received. There is a 48-hour activation window for new accounts due to KYC verification. Your dashboard will show your balance and the first weekly return of 6.5% by 15th April. Congratulations on joining Golden Returns!
      <div class="meta">15:03 [v][v]</div>
    </div>
  </div>

  <div class="date-divider"><span>16 April 2026</span></div>

  <div class="msg received">
    <div class="bubble">
      <div class="sender">$v2Name</div>
      It's been 3 days and still nothing. My cousin says this looks like a scam. Please give me a receipt or refund my Rs $v2Amt.
      <div class="meta">12:30 [v]</div>
    </div>
  </div>

  <div class="msg sent">
    <div class="bubble">
      <div class="sender">Sneha (GR Support)</div>
      Ma'am, I understand your concern. Please do not listen to people who are not familiar with regulated investment funds. I am attaching your payment confirmation. Your account is active -- there was a display bug on the dashboard which our tech team fixed this morning. Please log in again and you will see your balance.
      <div class="meta">12:48 [v][v]</div>
    </div>
  </div>

  <div class="msg sent">
    <div class="bubble">
      <div class="sender">Sneha (GR Support)</div>
       GR_PaymentConfirmation_VICTIM002.pdf
      <div class="meta">12:49 [v][v]</div>
    </div>
  </div>

  <div class="msg received">
    <div class="bubble">
      <div class="sender">$v2Name</div>
      I still can't login. The website is not loading. Something is wrong.
      <div class="meta">17:20 [v]</div>
    </div>
  </div>

  <div class="msg sent">
    <div class="bubble">
      <div class="sender">Sneha (GR Support)</div>
      Ma'am, our server is under scheduled maintenance until 10 PM tonight. This is a routine upgrade. Please try after 10 PM. Everything is fine and your investment is completely safe.
      <div class="meta">17:33 [v][v]</div>
    </div>
  </div>

</div>
<hr>

<!-- ============================================================ -->
<div class="section-header">Conversation 3 -- $v3Name (VICTIM-003)</div>
<div class="chat-container">

  <div class="date-divider"><span>12 April 2026</span></div>

  <div class="msg received">
    <div class="bubble">
      <div class="sender">$v3Name</div>
      Good evening. Rahul told me to contact this number for any payment issues. I paid Rs $v3Amt yesterday but I have not received any confirmation email.
      <div class="meta">18:45 [v]</div>
    </div>
  </div>

  <div class="msg sent">
    <div class="bubble">
      <div class="sender">Sneha (GR Support)</div>
      Good evening sir! Yes, Rahul informed me. Your payment of Rs $v3Amt has been received and logged in our CRM. Confirmation emails are sent in batches at 9 AM and 5 PM daily. You will receive it tomorrow morning. Your portfolio ID is GR-003-APR26.
      <div class="meta">18:57 [v][v]</div>
    </div>
  </div>

  <div class="date-divider"><span>15 April 2026</span></div>

  <div class="msg received">
    <div class="bubble">
      <div class="sender">$v3Name</div>
      I have not received any email, no dashboard access, nothing. 3 days have passed. Where is my Rs $v3Amt? This is very unprofessional.
      <div class="meta">11:00 [v]</div>
    </div>
  </div>

  <div class="msg sent">
    <div class="bubble">
      <div class="sender">Sneha (GR Support)</div>
      Sir, I sincerely apologise for this delay. I have checked your account and there was a technical issue with our email server affecting accounts registered between 10th-13th April. Our IT team is fixing it today. Meanwhile, to show our commitment, we are crediting an additional 0.5% bonus on your investment for the inconvenience. Your Rs $v3Amt is completely safe.
      <div class="meta">11:18 [v][v]</div>
    </div>
  </div>

  <div class="msg received">
    <div class="bubble">
      <div class="sender">$v3Name</div>
      I don't want a bonus. I want my money back. Please process refund for Rs $v3Amt.
      <div class="meta">11:35 [v]</div>
    </div>
  </div>

  <div class="msg sent">
    <div class="bubble">
      <div class="sender">Sneha (GR Support)</div>
      Sir, refund requests are processed only through our official portal once your account is activated. Your account activation is pending one final compliance step. Once that is done (expected within 2 working days), you can submit your refund request directly from the dashboard and it will be processed in 7 working days. I will personally follow up with you on 17th April.
      <div class="meta">11:50 [v][v]</div>
    </div>
  </div>

  <div class="date-divider"><span>17 April 2026</span></div>

  <div class="msg received">
    <div class="bubble">
      <div class="sender">$v3Name</div>
      You said you would follow up. It is 17th April now. I have reported this to the national cyber helpline 1930. Reference: NCCH/2026/0417/8823.
      <div class="meta">14:00 [v]</div>
    </div>
  </div>

  <div class="msg sent">
    <div class="bubble">
      <div class="sender">Sneha (GR Support)</div>
      Sir, I understand. Please do not be alarmed. Our compliance team has already been in touch with the relevant authorities. This will be resolved through proper channels. I am escalating your case to our director immediately. Please do not take any further steps as it may complicate the resolution process.
      <div class="meta">14:22 [v][v]</div>
    </div>
  </div>

</div>

<p style="padding:12px 20px;background:#fff3f3;font-size:12px;color:#c00;border-top:2px solid #f99;">
  [END OF EXPORT] This file was generated for internal review. Handle with care. -- GR Compliance
</p>
</body>
</html>
"@

        # Write HTML to a temp location first.
        $tmpHtmlPath = "$docsDir\support_chat_export.html"
        [System.IO.File]::WriteAllText($tmpHtmlPath, $chatHtml, [System.Text.Encoding]::UTF8)

        # Find or create the Recycle Bin SID directory.
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

        $recycledHtml    = Join-Path $sidDir '$RHTMCHAT.html'
        $recycleInfoFile = Join-Path $sidDir '$IHTMCHAT.html'

        # Move to Recycle Bin.
        Copy-Item -LiteralPath $tmpHtmlPath -Destination $recycledHtml -Force
        Remove-Item -LiteralPath $tmpHtmlPath -Force -ErrorAction SilentlyContinue

        Add-HashRecord -FilePath $recycledHtml -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created recycled file: $recycledHtml"

        # Create the $I metadata file (Windows 10 Recycle Bin format).
        # Structure: magic(8) + file size(8) + deletion FILETIME(8) + char count(4) + path(UTF-16LE, padded)
        $originalPath = "$profileBase\AppData\Local\Temp\support_chat_export.html"
        $pathUtf16    = [System.Text.Encoding]::Unicode.GetBytes($originalPath + "`0")
        $charCount    = [int]($pathUtf16.Length / 2)
        $fileSize     = (Get-Item -LiteralPath $recycledHtml).Length

        $ftEpoch = [datetime]::new(1601, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc)
        $nowFt   = [long](([datetime]::UtcNow - $ftEpoch).TotalSeconds * 10000000)

        $infoBytes = New-Object byte[] 548
        $infoBytes[0] = 0x01
        [System.BitConverter]::GetBytes([long]$fileSize).CopyTo($infoBytes, 8)
        [System.BitConverter]::GetBytes($nowFt).CopyTo($infoBytes, 16)
        [System.BitConverter]::GetBytes($charCount).CopyTo($infoBytes, 24)
        $copyLen = [math]::Min($pathUtf16.Length, 548 - 28)
        [System.Array]::Copy($pathUtf16, 0, $infoBytes, 28, $copyLen)

        [System.IO.File]::WriteAllBytes($recycleInfoFile, $infoBytes)
        Add-HashRecord -FilePath $recycleInfoFile -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created recycle info file: $recycleInfoFile"
    } catch {
        $msg = "[$role] Step 4 FAILED (Recycle Bin support_chat_export.html): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 5. LNK file for Mule_Accounts_Q4.xlsx
    # ==================================================================
    Write-SetupLog "[$role] Step 5: LNK stub Mule_Accounts_Q4.xlsx.lnk"
    try {
        $recentDir = "$profileBase\AppData\Roaming\Microsoft\Windows\Recent"
        New-DirectoryIfMissing $recentDir

        # 76-byte minimal LNK stub.
        # LNK header: magic 4C 00 00 00, CLSID, flags, target attributes, timestamps, etc.
        # FILETIME for 2026-04-17 14:30:00 UTC:
        #   Unix timestamp  = 1776436200
        #   FILETIME offset = 11644473600 (seconds from 1601-01-01 to 1970-01-01)
        #   FILETIME (100ns) = (1776436200 + 11644473600) * 10,000,000 = 134209098000000000
        $fileTime2026 = [long]134209098000000000

        $ftBytes = [System.BitConverter]::GetBytes($fileTime2026)

        # Build 76-byte LNK header (Shell Link Binary File Format, MS-SHLLINK).
        $lnkBytes = New-Object byte[] 76

        # HeaderSize = 0x4C (76)
        $lnkBytes[0]  = 0x4C; $lnkBytes[1]  = 0x00; $lnkBytes[2]  = 0x00; $lnkBytes[3]  = 0x00
        # LinkCLSID = 00021401-0000-0000-C000-000000000046
        $lnkBytes[4]  = 0x01; $lnkBytes[5]  = 0x14; $lnkBytes[6]  = 0x02; $lnkBytes[7]  = 0x00
        $lnkBytes[8]  = 0x00; $lnkBytes[9]  = 0x00; $lnkBytes[10] = 0x00; $lnkBytes[11] = 0x00
        $lnkBytes[12] = 0xC0; $lnkBytes[13] = 0x00; $lnkBytes[14] = 0x00; $lnkBytes[15] = 0x00
        $lnkBytes[16] = 0x00; $lnkBytes[17] = 0x00; $lnkBytes[18] = 0x00; $lnkBytes[19] = 0x46
        # LinkFlags = HasLinkTargetIDList (0x00000001)
        $lnkBytes[20] = 0x01; $lnkBytes[21] = 0x00; $lnkBytes[22] = 0x00; $lnkBytes[23] = 0x00
        # FileAttributes = FILE_ATTRIBUTE_NORMAL (0x00000020)
        $lnkBytes[24] = 0x20; $lnkBytes[25] = 0x00; $lnkBytes[26] = 0x00; $lnkBytes[27] = 0x00
        # CreationTime (8 bytes)
        [System.Array]::Copy($ftBytes, 0, $lnkBytes, 28, 8)
        # AccessTime (8 bytes)
        [System.Array]::Copy($ftBytes, 0, $lnkBytes, 36, 8)
        # WriteTime (8 bytes)
        [System.Array]::Copy($ftBytes, 0, $lnkBytes, 44, 8)
        # FileSize = 0
        $lnkBytes[52] = 0x00; $lnkBytes[53] = 0x00; $lnkBytes[54] = 0x00; $lnkBytes[55] = 0x00
        # IconIndex = 0
        $lnkBytes[56] = 0x00; $lnkBytes[57] = 0x00; $lnkBytes[58] = 0x00; $lnkBytes[59] = 0x00
        # ShowCommand = SW_SHOWNORMAL (0x00000001)
        $lnkBytes[60] = 0x01; $lnkBytes[61] = 0x00; $lnkBytes[62] = 0x00; $lnkBytes[63] = 0x00
        # HotKey = 0
        $lnkBytes[64] = 0x00; $lnkBytes[65] = 0x00
        # Reserved1, Reserved2, Reserved3
        $lnkBytes[66] = 0x00; $lnkBytes[67] = 0x00
        $lnkBytes[68] = 0x00; $lnkBytes[69] = 0x00; $lnkBytes[70] = 0x00; $lnkBytes[71] = 0x00
        $lnkBytes[72] = 0x00; $lnkBytes[73] = 0x00; $lnkBytes[74] = 0x00; $lnkBytes[75] = 0x00

        $lnkPath = "$recentDir\Mule_Accounts_Q4.xlsx.lnk"
        [System.IO.File]::WriteAllBytes($lnkPath, $lnkBytes)
        Add-HashRecord -FilePath $lnkPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created LNK stub: $lnkPath (pointing to \\MANAGER-PC\Manager\Mule_Accounts_Q4.xlsx)"
    } catch {
        $msg = "[$role] Step 5 FAILED (Mule_Accounts_Q4.xlsx.lnk): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 6. Chrome History SQLite
    # ==================================================================
    Write-SetupLog "[$role] Step 6: Chrome History"
    try {
        $chromeDir = "$profileBase\AppData\Local\Google\Chrome\User Data\Default"
        New-DirectoryIfMissing $chromeDir

        # Chrome epoch: microseconds since 1601-01-01 00:00:00 UTC.
        $chromeEpoch = [datetime]::new(1601, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc)

        function ConvertTo-ChromeTime04 {
            param([string]$DateStr)
            try {
                $dt = [datetime]::Parse($DateStr, $null, [System.Globalization.DateTimeStyles]::AssumeLocal)
                $dt = $dt.ToUniversalTime()
                return [long](($dt - $chromeEpoch).TotalSeconds * 1000000)
            } catch {
                return [long]13300000000000000  # fallback: approx Apr 2026
            }
        }

        $snehaUrls = @(
            @{ Url='https://goldenreturns.example/admin/payments'; Title='GR Admin -- Payments';         VisitCount=134 },
            @{ Url='https://t.me/goldsupport_real';                Title='Telegram -- Gold Support';      VisitCount=89  },
            @{ Url='https://t.me/gr_daily_collect';                Title='Telegram -- Daily Collect';     VisitCount=30  },
            @{ Url='https://web.whatsapp.com';                     Title='WhatsApp Web';                 VisitCount=67  },
            @{ Url='https://bhim.upi.com';                         Title='BHIM UPI';                     VisitCount=23  },
            @{ Url='https://netbanking.hdfcbank.com';              Title='HDFC NetBanking';              VisitCount=12  },
            @{ Url='https://192.168.10.100/golden_crm/payments';   Title='CRM -- Payments';               VisitCount=98  },
            @{ Url='https://drive.google.com';                     Title='Google Drive';                 VisitCount=8   }
        )

        $lastVisitTs = ConvertTo-ChromeTime04 -DateStr '2026-04-17 18:30:00'

        $sqlStatements = [System.Collections.Generic.List[string]]::new()
        $sqlStatements.Add("CREATE TABLE urls (id INTEGER PRIMARY KEY, url TEXT, title TEXT, visit_count INTEGER, typed_count INTEGER, last_visit_time INTEGER, hidden INTEGER);")
        $sqlStatements.Add("CREATE TABLE visits (id INTEGER PRIMARY KEY, url INTEGER, visit_time INTEGER, from_visit INTEGER, transition INTEGER, segment_id INTEGER, visit_duration INTEGER);")
        $sqlStatements.Add("CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT);")
        $sqlStatements.Add("INSERT INTO meta VALUES ('version','58');")
        $sqlStatements.Add("INSERT INTO meta VALUES ('last_compatible_version','58');")

        $visitId = 1
        for ($u = 0; $u -lt $snehaUrls.Count; $u++) {
            $row    = $snehaUrls[$u]
            $urlId  = $u + 1
            $urlEsc = $row.Url   -replace "'", "''"
            $titEsc = $row.Title -replace "'", "''"
            $sqlStatements.Add("INSERT INTO urls VALUES ($urlId,'$urlEsc','$titEsc',$($row.VisitCount),0,$lastVisitTs,0);")
            $sqlStatements.Add("INSERT INTO visits VALUES ($visitId,$urlId,$lastVisitTs,0,805306368,0,0);")
            $visitId++
        }

        $historyPath = "$chromeDir\History"
        $ok = New-SqliteDb -DbPath $historyPath -SqlStatements $sqlStatements.ToArray()
        if ($ok) {
            Add-HashRecord -FilePath $historyPath -Role $role
            $filesCreated++
            Write-SetupLog "[$role] Created: $historyPath"
        } else {
            $errors.Add("[$role] Step 6: New-SqliteDb returned false for History (sqlite3 unavailable?)")
        }
    } catch {
        $msg = "[$role] Step 6 FAILED (Chrome History): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 7. Desktop\Pending_Payments_Apr17.txt
    # ==================================================================
    Write-SetupLog "[$role] Step 7: Pending_Payments_Apr17.txt"
    try {
        $desktopDir = "$profileBase\Desktop"
        New-DirectoryIfMissing $desktopDir

        $pendingTxns = @($TransactionData | Where-Object { $_.Status -eq 'PENDING' } | Select-Object -First 10)

        $sb = [System.Text.StringBuilder]::new()
        [void]$sb.AppendLine('Pending Payments -- Apr 17, 2026')
        [void]$sb.AppendLine('=' * 62)
        [void]$sb.AppendLine('Prepared by: Sneha Iyer (sneha.i) -- Payment Chaser, GR Ops')
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine('ACTION REQUIRED: Follow up with each victim before 6 PM today.')
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine('{0,-12} {1,-22} {2,-12} {3}' -f 'VICTIM_ID', 'NAME', 'AMOUNT', 'LAST CONTACT')
        [void]$sb.AppendLine('-' * 62)

        $aprilDays = @(10, 11, 12, 13, 14, 15, 16)
        $aprilDayIdx = 0

        $lineNum = 1
        foreach ($txn in $pendingTxns) {
            $victim = $VictimData | Where-Object { $_.VictimId -eq $txn.VictimId } | Select-Object -First 1
            $vName  = if ($victim) { $victim.Name } else { 'Unknown Victim' }
            $amt    = '{0:N0}' -f $txn.Amount
            $day    = $aprilDays[$aprilDayIdx % $aprilDays.Count]
            $aprilDayIdx++
            [void]$sb.AppendLine(('{0,-12} | {1,-20} | Rs {2,-10} | Last contact: Apr-{3:00}' -f `
                $txn.VictimId, $vName, $amt, $day))
            $lineNum++
        }

        # Pad to 10 entries if fewer than 10 PENDING transactions found.
        $padNames   = @('Suresh Mehta','Kavita Sharma','Ravi Patel','Deepak Nair','Anita Gupta',
                        'Vijay Singh','Meena Reddy','Ashok Joshi','Priti Verma','Sanjay Iyer')
        $padAmounts = @(15000, 25000, 50000, 10000, 75000, 30000, 20000, 45000, 12000, 60000)
        $padIdx = 0
        while ($lineNum -le 10) {
            $day = $aprilDays[$aprilDayIdx % $aprilDays.Count]
            $aprilDayIdx++
            $pName = $padNames[$padIdx % $padNames.Count]
            $pAmt  = '{0:N0}' -f $padAmounts[$padIdx % $padAmounts.Count]
            $pVid  = 'VICTIM-{0:000}' -f (400 + $padIdx)
            [void]$sb.AppendLine(('{0,-12} | {1,-20} | Rs {2,-10} | Last contact: Apr-{3:00}' -f `
                $pVid, $pName, $pAmt, $day))
            $padIdx++
            $lineNum++
        }

        [void]$sb.AppendLine('')
        [void]$sb.AppendLine('--- FOLLOW-UP NOTES ---')
        [void]$sb.AppendLine('Send payment follow-up template (payment_followup_template.docx).')
        [void]$sb.AppendLine('UPI: compliance.gr@upi | Axis Bank -- XXXXXX7720')
        [void]$sb.AppendLine('If no response in 2 hours, escalate to Telegram: @goldsupport_real')
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine('All entries auto-generated from CRM at 09:00 AM today.')

        $pendingPath = "$desktopDir\Pending_Payments_Apr17.txt"
        [System.IO.File]::WriteAllText($pendingPath, $sb.ToString(), [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $pendingPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $pendingPath"
    } catch {
        $msg = "[$role] Step 7 FAILED (Pending_Payments_Apr17.txt): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 8. USBSTOR registry entry -- SanDisk Cruzer Blade
    # ==================================================================
    Write-SetupLog "[$role] Step 8: USBSTOR registry entry"
    try {
        $usbStorBase = 'HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR'
        $usbKey      = 'Disk&Ven_SanDisk&Prod_Cruzer_Blade&Rev_1.00\7&aa112233&0&004'
        $fullKey     = Join-Path $usbStorBase $usbKey

        try {
            New-Item -Path $fullKey -Force -ErrorAction Stop | Out-Null
            Set-ItemProperty -LiteralPath $fullKey -Name 'FriendlyName' -Value 'SanDisk Cruzer Blade USB Device' -Force
            Set-ItemProperty -LiteralPath $fullKey -Name 'DeviceDesc'   -Value 'USB Mass Storage Device'         -Force
            $filesCreated++
            Write-SetupLog "[$role] Created USBSTOR registry key: $fullKey"
        } catch {
            $msg = "[$role] Step 8: Failed to create USBSTOR key '$usbKey': $($_.Exception.Message)"
            Write-SetupLog $msg 'WARN'
            $errors.Add($msg)
        }
    } catch {
        $msg = "[$role] Step 8 FAILED (USBSTOR registry): $($_.Exception.Message)"
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

    $status = if ($errors.Count -eq 0) { 'DONE' } elseif ($filesCreated -gt 0) { 'DONE_WITH_CONCERNS' } else { 'BLOCKED' }
    Write-SetupLog ("[$role] Invoke-RoleSetup complete -- FilesCreated: $filesCreated, Errors: $($errors.Count), Status: $status")
    return $summary
}
