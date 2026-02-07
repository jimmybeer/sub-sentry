# 05. Wireframes & User Flow

> **Design Philosophy**: "Thumb-First Efficiency". The user should be able to see their status and add a new bill with one hand while walking.

## 1. Screen Inventory
1.  **Onboarding Wizard** (First Run Only)
2.  **Dashboard** (The "Pulse" Home)
3.  **Add/Edit Subscription Sheet** (The Core Action)
4.  **Settings** (Preferences & Data)

---

## 2. Detailed Screen Specifications

### 2.1 Onboarding Wizard (First Run)
*Goal: Get the user to add *one* subscription immediately so the dashboard isn't empty.*

**Layout:**
*   **Header**: "Welcome to SubSentry. Let's get organized." (Large, Bold)
*   **Body**: 
    *   Simple Question: "What's one service you pay for?"
    *   **Input**: Smart Text Field (Auto-complete for "Netflix", "Spotify", etc.)
    *   **Action**: "Next" (Floating Action Button - FAB)
*   **Step 2**: "How much?" (Number Pad pops up)
*   **Step 3**: "When is it due?" (DatePicker)
*   **Completion**: "You're in control. Let's see your dashboard." -> Transitions to Home.

### 2.2 Dashboard (Home)
*Goal: Instant status check ("Where do I stand?") and quick access to add more.*

**Layout (Top to Bottom):**
1.  **The Insight Engine (Top 35%)**:
    *   **Tab Switcher** (Segmented Control): [Pulse] | [Breakdown]
    *   **"Pulse" View**: 
        *   Horizontal Scrollable Bar Chart (Days 1-31).
        *   Current Day highlighted.
        *   Line overlay showing cumulative spend to date.
    *   **"Breakdown" View**: 
        *   Donut Chart (Color-coded by Category).
        *   Center Text: "Total: £145.50".
2.  **The Vault List (Remaining Vertical Space)**:
    *   **Section Header**: "Upcoming" (Sticky Header)
    *   **List Items**: Card layout.
        *   *Left*: Category Icon (color background circle).
        *   *Middle*: Name (Bold) + Next Due Date (Subtext, e.g. "Tomorrow").
        *   *Right*: Cost (e.g. "£9.99").
    *   **Empty State**: If list is empty, show illustration + "Clean slate. You're free! (Or are you forgetting something?)".
3.  **Floating Action Button (FAB)**:
    *   Position: Bottom-Right (Android) / Top-Right "Add" (iOS) - *Wait, enforcing bottom-right for both for thumb ease.*
    *   Icon: Large "+".
    *   Action: Opens "Add Subscription Sheet".

### 2.3 Add/Edit Subscription Sheet
*Goal: Minimum friction data entry. Progressive disclosure.*

**Type**: Modal Bottom Sheet (drags up from bottom).

**Layout:**
1.  **Header**: "New Subscription" (with 'Cancel' and 'Save' buttons).
2.  **Primary Fields (Visible)**:
    *   **Name Input**: "Service Name" (Auto-complete enabled).
    *   **Cost Input**: "0.00" (Large type).
    *   **Cycle Selector**: [Weekly] [Monthly] [Yearly] (Segmented Pill).
    *   **First Bill Date**: "Today" (Tap to open Calendar).
3.  **"More Options" (Collapsible Accordion)**:
    *   *Tap to Expand*:
        *   **Category**: Dropdown (defaults based on Name if smart-matched).
        *   **Description/Notes**: Text field.
        *   **Payment Source**: "e.g. Monzo" (Optional).
        *   **Reminders**: Toggle [On/Off].
        *   **Trial Mode**: Toggle [Off]. *If On → Show "Trial End Date"*.
        *   **URL**: "Cancellation Link" field.

### 2.4 Settings
*Goal: Set and forget.*

**Layout:**
*   **General**:
    *   Currency Symbol (£, $, €).
    *   Theme (System/Light/Dark).
*   **Notifications**:
    *   Renewal Alert: [Same Day] / [1 Day Before] / [3 Days Before].
    *   Trial Alert: [24 Hours Before] (Fixed).
*   **Data**:
    *   Export to CSV.
    *   Delete All Data.

---

## 3. Primary User Flow (The "Happy Path")
1.  **Launch**: App opens.
2.  **Dashboard**: User sees "Pulse" chart showing a spike on the 15th.
3.  **Decision**: "I forgot to add Amazon Prime."
4.  **Action**: Tap FAB (+).
5.  **Entry**:
    *   Type "Am..." -> Tap "Amazon Prime" suggestion.
    *   *System auto-fills Category (Shopping) and Color (Blue).*
    *   Type "8.99".
    *   Tap "Save".
6.  **Result**: Sheet closes. "Pulse" chart updates animating the new spike. Toast message: "Prime added."

## 4. Edge Case: Empty State (Zero Data)
*   **Scenario**: User skips onboarding or deletes all data.
*   **Visual**:
    *   Center Screen Illustration: A chill person relaxing (using `undraw` or similar).
    *   Headline: "Ghost Town?"
    *   Subtext: "If you really have 0 subscriptions, you are a legend. If not, hit the + button."
    *   Arrow pointing to FAB.

## 5. Mobile-Specific Constraints
*   **Keyboard Handling**: When entering Cost, ensure numeric keyboard does not obscure the "Save" button (use `ResizeToAvoidBottomInset`).
*   **Haptics**: light impact feedback on "Save" and "Tab Switch" interactions.
*   **Platform Dialogs**:
    *   Delete Confirmation: Use `CupertinoAlertDialog` on iOS, `AlertDialog` on Android.
