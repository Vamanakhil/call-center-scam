# 02 — Network Diagram

## 1. Topology

```
            ┌────────────────┐
            │   ISP / WAN    │  203.45.78.91 (public, dhcp)
            │   (fiber)      │
            └────────┬───────┘
                     │ RJ45
            ┌────────┴───────┐
            │   ROUTER       │  WAN: dhcp
            │   TP-Link      │  LAN: 192.168.10.1 / 24
            │   WR940N       │  DHCP server: ON
            │                │  DNS: 8.8.8.8, 1.1.1.1
            │   Port 1 ↓     │
            └────────┬───────┘
                     │ uplink
            ┌────────┴───────┐
            │   SWITCH       │  TP-Link SG1008D (unmanaged)
            │   8-port       │  No config
            │   gigabit      │
            └─┬──┬──┬──┬──┬──┘
              │  │  │  │  │
              │  │  │  │  └──── AGENT-05 (Vikas) 192.168.10.55
              │  │  │  └─────── AGENT-04 (Sneha) 192.168.10.44
              │  │  └────────── AGENT-03 (Amit)  192.168.10.33
              │  └───────────── AGENT-02 (Priya) 192.168.10.22
              └──────────────── AGENT-01 (Rahul) 192.168.10.11
                                          │
                                          │ extra patch
                                  ┌───────┴────────┐
                                  │  PRINTER       │  192.168.10.30
                                  │  HP M404n      │  static
                                  └────────────────┘
                                  ┌────────────────┐
                                  │  CRM-SERVER    │  192.168.10.100
                                  │  Dell T340     │  static (server)
                                  │  Server 2019   │
                                  │  XAMPP + MySQL │
                                  └────────────────┘
                                  ┌────────────────┐
                                  │  MANAGER-PC    │  192.168.10.50
                                  │  Custom build  │  static (manual)
                                  │  Win 11 Pro    │
                                  └────────────────┘
```

## 2. IP addressing scheme

| Host | IP | Subnet | Lease | Notes |
|---|---|---|---|---|
| Router | 192.168.10.1 | /24 | n/a | Gateway, DHCP server |
| AGENT-01 | 192.168.10.11 | /24 | 24h DHCP | Rahul |
| AGENT-02 | 192.168.10.22 | /24 | 24h DHCP | Priya |
| AGENT-03 | 192.168.10.33 | /24 | 24h DHCP | Amit |
| AGENT-04 | 192.168.10.44 | /24 | 24h DHCP | Sneha |
| AGENT-05 | 192.168.10.55 | /24 | **Static reservation** | Vikas (never loses IP) |
| MANAGER-PC | 192.168.10.50 | /24 | Manual | Arjun |
| CRM-SERVER | 192.168.10.100 | /24 | Manual | The backend |
| PRINTER | 192.168.10.30 | /24 | Static reservation | HP |
| Default gateway | 192.168.10.1 | | | |
| Subnet mask | 255.255.255.0 | | | |
| DNS 1 | 8.8.8.8 | | | |
| DNS 2 | 1.1.1.1 | | | |

## 3. Router port-forward rules (must be found by trainee)

```
Service   External Port   Internal IP           Internal Port   Protocol
RDP       3389            192.168.10.100        3389            TCP
HTTP      80              192.168.10.100        80              TCP   (CRM public-facing)
HTTPS     443             192.168.10.100        443             TCP   (unused but present)
```

The RDP forward is what allows `Arjun` to remote in from home. The **47 failed login attempts** in the server's Security log came through this port forward from a Bangalore-based IP that resolves to the **AnyDesk Singapore relay** (`103.41.218.x`).

## 4. DHCP lease table (frozen at raid time)

```
192.168.10.11   AA:BB:CC:11:22:33   AGENT-01      2026-04-18 09:14
192.168.10.22   AA:BB:CC:22:33:44   AGENT-02      2026-04-18 09:15
192.168.10.33   AA:BB:CC:33:44:55   AGENT-03      2026-04-18 09:16
192.168.10.44   AA:BB:CC:44:55:66   AGENT-04      2026-04-18 09:17
192.168.10.55   AA:BB:CC:55:66:77   AGENT-05      STATIC RESERVATION
192.168.10.50   AA:BB:CC:50:50:50   MANAGER-PC    manual
192.168.10.100  AA:BB:CC:00:01:00   CRM-SERVER    manual
192.168.10.30   AA:BB:CC:30:30:30   PRINTER       STATIC RESERVATION
```

