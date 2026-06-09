# 25 — Tool: USBDeview

## When to use it
- **Read-only** enumeration of all USB devices that have ever been plugged into a Windows system.
- Reads from `HKLM\SYSTEM\CurrentControlSet\Enum\USBSTOR`, `USB`, `HID`, `SCSI`, etc.
- For each device shows: VID, PID, **Serial Number**, first plug-in, last plug-in, mount points.

## Pre-flight
- `USBDeview.exe` from NirSoft.
- Administrator required to see all users' devices.

## Step-by-step

1. Run `USBDeview.exe` as Administrator.
2. Sort by **"Last Plug/Unplug Date"** descending.
3. For each row, the columns:
   - **Device Name** — Vendor + Product
   - **Description** — full name
   - **Device Type** — Mass Storage / HID / etc.
   - **Connected** — Yes/No (current state)
   - **Safe To Unplug** — Yes/No
   - **Vendor ID, Product ID, Serial Number** — the forensic fingerprint
   - **First/Last Plug Date** — when
   - **Drive Letter** — what drive it mounted
4. **File → Export Selected Items → CSV.**
5. Hash the CSV with `Get-FileHash`. Append to the case file.

## Correlating with the disk image

The Serial Number from USBDeview matches the serial in the E01 image's registry hive at:
`HKLM\SYSTEM\CurrentControlSet\Enum\USBSTOR\<VendorPID>\<Serial>\`
`HKLM\SYSTEM\CurrentControlSet\Enum\USB\<VendorPID>\<Serial>\`

To verify:
1. Mount the E01 in FTK Imager.
2. Open `C:\Windows\System32\config\SYSTEM` in Registry Explorer.
3. Navigate to that path.
4. Cross-check the serial.

## Common mistakes
- ❌ Trusting the "Connected" column for last-use time. It only updates when the device is plugged in. For a device that was plugged in last month, the **Last Plug Date** is the truth.
- ❌ Forgetting that **USBSTOR** is for storage devices. For keyboards, mice, network adapters, see **USB** + **HID** + **SCSI** keys.
- ❌ Noting only the VID/PID without the **Serial**. Two identical-model pen drives have the same VID/PID; the serial is the unique identifier.

## Court admissibility
- USBDeview's output is widely accepted. Pair with the registry hive for a complete picture.
- Always include the **CSV export** + the **utility's version** + the **hash** in the case file.
