# 01. App Concept: SubSentry

> "Never get surprised by a renewal again."

## 1. Core Proposition

**SubSentry** is a premium, privacy-first utility that helps users take control of their recurring expenses. In an era of "subscription fatigue," it provides a simple, manual-entry dashboard to track free trials, monthly bills, and contract end-dates without requiring bank connection or data sharing.

## 2. Target Audience

-   **Demographic**: Adults 25-45 with multiple digital services (streaming, SaaS, cloud storage) and physical memberships (gyms, clubs).

-   **Psychographic**: Budget-conscious but privacy-aware. They dislike "automatic" trackers that scan their bank emails and prefer a high-control, manual "set and forget" system.

## 3. The "Why" (Market Fit)

-   **Problem**: Users sign up for trials and forget to cancel. Contracts roll over automatically. "Death by a thousand cuts" from £0.99 iCloud tiers and £14.99 Netflix bumps.

-   **Solution**: A rigid, loud, and annoying-when-necessary alarm system for your money.

-   **Differentiation**:

    *   **vs. Spreadsheets**: Better mobile UI, push notifications.

    *   **vs. Fintech Apps**: Privacy (no bank linking), one-off price (no subscription to track subscriptions).

## 4. MVP Feature Scope (Version 1.0)

### 4.1 Subscription Vault

-   **List View**: Clean, categorized list of all active subscriptions.

-   **Sorting**: By "Next Renewal Date" (default), Cost, or Category.

-   **Quick Stats**: "Monthly Total" and "Yearly Total" pinned to the top.
- **Smart Graphs**: Help users visualize when their money is being spend during the month/week/year. This is to help people how struggle to interpret a list of dates and numbers.

### 4.2 Smart Add (Friction Reduction)

-   **Smart Suggestions**: Typing "Net..." suggests "Netflix" and populates default price.

-   **Category Colour Coding**: Visual branding by category (e.g., Entertainment = Red, Utilities = Blue) rather than copyrighted logos.

-   **Cycle Presets**: Weekly, Monthly, Quarterly, Yearly.

### 4.3 The Alert Engine

-   **Renewal Warnings**: Configurable (e.g., 3 days before).

-   **Trial Killer**: "Free Trial" mode with aggressive alerts (24h before expiry).

-   **Contract Watch**: Separate expiry field for long-term contracts (e.g., Broadband 18-month term) to prompt renegotiation.
- **Weekly Look Ahead**: Inform user of the coming weeks total expenditure on subscriptions.

### 4.4 Data & Settings

-   **Local-First Architecture**: All data stored in SQLite/Hive on device. No accounts.

-   **CSV Export**: "Take your data with you" feature.

-   **Single Currency**: Global currency setting (user selects £, $, or € at setup) - initially set based on user locale.

## 5. Monetisation Strategy

-   **Model**: Paid Upfront ("Premium Utility").

-   **Price Point**: £0.99 / $0.99.

-   **Rationale**:

    *   Aligns with the "Save Money" value prop.

    *   Distances the app from ad-supported/data-selling competitors.

    *   Simple "Pay once, save forever" marketing hook.

## 6. Technical Constraints & Risks

-   **Platform**: Flutter (iOS & Android) from a single codebase.

-   **Backend**: None. Zero server costs.

-   **Risk**: User churn due to manual entry friction.

    *   *Mitigation*: "Quick Add" presets and a delightful, haptic-rich UI.

-   **Risk**: Apple/Google rejection for "low functionality".

    *   *Mitigation*: Emphasize the "Contract Watch" and "Trial Killer" specific notifications as unique value.

## 7. Success Metric (North Star)

*   **User Success**: The user cancels a sub *because* of a SubSentry notification.
-   **App Success**: 4.5+ Star Rating focused on "Simple" and "Clean".