# Company Laptop / PC Security Proposal

**Document type:** Management proposal  
**Prepared for:** Management, Medical Billing Company (India)  
**Subject:** Issuing company-owned laptops and PCs for medical billing, and best practices to protect patient and claim data  
**Status:** For discussion and decision  
**Date:** 12 November 2026  
**Classification:** Internal — Confidential

**Related document:** `Medical-Billing-Workstation-Security-Proposal.md` (personal laptop controls and AWS virtual desktop option)

---

## 1. Purpose of this paper

Management is considering **company-provided laptops or desktop PCs** so billing and follow-up work is not done on employees’ personal machines.

This paper explains:

1. Why company devices are a stronger choice than personal laptops  
2. What must be in place so a company laptop actually protects data (not just a sticker that says “company property”)  
3. How this option compares to cloud virtual desktops  
4. What management should approve for rollout  

This is an operating and control proposal. It is not a legal opinion. Client contracts and qualified counsel should confirm obligations under Indian law (including the Digital Personal Data Protection Act, 2023) and any US client HIPAA-style requirements.

---

## 2. Executive summary

**Recommendation:** Move production medical billing work to **company-owned, company-managed Windows laptops or PCs**. Personal laptops should be **prohibited** for patient data, claim files, and payer portal work.

A company laptop gives the organization **legal ownership, full management, and the right to wipe the device** when someone leaves. That is the foundation every other control builds on. Without it, copy blocking, USB bans, and audit logs are easy to bypass.

Company devices are **not automatically secure.** Buying hardware alone does not stop someone from emailing a spreadsheet to personal Gmail or uploading a file to Drive. Security comes from a **standard image**, **central management (MDM)**, **identity and MFA**, **data-loss prevention**, **network rules**, and **clear policies** enforced every day.

**Compared to AWS virtual desktops:** Company laptops keep data on the disk inside the device (unless you also centralize files in the cloud). That is simpler for staff and avoids monthly cloud desktop fees, but **you must invest in IT operations**: patching, MDM, DLP, and lost-device response. Virtual desktops still win when the main goal is “data never touches any laptop disk.” Company laptops win when the goal is “we control the only machine used for work” with acceptable on-device risk.

**Decision requested**

| Decision | Recommended position |
| --- | --- |
| Device ownership | Company buys and owns all devices used for billing and follow-up. Personal laptops banned for PHI/claim data. |
| Operating model | Windows 11 Pro or Enterprise laptops/desktops; **Azure AD / Microsoft Entra ID** + **Microsoft Intune** (or equivalent MDM). |
| Data location | Claims and remittances live in **company billing application + company-controlled storage** (e.g. SharePoint/OneDrive for Business with download restrictions), not in local “Documents” long term. |
| Home / WFH | Allowed only on **company laptop + company VPN + conditional access** (compliant device, MFA, no legacy auth). |
| AWS virtual desktop | Optional later hybrid: company laptop used only as a thin client to VDI for highest-risk clients. Not required to start if controls below are implemented. |
| Before go-live | Written acceptable-use policy, asset register, leaver wipe process, and named IT owner. |

---

## 3. What we are protecting

Same data scope as the AWS proposal: patient demographics, insurance IDs, clinical codes, claims, ERA/EOB files, denial and appeal notes, call logs tied to accounts, and credentials for payers and clearinghouses.

**Threats that company laptops must address**

| Threat | Why company laptop helps |
| --- | --- |
| Data saved on personal machine | Company disk can be encrypted, wiped, and audited. |
| USB and personal cloud exfiltration | Policy + DLP + USB block via MDM. |
| Shared Windows login | Entra ID per user; no shared billing account. |
| Stolen or lost device | Remote wipe, BitLocker, compliance lock. |
| Malware from family use | Dedicated work device; optional “work profile only” rule. |
| Unpatched OS | Central patching via Intune. |
| Weak passwords | MFA and conditional access mandatory. |

**Residual risk (be honest with management)** Screen photos, dictation into personal phones, and writing account numbers on paper cannot be fully stopped by IT. Policies, training, and disciplinary process cover those gaps.

---

## 4. Design principle for company laptops

**One device, one job, one identity.**

