<#
================================================================================
  Setup-Router.ps1  --  ROUTER artefact generator
  "Golden Returns Wealth Management" cyber-forensics training lab.

  Role    : TP-Link TL-R605 office router
  LAN IP  : 192.168.10.1
  WAN IP  : 49.207.198.112 (Airtel Broadband Mumbai)

  *** SYNTHETIC TRAINING DATA ONLY ***
  All IP addresses, MAC addresses, hostnames, and network data are entirely
  fictional and machine-generated for an isolated DSP forensics training
  exercise. Any resemblance to real networks or entities is purely coincidental.

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
# Invoke-RoleSetup  --  creates all ROUTER evidence artefacts.
# ---------------------------------------------------------------------------
function Invoke-RoleSetup {
    <#
        Returns @{ Role='ROUTER'; FilesCreated=N; Errors=@() }
    #>

    $role         = 'ROUTER'
    $routerDir    = "$env:SystemDrive\GR_LabAssets\RouterEvidence"
    $filesCreated = 0
    $errors       = [System.Collections.Generic.List[string]]::new()

    Write-SetupLog "[$role] Invoke-RoleSetup starting -- output dir: $routerDir"
    New-DirectoryIfMissing $routerDir

    # ------------------------------------------------------------------
    # Artefact 1: running-config.txt
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] Artefact 1: running-config.txt"
    try {
        $cfgPath = Join-Path $routerDir 'running-config.txt'

        $cfgContent = @'
! TP-Link TL-R605 running configuration
! Last saved: 2026-04-17 02:00:11
! Firmware: TL-R605_V2_2.0.11
!
hostname GR-OFFICE-ROUTER
!
interface WAN1
  ip address dhcp
  description Airtel Broadband
!
interface LAN
  ip address 192.168.10.1 255.255.255.0
  dhcp-server enable
  dhcp-server pool GR-LAN
    network 192.168.10.0 255.255.255.0
    default-gateway 192.168.10.1
    dns-server 8.8.8.8 1.1.1.1
    lease-time 86400
  end
!
dhcp static-bind mac 00:1A:2B:3C:4D:01 ip 192.168.10.11  hostname AGENT-01
dhcp static-bind mac 00:1A:2B:3C:4D:02 ip 192.168.10.22  hostname AGENT-02
dhcp static-bind mac 00:1A:2B:3C:4D:03 ip 192.168.10.33  hostname AGENT-03
dhcp static-bind mac 00:1A:2B:3C:4D:04 ip 192.168.10.44  hostname AGENT-04
dhcp static-bind mac 00:1A:2B:3C:4D:05 ip 192.168.10.55  hostname AGENT-05   static-ip
dhcp static-bind mac 00:1A:2B:3C:4D:50 ip 192.168.10.50  hostname MANAGER-PC
dhcp static-bind mac 00:1A:2B:3C:4D:64 ip 192.168.10.100 hostname CRM-SERVER
dhcp static-bind mac 00:1A:2B:3C:4D:1E ip 192.168.10.30  hostname HP-PRINTER
!
ip nat inside source static tcp 192.168.10.100 3389 interface WAN1 3389
ip nat inside source static tcp 192.168.10.100 80   interface WAN1 80
ip nat inside source static tcp 192.168.10.100 443  interface WAN1 443
!
end
'@

        [System.IO.File]::WriteAllText($cfgPath, $cfgContent, [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $cfgPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: running-config.txt"
    } catch {
        $msg = "[$role] Artefact 1 FAILED (running-config.txt): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # Artefact 2: dhcp-leases.txt
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] Artefact 2: dhcp-leases.txt"
    try {
        $leasesPath = Join-Path $routerDir 'dhcp-leases.txt'

        $leasesContent = @'
DHCP Lease Table -- GR-OFFICE-ROUTER -- 2026-04-17 18:55:00
============================================================
IP               MAC                 Hostname        Expires              Note
---------------  ------------------  --------------  -------------------  --------
192.168.10.11    00:1A:2B:3C:4D:01   AGENT-01        2026-04-18 09:00     STATIC
192.168.10.22    00:1A:2B:3C:4D:02   AGENT-02        2026-04-18 09:00     STATIC
192.168.10.33    00:1A:2B:3C:4D:03   AGENT-03        2026-04-18 09:00     STATIC
192.168.10.44    00:1A:2B:3C:4D:04   AGENT-04        2026-04-18 09:00     STATIC
192.168.10.55    00:1A:2B:3C:4D:05   AGENT-05        PERMANENT            STATIC RESERVATION
192.168.10.50    00:1A:2B:3C:4D:50   MANAGER-PC      2026-04-18 09:00     STATIC
192.168.10.100   00:1A:2B:3C:4D:64   CRM-SERVER      PERMANENT            STATIC
192.168.10.30    00:1A:2B:3C:4D:1E   HP-PRINTER      2026-04-18 09:00     STATIC
192.168.10.245   AA:BB:CC:DD:EE:FF   UNKNOWN-DEVICE  2026-04-17 22:55     DYNAMIC -- investigate
'@

        [System.IO.File]::WriteAllText($leasesPath, $leasesContent, [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $leasesPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: dhcp-leases.txt"
    } catch {
        $msg = "[$role] Artefact 2 FAILED (dhcp-leases.txt): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # Artefact 3: arp-table.txt
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] Artefact 3: arp-table.txt"
    try {
        $arpPath = Join-Path $routerDir 'arp-table.txt'

        $arpContent = @'
ARP Cache -- GR-OFFICE-ROUTER -- 2026-04-17 18:55:00
=====================================================
Address          HW type    Flags    HW address          Device
192.168.10.1     ether      C        00:1A:2B:00:00:01   LAN (self)
192.168.10.11    ether      C        00:1A:2B:3C:4D:01   LAN
192.168.10.22    ether      C        00:1A:2B:3C:4D:02   LAN
192.168.10.33    ether      C        00:1A:2B:3C:4D:03   LAN
192.168.10.44    ether      C        00:1A:2B:3C:4D:04   LAN
192.168.10.55    ether      C        00:1A:2B:3C:4D:05   LAN
192.168.10.50    ether      C        00:1A:2B:3C:4D:50   LAN
192.168.10.100   ether      C        00:1A:2B:3C:4D:64   LAN
192.168.10.30    ether      C        00:1A:2B:3C:4D:1E   LAN
192.168.10.245   ether      C        AA:BB:CC:DD:EE:FF   LAN
'@

        [System.IO.File]::WriteAllText($arpPath, $arpContent, [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $arpPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: arp-table.txt"
    } catch {
        $msg = "[$role] Artefact 3 FAILED (arp-table.txt): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # Artefact 4: dns-log.txt   (14 days, Apr 4-Apr 17 2026, ~200+ lines)
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] Artefact 4: dns-log.txt (programmatic, 14 days)"
    try {
        $dnsPath = Join-Path $routerDir 'dns-log.txt'

        # Seeded RNG for deterministic output (separate from shared library's RNG).
        $dnsRng = New-Object System.Random(77)

        # Agent IPs used for daytime noise traffic.
        $agentIPs = @('192.168.10.11','192.168.10.22','192.168.10.33','192.168.10.44','192.168.10.55')

        # Noise hostnames and their resolved IPs.
        $noiseHosts = @(
            @{ Host='google.com';                  IP='142.250.182.46'  },
            @{ Host='www.google.com';              IP='142.250.182.78'  },
            @{ Host='linkedin.com';                IP='108.174.10.10'   },
            @{ Host='www.linkedin.com';            IP='108.174.10.10'   },
            @{ Host='t.me';                        IP='149.154.167.99'  },
            @{ Host='youtube.com';                 IP='142.250.195.78'  },
            @{ Host='www.youtube.com';             IP='142.250.195.78'  },
            @{ Host='facebook.com';                IP='157.240.14.35'   },
            @{ Host='www.facebook.com';            IP='157.240.14.35'   },
            @{ Host='instagram.com';               IP='157.240.22.174'  },
            @{ Host='goldenreturns.example';       IP='192.168.10.100'  },
            @{ Host='crm.goldenreturns.example';   IP='192.168.10.100'  }
        )

        # Line builder helper (uses closure over $dnsRng).
        # Returns a formatted DNS log line string.
        $sb = New-Object System.Text.StringBuilder
        [void]$sb.AppendLine('DNS Query Log -- GR-OFFICE-ROUTER -- Apr 4 - Apr 17 2026')
        [void]$sb.AppendLine('============================================================')

        # Iterate 14 days: April 4 through April 17 2026 inclusive.
        $startDate = [datetime]'2026-04-04'
        for ($dayOffset = 0; $dayOffset -lt 14; $dayOffset++) {
            $day        = $startDate.AddDays($dayOffset)
            $dateStr    = $day.ToString('yyyy-MM-dd')

            # Number of daytime noise entries this day (12-18).
            $noiseCount = 12 + $dnsRng.Next(0, 7)

            # Generate noise entries spread across 08:00-21:59.
            for ($n = 0; $n -lt $noiseCount; $n++) {
                $hh     = 8 + $dnsRng.Next(0, 14)          # 08..21
                $mm     = $dnsRng.Next(0, 60)
                $ss     = $dnsRng.Next(0, 60)
                $srcIP  = $agentIPs[$dnsRng.Next(0, $agentIPs.Count)]
                $entry  = $noiseHosts[$dnsRng.Next(0, $noiseHosts.Count)]

                # Occasionally (roughly 1-in-6) substitute a goldenreturns.example lookup.
                if ($dnsRng.Next(0, 6) -eq 0) {
                    $entry = @{ Host='goldenreturns.example'; IP='192.168.10.100' }
                }

                $line = '[{0} {1:00}:{2:00}:{3:00}] DNS QUERY: {4} -> {5} -> {6}' -f `
                        $dateStr, $hh, $mm, $ss, $srcIP, $entry.Host, $entry.IP
                [void]$sb.AppendLine($line)
            }

            # Guaranteed nightly entry 1: 23:14 (+/-30 sec) from MANAGER-PC -> relay.anydesk.com
            $anyMs  = $dnsRng.Next(0, 31)
            $anyS   = $dnsRng.Next(0, 30) + ($anyMs % 2)   # seconds offset 0-30
            $anyMin = 14
            # Apply a +/-30-second jitter: occasionally push into :13 or :15.
            if ($dnsRng.Next(0, 2) -eq 0) { $anyMin = 13 ; $anyS = 30 + $dnsRng.Next(0, 30) }
            $line1 = '[{0} 23:{1:00}:{2:00}] DNS QUERY: 192.168.10.50 -> relay.anydesk.com -> 195.90.158.100' -f `
                     $dateStr, $anyMin, ($dnsRng.Next(0, 30))
            [void]$sb.AppendLine($line1)

            # Guaranteed nightly entry 2: 23:47 (+/-30 sec) from MANAGER-PC -> t.me
            $telMin = 47
            if ($dnsRng.Next(0, 2) -eq 0) { $telMin = 46 }
            $line2 = '[{0} 23:{1:00}:{2:00}] DNS QUERY: 192.168.10.50 -> t.me -> 149.154.167.99' -f `
                     $dateStr, $telMin, ($dnsRng.Next(0, 60))
            [void]$sb.AppendLine($line2)
        }

        $dnsLog = $sb.ToString()
        [System.IO.File]::WriteAllText($dnsPath, $dnsLog, [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $dnsPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: dns-log.txt"
    } catch {
        $msg = "[$role] Artefact 4 FAILED (dns-log.txt): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # Artefact 5: nat-table.txt
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] Artefact 5: nat-table.txt"
    try {
        $natPath = Join-Path $routerDir 'nat-table.txt'

        $natContent = @'
NAT/Port Forwarding Rules -- GR-OFFICE-ROUTER
==============================================
Rule | Protocol | WAN Port | LAN IP          | LAN Port | Description           | Status
-----|----------|----------|-----------------| ---------|-----------------------|--------
1    | TCP      | 3389     | 192.168.10.100  | 3389     | CRM Server RDP        | ENABLED
2    | TCP      | 80       | 192.168.10.100  | 80       | CRM Web App           | ENABLED
3    | TCP      | 443      | 192.168.10.100  | 443      | CRM HTTPS             | ENABLED
4    | TCP      | 5060     | 192.168.10.33   | 5060     | VoIP SIP (Amit)       | ENABLED
5    | UDP      | 5060     | 192.168.10.33   | 5060     | VoIP SIP UDP          | ENABLED

NOTE: Port 3389 forwarded to CRM-SERVER. This is how 103.41.218.91 connected remotely.
'@

        [System.IO.File]::WriteAllText($natPath, $natContent, [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $natPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: nat-table.txt"
    } catch {
        $msg = "[$role] Artefact 5 FAILED (nat-table.txt): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # Artefact 6: wan-info.txt
    # ------------------------------------------------------------------
    Write-SetupLog "[$role] Artefact 6: wan-info.txt"
    try {
        $wanPath = Join-Path $routerDir 'wan-info.txt'

        $wanContent = @'
WAN Interface -- GR-OFFICE-ROUTER -- 2026-04-17 18:55:00
=========================================================
WAN IP:           49.207.198.112 (Airtel Broadband Mumbai)
Gateway:          49.207.198.1
DNS1:             8.8.8.8
DNS2:             1.1.1.1
MAC:              00:1A:2B:3C:4D:FF (WAN interface)
Connection Type:  DHCP
Uptime:           13 days 4 hours 22 minutes
Last DHCP renew:  2026-04-17 06:00:00
Firmware:         TL-R605_V2_2.0.11
'@

        [System.IO.File]::WriteAllText($wanPath, $wanContent, [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $wanPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: wan-info.txt"
    } catch {
        $msg = "[$role] Artefact 6 FAILED (wan-info.txt): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ------------------------------------------------------------------
    # Summary
    # ------------------------------------------------------------------
    $status = if ($errors.Count -eq 0) { 'DONE' } elseif ($errors.Count -le 2) { 'DONE_WITH_CONCERNS' } else { 'NEEDS_CONTEXT' }
    Write-SetupLog ("[$role] Invoke-RoleSetup complete -- files created: $filesCreated, errors: $($errors.Count) -- status: $status")

    return @{
        Role         = $role
        FilesCreated = $filesCreated
        Errors       = $errors.ToArray()
    }
}
