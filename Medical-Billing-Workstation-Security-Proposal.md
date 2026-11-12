# Medical Billing Workstation Security Proposal

**Document type:** Management proposal  
**Prepared for:** Management, Medical Billing Company (India)  
**Subject:** How to stop billing and patient data leaving employee personal laptops  
**Status:** For discussion and decision  
**Date:** 12 November 2026  
**Classification:** Internal — Confidential

---

## 1. Purpose of this paper

Employees today use their own laptops for medical billing operations and follow-ups. Management wants that work tightened so staff cannot copy patient or claim data onto a personal computer, a USB drive, personal email, or a personal cloud account.

This paper answers three questions:

1. Can we enforce that rule on the employee’s own computer?
2. If we move the work to an AWS Windows workstation, what must be in place to keep the data safe?
3. What should management approve first?

This is a business and control proposal. It is not a build specification and it does not replace legal review of client contracts.

---

## 2. Executive summary

**Recommendation: do not try to make the personal laptop the secure workplace.** Use it only as a screen and keyboard. Keep every billing application, file, and follow-up record inside a company-controlled virtual Windows desktop on AWS.

A personal laptop cannot be fully trusted. The employee owns it, can remove software, can use a second device, and can photograph the screen. Technical controls on that laptop reduce risk. They do not close it.

A plain Amazon EC2 Windows machine, opened with Remote Desktop over the internet, is also the wrong design. It can be made safe, but only if the company builds the security around it. Amazon WorkSpaces, or Amazon WorkSpaces Applications, already includes the controls this risk needs: block copy-out, block file download, block local printing, and keep the data off the laptop.

**Decision requested**

| Decision | Recommended position |
| --- | --- |
| Where the work happens | Inside a company virtual desktop. The home laptop does not store billing data. |
| AWS service | Start with **Amazon WorkSpaces Applications** for standard billing and follow-up work. Use **Amazon WorkSpaces Personal** only for roles that need a persistent desktop. |
| Plain EC2 as the user desktop | Accept only if IT is ready to operate the full control list in Section 8. Do not expose Remote Desktop to the internet. |
| Before any patient data is placed in AWS | Sign an AWS Business Associate Agreement if US client contracts require HIPAA-style protection, and confirm the allowed AWS region in each client contract. |
| Immediate rule, before the technology is ready | No patient or claim data on WhatsApp, personal Gmail, Google Drive, OneDrive personal, Dropbox, USB, or a personal laptop folder. |

A 10-user pilot of four to six weeks is enough to prove the operating model before a full rollout.

---

## 3. What data we are protecting

Medical billing work typically includes:

- Patient name, date of birth, address, phone, and insurance member ID
- Policy and payer details
- Diagnosis and procedure codes
- Claim forms, remittances, denials, and appeal notes
- Provider and facility identifiers
- Follow-up notes and call outcomes
- Login details for payer and clearinghouse portals

If the company bills for US providers, clients usually treat this as protected health information and expect HIPAA-style safeguards in the contract, even though the company is registered in India. Indian law also applies. The Digital Personal Data Protection Act, 2023 requires reasonable security safeguards for personal data, and health-related data is high-impact if it is misused or leaked.

A leak does not need a hacker. The common failures in this operating model are ordinary:

- A file copied to the laptop, then uploaded to personal Google Drive “to finish at home”
- A claim spreadsheet sent to a personal email or WhatsApp group
- A USB drive used to move a payer report
- A shared Windows login, so a mistake cannot be traced to one person
- A laptop that is sold, stolen, or used by a family member while files remain on disk

---

## 4. The control principle

**Billing data should be created, viewed, and saved only inside a company environment that the employee cannot carry away.**

The personal laptop may show the screen. It should not receive the file, the clipboard contents, or a printout. Internet from the virtual desktop should reach only the payer portals, clearinghouses, and company systems the role needs. Everything else — personal cloud storage, personal email, file-sharing sites — should be blocked.

Three rules follow from that principle:

