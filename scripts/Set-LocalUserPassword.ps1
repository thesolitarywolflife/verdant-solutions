#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Sets a new password for an existing local user.
.DESCRIPTION
  Edit the CONFIG block before running. Run as Administrator.
.EXAMPLE
  .\Set-LocalUserPassword.ps1
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ========== CONFIG — edit before running ==========
$UserName      = 'ops-jane'
$PlainPassword = 'CHANGE_ME_STRONG_PASSWORD_HERE'
# ================================================

if ($PlainPassword -eq 'CHANGE_ME_STRONG_PASSWORD_HERE' -or [string]::IsNullOrWhiteSpace($PlainPassword)) {
    throw 'Set $PlainPassword in the CONFIG block before running this script.'
}

$user = Get-LocalUser -Name $UserName -ErrorAction Stop
$secure = ConvertTo-SecureString $PlainPassword -AsPlainText -Force

Set-LocalUser -Name $UserName -Password $secure

# Optional: require user to choose a new password at next Windows sign-in (uncomment if policy requires)
# cmd.exe /c "net user $UserName /logonpasswordchg:yes"

Write-Host "Password updated for '$UserName'."
Write-Host 'Store the password only in your company password manager; do not email or chat it.'