1. **The company laptop is for company medical billing work only** (or “primary work only” if management allows limited personal browsing on a separate browser profile — not recommended for high-risk clients).  
2. **Patient and claim data is labeled and handled only in approved applications and company cloud storage.**  
3. **The company can always locate, lock, wipe, and reimage the device.**  
4. **No billing data on personal email, WhatsApp, Telegram, personal Google account, or USB.**  

```text
Employee
    |
    v
Company laptop (owned by company, enrolled in MDM)
    |  BitLocker, patch compliance, antivirus
    |  Entra ID user + MFA
    v
Conditional access (compliant device + MFA only)
    |
    +--> Company billing application
    +--> Payer / clearinghouse sites (allow-list where possible)
    +--> Company email + SharePoint / OneDrive for Business (DLP)
    |
    v
Logs: sign-in, DLP incidents, device compliance, admin actions
```

---

## 5. Why company laptop beats personal laptop

| Area | Personal laptop | Company laptop (with controls) |
| --- | --- | --- |
| Ownership | Employee can refuse controls | Company sets baseline; no production work without enrollment |
| Disk encryption | Unknown | BitLocker enforced via Intune |
| Leave / termination | Hard to prove data removed | Remote wipe + reimage + asset return |
| USB / cloud apps | User installs freely | Blocked or DLP-monitored |
| Audit | Weak | Entra sign-in logs, Intune compliance, M365 DLP |
| Client questionnaires | “We trust staff” | “Managed device, encryption, DLP, MFA” |

Company laptop **without** MDM, DLP, and MFA is only slightly better than personal laptop. The **program**, not the hardware purchase, creates security.

---

## 6. Company laptop vs AWS virtual desktop (short comparison)

| Criterion | Company laptop + controls | AWS WorkSpaces / AppStream |
| --- | --- | --- |
| Data on employee disk | Yes (unless files only in SaaS) | No, if clipboard/download disabled |
| Upfront cost | Hardware CapEx | Lower hardware; recurring cloud OpEx |
| IT skill needed | MDM, Windows, M365, DLP | AWS, directory, session controls |
| Offline work | Possible (risk if data cached locally) | Poor offline; session-based |
| Best for | Teams with stable WFH, standard payers, moderate client audit | Strict “no local PHI” contracts, high turnover, BYOD ban |
| Hybrid | Company laptop + browser-only to billing SaaS | Company laptop as client to VDI only |

Management may choose **company laptops first**, then add VDI for specific US clients that contractually require no local storage.

---

## 7. Hardware and procurement standards

### 7.1 Minimum specifications (billing / follow-up role)

| Item | Guideline |
| --- | --- |
| Form factor | Laptop for WFH; desktop + monitor in office if fixed seats |
| OS | Windows 11 **Pro** or **Enterprise** (required for BitLocker and domain/Entra join) |
| RAM | 16 GB minimum (32 GB for team leads running multiple apps) |
| Storage | 256 GB SSD minimum; **encrypted** |
| TPM | TPM 2.0 enabled (Windows 11 requirement) |
| Webcam / mic | Present for training; optional privacy shutter policy |
| Warranty | 3-year on-site or carry-in |
| Spare pool | 10–15% spare units for break/fix |

Avoid “Home” edition Windows. It cannot join modern management the same way.

### 7.2 Asset lifecycle

- Unique **asset tag** and register: serial number, assigned user, date issued, condition.  
- **Loan agreement** signed at issuance: company owns device; return on exit; no tampering with security software.  
- **No employee purchase** of “bring your own” for billing roles.  
- Retired devices: **secure wipe** or physical destruction certificate; never sold with disk intact.

### 7.3 Peripherals

- Company-approved USB keyboard/mouse only if needed; still subject to USB policy.  
- **No personal USB storage** on billing machines.  
- Headsets for calls: company-provided if client requires recorded quality standards.

---

## 8. Identity, access, and sign-in

### 8.1 One account per person

- **Microsoft Entra ID** (Azure AD) account for each employee: `firstname.lastname@company.com`.  
- **No shared billing login** on payer portals; use payer features for sub-users where available, or a privileged password vault with named check-out for exceptions only.  
- **Privileged admin** accounts separate from daily billing account (IT only).