1. **One person, one identity.** No shared user IDs for billing work.
2. **Least access.** A follow-up executive does not need the same file rights as a billing lead.
3. **Evidence.** Every login, file export, and admin change should be logged, so a client or regulator question can be answered.

---

## 5. Option 1 — Restrict the employee’s own computer

### 5.1 What management is hoping this option will do

Keep today’s habit (work on the personal laptop) and add rules so data cannot be copied out or uploaded.

### 5.2 What can be done

If the company enrols each personal laptop into company device management (for example Microsoft Intune) and staff accept that enrolment, IT can:

- Require a PIN or password, disk encryption, and an up-to-date operating system before company applications open
- Require multi-factor authentication
- Push company applications and block unapproved ones
- Apply data-loss rules that warn or block copy of labelled files to USB, personal email, and personal cloud apps
- Wipe company data from the laptop when the person leaves
- Restrict company Microsoft 365 files so they open in the browser and cannot be downloaded

These controls help for email and Office files that stay inside Microsoft 365. They are a reasonable **interim** step for a few weeks.

### 5.3 Why this option fails as the lasting design

| Gap | Why it matters |
| --- | --- |
| The employee owns the device | They can refuse enrolment, remove the agent, or do the work on a second laptop that was never enrolled. |
| The data still lands on the laptop | Once a spreadsheet or portal download is on the disk, a later upload is difficult to guarantee against. |
| Personal cloud apps are already installed | Drive, Dropbox, and WhatsApp Desktop sit next to the billing files. |
| Family use and resale | A stolen or sold laptop can still hold downloads, browser history, and saved passwords. |
| Screen photos | No laptop policy stops a phone camera. |
| Staff relations | Full monitoring of a personal computer raises privacy and consent issues under Indian employment practice and the DPDP Act. Heavy monitoring of a personal device is a poor bargain. Monitoring a company virtual desktop is easier to justify. |
| Client audits | “We asked staff not to copy files” is weak evidence. “Files cannot leave the virtual desktop” is evidence. |

**Management conclusion for Option 1:** use it only as a short bridge. Do not invest in a long-term personal-laptop security programme. The access policy should be rewritten so the personal computer is **not an approved place to store or process billing data**.

### 5.4 Interim rules, starting this week

These need no new AWS account:

1. Billing and follow-up work uses company email and company systems only.
2. Patient names, member IDs, claims, and remittances are not sent or stored on WhatsApp, Telegram, personal Gmail, personal Drive, or a personal laptop folder.
3. USB drives are not used for billing files.
4. Each person uses their own login. Shared IDs are retired for production work.
5. Passwords are not stored in a browser on the personal laptop or written in a personal notebook.
6. A leaver’s access to payer portals and company systems is removed on the last working day.
7. Staff sign a short acceptable-use rule that states these points in plain language.

---

## 6. Option 2 — AWS virtual Windows workstation

### 6.1 The idea in one sentence

The employee opens a small company application on the personal laptop, signs in with multi-factor authentication, and works on a Windows desktop that lives in AWS. Closing the window leaves no billing file behind.

### 6.2 Which AWS service to choose

| | Amazon WorkSpaces Applications | Amazon WorkSpaces Personal | Amazon EC2 Windows, self-managed |
| --- | --- | --- | --- |
| What the user gets | The billing applications, streamed in a browser or client. The desktop can be rebuilt fresh. | A persistent Windows desktop assigned to that person. | A Windows server or workstation the company builds and patches itself. |
| Fit for billing operations | Strong fit for shared production work: claim entry, follow-up, payer portals. | Fit for team leads who need installed tools and files that stay between sessions. | Fit only if the company has the people to run a full desktop platform. |
| Copy, download, and print controls | Built in. Clipboard, file transfer, local drive, and local print can be turned off per group of users. | Available through Group Policy. Must be set deliberately. File transfer exists and must stay **off**. | Possible, but every control is custom: firewall, Group Policy, and the remote-display product. Easy to miss one path. |
| Data left on the home laptop | None, if download and clipboard-out are disabled. | None, if those same paths are disabled. | None, only if IT disables them and keeps them disabled. |
| Operating load | Lower. AWS manages the fleet image. | Medium. IT manages the desktop image and directory. | Highest. IT manages patching, backups, access, and hardening. |
| Cost shape | Pay for the hours the fleet runs. Often cheaper for shift-based teams. | Pay for each desktop, each month, whether or not it is used all day. | Pay for each running instance, storage, and the staff time to secure it. A cheap instance with a public Remote Desktop port is the expensive mistake. |
| Management recommendation | **Default choice for billing and follow-up staff.** | **Use for the few roles that need a personal desktop.** | **Do not make this the standard user desktop.** |

