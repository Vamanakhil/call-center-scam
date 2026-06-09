<#
AGENT-02 (Priya, lead generator) — Targeted setup.
Run on the AGENT-02 workstation. 192.168.10.22.
#>
[CmdletBinding()] param()
& "$PSScriptRoot\00-Master-Setup.ps1" -Role AGENT-02
