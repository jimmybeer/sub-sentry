# Google Play Store — Submission Guide
### SubSentry v1.0 · First-time publisher edition

> **How to use this guide:** Work through it top to bottom, in order. Don't skip ahead.
> Every piece of text you need to paste is included here — you don't need to open any other document.
> Anything in a `code block` is something you copy and paste verbatim.

---

## Before You Start — Get These Ready

Collect everything in one place before you open Play Console.

| What | Where it is |
|---|---|
| Signed release `.aab` file | Your Flutter project's `build/app/outputs/bundle/release/` folder |
| Keystore file (`.jks`) | Wherever you saved it when you created it |
| Keystore password | In your head (test it with `keytool -list -keystore your-file.jks` first) |
| 5 screenshot PNG files | You'll export these in Step 1 below |
| App icon PNG | Your launcher icon at 512×512px |
| Privacy policy URL | `https://jyappsupport.github.io/subsentry/` |

---

## Step 1 — Export Your Screenshots

Your screenshots are currently HTML files. You need to turn them into PNG images first.

**Do this once for each of the 5 frame files** (`frame_01` through `frame_05`):

1. Open the HTML file in **Google Chrome** (right-click the file → Open with → Chrome)
2. Press **F12** to open DevTools
3. Click the **phone/tablet icon** at the top of the DevTools panel (called "Toggle device toolbar"). It looks like a small phone outline. If you can't see it, the DevTools panel might be too narrow — drag it wider.
4. In the toolbar that appears at the top of the page, set the dimensions to **430** wide × **932** tall
5. Make sure DPR (device pixel ratio) is set to **3** — there's a dropdown for it. If you don't see a DPR field, click the three dots (⋮) in that toolbar to find it.
6. Press **Ctrl+Shift+P** to open the command palette
7. Type `capture full` and select **"Capture full size screenshot"**
8. Chrome will download a PNG automatically — rename it `frame_01.png`, `frame_02.png`, etc.

Do this for all 5 frames. When you're done you should have:
- `frame_01.png`
- `frame_02.png`
- `frame_03.png`
- `frame_04.png`
- `frame_05.png`

> **If the screenshot looks wrong** (cut off, wrong size): make sure the page is fully loaded and the device dimensions are set *before* you take the screenshot. Refresh the page after changing dimensions if needed.

---

## Step 2 — Open Google Play Console

1. Go to **play.google.com/console**
2. Sign in with the Google account attached to your developer account
3. You'll land on the **All apps** screen

---

## Step 3 — Create Your App

1. Click the blue **"Create app"** button (top right)
2. Fill in the form:
   - **App name:** `SubSentry: Subscription Alert`
   - **Default language:** English (United Kingdom)
   - **App or game:** App
   - **Free or paid:** Paid
3. Tick both declaration boxes at the bottom
4. Click **"Create app"**

You'll land on your app's **Dashboard**. This is your home base — everything branches off from here. You'll see a list of tasks to complete. Don't worry about the order on screen; follow this guide instead.

---

## Step 4 — Complete App Content Declarations

Play Console requires you to answer several policy questions before anything else goes live. Find the **"App content"** section in the left sidebar.

### 4a — Privacy Policy

1. Click **"Privacy policy"** in the App content list
2. Paste this URL: `https://jyappsupport.github.io/subsentry/`
3. Click **Save**

### 4b — Ads

1. Click **"Ads"**
2. Select **"No, my app does not contain ads"**
3. Click **Save**

### 4c — Content Rating

1. Click **"Content rating"**
2. Click **"Start questionnaire"**
3. Enter your email address when asked
4. **App category:** Select **Utility** (closest match for a finance utility app)
5. Work through the questions — answer **No** to everything (violence, sexual content, substances, etc.). SubSentry has none of these.
6. Click **"Calculate rating"**
7. You should see **"Everyone"** (or equivalent). Click **"Apply rating"**

### 4d — Target Audience

1. Click **"Target audience"**
2. Select **"18 and over"** — even though the app suits all ages, selecting 18+ avoids Play's child-directed content policy requirements, which add significant compliance overhead for no benefit here
3. Click **Save**

### 4e — App Category (while you're in this area)

1. In the left sidebar, look for **"Store settings"** (sometimes under "Grow" or directly in the sidebar)
2. Set **App category** to **Finance**
3. Set **Email address** to your support/contact email
4. Click **Save**

