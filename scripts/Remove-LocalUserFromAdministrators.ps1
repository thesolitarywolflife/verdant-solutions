#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Removes a local user from the built-in Administrators group.
.DESCRIPTION
  Edit $UserName in CONFIG before running. Keeps break-glass admins untouched.
  Run as Administrator after creating a user who was mistakenly made admin.
.EXAMPLE
  .\Remove-LocalUserFromAdministrators.ps1
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ========== CONFIG — edit before running ==========
$UserName = 'ops-jane'   # Local account to demote from Administrator
# ================================================

$members = Get-LocalGroupMember -Group 'Administrators'
$target = $members | Where-Object {
    $_.Name -like "*\$UserName" -or
    $_.Name -eq $UserName -or
    $_.Name -like "$UserName@*"
}

if (-not $target) {
    Write-Host "User '$UserName' is not a member of Administrators (already standard or not found)."
    Get-LocalGroupMember -Group 'Administrators' | ForEach-Object { Write-Host "  Admin: $($_.Name)" }
    exit 0
}

$adminCount = ($members | Measure-Object).Count
if ($adminCount -le 1) {
    throw 'Refusing to remove the last Administrator on this machine. Create verdant-admin first.'
}

Remove-LocalGroupMember -Group 'Administrators' -Member $UserName -ErrorAction Stop
Write-Host "Removed '$UserName' from Administrators."

Write-Host 'Remaining Administrators:'
Get-LocalGroupMember -Group 'Administrators' | ForEach-Object { Write-Host "  $($_.Name)" }