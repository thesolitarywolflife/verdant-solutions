# Cloudflare Zero Trust — Basics for Medical Billing (Explained Simply)

**For:** Management + DevOps (no prior Zero Trust experience)  
**Your plan:** **Microsoft 365 Business Basic** + **Cloudflare** instead of Zscaler  
**Related:** `Medical-Billing-Data-Protection-Alternatives.md`, `Medical-Billing-Windows-USB-And-App-Restriction-Guide.md` (USB + no admin installs on company laptops)

---

## 1. What problem does this solve?

Your staff use the **internet** to open:

- Microsoft 365 (mail, OneDrive)  
- Billing software  
- Payer websites  

You want to **stop** them from also using:

- Personal Google Drive / Dropbox / WeTransfer  
- WhatsApp Web / Telegram Web for sending files  
- Random browsing  

**Cloudflare Zero Trust** gives you a **company-controlled filter in the cloud**. Each laptop runs a small app (**WARP**) that sends internet traffic through Cloudflare, where **your rules** apply: **allow** work sites, **block** everything else (or block known bad categories).

**Important:** Cloudflare controls **internet browsing and many web uploads**. It does **not** replace Microsoft controls for “no download from OneDrive on a personal phone” — that still needs **M365 Business Premium** later (see alternatives doc).

---

## 2. Main pieces (vocabulary)

| Term | What it is (simple) |
| --- | --- |
| **Cloudflare account** | Your company’s login at Cloudflare; you create **one Zero Trust organization** (e.g. `yourcompany.cloudflareaccess.com`) |
| **Zero Trust Dashboard** | Web console where **you (DevOps)** create rules — not where staff work daily |
| **Gateway** | The **filter engine** — DNS + HTTP policies |
| **Lists** | Spreadsheets in the cloud: **Allowed-Work domains**, **Blocked-Always domains** |
| **DNS policy** | Rule on **domain names** (e.g. block `dropbox.com`) |
| **HTTP policy** | Deeper rule on **web traffic** (needs WARP in many setups) |
| **WARP / Cloudflare One Client** | **Small app on the laptop** — connects user device to Cloudflare |
| **Identity** | Link to **Microsoft Entra ID** (your M365 users) so rules can say “billing team vs others” later |
| **Device enrollment** | One-time (or occasional) **sign-in** so Cloudflare knows **which user** is on which laptop |

Think of it as:

```text
[ User laptop ] --WARP--> [ Cloudflare cloud ] --allowed--> [ Microsoft / payer site ]
                              |
                              +--blocked--> [ Dropbox / WhatsApp web ]  (user sees "blocked")
```

---

## 3. Your understanding — corrected and completed

You wrote:

> We create allowed list and blocked list in the web application, and install WARP on the office laptop in the user account. User needs to enforce every time they are logging in, right?

### 3.1 Allowed list and blocked list — **yes, in the web dashboard**

**Correct.** As DevOps you:

1. Log in to **Cloudflare Zero Trust** (browser).  
2. Create **Lists** (e.g. `Allowed-Work-Domains`, `Blocked-Cloud-Apps`).  
3. Create **Gateway policies** that say:
   - If domain is in **Allowed-Work** → **Allow**  
   - If domain is in **Blocked** list or category (Social, File sharing) → **Block**  
   - (Strict mode) If not in allow list → **Block**

You do **not** edit lists on each laptop — laptops only run WARP.

### 3.2 Install WARP on the laptop — **yes**

**Correct.** Install **Cloudflare One Client (WARP)** on each **office / company laptop** (and management laptops if they agree).

- Install **per Windows user profile** that does billing work (or machine-wide — DevOps choice).  
- DevOps uses **the same organization enrollment** for all company users (your team name / registration code or MDM).

### 3.3 “User must enforce every time they log in to Windows” — **mostly no**

**Daily use is not:** “Turn on security every Windows login by hand.”

**What actually happens:**

| When | What the user does |
| --- | --- |
| **First time on that laptop** | Install WARP (or IT installs it) → **Sign in once** to your company Zero Trust (often **Microsoft work account**, same as M365) |
| **Every day / every reboot** | WARP should **start automatically** and connect — **user does nothing** if you configure it right |
| **Sometimes** | Cloudflare may ask to **sign in again** if session expired (like staying logged into M365) — usually a **browser popup**, not every Windows login |
| **Wrong setup** | If WARP is **not** set to auto-start / lock, user could **turn WARP off** and bypass filters — **you must lock this as admin** |

**So:**

- **One-time enrollment login** to Cloudflare (link device to `name@company.com`).  
- **Not** “enforce policy manually every morning” if WARP is locked and auto-connects.

**What you configure as DevOps (recommended):**

