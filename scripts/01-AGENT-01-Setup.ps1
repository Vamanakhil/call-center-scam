<#
AGENT-01 (Rahul, closer) — Targeted setup.
Run on the AGENT-01 workstation. 192.168.10.11.
#>
[CmdletBinding()] param()
& "$PSScriptRoot\00-Master-Setup.ps1" -Role AGENT-01