WorkSpaces Applications was formerly called Amazon AppStream 2.0. Older quotes and articles still use that name. It is the same family of service.

### 6.3 Why a “normal” EC2 desktop is the weaker choice

An EC2 Windows machine is a server the company rents. AWS keeps the building and the locks on the building. The company is responsible for who has the key, what the machine is allowed to do, and whether patient data can be copied out.

Teams often start with a single Windows EC2 instance and open port 3389 (Remote Desktop) to the internet so staff can connect from home. That pattern has caused real breaches across many industries: passwords are guessed, the port is scanned within minutes, and the machine is taken over. Security groups and a strong password do not make that design acceptable for patient data.

EC2 remains a valid place to run a **server** — a database, a file service, or a session host — inside a private network. It is a poor product to hand to each billing executive as “their PC,” unless Section 8 is implemented and owned by a named person.

---

## 7. Recommended target

### 7.1 How a day’s work should look

1. The employee uses their own laptop only to open the company client or browser.
2. They sign in with their own company ID and a second factor (phone app or hardware key). A password alone is not enough.
3. They land in a Windows session that contains only the billing application, the payer sites they are allowed to use, and company file storage.
4. Copy from the session back to the laptop is blocked. Download to the laptop is blocked. Printing to the home printer is blocked.
5. Upload from the laptop into the session can be allowed where a client must send a source file, and blocked where it is not needed.
6. Personal email, Drive, Dropbox, WeTransfer, and WhatsApp Web are blocked from that session.
7. Idle sessions lock and then disconnect. After hours, access can be limited to people on an approved roster.
8. When they sign out, the laptop holds no claim file.

### 7.2 Picture of the design

```text
Employee personal laptop
    |
    |  sign-in + multi-factor authentication
    |  screen only — no file download, no copy-out
    v
Company identity (directory + MFA)
    |
    v
AWS virtual Windows desktop
    |  private network, no public Remote Desktop
    |  allowed websites only
    |
    +--> Billing application and follow-up screens
    +--> Payer and clearinghouse portals
    +--> Company file store (encrypted)
    |
    v
Logs: who signed in, from where, and what was changed
```

### 7.3 What “do not copy the data out” means in practice

| Path data uses to leave | Setting for billing staff |
| --- | --- |
| Copy and paste from the session to the laptop | Off. Paste **into** the session may stay on if staff must paste a reference number. |
| Download a file to the laptop | Off. |
| Open the laptop’s drives inside the session | Off. |
| USB storage on the laptop, seen by the session | Off. |
| Print to the home or office printer | Off. If a client needs a printed appeal, print on a company printer that is logged. |
| Personal cloud, webmail, and chat sites inside the session | Blocked. |
| Screenshot of the virtual desktop | Block where the product allows it. A phone photo of the screen remains possible. Reduce temptation with a visible watermark (user name and time on the screen) and a written rule. |
| Email of a claim file | Allowed only from company email, to the client or payer address the process requires, with a size and recipient check. |

Within the session, copy and paste between billing screens can stay on. Staff still need to move a claim number from one company screen to another. The block is the path **out** of the company environment.

---

## 8. Best practices if management still chooses EC2 Windows

Use this section only if the company decides to build its own Windows workstation on EC2. These are the practices that keep that choice defensible. Skipping the access items in 8.2 removes the benefit of every other control.

### 8.1 Account and legal baseline

