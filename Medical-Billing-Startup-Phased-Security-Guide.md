# Small Startup Security Guide — Phased & Cost-Effective

**Document type:** Practical guide for management + hands-on setup (DevOps)  
**Company profile:** Very small medical billing startup (India)  
**Devices today:**

- **~4 management laptops** — personal devices (owners / managers)  
- **~2–4 operations laptops** — company-owned (billing & follow-up staff)

**Goal now:** Stop data going to personal cloud, USB/pendrive, WhatsApp, and personal email — using **affordable** controls.  
**Goal later:** Full company setup (Microsoft Entra, Intune, DLP) as revenue and team size grow.

**Audience:** You are a **DevOps engineer**, not a full-time IT admin. This doc explains *what* each Microsoft piece is, *what it costs in India (indicative)*, and *what to do this month* vs *next year*.

**Management decision (current plan):**

| Layer | Choice |
| --- | --- |
| **Office cloud, email, identity** | **Microsoft 365 Business Basic** for all staff |
| **Desktop operating system** | **Existing Windows installs on laptops** — management has indicated these are **non-genuine (unlicensed / cracked) Windows**, not purchased OEM or retail licences |
| **Desktop Microsoft Office** | **Not licensed separately** — use **Office on the web** (Word, Excel, PowerPoint, Outlook) included in Business Basic |

This guide is written for **that** combination: **M365 Basic + browser/web workflow**, with **manual laptop hardening** until you can afford **genuine Windows Pro** (or **Business Premium** with a Pro upgrade right) for company machines.

**Related docs:**

- `Medical-Billing-M365-Zscaler-Implementation-Guide.md` (**approved:** M365 Business Basic + Zscaler — scope, pricing, step-by-step)  
- `Medical-Billing-Workstation-Security-Proposal.md` (AWS virtual desktop — strongest “no data on laptop”)  
- `Medical-Billing-Company-Laptop-Security-Proposal.md` (full company-laptop + Entra/Intune program)

---

## 1. Executive summary (for management)

| Reality | What to do |
| --- | --- |
| **Licenced stack:** **M365 Business Basic only** — no separate Windows or desktop Office budget for now | Use **company OneDrive / SharePoint + Office in the browser**; **no** saving PHI to `Desktop` or `Downloads` |
| **Non-genuine Windows** on laptops | You can still do **USB block, standard user, DNS filter, MFA on M365** — you **cannot** honestly claim **BitLocker, Intune, or full patch trust** until Windows is **genuine Pro** |
| **Management personal laptops** cannot be locked like company PCs | **Browser-only PHI** — `outlook.office.com`, `office.com`, billing SaaS; signed policy |
| **Company operations laptops** | Same M365 rules + Section 6 hardening adapted for **Section 1.1** (no BitLocker path until legal Windows) |
| Long-term target | **Genuine Windows 11 Pro** on company laptops, then **Business Premium** (or Basic + Intune) on **ops users only** |

**Phase 1 stack (matches management plan)**

1. **Microsoft 365 Business Basic** for all staff — `@company.com` mail, **OneDrive 1 TB**, Teams, **web Office** (no desktop Office licence required).  
2. **MFA (2FA)** in Entra ID — included with Basic; enable for every user.  
3. **Work pattern:** claims and ERAs in **OneDrive/SharePoint** or billing SaaS — **not** on local disk; Excel/Word via **browser** when needed.  
4. **Company laptops (2–4):** Section 6 hardening **without** relying on BitLocker or Group Policy (see **Section 1.1**).  
5. **Zscaler (ZIA + Client Connector)** — primary web/DLP control (see `Medical-Billing-M365-Zscaler-Implementation-Guide.md`). Cloudflare Zero Trust was an optional interim alternative.  
6. **Written rules** — Section 5 (no USB/personal cloud/WhatsApp for PHI).

**Indicative annual cost (8 users — M365 only for Phase 1)**

