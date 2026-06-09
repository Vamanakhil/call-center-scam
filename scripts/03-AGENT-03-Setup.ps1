<#
AGENT-03 (Amit, VoIP caller) — Targeted setup.
Run on the AGENT-03 workstation. 192.168.10.33.
#>
[CmdletBinding()] param()
& "$PSScriptRoot\00-Master-Setup.ps1" -Role AGENT-03
