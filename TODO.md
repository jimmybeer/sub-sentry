# SubSentry — Production Release TODO


> Generated: 2026-03-13

> Version: 1.0.0+1

> Target: Google Play Store (Android)


Issues are grouped by severity and ordered by recommended fix sequence. Each issue lists three candidate solutions, with a ✅ **recommended** option and a ready-to-use AI agent prompt for that recommendation.



---


## BLOCKERS — Must fix before any submission attempt



---


### BLOCKER-1 · Release build signed with debug keys


**File:** `android/app/build.gradle.kts:35–39`
The release build type uses `signingConfigs.getByName("debug")`. Play Store will reject any AAB signed with the Android debug keystore, and any future update must be signed with the same key — so establishing the correct key now is critical.


#### Option A — `key.properties` file + `signingConfigs.release` block (✅ Recommended)

Create a `key.properties` file excluded from version control, read it in `build.gradle.kts`, define a `signingConfigs.release` block pointing to the real keystore, and assign it to `buildTypes.release`. This is the standard Flutter/Android approach and keeps secrets out of source.


**Rationale:** Industry standard, supported by official Flutter docs, allows CI to inject the keystore path/password via environment variables, and `.gitignore`-able by default.

> **AI Agent Prompt:**

> ``

> You are working on a Flutter app targeting the Google Play Store.

`> The file `android/app/build.gradle.kts currently uses the debug signing

> config for the release build type (line 38: signingConfig = signingConfigs.getByName("debug")).

>

> Task:

`> 1. Create the file `android/key.properties with the following placeholder content

>    (do NOT populate real values — leave them as placeholders the developer fills in):

>      storePassword=REPLACE_WITH_KEYSTORE_PASSWORD

>      keyPassword=REPLACE_WITH_KEY_PASSWORD

>      keyAlias=REPLACE_WITH_KEY_ALIAS

>      storeFile=REPLACE_WITH_PATH_TO_JKS_FILE

>

`> 2. Add `key.properties` to `android/.gitignore if not already present.

>

`> 3. Update `android/app/build.gradle.kts to:

`>    a. Read `key.properties` into a `Properties object at the top of the file,

>       with a graceful fallback (log a warning if the file is missing so CI can

>       override via environment variables instead).

`>    b. Define a `signingConfigs { release { ... } } block that reads storeFile,

>       storePassword, keyAlias, and keyPassword from that Properties object.

`>    c. Replace `signingConfig = signingConfigs.getByName("debug") inside

`>       `buildTypes { release { ... } } with

`>       `signingConfig = signingConfigs.getByName("release").

>

> 4. Leave a comment above the key.properties block explaining that the developer

`>    must generate a keystore via `keytool before building a release AAB.

>

> Do not generate or invent any actual passwords or keystore data.

`> ``


#### Option B — Android Studio GUI signing wizard

`Use Android Studio's "Generate Signed Bundle / APK" wizard to create the keystore and auto-update `build.gradle`. Easier for beginners but stores credentials in IDE config rather than a portable `key.properties file.


#### Option C — Google Play App Signing (upload key only)

Generate a temporary upload key, configure it for release signing, and enrol in Google Play App Signing so Google manages the distribution key. Adds an extra layer of safety if the upload key is ever lost, but requires completing Play Console enrolment before the first build.



---


### BLOCKER-2 · Dev-only tools exposed to production users


**File:** lib/features/settings/presentation/screens/settings_screen.dart:162–188
"Generate Test Data" and "Test Notification" are visible to all users. These items create junk data and fire spurious notifications on production devices.


#### `Option A — Wrap both items in `kDebugMode` guards (✅ Recommended)`

`Surround each `ListTile` (and its following `Divider`) with `if (kDebugMode) .... Zero runtime cost in release builds; the items simply don't exist in the widget tree.


**Rationale:** One-line change per item, zero architectural impact, Flutter's standard mechanism for debug-only UI, and the items are preserved for continued development use.

> **AI Agent Prompt:**

`> ``

> You are working on a Flutter app.

`> File: `lib/features/settings/presentation/screens/settings_screen.dart

>

> Task: Gate the two development-only settings list items so they are

> completely absent from release builds.

>

`> 1. Add `import 'package:flutter/foundation.dart'; if it is not already

>    imported at the top of the file.

>

> 2. Find the ListTile for "Generate Test Data" (around line 162) and its

`>    immediately following `const Divider(). Wrap both together in:

>      if (kDebugMode) ...[

>        // ... ListTile ...

>        const Divider(),

>      ],

>

> 3. Find the ListTile for "Test Notification" (around line 178) and its

`>    immediately following `const Divider()`. Apply the same `if (kDebugMode)

>    spread wrapper.

>

> 4. Do not change any other code. Do not remove the underlying

`>    `_generateTestData` or `_triggerTestNotification methods — they are still

>    useful during development.

`> ``


#### Option B — Delete both items and their handler methods entirely

Removes dead code permanently. Downside: you lose the convenient test-data generator for future development and QA.


#### Option C — Move to a hidden "Developer Menu" behind a tap counter

