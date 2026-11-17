#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Disables USB mass storage (pendrives, most external disks) on Windows.
.DESCRIPTION
  Sets USBSTOR Start=4 and RemovableStorageDevices Deny_All for medical billing laptops.
  Reboot recommended after running.
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$regPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR'
if (-not (Test-Path $regPath)) {
    throw "USBSTOR registry path not found."
}

$current = Get-ItemProperty -Path $regPath -Name 'Start' -ErrorAction SilentlyContinue
Set-ItemProperty -Path $regPath -Name 'Start' -Value 4 -Type DWord
Write-Host "USBSTOR Start was '$($current.Start)'; now set to 4 (Disabled)."

$denyPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices'
New-Item -Path $denyPath -Force | Out-Null
New-ItemProperty -Path $denyPath -Name 'Deny_All' -Value 1 -PropertyType DWord -Force | Out-Null
Write-Host "RemovableStorageDevices\Deny_All = 1."

Write-Host "Done. Reboot the laptop for best results."