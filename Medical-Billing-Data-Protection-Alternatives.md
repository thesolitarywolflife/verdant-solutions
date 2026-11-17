# Data Protection Alternatives to Zscaler (Cost-Effective)

**Document type:** Requirements mapping + alternative products + recommended stack  
**Context:** Medical billing startup (India), **Microsoft 365 Business Basic** chosen, Zscaler felt **too expensive**  
**Related:** `Medical-Billing-Cloudflare-Zero-Trust-Basics-Guide.md` (beginner: lists, WARP, login), `Medical-Billing-M365-Zscaler-Implementation-Guide.md`, `Medical-Billing-Startup-Phased-Security-Guide.md`

---

## 1. What you said you need (in plain language)

| # | Requirement | What “good” looks like |
| --- | --- | --- |
| **R1** | Only allowed apps/sites | User cannot browse random public internet; only **payer portals**, **billing SaaS**, **Microsoft 365**, and a short IT list |
| **R2** | No other clouds | User cannot upload claim/ERA files to **Google Drive, Dropbox, personal OneDrive, WeTransfer**, etc. — only **company M365** (OneDrive/SharePoint) |
| **R3** | No M365 download on other devices | User cannot sign in to **Office 365 on a personal phone/old PC** and **download or sync** company files; work happens on **approved devices only** |
| **R4** | No social / chat exfiltration | No **WhatsApp, Telegram**, or other social apps used to **send work files** (web or desktop where possible) |

**Reality check:** No single free tool does all four perfectly on **personal laptops** without the user installing your security agent and without **Microsoft licences above Basic** for **R3**. The section below splits **what each requirement needs** and **cheaper stacks** that get you closest.

---

## 2. Requirement map — which tool does what

| Requirement | M365 **Business Basic** alone | **Cloudflare Zero Trust** (free ≤50 users) | **M365 Business Premium** + Intune (per user) | **Zscaler** |
| --- | --- | --- | --- | --- |
| **R1** Allowlist internet | No | **Yes** (DNS + HTTP lists, WARP client) | Partial (Edge policies if Intune) | Yes |
| **R2** Block other clouds | Weak (policy only) | **Good** (block domains/categories) | Better with DLP add-ons | Strong (+ Endpoint DLP) |
| **R3** Block download/sync on unmanaged devices | **No** | **No** (not M365-aware) | **Yes** (CA + SharePoint unmanaged device) | Partial (CASB add-on) |
| **R4** Block WhatsApp/Telegram | No | **Good for web**; weak for desktop app | **Good** with Intune app block on **managed** PCs | Good with Endpoint DLP |
| **Typical cost (8 users)** | ~₹16k/year | **$0** on free plan | ~₹1,830/user/mo × who needs it | Quote (high) |

**Important:** **R3 is a Microsoft problem.** It needs **Entra ID P1** (included in **Business Premium**, not in Basic). Cloudflare and Zscaler do not replace that for OneDrive/SharePoint download control.

---

## 3. Recommended alternative (best value for you)

### **Option A — “Minimum spend, maximum coverage” (recommended to start)**

