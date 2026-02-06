# 04. Go/No-Go Decision

## 1. Executive Summary
**Decision: GO**

The project **SubSentry** is a viable candidate for development. It targets a clear, verified dissatisfaction with existing solutions ("Paywall limits" and "Subscription Bloat") and executes a simple, high-value utility with a proven business model (Premium Upfront).

## 2. Assessment Criteria

### 2.1 Market Gap (Strong)
*   **The Competitors**: Polarized between "Free-but-crippled" (5 sub limit) and "High-end Automated" ($10/mo bank scanners).
*   **The Opportunity**: A "Blue Ocean" in the middle: An unlimited, manual, private tracker for a single low price.
*   **Verdict**: The "Unlimited for 99p" angle is a strong, defensible marketing hook.

### 2.2 Feasibility (High)
*   **Scope**: Tightly constrained to "Vault + Alerts + Charts". No backend, no bank APIs.
*   **Timeframe**: Core features (CRUD Vault, Local Notifications) can be built in ~3 days. Remaining time (7-10 days) can be dedicated entirely to visual polish (charts/animations).
*   **Tech Stack**: Flutter + Hive + fl_chart is a mature, low-risk stack.

### 2.3 Pricing Logic (Valid)
*   **99p Strategy**: removes friction for acquisition while filtering out "free-loading" users who leave 1-star reviews for lack of features.
*   **Psychology**: "Pay 99p once to save £100s/year" is a compelling value proposition.

## 3. Top 3 Risks & Mitigations

### Risk 1: "The Empty State Problem" (Churn)
User downloads app, sees empty white screen, feels overwhelmed by manual entry, and quits.
*   **Mitigation**: "Smart Onboarding" wizard that asks "Do you have Netflix? Spotify? Amazon Prime?" and pre-populates the vault *before* they land on the dashboard.

### Risk 2: "Ugly Chart Syndrome"
A premium app lives or dies by its aesthetics. If the charts look like Excel defaults, the "Premium" promise is broken.
*   **Mitigation**: Dedicate 40% of development time to UI/Animation. Use a custom theme system (Colors, Rounded corners, Haptics).

### Risk 3: "Notification Fatigue"
If the app nags too much (or at the wrong time), users will revoke permission, killing the core value.
*   **Mitigation**: "Smart Quiet Hours" (don't ping at 3AM) and separate channels for "Bills" vs "Trials".

## 4. Final Verdict

**Project Status: APPROVED (GO)**

*   **Next Phase**: Phase 2 (Design & Architecture)
*   **Immediate Action**: Begin Wireframing Screens (05_WIREFRAMES.md).
