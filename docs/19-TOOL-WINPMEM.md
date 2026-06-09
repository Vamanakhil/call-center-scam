# 19 — Tool: WinPmem (RECOMAGER)

## When to use it
- **Command-line** RAM acquisition, scripted deployments.
- Includes the **pagefile** by default.
- Open source, free.
- Best when the IO wants a **single CLI command** that can be run over WinRM/PowerShell remoting.

## Pre-flight
- Download from `github.com/Velocidex/WinPmem` (or the older Rekall winpmem).
- Two binaries: `winpmem_mini_x64_rc2.exe` and `winpmem.exe`. Mini is the kernel driver version.
- Place on the same USB as the other tools.

## Step-by-step (CLI)

```cmd
:: Basic acquisition
winpmem_mini_x64_rc2.exe E:\EVIDENCE\AGENT-01.raw

:: With pagefile
winpmem_mini_x64_rc2.exe -p E:\EVIDENCE\AGENT-01.raw

:: Verbose log
winpmem_mini_x64_rc2.exe -l E:\EVIDENCE\winpmem.log E:\EVIDENCE\AGENT-01.raw
```

The tool writes the .raw file and prints a SHA1 of the dump at the end.

## When to prefer WinPmem
- **Scripted** acquisition over PowerShell remoting:
  ```powershell
  Invoke-Command -ComputerName AGENT-01 -ScriptBlock {
    E:\tools\winpmem_mini_x64_rc2.exe E:\EVIDENCE\AGENT-01.raw
  }
  ```
- When you need the **pagefile** included.
- When you want a **signed binary** (REKALL version is signed by Google).

## Common mistakes
- ❌ Running on a 32-bit system with the 64-bit binary. Use `winpmem_mini_x86.exe`.
- ❌ Running without Administrator. UAC will block the driver.
- ❌ Not hashing the output. Always hash.

## Court admissibility
- WinPmem is a Rekall/Google-signed binary, often used as the **defence-favourable** tool because the source is auditable.
- Always pair with a hash and the original tool's log.
