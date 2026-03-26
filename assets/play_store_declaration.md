# Google Play Console — Alarms & Reminders Permission Declaration

**App:** SubSentry
**Package:** com.subsentry.sub_sentry
**Permission:** `USE_EXACT_ALARM`
**Declaration section:** App content → Alarms & Reminders

---

## Declaration Text

> SubSentry is a subscription tracking app that helps users monitor their recurring payments and avoid unexpected charges. The app uses exact alarms exclusively to deliver time-sensitive financial notifications, specifically:
>
> - **Renewal reminders** — alerts scheduled 7 days and 1 day before a subscription's annual or quarterly renewal date, giving users time to cancel or budget accordingly.
> - **Trial expiry alerts** — alerts scheduled 5 days, 3 days, 1 day before, and on the day a free trial converts to a paid subscription.
> - **Contract end reminders** — an alert scheduled 30 days before a contract end date so users can renegotiate in time.
> - **Weekly payment summary** — a summary notification delivered at a user-chosen day and time each week, listing upcoming bills.
>
> Exact alarm scheduling is essential because the core value of these alerts is precision. A renewal reminder that fires 6 hours late — after the charge has already been taken — is not useful. Users rely on these alerts to take action (cancelling a subscription, moving funds) before a specific billing event occurs.
>
> The app does not use exact alarms for advertising, engagement, or any purpose unrelated to the user's own subscription schedule. All notification times are set explicitly by the user's billing data and preferences. The permission is used solely to fulfil the app's stated purpose as a financial reminder tool.

---

## Supporting Notes for Reviewer

- All subscription data is stored locally on the user's device. No data is transmitted to any server.
- Notifications are scheduled using `flutter_local_notifications` with `AndroidScheduleMode.exactAllowWhileIdle`.
- The `SCHEDULE_EXACT_ALARM` permission (for Android 12 and below) and `USE_EXACT_ALARM` (Android 13+) are both declared. `SCHEDULE_EXACT_ALARM` is capped at `maxSdkVersion="32"` to avoid duplication on newer devices.
- Users can disable all notification types individually in the app's Settings screen.
- The app targets users who want to track and control their subscription spending — exact timing is a core product requirement, not a convenience feature.
