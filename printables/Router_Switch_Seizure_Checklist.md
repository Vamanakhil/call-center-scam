# Router / Switch Seizure Checklist

```
ANDHERI CYBER CELL — ROUTER / SWITCH SEIZURE CHECKLIST
Case FIR No. : ____________________
Device       : ☐ Router (TP-Link WR940N)   ☐ Switch (TP-Link SG1008D)
IP           : ____________________
Date / time  : ____/____/____  ____:____ hrs IST

ROUTER ONLY

[ ] Photograph WAN port + cable
[ ] Photograph LAN ports (label which cable goes where)
[ ] Photograph all sides, including S/N sticker
[ ] Photograph power adapter
[ ] Photograph all status LEDs
[ ] Photograph web UI login page
[ ] If default creds work (admin/admin):
      [ ] Screenshot Status page
      [ ] Screenshot DHCP lease table
      [ ] Screenshot Port Forwarding / Virtual Servers
      [ ] Screenshot DNS settings
      [ ] Screenshot Wireless settings
      [ ] Screenshot System Log (if available)
[ ] If creds do NOT work:
      [ ] Use console cable (RJ45-to-USB) at 9600 8N1
      [ ] `enable`
      [ ] `copy running-config tftp://<laptop-ip>/<case>.cfg`
      [ ] Hash the saved .cfg
[ ] Photograph all cables before unplugging
[ ] Unplug WAN, then LAN
[ ] Bag the device whole (DO NOT open it)
[ ] Tamper-evident seal
[ ] Chain of custody signed

SWITCH ONLY

[ ] Photograph all ports with labels
[ ] Photograph all sides, including S/N sticker
[ ] Bag the device whole
[ ] Tamper-evident seal
[ ] Chain of custody signed
[ ] (Switches have no volatile data — they are stateless)

EVIDENCE TO RECORD
[ ] Running config (.cfg)         SHA256 : ____________________________
[ ] DHCP lease table (screenshot) SHA256 : ____________________________
[ ] Web UI screenshots            SHA256 : ____________________________
[ ] Port-forward rules            SHA256 : ____________________________
```
