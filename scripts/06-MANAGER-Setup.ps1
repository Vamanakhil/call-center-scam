<#
MANAGER-PC (Arjun, ringleader) — Targeted setup.
Run on the MANAGER-PC workstation. 192.168.10.50.
#>
[CmdletBinding()] param()
& "$PSScriptRoot\00-Master-Setup.ps1" -Role MANAGER
