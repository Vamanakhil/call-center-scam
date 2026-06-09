# 26 — Tool: Registry Explorer (Eric Zimmerman)

## When to use it
- The **gold standard** for parsing Windows registry hives from an E01 image.
- Free, open source, from `ericzimmerman.github.io`.
- Handles transaction logs (`.log1`) automatically.

## Step-by-step

1. Launch `RegistryExplorer.exe`.
2. **File → Load Hive**.
3. Navigate to the mounted E01. Load all 5 hives:
   - **SAM** → `C:\Windows\System32\config\SAM`
   - **SECURITY** → `C:\Windows\System32\config\SECURITY`
   - **SOFTWARE** → `C:\Windows\System32\config\SOFTWARE`
   - **SYSTEM** → `C:\Windows\System32\config\SYSTEM`
   - **NTUSER.DAT** (per user) → `C:\Users\<user>\NTUSER.DAT`

## Key forensic queries

### Last login
`SAM\Domains\Account\Users\<RID>\F` — Last Login (binary, parse F value).

### USB devices
- `SYSTEM\ControlSet001\Enum\USBSTOR`
- `SYSTEM\ControlSet001\Enum\USB`
- `SYSTEM\ControlSet001\Enum\HID`

### Network interfaces (DHCP-assigned IPs)
`SYSTEM\ControlSet001\Services\Tcpip\Parameters\Interfaces\<GUID>`

### Programs run (UserAssist)
`NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist\<GUID>\Count`

### RecentDocs
`NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs`

### Run keys (startup)
- `HKLM\Software\Microsoft\Windows\CurrentVersion\Run`
- `HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce`
- `HKCU\Software\Microsoft\Windows\CurrentVersion\Run`

### Shimcache / AmCache
- `SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache` (shimcache)
- `C:\Windows\AppCompat\Programs\Amcache.hve` (AmCache) — load this as a hive

## Exporting
- Right-click any key → **Export key** → save as `.reg`. Hash with `Get-FileHash`.

## Common mistakes
- ❌ Not loading the **.log1** transaction file — Registry Explorer does this automatically; if you use `regedit` instead, it doesn't, and you may miss recent changes.
- ❌ Confusing the **NTUSER.DAT** for the local SYSTEM user (which doesn't exist) with the per-user hives.
- ❌ Forgetting to check **Wow6432Node** for 32-bit programs on a 64-bit OS.

## Court admissibility
- Eric Zimmerman's tools are the most-cited in the forensic community. Reports are accepted.
- Always pair with a contemporaneous photograph of the tool being run + the hash of the exported `.reg`.
