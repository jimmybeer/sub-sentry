# Screenshot Capture Script — SubSentry v1.0

Five screenshots, one dataset. Set up the data once, capture in order.

---

## Step 1 — Set Up Your Test Data

Enter these 7 subscriptions before capturing anything. Frames 01, 02, and 04 all use this same dataset.

| Name | Cost | Cycle | Category | Next Bill |
|:-----|:-----|:------|:---------|:----------|
| Netflix | £17.99 | Monthly | Entertainment | 3 days time |
| Spotify | £10.99 | Monthly | Entertainment | 8 days time |
| Adobe CC | £54.99 | Monthly | Software | 12 days time |
| iCloud 200GB | £2.99 | Monthly | Software | 15 days time |
| Gym | £35.00 | Monthly | Gym | 22 days time |
| Broadband | £28.00 | Monthly | Utilities | 28 days time |
| Disney+ | £4.99 | Monthly | Entertainment | 31 days time |

**Why these:** Four categories (Entertainment, Software, Gym, Utilities) ensures the Pulse chart has colour variety and the Spending Breakdown donut has distinct segments. The spread of renewal dates across a full month makes the Pulse chart look naturally busy rather than sparse.

---

## Capture Order

Capture in this order to minimise navigation back-and-forth.

---

### Frame 04 — Analysis / Pulse Chart
*Capture this first while the data is fresh and charts are fully rendered.*

**Navigate to:** Analysis tab

**What to show:**
- Both the Pulse chart (stacked bars + cumulative line) and the Spending Breakdown donut visible simultaneously without scrolling
- If both can't fit on one screen, prioritise the Pulse chart — the stacked coloured bars across the month is the more distinctive visual
- Bars should span multiple days with at least 3 category colours visible

**The shot:** A screen full of rich, colourful data. The viewer should immediately think "I can see exactly where my money goes."

---

### Frame 01 — Dashboard
**Navigate to:** Main dashboard, sorted by Next Renewal Date (default), scrolled to the very top

**What to show:**
- The Monthly Total figure fully visible at the top of the screen
- At least 5–6 subscription cards visible, category colour dots running down the left
- The Netflix card near the top (renewing in 3 days) — the close renewal date creates visual urgency

**The shot:** A list that looks like a real person's subscriptions — busy, colourful, money leaving every week.

---

### Frame 02 — Upcoming Alerts
**Navigate to:** Tap into the Netflix subscription (renewing in 3 days)

**What to show:**
- The renewal date prominently displayed
- Whatever alert/warning indicator the app shows for an imminent renewal
- If there's a dedicated Upcoming view showing multiple cards, use that instead — 2–3 upcoming items is better than one detail screen
- A date in the near future must be clearly readable

**The shot:** The viewer must immediately understand the app warned them *before* the charge hit. "Renews in 3 days" is the emotional core.

---

### Frame 03 — Trial Killer
**Add one new subscription for this screenshot only:**

| Field | Value |
|:------|:------|
| Name | Amazon Prime |
| Cost | £8.99 |
| Category | Entertainment |
| Is Trial | ✅ ON |
| Trial End | Tomorrow's date |

**Navigate to:** The Amazon Prime card or detail screen

**What to show:**
- The trial badge or warning indicator in its urgent state (triggered by the tomorrow end date)
- The 24-hour warning UI — whatever the app shows when a trial is about to convert
- The trial end date visible on screen

**The shot:** Visual urgency. The viewer should feel the time pressure. The warm brown frame background was matched specifically to complement a warning/alert colour state.

---

### Frame 05 — Add Subscription (Smart Defaults)
**Navigate to:** Add Subscription screen (tap the FAB / add button)

**What to show:**
- Tap into the Name field and type `N`, `e`, `t` slowly
- Wait for the Netflix smart suggestion to appear / auto-populate
- Capture the moment the price field is already filled in (£17.99 or similar) from the smart default
- Category colour should be auto-selected (Entertainment / red)
- The form should look intelligent and pre-filled, not blank

**The shot:** The autocomplete/suggestion moment. A viewer sees "I could add Netflix in 3 taps" — which removes the last objection to a manual-entry app. This screenshot directly justifies the premium price.

---

## After Capturing

1. Place each screenshot into the corresponding frame HTML file:
   - Open `frames/frame_0X_name.html` in a text editor
   - Find the commented `<img>` tag inside the `.screen` div
   - Uncomment it and set `src` to your screenshot file path
2. Export each frame at 3× scale — see `SCREENSHOT_GUIDE.md` for export instructions
3. Final exports should be **1290 × 2796px PNG** for submission to both stores
