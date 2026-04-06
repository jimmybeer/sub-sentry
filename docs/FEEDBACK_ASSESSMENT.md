# Feedback Assessment — SubSentry


Assessment of user feedback from `REVIEW_FEEDBACK.md`, evaluated against the current codebase


(Flutter/Riverpod, Hive persistence, `intl` formatting, `url_launcher` and `share_plus` already


included as dependencies).




---


## 1. Dynamic Walkthrough for New Users


### Current State

An onboarding flow **already exists** (`lib/features/onboarding/presentation/onboarding_screen.dart`).


It is a 4-page `PageView`: Welcome → Currency Selection → Notification Permission → Ready. It


launches on first run via the `hasSeenOnboarding` flag in `SettingsState` and is gated by the


router. There is no skip option and no interactive tutorial within the main app itself.



### Assessment



| Dimension | Detail |
| --- | --- |
| **Validity** | Partially valid. The reviewer likely did not see the existing onboarding, or found it insufficient because it does not guide users through actually using the app. |
| **Effort** | Medium |
| **Risk** | Low |


**Pros**
- Reduces first-run abandonment, especially for users unfamiliar with subscription-tracker apps.

- The skeleton is already present — pages can be expanded in-place.

- A skip option is a single `TextButton` addition to the bottom nav row.


**Cons**
- Feature-tour overlays (coach marks) require a third-party package (e.g., `tutorial_coach_mark`)

  or bespoke `OverlayEntry` logic — this is the bulk of the work.


- The main app pages (Dashboard, Add Subscription) were not designed with coach-mark anchor

  points, so adding them requires touching multiple widgets.


- Risk of feeling patronising to returning users if not guarded correctly — requires resetting

  properly per install, not per session.



### Recommended Implementation Options


**Option A — Expand existing onboarding (low effort, addresses most of the concern)**
Add 2–3 extra pages to the existing `PageView` that use screenshots or animated illustrations of


the key screens (dashboard, add subscription, alerts). Add a **Skip** button alongside the


existing Next button. This is the lowest effort path and covers the reviewer's main concern about


users feeling lost.



**Option B — In-app coach marks (high effort, highest quality)**
Add the `tutorial_coach_mark` package. Define spotlight anchors on the FAB (add subscription),


the bottom nav (analysis, settings), and a subscription card. Trigger the tour on first post-


onboarding launch only. Requires `GlobalKey` anchors injected into `DashboardScreen`.



**Option C — Help section (low effort, supplementary)**
Add a "Help & FAQ" `ListTile` in Settings pointing to a GitHub Pages URL or an in-app


`AlertDialog`/`BottomSheet` with common questions. Zero new dependencies, minutes to implement.

**Recommendation:** Ship **Option A + Option C** together. Option B can follow in a later release
once the app has more users to validate the complexity cost.




---


## 2. Comprehensive Currency Support


### Current State

The currency list is hardcoded to three items — `['GBP', 'USD', 'EUR']` — in **two places**:


- `lib/features/settings/presentation/screens/settings_screen.dart` (line 54)

- `lib/features/onboarding/presentation/onboarding_screen.dart` (line 144)


The underlying formatter (`lib/core/utils/currency_formatter.dart`) uses


`intl`'s `NumberFormat.simpleCurrency(name: currencyCode)`, which accepts **any valid ISO 4217
code** without code changes. The `intl` package (already a dependency) bundles locale data that


covers well over 100 currencies.



### Assessment



| Dimension | Detail |
| --- | --- |
| **Validity** | Fully valid — and the fix is almost entirely already in place. |
| **Effort** | Very low |
| **Risk** | Very low |


**Pros**
- The formatter already supports any ISO 4217 code — the only change needed is widening the

  hardcoded list in the two UI files.


- No new dependencies, no API calls, no persistence schema changes.

- Immediately improves accessibility for international users.


**Cons**
- Presenting 150+ currencies in a flat `DropdownButton` as currently used in settings is

  unwieldy — a searchable modal or grouped list would be better UX, which adds minor effort.


- Real-time currency conversion (suggested as an enhancement) is a separate, significantly

  larger feature requiring a third-party exchange rate API, network access, and caching logic.


  The app is currently fully offline; adding network calls changes the privacy/trust posture.



### Recommended Implementation Options


