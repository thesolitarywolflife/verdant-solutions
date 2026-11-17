# Windows Guide — Block USB Storage & Stop App Installs (No Admin for Users)

**For:** Company **operations laptops** (2–4) + optional hardening on **management** PCs (with consent)  
**Stack:** Works with **M365 Basic + Cloudflare WARP** (USB/app control is **on the laptop**, separate from Cloudflare)  
**Who does setup:** **DevOps or IT** logs in as **Administrator once**; daily work uses a **Standard user**  
**Related:** `Medical-Billing-Startup-Phased-Security-Guide.md` §6, `Medical-Billing-Cloudflare-Zero-Trust-Basics-Guide.md`

---

## 1. What you achieve

| Goal | Method |
| --- | --- |
| User cannot copy files to **USB pendrive / external disk** | Disable USB **mass storage** driver + policy |
| User cannot **install** software (`.exe`, Store, most installers) | **Standard user** account (not Administrator) + optional extra policies |
| User cannot **turn off** USB block easily | They have no admin password |
| IT can still fix laptop | Separate **IT admin** account (or your DevOps account) |

**Not covered:** Phone-as-USB (MTP) sometimes still works for photos; **phones on Wi‑Fi** bypass USB; **admin users** can undo everything. This guide assumes **ops are not admins**.

---

## 2. Big picture (order of work)

```text
1. DevOps: sign in as LOCAL ADMIN (or setup account)
2. Create STANDARD user for daily work (e.g. verdant\ops-jane)
3. Remove standard user from Administrators group
4. Disable USB mass storage (registry or GPO)
5. Optional: extra install restrictions (Store, UAC)
6. Install Cloudflare WARP, billing apps — as ADMIN
7. User logs in only as STANDARD user from now on
```

**Rule:** Billing staff **never** use an Administrator account for email, claims, or browser work.

---

## 3. Standard user = main control for “no installs”

On Windows, **only Administrators** can install most programs for **all users** and change system settings.

| Account type | Install typical `.exe`? | Change USB policy? | Install WARP (if needed)? |
| --- | --- | --- | --- |
| **Administrator** | Yes | Yes | Yes |
| **Standard user** | Usually **No** (UAC asks admin password) | **No** | Sometimes (per-user install only) |

### 3.1 Create a standard user (DevOps — one-time per laptop)

**GUI**

1. `Settings → Accounts → Other users → Add account`  
2. Create `ops-jane` (or `verdant-jane`) **without** Microsoft account if you use local + M365 in browser only — or link later  
3. Account type: **Standard User** (not Administrator)

**PowerShell scripts (run as Administrator)** — edit **CONFIG** at the top of each file before running:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
cd "C:\path\to\Verdant-Solutions\scripts"

# 1) Edit $UserName and $PlainPassword in the script, then:
.\New-StandardBillingUser.ps1

# 2) If user is still in Administrators (or was created as admin by mistake):
#    Edit $UserName in the script, then:
.\Remove-LocalUserFromAdministrators.ps1

# 3) To reset password later: edit CONFIG in Set-LocalUserPassword.ps1, then:
.\Set-LocalUserPassword.ps1
```

Do **not** commit real passwords in git — use CONFIG on the laptop only, then clear or use a password manager.

### 3.2 IT admin account (break-glass)

- Keep **one** separate local admin, e.g. `verdant-admin`, password in company password manager — **not** shared with billing staff.  
- Or DevOps uses their own admin only during maintenance.

### 3.3 Test “cannot install”

1. Sign in as **ops-jane**.  
2. Run a random installer (e.g. 7-Zip) — should prompt **admin credentials** and **fail** if user does not know password.  
3. Microsoft Store installs — often blocked or limited for standard users (see §5).

---

## 4. Block USB pendrive / external disk

### 4.1 How it works

Windows uses the **USBSTOR** driver for most USB sticks and external drives. Setting its **Start** value to **4 (Disabled)** stops new USB storage volumes from loading.

**Requires:** **Administrator** once. **Standard user** cannot revert without admin.

**Does not block:** USB keyboard/mouse; some phones in **charge-only** mode; all phone MTP modes (varies by device).

### 4.2 Method A — PowerShell script (all Windows Pro/Home — quick)

Run **as Administrator** (see `scripts/Disable-UsbMassStorage.ps1` in this repo folder):

```powershell
# Run as Administrator
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR"
if (-not (Test-Path $regPath)) {
    Write-Error "USBSTOR registry path not found."
    exit 1
}
Set-ItemProperty -Path $regPath -Name "Start" -Value 4 -Type DWord
Write-Host "USB mass storage disabled (Start=4). Reboot recommended."