### 8.2 Multi-factor authentication (MFA)

- **MFA required** for: company email, VPN, billing SaaS, M365, and any admin console.  
- Prefer **Microsoft Authenticator** app or FIDO2 key; SMS only as fallback.  
- Block legacy authentication protocols in Entra.

### 8.3 Conditional access (non-negotiable)

Allow sign-in to company email and file storage only when:

- Device is **Entra joined** or **Intune enrolled** and **compliant** (encryption on, OS patch level, antivirus on).  
- User passed **MFA**.  
- Sign-in from **approved countries** (e.g. India only, unless travel exception).  
- Optionally: **company VPN** required for accessing claim repositories.

### 8.4 Password and lock screen

- Minimum 12–14 character password or Windows Hello PIN tied to TPM where used.  
- **Screen lock** after 5–10 minutes idle; **full disk** protected when locked.  
- **Automatic sign-out** or device lock after repeated failed attempts.

---

## 9. Device management (MDM) — Microsoft Intune

Intune (or comparable MDM) is the control plane for company laptops.

### 9.1 Enrollment

- **Autopilot** or manual Entra join + Intune enrollment at first boot (IT or pre-staged vendor).  
- **User cannot remove** company management from a production billing device without IT action.  
- Personal laptops **not enrolled** for production PHI work.

### 9.2 Security baselines (apply to all billing devices)

| Control | Setting |
| --- | --- |
| BitLocker | Required; recovery keys escrowed in Entra / Intune |
| Windows Defender | On; cloud-delivered protection; tamper protection on |
| Firewall | On; no inbound RDP from internet |
| Secure Boot | Required |
| OS updates | Automatic; compliance policy fails device if N days behind |
| Local administrator | Removed for standard users; LAPS for break-glass local admin if needed |
| Guest account | Disabled |

### 9.3 Application control

- **Company billing software**, **Microsoft 365 Apps**, **approved browser** (Edge managed).  
- Block or warn on installation of: personal cloud sync (Dropbox personal, Google Backup and Sync), torrent clients, remote desktop servers, unauthorized screen recorders.  
- Use **Microsoft Defender Application Control** or **AppLocker** for high-assurance clients if required.

### 9.4 USB and removable media

- **Block USB mass storage** on billing laptops via Intune policy (allow only approved encrypted company drives if a client mandates removable media — rare).  
- Block **phone USB tethering** only if it breaks legitimate work; otherwise monitor.  
- Bluetooth file transfer: restrict if not needed.

### 9.5 Printing

- Default: **no home printer** for claim documents; print to **office-managed network printer** with logging where possible.  
- If home printing is unavoidable for a role, **watermarked PDFs** and **print DLP** rules; management approval per user.

---

## 10. Data handling on the device

### 10.1 Where files may live

| Allowed | Not allowed |
| --- | --- |
| Data inside **billing application** database/workflows | Long-term copies in `Downloads` or Desktop |
| Short-term working files in **OneDrive for Business** / SharePoint sync with **known folder move** | Personal OneDrive, Google Drive, iCloud |
| Scanned attachments uploaded straight into billing system | ZIP files emailed to personal accounts |

**Best practice:** Turn on **Known Folder Move** so Documents/Desktop redirect to OneDrive for Business under company tenant, then apply **sync restrictions** (block sync on unmanaged devices).

### 10.2 Microsoft Purview / DLP (strongly recommended)

Define sensitive information types (patient name + MRN patterns, SSN where applicable, member ID formats) and policies that:

- **Block** sending PHI in email to external domains except approved payer domains.  
- **Block or audit** upload to personal cloud connectors.  
- **Warn** on paste into personal webmail.  
- **Encrypt** emails containing sensitive labels (optional per client).

DLP is not perfect on day one; start with **audit mode**, tune false positives, then **enforce** for production OU.

### 10.3 Browser

- **Microsoft Edge** managed: block unauthorized extensions; force **smart screen**.  
- **URL filtering** (Defender for Endpoint web content filtering or third-party DNS) to block file-sharing sites, personal webmail, and social media during work hours if policy requires.  
- Separate **work profile**; discourage logging into personal Google on the billing browser profile.

