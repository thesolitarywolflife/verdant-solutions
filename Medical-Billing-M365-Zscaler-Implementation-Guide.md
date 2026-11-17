# Microsoft 365 Business Basic + Zscaler Security — Implementation Guide

**Document type:** Architecture, scope, pricing, and step-by-step implementation  
**Company profile:** Small medical billing startup (India) — ~6–8 users (management on personal laptops, 2–4 operations on company laptops)  
**Approved productivity stack:** **Microsoft 365 Business Basic** (`@company.com`, OneDrive/SharePoint, Office on the web, Entra ID Free, MFA)  
**Approved security stack:** **Zscaler** (cloud security gateway on laptops, home, and office networks)

**Audience:** Management (decision and budget) + **DevOps engineer** (deployment and policy)  
**Related docs:** `Medical-Billing-Data-Protection-Alternatives.md` (**lower-cost:** Cloudflare + M365 Premium for download control — if Zscaler is too costly), `Medical-Billing-Startup-Phased-Security-Guide.md`, `Medical-Billing-Company-Laptop-Security-Proposal.md`

---

## 1. Executive summary

**Microsoft 365 Business Basic** gives you **where data should live** (company email and OneDrive). It does **not** stop someone from opening **personal Dropbox**, **WeTransfer**, or **Gmail** in the browser and uploading a claim file. **Basic** has no built-in **DLP** or **web filtering** on the laptop.

**Zscaler** sits between users and the internet (and, with add-ons, SaaS applications). It can:

- **Allow** only approved destinations for work (payers, `*.office.com`, billing SaaS) or **block** personal cloud and file-sharing categories  
- **Inspect** HTTPS traffic (when SSL inspection is enabled and legally/contractually acceptable)  
- **Block uploads** to personal cloud storage from the endpoint (with **Endpoint DLP** + **Zscaler Client Connector**)  
- **Reduce malware** and phishing on browsing paths  
- Apply the **same policy** for staff at home, in office, or on mobile Wi‑Fi — important when you have **no corporate firewall**

For a billing company, Zscaler is the **technical enforcement** partner to your rule: *“Office cloud only — no personal cloud, no USB exfiltration (endpoint DLP + laptop hardening).”*

| Layer | Role |
| --- | --- |
| **M365 Business Basic** | Identity (Entra), MFA, approved **office cloud**, mail, Teams |
| **Zscaler Internet Access (ZIA)** + **Client Connector (ZCC)** | Secure web access, URL / cloud-app control, optional inline & endpoint DLP |
| **Laptop hardening** (existing guide) | USB registry block, standard user, no local PHI — **still required** |
| **Later:** Intune + genuine Windows | Device compliance, BitLocker — **after** budget (not replaced by Zscaler) |

---

## 2. What is Zscaler?

**Zscaler** is a **cloud security platform** delivered from Zscaler’s global data centres (often described as **Security Service Edge** or **SSE**). Instead of sending all internet traffic through an office firewall appliance, each laptop runs **Zscaler Client Connector (ZCC)**. Traffic is sent to Zscaler’s cloud, where policies are applied, then allowed or blocked toward the destination.

### 2.1 Plain-language analogy

Think of Zscaler as a **security checkpoint in the cloud**:

- Every website or SaaS app the employee opens passes through **your policies**  
- You define **who** (billing team), **what** (block “Personal Cloud Storage”), and **action** (block + show message)  
- You get **logs** when someone tried to upload to Dropbox  

M365 answers: *“Store files in company OneDrive.”*  
Zscaler answers: *“We block or alert when someone tries to put claim data elsewhere on the internet.”*

### 2.2 Main products you will hear about

| Product | Name | Typical use for your startup |
| --- | --- | --- |
| **ZIA** | Zscaler Internet Access | Web filtering, malware, SSL inspection, **Cloud App Control**, inline DLP for web |
| **ZCC** | Zscaler Client Connector | **Agent on Windows/Mac** — required to enforce ZIA on laptops at home |
| **ZPA** | Zscaler Private Access | Replace VPN for **internal** apps — optional unless you host apps in private DC |
| **Endpoint DLP** | Endpoint Data Loss Prevention | **USB, print, personal Dropbox/OneDrive personal** on the device — **high value for billing** |
| **CASB / SaaS Security** | Cloud App Security Broker | Deeper control inside **Microsoft 365** tenants — often **add-on** or higher bundle |
| **ZDX** | Digital Experience | “Is Teams slow because of Wi‑Fi or Zscaler?” — optional |

