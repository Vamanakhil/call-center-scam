# 28 — Tool: Wireshark + NetworkMiner (PCAP analysis)

## When to use it
- Captured network traffic from a server, from a network tap, or from a malware sandbox.
- The lab scenario: 2-minute Wireshark capture on the CRM-SERVER LAN interface.

## Step-by-step — Wireshark live capture

1. Install Wireshark 4.x.
2. Run as Administrator.
3. **Capture → Options** → select the LAN interface.
4. **Capture filter:** `host 192.168.10.0/24` (to limit to the office LAN).
5. Click **Start**. Capture for 2 minutes.
6. **Stop**. **File → Save As → crm_server_capture.pcapng**.

## Step-by-step — Wireshark analysis

1. Open the .pcapng.
2. **Statistics → Conversations** → TCP tab. List all conversations. Sort by bytes.
3. **Statistics → Endpoints** → IPv4. Find the IPs.
4. **Statistics → DNS** → list all DNS queries. Look for unusual domains (`relay.anydesk.com`, `t.me`).
5. **Statistics → HTTP → Requests** → list all HTTP requests. Find the CRM login posts.
6. **Statistics → Protocol Hierarchy** → confirm what protocols are present.

## Key filters
- `dns.qry.name contains "telegram"` — find Telegram C2
- `http.request.uri contains "goldenreturns"` — find CRM access
- `ip.addr == 103.41.218.91` — find AnyDesk relay traffic
- `tcp.port == 3389` — RDP traffic
- `smb2` — file-share traffic
- `tls.handshake.extensions_server_name contains "drive.google.com"` — Google Drive access

## Step-by-step — NetworkMiner (passive sniffing)

NetworkMiner is **passive** — it listens, doesn't send. It auto-extracts:
- DNS queries
- HTTP requests + files
- SMTP/POP3/IMAP emails
- FTP files
- SMB files (downloaded files from the file share)
- Operating-system fingerprints

1. Install NetworkMiner.
2. Select the interface. Click **Start**.
3. It builds a host list. For each host, click to see sessions.
4. **Files tab** lists every file extracted.
5. **Images tab** lists every image (including from UPI screenshots if the suspect was viewing them in Chrome).
6. **Credentials tab** lists any unencrypted passwords.
7. **File → Export** → save to case folder.

## Common mistakes
- ❌ Capturing on the wrong interface (Wi-Fi vs. Ethernet).
- ❌ Letting the capture run too long (100+ GB pcap). Use a capture filter.
- ❌ Saving as `.pcap` instead of `.pcapng` (older format, less metadata).

## Court admissibility
- PCAPs are **excellent evidence** when captured properly. Pair with a contemporaneous photograph of Wireshark running.
- Hash the .pcapng. Append to the case file.
- If the capture is from a malware sandbox, document the sandbox configuration.
