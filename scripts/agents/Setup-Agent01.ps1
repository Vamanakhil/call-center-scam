<#
================================================================================
  Setup-Agent01.ps1  --  AGENT-01 artefact generator
  "Golden Returns Wealth Management" cyber-forensics training lab.

  Role    : Rahul Sharma -- Senior Closer
  Username: rahul.s
  Profile : C:\Users\rahul.s
  IP      : 192.168.10.11

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
if (-not (Get-Command 'Write-SetupLog' -ErrorAction SilentlyContinue)) {
    . "$PSScriptRoot\..\shared\New-FakeData.ps1"
}

function Invoke-RoleSetup {
    <#
        Creates all AGENT-01 evidence artefacts.
        Returns @{ Role='AGENT-01'; FilesCreated=N; Errors=@() }
    #>

    $role       = 'AGENT-01'
    $profileBase = "$env:SystemDrive\Users\rahul.s"
    $filesCreated = 0
    $errors      = [System.Collections.Generic.List[string]]::new()

    Write-SetupLog "[$role] Invoke-RoleSetup starting -- profile: $profileBase"

    # ------------------------------------------------------------------
    # Helper: wrap each file-creation block.
    # ------------------------------------------------------------------
    # (Inline try/catch is used per-file; this is just a note.)

    # ==================================================================
    # 1. Desktop\closer_script.docx
    # ==================================================================
    Write-SetupLog "[$role] Step 1: closer_script.docx"
    try {
        $destDir = "$profileBase\Desktop"
        New-DirectoryIfMissing $destDir

        $closerBody = @'
CLOSER SCRIPT -- Golden Returns Wealth Management
FOR INTERNAL USE ONLY. DO NOT SHARE WITH CUSTOMER OR SHOW ON SCREEN.
Document Version: 4.2 -- Approved by Arjun, Apr 2026.
==============================================================

SECTION 1 -- GREETING
---------------------
"Good [morning/afternoon], may I speak with [Name] ji? ... Sir/Madam, I am Rahul
calling from Golden Returns Wealth Management. You had shown interest in our
assured wealth growth programme some time ago. Do you have two minutes?"

If they say no: "I completely understand, sir. Would tomorrow morning at 10 be
convenient? I will call you at exactly that time."


SECTION 2 -- BUILDING RAPPORT
-----------------------------
"Sir, I see from your profile that you are from [City] and you are in [profession].
Most of our best-performing clients are from the same background -- people who
understand money and don't want it just sitting in an FD earning 6% when inflation
is at 7%. Am I right?"

Pause. Let them agree. Mirror their language. Speak slowly, with confidence.
Key phrases: "as a fellow investor," "between us," "confidentially," "this is not
for everyone -- we screen our clients."


SECTION 3 -- PRESENTING THE OPPORTUNITY
---------------------------------------
"Golden Returns is a SEBI-registered portfolio advisory firm operating under a
Category III AIF licence. Our flagship product -- the Gold Assurance Plan -- has
delivered 18-22% per annum net returns consistently for the last 36 months. Our
minimum ticket size is Rs 25,000. Most clients start small and increase. I have
clients who started with Rs 25,000 in January and are now at Rs 3 lakh. Their
names are on our website."

Show: goldenreturns.example/testimonials (Arjun to keep page live.)
Do NOT mention specific names unless the victim asks -- then use VICTIM-008 alias.


SECTION 4 -- HANDLING SEBI OBJECTION
-------------------------------------
When the victim says "I will call SEBI":
"Sir, you absolutely can and you should -- that shows you are a careful investor and
I respect that. SEBI is a regulatory body. They take 6 to 8 months to even
acknowledge a standard enquiry. By the time they even reply, your returns in our
scheme would have grown 20%. But more importantly -- we ARE registered with SEBI.
Our CIN is U67120MH2020PTC123456. You can verify it on the MCA21 portal right now.
Shall I wait while you check? ... You see, sir -- everything is transparent. Now, the
real question is: do you want your money working for you while you wait, or do you
want it sitting idle?"

Do NOT panic. Do NOT end the call. Stay warm and confident.
Key phrase: "This is a relationship, not a transaction."


SECTION 5 -- HANDLING "TOO GOOD TO BE TRUE"
--------------------------------------------
"Sir, I completely understand that reaction. Two years ago I would have said the
same thing. The truth is: 18% is not magic. It is achievable when you have insider
access to pre-IPO allotments and arbitrage in the SGX-NSE price differential. Our
fund manager Ravi Menon has 22 years of experience. Our top clients -- and I am not
allowed to name them -- include retired senior IAS officers and a former PSU bank MD.
Would someone of that stature invest if this was fake? ... Exactly."

Use the "social proof" technique. Refer to anonymous high-status clients.
If they press: "Sir, SEBI registration alone protects you. We are not going anywhere."


SECTION 6 -- HANDLING HESITATION / "LET ME THINK"
--------------------------------------------------
"Sir, absolutely take your time. The only thing I will say is that the next
subscription window closes on the 25th of this month. After that the plan is
locked for new entrants for 90 days. I have two slots left for this cycle. I have
already kept one for you because of your profile. If you do not take it, I will
have to release it. It is not pressure -- it is just the reality of a capped scheme."

Scarcity + deadline + personalisation. Works 60% of the time on second objection.


SECTION 7 -- CLOSING TECHNIQUE
-------------------------------
"So shall I send you the payment QR code now? Rs 25,000 is the starting amount.
You will receive a welcome email from our CRM within 2 hours. Your dashboard will
show your balance growing daily. Most clients re-invest their first month's returns
immediately -- you don't even have to do anything. Shall I send it to this WhatsApp
number only, or do you have a different one?"

Assume-the-close: frame it as a logistics question, not a yes/no question.
If they say "send it": immediately send the UPI QR from WhatsApp Web (see Section 8).


SECTION 8 -- PAYMENT INSTRUCTIONS
-----------------------------------
Current active UPI: compliance.gr@upi (Axis Bank -- XXXXXX7720)
Alternate: gr.deposit@upi (ICICI -- XXXXXX9191)
Fallback: arjun.collect@upi (HDFC -- XXXXXX4242)

Always confirm receipt with: "Sir, I can see the payment. Your plan is now active.
You will receive a PDF confirmation in 24 hours. Your relationship manager is me --
save this number. Call me for ANY concern."

Do NOT use the mule account names on any customer-facing communication.
If victim asks for a receipt: share the GoldenReturns.example PDF template (Vikas
will generate it from the CRM -- raise a ticket in the Telegram group).


SECTION 9 -- HANDLING WITHDRAWAL REQUESTS
------------------------------------------
"Sir, I completely understand. Your money is absolutely safe. The withdrawal process
takes 7-10 working days as per our fund structure. Can I ask -- is there an
emergency? Because if you need the money urgently I can raise a priority request,
but there is a 2% early exit fee. ... Sir, honestly -- withdrawing now would mean
missing the Q1 bonus payout which is due in 8 days. Let me send you the bonus
schedule. Take one week more and you will get an extra 5% on your corpus. Is that
fair?"

Delay-and-distract. Buy 2-3 more weeks. Escalate to Arjun if victim is very firm.


SECTION 10 -- HANDLING POLICE / CYBER CELL THREATS
---------------------------------------------------
"Sir, I respect your concern completely. If you have any doubt, you should verify.
Our registered address is Suite 12, Prestige Tower, BKC, Mumbai -- you can visit us.
Our directors are on the MCA portal. But sir, may I request -- before you do
anything, speak to me once more? I have seen cases where a misunderstanding like
this caused a client to lose their bonus payout permanently. Can we have a 15-minute
call tomorrow? I will bring our compliance officer on the line."

If they threaten the police: remain calm. Do NOT threaten back. Stall.
Notify Arjun on Telegram (@gr_daily_collect) with victim ID and threat level.


SECTION 11 -- FOLLOW-UP PROMISE
--------------------------------
"Sir, I will call you personally every Friday with your portfolio update. You will
also receive an auto-SMS from our system every Monday. My personal number is saved
in your phone -- use it any time. We are not a bank or a call centre. We are your
personal wealth team."

After each call: update the victim record in the CRM within 30 minutes.
WhatsApp follow-up within 2 hours of every call.
If no response in 48 hours: escalate to Priya (lead generator) for re-contact.


SECTION 12 -- NOTES FOR NEW CLOSERS
-------------------------------------
- Never use the words "guaranteed returns" in writing. Say "consistent historical
  performance" or "expected annualised growth."
- Never confirm the fund structure in writing. Voice only.
- If a victim records the call: deny, say it was a "hypothetical illustration."
- SEBI complaint reference number (if victim cites one): reply "We are aware, it is
  being handled by our legal team. Please don't take any further action until they
  contact you -- it will jeopardise the process."
- Target: 5 new deposits per day minimum. Arjun monitors daily at 8 PM.
- WhatsApp group for closers: "GR Closers Elite" -- ask Arjun for the invite link.
- The "golden returns" brand name is NOT trademarked. Do NOT put it in writing
  on official-looking letterhead without Vikas checking it first.

NOTE: This version is approved and current. Replace any older copies.
'@

        $docxPath = "$destDir\closer_script.docx"
        New-MinimalDocx -OutPath $docxPath -BodyText $closerBody
        Add-HashRecord -FilePath $docxPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $docxPath"
    } catch {
        $msg = "[$role] Step 1 FAILED (closer_script.docx): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 2. Desktop\hot_leads_today.txt
    # ==================================================================
    Write-SetupLog "[$role] Step 2: hot_leads_today.txt"
    try {
        $destDir = "$profileBase\Desktop"
        New-DirectoryIfMissing $destDir

        $hotVictimNums = @(1,23,47,52,88,101,122,145,167,189,202,234)

        $sb = [System.Text.StringBuilder]::new()
        [void]$sb.AppendLine('Hot Leads -- Today''s Priority List -- 17-Apr-2026')
        [void]$sb.AppendLine('=' * 60)
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine('Prepared by: Arjun (Manager)  |  Closer: Rahul Sharma')
        [void]$sb.AppendLine('Target for today: Rs 5,00,000')
        [void]$sb.AppendLine('')

        foreach ($num in $hotVictimNums) {
            $v = $VictimData | Where-Object { $_.VictimId -eq "VICTIM-$($num.ToString('000'))" } |
                 Select-Object -First 1
            if ($v) {
                $amtFormatted = '{0:N0}' -f $v.AmountPaid
                $line = 'VICTIM-{0} | +91-{1} | {2} | Amount Paid: Rs {3}' -f `
                    $num.ToString('000'), $v.Phone, $v.Name, $amtFormatted
            } else {
                $line = "VICTIM-$($num.ToString('000')) | +91-XXXXXXXXXX | (Unknown) | Amount Paid: Rs 0"
            }
            [void]$sb.AppendLine($line)
        }

        [void]$sb.AppendLine('')
        [void]$sb.AppendLine('--- PRIORITY NOTES ---')
        [void]$sb.AppendLine('VICTIM-047: Follow up on 50K deposit promise. Very close. Call before 11 AM.')
        [void]$sb.AppendLine('VICTIM-202: Raised complaint. Stall with SEBI excuse. See Section 10 of script.')
        [void]$sb.AppendLine('VICTIM-001: First call today. High potential. Use rapport script (Section 2).')
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine('All amounts reflect current paid amount. Update CRM after each call.')

        $leadsPath = "$destDir\hot_leads_today.txt"
        [System.IO.File]::WriteAllText($leadsPath, $sb.ToString(), [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $leadsPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $leadsPath"
    } catch {
        $msg = "[$role] Step 2 FAILED (hot_leads_today.txt): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 3. Desktop\Daily_Target.txt
    # ==================================================================
    Write-SetupLog "[$role] Step 3: Daily_Target.txt"
    try {
        $destDir = "$profileBase\Desktop"
        New-DirectoryIfMissing $destDir

        $targetContent = @"
Daily Target -- Apr 17, 2026
Target: Rs 5,00,000
Current: Rs 1,42,000
Remaining: Rs 3,58,000

-- Arjun
"@

        $targetPath = "$destDir\Daily_Target.txt"
        [System.IO.File]::WriteAllText($targetPath, $targetContent, [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $targetPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $targetPath"
    } catch {
        $msg = "[$role] Step 3 FAILED (Daily_Target.txt): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 4. Documents\call_notes_2026-04-17.md
    # ==================================================================
    Write-SetupLog "[$role] Step 4: call_notes_2026-04-17.md"
    try {
        $destDir = "$profileBase\Documents"
        New-DirectoryIfMissing $destDir

        # Pull names from VictimData for the three featured victims.
        $v001 = $VictimData | Where-Object { $_.VictimId -eq 'VICTIM-001' } | Select-Object -First 1
        $v047 = $VictimData | Where-Object { $_.VictimId -eq 'VICTIM-047' } | Select-Object -First 1
        $v202 = $VictimData | Where-Object { $_.VictimId -eq 'VICTIM-202' } | Select-Object -First 1

        $n001 = if ($v001) { $v001.Name } else { 'Unknown Victim' }
        $n047 = if ($v047) { $v047.Name } else { 'Unknown Victim' }
        $n202 = if ($v202) { $v202.Name } else { 'Unknown Victim' }

        $callNotesContent = @"
# Call Notes -- 17 Apr 2026
**Agent:** Rahul Sharma (rahul.s)
**Date:** 2026-04-17

---

## Call with $n001 (VICTIM-001) -- 09:22
- First contact. Picked up after 2 rings -- good sign.
- Intro went well. He is a retired LIC agent from Pune -- knows financial products.
- Pitched Gold Assurance Plan at 20% p.a. He was cautious at first.
- Asked for SEBI registration proof -- sent him the CIN on WhatsApp.
- Agreed in principle to invest Rs 25,000 as a trial. Will confirm tomorrow morning.
- **Follow-up:** Call at 10:00 on 18-Apr. Send him the payment QR tonight on WA.
- **Status:** WARM -> CONVERTING

---

## Call with $n047 (VICTIM-047) -- 11:05
- 3rd follow-up call. He had promised Rs 50,000 last week.
- He said his wife is suspicious and wants a "certificate" from SEBI.
- Used Section 4 script (SEBI objection). Told him SEBI takes 6-8 months to reply.
- He calmed down. Agreed to invest 50k by end of day today.
- Confirmed payment came in at 14:32 -- Rs 50,000 to compliance.gr@upi.
- Sent him a WhatsApp receipt (Vikas generated from CRM).
- **Status:** CONVERTED -- Rs 50,000 received. Update victim record.

---

## Call with $n202 (VICTIM-202) -- 16:47
- He is angry. Says he has filed a complaint with the Cyber Cell.
- I used the stalling script (Section 10). Told him our legal team will contact him.
- He mentioned a complaint reference number -- CYCCELL/MUM/2026/04172.
- Arjun notified on Telegram immediately (threat level: HIGH).
- He hung up. Do NOT call him again without Arjun's approval.
- **Status:** HIGH RISK -- Arjun to manage from here.

---

*Notes auto-saved. Update CRM before 8 PM daily standup.*
"@

        $notesPath = "$destDir\call_notes_2026-04-17.md"
        [System.IO.File]::WriteAllText($notesPath, $callNotesContent, [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $notesPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $notesPath"
    } catch {
        $msg = "[$role] Step 4 FAILED (call_notes_2026-04-17.md): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 5. Documents\Objection_Handling_Cheat_Sheet.pdf
    # ==================================================================
    Write-SetupLog "[$role] Step 5: Objection_Handling_Cheat_Sheet.pdf"
    try {
        $destDir = "$profileBase\Documents"
        New-DirectoryIfMissing $destDir

        # Minimal valid PDF-1.4 with two text lines on one page.
        # All byte offsets in xref are computed so Acrobat / PDF tools accept it.
        $pdfText  = 'SEBI Objection Handling - Golden Returns'
        $pdfText2 = 'For internal use only. Version 4.2 - Apr 2026.'

        $streamContent = "BT /F1 12 Tf 72 720 Td ($pdfText) Tj 0 -20 Td ($pdfText2) Tj ET"
        $streamLen = [System.Text.Encoding]::ASCII.GetByteCount($streamContent)

        # Build the PDF body and record byte positions for xref.
        $pdfBuilder = [System.Text.StringBuilder]::new()

        # %PDF header + binary comment (4 bytes >= 128 to flag binary content)
        $pdfBuilder.AppendLine('%PDF-1.4') | Out-Null
        $pdfBuilder.AppendLine('%' + [char]0xE2 + [char]0xE3 + [char]0xCF + [char]0xD3) | Out-Null

        # Obj 1 -- Catalog
        $off1 = [System.Text.Encoding]::ASCII.GetByteCount($pdfBuilder.ToString())
        $pdfBuilder.AppendLine('1 0 obj') | Out-Null
        $pdfBuilder.AppendLine('<< /Type /Catalog /Pages 2 0 R >>') | Out-Null
        $pdfBuilder.AppendLine('endobj') | Out-Null

        # Obj 2 -- Pages
        $off2 = [System.Text.Encoding]::ASCII.GetByteCount($pdfBuilder.ToString())
        $pdfBuilder.AppendLine('2 0 obj') | Out-Null
        $pdfBuilder.AppendLine('<< /Type /Pages /Kids [3 0 R] /Count 1 >>') | Out-Null
        $pdfBuilder.AppendLine('endobj') | Out-Null

        # Obj 3 -- Page
        $off3 = [System.Text.Encoding]::ASCII.GetByteCount($pdfBuilder.ToString())
        $pdfBuilder.AppendLine('3 0 obj') | Out-Null
        $pdfBuilder.AppendLine('<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792]') | Out-Null
        $pdfBuilder.AppendLine('   /Contents 4 0 R') | Out-Null
        $pdfBuilder.AppendLine('   /Resources << /Font << /F1 << /Type /Font /Subtype /Type1 /BaseFont /Helvetica >> >> >> >>') | Out-Null
        $pdfBuilder.AppendLine('endobj') | Out-Null

        # Obj 4 -- Content stream
        $off4 = [System.Text.Encoding]::ASCII.GetByteCount($pdfBuilder.ToString())
        $pdfBuilder.AppendLine('4 0 obj') | Out-Null
        $pdfBuilder.AppendLine("<< /Length $streamLen >>") | Out-Null
        $pdfBuilder.AppendLine('stream') | Out-Null
        $pdfBuilder.AppendLine($streamContent) | Out-Null
        $pdfBuilder.AppendLine('endstream') | Out-Null
        $pdfBuilder.AppendLine('endobj') | Out-Null

        # xref table
        $xrefOffset = [System.Text.Encoding]::ASCII.GetByteCount($pdfBuilder.ToString())
        $pdfBuilder.AppendLine('xref') | Out-Null
        $pdfBuilder.AppendLine('0 5') | Out-Null
        $pdfBuilder.AppendLine('0000000000 65535 f ') | Out-Null
        $pdfBuilder.AppendLine(('{0:D10} 00000 n ' -f $off1)) | Out-Null
        $pdfBuilder.AppendLine(('{0:D10} 00000 n ' -f $off2)) | Out-Null
        $pdfBuilder.AppendLine(('{0:D10} 00000 n ' -f $off3)) | Out-Null
        $pdfBuilder.AppendLine(('{0:D10} 00000 n ' -f $off4)) | Out-Null

        $pdfBuilder.AppendLine('trailer') | Out-Null
        $pdfBuilder.AppendLine('<< /Size 5 /Root 1 0 R >>') | Out-Null
        $pdfBuilder.AppendLine('startxref') | Out-Null
        $pdfBuilder.AppendLine($xrefOffset.ToString()) | Out-Null
        $pdfBuilder.Append('%%EOF') | Out-Null

        $pdfPath = "$destDir\Objection_Handling_Cheat_Sheet.pdf"
        $pdfBytes = [System.Text.Encoding]::ASCII.GetBytes($pdfBuilder.ToString())
        [System.IO.File]::WriteAllBytes($pdfPath, $pdfBytes)
        Add-HashRecord -FilePath $pdfPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $pdfPath"
    } catch {
        $msg = "[$role] Step 5 FAILED (Objection_Handling_Cheat_Sheet.pdf): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 6. Downloads\whatsapp_web_session_export.zip
    # ==================================================================
    Write-SetupLog "[$role] Step 6: whatsapp_web_session_export.zip"
    try {
        $destDir = "$profileBase\Downloads"
        New-DirectoryIfMissing $destDir

        $hotVictimNums = @(1,23,47,52,88,101,122,145,167,189,202,234)

        $zipFiles = @{}
        foreach ($num in $hotVictimNums) {
            $vid = "VICTIM-$($num.ToString('000'))"
            $v = $VictimData | Where-Object { $_.VictimId -eq $vid } | Select-Object -First 1
            $vName = if ($v) { $v.Name } else { "Unknown Victim $num" }
            $vPhone = if ($v) { '+91-' + $v.Phone } else { '+91-XXXXXXXXXX' }
            $amtPaid = if ($v) { '{0:N0}' -f $v.AmountPaid } else { '0' }

            $entryName = "chat_$($vid -replace '-','').html"

            $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>WhatsApp Chat - $vName</title>
<style>
  body { font-family: Arial, sans-serif; background: #e5ddd5; margin: 0; padding: 0; }
  .chat-container { max-width: 680px; margin: 0 auto; padding: 16px; }
  .msg { margin: 8px 0; display: flex; }
  .msg.sent { justify-content: flex-end; }
  .msg.received { justify-content: flex-start; }
  .bubble { max-width: 65%; padding: 8px 12px; border-radius: 8px; font-size: 14px; line-height: 1.4; }
  .sent .bubble { background: #dcf8c6; }
  .received .bubble { background: #ffffff; }
  .meta { font-size: 11px; color: #666; margin-top: 4px; text-align: right; }
  .sender-name { font-weight: bold; font-size: 12px; color: #128C7E; margin-bottom: 2px; }
  .chat-header { background: #075E54; color: white; padding: 12px 16px; display: flex; align-items: center; }
  .chat-header h2 { margin: 0; font-size: 16px; }
  .chat-header p { margin: 0; font-size: 12px; opacity: 0.8; }
  .date-divider { text-align: center; margin: 16px 0; }
  .date-divider span { background: #e1f3fb; padding: 4px 12px; border-radius: 8px; font-size: 12px; color: #555; }
</style>
</head>
<body>
<div class="chat-header">
  <div>
    <h2>$vName</h2>
    <p>$vPhone &nbsp;|&nbsp; Golden Returns Client</p>
  </div>
</div>
<div class="chat-container">

  <div class="date-divider"><span>14 April 2026</span></div>

  <div class="msg received">
    <div class="bubble">
      <div class="sender-name">$vName</div>
      Hello, you called me earlier about some investment scheme?
      <div class="meta">14:10 [v]</div>
    </div>
  </div>

  <div class="msg sent">
    <div class="bubble">
      <div class="sender-name">Rahul (GR Support)</div>
      Yes sir! Thank you for reaching back. I am Rahul from Golden Returns
      Wealth Management. We have an exciting opportunity -- our Gold Assurance
      Plan is giving consistent 18-22% per annum returns. Minimum investment
      is just Rs 25,000. Can I share more details?
      <div class="meta">14:12 [v][v]</div>
    </div>
  </div>

  <div class="msg received">
    <div class="bubble">
      <div class="sender-name">$vName</div>
      Sounds interesting. Is it SEBI registered?
      <div class="meta">14:15 [v]</div>
    </div>
  </div>

  <div class="msg sent">
    <div class="bubble">
      <div class="sender-name">Rahul (GR Support)</div>
      Absolutely sir! We are fully SEBI registered under Category III AIF.
      CIN: U67120MH2020PTC123456. You can verify on MCA21 portal.
      I will also send you our brochure now.
      <div class="meta">14:16 [v][v]</div>
    </div>
  </div>

  <div class="msg sent">
    <div class="bubble">
      <div class="sender-name">Rahul (GR Support)</div>
       GoldenReturns_Brochure_Apr2026.pdf
      <div class="meta">14:17 [v][v]</div>
    </div>
  </div>

  <div class="date-divider"><span>15 April 2026</span></div>

  <div class="msg sent">
    <div class="bubble">
      <div class="sender-name">Rahul (GR Support)</div>
      Good morning sir! Just following up. Did you get a chance to look at
      the brochure? The April subscription window closes on 25th. Only 2
      slots left in your tier.
      <div class="meta">09:30 [v][v]</div>
    </div>
  </div>

  <div class="msg received">
    <div class="bubble">
      <div class="sender-name">$vName</div>
      Yes I saw it. How do I invest? What is the process?
      <div class="meta">10:05 [v]</div>
    </div>
  </div>

  <div class="msg sent">
    <div class="bubble">
      <div class="sender-name">Rahul (GR Support)</div>
      Very simple sir. Transfer the amount via UPI to our compliance account.
      You will receive a confirmation and your dashboard access within 2 hours.
      Here is the QR code:
      <div class="meta">10:07 [v][v]</div>
    </div>
  </div>

  <div class="msg sent">
    <div class="bubble">
      <div class="sender-name">Rahul (GR Support)</div>
       GR_Payment_QR_Apr2026.png &nbsp;|&nbsp; UPI: compliance.gr@upi<br>
      Amount: Rs $amtPaid
      <div class="meta">10:08 [v][v]</div>
    </div>
  </div>

  <div class="date-divider"><span>17 April 2026</span></div>

  <div class="msg received">
    <div class="bubble">
      <div class="sender-name">$vName</div>
      I have transferred Rs $amtPaid. Transaction ID: UPI202604172207$num.
      <div class="meta">14:32 [v]</div>
    </div>
  </div>

  <div class="msg sent">
    <div class="bubble">
      <div class="sender-name">Rahul (GR Support)</div>
      Excellent sir! Payment received ???. Your Gold Assurance Plan is now ACTIVE.
      Your portfolio ID is GR-$($num.ToString('000'))-APR26.
      Dashboard access will be shared within 2 hours. Welcome to Golden Returns! ????
      <div class="meta">14:35 [v][v]</div>
    </div>
  </div>

  <div class="msg sent">
    <div class="bubble">
      <div class="sender-name">Rahul (GR Support)</div>
       GR_Welcome_Certificate_$vid.pdf
      <div class="meta">16:10 [v][v]</div>
    </div>
  </div>

</div>
</body>
</html>
"@
            $zipFiles[$entryName] = $html
        }

        $zipPath = "$destDir\whatsapp_web_session_export.zip"
        New-ZipWithContent -OutPath $zipPath -Files $zipFiles
        Add-HashRecord -FilePath $zipPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $zipPath ($($hotVictimNums.Count) chat files)"
    } catch {
        $msg = "[$role] Step 6 FAILED (whatsapp_web_session_export.zip): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 7. Chrome History SQLite
    # ==================================================================
    Write-SetupLog "[$role] Step 7: Chrome History"
    try {
        $chromeDir = "$profileBase\AppData\Local\Google\Chrome\User Data\Default"
        New-DirectoryIfMissing $chromeDir

        # Chrome timestamps: microseconds since 1601-01-01 00:00:00 UTC.
        $chromEpoch = [datetime]::new(1601, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc)

        function ConvertTo-ChromeTime {
            param([string]$DateStr)
            try {
                $dt = [datetime]::Parse($DateStr, $null, [System.Globalization.DateTimeStyles]::AssumeLocal)
                $dt = $dt.ToUniversalTime()
                return [long](($dt - $chromEpoch).TotalSeconds * 1000000)
            } catch {
                return 13300000000000000  # fallback: approx Apr 2026
            }
        }

        $sqlStatements = [System.Collections.Generic.List[string]]::new()
        $sqlStatements.Add("CREATE TABLE urls (id INTEGER PRIMARY KEY, url TEXT, title TEXT, visit_count INTEGER, typed_count INTEGER, last_visit_time INTEGER, hidden INTEGER);")
        $sqlStatements.Add("CREATE TABLE visits (id INTEGER PRIMARY KEY, url INTEGER, visit_time INTEGER, from_visit INTEGER, transition INTEGER, segment_id INTEGER, visit_duration INTEGER);")
        $sqlStatements.Add("CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT);")
        $sqlStatements.Add("INSERT INTO meta VALUES ('version','58');")
        $sqlStatements.Add("INSERT INTO meta VALUES ('last_compatible_version','58');")

        $visitId = 1
        for ($u = 0; $u -lt $ChromeUrlHistory.Count; $u++) {
            $row = $ChromeUrlHistory[$u]
            $urlId = $u + 1
            $chromeTs = ConvertTo-ChromeTime -DateStr $row.LastVisit
            $urlEsc   = $row.Url   -replace "'", "''"
            $titleEsc = $row.Title -replace "'", "''"
            $sqlStatements.Add("INSERT INTO urls VALUES ($urlId,'$urlEsc','$titleEsc',$($row.VisitCount),0,$chromeTs,0);")

            # One visit record per URL.
            $sqlStatements.Add("INSERT INTO visits VALUES ($visitId,$urlId,$chromeTs,0,805306368,0,0);")
            $visitId++
        }

        $historyPath = "$chromeDir\History"
        $ok = New-SqliteDb -DbPath $historyPath -SqlStatements $sqlStatements.ToArray()
        if ($ok) {
            Add-HashRecord -FilePath $historyPath -Role $role
            $filesCreated++
            Write-SetupLog "[$role] Created: $historyPath"
        } else {
            $errors.Add("[$role] Step 7: New-SqliteDb returned false for History (sqlite3 unavailable?)")
        }
    } catch {
        $msg = "[$role] Step 7 FAILED (Chrome History): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 8. Chrome Login Data SQLite
    # ==================================================================
    Write-SetupLog "[$role] Step 8: Chrome Login Data"
    try {
        $chromeDir = "$profileBase\AppData\Local\Google\Chrome\User Data\Default"
        New-DirectoryIfMissing $chromeDir

        $loginSql = @(
            "CREATE TABLE logins (origin_url TEXT, username_value TEXT, password_value BLOB, date_created INTEGER, date_last_used INTEGER);",
            "INSERT INTO logins VALUES ('https://goldenreturns.example/admin','rahul.s',X'00',0,0);",
            "INSERT INTO logins VALUES ('https://web.whatsapp.com','rahul.sharma.gr',X'00',0,0);",
            "INSERT INTO logins VALUES ('https://t.me','rahul_gr_closer',X'00',0,0);"
        )

        $loginPath = "$chromeDir\Login Data"
        $ok = New-SqliteDb -DbPath $loginPath -SqlStatements $loginSql
        if ($ok) {
            Add-HashRecord -FilePath $loginPath -Role $role
            $filesCreated++
            Write-SetupLog "[$role] Created: $loginPath"
        } else {
            $errors.Add("[$role] Step 8: New-SqliteDb returned false for Login Data (sqlite3 unavailable?)")
        }
    } catch {
        $msg = "[$role] Step 8 FAILED (Chrome Login Data): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 9. Recycle Bin entry: closer_script_old.docx
    # ==================================================================
    Write-SetupLog "[$role] Step 9: Recycle Bin closer_script_old.docx"
    try {
        $docsDir = "$profileBase\Documents"
        New-DirectoryIfMissing $docsDir

        # Create the old script document.
        $oldBodySuffix = @'


=== OLDER VERSION -- DIRECT APPROACH ===

NOTE: This version is more direct. Replace SEBI objection script with the
new approved language.

When the victim threatens SEBI:
"Sir, go ahead and call SEBI. They will tell you the same thing. Your
investment is safe. Now -- are you going to let bureaucracy stop you from
making Rs 1 lakh this month?"

[END OF OLD VERSION -- SUPERSEDED BY v4.2]
'@

        $closerBodyOld = @'
CLOSER SCRIPT -- Golden Returns Wealth Management (DRAFT v3.1)
FOR INTERNAL USE ONLY.

SECTION 1 -- GREETING
---------------------
"Good [morning/afternoon], may I speak with [Name] ji? ..."

SECTION 2 -- BUILDING RAPPORT
-----------------------------
Establish connection. Use city + profession hook.

SECTION 3 -- PRESENTING THE OPPORTUNITY
---------------------------------------
Golden Returns -- 18-22% per annum. SEBI Category III AIF.
Minimum Rs 25,000.

SECTION 4 -- HANDLING SEBI OBJECTION (OLD VERSION -- SEE NOTE BELOW)
--------------------------------------------------------------------
"Sir, go ahead and call SEBI. They will tell you the same thing.
Your investment is safe. Now -- are you going to let bureaucracy stop
you from making Rs 1 lakh this month?"

SECTION 5 -- CLOSING
--------------------
"Shall I send the UPI QR? Rs 5,000 to start."

SECTION 6 -- PAYMENT
--------------------
UPI: arjun.collect@upi / gr.deposit@upi
'@ + $oldBodySuffix

        $tmpDocxPath = "$docsDir\closer_script_old.docx"
        New-MinimalDocx -OutPath $tmpDocxPath -BodyText $closerBodyOld

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

        $recycledDocx  = Join-Path $sidDir '$RDOCXOLD.docx'
        $recycleInfoFile = Join-Path $sidDir '$IDOCXOLD.docx'

        # Move the file to Recycle Bin.
        Copy-Item -LiteralPath $tmpDocxPath -Destination $recycledDocx -Force
        Remove-Item -LiteralPath $tmpDocxPath -Force -ErrorAction SilentlyContinue

        Add-HashRecord -FilePath $recycledDocx -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created recycled file: $recycledDocx"

        # Create the $I (info) metadata file: a 544-byte binary with the
        # original file path encoded as UTF-16LE starting at offset 28.
        # Windows 10 $I format:
        #   0x00: UINT64 magic      (01 00 00 00 00 00 00 00)
        #   0x08: UINT64 file size  (little-endian)
        #   0x10: UINT64 deletion time (FILETIME)
        #   0x18: UINT32 path char count (little-endian)
        #   0x1C: path (UTF-16LE, null-terminated, padded to 520 bytes = 260 UTF-16 chars)
        # Total: 8 + 8 + 8 + 4 + 520 = 548 bytes (we use 544 as the path block is variable)

        $originalPath = "$profileBase\Documents\closer_script_old.docx"
        $pathUtf16    = [System.Text.Encoding]::Unicode.GetBytes($originalPath + "`0")
        $charCount    = [int]($pathUtf16.Length / 2)

        # Get file size from the recycled copy.
        $fileSize = (Get-Item -LiteralPath $recycledDocx).Length

        # Deletion time: current time as FILETIME (100-ns intervals since 1601-01-01).
        $ftEpoch  = [datetime]::new(1601,1,1,0,0,0,[System.DateTimeKind]::Utc)
        $nowFt    = [long](([datetime]::UtcNow - $ftEpoch).TotalSeconds * 10000000)

        $infoBytes = New-Object byte[] 548
        # Magic
        $infoBytes[0] = 0x01
        # File size (8 bytes LE)
        [System.BitConverter]::GetBytes([long]$fileSize).CopyTo($infoBytes, 8)
        # Deletion time (8 bytes LE)
        [System.BitConverter]::GetBytes($nowFt).CopyTo($infoBytes, 16)
        # Char count (4 bytes LE)
        [System.BitConverter]::GetBytes($charCount).CopyTo($infoBytes, 24)
        # Path (UTF-16LE)
        $copyLen = [math]::Min($pathUtf16.Length, 544 - 28)
        [System.Array]::Copy($pathUtf16, 0, $infoBytes, 28, $copyLen)

        [System.IO.File]::WriteAllBytes($recycleInfoFile, $infoBytes)
        Add-HashRecord -FilePath $recycleInfoFile -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created recycle info file: $recycleInfoFile"
    } catch {
        $msg = "[$role] Step 9 FAILED (Recycle Bin): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 10. USB registry entries
    # ==================================================================
    Write-SetupLog "[$role] Step 10: USBSTOR registry entries"
    try {
        $usbStorBase = 'HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR'

        $usbDevices = @(
            @{
                Key          = 'Disk&Ven_SanDisk&Prod_Ultra&Rev_1.00\7&abc12345&0&001'
                FriendlyName = 'SanDisk Ultra USB Device'
                DeviceDesc   = 'USB Mass Storage Device'
            },
            @{
                Key          = 'Disk&Ven_Kingston&Prod_DataTraveler&Rev_1.00\7&def67890&0&001'
                FriendlyName = 'Kingston DataTraveler USB Device'
                DeviceDesc   = 'USB Mass Storage Device'
            },
            @{
                Key          = 'Disk&Ven_Seagate&Prod_BUP_Slim&Rev_1.00\7&fed11223&0&001'
                FriendlyName = 'Seagate Backup Plus Slim'
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
                Write-SetupLog "[$role] Created USBSTOR key: $fullKey"
            } catch {
                $msg = "[$role] Step 10: Failed to create USBSTOR key '$($dev.Key)': $($_.Exception.Message)"
                Write-SetupLog $msg 'WARN'
                $errors.Add($msg)
            }
        }
    } catch {
        $msg = "[$role] Step 10 FAILED (USBSTOR registry): $($_.Exception.Message)"
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

    Write-SetupLog ("[$role] Invoke-RoleSetup complete -- files created: $filesCreated, errors: $($errors.Count)")
    return $summary
}
