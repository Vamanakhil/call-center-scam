<#
ROUTER (TP-Link WR940N) -- Targeted setup. Generates the router config artifact files.
Run on the CRM-SERVER (or any machine with TFTP/serial access to the router).
#>
[CmdletBinding()] param()
& "$PSScriptRoot\00-Master-Setup.ps1" -Role ROUTER
