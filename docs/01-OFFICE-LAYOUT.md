# 01 — Office Layout

> Kuber Complex, 3rd Floor, Flat 301, Andheri West, Mumbai — 400 058
> Total area: ~950 sq ft. Single-floor rental flat converted to a call centre.

## 1. Top-down view (ASCII)

```
                ← 35 ft →
   ┌────────────────────────────────────────────────────────────┐  ↑
   │                                                              │  │
   │   ┌──────────┐                          ┌──────────────┐     │  │
   │   │  PRINTER │                          │   MANAGER     │     │  │
   │   │  HP      │                          │   DESK        │     │  │
   │   │  M404n   │                          │   Arjun       │     │  │
   │   └──────────┘                          │   MANAGER-PC  │     │  │
   │                                          └──────────────┘     │  │
   │   ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐                │  │
   │   │ A1  │  │ A2  │  │ A3  │  │ A4  │  │ A5  │                │  30 ft
   │   │Rahu │  │Priya│  │ Amit│  │Sneha│  │Vikas│                │  │
   │   │  □  │  │  □  │  │  □  │  │  □  │  │  □  │                │  │
   │   └─────┘  └─────┘  └─────┘  └─────┘  └─────┘                │  │
   │      │        │        │        │        │                   │  │
   │      └────────┴────────┴────────┴────────┘                   │  │
   │                          │                                   │  │
   │                  ┌───────┴────────┐                          │  │
   │                  │   SWITCH (8p)  │                          │  │
   │                  │   TP-Link      │                          │  │
   │                  └───────┬────────┘                          │  │
   │                          │                                   │  │
   │                  ┌───────┴────────┐                          │  │
   │                  │   ROUTER       │                          │  │
   │                  │   TP-Link WR940N│                         │  │
   │                  │   WAN: dhcp    │                          │  │
   │                  └───────┬────────┘                          │  │
   │                          │ Fiber drop                        │  │
   │                          ↓                                   │  │
   │   ┌──────────────────────────────────────────────┐          │  │
   │   │  ENTRANCE / DOOR                              │          │  │
   │   │  (reception, no receptionist)                 │          │  │
   │   └──────────────────────────────────────────────┘          │  ↓
   └────────────────────────────────────────────────────────────┘
            ↑ single door, grilled, no camera
            ↑ balcony at back (escape route for manager)
```

## 2. Per-workstation detail

### 2.1 AGENT-01 (Rahul) — leftmost

| Item | Detail |
|---|---|
| Desk | Particle board, L-shape, 4 ft × 3 ft |
| Monitor | Dell 22" 1080p |
| PC | HP ProDesk 400 G5, i5-8400, 8 GB RAM, 1 TB HDD |
| Headset | Jabra Biz 2300 with boom mic |
| Notes | A1 has the closer script printed and pinned to the wall. A whiteboard behind has the 12 hot leads for the day. A small desk calendar has "Target: 5 lakhs / day" scribbled. |

### 2.2 AGENT-02 (Priya)
| Item | Detail |
|---|---|
| PC | Lenovo ThinkCentre M720q, i5-8400T, 16 GB RAM, 512 GB SSD |
| Notes | Two 24" monitors — one for LinkedIn, one for the CRM. A sticky note says "renew Sales Nav trial — expires 21-Apr". |

### 2.3 AGENT-03 (Amit)
| Item | Detail |
|---|---|
| PC | Assembled, Ryzen 5 3600, 16 GB, 256 GB SSD + 1 TB HDD |
| Notes | A MicroSD-to-USB adapter is plugged into the front panel with a 64 GB SanDisk card. The card holds 47 call recordings (`.wav` placeholders). |

### 2.4 AGENT-04 (Sneha)
| Item | Detail |
|---|---|
| PC | Dell OptiPlex 5070, i5-9500, 8 GB, 256 GB SSD |
| Notes | A folder on the desktop `UPI_Screenshots` with 312 PNGs of payment confirmations from victims. |

### 2.5 AGENT-05 (Vikas)
| Item | Detail |
|---|---|
| PC | HP EliteDesk 800 G5, i7-9700, 32 GB RAM, 512 GB NVMe + 2 TB HDD |
| Notes | The IT guy. Has a Raspberry Pi 4 on the shelf behind him running a script that pings the manager's phone every 60 sec. A spare HDD is in the drawer labeled `BACKUP`. A second, smaller pen drive is hidden inside a hollowed-out book (`Hacking Exposed 7th Ed.`). |

### 2.6 MANAGER-PC (Arjun) — back-right corner
| Item | Detail |
|---|---|
| PC | Custom build, i9-13900K, 64 GB RAM, 2 TB NVMe + 4 TB HDD |
| Notes | Behind the manager's chair is a **false-bottom drawer** with a 32 GB SanDisk pen drive inside containing the **deleted** `victims_old.xlsx`. The manager's **VeraCrypt container** is mounted as `E:` — `D:\Manager\vault.veracrypt`. The mount is currently open (do not close it). |

### 2.7 CRM-SERVER — under the manager's desk
| Item | Detail |
|---|---|
| Hardware | Dell PowerEdge T340, Xeon E-2236, 32 GB ECC, 2× 2 TB SATA HDD in RAID-1 |
| OS | Windows Server 2019 Standard |
| Software | XAMPP 8.2, MySQL 8.0, Apache 2.4, the `golden_crm` web app, a hidden `D:\Backups\old\` share |
| Notes | The server has **two NICs** — one on the office LAN, one on a **separate management VLAN** for RDP from `Arjun`'s home. There are 47 failed RDP attempts in the Security log from `103.41.218.x` (Bangalore-based AnyDesk relay). |

### 2.8 PRINTER
| Item | Detail |
|---|---|
| Hardware | HP LaserJet Pro M404n (networked) |
| IP | `192.168.10.30` (static) |
| Spool share | `\\PRINTER\Spool` (read-only) |
| Notes | The printer's internal flash contains the last 32 print jobs. The paper tray has a partially-printed `Mule_Accounts_Q4.pdf`. |

### 2.9 ROUTER
| Item | Detail |
|---|---|
| Hardware | TP-Link TL-WR940N |
| WAN IP | `203.45.78.91` (synthetic) |
| LAN IP | `192.168.10.1` |
| Notes | Stock firmware, default `admin`/`admin` credentials. The instructor can demonstrate the console-cable bypass. |

### 2.10 SWITCH
| Item | Detail |
|---|---|
| Hardware | TP-Link TL-SG1008D (8-port unmanaged gigabit) |
| Notes | No config to grab. Seized for MAC-address table only. |

## 3. Loose evidence on the floor / shelves

- **4 pen drives** in a plastic box on the shelf above AGENT-05 (1 × 32 GB empty, 1 × 16 GB labeled "BACKUP", 1 × 8 GB containing a CRM export CSV, 1 × 64 GB the hidden book one)
- **A4 file with 47 printed sheets** of victim complaints