| Item | Users | Indicative price (India, before 18% GST) |
| --- | --- | --- |
| **Microsoft 365 Business Basic** | 8 | ~₹170/user/month × 8 ≈ **₹16,320/year** |
| Windows / desktop Office | — | **₹0 in current plan** (not purchased; see risks in **Section 1.1**) |
| Company laptop hardening | 2–4 | **₹0** (DevOps time only) |
| Cloudflare Zero Trust Gateway | Small team | **Free** tier (verify limits on [Cloudflare Zero Trust pricing](https://www.cloudflare.com/plans/zero-trust-services/)) |
| **Future (budget separately):** genuine **Windows 11 Pro** per company laptop | 2–4 | ~**₹12,000–16,000/device** one-time — **required before Intune / BitLocker / client audits** |

> **Prices change.** Confirm on [Microsoft 365 India pricing](https://www.microsoft.com/en-in/microsoft-365/business/compare-all-microsoft-365-business-products) before purchase. Figures here are for **planning**, not a quote. GST is usually **18%** extra.

---

## 1.1 Non-genuine Windows — what still works and what does not

Management has chosen to run **Microsoft 365 Business Basic** on laptops that use **non-genuine (cracked/pirated) Windows**. This section is for **risk transparency** and **realistic DevOps steps**. It is **not** approval to use unlicensed software.

### What Business Basic gives you (no desktop Windows licence needed)

| Capability | How staff use it |
| --- | --- |
| Company email | Outlook on the web — [https://outlook.office.com](https://outlook.office.com) or Outlook mobile with work account |
| Files (“office cloud”) | **OneDrive for Business** and **SharePoint** — browser or **OneDrive sync client** (test on each laptop) |
| Word / Excel / PowerPoint | **Office on the web** — [https://www.office.com](https://www.office.com) (included in Basic; **not** desktop Office.exe) |
| Teams | Chat and meetings with work account |
| Identity | **Entra ID Free** — users, MFA, security defaults |

**Default rule with this plan:** treat the laptop as a **terminal**. PHI lives in **M365 cloud + billing app**, not in `C:\Users\...\Documents`.

### Risks of non-genuine Windows (management should record these)

| Risk | Impact on medical billing security |
| --- | --- |
| **No trustworthy updates** | Cracked builds often block or break **Windows Update** — unpatched machines are ransomware targets. |
| **Malware / backdoors** | Modified ISOs are a common infection source — PHI can be stolen without staff noticing. |
| **Legal & audit** | US clients and BAA-style questionnaires ask about **licensed, supported OS**. Non-genuine Windows is a **fail** on many audits. |
| **Microsoft services** | M365 **can** sign in from such PCs, but **Intune enrolment**, **Entra device join**, and **Conditional Access (compliant device)** need **supported, genuine Windows** later. |
| **BitLocker / device encryption** | **BitLocker requires genuine Windows 11 Pro/Enterprise** (or equivalent). Do not assume encryption is on. |
| **Defender** | Tamper protection and updates may be unreliable on cracked systems. |

### Phase 1 security model (M365 Basic + non-genuine Windows)

**Do rely on:**

- M365 **MFA** and **unique `@company.com` accounts**  
- **OneDrive/SharePoint** as the only approved file store  
- **USB disable** (Section 6.4) — works on most Windows editions  
- **Standard (non-admin) user** for ops  
- **Edge** signed in with **work profile only** for payer and M365  
- **DNS filtering** (Section 7) to reduce personal cloud uploads  
- **Policy** — no local PHI, no WhatsApp PHI  

**Do not claim (until Windows is genuine):**

- Full-disk encryption (BitLocker)  
- Intune compliance  
- “Managed corporate endpoint” in client security forms  

**Optional interim encryption (DevOps):** If a laptop holds **no PHI on disk** (browser-only), encryption is less critical. If someone insists on local files, use **VeraCrypt** on a dedicated volume **only after** management accepts operational complexity — **OneDrive-only is simpler**.

### Exit criteria — when to buy genuine Windows

Budget **genuine Windows 11 Pro** (or new laptops with **Pro OEM**) when any of these is true:

- You start **Intune** or **Entra join** for company laptops  
- A client asks for **encryption at rest** on endpoints  
- A laptop will store **OneDrive sync** of claim folders offline  
- You buy **Microsoft 365 Business Premium** for ops (includes **Windows 11 Pro upgrade** for that user — must be applied on a **eligible, genuine** install; plan a **clean reinstall** from Microsoft media in practice)

---

## 2. Two different worlds — manage expectations

### 2.1 Company operations laptops (2–4) — **you can enforce**

You own the machine. You can:

- Create a **standard Windows user** (not Administrator)  
- **Disable USB storage** (pendrive)  
- Turn on **BitLocker** only after **genuine Windows 11 Pro** (not in current plan — see **Section 1.1**)  
- Install only required software  
- Force login with **company Microsoft account** (later) or local company account (now)  
- Point DNS through a **filter** that blocks Dropbox / WeTransfer / etc.

### 2.2 Management personal laptops (4) — **you cannot fully enforce**

The manager owns the laptop. You **cannot** reliably block copy, USB, or personal Google without **their agreement** to enrol the device in company management (Intune) — and many managers will resist that on a personal machine.

**Practical rule for management (Phase 1–2):**

| Allowed | Not allowed |
| --- | --- |
| Open **billing SaaS** and **company OneDrive/SharePoint** in the **browser** | Download ERA/claim files to `Downloads` on personal laptop |
| Use **company email** (`name@company.com`) with MFA | Forward PHI to personal Gmail |
| View dashboards without patient detail where possible | USB copy of remittance files |
| Company WhatsApp **Business** policy: **no PHI in chat** (better: no WhatsApp for PHI at all) | Personal Google Drive / iCloud for work files |

**Later (Phase 3):** Offer managers either **company laptop** or **enrol personal device in Intune** with limited policies — or move managers to **browser-only VDI** (see AWS doc).

---

## 3. What you are protecting (same as other proposals)

Patient demographics, member IDs, claims, ERAs, denials, appeal notes, payer portal data, follow-up notes tied to accounts.

**Office cloud (approved):** Only **Microsoft 365 Business Basic** tenant — **OneDrive for Business / SharePoint** under `@company.com`. Not personal Gmail, personal OneDrive, Google Drive, iCloud, or Dropbox.

---

## 4. Phased roadmap (startup-friendly)

```text
Phase 0 (Week 1)     — Policy + MFA on M365 — ₹0
Phase 1 (Month 1)  — M365 Business Basic (all users) + browser/OneDrive workflow + laptop hardening (no BitLocker) — ~₹16k/year
Phase 1b (when funded)— Genuine Windows 11 Pro on company laptops (clean install) — per device CapEx
Phase 2 (Month 3–6)— Entra join + Intune on ops laptops (only after genuine Pro)
Phase 3 (Year 1+)  — Business Premium / DLP / Conditional Access; mgmt on company PCs or VDI
```

### Phase 0 — This week (no new licences required)

- [ ] Management signs **1-page rules** (Section 5).  
- [ ] **Unique login** per person for billing SaaS and payers; remove shared passwords.  
- [ ] Turn on **2FA** on every system that supports it (billing app, Google/M365 admin, AWS if any).  
- [ ] **Bitwarden** (free for personal, **Teams** ~$4/user/mo when budget allows) for shared **portal** passwords — never Excel on Desktop.  
- [ ] List **approved cloud**: only company OneDrive/Drive; block by policy everything else.  
- [ ] Operations: **no work files on Desktop** — save into browser upload to billing app or (once ready) company OneDrive.

### Phase 1 — **Microsoft 365 Business Basic** (approved plan)

- [ ] Buy **Microsoft 365 Business Basic** for **all 6–8 users** (management + ops).  
- [ ] Connect your domain; create `firstname@company.com`.  
- [ ] Enable **security defaults** or MFA for all users (Entra ID Free).  
- [ ] Create SharePoint libraries or OneDrive folders: `Claims`, `Clients`, `ERA` — document naming rules.  
- [ ] Train everyone: **open files from OneDrive in the browser**; use **Excel/Word on the web** — **do not** use unlicensed desktop Office.  
- [ ] Train ops: **no PHI** in `Desktop`, `Downloads`, or personal sync folders — if OneDrive sync is enabled, use **Files On-Demand** and keep data only under the work OneDrive account.  
- [ ] Harden **company laptops** (Section 6 — **M365 Basic + non-genuine Windows** track).  
- [ ] Optional: **Cloudflare Zero Trust** DNS policy on company laptops (Section 7).  

### Phase 1b — Genuine Windows (before Phase 2 device management)

- [ ] Purchase **Windows 11 Pro** retail/OEM or new **Pro OEM laptops** for **company operations** machines only.  
- [ ] **Clean install** from [Microsoft media](https://www.microsoft.com/software-download/windows11) — do not “upgrade” cracked installs in place.  
- [ ] Enable **BitLocker** after Pro is activated (Section 6.3).  
- [ ] Document activation and recovery keys in company password vault.

### Phase 2 — Device management (when budget allows)

**Target users:** **2–4 company operations laptops first** (not all management personal laptops).

Choose **one** path:

| Path | What you get | Indicative cost (per ops user / month, before GST) |
| --- | --- | --- |
| **A. Microsoft 365 Business Premium** | Desktop Office, **Entra ID P1**, **Intune**, Defender for Business, **Windows 11 Pro upgrade right** | ~**₹1,830** |
| **B. Business Basic + Intune Plan 1 add-on** | Email/cloud from Basic + Intune only | ~**₹170 + ₹665 ≈ ₹835** |
| **C. Business Basic + Entra ID P1 add-on** (no Intune yet) | Conditional Access, better identity — still manual USB etc. | ~**₹170 + ₹500 ≈ ₹670** |

**Recommendation:** **Do not start Phase 2 Intune on cracked Windows.** Complete **Phase 1b (genuine Pro)** first. Then **Business Premium for operations staff only** is usually simpler than stacking add-ons (includes Pro upgrade right + Intune).

**DevOps tasks in Phase 2 (after genuine Windows on ops laptops):**

- Entra join / Azure AD join company laptops  
- Intune enrolment + compliance policy (encryption, patch age, no jailbreak)  
- Deploy **USB restriction** and **Edge** settings from cloud  
- **Conditional Access:** require MFA + compliant device for company email/OneDrive

### Phase 3 — Proper programme (align with full company-laptop proposal)

- Microsoft Purview **DLP** (needs higher tier — often **Business Premium** or add-ons)  
- Block personal cloud at network/DNS layer for all work devices  
- Management: **company laptops** or **VDI**; personal laptops **not** used for PHI  
- Quarterly access review, leaver checklist, logging

---

## 5. One-page policy (give to all staff — management and ops)

**English, plain language — management should sign:**

1. Patient and claim data may exist only in **company billing systems** and **Microsoft 365** (`@company.com` OneDrive/SharePoint / Office on the web).  
2. **No** saving to personal Google Drive, iCloud, Dropbox, personal OneDrive, USB/pendrive, or personal email/WhatsApp.  
3. **No shared** Windows or payer portal passwords.  
4. **Report** wrong send, lost laptop, or malware the same day.  
5. **Management personal laptops:** work with PHI only through **browser**; do not keep copies in Downloads; clear browser downloads weekly.  
6. **Company laptops** are for work; USB storage is disabled by IT policy.

---

## 6. Hands-on: harden company laptops (DevOps — Phase 1, M365 Basic, no Intune)

Do this on each **company operations** machine. **Run as Administrator** for setup; daily work as **Standard user**.

This section has **two tracks**:

- **Track A (current plan):** non-genuine or unactivated Windows — follow **6.1A**, skip **6.3** until Phase 1b.  
- **Track B:** after **genuine Windows 11 Pro** — follow **6.1B** and **6.3** (BitLocker).

### 6.1A Prerequisites — **non-genuine Windows (current plan)**

| Check | Action |
| --- | --- |
| M365 user created | Assign **Business Basic** licence; user completes MFA registration |
| Edge or Chrome | Install **Edge**; work profile signed in with `@company.com` only |
| OneDrive | Sign in to **OneDrive for Business** in browser; test upload of a **non-PHI** test file; enable sync only if ops are trained |
| Windows Update | Run `Settings → Windows Update` — if updates **fail** or build is unknown, treat laptop as **high risk**; priority for Phase 1b reinstall |
| No desktop Office | Uninstall or do not install cracked Office — use **office.com** only |
| Admin access for setup | DevOps runs USB script; then ops use **standard user** |

### 6.1B Prerequisites — **genuine Windows 11 Pro (Phase 1b+)**

| Check | Action if fail |
| --- | --- |
| Windows 11 **Pro** activated | Show **Settings → System → Activation** — genuine copy |
| TPM 2.0 on | Enable in BIOS |
| Latest Windows Update | Install before BitLocker and Entra join |

### 6.2 Create accounts

1. Create local user `COMPANY\ops-jane` — member of **Users** only (not Administrators).  
2. IT admin uses separate admin account or LAPS later; do not give ops admin rights.  
3. After M365 exists: **Settings → Accounts → Access work or school → Connect** with `name@company.com` (works on many configs; full **Entra join** waits for genuine Pro + Phase 2).  
4. Sign in to **Edge** with work account; pin **office.com**, **outlook.office.com**, billing SaaS.

### 6.3 BitLocker (full-disk encryption) — **Track B only (genuine Pro)**

**Skip on non-genuine Windows** (Section 1.1). BitLocker requires a **genuine Windows 11 Pro or Enterprise** activation.

1. Settings → Privacy & security → **Device encryption** / **BitLocker** → Turn on for C: drive.  
2. **Save recovery key** to company (password manager + secure backup) — not only on the laptop.

**PowerShell (check):**

```powershell
Get-BitLockerVolume
Manage-BDE -Status
```

**Track A alternative:** no local PHI; if management requires disk encryption before Pro purchase, evaluate **VeraCrypt** with professional guidance — prefer **OneDrive-only** and faster **Phase 1b** instead.

### 6.4 Disable USB mass storage (pendrive) — registry

> Test on one laptop first. This blocks most USB sticks; some phones may still charge-only.

**Registry (requires admin):**

- Path: `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\USBSTOR`  
- `Start` = `4` (disabled)  

**PowerShell (admin):**

```powershell
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR" -Name "Start" -Value 4 -Type DWord
Restart-Service -Name "USBSTOR" -ErrorAction SilentlyContinue
```

**To allow IT exception USB (document serial numbers):** set `Start` back to `3` temporarily only under change control.

**Group Policy (if you later have Pro + local GPO):**  
Computer Configuration → Administrative Templates → System → Removable Storage Access → **Removable Disks: Deny all access**.

### 6.5 Standard user + disable guest

```powershell
net user Guest /active:no
```

Remove ops users from **Administrators** group:

```powershell
net localgroup Administrators
# Remove user if listed — do via Computer Management → Groups
```

### 6.6 Windows Defender baseline

- Turn on **Tamper Protection** where available (Windows Security → Virus & threat protection).  
- On **non-genuine Windows**, verify Defender is **not disabled** by the crack — if Defender cannot update, treat machine as **compromised** and schedule **Phase 1b** reinstall immediately.  
- Enable **Controlled folder access** only if it does not break billing app (test).  
- Keep **SmartScreen** on for Edge.

### 6.7 Browser discipline — **primary workflow for M365 Basic**

- Use **Microsoft Edge** (or Chrome with a **dedicated work profile**).  
- Sign in with **`name@company.com` only** for work — payers, `office.com`, `outlook.office.com`, billing SaaS.  
- **Do not** install or use **cracked desktop Office** — create/edit spreadsheets in **Excel on the web** from OneDrive.  
- Do not sign personal Gmail into the **same** profile used for payers.  
- Company laptop should be **work-only** where possible.

### 6.8 Local data hygiene (critical with non-genuine Windows)

- Default save location is **OneDrive in the browser**, not `This PC`.  
- Pin bookmarks: SharePoint **Claims** library, billing SaaS, Outlook web.  
- **Disk Cleanup** / script to alert if `Downloads` has `.xls`, `.csv`, `.pdf` with claim patterns (advanced — Phase 2).  
- Enable **Storage Sense** to delete files in Downloads after 30 days (company laptops only — warn ops first).

### 6.9 What Phase 1 hardening does **not** do

- Does not stop **screenshots** or **phone photos**.  
- Does not stop **email attach to wrong address** — needs DLP (Phase 3).  
- Does not stop a **determined admin user** — hence no admin rights for ops.  
- Does not fully control **management personal laptops** — policy + browser-only only.

### 6.10 Reusable asset for DevOps

Package the above as:

- `scripts/usb-disable.ps1`  
- `scripts/bitlocker-on.ps1`  
- `docs/laptop-checklist.md`  
- Version in git; run checklist per new hire laptop.

---

## 7. Cheap network / web controls (no Intune)

### 7.1 Cloudflare Zero Trust (Gateway) — DNS filtering

**Good for:** Blocking **WeTransfer**, **Dropbox**, personal file hosts from company laptops.

**High-level steps (learn as DevOps):**

1. Create Cloudflare account → Zero Trust → Gateway.  
2. Install **WARP client** on company laptops (optional “device enrollment” on free tier — check current limits).  
3. Create DNS policy: block categories “File Sharing” or explicit domains (`dropbox.com`, `wetransfer.com`, `mediafire.com`, etc.).  
4. **Allow** `*.office.com`, `*.sharepoint.com`, your billing SaaS domain, payer sites you need.

**Caution:** Over-blocking breaks payer portals. Maintain an **allow list** spreadsheet from operations team.

### 7.2 Router / office DNS (if staff work from one office)

- Point office DNS to filtered resolver (Cloudflare for Teams, or OpenDNS umbrella paid).  
- Home WFH: rely on **WARP on laptop**, not home router.

---

## 8. Chosen platform — Microsoft 365 Business Basic only

Management has **standardised on Microsoft 365 Business Basic**. Google Workspace is **out of scope** for this rollout.

### 8.1 What each user gets (8 users)

| Included in Basic | Use for medical billing |
| --- | --- |
| Exchange Online mailbox | `name@company.com` — client/payer email (with MFA) |
| OneDrive for Business (1 TB) | Approved **office cloud** for claim-related files |
| SharePoint | Team libraries `Claims`, `Clients`, `Templates` |
| Word, Excel, PowerPoint **on the web** | Spreadsheets and letters **without desktop Office licence** |
| Outlook on the web | Daily mail; avoid storing PHI in personal clients |
| Microsoft Teams | Internal chat — **no PHI** in channels unless DLP added later |
| Entra ID Free | Users, groups, MFA, security defaults |

**Not included (and not in current budget):** desktop Office apps, Intune, Entra ID P1 Conditional Access, Windows licence.

### 8.2 How staff should work day to day

1. Sign in at [https://www.office.com](https://www.office.com) with work account.  
2. Open files from **OneDrive/SharePoint** — edit in browser.  
3. Attach from **OneDrive link** in email when possible instead of downloading.  
4. Billing SaaS in Edge work profile — portal passwords in company password manager.  

### 8.3 DevOps: tenant setup checklist (Business Basic)

- [ ] Create tenant and add custom domain (DNS records).  
- [ ] Assign **Business Basic** licence to all 6–8 users.  
- [ ] Enable **MFA** (security defaults or per-user MFA).  
- [ ] Create SharePoint site **Billing Operations** with libraries and permissions by role.  
- [ ] Block legacy auth when billing app allows.  
- [ ] Global admin: **maximum 2 accounts**; DevOps uses separate admin login.  
- [ ] Optional: disable **consumer OneDrive** use in policy (train users — technical block comes in Phase 2/3).

---

## Module A — What is Microsoft Entra ID? (formerly Azure AD)

### A.1 Simple explanation

**Microsoft Entra ID** is your company’s **user directory in the cloud**:

- Who works here (`jane@company.com`)  
- Passwords and **multi-factor authentication (MFA)**  
- Which apps they can open (billing SaaS, Office, VPN later)  
- **Sign-in logs** (who logged in, from where, success/fail)

When people say “Azure AD” or “Entra”, for a startup they usually mean **the same identity system behind Microsoft 365**.

### A.2 Editions you care about

| Edition | Cost (indicative India) | What you get |
| --- | --- | --- |
| **Entra ID Free** | Included with **Microsoft 365 Business Basic/Standard** | Users, groups, MFA (with security defaults), basic sync, **no** Conditional Access |
| **Entra ID P1** | ~**₹500/user/month** standalone, or included in **Business Premium** | **Conditional Access** (“only compliant laptops”), dynamic groups, self-service password reset policies |
| **Entra ID P2** | ~**₹750/user/month** | Identity Protection (risky sign-in), access reviews — overkill for 8 users early on |

**You do not buy Entra separately on day one** — it comes with M365 Business Basic (Free tier).

### A.3 Key concepts (glossary)

| Term | Meaning |
| --- | --- |
| **Tenant** | Your organisation’s Microsoft cloud account (`company.onmicrosoft.com`) |
| **MFA / 2FA** | Phone app approves login — stops password theft |
| **Conditional Access** | Rules like “M365 only from managed/compliant device in India” — needs **P1** |
| **Entra join** | Laptop is registered to your tenant; users sign in with work account |
| **Security defaults** | Microsoft’s free baseline MFA policy — good for Phase 1 |

### A.4 What DevOps should do first in Entra (Phase 1)

1. Go to [Microsoft 365 admin center](https://admin.microsoft.com) → Users → Active users.  
2. Create users; assign **Business Basic** licence.  
3. [Entra admin center](https://entra.microsoft.com) → **Identity** → **Overview** → enable **MFA** (Per-user or Security defaults).  
4. **Roles:** only 1–2 **Global Admins** (not every manager). You can be Global Admin as DevOps — use a dedicated admin account, not daily email.  
5. Turn off **legacy authentication** when ready (SMTP old clients may break — plan with billing app).

**Learn (free):**

- [Microsoft Learn — Entra ID fundamentals](https://learn.microsoft.com/en-us/training/paths/explore-identity-access-management/)  
- [Manage Entra ID](https://learn.microsoft.com/en-us/entra/fundamentals/whatis)

---

## Module B — Microsoft 365 licences (what to buy when)

### B.1 Plans compared (India list prices — verify before buy)

| Plan | Indicative ₹/user/month (annual, ex-GST) | Desktop Office? | Entra | Intune | Notes for startup |
| --- | --- | --- | --- | --- | --- |
| **Business Basic** | ~145–170 | Web/mobile only | Entra **Free** | No | **Approved for all 8 users today** — matches “no desktop Office licence” |
| **Business Standard** | ~860 | Desktop Word/Excel/Outlook | Entra Free | No | Needs **genuine Windows**; buy when budget allows offline Excel |
| **Business Premium** | ~1,830 | Desktop Office | Entra **P1** | **Yes** | **Target for 2–4 ops laptops** after **genuine Windows Pro** (Phase 1b) |

**GST:** add ~18%.

**Mixed licensing (cost tip):**  
8 × Premium is expensive. Common pattern:

- **4 management** → Business Basic (email + OneDrive + Teams web)  
- **4 operations** → Business Premium when budget allows (Intune + Pro + security)

### B.2 Windows and Office licensing (current management plan)

| Component | Current plan | Future target |
| --- | --- | --- |
| **Microsoft 365** | **Business Basic** (all users) | Ops may move to **Premium** |
| **Desktop Office** | **Not licensed** — use **Office on the web** | Standard/Premium if desktop apps required |
| **Windows on laptops** | **Non-genuine installs in use** (high risk) | **Genuine Windows 11 Pro** on company laptops (Phase 1b) |

- **Business Premium** includes a **Windows 11 Pro upgrade** right **per user** — use only after a **clean genuine install**, not on cracked images.  
- **Entra** is included with Basic (Free tier) — no separate Entra purchase in Phase 1.  
- Using **M365 does not legalise unlicensed Windows** — both matter for client audits.

### B.3 How to buy Business Basic (first time)

1. Go to [Microsoft 365 for business](https://www.microsoft.com/en-in/microsoft-365/business) → Business Basic → buy for **1 user** to create tenant.  
2. Add domain (DNS TXT record at your registrar — DevOps task).  
3. Add remaining users and licences in admin center.  
4. Indian partner/reseller optional (sometimes helps with GST invoice); direct from Microsoft is fine for small seat counts.

---

## Module C — What is Microsoft Intune?

### C.1 Simple explanation

**Intune** is **cloud MDM** (mobile device management) for laptops and phones:

- Push **policies** (USB off, password length, encryption required)  
- See **inventory** (OS version, encryption on/off)  
- **Remote wipe** company data when someone leaves  
- Deploy software (Chrome, billing app, certificates)

Without Intune, you are manually running PowerShell on each laptop (Section 6). With Intune, policies **re-apply** if someone tries to change settings.

### C.2 How to get Intune

| Method | Cost |
| --- | --- |
| Included in **Microsoft 365 Business Premium** | ~₹1,830/user/mo |
| **Intune Plan 1** standalone add-on to Basic | ~**₹665/user/mo** (verify on Microsoft India site) |

For **2–4 ops users**, compare:

- 4 × Premium ≈ **₹7,320/mo** (all-in)  
- 4 × (Basic + Intune) ≈ **₹3,340/mo** — cheaper but **no** Entra P1 Conditional Access unless you add P1 (~₹500 more each)

### C.3 DevOps learning path — Intune (Phase 2)

1. [Microsoft Learn — Intune fundamentals](https://learn.microsoft.com/en-us/training/paths/manage-microsoft-intune/)  
2. In [Intune admin center](https://intune.microsoft.com):  
   - **Devices → Enrollment** — configure **Automatic Enrollment** (Entra join).  
   - **Devices → Compliance policies** — require encryption, minimum OS.  
   - **Devices → Configuration profiles** — Settings catalog → Storage → removable storage deny.  
   - **Apps** — deploy Edge, billing client.  
3. **Conditional Access** (Entra P1): block email if device not compliant.

**Enrolment flow for company laptop (Phase 2 — not on cracked Windows):**

```text
Clean install genuine Windows 11 Pro → activate
→ Sign in with work account (Entra join)
→ Settings → Accounts → Access work or school → Connect
→ Intune auto-enrols → policies apply after sync (up to ~1 hour)
```

---

## Module D — Step-by-step setup order (DevOps playbook)

Use this order to avoid rework.

| Step | Task | Phase |
| --- | --- | --- |
| 1 | Sign policy (Section 5) | 0 |
| 2 | Create M365 tenant + domain + users | 1 |
| 3 | MFA for all users | 1 |
| 4 | Create SharePoint/OneDrive folder structure `Clients`, `ERA`, `Templates` | 1 |
| 5 | Harden company laptops — **Track A** (Section 6) | 1 |
| 6 | Cloudflare DNS filter on company laptops | 1 |
| 6b | **Genuine Windows 11 Pro** clean install on ops laptops | 1b |
| 6c | BitLocker + hardening **Track B** | 1b |
| 7 | Upgrade ops users to **Business Premium** | 2 |
| 8 | Entra join + Intune policies (ops laptops only) | 2 |
| 9 | Conditional Access: MFA + compliant device | 2 |
| 10 | Evaluate DLP / VDI for strict clients | 3 |

**Time estimate (solo DevOps, first time):**

- Phase 0: 1 day  
- Phase 1: 3–5 days spread over 2 weeks (plus user training 1 hour)  
- Phase 2: 1–2 weeks pilot on one laptop, then roll to remaining ops machines

---

## 9. Management personal laptops — minimum viable controls

Until managers get company devices or Premium/Intune:

| Control | How |
| --- | --- |
| Identity | Each manager has **@company.com**; MFA **on** |
| Data location | **No local PHI** — use browser to billing SaaS; upload/download only through company OneDrive web if needed |
| Email | **Outlook on the web** only, or Outlook desktop signed in to **work account only** |
| Downloads | Weekly delete Downloads; policy says so |
| USB | Cannot control — **trust + audit logs** in billing app |
| Training | 30-minute session: what is PHI, what not to do |
| Optional | Separate **Chrome profile** named “Company Work” signed in only with work account |

**Decision point for management:** If a US client audit requires **no PHI on unmanaged devices**, management must move to **company laptop** or **AWS WorkSpaces** (other proposal) — personal laptop cannot pass that audit.

---

## 10. Cost scenarios (8 people — planning table)

Assume **8 users**; prices **annual commitment, before GST**.

### Scenario S1 — “Approved plan now” (M365 Basic + no Windows/Office licence)

| Line | Calculation | Year 1 (approx.) |
| --- | --- | --- |
| M365 Business Basic × 8 | 170 × 8 × 12 | ₹16,320 |
| Windows / desktop Office | Deferred (non-genuine in use — see §1.1) | ₹0 budgeted |
| Hardening 4 company laptops | Labour only | ₹0 |
| Cloudflare Zero Trust | Free tier | ₹0 |
| **Total licences (Phase 1)** | | **~₹16,320 + GST** |
| **Add when budgeted (Phase 1b):** Windows 11 Pro × 4 ops laptops | ~₹12k–16k each one-time | ~₹48k–64k (CapEx, separate) |

### Scenario S2 — “Ops secure first” (when revenue allows)

| Line | Calculation | Year 1 (approx.) |
| --- | --- | --- |
| Basic × 4 management | 170 × 4 × 12 | ₹8,160 |
| Premium × 4 operations | 1,830 × 4 × 12 | ₹87,840 |
| **Total** | | **~₹96,000 + GST** |

### Scenario S3 — “Basic + Intune on ops only” (middle ground)

| Line | Calculation | Year 1 (approx.) |
| --- | --- | --- |
| Basic × 8 | 170 × 8 × 12 | ₹16,320 |
| Intune Plan 1 × 4 ops | 665 × 4 × 12 | ₹31,920 |
| **Total** | | **~₹48,240 + GST** |

Management should pick **S1 now**, plan **S2 or S3** within 6–12 months.

---

## 11. Migration path to “proper” company setup

| When | Milestone |
| --- | --- |
| Now | **M365 Basic** for all + policy + laptop scripts (Track A) |
| +1–3 months | All PHI in OneDrive/SharePoint; **no cracked Office** |
| +3–6 months | **Phase 1b:** genuine Pro on ops laptops + BitLocker |
| +6 months | S3 or Premium on ops; Entra join + Intune |
| +12 months | DLP, Conditional Access, consider **company laptops for management** |
| Client-driven | AWS VDI for “zero local PHI” contracts |

Align full target state with `Medical-Billing-Company-Laptop-Security-Proposal.md`.

---

## 12. What you (DevOps) should learn — skills map

| Skill | Why | Resource |
| --- | --- | --- |
| Microsoft 365 admin | Users, licences, mail flow | [Microsoft 365 admin docs](https://learn.microsoft.com/en-us/microsoft-365/admin/) |
| Entra ID | MFA, groups, CA later | Module A + Learn path |
| Intune | Policy deployment | Module C + Learn path |
| PowerShell on Windows | USB/BitLocker scripts | Section 6 |
| DNS / Zero Trust | Cheap egress control | Cloudflare docs |
| ITIL-light change control | Track who changed laptop policy | Simple spreadsheet + git |

You do **not** need a Windows domain controller in a closet for Phase 1–2. **Entra + Intune** replaces traditional Active Directory for cloud-first startups.

---

## 13. Decisions for management (this doc)

1. Approve **Phase 0 policy** this week.  
2. Confirm **Microsoft 365 Business Basic only** — no separate Windows/desktop Office licence in Phase 1 budget.  
3. Approve **browser + OneDrive workflow** (Section 8.2) — **no PHI on local disk**.  
4. Record **risk acceptance** for **non-genuine Windows** (Section 1.1) and set a **Phase 1b budget date** for genuine Pro on **company laptops**.  
5. Invest DevOps time in **Section 6 Track A** on company laptops; management personal laptops follow Section 9.  
6. Set a **budget date** for **Business Premium** (or Basic+Intune) on **operations only**, **after** Phase 1b.  
7. Name **you (DevOps)** as technical owner for M365 tenant + laptop checklist.

---

## 14. Quick reference — FAQ

**We use M365 Basic and non-genuine Windows — is that enough?**  
Enough to start **email, OneDrive, MFA, and policy** if PHI stays in the cloud. **Not enough** for client-grade endpoint compliance. Plan **genuine Windows Pro** (Phase 1b) before claiming encryption or enrolling **Intune**.

**Do we need to licence Windows separately from M365 Basic?**  
**Yes, for a supported PC.** Basic does **not** include Windows. Your current plan defers Windows purchase; **Business Premium** later includes a **Pro upgrade** for that user, but you still need a proper install.

**Can we use cracked desktop Office with Basic?**  
**No.** Use **Office on the web** included in Basic. Cracked Office adds malware risk and audit failure.

**Will Basic stop upload to personal Google Drive?**  
Not by itself. Use **DNS filter + policy**; store files only in **company OneDrive**. DLP comes in Phase 3.

**Can management use personal laptops with Basic?**  
Yes — **Outlook/Office web + OneDrive in browser**, MFA on, **no local PHI** (Section 9).

**Can one DevOps person do this?**  
Yes for 8 users. Budget 2–4 weeks calendar time learning + doing Phase 1.

**When do we need the AWS virtual desktop doc?**  
When a client contract says PHI must not reside on **any** laptop disk — or management refuses company laptops.

---

## 15. Document control

| Version | Date | Author note |
| --- | --- | --- |
| 1.0 | 12 Nov 2026 | Startup phased guide; indicative India pricing |
| 1.1 | 12 Nov 2026 | Aligned to plan: **M365 Business Basic only** + **non-genuine Windows**; Tracks A/B in Section 6; Phase 1b genuine Pro |

**Disclaimer:** Licence prices are indicative and exclude GST. Microsoft and Google change packaging periodically (e.g. Teams/Copilot bundles). Verify before purchase. This is not legal or HIPAA compliance advice.
