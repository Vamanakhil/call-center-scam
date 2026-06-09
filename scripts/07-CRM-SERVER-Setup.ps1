<#
CRM-SERVER -- Targeted setup.
Run on the CRM-SERVER (192.168.10.100). Generates a MySQL dump and web-app stub.
For the live MySQL experience, install XAMPP first, then run the per-table
PowerShell inside XAMPP's htdocs.
#>
[CmdletBinding()] param()
& "$PSScriptRoot\00-Master-Setup.ps1" -Role CRM-SERVER
