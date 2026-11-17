#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Creates a local standard (non-admin) user for medical billing laptops.
.DESCRIPTION
  Edit the CONFIG block below before running. Run as Administrator.
  After creation, run Remove-LocalUserFromAdministrators.ps1 if the account
  was ever added to Administrators.
.EXAMPLE
  .\New-StandardBillingUser.ps1
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ========== CONFIG — edit before running ==========
$UserName     = 'ops-jane'          # Local login name (no spaces)
$PlainPassword = 'CHANGE_ME_STRONG_PASSWORD_HERE'  # Replace before run; do not commit real passwords to git
$FullName     = 'Billing Operations'
$Description  = 'Medical billing standard user — no admin rights'
# ================================================

if ($PlainPassword -eq 'CHANGE_ME_STRONG_PASSWORD_HERE' -or [string]::IsNullOrWhiteSpace($PlainPassword)) {
    throw 'Set $PlainPassword in the CONFIG block before running this script.'
}

if ($UserName -match '\s') {
    throw 'UserName must not contain spaces.'
}

$existing = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue
if ($existing) {
    throw "Local user '$UserName' already exists. Use Set-LocalUserPassword.ps1 to change password, or pick another name."
}

$secure = ConvertTo-SecureString $PlainPassword -AsPlainText -Force

New-LocalUser -Name $UserName -Password $secure -FullName $FullName -Description $Description `
    -PasswordNeverExpires:$false -UserMayNotChangePassword:$false -AccountNeverExpires

Add-LocalGroupMember -Group 'Users' -Member $UserName

$inAdmin = Get-LocalGroupMember -Group 'Administrators' -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -like "*\$UserName" -or $_.Name -eq $UserName }

if ($inAdmin) {
    Write-Warning "User '$UserName' is in Administrators. Run Remove-LocalUserFromAdministrators.ps1"
} else {
    Write-Host "User '$UserName' created as standard user (not in Administrators)."
}

Write-Host 'Done. User must sign in once with the new password and enroll Cloudflare WARP / M365 as needed.'