Add a secret 7-tap counter on the app version number (like Android's Developer Options) to reveal a dev menu. Preserves access but is over-engineered for this use case.



---


### `BLOCKER-3 · Sentry `tracesSampleRate = 1.0` in production`


**File:** lib/main.dart:24
100% performance tracing on every user session will exhaust the Sentry free tier almost immediately, add measurable latency on every transaction, and generate unexpected billing charges.


#### `Option A — Lower to `0.1` and guard debug vs release with `kReleaseMode` (✅ Recommended)`

`Set `tracesSampleRate = kReleaseMode ? 0.1 : 1.0. This preserves full local tracing during development while only capturing 10% of production traces — enough to identify patterns without quota impact.


**Rationale:** Best of both worlds; no separate build configurations required; instantly understandable to any developer reading the file.

> **AI Agent Prompt:**

`> ``

> You are working on a Flutter app.

`> File: `lib/main.dart

>

> Task: Fix the Sentry performance tracing sample rate so it is safe for

> production.

>

`> 1. Add `import 'package:flutter/foundation.dart'; if not already present.

>

`> 2. Find the line `options.tracesSampleRate = 1.0; (around line 24).

>    Replace it with:

>      options.tracesSampleRate = kReleaseMode ? 0.1 : 1.0;

>

> 3. Do not change anything else in the file.

`> ``


#### `Option B — Remove `tracesSampleRate` entirely`

Disables performance tracing completely. Simpler, but you lose all production performance data.


#### `Option C — Set `tracesSampleRate = 0.05` unconditionally`

A fixed low rate is fine for production but means you get reduced trace coverage even during local development and QA, making it harder to catch performance regressions before shipping.



---


### BLOCKER-4 · Sentry DSN hardcoded in source


**File:** lib/main.dart:22–23
The DSN is committed in plain text. Anyone with repository access can flood your Sentry project with fake events or infer your org/project IDs.


#### `Option A — Extract to `--dart-define` with a fallback empty string (✅ Recommended)`

`Replace the inline string with `const String.fromEnvironment('SENTRY_DSN')`. Pass the real DSN at build time via `flutter build appbundle --dart-define=SENTRY_DSN=https://.... Add a guard so Sentry only initialises when the DSN is non-empty, preventing crashes in environments where it is not supplied.


**Rationale:** No external tooling required; works with any CI system; the DSN is never in source or build artefacts; --dart-define values are stripped from debug output.

> **AI Agent Prompt:**

`> ``

> You are working on a Flutter app.

`> File: `lib/main.dart

>

> Task: Remove the hardcoded Sentry DSN and replace it with a dart-define

> environment variable.

>

> 1. Find the block:

>      options.dsn =

>          'https://38f4aebc60bdbbbe0321d756476987ba@o4510866595053568.ingest.de.sentry.io/4510894655537232';

>    Replace it with:

>      options.dsn = const String.fromEnvironment('SENTRY_DSN');

>

`> 2. The `SentryFlutter.init(...) call wraps the entire app startup. Add a

>    check so that if the DSN is empty (i.e. not provided), Sentry init is

>    skipped and the app starts directly. The cleanest approach is:

>

>      const sentryDsn = String.fromEnvironment('SENTRY_DSN');

>      if (sentryDsn.isNotEmpty) {

>        await SentryFlutter.init(

>          (options) {

>            options.dsn = sentryDsn;

>            options.tracesSampleRate = kReleaseMode ? 0.1 : 1.0;

>          },

>          appRunner: _runApp,

>        );

>      } else {

>        await _runApp();

>      }

>

>    Extract the existing app startup logic (Hive init through runApp) into a

`>    top-level `Future<void> _runApp() function so it can be called from both

>    branches.

>

> 3. Add a comment above the sentryDsn constant explaining that the DSN must be

`>    supplied via `--dart-define=SENTRY_DSN=<value> at build time and should

>    never be committed to source control.

>

> 4. Do not change any other logic.

`> ``


#### `Option B — Use a `.env` file loaded by `flutter_dotenv``

`Adds a dependency and a `.env` file that must also be excluded from version control. More familiar to web developers but adds complexity compared to `--dart-define.


#### Option C — Leave as-is but rotate the DSN immediately

The quickest mitigation if a release is imminent, but does not fix the root problem — the DSN will be exposed again in the next commit.



---


### `BLOCKER-5 · `debugLogDiagnostics: true` left on in router`


**File:** lib/app/router/app_router.dart:25
Emits verbose navigation logs on every route change. Technically a no-op in release mode output, but signals the code was not reviewed pre-release and marginally impacts build size.


#### `Option A — Replace with a `kDebugMode` conditional (✅ Recommended)`

`Change `debugLogDiagnostics: true` to `debugLogDiagnostics: kDebugMode. One character change, no imports needed (already used elsewhere in the file).


**Rationale:** Minimal change, zero risk, and preserves the useful debug logging during development.

> **AI Agent Prompt:**

`> ``

> You are working on a Flutter app.

`> File: `lib/app/router/app_router.dart

>

> Task: Make the GoRouter debug logging conditional on debug builds only.

>

`> 1. Find the line `debugLogDiagnostics: true, in the GoRouter constructor.

`> 2. Replace it with `debugLogDiagnostics: kDebugMode,

`> 3. Ensure `package:flutter/foundation.dart is imported (add it if missing).

> 4. Do not change anything else.

`> ``


#### `Option B — Set to `false` unconditionally`

Disables it permanently including in debug builds, losing useful development logging.


#### Option C — Remove the parameter entirely

`Equivalent to `false (the default). Valid but less explicit about intent.



---


### `BLOCKER-6 · `USE_EXACT_ALARM` not declared in Play Console`


**File:** android/app/src/main/AndroidManifest.xml:5
`Google Play requires apps using `USE_EXACT_ALARM to complete the "Alarms & Reminders" declaration in Play Console's "App content" section. Apps submitted without this declaration are rejected.


#### Option A — Complete the Play Console declaration + add in-app justification comment (✅ Recommended)

`This is a Play Console action, not a code change. Navigate to Play Console → App content → Alarms & Reminders, declare the use case ("notify users of upcoming subscription renewals and trial expirations at precise dates and times"), and add a code comment in `AndroidManifest.xml explaining the permission's purpose for future reviewers.


**Rationale:** Required. No alternatives exist — you must complete this form before submission.

> **AI Agent Prompt:**

`> ``

> You are working on a Flutter app's Android manifest.

`> File: `android/app/src/main/AndroidManifest.xml

>

> Task: Add a developer-facing comment above the USE_EXACT_ALARM permission

> that explains the use case, making it easy to copy into the Play Console

> "Alarms & Reminders" declaration form.

>

> 1. Find the line:

>      <uses-permission android:name="android.permission.USE_EXACT_ALARM" />

>

> 2. Add the following comment block immediately above it:

>      <!--

>        USE_EXACT_ALARM: Required to schedule subscription renewal and trial

>        expiry notifications at precise dates and times. SubSentry is a

>        subscription tracker whose core value proposition is alerting users

>        before they are charged. Imprecise alarms (AlarmManager.set or

>        setInexactRepeating) could fire hours late, making the alerts useless.

>        This permission is declared in Play Console under:

>        App content > Alarms & Reminders > [justification submitted].

>      -->

>

> 3. Do not change any other part of the manifest.

`> ``


#### `Option B — Switch to `SCHEDULE_EXACT_ALARM` (API 31–32 alternative)`

SCHEDULE_EXACT_ALARM` requires runtime permission request on API 31–32 but not API 33+. However `USE_EXACT_ALARM is the correct API 33+ replacement. Using both adds complexity.

#### Option C — Downgrade to inexact alarms

Avoids the permission entirely but fundamentally breaks the product — a "notify me 3 days before my trial ends" alert that fires at a random time is not useful.



---


## HIGH SEVERITY — Fix before launch



---


### HIGH-1 · Currency setting not wired to display formatting


**Files:**
``- ``lib/features/subscriptions/presentation/widgets/subscription_card.dart:35``

- ``lib/features/analysis/presentation/widgets/pulse_chart.dart:191``

- ``lib/features/analysis/presentation/widgets/breakdown_chart.dart:40``

- ``lib/features/notifications/logic/alert_scheduler.dart:60``

- ``lib/features/dashboard/presentation/dashboard_screen.dart:200``

- ``lib/features/subscriptions/presentation/widgets/subscription_form.dart:258``


`All these locations hardcode `en_GB` locale or the `£ symbol. A user who selects USD or EUR in Settings will see wrong currency symbols everywhere.


#### `Option A — Create a shared `CurrencyFormatter` utility that reads from `settingsControllerProvider` (✅ Recommended)`

`Create `lib/core/utils/currency_formatter.dart` with a single `format(double amount, String currencyCode)` function. Update each widget to use it — `ConsumerWidget` variants where needed to access `ref.


**Rationale:** Centralises currency logic so future currency additions only require one change. The settings system is already built; this just wires it up.

> **AI Agent Prompt:**

`> ``

> You are working on a Flutter/Riverpod app (sub_sentry).

`> The app has a `settingsControllerProvider (Riverpod AsyncNotifier) whose

`> `SettingsState` has a `String currencyCode field ('GBP', 'USD', or 'EUR').

>

> Task: Wire the currency setting to all display widgets that currently

> hardcode GBP/£.

>

`> Step 1 — Create `lib/core/utils/currency_formatter.dart:

>   A top-level function:

>     String formatCurrency(double amount, String currencyCode)

`>   that uses `NumberFormat.simpleCurrency(name: currencyCode) from the

`>   `intl` package to format `amount. No class needed — just the function.

>

`> Step 2 — Update `lib/features/subscriptions/presentation/widgets/subscription_card.dart:

`>   - Convert `SubscriptionCard` from `StatelessWidget` to `ConsumerWidget.

`>   - Watch `settingsControllerProvider.select((s) => s.value?.currencyCode ?? 'GBP').

`>   - Replace `NumberFormat.simpleCurrency(locale: 'en_GB').format(subscription.cost)

`>     with `formatCurrency(subscription.cost, currencyCode).

>

`> Step 3 — Update `lib/features/analysis/presentation/widgets/pulse_chart.dart:

>   - The widget is already a ConsumerWidget or has access to ref. If not,

>     convert it.

`>   - Replace the `en_GB` locale format call with `formatCurrency(value, currencyCode).

>

`> Step 4 — Update `lib/features/analysis/presentation/widgets/breakdown_chart.dart:

>   - Same pattern as Step 3.

>

`> Step 5 — Update `lib/features/dashboard/presentation/dashboard_screen.dart:

`>   - Find the hardcoded `'Run Rate: £${stats.totalNormalizedMonthlyCost.toStringAsFixed(2)}/mo' string.

`>   - Replace the `£` prefix and `toStringAsFixed(2) with

`>     `formatCurrency(stats.totalNormalizedMonthlyCost, currencyCode).

`>   - Append `/mo after the formatted value.

>

`> Step 6 — Update `lib/features/subscriptions/presentation/widgets/subscription_form.dart:

`>   - Find `prefixText: '£' in the cost TextFormField InputDecoration.

>   - Convert the form widget to a ConsumerWidget if it is not already.

>   - Derive the currency symbol from the currency code:

>     const symbols = {'GBP': '£', 'USD': '\$', 'EUR': '€'};

>     final symbol = symbols[currencyCode] ?? currencyCode;

`>   - Replace the hardcoded `'£'` with `symbol.

>

`> Step 7 — Update `lib/features/notifications/logic/alert_scheduler.dart:

`>   - The `calculateWeeklySummary or relevant method passes the currency code

`>     already (or if not, add a `String currencyCode parameter).

`>   - Replace `NumberFormat.simpleCurrency(locale: 'en_GB') with

`>     `NumberFormat.simpleCurrency(name: currencyCode).

>

> Only modify the currency-related lines in each file. Do not refactor other

`> logic. Run `flutter analyze mentally and ensure no new type errors are

> introduced.

`> ``


#### `Option B — Pass `currencyCode` as a constructor parameter to each widget`

Avoids making widgets into ConsumerWidgets but requires all callers to pass the currency down. Verbose and easy to miss a call site.


#### `Option C — Use a global `ValueNotifier` for currency`

Bypasses Riverpod and adds a parallel state management pattern to an app that already uses Riverpod throughout. Not recommended.



---


### `HIGH-2 · Broken `alert_scheduler_test.dart` test`


**File:** test/features/notifications/logic/alert_scheduler_test.dart:104
calculateTrialAlertDates()` now returns 4 dates (5d, 3d, 1d, day-of) but the test asserts `expect(dates.length, 3). The test is currently failing and will fail CI.

#### Option A — Update the test to match the current 4-date implementation (✅ Recommended)

`Change `expect(dates.length, 3)` to `expect(dates.length, 4)`, add an assertion for `dates[3]` (day-of), and normalise all expected values to 9 AM to match the `set9am() normalisation in the production code.


**Rationale:** The production code is correct; the test simply lags behind. Updating the test is the right fix.

> **AI Agent Prompt:**

`> ``

> You are working on a Flutter app.

`> File: `test/features/notifications/logic/alert_scheduler_test.dart

>

`> Background: `AlertScheduler.calculateTrialAlertDates(sub) returns 4

> DateTime values — alerts at 5 days, 3 days, 1 day, and 0 days (day-of)

`> before `sub.trialEndDate. Each returned date is normalised to 09:00 local

> time (i.e. the same calendar date as the raw offset, but with hour=9,

> minute=0, second=0, millisecond=0).

>

> Task: Fix the failing test so it correctly asserts the 4-date contract.

>

`> 1. Find `expect(dates.length, 3)` and change it to `expect(dates.length, 4).

>

`> 2. Review all existing `expect(dates[0], ...)`, `expect(dates[1], ...),

`>    `expect(dates[2], ...) assertions. Each expected value should be:

>      DateTime(trialEnd.year, trialEnd.month, trialEnd.day - N, 9, 0, 0, 0)

>    where N is 5, 3, 1 respectively (accounting for month boundaries

>    correctly if the test fixture's trialEnd is near the start of a month).

>

`> 3. Add a new assertion for `dates[3]:

>      expect(dates[3], DateTime(trialEnd.year, trialEnd.month, trialEnd.day, 9, 0, 0, 0));

>    (same calendar day as trialEnd, at 09:00).

>

`> 4. If the existing expected values use raw `trialEnd.subtract(Duration(days: N))

>    without hour normalisation, replace them with the explicit

`>    `DateTime(year, month, day, 9, 0, 0, 0) form.

>

> 5. Do not change the production AlertScheduler code.

> 6. Run the test mentally to verify it would pass.

`> ``


#### Option B — Delete the test and write a new one from scratch

Clean but wasteful — the existing test fixture setup and test structure are reusable.


#### `Option C — Mark the test as `@Skip('needs update')` temporarily`

Hides the failure but ships broken code. Not acceptable for a production release.



---


### HIGH-3 · Notification ID hash collision risk


**File:** lib/features/subscriptions/presentation/providers/subscription_controller.dart:91,121,143
`Notification IDs are computed as `sub.id.hashCode + offset`. Two subscriptions with different IDs but colliding `hashCode values (or offset-overlapping hashes) will silently overwrite each other's notifications.


#### Option A — Use a deterministic, collision-safe ID derived from UUID + category (✅ Recommended)

`Replace `sub.id.hashCode with a 32-bit hash of the full UUID that guarantees uniqueness within the app's subscription set. The cleanest approach: parse the last 8 hex characters of the UUID as a 32-bit int, then apply the offsets. Since UUIDs are unique by construction, and the offsets are small relative to the UUID range, collisions become astronomically unlikely.


**Rationale:** No new dependencies, no storage changes, minimal code change, and UUIDs are already the subscription ID format.

> **AI Agent Prompt:**

`> ``

> You are working on a Flutter app.

`> File: `lib/features/subscriptions/presentation/providers/subscription_controller.dart

>

> Background: Notification IDs are currently computed as:

`>   - Trial alerts:    `sub.id.hashCode + (i + 1)   (values 1..4)

`>   - Renewal alerts:  `sub.id.hashCode + 2000 + i  (values 2000..2001)

`>   - Contract alerts: `sub.id.hashCode + 999

>

`> `sub.id` is a UUID string. `String.hashCode in Dart is not collision-safe

> and can be the same for two different UUIDs, causing one subscription's

> notification to silently overwrite another's.

>

`> Task: Replace `sub.id.hashCode with a more collision-resistant base ID.

>

`> 1. Add a private helper method to the `SubscriptionController class:

>

>      /// Returns a stable 28-bit base notification ID for a subscription.

>      /// Uses the last 7 hex characters of the UUID, leaving headroom for

>      /// per-type offsets up to ~2004 without overflow into 32-bit signed int.

>      int _baseNotificationId(String subscriptionId) {

>        final clean = subscriptionId.replaceAll('-', '');

>        if (clean.length < 7) return subscriptionId.hashCode.abs() & 0x0FFFFFFF;

>        return int.parse(clean.substring(clean.length - 7), radix: 16);

>      }

>

`> 2. In `_scheduleAlerts`, replace every occurrence of `sub.id.hashCode with

`>    `_baseNotificationId(sub.id).

>

>    The three lines to update are:

>      final id = sub.id.hashCode + (i + 1);        → _baseNotificationId(sub.id) + (i + 1)

>      final id = sub.id.hashCode + 2000 + i;       → _baseNotificationId(sub.id) + 2000 + i

>      final id = sub.id.hashCode + 999;            → _baseNotificationId(sub.id) + 999

>

> 3. Do not change any other logic.

`> ``


#### Option B — Store a monotonically-increasing integer ID per subscription in Hive

`Guarantees uniqueness but requires a migration and a new field on `SubscriptionModel. Over-engineered for this problem.


#### `Option C — Use a full UUID-to-int hash using `crypto` package`

Adds a dependency for a problem solvable without one.



---


### HIGH-4 · Dead duplicate settings screen file


**File:** lib/features/settings/presentation/settings_screen.dart (not routed to)
`An older, simpler settings screen exists at this path. The router points to `lib/features/settings/presentation/screens/settings_screen.dart. The file at the shorter path is dead code.


#### Option A — Delete the file (✅ Recommended)

lib/features/settings/presentation/settings_screen.dart is not referenced by any import or route. Delete it.

**Rationale:** Dead code causes confusion, inflates project size, and can mislead future developers. There is no reason to keep it.

> **AI Agent Prompt:**

`> ``

> You are working on a Flutter app.

>

> Task: Remove a dead code file that is no longer referenced anywhere.

>

`> 1. Verify that `lib/features/settings/presentation/settings_screen.dart

>    is not imported by any other file in the project (search for

>    'settings/presentation/settings_screen' in all .dart files).

>

> 2. If no imports are found, delete the file

`>    `lib/features/settings/presentation/settings_screen.dart.

>

> 3. The correct, active settings screen is at

`>    `lib/features/settings/presentation/screens/settings_screen.dart —

>    do not touch that file.

>

`> 4. Run `flutter analyze to confirm no broken imports after deletion.

`> ``


#### `Option B — Rename it with a `_deprecated` suffix as a record`

Keeps dead code in the repo. Not recommended.


#### Option C — Merge any unique logic back into the active screen first, then delete

Only necessary if the old file contains logic not present in the new screen — which on review it does not.



---


### `HIGH-5 · `cancellationUrl` field has no UI`


**File:** lib/features/subscriptions/presentation/widgets/subscription_form.dart:129
cancellationUrl` exists in the domain model, is persisted, and is exported/imported via CSV, but there is no field in `SubscriptionForm to view or edit it. Users who import data with a cancellation URL set will never see or be able to use it.

#### `Option A — Add a URL text field to `SubscriptionForm` (✅ Recommended)`

`Add a `TextFormField` for `cancellationUrl` below the notes/contract fields, with a validator that checks for a valid URL format using `Uri.tryParse`. Optionally add a launch button using `url_launcher.


**Rationale:** The field was clearly intended to be user-facing (it's in the CSV export, domain model, and Hive adapter). Adding the UI completes the intended feature.

> **AI Agent Prompt:**

`> ``

> You are working on a Flutter app.

`> File: `lib/features/subscriptions/presentation/widgets/subscription_form.dart

>

`> Background: The `Subscription domain model has a nullable

`> `String? cancellationUrl field. It is persisted to Hive and exported/

> imported via CSV, but there is no input field for it in SubscriptionForm.

>

> Task: Add a cancellation URL input field to the subscription form.

>

`> 1. In the `_SubscriptionFormState` class, add a `TextEditingController:

>      final _cancellationUrlController = TextEditingController();

>

`> 2. In `initState`, initialise it from `widget.initialData:

>      _cancellationUrlController.text = widget.initialData?.cancellationUrl ?? '';

>

`> 3. In `dispose, dispose it:

>      _cancellationUrlController.dispose();

>

`> 4. Add a `TextFormField to the form (after the existing notes or contract

>    date field, before the submit button) with:

>    - controller: _cancellationUrlController

>    - labelText: 'Cancellation URL (optional)'

>    - hintText: 'https://...'

>    - keyboardType: TextInputType.url

>    - A validator that returns an error string if the value is non-empty

`>      and `Uri.tryParse(value)?.hasAbsolutePath != true.

>

`> 5. When building the `Subscription object on form submission (find the

`>    place where `Subscription(...) is constructed), add:

>      cancellationUrl: _cancellationUrlController.text.trim().isEmpty

>          ? null

>          : _cancellationUrlController.text.trim(),

>

> 6. Do not change any other form logic.

`> ``


#### `Option B — Remove `cancellationUrl` from the domain model, Hive adapter, and CSV`

Makes the codebase consistent by removing the field entirely. Breaks existing CSV imports for any users who have this data.


#### Option C — Display the URL as read-only in the subscription detail view only

Easier than a full editable field, but still leaves the user unable to set it from within the app.



---


### HIGH-6 · No Privacy Policy


The app collects crash and performance data via Sentry. Google Play requires a Privacy Policy URL in the Play Console listing. Its absence is a submission blocker.


#### Option A — Create a minimal hosted Privacy Policy and add an in-app link (✅ Recommended)

Write a minimal Privacy Policy (covering: data collected = crash reports/performance traces; processor = Sentry; data retention = Sentry's default; no sale of data; contact email). Host it on a free static page (GitHub Pages, Notion, etc.). Add a "Privacy Policy" link in the Settings screen. Paste the URL into Play Console's Store Listing.


**Rationale:** Required by Play Store policy. Even a one-page policy covering Sentry crash reporting is sufficient for an app of this type.

> **AI Agent Prompt:**

`> ``

> You are working on a Flutter app.

`> File: `lib/features/settings/presentation/screens/settings_screen.dart

>

> Task: Add a Privacy Policy link tile to the Settings screen.

>

`> 1. Add the `url_launcher package import at the top of the file:

>      import 'package:url_launcher/url_launcher.dart';

>    (Assume url_launcher is already in pubspec.yaml; if not, note that it

>    must be added.)

>

`> 2. At the bottom of the `ListView` children list (before the closing `]),

>    add a new section:

>

>      const Divider(),

>      const Padding(

>        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),

>        child: Text('About',

>            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),

>      ),

>      ListTile(

>        leading: const Icon(Icons.privacy_tip_outlined),

>        title: const Text('Privacy Policy'),

>        trailing: const Icon(Icons.open_in_new, size: 16),

>        onTap: () => launchUrl(

>          Uri.parse('[https://jyappsupport.github.io/subsentry/](https://jyappsupport.github.io/subsentry/)'),

>          mode: LaunchMode.externalApplication,

>        ),

>      ),

>      ListTile(

>        leading: const Icon(Icons.info_outline),

>        title: const Text('Version'),

>        subtitle: const Text('1.0.0'),   // Replace with PackageInfo lookup if desired

>      ),

>

> 3. Leave 'REPLACE_WITH_PRIVACY_POLICY_URL' as a placeholder string with a

>    TODO comment so the developer can fill it in once the policy is hosted.

>

> 4. Do not change any other settings screen logic.

`> ``


#### Option B — Use an in-app WebView to display an HTML privacy policy stored as an asset

`Avoids external hosting but requires `webview_flutter dependency and makes policy updates require an app update.


#### Option C — Display the policy as a full-screen text widget

No dependency needed but looks unprofessional and is harder to update.



---


## MEDIUM SEVERITY — Fix before launch



---


### `MED-1 · Bare `print()` in production code`


**File:** lib/features/settings/data/data_transfer_service.dart:112
`An unguarded `print(...) call will output to stdout in release builds and may expose subscription data names in device logs.


#### `Option A — Replace with `debugPrint` inside `kDebugMode` (✅ Recommended)`

if (kDebugMode) debugPrint('CSV parse error on row $i: $e');

> **AI Agent Prompt:**

`> ``

`> File: `lib/features/settings/data/data_transfer_service.dart

`> Find the bare `print(...) call around line 112 (inside a CSV row parse

> catch block). Replace it with:

>   if (kDebugMode) debugPrint('CSV row parse error: $e');

`> Add `import 'package:flutter/foundation.dart'; if not already imported.

`> ``


#### Option B — Remove the log entirely

Silently swallows parsing errors with no trace even in debug builds.


#### `Option C — Use `ErrorHandler.log(e, StackTrace.current)` to route through Sentry`

Appropriate for errors you want tracked in production. May be over-reporting for routine malformed CSV rows.



---


### `MED-2 · `ErrorHandler.handleError` is a no-op`


**File:** lib/shared/error_handling/error_handler.dart:39–45
The method logs to Sentry but never surfaces anything to the user. The comment says "in a real app you might show a SnackBar" — this is a real app.


#### Option A — Implement SnackBar display and remove the comment (✅ Recommended)

`Make `handleError` show a brief SnackBar using the provided `BuildContext. Keep it non-intrusive: a single line error summary, no stack trace shown to the user.


> **AI Agent Prompt:**

`> ``

`> File: `lib/shared/error_handling/error_handler.dart

`> The `handleError(BuildContext context, dynamic error, ...) method currently

> only logs to Sentry. Implement it to also show a SnackBar to the user.

>

> Replace the method body with:

>   static void handleError(BuildContext context, dynamic error,

>       [StackTrace? stackTrace, String? userMessage]) {

>     log(error, stackTrace);

>     if (context.mounted) {

>       ScaffoldMessenger.of(context).showSnackBar(

>         SnackBar(

>           content: Text(userMessage ?? 'Something went wrong. Please try again.'),

>           duration: const Duration(seconds: 4),

>         ),

>       );

>     }

>   }

>

`> Remove the "in a real app" comment. Do not change the `log method or any

> other part of the file.

`> ``


#### `Option B — Delete `handleError` and always use `state = AsyncValue.error(...)` in providers`

`Consistent with the Riverpod approach already used in `SubscriptionController. But leaves no centralised user-facing error display mechanism.


#### Option C — Leave as-is

`The method's callers (`DashboardScreen etc.) handle errors inline anyway, so the practical impact is low. Acceptable short-term but leaves misleading infrastructure.



---


### `MED-3 · Notification scheduling as a side-effect in provider `build()``


**File:** lib/features/subscriptions/presentation/providers/subscription_controller.dart:43–53
`Every rebuild of `SubscriptionController` cancels and reschedules all notifications. This is an anti-pattern in Riverpod and causes excessive `cancelAll() / schedule calls.


#### `Option A — Move scheduling to a `_scheduleAlertsOnce` call triggered only after mutations (✅ Recommended)`

`Extract the scheduling side-effect out of `build()` and call it explicitly inside `addSubscription`, `updateSubscription`, `deleteSubscription`, and `importSubscriptions` after `ref.invalidateSelf()`. Use `ref.listenSelf` or a post-build callback rather than inline in `build.


> **AI Agent Prompt:**

`> ``

`> File: `lib/features/subscriptions/presentation/providers/subscription_controller.dart

>

`> Background: `_scheduleAlerts` is called inside `build(), which means

> notifications are rescheduled on every provider rebuild — even rebuilds

> triggered by unrelated settings changes. This causes excessive

> notification cancellation/rescheduling.

>

> Task: Move notification scheduling so it only runs after data mutations.

>

`> 1. Remove the entire try/catch block that calls `_scheduleAlerts from

`>    the `build()` method (lines ~43–53). The `build() method should only

>    load, sort, and return subscriptions.

>

`> 2. Add a private method `Future<void> _refreshNotifications() async that

>    contains the scheduling logic (get the current state's data, get the

`>    notification service and settings, call `_scheduleAlerts). It should

`>    guard against `state.hasValue == false and swallow notification errors

`>    with a `debugPrint.

>

`> 3. Call `_refreshNotifications()` (unawaited with `unawaited(...) or

`>    fire-and-forget) at the end of `addSubscription`, `deleteSubscription,

`>    and `importSubscriptions`, after the `ref.invalidateSelf() call.

>    Wrap in try/catch to prevent notification errors from surfacing to callers.

>

`> 4. Do not change the `_scheduleAlerts` or `_nextInstanceOfDay methods.

`> ``


#### `Option B — Keep in `build()` but debounce using a `Timer``

`Reduces frequency but adds complexity and a `Timer that must be disposed.


#### Option C — Leave as-is

The current implementation is functionally correct — rescheduling is idempotent. The main downside is performance on every rebuild, which is low severity for most users.



---


### MED-4 · Weekend shift direction inconsistency


**File:** lib/core/logic/billing_calculator.dart:80–93
The Settings UI says "Move Sat/Sun payments to Monday" but the billing calculator shifts payments *backward* to Friday.


#### Option A — Align calculator to shift forward to Monday (✅ Recommended)

`Update the `autoShiftWeekendPayments` branch in `BillingCalculator to add days forward to Monday instead of subtracting back to Friday, matching the UI description.


> **AI Agent Prompt:**

`> ``

`> File: `lib/core/logic/billing_calculator.dart

>

> Background: The Settings screen has a toggle labelled "Move Sat/Sun

> payments to Monday". However, the billing calculator's weekend shift

> logic moves Saturday → Friday and Sunday → Friday (backward shift).

> This contradicts the user-facing description.

>

> Task: Fix the weekend shift direction to move Saturday → Monday and

> Sunday → Monday (forward shift), matching the UI label.

>

`> 1. Find the section in `calculateNextBillDate (or equivalent method)

`>    that handles `autoShiftWeekendPayments. It likely contains a condition

`>    checking `candidate.weekday == DateTime.saturday or

`>    `candidate.weekday == DateTime.sunday.

>

> 2. Replace the backward subtraction logic with a forward addition:

>    - If weekday == Saturday: add 2 days (→ Monday)

>    - If weekday == Sunday: add 1 day (→ Monday)

>

> 3. Update any existing unit tests in

`>    `test/core/logic/billing_calculator_test.dart that assert the old

>    Friday-shift behaviour to instead assert the Monday result.

>

> 4. Do not change any other logic in the calculator.

`> ``


#### Option B — Change the Settings label to say "Move Sat/Sun payments to Friday"

Fixes the inconsistency by updating the label instead of the logic. Debatable which behaviour is more useful.


#### Option C — Add a separate setting for shift direction (Forward/Backward)

Over-engineered. Pick one behaviour and be consistent.



---


### `MED-5 · `SubscriptionStats.empty()` uses `DateTime.now()` for `month``


**File:** lib/features/analysis/logic/subscription_stats_logic.dart:23–32
`When the analysis provider reloads, it briefly returns `SubscriptionStats.empty()` whose `month is always the current month, even if the user is viewing a different month. This can cause brief UI flicker.


#### `Option A — Pass the selected month into `SubscriptionStats.empty(DateTime month)` (✅ Recommended)`

`Add a required `DateTime month` parameter to `empty() and update call sites in the analysis provider to pass the currently selected month.


> **AI Agent Prompt:**

`> ``

> Files:

`>   - `lib/features/analysis/logic/subscription_stats_logic.dart

`>   - `lib/features/analysis/presentation/providers/analysis_provider.dart

>

`> Task: Fix `SubscriptionStats.empty() to accept the target month instead

> of defaulting to DateTime.now().

>

`> 1. In `subscription_stats_logic.dart`, change the `empty() factory

>    signature from:

>      factory SubscriptionStats.empty()

>    to:

>      factory SubscriptionStats.empty(DateTime month)

`>    Update the body to use the passed `month parameter instead of

`>    `DateTime.now().

>

`> 2. In `analysis_provider.dart`, find every call to `SubscriptionStats.empty()

>    and update it to pass the currently-selected month. The provider likely

>    has access to the selected month via a state variable or parameter.

>

`> 3. Fix any other call sites that call `SubscriptionStats.empty() without

>    arguments.

>

> 4. Do not change other fields or methods in SubscriptionStats.

`> ``


#### `Option B — Return `null` from the provider during loading instead of an empty object`

Requires updating all consumers to handle nullable stats. More churn.


#### Option C — Leave as-is

The flicker is brief and only visible during data loads. Low user impact.



---


### `MED-6 · `while (true)` loop in stats logic with weak termination guard`


**File:** lib/features/analysis/logic/subscription_stats_logic.dart:144
`The loop guard `candidate.year > targetMonth.year + 1 could allow many iterations for yearly subscriptions with distant future start dates.


#### Option A — Add a tight cycle-count guard (✅ Recommended)

`Cap `cycleIndex` iterations at a reasonable bound (e.g., 500). If the bound is exceeded, return `null` or throw an `AssertionError in debug mode only.


> **AI Agent Prompt:**

`> ``

`> File: `lib/features/analysis/logic/subscription_stats_logic.dart

>

`> Task: Add a safety cap to the `while (true) loop around line 144 to

> prevent runaway iteration.

>

`> 1. Find the `while (true) loop.

`> 2. Add an iteration counter before the loop: `int _guard = 0;

> 3. At the top of the loop body, add:

>      if (++_guard > 500) {

>        assert(false, 'SubscriptionStatsLogic: loop exceeded 500 iterations');

>        break;

>      }

> 4. Do not change any other logic.

`> ``


#### Option B — Rewrite the loop using a closed-form date calculation

Eliminates the loop entirely for billing cycle date math. Correct but significant refactor.


#### Option C — Leave as-is

The year+1 guard works for all realistic subscription start dates. The risk is theoretical.



---


## LOW SEVERITY / POLISH



---


### LOW-1 · Google Fonts fetched over network on first launch


**File:** lib/app/theme/app_theme.dart
GoogleFonts.outfit()` and `GoogleFonts.inter() make network requests on first launch when fonts are not cached. On a slow connection or offline, the app will use a fallback font with visible flicker.

#### `Option A — Bundle fonts as assets using `google_fonts` asset bundling (✅ Recommended)`

`Download the Outfit and Inter font files, add them to `assets/fonts/`, and reference them via `pubspec.yaml`. Use `GoogleFonts.outfitTextTheme()` with `assetLoader` or switch to direct `TextStyle(fontFamily: 'Outfit') with asset fonts.


> **AI Agent Prompt:**

`> ``

> You are working on a Flutter app that uses google_fonts package.

`> File: `lib/app/theme/app_theme.dart

>

> Task: Configure the app to load Google Fonts (Outfit and Inter) from

> bundled assets rather than the network.

>

`> 1. In `pubspec.yaml`, under the `flutter: section, add font declarations

>    for Outfit (Regular 400, Medium 500, SemiBold 600, Bold 700) and

`>    Inter (Regular 400, Medium 500) pointing to files in `assets/fonts/.

>    Leave placeholder paths — note in a comment that the actual .ttf files

`>    must be downloaded from fonts.google.com and placed in `assets/fonts/.

>

`> 2. In `lib/app/theme/app_theme.dart`, replace `GoogleFonts.outfit(...)

`>    calls with `TextStyle(fontFamily: 'Outfit', ...) using the same

>    fontWeight/fontSize/color values that were previously passed to

`>    GoogleFonts. Do the same for `GoogleFonts.inter(...) →

`>    `TextStyle(fontFamily: 'Inter', ...).

>

`> 3. Remove the `google_fonts` import from `app_theme.dart if it is no

>    longer used elsewhere in that file.

>

`> 4. Add `assets/fonts/` to the `assets: list in pubspec.yaml.

>

> 5. Leave a TODO comment listing the exact font files that need to be

>    downloaded before the build will work.

`> ``


#### `Option B — Call `GoogleFonts.config.allowRuntimeFetching = false` to force asset-only mode`

Simpler one-liner but will silently fall back to the default font if the bundled assets are not present — misleading.


#### Option C — Leave as-is

Network font loading is the default and works fine on most devices after the first launch. Acceptable risk.



---


### `LOW-2 · Identical ternary branches in `pulse_chart.dart``


**File:** lib/features/analysis/presentation/widgets/pulse_chart.dart:41–44
`Both the dark and light mode branches of the weekend range annotation colour resolve to `Colors.grey.withValues(alpha: 0.1).


#### Option A — Differentiate the dark-mode colour (✅ Recommended)

`Use a slightly higher alpha for dark mode, e.g. `alpha: 0.15, so the weekend annotation is visible against the dark background.


> **AI Agent Prompt:**

`> ``

`> File: `lib/features/analysis/presentation/widgets/pulse_chart.dart

>

> Around line 41, there is a ternary:

>   color: Theme.of(context).brightness == Brightness.dark

>       ? Colors.grey.withValues(alpha: 0.1)

>       : Colors.grey.withValues(alpha: 0.1),

>

> Both branches are identical. Fix the dark-mode branch to use alpha: 0.15

> so weekend range annotations are more visible in dark mode:

>   color: Theme.of(context).brightness == Brightness.dark

>       ? Colors.grey.withValues(alpha: 0.15)

>       : Colors.grey.withValues(alpha: 0.1),

>

> Do not change anything else.

`> ``


#### Option B — Remove the ternary and use a single value

`Simplest. Use `alpha: 0.12 as a compromise that works in both modes.


#### Option C — Leave as-is

Functionally harmless — the annotation is visible in both modes at 0.1 alpha.



---


### LOW-3 · No app version displayed in Settings


The app has no "About" section. Users and support staff cannot see which version is installed.


#### `Option A — Add a static version `ListTile` using the version from `pubspec.yaml` via `package_info_plus` (✅ Recommended)`

`Use `PackageInfo.fromPlatform() to read the version at runtime and display it in the About section added by HIGH-6.


> **AI Agent Prompt:**

`> ``

`> File: `lib/features/settings/presentation/screens/settings_screen.dart

>

> Task: Display the app version number in the About section of Settings.

`> Assume `package_info_plus is in pubspec.yaml (add it if not).

>

`> 1. Add `import 'package:package_info_plus/package_info_plus.dart';

>

> 2. The Settings screen is a ConsumerWidget. Convert it to a

>    ConsumerStatefulWidget so it can hold async state, OR use a FutureBuilder.

>    FutureBuilder is simpler — use that approach.

>

> 3. In the About section ListTile for 'Version' (added by the privacy policy

>    task), wrap the subtitle in a FutureBuilder<PackageInfo>:

>      subtitle: FutureBuilder<PackageInfo>(

>        future: PackageInfo.fromPlatform(),

>        builder: (context, snap) => Text(

>          snap.hasData

>              ? '${snap.data!.version} (${snap.data!.buildNumber})'

>              : '...',

>        ),

>      ),

>

> 4. Do not change any other settings screen logic.

`> ``


#### `Option B — Hardcode `const Text('1.0.0')``

Works but requires manual update with every release.


#### Option C — Leave as-is

Low user impact. Acceptable to defer post-launch.



---


### LOW-4 · JVM crash dump files committed to repository


**Directory:** android/` — 7 `hs_err_pid*.log` / `replay_pid*.log files committed.

#### `Option A — Delete files and update `.gitignore` (✅ Recommended)`


> **AI Agent Prompt:**

`> ``

> You are working on a Flutter app repository.

>

> Task: Remove JVM crash dump files from the android/ directory and prevent

> them from being committed in future.

>

`> 1. Delete all files matching `android/hs_err_pid*.log and

`>    `android/replay_pid*.log.

>

`> 2. Add the following lines to `android/.gitignore (create it if it does

>    not exist):

>      hs_err_pid*.log

>      replay_pid*.log

>

> 3. Stage the deletions and the .gitignore update.

`> ``


#### Option B — Leave them — they contain no secrets

Technically safe but unprofessional and adds repo bloat.


#### `Option C — Add to root `.gitignore` instead`

`Also acceptable, but `android/.gitignore is the more canonical location for Android-specific ignores.



---


### `LOW-5 · No tests for `DataTransferService` (CSV import/export)`


**File:** lib/features/settings/data/data_transfer_service.dart
`CSV import/export has no test coverage despite containing parsing logic with real crash risk (bare `double.parse`, `DateTime.parse on raw user input).


#### Option A — Add unit tests for the import parser covering happy path and error cases (✅ Recommended)

`Create `test/features/settings/data/data_transfer_service_test.dart with tests for: valid CSV round-trip, malformed price (non-numeric), missing required fields, and empty file.


> **AI Agent Prompt:**

`> ``

> You are working on a Flutter app.

`> File to test: `lib/features/settings/data/data_transfer_service.dart

>

> Task: Create a unit test file at

`> `test/features/settings/data/data_transfer_service_test.dart

> that tests the CSV import parsing logic.

>

`> First, read `lib/features/settings/data/data_transfer_service.dart in

`> full to understand the CSV column format and the `importFromCsv /

`> `exportToCsv methods.

>

> Write tests for:

> 1. Happy path: a valid CSV string with 2 subscriptions round-trips

>    correctly through export then import, preserving name, cost, cycle,

>    firstBillDate, category, and status.

> 2. Malformed price: a row with a non-numeric cost value is skipped without

>    throwing, and the remaining rows are still imported.

> 3. Missing required column: a CSV row with fewer columns than expected is

>    skipped without throwing.

> 4. Empty input: importing an empty string or header-only CSV returns an

>    empty list without throwing.

> 5. Import count: the method returns the correct count of successfully

>    imported subscriptions.

>

`> Use `flutter_test only. Do not mock the file system for the parsing

> tests — call the parsing logic directly by passing CSV strings.

`> If the current implementation only accepts a `File, refactor the pure

`> parsing logic into a package-private `parseSubscriptionsFromCsvString

> method so it can be unit tested without file I/O, and call it from the

> existing file-based method.

`> ``


#### Option B — Add integration tests using a real temp file

More realistic but slower and harder to set up on CI.


#### Option C — Leave as-is

The error handling exists (try/catch per row). Low immediate risk but high regret potential when a user reports data loss.



---


## Summary Checklist



| ID | Description | Severity | Status |
| --- | --- | --- | --- |
| BLOCKER-1 | Configure production release signing | Blocker | ☐ |
| BLOCKER-2 | Gate dev tools behind kDebugMode`` | Blocker | ☐ |
| BLOCKER-3 | Lower Sentry tracesSampleRate` to 0.1` | Blocker | ☐ |
| BLOCKER-4 | Extract Sentry DSN to --dart-define`` | Blocker | ☐ |
| BLOCKER-5 | Set debugLogDiagnostics: kDebugMode`` | Blocker | ☐ |
| BLOCKER-6 | Declare USE_EXACT_ALARM` in Play Console` | Blocker | ☐ |
| HIGH-1 | Wire currency setting to all display widgets | High | ☐ |
| HIGH-2 | Fix broken alert_scheduler_test.dart`` | High | ☐ |
| HIGH-3 | Replace hashCode`-based notification IDs` | High | ☐ |
| HIGH-4 | Delete dead duplicate settings screen file | High | ☐ |
| HIGH-5 | Add cancellationUrl` field to SubscriptionForm` | High | ☐ |
| HIGH-6 | Add Privacy Policy link + host policy page | High | ☐ |
| MED-1 | Replace bare print()` with `debugPrint` guard` | Medium | ☐ |
| MED-2 | Implement ErrorHandler.handleError` SnackBar` | Medium | ☐ |
| MED-3 | Move notification scheduling out of build()`` | Medium | ☐ |
| MED-4 | Fix weekend shift direction (Fri→Mon) | Medium | ☐ |
| MED-5 | Pass selected month to SubscriptionStats.empty()`` | Medium | ☐ |
| MED-6 | Add iteration cap to stats logic while loop | Medium | ☐ |
| LOW-1 | Bundle Google Fonts as assets | Low | ☐ |
| LOW-2 | Fix identical ternary in pulse_chart.dart`` | Low | ☐ |
| LOW-3 | Display app version in Settings | Low | ☐ |
| LOW-4 | Delete JVM crash logs + update .gitignore`` | Low | ☐ |
| LOW-5 | Add tests for DataTransferService` | Low | ☐ |