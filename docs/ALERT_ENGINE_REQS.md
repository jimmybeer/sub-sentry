# Alert Engine Requirements & Implementation Plan

> **Objective**: Implement a robust, local-first notification system ("Alert Engine") that ensures users never miss a subscription renewal, trial expiry, or contract end date.

## 1. Overview
The **Alert Engine** acts as the proactive voice of SubSentry. It is responsibly for calculating upcoming key dates for every subscription and scheduling local push notifications to warn the user. Ideally, it works entirely offline without a backend.

## 2. Functional Requirements


### 2.1 Notification Types
The engine must support three distinct categories of alerts:

| Type | Trigger Logic | Content Template | Priority |
| :--- | :--- | :--- | :--- |
| **Weekly Summary** | Every Monday at 9:00 AM | "This week's outgoings: **£45.99** across 3 subscriptions (Netflix, Gym, Spotify)." | High |
| **Trial Warning** | 5 days, 3 days, & 24h before `trialEndDate` | "URGENT: Your **Adobe** free trial ends in [X] days. Cancel now to avoid charge." | Max (Critical) |
| **Contract Expiry** | 30 days before `contractEndDate` | "Heads up: Your **Virgin Media** contract ends soon. Time to re-negotiate?" | Medium |

### 2.2 User Configuration (Settings)
The user must have global control over *when* they receive these alerts.

**Global Settings (`SettingsScreen`)**:
1.  **Weekly Summary**:
    *   Options: `[Monday 9:00 AM]`, `[Sunday 8:00 PM]`, `[Never]`. Default: **Monday 9:00 AM**.
2.  **Trial Alerts**:
    *   Toggle: `[Enable Multi-Stage Warnings]`. Default: **On**.
    *   *Logic*: If On, sends alerts at 5 days, 3 days, and 24 hours. If Off, sends only 24h warning.

**Per-Subscription Overrides (`Add/Edit Subscription`)**:
1.  **Include in Summary**: `bool includeInWeeklySummary`.
    *   If `false`, this subscription's cost is excluded from the "This week's outgoings" calculation (e.g. for secret gifts).


### 2.3 System Logic & Scheduling
1.  **Triggers**:
    *   **On Create/Update Subscription**: Immediately calculate next alert dates and schedule/reschedule via plugin.
    *   **On Delete Subscription**: Cancel specific ID's pending notifications.
    *   **On App Open**: "Daily housekeeping" task to prune old alerts and schedule next cycle (e.g. if a monthly sub just renewed, schedule next month's alert).
    *   **On Settings Change**: Reschedule ALL notifications if the user changes "1 Day Before" to "3 Days Before".

2.  **Permissions**:
    *   Request `Notification` permissions on first app launch OR when the user first visits Settings/Add Screen.
    *   Handle "Permission Denied" gracefully (show UI warning in Settings).

---

## 3. Technical Architecture

### 3.1 Dependencies
*   `flutter_local_notifications`: Core scheduling engine.
*   `timezone`: Required for "Absolute Time" scheduling (e.g. "9:00 AM local time").
*   `permission_handler`: For managing OS-level query.
*   `shared_preferences` / `hive`: Persisting global settings.

### 3.2 Key Classes
*   **`NotificationService`**: Wrapper around the plugin. Handles low-level `show()` and `zonedSchedule()`.
*   **`AlertScheduler` (The Brain)**:
    *   Pure Dart logic (if possible) or Business Logic layer.
    *   Inputs: `List<Subscription>`, `GlobalSettings`.
    *   Outputs: Calls to `NotificationService`.
    *   Methods: `scheduleFor(sub)`, `cancelFor(sub)`, `rescheduleAll()`.

---

## 4. Implementation Plan & TDD Suite

Follow **Test-Driven Development**. Everything below defines the *behavior* we want to verify before we write the code.

### Phase 1: The `AlertScheduler` Logic (Pure Dart)
*Goal: Verify correct date math without touching the plugin.*

#### Test Suite: `test/features/notifications/logic/alert_scheduler_test.dart`

**TC1: Weekly Summary Calculation**
*   **Given**: Today is Sunday. 3 active subscriptions due next week (Total £45).
*   **When**: `calculateWeeklySummary(subs, nextMonday)` is called.
*   **Then**: Return `NotificationPayload` with text "This week's outgoings: £45...".

**TC2: Multi-Stage Trial Warnings**
*   **Given**: `trialEndDate` is 10 days away. Active.
*   **When**: `calculateTrialAlerts(sub)` is called.
*   **Then**: Return LIST of 3 dates: `[EndDate - 5d, EndDate - 3d, EndDate - 24h]`.

**TC3: Excluded from Summary**
*   **Given**: Sub A (£10, included), Sub B (£20, excluded).
*   **When**: `calculateWeeklyTotal(subs)` is called.
*   **Then**: Result is £10.

### Phase 2: The Service Integration (Mocking Plugin)
*Goal: Verify we are calling the platform channel correctly.*

#### Test Suite: `test/features/notifications/services/notification_service_test.dart`

**TC4: Recurring Schedule**
*   **Given**: Weekly Summary enabled for Monday 9am.
*   **When**: `scheduleWeeklySummary()` is called.
*   **Then**: Verify `plugin.zonedSchedule()` called with `DateTimeComponents.dayOfWeekAndTime`.

### Phase 3: Data Layer Integration
*Goal: Reactivity.*

#### Test Suite: `test/features/notifications/integration_test.dart`

**TC5: Summary Update on Edit**
*   **Given**: Weekly Summary scheduled.
*   **When**: User edits Subscription to cost £100 more.
*   **Then**: The *next* Weekly Summary content is regenerated (cancel + reschedule next instance).
*(Note: Since Weekly Summary is recurring, we might just update the payload, or regeneration happens just-in-time if feasible. For MVP, we pre-calculate next occurrence.)*

---

## 5. Developer Checklist (Step-by-Step)

1.  **Dependencies**: Add `flutter_local_notifications`, `timezone`.
2.  **Domain Setup**:
    *   Create `NotificationSettings` model.
    *   Update `Subscription` model with `includeInWeeklySummary`.
    *   Create `AlertScheduler` logic.
3.  **TDD Logic**: Write tests TC1-TC3. Implement `AlertScheduler`.
4.  **Service Setup**: Create `NotificationService` (Wrapper).
5.  **Integration**:
    *   Inject `NotificationService` into `SubscriptionController`.
    *   Add hooks to schedule/cancel Trial alerts.
    *   Add hook to update Weekly Summary total when subs change.
6.  **UI**:
    *   Add "Include in Summary" Toggle to `AddSubscriptionSheet`.
    *   Add "Weekly Summary" & "Trial Warnings" sections to `SettingsScreen`.

## 6. Migration Notes
*   **Existing Data**: Existing subscriptions created before this feature won't have alerts scheduled.
*   **Strategy**: On first launch after update, run a one-time `AlertScheduler.rescheduleAll()` to catch up all existing database items.