**Option A — Expand the hardcoded list (trivial effort)**
Replace `['GBP', 'USD', 'EUR']` with the ~30–40 most commonly used world currencies. Keep


the `DropdownButton` but sort alphabetically. Two file changes, no new dependencies.



**Option B — Searchable currency picker (low–medium effort)**
Replace the `DropdownButton` with a full-screen or bottom-sheet list with a `TextField` search


filter. More polished, scales to 150+ currencies, mirrors how banking apps handle this. A


`showSearch` scaffold or `showModalBottomSheet` with a filtered `ListView` achieves this.

**Option C — Real-time conversion (out of scope for now)**
Requires an exchange-rate API, network handling, error states, and offline fallback. Deferred


to a future release.



**Recommendation:** Ship **Option B** targeting ~50 common currencies. The infrastructure is
already complete; this is a UI change only. Defer real-time conversion indefinitely unless


analytics show user demand.




---


## 3. "Rate Your App" Button


### Current State

No rate/review prompt exists. The Settings screen has a "Privacy Policy" `ListTile` that


already uses `url_launcher` to open an external URL. `url_launcher` is already a dependency


in `pubspec.yaml`.



### Assessment



| Dimension | Detail |
| --- | --- |
| **Validity** | Fully valid — standard practice for Play Store visibility. |
| **Effort** | Trivial |
| **Risk** | Very low |


**Pros**
- `url_launcher` is already present — this is literally adding one `ListTile`.

- The Play Store deep-link URL scheme (`market://details?id=<package>` with HTTPS fallback) is

  well-documented.


- `package_info_plus` is already a dependency and can supply the package name dynamically.

- Boosts store ratings and visibility at zero ongoing cost.


**Cons**
- A static link in Settings relies on the user proactively navigating there; many users never

  will. A timed in-app prompt (after N subscriptions added or N days of use) would be more


  effective, but is slightly more work and must be carefully tuned to avoid being intrusive.


- Google Play In-App Review API (`in_app_review` Flutter package) provides a native prompt

  without leaving the app — a better experience than a link, but adds a dependency.



### Recommended Implementation Options


**Option A — Static link in Settings (trivial)**
Add a `ListTile` in the "About" section of `SettingsScreen` with `Icons.star_rate` and a


`launchUrl` call to `market://details?id=com.jyapps.subsentry` (HTTPS fallback to Play Store).
Five lines of code.



**Option B — In-App Review API (low effort, better UX)**
Add the `in_app_review` package. Trigger `InAppReview.instance.requestReview()` after the user


has added their third subscription (a signal of genuine engagement). Rate-limit using a


`SharedPreferences`/Hive flag so the prompt only fires once. This is the Google-recommended
pattern and requires no navigation away from the app.



**Recommendation:** Ship both — **Option A** immediately (trivial), and **Option B** in the
next iteration to complement it.




---


## 4. System Theme Option


### Current State

`SettingsState` already defaults to `ThemeMode.system` and the `_themeModeName()` helper in
`SettingsScreen` already has a `ThemeMode.system` → `'System Default'` case. However, the
UI exposes only a binary `Switch` (`dark` / `light`), skipping over system mode entirely.


`toggleTheme()` in `SettingsController` writes `'dark'` or `'light'` — never `'system'`.
The `main.dart` theme resolution wires `themeMode` directly to `MaterialApp`, so system mode


would work end-to-end if the toggle exposed it.



### Assessment



| Dimension | Detail |
| --- | --- |
| **Validity** | Fully valid — this is essentially a bug/omission rather than a new feature. |
| **Effort** | Very low |
| **Risk** | Very low |


**Pros**
- The entire theme infrastructure is already built; `ThemeMode.system` is a Flutter-native

  enum value already handled in `MaterialApp`. Zero new dependencies.


- Fixes the fact that users who installed the app while in system mode and then toggled dark mode can never return to system mode through the UI.

- A `SegmentedButton` or `PopupMenuButton` with three options (System / Light / Dark) is the

  idiomatic Material 3 UI pattern and replaces the current `Switch`.



**Cons**
- The binary `Switch` is simple and discoverable; a three-way control is slightly more complex

  but still standard in Material 3.


- Minor persistence change: `toggleTheme(bool)` needs to be replaced or supplemented with a

  `setThemeMode(ThemeMode)` method that also persists `'system'`.

