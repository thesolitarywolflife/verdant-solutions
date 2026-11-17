#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Re-enables USB mass storage (IT maintenance only).
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$regPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR'
Set-ItemProperty -Path $regPath -Name 'Start' -Value 3 -Type DWord
Write-Host "USBSTOR Start set to 3 (Manual)."

$denyPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices'
if (Test-Path $denyPath) {
    Remove-ItemProperty -Path $denyPath -Name 'Deny_All' -ErrorAction SilentlyContinue
    Write-Host "Removed Deny_All if present."
}

Write-Host "USB mass storage re-enabled. Reboot recommended."