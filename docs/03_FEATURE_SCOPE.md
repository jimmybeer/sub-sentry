# 03. Feature Scope (MVP)

> **Philosophy**: "Do less, but better." This is a premium utility, not an enterprise platform.

## 1. The Single Core Feature (The "One Thing")
**The Active Subscription Vault**

The app's primary function is to serve as the **authoritative, local source of truth** for recurring expenses. It must execute **Manual Entry** and **Renewal Tracking** with zero friction and high visual polish.

### 1.1 The "Vault" Experience
*   **Visual List**: Subscriptions displayed as cards with Category Colors (e.g., Entertainment = Red).
*   **Smart Defaults**: Pre-populated fields for common services (Name, Color, Default Price) to speed up entry.
*   **Cycle Logic**: Handling of Weekly, Monthly, Quarterly, and Annual billing cycles.

### 1.2 The "Alert Engine" (The Value Driver)
*   **Renewal Alerts**: Push notifications sent X days before billing.
*   **Trial Warnings**: Distinct "URGENT" style notification 24 hours before a free trial converts.
*   **Contract Expiry**: Long-term warning for 12/18/24 month broadband/gym contracts.

### 1.3 The "Insight Engine" (Visual Premium Feel)
*   **Category Donut Chart**: "Where is my money going?" (e.g., 50% Entertainment).
*   **Monthly Bar Goal**: Visualizing the "Monthly Burden" vs a user-set budget line.
*   *Constraint*: High-polish, static viz (using `fl_chart`). No complex drill-downs or interactive filtering in v1.0.

---

## 2. Explicit "Won't Have" List (v1.0)
*To ensure a 3-4 day build time and eliminate complexity/risk, these features are strictly OUT of scope for v1.0.*

| Feature | Reason for Exclusion |
| :--- | :--- |
| **Cloud Sync / Accounts** | Violates "Local First" privacy promise; adds backend complexity/cost. |
| **Bank Integration (Open Banking)** | Regulatory nightmare; high cost (Plaid/Yodlee fees); violates "99p" model. |
| **Multi-Currency Conversion** | Requires live exchange rate API; adds UI complexity. (User selects ONE global currency). |
| **Receipt Scanning / OCR** | High technical risk; high error rate; unnecessary for simple tracking. |
| **Interactive Spending Reports** | Complex drill-downs excluded. Static charts ONLY. |
| **Family Sharing** | Requires cloud sync (see above). |
| **Subscription Cancellation Services** | Legal risk; we are a tracker, not a "Cancel for me" concierge. |

---

## 3. Complexity Estimate
**Overall Rating: Low-Medium**

*   **UI/UX**: **Medium**. Requires custom animations, haptic feedback, and a polish level equal to "Bobby" to justify the price.
*   **Logic**: **Low**. Standard CRUD (Create, Read, Update, Delete) + Date Math for Next Billing Date.
*   **Notifications**: **Medium**. Requires robust local notification scheduling (handling time zones and device restarts).
*   **Data**: **Low**. Simple local relational integration (SQLite/Hive).

---

## 4. Technical Architecture Strategy
**App Type: `self_contained`**

*   **Backend**: **None**. Zero server dependencies.
*   **Database**: **Local Storage** (Hive or SQLite via Drift).
*   **State Management**: **Riverpod** (standard Flutter choice for clean architecture).
*   **Assets**: All "logo-like" assets (Category Icons) must be bundled within the app binary.

## 5. Success Criteria (Definition of Done)
1.  User can add "Netflix" in < 10 seconds.
2.  App correctly calculates "Next Bill Date" for Monthly vs Yearly cycles.
3.  Notification fires reliably on the simulated date.
4.  User can see "Total Monthly Spend" at a glance.