| Layer | Product | Cost (indicative) |
| --- | --- | --- |
| Identity + office cloud | **M365 Business Basic** (all users) | ~₹170/user/month |
| Internet allowlist + block social/cloud | **Cloudflare Zero Trust Gateway** + **WARP** on each laptop | **$0** (free plan, up to **50 users**) — [pricing](https://www.cloudflare.com/plans/zero-trust-services/) |
| USB / local discipline | Scripts + policy (startup guide §6) | ₹0 labour |
| **R3** (M365 download on random devices) | Upgrade **only users with PHI** to **Business Premium** when budget allows — or **all users** if every person touches files | ~₹1,830/user/month for those users |

**Why this beats Zscaler for a startup:** For **R1, R2, R4**, Cloudflare on the free tier is often enough. You pay Microsoft only for **R3** when you can afford **Premium**, instead of paying Zscaler **per user per year** for everything.

**What you still cannot fully do on Basic + Cloudflare only:**

- Stop OneDrive sync on a **personal phone** (R3) — need **Premium + Conditional Access + Intune**  
- Block **WhatsApp Desktop** without Intune/AppLocker on **unmanaged** personal laptops — block **web.whatsapp.com** via Cloudflare; desktop app needs app control or policy  

---

### **Option B — “Microsoft-first” (fewer agents)**

| Layer | Product |
| --- | --- |
| All staff | **Business Basic** for email-only roles (optional) |
| Ops + anyone opening claim files | **Business Premium** |
| Internet | **Intune** → Edge **allow list** + block installers (company laptops first) |

**Cost:** Higher Microsoft bill, **no Zscaler/Cloudflare** if Edge policies are enough on **company** laptops only. **Weak on management personal laptops** unless they enroll in Intune.

---

### **Option C — Keep comparing Zscaler**

Use Zscaler only if a client **mandates** a named SSE vendor or you need **Endpoint DLP** on every personal laptop with one vendor. Otherwise Options A or B are usually cheaper for 6–8 users.

---

## 4. Alternatives to Zscaler (short list)

| Product | Best for | R1–R4 fit | Indicative cost |
| --- | --- | --- | --- |
| **Cloudflare Zero Trust Gateway** | Allowlist, block social/file sharing | R1, R2, R4 web **strong**; R3 **no** | **Free** ≤50 users; paid ~$7/user/mo |
| **Microsoft 365 Business Premium** | M365 download/sync control, Intune | R3 **strong**; R1/R4 with Intune | ~₹1,830/user/mo + GST |
| **Microsoft Defender for Cloud Apps** | Session block download in browser | R3 in browser | Add-on / E5 class — often overkill |
| **DNSfilter / NextDNS / Control D** | Cheap domain blocking | R1/R2/R4 **partial** (DNS only, no HTTPS app detail) | Low $/user |
| **Cisco Umbrella / Fortinet** | Enterprise SWG | Similar to Zscaler | Usually not cheaper for 8 users |
| **Policy + USB block only** | Zero software cost | **Weak** | ₹0 |

**Not recommended as primary:** VPN-only tools, antivirus-only, or “DLP” browser extensions without central logging.

---

## 5. How to meet each requirement (step-by-step concepts)

### R1 — Only allowed public sites / apps

**Target mode:** **Default deny** — block all internet except an **allow list**.

**Cloudflare Zero Trust (recommended)**

1. Create account → **Zero Trust** → **Gateway** → **DNS** and **HTTP** policies.  
2. Create list **Allowed-Work**: Microsoft domains, billing SaaS, each payer FQDN (from operations).  
3. Policy order (top to bottom):  
   - **Allow** if domain **in list** Allowed-Work  
   - **Allow** Microsoft 365 categories if you use categories (backup)  
   - **Block** all other DNS / HTTP  
4. Install **Cloudflare WARP** on every laptop (company + management with consent).  
5. **Enforce:** WARP must be on before work; policy in employment rules.  

Docs: [Create an allowlist](https://developers.cloudflare.com/learning-paths/secure-internet-traffic/build-dns-policies/create-list/), [Common HTTP policies](https://developers.cloudflare.com/cloudflare-one/traffic-controls/http-policies/common-policies/).

**Caveats**

- Users without WARP bypass controls.  
- Some payer sites need testing (SSL/captive portals).  
- **Mobile phone** for work needs WARP mobile or block work mail on phone until R3 is solved.

---

### R2 — No file share to cloud except company M365

**Layers (use together):**

| Layer | Action |
| --- | --- |
| **Policy** | “Files only in OneDrive/SharePoint or billing SaaS” — signed |
| **Cloudflare** | Block: `dropbox.com`, `drive.google.com`, `onedrive.live.com` (personal), `wetransfer.com`, `send-anywhere.com`, file-sharing categories |
| **Work habit** | Edit in **Office on the web**; attach **SharePoint links** in mail, not attachments |
| **Premium + DLP** (later) | Purview DLP block external share with PHI patterns |

**M365 Basic does not scan uploads to Google Drive** — network block (Cloudflare) is your main cheap control.

---

### R3 — No Office 365 download / sync from other (unmanaged) devices

This is the control you asked for in the clearest way:

> *“User should not connect Office 365 and download files from other devices.”*

**Minimum Microsoft stack**

| Piece | Purpose |
| --- | --- |
| **Entra ID P1** | Conditional Access |
| **Intune** | Mark company laptops as **compliant** / managed |
| **SharePoint admin** | **Access control → Unmanaged devices → Allow limited, web-only access** |

Result on **unmanaged** devices (personal phone, home PC not enrolled): user may **view in browser only** — **no download, print, sync**, and no full Office desktop to local disk (per Microsoft’s unmanaged device model).

Docs: [Control access from unmanaged devices](https://learn.microsoft.com/en-us/sharepoint/control-access-from-unmanaged-devices), [App enforced restrictions](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-app-enforced-restrictions).

**Licence:** **Business Basic cannot turn this on.** Minimum practical licence: **Microsoft 365 Business Premium** (includes Entra P1 + Intune) assigned to users who access claim libraries.

**Extra Conditional Access policies (after Premium)**

1. **Require compliant device** for **Office 365** / SharePoint (ops on company laptops).  
2. **Block legacy authentication**.  
3. Optional: **block M365 access from unmanaged devices entirely** for strict mode (stricter than web-only).

**Management on personal laptops:** Either enroll as **managed** (Intune) with limited policy, or **block M365 file access** from that device class and use **company laptop** for files.

**Cloudflare does not do R3** — it does not know SharePoint “download” vs “view”.

---

### R4 — No WhatsApp, Telegram, social media for file sharing

| Vector | Control |
| --- | --- |
| **Web** (`web.whatsapp.com`, `web.telegram.org`, facebook.com, etc.) | Cloudflare: block **Social Networks** category + explicit domains |
| **Desktop apps** (WhatsApp.exe, Telegram.exe) | **Intune** → block or allow-list apps on **company** laptops; on personal laptops: **policy + no local files** |
| **Mobile** | Block work account on personal phone (R3) or **MDM** later |

**DNS block alone:** Desktop apps may still work on some networks — combine **WARP (HTTP/DNS)** + **no PHI on disk** + **Premium session controls** for files still in M365.

---

## 6. Suggested combined architecture (replace Zscaler)

```text
┌─────────────────────────────────────────────────────────────┐
│ Microsoft 365 Business Basic (all)                          │
│  • MFA, OneDrive/SharePoint, Office web                     │
│  • R3 enabled later via Premium licence for file users      │
└───────────────────────────┬─────────────────────────────────┘
                            │
        ┌───────────────────┴───────────────────┐
        │                                       │
        ▼                                       ▼
┌───────────────────┐               ┌───────────────────────┐
│ Cloudflare WARP   │               │ Business Premium        │
│ + Gateway         │               │ (ops / all file users)  │
│ R1 allowlist      │               │ R3 unmanaged device     │
│ R2 block clouds   │               │ Intune R4 app block     │
│ R4 block social   │               │ on company laptops    │
└───────────────────┘               └───────────────────────┘
```

---

## 7. Phased rollout (DevOps) — without Zscaler

### Phase 1 — This month (stay on Basic + Cloudflare free)

| Step | Task |
| --- | --- |
| 1 | M365 MFA on all users |
| 2 | SharePoint libraries for claims; train **no local save** |
| 3 | Cloudflare Zero Trust account, WARP rollout pilot (2 users) |
| 4 | Build **Allowed-Work** domain list + **default block** |
| 5 | Block social + file sharing + personal cloud domains |
| 6 | Company laptops: USB disable script (startup guide) |
| 7 | Written policy: no WhatsApp/Telegram for PHI |

### Phase 2 — When budget allows (R3)

| Step | Task |
| --- | --- |
| 1 | Purchase **Business Premium** for users who access claim data (start with 2–4 ops) |
| 2 | Enroll **company laptops** in Intune |
| 3 | SharePoint admin → **Unmanaged devices → Allow limited, web-only access** |
| 4 | Conditional Access: require **compliant device** for SharePoint/Office 365 (pilot Report-only first) |
| 5 | Block or restrict WhatsApp/Telegram desktop via Intune on company PCs |

### Phase 3 — Optional tighten

- Purview DLP (if licensed with Premium/advanced SKU)  
- Genuine **Windows 11 Pro** on company laptops  
- AWS VDI doc if client forbids any local PHI  

---

## 8. Cost comparison (8 users — planning only)

| Stack | Year 1 order of magnitude (ex-GST) | Covers |
| --- | --- | --- |
| Basic only + policy | ~₹16k | Cloud only, **weak** R1–R4 |
| **Basic + Cloudflare Free** | ~₹16k + **$0** | **Strong R1/R2/R4 web**; **no R3** |
| Basic + Cloudflare + **Premium × 4 ops** | ~₹16k + ~₹88k ≈ **₹1L** | R1–R4 **good** on ops; mgmt personal still gap |
| **Premium × 8** + Cloudflare | ~₹1.75L + $0 | Best Microsoft R3 for everyone enrolled |
| Zscaler (typical quote) | Often **₹1.5L–4L+/year** for 8 users (varies) | Strong SSE; R3 still needs Microsoft for M365 |

For many startups your size, **Basic + Cloudflare free + Premium for 4 ops** is **cheaper than Zscaler** and matches your four requirements better than Basic alone.

---

## 9. Allow list starter (customize with operations)

**Always allow (examples — add your billing SaaS and payers):**

```text
*.office.com
*.office365.com
*.microsoftonline.com
*.sharepoint.com
*.onedrive.com
outlook.office.com
login.microsoftonline.com
graph.microsoft.com
<your-billing-saas-domain>
<payer1-portal-domain>
<payer2-portal-domain>
```

**Always block (examples):**

```text
dropbox.com
drive.google.com
docs.google.com
onedrive.live.com
wetransfer.com
web.whatsapp.com
web.telegram.org
telegram.org
facebook.com
instagram.com
t.co
```

Maintain this list in Cloudflare **Lists**; review monthly when payers change.

---

## 10. Honest gaps (tell management)

| Gap | Mitigation |
| --- | --- |
| User turns off WARP | Policy + periodic check; block work if non-compliant |
| Phone photo of screen | Training |
| WhatsApp **phone app** with file already downloaded | R3 + no local PHI |
| **Business Basic** cannot stop OneDrive on personal PC | **Premium** + unmanaged device policy |
| Cracked Windows | Reinstall genuine Pro when possible |
| Strict allowlist breaks a new payer | Change-control on allow list |

---

## 11. Decision summary

| Question | Recommendation |
| --- | --- |
| Zscaler too costly? | **Yes for 6–8 users — use Cloudflare Zero Trust (free) + Microsoft instead** |
| Keep Business Basic? | **Yes for all**; add **Premium** for anyone who needs **R3** |
| Best first move? | Deploy **Cloudflare WARP + allowlist + block social/cloud** this week |
| Best second move? | **Premium + Intune** on **company ops laptops** for **no download on unmanaged devices** |
| Update Zscaler doc? | Treat Zscaler as **optional future** if client mandates SSE vendor |

---

## 12. Document control

| Version | Date | Notes |
| --- | --- | --- |
| 1.0 | 16 Nov 2026 | Zscaler alternatives; R1–R4 mapping; Cloudflare + M365 Premium path |

**Disclaimer:** Prices and product features change. Verify Microsoft and Cloudflare plans before purchase. Not legal or compliance advice.