**Minimum practical bundle for you:** **ZIA + ZCC** for all users who handle PHI. Add **Endpoint DLP** in the quote if budget allows — it directly supports “no personal cloud / USB” goals.

Official overview: [Zscaler Internet Access](https://www.zscaler.com/products/zscaler-internet-access), [Zscaler Client Connector](https://www.zscaler.com/products/client-connector), [Pricing and plans](https://www.zscaler.com/pricing-and-plans).

---

## 3. Scope — what Zscaler will and will not cover

### 3.1 In scope (when implemented correctly)

| Area | How Zscaler helps |
| --- | --- |
| **Personal cloud upload** | Block or confirm: Dropbox, Google Drive (personal), personal OneDrive, iCloud sync clients (Endpoint DLP + Cloud App Control where licensed) |
| **File-sharing sites** | Block WeTransfer, MediaFire, anonymous paste sites via URL / cloud app categories |
| **Unapproved webmail** | Block or limit `gmail.com` web upload while **allowing** `outlook.office.com` / `office.com` |
| **Malware & risky sites** | Default threat categories; reduce drive-by downloads on billing laptops |
| **Work from anywhere** | Same policy on management personal laptops and company laptops — **if ZCC is installed and users cannot bypass it** |
| **Visibility** | Logs of blocked attempts — useful for management audits and coaching |
| **M365 alignment** | **Allowlist** `*.office.com`, `*.sharepoint.com`, `*.microsoftonline.com`, payer portals |

### 3.2 Partially in scope (depends on licence edition)

| Area | Note |
| --- | --- |
| **Inline DLP** (scan content for member IDs, SSN patterns) | Usually **Business/Transformation** platform or **Data Protection** add-on — confirm in quote |
| **M365 CASB** (stop sync client misconfig) | Often separate; **Basic** tenant still benefits from web + endpoint controls |
| **Email DLP** | Typically Microsoft Purview or Zscaler add-on — **not** in M365 Basic alone |
| **WhatsApp Web** | Can block category or domain; **phone app** is outside Zscaler unless mobile ZCC |

### 3.3 Out of scope — Zscaler does not replace

| Gap | What you still need |
| --- | --- |
| **Phone photos of screen** | Policy + training |
| **WhatsApp mobile app** | Policy; optional MDM later |
| **Data already on disk** | **OneDrive-only workflow** + Endpoint DLP + laptop hardening |
| **Non-genuine Windows** | ZCC may install, but **patching/BitLocker/Intune** still broken — plan genuine **Windows 11 Pro** |
| **Payer portal inside approved browser** | User can still **copy/paste** within allowed sites — combine with **training** and **inline DLP** if purchased |
| **Legal/HIPAA/BAA** | Contract and M365 configuration — Zscaler is a **control**, not automatic compliance |

### 3.4 Recommended scope for your first rollout (6–8 users)

**Phase A — all users with PHI access**

- ZIA + ZCC on **Windows** (ops laptops first, then management personal laptops with signed consent)  
- URL / Cloud App policy: **block Personal Cloud Storage & File Sharing**; **allow** M365 + payer allow-list  
- SSL inspection: **pilot** with care (some payers break inspection — use bypass rules)

**Phase B — after licence confirmation**

- **Endpoint DLP:** block **personal cloud storage** channel; block **removable storage** (complement USB registry script)  
- Optional inline DLP dictionaries for **Member ID / DOB** patterns  

**Phase C — later**

- ZPA only if you expose internal APIs without public SaaS  
- Microsoft **Business Premium** + Intune for **device compliance** alongside Zscaler  

---

## 4. How Zscaler helps prevent data loss (mapped to your risks)

| Risk | Without Zscaler (M365 Basic only) | With Zscaler |
| --- | --- | --- |
| Upload ERA to **personal Google Drive** | Easy in browser | **Cloud App Control / URL block** + Endpoint DLP on sync clients |
| **WeTransfer** large claim PDF | Easy | **Blocked** category |
| **USB copy** | Script on company laptops only | **Endpoint DLP** on machines with ZCC (ops + enrolled mgmt) |
| **Same rules at home** | Depends on each router | **ZCC tunnels** policy to Zscaler |
| Manager on **personal laptop** | Only policy | **ZCC required** on that device (with agreement) or **browser-only VDI** instead |
| Prove effort to client | “We told staff not to” | **Logs** of blocked attempts |

**Important:** Zscaler **reduces** casual and negligent leakage. **Determined** insiders need DLP content inspection + HR/policy. For startups, blocking **personal cloud and file sharing** is the highest **ROI** first step.

---

## 5. How this fits with Microsoft 365 Business Basic

| M365 Basic capability | Zscaler complement |
| --- | --- |
| OneDrive / SharePoint = **approved office cloud** | Allow `*.sharepoint.com`, `*-my.sharepoint.com`, `graph.microsoft.com`, `login.microsoftonline.com` |
| Outlook on the web | Allow `outlook.office.com`, `outlook.office365.com` |
| Office on the web | Allow `office.com`, `officeapps.live.com` |
| Entra ID + MFA | Zscaler can integrate **SAML SSO** for admin portal; users still use M365 MFA for mail |
| **No** Microsoft DLP in Basic | Zscaler **Endpoint DLP / inline DLP** (if licensed) fills part of the gap |

**Policy principle:** *Allow Microsoft 365 tenant traffic; block generic consumer cloud and file sharing unless explicitly approved.*

---

## 6. Architecture (target)

```text
                    ┌─────────────────────────────────────┐
                    │   Microsoft 365 Business Basic      │
                    │   Entra ID, MFA, Exchange,          │
                    │   OneDrive, SharePoint, Teams       │
                    └─────────────────┬───────────────────┘
                                      │  (allowed SaaS)
User laptop                         │
 (mgmt personal or ops company)      │
      │                              │
      │  Zscaler Client Connector    │
      ▼                              ▼
┌──────────────┐              ┌──────────────┐
│ All other    │─── blocked ──│ Dropbox,     │
│ HTTPS/web    │   or logged  │ WeTransfer,  │
└──────────────┘              │ personal     │
      │                       │ webmail…     │
      ▼                       └──────────────┘
┌──────────────────────────────────────────────┐
│        Zscaler Cloud (ZIA policy)            │
│  URL filter │ Cloud apps │ Threat │ DLP      │
└──────────────────────────────────────────────┘
      │
      ▼
 Internet (payer portals — allow-listed)
```

---

## 7. Pricing (planning — not a quote)

Zscaler **does not publish fixed list prices**. You buy **per user per year** (usually USD from Zscaler; Indian partners may invoice **INR + GST**).

### 7.1 What drives your price

1. **Number of users** (count everyone who gets ZCC — likely **6–8**)  
2. **Edition** (Essentials Platform vs full **Zscaler Platform** — see [Pricing and plans](https://www.zscaler.com/pricing-and-plans))  
3. **Add-ons:** Endpoint DLP, advanced sandbox, browser isolation, full **Data Security** inline  
4. **Contract term** (1 vs 3 years — longer often cheaper per user)  
5. **Who operates it** — DIY (you as DevOps) vs **MSP/partner** (monthly fee per user)

### 7.2 Indicative market references (verify with partner)

Use these only for **budget conversations**, not procurement.

| Reference | Indicative figure | Notes |
| --- | --- | --- |
| Public **AWS Marketplace** packaging (reported third-party) | ~**USD 315/user/year** (50-user Business tier reference) | Ceiling reference; startups often negotiate lower |
| Managed Zscaler services (third-party MSP claims) | From ~**USD 8/user/month** | Includes ops/monitoring — varies by products |
| **M365 Business Basic** (your separate cost) | ~**₹170/user/month** + GST | Unchanged |
| **Indian Zscaler partners** | Quote in INR | e.g. partners advertise same-day quotes — contact 2–3 partners |

**Rough annual stack example (8 users, illustrative only):**

| Item | Low planning guess | High planning guess |
| --- | --- | --- |
| M365 Business Basic | ~₹16k/year | ~₹20k/year |
| Zscaler (ZIA + ZCC only) | ~USD 2,000–2,500/year total | ~USD 4,000+/year with DLP bundle |
| Implementation labour | Internal DevOps | Partner professional services |

**Action for management:** Request **3 quotes** — Zscaler direct sales, one **India partner**, and compare **Essentials vs Platform** with **Endpoint DLP** line item broken out.

### 7.3 Cost-saving tips for a startup

- Licence **only users who touch PHI** (if some staff are pure admin with no claims data, scope separately — legal/compliance may still want all staff on ZIA).  
- Start **1-year** term unless discount is material.  
- **Pilot 2 users** on monthly MSP if offered, then annualise.  
- Do **not** buy ZPA until you have internal apps that need it.  
- Pair Zscaler with **free M365 MFA** — do not duplicate expensive identity add-ons early.

---

## 8. Prerequisites before implementation

### 8.1 Business and legal

- [ ] Signed **acceptable use policy** (no PHI on personal cloud/USB) — `Medical-Billing-Startup-Phased-Security-Guide.md` Section 5  
- [ ] **Consent** for management to install **ZCC on personal laptops** (company security agent)  
- [ ] Document **payer portal URLs** for allow-list (operations team)  
- [ ] Confirm with largest US client whether **SSL inspection** is acceptable (some financial/health portals break)

### 8.2 Microsoft 365

- [ ] Tenant live with **Business Basic** on all users  
- [ ] **MFA enforced** for all  
- [ ] SharePoint site / OneDrive structure for claims  
- [ ] List of **Global Admins** (max 2) for break-glass  

### 8.3 Technical

- [ ] Zscaler **tenant** provisioned (from sales/partner)  
- [ ] Admin access to **ZIA Admin Portal** and **ZCC Portal**  
- [ ] Test **Windows** laptops: ops first (company), then mgmt  
- [ ] macOS plan for management MacBooks — **ZCC for macOS** supported; test Endpoint DLP requirements  
- [ ] Outbound ports: ZCC needs internet to Zscaler cloud — document for restrictive office networks  

### 8.4 Roles (you as DevOps)

| Role | Owner |
| --- | --- |
| Zscaler policy author | DevOps (you) |
| Payer allow-list | Operations lead |
| User onboarding / ZCC install | DevOps + team leads |
| Log review weekly | DevOps → management summary |

---

## 9. Step-by-step implementation

### Phase 0 — Procurement and design (Week 1–2)

**Step 0.1 — Define user count and SKUs**

- List users: name, device type (Windows/Mac), personal vs company laptop, PHI yes/no  
- Ask partner for: **ZIA + ZCC**, **Endpoint DLP** yes/no, **SSL inspection** yes/no  

**Step 0.2 — Obtain Zscaler tenant**

- Complete Zscaler or partner onboarding  
- Receive: ZIA admin URL, ZCC portal URL, support PIN  

**Step 0.3 — Design document (one page)**

- Allowed: M365, billing SaaS FQDNs, payer list  
- Blocked: Personal cloud, file sharing, consumer webmail (optional)  
- Pilot group: **2 operations users**  

---

### Phase 1 — Zscaler Client Connector rollout (Week 2–3)

**Step 1.1 — Download ZCC from Zscaler Client Connector portal**

- Zscaler Help: [What Is Zscaler Client Connector?](https://help.zscaler.com/zscaler-client-connector/what-is-zscaler-client-connector)  
- Create **app profile** for **Internet & SaaS (ZIA)** forwarding  
- Enable **user authentication** (Zscaler user = corporate email recommended, synced or SAML later)

**Step 1.2 — Pilot install (2 laptops)**

1. Run ZCC installer as admin (Windows).  
2. User signs in with Zscaler identity (often `user@company.com`).  
3. Confirm **ZCC shows “ON”** / connected to Zscaler.  
4. Visit `https://ip.zscaler.com` or Zscaler-provided test page — verify traffic goes via Zscaler.

**Step 1.3 — Rollout remaining ops laptops**

- Use **silent install** switches from Zscaler docs for your version  
- Keep spreadsheet: device name, user, install date, ZCC version  

**Step 1.4 — Management personal laptops**

- Only after **written consent**  
- Same ZCC profile; consider separate **Zscaler department** “Management” for logging  
- If someone refuses ZCC: **no PHI on that device** — browser-only on company PC or future VDI  

**Step 1.5 — macOS (if any)**

- Deploy ZCC Mac package; test payer portals and M365  

---

### Phase 2 — ZIA URL and cloud application policy (Week 3–4)

**Step 2.1 — SSL/TLS inspection (pilot carefully)**

- ZIA → **Administration → SSL Inspection**  
- Start with **default bypass** for banking/health categories if offered  
- Add **custom bypass** for any payer portal that fails certificate pinning  
- Train users: one-time certificate trust prompts may appear — use official Zscaler guidance only  

**Step 2.2 — URL filtering policy**

- ZIA → **Policies → URL Filtering** (see [Configuring URL Filtering](https://help.zscaler.com/zia/configuring-url-filtering-policy))  
- Create rule **“Block high-risk leisure”** (optional): Social networking if distracting — often skip initially  
- Create rule **“Block file sharing”**: categories such as **File Sharing**, **Anonymizers** — **Block**  
- Create rule **“Allow Microsoft 365”**: custom URLs or categories for Microsoft — **Allow**  
- **Lower priority / last rule:** default allow for business need, or default block for strict mode (strict mode needs complete payer allow-list)

**Step 2.3 — Cloud App Control (preferred over URL alone for SaaS)**

- ZIA → **Cloud App Control**  
- **Block** “Personal Cloud Storage” apps for billing users  
- **Allow** “Microsoft Office 365” / OneDrive for Business as **corporate** instance (link tenant if CASB licensed; otherwise allow O365 category and rely on Endpoint DLP for personal OneDrive)  

**Step 2.4 — Payer allow-list**

- Build **URL category** or **custom block exception** list from operations  
- Test **each payer** login, file upload, report download with 2 pilot users  
- Document breakages in runbook  

**Step 2.5 — End-user notification (EUN)**

- Enable block page: *“Company policy: use OneDrive only. Contact IT.”*  
- Reduces helpdesk mystery when Dropbox is blocked  

**Step 2.6 — Activate policy**

- Zscaler uses **activate** / publish workflow — always **activate** after changes  

---

### Phase 3 — Endpoint DLP (Week 4–6, if licensed)

**Step 3.1 — Confirm licence includes Endpoint DLP**

- ZIA admin → verify **Endpoint DLP** menus exist  

**Step 3.2 — Configure policy**

- Follow [Step-by-Step Endpoint DLP](https://help.zscaler.com/zia/step-by-step-endpoint-dlp)  
- **Personal Cloud Storage:** action **Block** for billing groups  
- **Removable Storage:** action **Block** (aligns with USB hardening script)  
- **Printing:** **Allow** with notification or block for PHI roles  

**Step 3.3 — Deploy to ZCC**

- Policies push via ZCC automatically when activated (see [Endpoint DLP integration with ZCC](https://help.zscaler.us/zscaler-client-connector/zscaler-endpoint-data-loss-prevention-dlp-integration-zscaler-client-connector))  
- **Windows:** may require **Full Disk Access** / permissions per Zscaler doc  
- Test: attempt save to personal Dropbox client — expect **block + log**  

**Step 3.4 — Custom EUN for Personal Cloud Storage**

- Administration → End User Notification — custom message for block action  

**Step 3.5 — Allowlist Zscaler DLP endpoints**

- If using corporate firewall, allowlist Zscaler data protection URLs from Zscaler help (for incident upload)  

---

### Phase 4 — Inline DLP (optional, if in quote)

- Define dictionaries: member ID patterns, dates of birth format, keywords “ERA”, “remittance”  
- Start in **alert-only** mode 2 weeks, then **block** external upload  
- Coordinate with operations to reduce false positives  

---

### Phase 5 — Logging, monitoring, and handover (Week 6+)

**Step 5.1 — Dashboards**

- ZIA → **Analytics → Web Insights** — top blocked categories  
- Endpoint DLP → incident reports  

**Step 5.2 — Weekly routine (DevOps)**

- Review blocked **Personal Cloud Storage** attempts  
- One-line summary to management (user anonymised or named per HR policy)  

**Step 5.3 — Onboarding new hire**

1. M365 Basic user + MFA  
2. Zscaler user (if separate) or SSO  
3. Install ZCC before first day of PHI work  
4. 30-minute training: OneDrive-only, what block message means  

**Step 5.4 — Leaver**

1. Disable Entra account  
2. Disable Zscaler user  
3. Uninstall ZCC or wipe laptop  

---

## 10. Policy templates (starting points)

### 10.1 Allow list categories / apps (examples — confirm in your portal)

| Allow | Reason |
| --- | --- |
| Microsoft 365 / Office 365 | Company cloud and mail |
| Your billing SaaS hostname | Production work |
| Payer portals (custom list) | Claims and ERA |
| Microsoft Teams / Zoom (if used for clients) | Meetings — no PHI in chat |

### 10.2 Block or restrict (examples)

| Block | Reason |
| --- | --- |
| Personal cloud storage (Dropbox personal, Google personal drive upload) | Data loss |
| File sharing (WeTransfer, etc.) | Data loss |
| Personal webmail upload paths (optional) | Reduce mis-send |
| Known malware / phishing categories | Security baseline |

### 10.3 Zscaler departments / groups (suggested)

| Group | Members | Policy |
| --- | --- | --- |
| `Billing-Operations` | 2–4 ops | Strict block personal cloud + Endpoint DLP |
| `Management` | 4 mgmt | Strict block; log more; personal laptops |
| `IT-Admin` | DevOps | Relaxed for testing only — separate admin profile |

---

## 11. Pilot test plan (pass before full rollout)

| # | Test | Expected |
| --- | --- | --- |
| 1 | Open `office.com`, edit Excel in browser, save to OneDrive | **Success** |
| 2 | Open Outlook web, send mail to test address | **Success** |
| 3 | Open payer portal from allow-list, login | **Success** |
| 4 | Attempt `dropbox.com` upload (web) | **Block** or corporate EUN |
| 5 | Attempt WeTransfer upload | **Block** |
| 6 | USB copy of test file (Endpoint DLP) | **Block** (if licensed) |
| 7 | Billing SaaS full workflow | **Success** |
| 8 | ZCC disconnected / bypass attempt | Document behaviour — should fail closed or alert |

---

## 12. Operations runbook (DevOps cheat sheet)

| Issue | Check |
| --- | --- |
| User cannot open payer site | SSL bypass rule; URL allow-list |
| OneDrive broken | Cloud App O365 allow; SSL inspection bypass for Microsoft |
| ZCC shows disconnected | Firewall, captive portal, Zscaler status page |
| Slow internet | ZDX if licensed; else check SSL inspection scope |
| False block on client file | Temporary allow with ticket + expiry date |

**Zscaler trust:** Subscribe to [Zscaler Trust](https://trust.zscaler.com) for incidents.

---

## 13. Comparison: Zscaler vs “M365 only” vs Cloudflare Zero Trust

| | M365 Basic alone | Cloudflare Zero Trust (free/low) | Zscaler ZIA + ZCC |
| --- | --- | --- | --- |
| Company cloud | Yes | No | No (complement) |
| DNS / URL block | No | Yes (good start) | Yes (enterprise-grade) |
| Endpoint USB / personal cloud client | No | Limited | **Endpoint DLP** (licensed) |
| SSL inspection at scale | No | Varies | Yes (ZIA) |
| Medical billing audit story | Weak | Moderate | Stronger |
| Cost | Low | Low | **Higher** (quote) |
| DevOps effort | Low | Medium | **Medium–high** |

**Your decision:** M365 Basic + Zscaler is **stronger** than M365 + Cloudflare for **DLP and unified SSE**, at **higher cost**. You may run Cloudflare during procurement, then **replace** with Zscaler to avoid double agents.

---

## 14. Risks and limitations (management sign-off)

1. **ZCC bypass:** Admin users or uninstalling ZCC defeats controls — use **standard user** and policy.  
2. **Personal laptops:** Requires **installation consent** and trust.  
3. **SSL inspection:** Privacy and portal compatibility — document decision.  
4. **Non-genuine Windows:** ZCC may run, but OS integrity risk remains — **Phase 1b genuine Pro** still recommended.  
5. **Phones:** WhatsApp / mobile upload — **policy**, not Zscaler alone.  
6. **Licence mismatch:** Buying ZIA without Endpoint DLP leaves **USB/client cloud** gaps — confirm SKU in writing.

---

## 15. Decisions for management

| # | Decision |
| --- | --- |
| 1 | Approve **M365 Business Basic + Zscaler** as standard stack |
| 2 | Approve **Endpoint DLP** in initial quote if affordable |
| 3 | Mandate **ZCC on any device** used for PHI (company + consented personal) |
| 4 | Approve **3 vendor quotes** and pilot **2 users** before 8-user rollout |
| 5 | Keep **laptop USB hardening** and **OneDrive-only** process in parallel |
| 6 | Budget **genuine Windows Pro** on company laptops within 6–12 months |

---

## 16. DevOps learning resources

| Topic | Link |
| --- | --- |
| ZIA URL filtering | https://help.zscaler.com/zia/configuring-url-filtering-policy |
| Endpoint DLP setup | https://help.zscaler.com/zia/step-by-step-endpoint-dlp |
| ZCC overview | https://help.zscaler.com/zscaler-client-connector/what-is-zscaler-client-connector |
| M365 admin (parallel) | https://learn.microsoft.com/en-us/microsoft-365/admin/ |
| Zscaler pricing (bundles) | https://www.zscaler.com/pricing-and-plans |

---

## 17. Document control

| Version | Date | Notes |
| --- | --- | --- |
| 1.0 | 16 Nov 2026 | M365 Business Basic + Zscaler scope, pricing, implementation |

**Disclaimer:** Zscaler and Microsoft pricing require formal quotes. This guide does not constitute legal, HIPAA, or DPDP compliance advice. SSL inspection and employee monitoring should align with Indian employment practice and client contracts.