### Recommended Implementation Options


**Option A — Three-way SegmentedButton (very low effort)**
Replace the `Switch` in `SettingsScreen` with a `SegmentedButton<ThemeMode>` with segments for


`System`, `Light`, `Dark`. Update `SettingsController` to add a `setThemeMode(ThemeMode)` method
that writes `'system'`/`'light'`/`'dark'`. Change the Hive read at startup to recognise


`'system'`. Total changes: `settings_screen.dart` + `settings_controller.dart`, ~15 lines.

**Option B — Keep Switch, add third state (not recommended)**
Extend the existing switch with a separate toggle for "Use System Theme." Adds UI complexity


without benefit. Avoid.



**Recommendation:** **Option A** — this is the highest value-to-effort ratio item in the entire
feedback report. Ship it.




---


## 5. Additional Recommendations (Supplementary Feedback)


### 5a. Feedback Mechanism


**Assessment:** Low priority. A `mailto:` link in Settings ("Send Feedback") using `url_launcher`
is trivial to add and meets the spirit of the suggestion without requiring a backend or third-party


survey tool. A Google Form URL is another zero-backend option.



**Recommendation:** Add a `ListTile` in the About section opening a `mailto:` link. Trivial effort.


---


### 5b. Regular Updates


**Assessment:** Not a code change. This is a product/process recommendation. Acknowledge as
a development practice commitment rather than an implementation task.



**Recommendation:** No code action required.


---


### 5c. Enhanced Data Security Information


**Assessment:** The app is already fully local — all data is stored in Hive on-device with no
network transmission except Sentry error reporting (already disclosed via the privacy policy).


The privacy policy page is already linked in Settings. The main gap is that users who never


visit Settings may not know this.



Adding a brief "Your data stays on your device" callout to the existing onboarding screen (e.g.,


a bullet point on the welcome page or a dedicated trust page) would address this at zero code


complexity.



**Recommendation:** Add a one-liner to the onboarding welcome page or the "You're All Set!" page.
Trivial effort, meaningful trust signal.




---


### 5d. Social Media Integration


**Assessment:** `share_plus` is **already a dependency** in `pubspec.yaml`. The infrastructure
for sharing is present. Sharing could expose something like "I saved £X this month by cancelling


N subscriptions with SubSentry" drawn from the existing analysis stats logic.



**Pros:** `share_plus` is already imported; no new dependencies. Analysis data is already
computed in `lib/features/analysis/logic/subscription_stats_logic.dart`.



**Cons:** Sharing financial data requires careful user consent framing. The message text must be
opt-in and clearly non-sensitive (total spend, not individual subscription names). The share


sheet UI needs a natural trigger point — this is the main design decision.



**Recommendation:** Medium priority. A "Share your savings" button on the Analysis screen
is the natural home. Achievable in ~1–2 hours given `share_plus` is already present.




---


### 5e. Promotional Offers / Partnerships


**Assessment:** This is a business development suggestion, not a technical implementation task.
It would require negotiating partnerships, building a dedicated screen, and potentially managing


affiliate links — well out of scope for an app challenge submission. Not recommended for this


phase.



**Recommendation:** Deferred indefinitely. Not actionable at this stage.


---


## Priority Summary



| # | Suggestion | Effort | Recommended Action |
| --- | --- | --- | --- |
| 4 | System Theme Option | Very low | **Ship immediately** — infrastructure 95% done |
| 3a | Rate App — Static Link | Trivial | **Ship immediately** — one `ListTile` |
| 2 | Expanded Currency Support | Low | **Ship in next update** — formatter already supports it |
| 3b | Rate App — In-App Review API | Low | Ship alongside currency update |
| 1a | Onboarding skip + extra pages | Low | Ship in next update |
| 5a | Feedback mailto link | Trivial | Bundle with next update |
| 5c | Data security callout in onboarding | Trivial | Bundle with next update |
| 5d | Share savings (share_plus) | Medium | Next iteration — dependency already present |
| 1b | Coach mark feature tour | High | Future release |
| 2c | Real-time currency conversion | High | Future release — changes offline posture |
| 5b | Regular updates | N/A | Process commitment, not code |
| 5e | Promotional partnerships | N/A | Business decision, out of scope |