---

## Step 5 — Fill In the Store Listing

Find **"Main store listing"** in the left sidebar.

### App Name
```
SubSentry: Subscription Alert
```
*(29 / 30 characters — Google reduced the title limit to 30 in 2023)*

### Short Description
```
Track every subscription privately. 99p once — no bank link, no monthly fee.
```

### Full Description

Copy and paste everything between the lines below exactly as written:

---

**Stop getting surprised by charges you forgot about.**

Every month, millions of pounds disappear in £0.99 iCloud tiers, £14.99 streaming bumps, and forgotten free trials that silently converted. SubSentry is the subscription tracker that actually tells you — loudly, and before it happens.

Pay 99p, once. Track unlimited subscriptions, forever.

---

**WHY SUBSENTRY?**

Most subscription trackers make you choose between your privacy and your money:

→ Rocket Money connects to your bank account and charges £8/month to scan it
→ Subby limits you to 5 subscriptions until you pay £8 for the Pro upgrade
→ Bobby is iOS-only and paywalls basic features like Dark Mode

SubSentry takes a different approach. One-time purchase. No bank linking. No limits. No subscription to manage your subscriptions.

---

**WHAT IT DOES**

SubSentry is a manual, private subscription vault. You add your bills, it tracks the renewals, and it alerts you before you're charged.

**Renewal Alerts**
Get notified days before any subscription renews — you set how many days in advance. No more "I didn't know it was renewing this week."

**Free Trial Killer**
Signed up for a free trial? SubSentry sends alerts at 5 days, 3 days, 1 day, and the day itself before it converts to a paid plan. Cancel on your terms, not theirs.

**Contract Watch**
Tracking a broadband deal or gym membership? Set the contract end date and SubSentry tells you when it's time to renegotiate or switch.

**Spending Pulse**
A day-by-day chart of your monthly cash flow — instantly see your expensive weeks. Know your total monthly and annual spend without doing any maths.

**Category Breakdown**
See exactly how much of your budget goes to Entertainment, Software, Utilities, and more. Cut with confidence.

---

**BUILT FOR PRIVACY**

SubSentry never connects to your bank. There's no account, no email address, no server. Every subscription you add is stored locally on your device using encrypted on-device storage.

If you delete the app, your data is gone. Not archived. Not sold. Gone.

---

**QUICK TO USE**

Add a subscription in under 10 seconds. Fill in the name, cost, and renewal date — category colours are applied automatically. Done.

Supports weekly, monthly, quarterly, and annual billing cycles. Handles free trials, paused subscriptions, and long-term contracts.

---

**EVERYTHING INCLUDED FROM DAY ONE**

✓ Unlimited subscriptions
✓ Renewal & trial alerts
✓ Contract end-date tracking
✓ Spending Pulse & Category Breakdown charts
✓ Dark mode
✓ CSV data export
✓ No ads — ever
✓ No bank account required
✓ No in-app purchases
✓ No subscription

---

**THE HONEST PRICE**

99p. Once.

It's less than a cup of tea. It works forever. And it'll save you significantly more than 99p the first time it catches a renewal you forgot about.

---

All data is stored locally on your device. SubSentry does not collect, transmit, or sell any personal data. Full privacy policy available at https://jyappsupport.github.io/subsentry/

---

*(end of description)*

### Screenshots

Scroll down to the **"Phone screenshots"** section.

1. Click **"Add phone screenshots"**
2. Upload your 5 PNG files: `frame_01.png` through `frame_05.png`
3. Drag them into this order if Play Console lets you reorder:
   - frame_01 — Dashboard (the problem)
   - frame_02 — Upcoming renewals (the solution)
   - frame_03 — Urgency pulse view
   - frame_04 — Add subscription
   - frame_05 — Settings

> **If a screenshot is rejected:** Play Console requires images to be at least 320px on the short side and no more than 3840px on any side. Your exports should be 1290×2796 which is within limits. If it's rejected for aspect ratio, re-export from Chrome without setting a DPR (just use 430×932 at 1×) — that gives a smaller file that always passes.

### App Icon

Upload your **512×512px PNG** app icon. This must be a flat PNG with no rounded corners — Play Console applies the rounding itself.

### Feature Graphic

