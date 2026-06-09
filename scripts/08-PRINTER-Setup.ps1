<#
PRINTER (HP M404n) — Targeted setup. Generates the shared printer spool folder.
Run on the CRM-SERVER (or any machine that shares the printer).
#>
[CmdletBinding()] param()
& "$PSScriptRoot\00-Master-Setup.ps1" -Role PRINTER
