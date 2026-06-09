# Server Seizure Checklist

```
ANDHERI CYBER CELL — SERVER SEIZURE CHECKLIST
Case FIR No. : ____________________
Host         : CRM-SERVER (192.168.10.100)
OS           : Windows Server 2019 Standard
Services     : XAMPP / Apache / MySQL / SMB / RDP
Date / time  : ____/____/____  ____:____ hrs IST

[ ] DO NOT POWER OFF (yet)
[ ] Photograph all 4 disks in Disk Management (volumes, hidden partitions)
[ ] Screenshot Computer Management → Services (list all services)
[ ] Screenshot Task Manager → Performance tab
[ ] Screenshot Event Viewer → System (last 50 events)
[ ] Screenshot Event Viewer → Security (last 50 events)

LIVE DATABASE CAPTURE
[ ] Open cmd as Administrator
[ ] mysqldump --all-databases --single-transaction --routines --triggers
    > E:\EVIDENCE\dump_<ts>.sql
       SHA256 : ________________________________________________
[ ] mysql -u root -e "SHOW PROCESSLIST\G"
    > E:\EVIDENCE\processlist_<ts>.txt
       SHA256 : ________________________________________________
[ ] mysql -u root -e "SHOW DATABASES\G"
    > E:\EVIDENCE\databases_<ts>.txt
       SHA256 : ________________________________________________
[ ] mysql -u root -e "SELECT user, host FROM mysql.user\G"
    > E:\EVIDENCE\users_<ts>.txt
       SHA256 : ________________________________________________
[ ] mysql -u root -e "SHOW VARIABLES LIKE '%dir%'\G"
    > E:\EVIDENCE\datadir_<ts>.txt
       SHA256 : ________________________________________________
[ ] Screenshot MySQL Workbench → Server Status

NETWORK
[ ] netstat -ano     → E:\VOL\crm_netstat.txt  SHA256 : ____________
[ ] netstat -b       → E:\VOL\crm_netstat_b.txt  SHA256 : __________
[ ] qwinsta          → E:\VOL\crm_qwinsta.txt  SHA256 : ____________
[ ] net session      → E:\VOL\crm_netsession.txt  SHA256 : __________
[ ] net share        → E:\VOL\crm_netshare.txt  SHA256 : ____________
[ ] Wireshark 2-min capture → E:\EVIDENCE\crm_capture.pcapng  SHA256 : _

FIREWALL & SECURITY LOG
[ ] wevtutil epl Security    → E:\VOL\crm_security.evtx  SHA256 : ____
[ ] wevtutil epl System      → E:\VOL\crm_system.evtx    SHA256 : ____
[ ] wevtutil epl Application → E:\VOL\crm_app.evtx       SHA256 : ____
[ ] Copy C:\Windows\System32\LogFiles\Firewall\pfirewall.log
                          → E:\VOL\crm_firewall.log  SHA256 : ______

RAM
[ ] Belkasoft RAM Capture  → E:\EVIDENCE\crm-server.mem
       SHA256 : ________________________________________________
       (NOTE: 15-30 min on a server. Do not pull cable until done.)

NETWORK CABLE
[ ] Photograph cable + port before pulling
[ ] Label port
[ ] Pull cable

POWER OFF (controlled)
[ ] Start → Shutdown (NOT pull plug)
[ ] Wait for full shutdown
[ ] Photograph power-off state

IMAGING (next 8+ hours at CCL)
[ ] Disk 1 (\\.\PHYSICALDRIVE0) → E01, 2 TB
[ ] Disk 2 (\\.\PHYSICALDRIVE1) → E01, 2 TB
[ ] Each disk hashed, verified
[ ] FTK log file saved, hashed, attached to imaging log

PACKAGING
[ ] Server in large anti-static bag
[ ] "FRAGILE / THIS SIDE UP" label
[ ] Tamper-evident seal
[ ] Chain of custody signed
[ ] Transport to CCL
```