Play Console also asks for a **1024×500px "feature graphic"** — a banner image shown at the top of your store listing on some devices. This is **required** even if you don't run ads.

Quickest option: create a simple 1024×500px image in Canva or Figma using your brand colours (deep teal, `#0E4057`) with the SubSentry wordmark centred. It doesn't need to be elaborate — a coloured background with the app name and tagline is fine.

### Click Save

Scroll to the bottom and click **"Save"**.

---

## Step 6 — Upload Your AAB (the App File)

This is where you actually put your app into Google Play.

1. In the left sidebar, find **"Production"** under the "Release" section
2. Click **"Create new release"**
3. You'll be asked about **App signing by Google Play** — click **"Continue"**. This means Google holds the final signing key. Your keystore is used to sign the upload, but Google re-signs for distribution. This is the standard modern approach and is fine.
4. Under **"App bundles"**, click **"Upload"**
5. Find your `.aab` file — it's at:
   ```
   [your flutter project]/build/app/outputs/bundle/release/app-release.aab
   ```
6. Upload it and wait for it to process (can take a minute)
7. Once processed, you'll see it listed with a version code

### Release Notes

Scroll down to **"Release notes"** and paste:

```
SubSentry 1.0 — The full app, from day one.

Track unlimited subscriptions. Get notified before renewals hit. See your monthly spending in one clear chart.

No free tier. No paywall. No subscription to track your subscriptions.

Pay once. Done.
```

8. Click **"Save"** then **"Review release"**

---

## Step 7 — Set Pricing

1. In the left sidebar, find **"Countries / regions"** (sometimes under "Monetise" or "Pricing")
2. Click **"Add countries / regions"** and select **United Kingdom** (and any other countries you want)
3. Find **"App price"** — click the price field next to United Kingdom
4. Set it to **£0.99**
5. You can click **"Set price for all countries"** to auto-convert to other currencies if you're releasing globally, or leave other countries at their defaults
6. Click **"Save"**

---

## Step 8 — Check the Dashboard for Remaining Tasks

Go back to your app's **Dashboard** (click "Dashboard" in the left sidebar).

You'll see a list of tasks with green ticks or orange warnings. Work through anything still showing as incomplete. Common ones at this stage:

- **"Select an app category"** — should be done (Finance, from Step 4e)
- **"Provide contact details"** — add your email address
- **"Complete data safety"** — see below

### Data Safety Section

Google requires you to declare what data your app collects. Find **"Data safety"** in the left sidebar.

Answer as follows:

- **Does your app collect or share any of the required user data types?** → **No**
  *(SubSentry stores everything locally and collects nothing)*
- **Is all of the user data collected by your app encrypted in transit?** → Not applicable (no data is transmitted)
- **Do you provide a way for users to request that their data is deleted?** → **Yes** — deleting the app removes all data, and there's a "wipe data" option in settings

Click **Save** and **Submit**.

---

## Step 9 — Final Review and Submit

1. Go to **"Production"** in the left sidebar
2. Click on the release you created in Step 6
3. Click **"Review release"**
4. Play Console will show a summary of any warnings or errors
   - **Warnings** (yellow) — usually fine to proceed
   - **Errors** (red) — must be fixed before you can submit
5. If everything looks good, click **"Start rollout to Production"**
6. Confirm when prompted

---

## What Happens Next

- Google will review your app — this typically takes **1–3 days** for a first submission, sometimes up to 7 days
- You'll get an email when it's approved or if there's an issue
- Once approved, the app goes live on the Play Store automatically
- You can check the status any time in Play Console → **"Production"** → your release will show as "In review" then "Published"

> **If it's rejected:** Google sends an email explaining why. Common first-time rejection reasons are policy wording in the description (rare for a finance app with no data collection) or a missing feature graphic. Fix the issue and resubmit — the review clock restarts but it's usually faster the second time.

---

## Quick Reference — All Your Store Listing Text

| Field | Value |
|---|---|
| App name | `SubSentry: Subscription Alert` |
| Short description | `Track every subscription privately. 99p once — no bank link, no monthly fee.` |
| Privacy policy URL | `https://jyappsupport.github.io/subsentry/` |
| Category | Finance |
| Price | £0.99 |
| Content rating | Everyone |
| Target audience | 18+ |
| Data collected | None |
