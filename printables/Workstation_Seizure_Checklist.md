# Workstation Seizure Checklist

Print **one** per workstation. Tick as you go.

```
ANDHERI CYBER CELL — WORKSTATION SEIZURE CHECKLIST
Case FIR No. : ____________________
Host         : ____________________  (AGENT-01..05 / MANAGER-PC)
User         : ____________________
IP           : ____________________
Date / time  : ____/____/____  ____:____ hrs IST

POWER STATE
[ ] Photograph screen with windows visible
[ ] Photograph desktop, taskbar, system tray
[ ] Note hostname, logged-in user, OS version, IP
[ ] Active sessions (qwinsta output):  _________________________

RAM & VOLATILE
[ ] Insert write-blocked USB → Belkasoft RAM capture → E:\EVIDENCE\<host>.mem
       SHA256 : ________________________________________________
[ ] tasklist /v       → E:\VOL\<host>_tasklist.txt       SHA256 : ____
[ ] tasklist /svc     → E:\VOL\<host>_tasklist_svc.txt   SHA256 : ____
[ ] netstat -ano      → E:\VOL\<host>_netstat.txt        SHA256 : ____
[ ] netstat -b        → E:\VOL\<host>_netstat_b.txt      SHA256 : ____
[ ] ipconfig /all     → E:\VOL\<host>_ipconfig.txt       SHA256 : ____
[ ] ipconfig /displaydns → E:\VOL\<host>_dns.txt         SHA256 : ____
[ ] arp -a            → E:\VOL\<host>_arp.txt            SHA256 : ____
[ ] route print       → E:\VOL\<host>_route.txt          SHA256 : ____
[ ] net session       → E:\VOL\<host>_netsession.txt     SHA256 : ____
[ ] net share         → E:\VOL\<host>_netshare.txt       SHA256 : ____
[ ] net user          → E:\VOL\<host>_netuser.txt        SHA256 : ____
[ ] net localgroup administrators → E:\VOL\<host>_admins.txt  SHA256 : ____
[ ] wmic process list full        → E:\VOL\<host>_wmic.txt      SHA256 : ____
[ ] wmic startup list full        → E:\VOL\<host>_startup.txt  SHA256 : ____
[ ] wmic service list brief       → E:\VOL\<host>_services.txt SHA256 : ____
[ ] wevtutil epl Security         → E:\VOL\<host>_security.evtx SHA256 : ____
[ ] wevtutil epl System           → E:\VOL\<host>_system.evtx   SHA256 : ____
[ ] wevtutil epl Application      → E:\VOL\<host>_app.evtx      SHA256 : ____
[ ] sc query                      → E:\VOL\<host>_sc.txt        SHA256 : ____
[ ] reg export HKLM\…\Run        → E:\VOL\<host>_run.txt        SHA256 : ____
[ ] Screenshot clipboard          → IMG-______
[ ] Screenshot desktop            → IMG-______

NETWORK
[ ] Photograph network cable + port before unplugging
[ ] Label the port (label # _________)
[ ] Pull network cable
[ ] Photograph post-disconnect state

POWER OFF
[ ] Method : ☐ Start menu  ☐ 4-second hold  ☐ Other (note: _______)
[ ] If encrypted, confirm RAM captured BEFORE power off

PHYSICAL
[ ] Photograph back panel (S/N sticker)
[ ] Photograph all sides
[ ] Photograph asset tags
[ ] Photograph all USB ports (cables plugged in)

PACKAGING
[ ] HDD removed, in separate bag, tagged MSL-2026-___
[ ] PC in anti-static bag, tagged MSL-2026-___
[ ] Tamper-evident seal across bag opening
[ ] Hashes written on bag label in permanent ink
[ ] Chain of custody form filled and signed
[ ] Witness signature obtained

TRANSPORT
[ ] Item carried to transport vehicle by Officer ______
[ ] Item loaded in tamper-evident transport bag
[ ] Transport log signed
```