- Create the AWS account under the company, not under an individual’s personal email.
- Turn on AWS Organizations, a separate production account, and a separate test account. Patient data never goes in the test account.
- Sign the AWS Business Associate Agreement before production patient data is stored or viewed, where US client contracts require it.
- Confirm the region with the client. Many US healthcare contracts require the data to stay in a US region. Do not assume the Mumbai region is acceptable.
- Root account: hardware multi-factor authentication, locked away, not used for daily work. Daily administration uses named admin users.
- Billing alarms so a forgotten running desktop is visible to finance.

### 8.2 How staff reach the machine

- The instance has **no public IP address** and sits in a private subnet.
- Port 3389 is **not** open to the internet, and not open to `0.0.0.0/0`.
- Staff connect through a company remote-access path with multi-factor authentication (AWS Client VPN with certificate and MFA, or an equivalent private access design).
- Prefer a managed display protocol with clipboard and file controls (Amazon WorkSpaces, or DCV configured to disable clipboard-out, file transfer, and USB). Plain Remote Desktop is a last resort and must disable clipboard redirection, drive redirection, and printer redirection by Group Policy.
- Each person has a unique Active Directory (or equivalent) account. Billing staff are not local administrators.
- Sessions lock after a short idle period and disconnect after a defined idle time. Concurrent session limits stop one ID being shared across a shift.
- Access hours follow the roster. Break-glass access for an incident is a named admin path, logged and reviewed the next day.

### 8.3 The Windows image

- One standard image, rebuilt when the standard changes. Staff do not install software.
- Application allow-list: only the billing app, the approved browser, the company PDF reader, and the company line-of-business tools.
- Consumer sync clients are not in the image: Google Drive, Dropbox, OneDrive personal, iCloud, WeTransfer desktop, WhatsApp, Telegram.
- Browser policy allows only the payer, clearinghouse, and company sites required for that role. Everything else is denied by a web filter, not by a written instruction.
- Windows Defender is on. Tamper protection is on. Automatic sample submission of documents that may contain patient data is reviewed with the client contract before it is enabled.
- Disk encryption is on. BitLocker or the equivalent, with keys held by the company.
- Local guest accounts are disabled. The local administrator password is unique per machine and stored in a company password vault, not in a spreadsheet.
- USB mass storage is disabled by policy.
- Macros and unsigned installers are blocked.

### 8.4 Data on the machine

- The desktop is not the filing cabinet. Claim files live in the billing application or in a company store with access by role.
- User profiles do not roam onto the personal laptop.
- If a persistent disk is required, encrypt it with a company-managed key (AWS KMS, customer managed key). Restrict who can disable that key.
- Snapshots and backups are encrypted with the same standard. A backup of patient data is still patient data.
- Test and training use synthetic or fully de-identified records.
- Retention follows the client contract. When a client offboards, export and deletion are a checklist, not a hope that someone will “clean the folder.”

### 8.5 Network

- Outbound internet goes through a proxy or firewall that allows named sites. A wide-open NAT gateway lets a user open personal Drive inside the session, which defeats the project.
- Inbound administration uses AWS Systems Manager Session Manager where possible, so administrators do not need a standing Remote Desktop hole.
- Security groups allow only the ports the design needs, from the known access path.
- VPC flow logs are on.

### 8.6 Identity inside AWS

- No long-lived access keys stored on the workstation.
- The instance role, if any, can do only what that machine must do. It cannot read every bucket in the account.
- Instance metadata uses IMDSv2 only, so a malicious page inside the browser cannot easily steal the instance role.
- Administrator access to the AWS console is separate from the billing user’s desktop login, and uses its own multi-factor authentication.

### 8.7 Logging and response

- AWS CloudTrail logs account activity. Logs are stored in a separate account or bucket that desktop users cannot delete.
- Amazon GuardDuty is on for the production account.
- Windows security logs (logon, logoff, failed logon, policy change, new local user) are retained for a period agreed with clients. Twelve months is a practical starting point if the contract is silent.
- A named person reviews failed logins and after-hours access at least weekly.
- A one-page incident note exists: who to call, how to disable a user, how to preserve logs, and when a client must be told. The legal duty to notify depends on the contract and on whether Indian or US rules apply to that client. Do not improvise this during an incident.