- **Lock WARP switch** = user **cannot** turn protection off  
- **Auto connect** = if it disconnects briefly (hotel Wi‑Fi), it turns back on within minutes  
- Optional later: **mandatory authentication** (Windows) = no full internet until user signs in to Cloudflare  

Official reference: [Device client settings](https://developers.cloudflare.com/cloudflare-one/team-and-resources/devices/cloudflare-one-client/configure/settings/) (`Lock device client switch`, `Auto connect`).

---

## 4. How filtering works (allow + block)

### 4.1 Two styles

| Style | Good for | Risk |
| --- | --- | --- |
| **Block list only** | “Block Dropbox + social; allow rest of internet” | Users can still open **unknown** new sites |
| **Allow list only (strict)** | “Only payers + Microsoft + billing SaaS” | New payer URL breaks until you **add to list** |

For medical billing, start **strict allow list** for **billing users**, with a fast process to add payer URLs.

### 4.2 Policy order matters

Cloudflare evaluates rules **from top to bottom**. First match wins.

**Example strict order:**

1. **Allow** — domain in list `Allowed-Work-Domains`  
2. **Allow** — Microsoft-related (optional backup rule)  
3. **Block** — domain in list `Blocked-Always`  
4. **Block** — categories: Social Networks, File Sharing  
5. **Block** — **all other** internet (catch-all)

### 4.3 DNS vs HTTP

| Type | What it blocks |
| --- | --- |
| **DNS policy** | Easier; stops many sites by **name** |
| **HTTP policy** | Stronger; can use **host/URL**; needed for finer control |

For “no personal cloud,” use **both**: DNS blocks obvious domains; HTTP rules for HTTPS apps.

Tutorial: [Create allowlist or blocklist](https://developers.cloudflare.com/learning-paths/secure-internet-traffic/build-dns-policies/create-list/).

---

## 5. What the employee sees (day in the life)

**Monday — first day after IT setup**

1. IT installed WARP; user opens **Cloudflare One Client**.  
2. User clicks **Sign in to Zero Trust** → logs in with **`firstname@company.com`** (Microsoft).  
3. Status shows **Connected** (often green).  
4. User opens Edge, goes to `office.com` → **works**.  
5. User tries `dropbox.com` → **blocked page** from company policy (or browser error).

**Tuesday onward**

1. User turns on laptop, logs in to Windows.  
2. WARP is already running in the tray (system tray icon).  
3. User works as normal — **no extra step** unless session expired (rare sign-in popup).

**If WARP is disconnected (bad configuration)**

- Internet might work **without** filter — treat as **misconfiguration**; fix **lock switch**.

---

## 6. Step-by-step — DevOps setup (first time)

### Phase A — Cloudflare organization (you, once)

| Step | Action |
| --- | --- |
| A1 | Go to [Cloudflare Zero Trust](https://one.dash.cloudflare.com/) → create account / team name (e.g. `verdant-billing`) |
| A2 | **Settings → Authentication** → add **Microsoft Entra ID** (Azure AD) as login method — same tenant as M365 |
| A3 | Note your **team domain**: `verdant-billing.cloudflareaccess.com` |

### Phase B — Lists (you, in browser)

| Step | Action |
| --- | --- |
| B1 | **Gateway → Firewall policies → Lists** → create `Allowed-Work-Domains` |
| B2 | Add: `office.com`, `microsoftonline.com`, `sharepoint.com`, `office365.com`, `outlook.office.com`, your billing SaaS, each payer domain |
| B3 | Create `Blocked-Always`: `dropbox.com`, `wetransfer.com`, `web.whatsapp.com`, `web.telegram.org`, `drive.google.com`, etc. |

### Phase C — Policies (you, in browser)

| Step | Action |
| --- | --- |
| C1 | **Gateway → DNS policies** → Add rule: Allow if domain in `Allowed-Work-Domains` |
| C2 | Add rule: Block if domain in `Blocked-Always` |
| C3 | Add rule: Block category **Social Networks** and **File Sharing** (names in dashboard) |
| C4 | (Strict) Add last rule: Block **all other** DNS |
| C5 | **HTTP policies** — mirror critical blocks (optional but recommended) |

### Phase D — Device profile (lock WARP)

**Where:** **100% in the Cloudflare Zero Trust website** (same dashboard as Phase A–C). **Not** configured on each laptop. After you save, enrolled WARP clients download the new settings (often within a few minutes; can take up to ~10).

**On the laptop:** users only see the result — the WARP **toggle is greyed out** / cannot stay off — they do not set “lock” locally.

| Step | Action |
| --- | --- |
| D1 | In **browser:** [Zero Trust dashboard](https://one.dash.cloudflare.com/) → **Settings → Devices → Device settings** (or **Device profiles**) |
| D2 | Enable **Lock device client switch** (user cannot turn off) |
| D3 | Set **Auto connect** (e.g. 1–5 minutes) so it reconnects quickly |
| D4 | Service mode: **Gateway with WARP** (routes through Cloudflare) |

### Phase E — Install on user laptop

| Step | Action |
| --- | --- |
| E1 | Download **Cloudflare One Client** for Windows from Cloudflare |
| E2 | Install (admin rights once) |
| E3 | **Settings → Account → Login with Cloudflare Zero Trust** → user signs in with `name@company.com` |
| E4 | Confirm **Connected**; test allow and block URLs from Section 7 |

### Phase F — Pilot before all users

2 operations users → fix payer URLs → then roll out to remaining laptops.

---

## 7. Tests after install (copy to runbook)

| Test | Expected |
| --- | --- |
| `https://www.office.com` | Opens |
| `https://outlook.office.com` | Opens |
| Your billing SaaS URL | Opens |
| One payer portal from allow list | Opens |
| `https://www.dropbox.com` | **Blocked** |
| `https://web.whatsapp.com` | **Blocked** |
| Turn WARP off (user try) | **Should fail** if switch is locked |

---

## 8. Allow list starter (customize)

**Allowed (examples):**

```text
office.com
microsoft.com
microsoftonline.com
live.com
sharepoint.com
onedrive.com
office365.com
outlook.com
teams.microsoft.com
<yourcompany>.sharepoint.com
<billing-saas>.com
<payer-portal>.com
```

**Blocked (examples):**

```text
dropbox.com
box.com
drive.google.com
docs.google.com
accounts.google.com   (careful: may break non-Google SSO — test)
onedrive.live.com
wetransfer.com
web.whatsapp.com
web.telegram.org
facebook.com
instagram.com
```

When a **new payer** fails to open, add FQDN to **Allowed-Work** — do not permanently open “all internet.”

---

## 9. What Cloudflare does **not** do (be clear)

| You wanted | Cloudflare alone |
| --- | --- |
| Block **WhatsApp desktop app** | May still work; blocks **web** well — use **policy** + Intune later |
| Stop **USB copy** | No — use USB script in startup guide |
| Stop **OneDrive download on personal phone** | No — needs **M365 Premium** unmanaged-device settings |
| Stop **user on phone hotspot with no WARP** | Phone not protected unless WARP mobile enrolled |
| See **file content** inside ERA PDF | Limited — domain block only unless higher paid inspection |

---

## 10. Free plan limits (planning)

Cloudflare’s **Zero Trust free plan** supports up to **50 users** at **$0** (verify on [pricing page](https://www.cloudflare.com/plans/zero-trust-services/)).

- Enough for your **6–8 users**  
- Paid tiers if you need more logging retention or support  

---

## 11. FAQ — your questions and others

**Do we maintain lists in the web app only?**  
Yes. Laptops pick up policy automatically within a few minutes after you save.

**Does each user install WARP themselves?**  
Usually **IT/DevOps installs once**; user only does **first Cloudflare login**.

**Must user “enforce” security every Windows login?**  
**No** — WARP runs in background. User may re-auth to Cloudflare **sometimes**, not every PC login.

**Can user bypass by using mobile data on phone?**  
Yes, for work on **personal phone** unless you block M365 on unmanaged devices (Premium) or install WARP on mobile.

**Company laptop vs management personal laptop?**  
Same WARP install; consider **same strict policy** for anyone touching PHI, with written consent on personal devices.

**Replace antivirus?**  
No. Keep **Windows Defender**; Cloudflare is **network filter**, not antivirus.

---

## 12. Simple diagram (management slide)

```text
                    CLOUD (you configure in browser)
                    ┌─────────────────────────────┐
                    │  Allow list: M365, payers   │
                    │  Block list: Dropbox, WA…   │
                    └──────────────┬──────────────┘
                                   │
    Employee laptop                │
    ┌──────────────────┐          │
    │ Cloudflare WARP  │◄─────────┘  always on (locked)
    │ (small app)      │
    └────────┬─────────┘
             │
             ▼
       Internet / websites
```

---

## 13. Next steps for you (DevOps)

1. Read Phase A–E above; create Cloudflare team and connect **Microsoft login**.  
2. Pilot **2 laptops** with strict allow list.  
3. Document payer URLs with operations team.  
4. Write **1-page user note**: “WARP must show Connected; do not uninstall; report if blocked payer site.”  
5. Plan **M365 Business Premium** later for **no download on personal devices** (separate from Cloudflare).

---

## 14. Document control

| Version | Date | Notes |
| --- | --- | --- |
| 1.0 | 16 Nov 2026 | Beginner Cloudflare + WARP; login vs daily use |

**Learn more (official):** [Cloudflare One documentation](https://developers.cloudflare.com/cloudflare-one/), [Secure Internet traffic learning path](https://developers.cloudflare.com/learning-paths/secure-internet-traffic/).