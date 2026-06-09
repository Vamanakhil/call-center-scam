<#
AGENT-05 (Vikas, IT support) — Targeted setup. Includes the "malware" stub.
Run on the AGENT-05 workstation. 192.168.10.55.
#>
[CmdletBinding()] param()
& "$PSScriptRoot\00-Master-Setup.ps1" -Role AGENT-05
