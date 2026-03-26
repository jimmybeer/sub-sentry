# Screenshot Frame Guide — SubSentry v1.0

## Overview

Five screenshot frames designed in HTML/CSS at **430×932px** (portrait).
Export at **3× browser scale** = **1290×2796px** — the required size for Apple App Store (6.7" iPhone).
Google Play accepts the same images.

---

## Directory Structure

```
docs/screenshots/
├── SCREENSHOT_GUIDE.md        ← This file
└── frames/
    ├── frame_01_problem.html   ← "Every sub costs you. Most charge you twice."
    ├── frame_02_alerts.html    ← "Know before it hits."
    ├── frame_03_trial.html     ← "Kill the trial. Keep the saving."
    ├── frame_04_pulse.html     ← "See where it all goes."
    └── frame_05_design.html   ← "Premium design. 99p, once."
```

---

## The 5-Screenshot Story Arc

| # | Frame | Caption | Emotional Job | Screen to Capture |
|:--|:------|:--------|:--------------|:------------------|
| 1 | Problem | "Every sub costs you. Most charge you **twice**." | Surface the pain | Dashboard — subscription list, monthly total visible |
| 2 | Solution | "Know before **it hits**." | Deliver relief | Upcoming renewals / alert timing settings |
| 3 | Trial Killer | "Kill the trial. Keep the **saving**." | Urgency / control | A subscription in Trial Mode with the 24h badge |
| 4 | Analytics | "See where **it all goes**." | Insight / clarity | Analysis tab — Pulse chart + Spending Breakdown |
| 5 | Premium | "Premium design. **99p, once**." | Justify the purchase | Add Subscription screen (clean form, smart defaults) |

The arc: **Pain → Relief → Control → Insight → Worth it.**

---

## What to Capture on Each Screen

### Screen 1 — Dashboard
- Show 5–7 subscriptions with category colours visible
- Make sure the **Monthly Total** (`£XX.XX / month`) is prominent
- Sort by Next Renewal Date
- Tip: Include a mix of categories (Entertainment, Software, Utilities) so the colour coding is visible

### Screen 2 — Upcoming Alerts
- Navigate to a view showing renewals within the next 7 days
- If the app shows a notification preview, capture that
- Alternatively: Settings → Alert timing screen
- Tip: Show at least 2–3 upcoming items with dates clearly readable

### Screen 3 — Trial Mode
- Tap into a subscription that has **Is Trial = true** enabled
- The trial end date and countdown badge should be prominent
- Ideally show the "24h warning" indicator or the trial badge in the card list
- Tip: Set a trial end date of "tomorrow" in the app to trigger the urgent state

### Screen 4 — Analysis / Pulse Chart
- Navigate to the Analysis tab
- The **Pulse Chart** (stacked bar + cumulative line) should be fully rendered with data
- The **Spending Breakdown donut** should also be visible
- Tip: Have at least 4–5 subscriptions with different categories so the charts look rich

### Screen 5 — Add Subscription Form
- Open the "Add Subscription" flow
- Let Smart Defaults populate a few fields (type "Net..." to trigger Netflix suggestion)
- The clean form UI with category colour picker visible
- Tip: Capture at the moment smart defaults have filled in the fields — it shows the polish

---

## How to Export Frames

### Method A — Browser Screenshot (Recommended)

1. Open a frame file in Chrome or Edge
2. Press `F12` to open DevTools
3. Click the device toolbar icon (Ctrl+Shift+M / Cmd+Shift+M)
4. Set dimensions to **430 × 932** and DPR (Device Pixel Ratio) to **3**
5. Close DevTools
6. Press Ctrl+Shift+P → search "Capture screenshot" → select **"Capture full size screenshot"**
7. This exports at 1290×2796px

### Method B — Manual Screenshot Tool

1. Open the frame in a browser
2. Zoom to 200% so the frame is large on screen
3. Use a screenshot tool (Snagit, Greenshot, etc.) to capture exactly the frame div
4. Resize to 1290×2796 in any image editor

### Method C — Figma / Design Tool Composite (Best Quality)

1. Use the frame HTML as a design reference for colours, typography, and layout
2. Recreate in Figma at 1290×2796px
3. Import your screenshots as fills in the phone screen rectangle
4. Export as PNG from Figma

---

## Compositing Your Screenshots Into the Frames

Each HTML frame has a **screen placeholder div** inside the phone mockup.
To place your real screenshots without Figma:

1. Take your app screenshot (e.g., using Android/iOS simulator)
2. In the HTML file, find this comment inside the `.screen` div:
   ```html
   <!-- PLACE YOUR SCREENSHOT: uncomment and set the src path -->
   <!-- <img src="../your-screenshot.png" alt="" style="width:100%;height:100%;object-fit:cover;border-radius:36px;"> -->
   ```
3. Uncomment the `<img>` tag and update the `src` path to your screenshot file
4. The screenshot will fill the phone screen exactly
5. Export using Method A above

### Screen Area Position (for Figma/Photoshop compositing)
At 3× export (1290×2796):

| Frame | Screen X | Screen Y | Screen W | Screen H |
|:------|:---------|:---------|:---------|:---------|
| 1–4 (caption above) | 255px | 727px | 720px | 1620px |
| 5 (caption below) | 255px | 207px | 720px | 1620px |

---

## Colour Reference

| Element | Hex |
|:--------|:----|
| Frame background (Teal) | `#0B3A4A → #040F14` |
| Frame background (Warm — Frame 3) | `#2D0D02 → #180600` |
| Frame background (Black — Frame 5) | `#0A0E12 → #060810` |
| Headline text | `#FFFFFF` |
| Accent word | `#E36414` (Burnt Coral) |
| Sub-caption | `rgba(255,255,255,0.60)` |
| Wordmark | `rgba(255,255,255,0.38)` |
| Badge text | `rgba(255,255,255,0.38)` |

---

## Store Submission Specs

| Store | Required Size | Format | Notes |
|:------|:-------------|:-------|:------|
| Apple App Store | 1290 × 2796 px | PNG or JPEG | 6.7" required; also submit 6.5" (1242×2688) |
| Google Play | Min 320px any side | PNG or JPEG | Portrait recommended; 1290×2796 accepted |

For Apple 6.5" (secondary required): export at 2.886× scale from the 430×932 frame = 1242×2688.
Simplest approach: export at 1290×2796, Google Play and Apple will accept it for all required sizes.

---

## Typography Cheat Sheet

| Usage | Font | Weight | Size |
|:------|:-----|:-------|:-----|
| Wordmark | Outfit | 600 | 13px |
| Headline line 1 | Outfit | 800 | 38px |
| Headline line 2 (accent) | Outfit | 800 | 38px — Coral `#E36414` |
| Sub-caption | Inter | 400 | 14px |
| Badges | Inter | 500 | 10px |

---

## A/B Test Candidates

Once live, consider testing:
- **Frame 1 caption**: "Every sub costs you. Most charge you twice." vs "You're paying for subscriptions you forgot existed."
- **Frame 5 caption**: "Premium design. 99p, once." vs "Pay once. Save forever."
- **Frame order**: Lead with Problem (current) vs lead with Analytics (visual-first)
