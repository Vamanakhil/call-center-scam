<#
AGENT-04 (Sneha, payment chaser) — Targeted setup.
Run on the AGENT-04 workstation. 192.168.10.44.
#>
[CmdletBinding()] param()
& "$PSScriptRoot\00-Master-Setup.ps1" -Role AGENT-04