### 8.8 Patching and recovery

- Operating system and application updates are applied at least monthly, and critical updates faster.
- The image is scanned (Amazon Inspector or an equivalent) before it is given to staff.
- A restore test is done twice a year. An untested backup is not a backup.
- Desktops that are not in use overnight are stopped, both to cut cost and to shrink the time a forgotten machine sits exposed.

### 8.9 People

- Two administrators, not one. The design should survive one person being on leave.
- Administrators do their admin work from an admin path, not from a billing user’s session.
- A joiner gets access only after the manager approves the role. A leaver loses the virtual desktop, the payer portals, and the company email on the last day.
- Vendors and freelancers do not receive a standing desktop. If they must help, access is time-bound and watched.

---

## 9. Controls that apply whichever AWS service is chosen

These are the non-negotiables. They are written so a client security questionnaire can be answered with a yes and a short proof.

1. **Agreement before data.** AWS BAA in place when the client requires HIPAA safeguards. Client contract checked for region and subcontractors.
2. **Encryption.** Data encrypted on disk and on the wire. Company-managed keys for stores that hold claim files.
3. **No public Remote Desktop.**
4. **Multi-factor authentication** for every user and every administrator.
5. **Unique user IDs.** No shared “billing team” login.
6. **Clipboard out, file download, local drives, USB, and local print turned off** for production billing roles.
7. **Internet allow-list** from the virtual desktop.
8. **No local admin** for billing staff, and no personal cloud client in the image.
9. **Logs retained and protected** from the people whose activity they record.
10. **Joiner and leaver process** operated the same week it is written, not only on paper.
11. **Production data banned from test,** from personal laptops, and from chat apps.
12. **Watermark and written rule** covering phone photographs of the screen, because technology will not fully stop that path.

---

## 10. What will still be possible after this is built

Management should hear this plainly so the project is not oversold.

- A determined employee can photograph the screen with a phone. Watermarks, a clean-desk rule for work-from-home, and discipline reduce this. They do not erase it.
- A person who is allowed to email a payer can still attach the wrong file. Mail rules and a short approved-recipient list reduce that.
- If one role is later given “download allowed” for convenience, that role becomes the exit path for everyone who asks them for a file. Exceptions should be rare, named, and reviewed.
- The virtual desktop protects company data only while staff actually work inside it. The interim rules in Section 5.4 have to hold until the pilot is the only approved way to work.

---

## 11. Policy changes management should approve with the technology

Technology without a rule will be worked around in the first week. The rule set can be two pages.

**Acceptable use, in plain language**

- Company patient and claim data is handled only inside the company virtual desktop and company email.
- Personal laptops, personal email, personal cloud, USB, and messaging apps are not a place to store or send that data.
- Passwords are individual. They are not shared to “cover the shift.”
- Printing, downloading, and copying out are disabled on purpose. Asking a colleague to bypass them is a policy breach.
- Lost laptop, suspected shared password, or a file sent to the wrong place is reported the same day. Early reporting is protected. Concealment is not.
- Photographing a claim screen is not allowed.
- Access is removed on the last working day.

**Employment paperwork**

- The rule is part of joining, in a language the employee actually reads.
- For any personal laptop that is enrolled during the bridge period, the employee is told what the company can see and what it can wipe (company data, not the family’s photos).
- Home-working staff have a private place to sit when claim screens are open.

---

## 12. Suggested rollout