# Optional: also deny removable disks via StorageDevicePolicies (needs policy refresh)
$denyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices"
New-Item -Path $denyPath -Force | Out-Null
New-ItemProperty -Path $denyPath -Name "Deny_All" -Value 1 -PropertyType DWord -Force | Out-Null
Write-Host "RemovableStorageDevices Deny_All set. Reboot or gpupdate if domain-joined."
```

**Re-enable (IT only, e.g. approved USB):**

```powershell
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR" -Name "Start" -Value 3 -Type DWord
```

### 4.3 Method B — Group Policy (Windows Pro / Enterprise — stronger story)

If laptop has **genuine Windows 11 Pro** and you can run `gpedit.msc`:

1. `Win + R` → `gpedit.msc`  
2. **Computer Configuration → Administrative Templates → System → Removable Storage Access**  
3. Enable: **Removable Disks: Deny all access**  
4. Enable: **All Removable Storage: Deny read access** / **Deny write access** (as needed)  
5. `gpupdate /force` → **reboot**

Also under **Device Installation → Device Installation Restrictions** you can block USB device classes (advanced).

### 4.4 Method C — Later with Intune (Business Premium)

When you have **Intune**, deploy **Settings catalog**:

- **Removable storage – Deny write access**  
- **Prevent installation of removable devices**

Same outcome, **central** control for all company laptops.

### 4.5 Verify USB block

| Test | As standard user | Expected |
| --- | --- | --- |
| Insert USB stick | File Explorer | **No new drive** or “access denied” |
| Copy file to USB | | **Fails** |
| Keyboard/mouse USB | | Still works |

---

## 5. Extra restrictions on installing applications

Standard user is **80% of the solution**. Add these as **Administrator**:

### 5.1 UAC — always prompt for admins

1. `Control Panel → User Accounts → Change User Account Control settings`  
2. Set slider to **“Always notify”** (top)  
3. Standard users already cannot elevate without admin password

### 5.2 Disable Microsoft Store installs (optional)

For work-only laptops, block Store apps:

**GUI (Windows 11 Pro):**  
`gpedit.msc` → **Computer Configuration → Administrative Templates → Windows Components → Store** → **Disable all apps from Microsoft Store** → **Enabled**

**Registry (Admin):**

```powershell
$storePath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
New-Item -Path $storePath -Force | Out-Null
New-ItemProperty -Path $storePath -Name "RemoveWindowsStore" -Value 1 -PropertyType DWord -Force
```

*(Exact policy names vary slightly on Home — Home has no `gpedit`; use registry with care.)*

### 5.3 Block “Run as administrator” for standard users

They cannot use Run as admin **without** credentials — ensure they are **not** in Administrators group (§3).

### 5.4 AppLocker (Windows Pro/Enterprise only — stronger)

**Best when:** genuine **Pro**, few apps, willing to maintain allow-list.

1. `secpol.msc` → **Application Control Policies → AppLocker**  
2. Create **Executable Rules → Deny** default with **Allow** paths:  
   - `C:\Program Files\*`  
   - `C:\Program Files (x86)\*`  
   - `C:\Windows\*`  
   - `C:\Program Files\Cloudflare\Cloudflare WARP\*`  
   - Your billing app folder  
3. **Block** everything else for standard users  

AppLocker is **powerful but easy to break** billing apps — pilot one laptop first.

### 5.5 Software Restriction Policies (legacy, simpler deny)

`gpedit.msc` → **Windows Settings → Security Settings → Software Restriction Policies** — default **Disallowed** with path exceptions. Use only if familiar; AppLocker is newer.

### 5.6 What standard user can still install

| Item | Often allowed without admin? |
| --- | --- |
| **Per-user** portable apps in `%LocalAppData%` | Sometimes — block with AppLocker if needed |
| **Browser extensions** | Yes — restrict via **managed Edge** policy later (Intune) |
| **PWAs / web apps** | Yes — Cloudflare handles web |
| **Cracked installers run as user** | May write to user folder — **policy + no admin** limits system-wide installs |

Combine **USB block** + **Cloudflare** + **no local PHI** for defense in depth.

---

## 6. Recommended setup checklist (per company laptop)

Run as **Administrator**; check off in order:

- [ ] Windows updated (as far as possible)  
- [ ] Create `verdant-admin` (IT only) — strong password in vault  
- [ ] Create `ops-<name>` **standard user**  
- [ ] Confirm user **not** in Administrators  
- [ ] Run USB disable script (§4.2) → **reboot**  
- [ ] Set UAC **Always notify**  
- [ ] (Optional) Disable Store (§5.2)  
- [ ] Install **Cloudflare WARP** (as admin) → user completes Zero Trust login  
- [ ] Install billing app / Edge — as admin  
- [ ] Test install as standard user — must fail  
- [ ] Test USB — must fail  
- [ ] Hand laptop to user — **only standard account** for daily use  

---

## 7. Management personal laptops (different rules)

You **cannot** force USB block on a manager’s **personal** PC without their agreement (they may be admin on their own machine).

| Option | USB / install control |
| --- | --- |
| **Policy only** | No USB for PHI; M365 browser-only |
| **Consent + same script** | Manager agrees; DevOps runs §4 as admin **one time** |
| **Company laptop for PHI** | Preferred — full §6 checklist |

---

## 8. Limitations (tell management)

| Limit | Note |
| --- | --- |
| User with **admin password** | Can undo USB block — keep admin secret |
| **Personal laptop** owner is admin | Technical block weak without ownership change |
| **Phone** camera / WhatsApp app | Not USB-related |
| **Network exfiltration** | Use **Cloudflare** |
| **Home edition** | No `gpedit`; registry USB method still works |
| **Reboot after USB change** | Recommend reboot for consistent behaviour |

---

## 9. Troubleshooting

| Problem | Fix |
| --- | --- |
| USB still works | Reboot; confirm `USBSTOR` Start = 4; user not admin |
| Billing app won’t run | Install/fix as **admin**; add AppLocker path if used |
| WARP won’t install for user | Install as admin; user signs in to Zero Trust |
| gpedit missing | Windows **Home** — use PowerShell §4.2 only |
| Need one USB for IT | Re-enable §4.2 revert script; copy file; disable again |

---

## 10. Scripts in this repository

| File | Purpose |
| --- | --- |
| `scripts/New-StandardBillingUser.ps1` | Create local **standard** user (edit password in CONFIG first) |
| `scripts/Set-LocalUserPassword.ps1` | Change local user password (edit CONFIG first) |
| `scripts/Remove-LocalUserFromAdministrators.ps1` | Remove user from **Administrators** group |
| `scripts/Disable-UsbMassStorage.ps1` | Disable USB storage (admin) |
| `scripts/Enable-UsbMassStorage.ps1` | IT rollback (admin) |
| `scripts/Verify-LaptopHardening.ps1` | Check USB + admin membership |

**Suggested order on a new laptop** (all scripts as Administrator):

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
cd "C:\path\to\Verdant-Solutions\scripts"

.\New-StandardBillingUser.ps1          # edit CONFIG first
.\Remove-LocalUserFromAdministrators.ps1   # edit CONFIG if needed
.\Disable-UsbMassStorage.ps1
# Reboot, then as standard user test; as admin install WARP/apps
.\Verify-LaptopHardening.ps1
```

---

## 11. Future upgrade path

| When | Add |
| --- | --- |
| **Business Premium + Intune** | Same policies pushed from cloud; USB + Edge manage |
| **Genuine Pro** | Group Policy + BitLocker |
| **AppLocker** | Allow-list only billing stack |

---

## 12. Document control

| Version | Date | Notes |
| --- | --- | --- |
| 1.0 | 16 Nov 2026 | USB + standard user + optional Store/AppLocker |
| 1.1 | 16 Nov 2026 | Added scripts: New-StandardBillingUser, Set-LocalUserPassword, Remove-LocalUserFromAdministrators |

**Disclaimer:** Test on one laptop before fleet rollout. Wrong AppLocker rules can block Windows login apps — pilot carefully.