### 10.4 Email and chat

- **Company Microsoft 365 mailbox only** for client and payer communication.  
- **WhatsApp, Telegram, personal Gmail** prohibited for PHI and claim attachments (written policy + training).  
- If Teams is used internally, **no PHI in public channels**; use private channels or billing system notes instead.

### 10.5 Full-disk encryption and recovery

- **BitLocker** on all drives; recovery key in Intune/Entra.  
- **Find my device** / **remote lock** via Intune.  
- **Wipe** on leaver same day.

---

## 11. Network and remote work

### 11.1 Office network

- Separate **staff Wi‑Fi** with Entra Wi‑Fi or certificate-based access; guest Wi‑Fi **no access** to billing VLAN.  
- **Firewall** egress: allow payer sites, clearinghouse, M365, billing SaaS; deny risky categories.  
- No open **port forwarding** to billing PCs.

### 11.2 Work from home

- **Company VPN** (always-on or on-demand) for access to internal file shares and management tools, if any.  
- **Split tunnel** only if security team accepts risk; many healthcare-oriented setups prefer **full tunnel** for billing role.  
- Home router: guidance document (WPA3/WPA2, change default admin password, no open guest network on same PC — use company laptop only).  
- **No billing work on family shared PC.**

### 11.3 Wi‑Fi in public places

- Policy: avoid public Wi‑Fi for payer portal access unless **VPN** is on.  
- Consider **hotspot from company phone** policy vs public café networks.

---

## 12. Endpoint detection and monitoring

| Tool / process | Purpose |
| --- | --- |
| Microsoft Defender for Endpoint | Malware, ransomware, behavioral alerts |
| Entra sign-in logs | Impossible travel, legacy auth, risky sign-ins |
| Intune compliance reports | Non-compliant devices blocked from mail |
| DLP incident review | Weekly review of high-severity DLP hits |
| Local admin / policy change alerts | Detect tampering |

**Privacy note (India):** Inform employees in writing what is monitored (company device, company accounts, DLP on work files). Monitoring should focus on **security and policy**, not arbitrary personal browsing, unless policy states work device is work-only.

---

## 13. Backup and business continuity

- **Billing application and databases**: vendor-managed backup with RPO/RTO documented.  
- **M365**: retention policies for mail and SharePoint; legal hold for disputes.  
- **Laptops**: user files should be in cloud sync; **laptop disk is not the backup**.  
- Test **restore** twice per year for critical claim data.  
- **Spare laptop** imaged and ready for same-day swap.

---

## 14. People, policy, and physical security

### 14.1 Policies to publish

- Acceptable use policy (work device, no PHI on personal apps).  
- Clean desk / clear screen at home (no visible claim screens to household).  
- Incident reporting within **same day** (lost laptop, wrong recipient email, malware popup).  
- **Return of asset** on last working day.  
- **Disciplinary** steps for intentional exfiltration.

### 14.2 Training

- Onboarding: 1–2 hours on DLP, MFA, USB rule, phishing.  
- Quarterly **phishing simulation** and short refresher.  
- Payer-specific rules (e.g. no screenshots for certain clients).

### 14.3 Physical

- Laptop **cable lock** in office optional.  
- **Do not leave** company laptop in unattended vehicle.  
- **Report theft** to IT and management immediately for remote wipe.

### 14.4 Joiners and leavers

| Event | Actions |
| --- | --- |
| Joiner | Create Entra user, assign licenses, issue laptop, enroll Intune, MFA registration, training |
| Role change | Adjust groups, payer portal rights, DLP scope |
| Leaver | Disable Entra account, wipe laptop, collect hardware, revoke MFA, document in checklist |

---

## 15. Implementation roadmap

| Phase | Duration | Deliverables |
| --- | --- | --- |
| 0. Policy | Week 1 | Ban personal laptops for PHI; asset agreement draft |
| 1. Foundation | Weeks 2–6 | Entra tenant hygiene, Intune, MFA, BitLocker baseline, M365 licenses |
| 2. Pilot | Weeks 7–10 | 10 users, billing apps, DLP audit mode, VPN if needed |
| 3. Enforce | Weeks 11–14 | DLP enforce, USB block, conditional access strict, full fleet rollout |
| 4. Assure | Ongoing | Monthly patch compliance report; quarterly access review |