| Phase | When | What “done” looks like | Management role |
| --- | --- | --- | --- |
| 0. Stop the obvious leaks | This week | Written rule issued. Shared IDs listed. WhatsApp and personal Drive called out by name. | Approve the rule and say it applies to leads as well as executives. |
| 1. Design | Weeks 1–3 | Region confirmed against the largest client contracts. Service chosen. User roles listed (billing, coding, AR follow-up, team lead). Allow-list of payer sites drafted by operations. | Name an owner. Approve pilot budget. |
| 2. Pilot | Weeks 4–8 | 8 to 10 people, one from each role, work only in the virtual desktop for real accounts. Clipboard-out and download are off. Issues are logged daily for the first two weeks. | Hear the pilot review. Do not add “temporary” download exceptions without a named end date. |
| 3. Production | Weeks 9–14 | All billing and follow-up staff moved. Personal-laptop storage of claim files prohibited. Leaver checklist in use. Logs being reviewed weekly. | Confirm the old way is closed. |
| 4. Evidence | After go-live | One client-style questionnaire answered from the live settings. Backup restore tested. Access review completed once. | Accept residual risks in Section 10. |

Pilot success is practical, not theoretical:

- A tester cannot copy a claim line onto the personal laptop clipboard.
- A tester cannot download a remittance file to the personal Downloads folder.
- A tester cannot open Google Drive or WhatsApp Web inside the session.
- A leaver test account cannot sign in the next morning.
- Staff can still complete a normal billing and follow-up day without a shared password.

---

## 13. Cost drivers

Exact monthly cost depends on user count, hours per shift, region, and whether desktops are persistent. Finance should take a written AWS estimate for the pilot size before approval. The line items to expect are:

- Virtual desktop or application-streaming hours
- User storage, if persistent desktops are used
- Directory (company identity)
- VPN or private access, if EC2 is chosen
- Logging storage
- Backup storage
- A web filtering or data-loss product, if the built-in AWS controls are not enough for a client
- Implementation time, and a retained administrator

**Cost warning:** the cheapest design — one shared Windows EC2 instance with Remote Desktop open, and one shared login — is the design most likely to fail a client audit and the design most likely to be compromised. Quote the recommended design, not that shortcut.

Stopping desktops outside the shift, and using non-persistent sessions for standard billing work, is where the operating cost stays reasonable.

---

## 14. Decisions for this meeting

Management is asked to decide the following.

1. **Approve the principle.** Personal laptops are display devices. Billing data is not stored on them.
2. **Approve the interim rule** in Section 5.4, effective immediately, including leads and managers.
3. **Choose the service.** Recommended: WorkSpaces Applications for standard users. WorkSpaces Personal only by role. EC2 only with a named owner for every control in Section 8.
4. **Confirm client constraints.** Which contracts require a US region, a BAA, and a right to audit.
5. **Approve a pilot** of 8 to 10 users and name the business owner and the technical owner.
6. **Accept the residual risk** that a phone can still photograph a screen, and approve watermarking plus the written rule.

---

## 15. Owner and next step

| Role | Responsibility |
| --- | --- |
| Management sponsor | Approves the principle, the rule, and the pilot budget. |
| Operations lead | Lists roles, payer websites, and the follow-up tools that must work on day one. Confirms no step depends on WhatsApp. |
| Technical owner | Builds the pilot with the controls in Section 7 and Section 9. Reports exceptions. |
| HR / admin | Issues the acceptable-use rule and the leaver checklist. |

**Next step after approval:** a two-week design note that names the AWS region, the pilot users, the website allow-list, and the pilot cost. Build starts only after that note is accepted.

---

## 16. Sources used for the technical position

The product behaviour described above is taken from AWS’s own guidance, checked on 12 November 2026:

- AWS End User Computing Lens: limit the ways data can leave a session (clipboard, file copy, local printers).
- Amazon WorkSpaces Applications data-loss settings: clipboard direction, file transfer, and print to the local device can be disabled. AWS advises leaving file transfer off to prevent data leakage.
- Amazon WorkSpaces administration guide: clipboard redirection is two-way unless Group Policy restricts it. File transfer to the local computer exists for personal Windows WorkSpaces and must be disabled for this use.
- AWS HIPAA Eligible Services Reference: Amazon EC2, Amazon WorkSpaces, and related services can be used for HIPAA workloads only inside the AWS Business Associate Agreement and the shared-responsibility model. Eligibility is not the same as a compliant setup.

Client contracts and a qualified privacy review should confirm how the DPDP Act and any US client obligations apply to this company’s specific clients. This paper is an operating proposal, not a legal opinion.