## 5. DNS resolver cache (last rotation: 17-Apr-2026 02:00)

```
t.me                                A    149.154.167.99
goldenreturns.example               A    192.168.10.100
web.telegram.org                    A    149.154.167.99
linkedin.com                        A    13.107.42.14
sales.linkedin.com                  A    13.107.42.14
facebook.com                        A    157.240.22.35
business.facebook.com               A    157.240.22.35
anydesk.com                         A    54.93.114.118
relay.anydesk.com                   A    103.41.218.91
static-cdn.zoom.us                  A    3.18.108.140
hdfcbank.com                        A    23.61.194.142
npci.org.in                         A    14.140.135.66
```

The `relay.anydesk.com` and `t.me` lookups are the smoking gun for the Telegram C2 channel and the AnyDesk remote access.

## 6. SMB sessions (on CRM-SERVER at seizure time)

```
SessionId  User            Client IP          Open files
2          ARJUN\admin     192.168.10.50      D:\Victims\victims_master.xlsx (read)
3          ARJUN\admin     192.168.10.50      D:\Backups\old\golden_crm_backup_2026-04-15.sql (read)
4          VIKAS\itadmin   192.168.10.55      D:\CRM\uploads\call_recording_2026-04-17_2230.wav (write)
5          ARJUN\admin     103.41.218.91      (RDP session, clipboard active)
```

## 7. Windows Firewall log (CRM-SERVER, last 100 lines)

```
2026-04-17 23:14:22  DROP  TCP  103.41.218.91:49521 -> 192.168.10.100:3389  52  (SYN)
2026-04-17 23:14:23  DROP  TCP  103.41.218.91:49521 -> 192.168.10.100:3389  52  (SYN)
2026-04-17 23:14:24  DROP  TCP  103.41.218.91:49521 -> 192.168.10.100:3389  52  (SYN)
... (47 attempts) ...
2026-04-17 23:18:09  ALLOW TCP  103.41.218.91:49521 -> 192.168.10.100:3389  52  (SYN,ACK)
2026-04-17 23:18:09  ALLOW TCP  103.41.218.91:49522 -> 192.168.10.100:3389  52  (ESTABLISHED)
2026-04-17 23:42:11  ALLOW TCP  192.168.10.50:49231 -> 192.168.10.100:445  60  (SMB session)
```

## 8. Active TCP connections (snapshot at raid time, from CRM-SERVER)

```
Local              Remote             State         PID
192.168.10.100:80  192.168.10.11:51234  ESTABLISHED  4 (System)
192.168.10.100:80  192.168.10.22:51240  ESTABLISHED  4
192.168.10.100:80  192.168.10.33:51242  ESTABLISHED  4
192.168.10.100:80  192.168.10.44:51244  ESTABLISHED  4
192.168.10.100:80  192.168.10.55:51246  ESTABLISHED  4
192.168.10.100:445 192.168.10.50:49231  ESTABLISHED  4 (SMB from manager)
192.168.10.100:3389 103.41.218.91:49522 ESTABLISHED 3584 (svchost - RDP from anydesk relay)
```

## 9. ARP cache correlation (cross-system)

If the trainee pulls `arp -a` on multiple agents, they will see:

| Source | Sees 192.168.10.50 (manager) | Sees 192.168.10.55 (IT) | Sees 192.168.10.100 (server) |
|---|---|---|---|
| AGENT-01 | **Yes** (00:50:50:50) — manager watching | Yes | Yes |
| AGENT-02 | **Yes** | Yes | Yes |
| AGENT-03 | **Yes** | Yes | Yes |
| AGENT-04 | **Yes** | **Yes (recent)** | Yes |
| AGENT-05 | Yes | (self) | **Yes (frequent)** |

The fact that **AGENT-04 and AGENT-05** have very recent ARP entries for each other (last write <5 min) suggests they are coordinating in real time.

## 10. Internal services running

- **Apache 2.4** (port 80) — serves the `golden_crm` web app
- **MySQL 8.0** (port 3306) — `golden_crm` database
- **SMB** (port 445) — file shares
- **RDP** (port 3389) — remote desktop
- **WinRM** (port 5985) — powershell remoting (admin)
- **VNC** (port 5900) — installed but **not** running (residual — shows Vikas tested it)