**Pilot success criteria**

- Non-compliant device cannot open company email.  
- Test PHI pattern triggers DLP block on external send.  
- USB storage blocked on pilot laptops.  
- Leaver test account disabled and device wiped within SLA (e.g. 4 hours).

---

## 16. Cost drivers (planning, not a quote)

| Category | Examples |
| --- | --- |
| Hardware | Laptop ₹50k–90k+ per user depending on spec; desktops lower; monitors |
| Licenses | Microsoft 365 Business Premium or E3 (includes Intune, Entra P1, Defender for Business) |
| Billing application | Existing SaaS or on-prem |
| Optional | Defender for Office 365 P2 / Purview DLP advanced, VPN appliance, third-party MDM |
| Operations | IT admin or MSP monthly per device |

**Compare to AWS VDI:** Higher upfront hardware, often **lower recurring** than per-hour streaming if users work long shifts daily. Total cost depends on headcount and license tier.

---

## 17. Decisions for management

1. **Approve company-owned devices** for all billing and follow-up staff; **end personal laptop use** for PHI.  
2. **Approve Microsoft stack** (or equivalent): Entra ID, Intune, MFA, BitLocker, M365 with DLP.  
3. **Name owners:** IT lead, operations lead for payer URL list, HR for policy.  
4. **Approve pilot** size and timeline (Section 15).  
5. **Decide WFH rules:** VPN required yes/no; home printing allowed yes/no.  
6. **Reserve option** to add AWS VDI later for clients that forbid local PHI storage.

---

## 18. Checklist — best practices summary

Use this as the IT implementation checklist.

**Governance**

- [ ] Written acceptable-use and asset return policy  
- [ ] Asset register and loan agreement  
- [ ] Incident response contact list  
- [ ] Leaver same-day disable + wipe procedure  

**Identity**

- [ ] One Entra account per user; no shared logins  
- [ ] MFA enforced  
- [ ] Conditional access: compliant device + MFA  
- [ ] Privileged accounts separated  

**Device**

- [ ] Windows 11 Pro/Enterprise; TPM 2.0  
- [ ] Entra join + Intune enrollment  
- [ ] BitLocker with escrowed keys  
- [ ] Security baseline deployed  
- [ ] Automatic OS and browser updates  
- [ ] Standard users (no local admin)  
- [ ] USB storage blocked (or exception process)  
- [ ] Remote wipe tested  

**Applications and data**

- [ ] Billing app only in approved path; minimize local PHI  
- [ ] OneDrive for Business / SharePoint for files; block personal cloud  
- [ ] DLP policies (audit then enforce)  
- [ ] Managed Edge; restrict extensions  
- [ ] Web filtering for high-risk sites  
- [ ] Company email only for client/payer comms  
- [ ] No WhatsApp/personal email for PHI  

**Network**

- [ ] VPN for WFH if accessing internal resources  
- [ ] No RDP exposed to internet on laptops  
- [ ] Office Wi‑Fi segmentation  

**Monitoring**

- [ ] Defender for Endpoint on all devices  
- [ ] Weekly review of risky sign-ins and DLP incidents  
- [ ] Monthly compliance report to management  

**Continuity**

- [ ] Cloud backup for mail and files  
- [ ] Application backup verified  
- [ ] Spare laptops imaged  

---

## 19. Next steps

After management approval:

1. Confirm user count and WFH vs office split.  
2. Procure pilot hardware to standard in Section 7.  
3. Complete Entra/Intune baseline and enroll pilot users.  
4. Run DLP in audit mode for two weeks, then enforce.  
5. Communicate **personal laptop ban** date to all staff.  

For clients requiring **no PHI on endpoint disk**, scope a follow-on addendum: hybrid access via AWS WorkSpaces using the existing AWS security proposal.

---

## 20. Document control

| Version | Date | Notes |
| --- | --- | --- |
| 1.0 | 12 Nov 2026 | Initial company laptop / PC security proposal |
