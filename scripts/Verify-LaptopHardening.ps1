<#
.SYNOPSIS
  Quick check: USB block status and local Administrators group members.
.NOTES
  Run as any user for read-only checks; admin not required.
#>
Write-Host "=== USB mass storage (USBSTOR Start) ==="
$regPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR'
if (Test-Path $regPath) {
    $start = (Get-ItemProperty -Path $regPath -Name 'Start' -ErrorAction SilentlyContinue).Start
    $meaning = switch ($start) {
        4 { 'Disabled (expected for billing laptops)' }
        3 { 'Manual (USB storage allowed)' }
        default { "Start=$start" }
    }
    Write-Host "Start = $start — $meaning"
} else {
    Write-Host "USBSTOR path not found."
}

$denyPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices'
$deny = (Get-ItemProperty -Path $denyPath -Name 'Deny_All' -ErrorAction SilentlyContinue).Deny_All
Write-Host "RemovableStorageDevices Deny_All = $deny"

Write-Host "`n=== Local Administrators ==="
Get-LocalGroupMember -Group 'Administrators' | ForEach-Object { Write-Host $_.Name }

Write-Host "`n=== Current user ==="
Write-Host $env:USERNAME
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
Write-Host "Running elevated: $isAdmin"
if ($isAdmin) {
    Write-Host "Note: Daily billing work should use a standard user, not an elevated session."
}