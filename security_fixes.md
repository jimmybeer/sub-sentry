# SubSentry — Security Fixes


AI developer prompts to address each issue from the security audit, in priority order.


Work through these sequentially — each fix is self-contained.




---


## Fix 1 — Hive Storage Encryption


**Audit finding:** The Hive `subscriptions` box is opened with no encryption cipher. Financial
data (subscription names, costs, payment sources, notes, cancellation URLs) is stored in


plaintext on disk. On rooted/jailbroken devices or desktop targets this data can be read


directly from the filesystem.



**Prompt:**

Add at-rest encryption to the Hive `subscriptions` box in this Flutter app.






Requirements:


 - Add `flutter_secure_storage` to `pubspec.yaml` dependencies.


 - In `lib/main.dart`, before opening the Hive box, read a key named `'hive_key'` from


`FlutterSecureStorage`. If the key does not exist, generate 32 cryptographically random


 bytes using `dart:math`'s `Random.secure()`, base64-encode them, and store them under


`'hive_key'`.


 - Decode the stored base64 key back to a `Uint8List` and pass it to `HiveAesCipher`.


 - Open the `subscriptions` box with `encryptionCipher: HiveAesCipher(keyBytes)`.


 - Apply the same cipher in the error-recovery path where the box is reopened after a


 corrupted-box deletion.


 - Do not change any other logic. Do not remove the existing `try/catch` recovery block.


 - Ensure the fix compiles — import `dart:math`, `dart:convert`, `dart:typed_data`, and


`flutter_secure_storage` as needed.




---


## Fix 2 — URL Scheme Validation


**Audit finding:** The cancellation URL validator in lib/features/subscriptions/presentation/
`widgets/subscription_form.dart` uses `Uri.tryParse()?.hasAbsolutePath` to check validity.


`hasAbsolutePath` only verifies the path component starts with `/` — it does not validate the
scheme. Values like `javascript:alert(1)` or `file:///etc/passwd` pass validation and are


stored in Hive.



**Prompt:**

> Fix the cancellation URL validator in


> `lib/features/subscriptions/presentation/widgets/subscription_form.dart`.


>


> Requirements:


> - Replace the existing validator logic for the `cancellation_url_input` field.


> - The field is optional — an empty or whitespace-only value must still return `null`


>   (valid).


> - For non-empty values: parse with `Uri.tryParse`. Reject if the result is null.


> - Reject any scheme that is not `http` or `https`. Return the error string


>   `'Must be a valid http:// or https:// URL'`.


> - No other changes to the form. Do not alter any other validators or fields.




---


## Fix 3 — Error Message Sanitisation


**Audit finding:** Raw Dart exception objects (`$e`) are interpolated directly into
user-visible `Text` widgets in four locations. This can expose internal file paths,


class names, and stack details to end users.



Affected locations:


`lib/main.dart` — fatal crash screen shows both `$e` and `$e2`
`lib/main.dart` — initialisation error screen shows `$e`
`lib/features/settings/presentation/screens/settings_screen.dart:24` — `'Error: $e'`
`lib/features/subscriptions/presentation/edit_subscription_screen.dart:74` — `'Error: $e'`

**Prompt:**

> Sanitise user-facing error messages in the four locations listed below. In each case,


> replace the raw exception interpolation with a generic, user-friendly string. Log the


> original exception to `ErrorHandler.log` (already imported where available) before


> showing the generic message so nothing is silently swallowed.


>


> **Location 1 — `lib/main.dart` fatal crash screen (the innermost `catch` block):**


> Replace the `Text` widget that displays `'Fatal Error: ... \n$e\n\nRecovery Error:\n$e2'`


> with `Text('Something went wrong and the app could not start. Please reinstall the app.')`.


> Keep both `ErrorHandler.log(e2, stack2)` calls that already exist above it.


>


> **Location 2 — `lib/main.dart` initialisation error in `SubSentryApp.build`:**


> Replace `Text('Initialization Error: $e')` with


> `Text('The app failed to load. Please restart.')`.


> The `ErrorHandler.log(e, st)` call above it already logs the detail — do not add another.


>


> **Location 3 — `lib/features/settings/presentation/screens/settings_screen.dart`:**


> In the `asyncSettings.when(error: ...)` callback, replace `Text('Error: $e')` with


> `Text('Settings could not be loaded.')`. Add `ErrorHandler.log(e, st)` before the


> returned widget. Import `ErrorHandler` if not already imported.


>


> **Location 4 — `lib/features/subscriptions/presentation/edit_subscription_screen.dart`:**


> In the `asyncSubs.when(error: ...)` callback, replace `Text('Error: $e')` with


> `Text('Could not load subscription.')`. Add `ErrorHandler.log(e, st)` before the


> returned widget. Import `ErrorHandler` if not already imported.


>


> Make no other changes to logic, layout, or imports beyond what is described above.




---


## Fix 4 — CSV Import File Size Limit


**Audit finding:** `lib/features/settings/presentation/providers/data_transfer_controller.dart`
reads the entire user-selected file into memory with no size check. A very large file could


cause an out-of-memory crash. Additionally, CSV rows trust the `id` column from the imported


file directly, which could allow an imported file to silently overwrite existing subscriptions


by ID collision.



**Prompt:**

> Apply two hardening changes to


> `lib/features/settings/presentation/providers/data_transfer_controller.dart`.


>


> **Change 1 — File size guard:**


> After confirming `result.files.single.path != null` but before calling


> `file.readAsString()`, call `await file.length()` and throw an `Exception` with the


> message `'Import file is too large (max 5 MB)'` if the size exceeds 5 × 1024 × 1024 bytes.


>


> **Change 2 — ID sanitisation on import:**


> After `_service.importFromCsv(content)` returns the list of subscriptions, remap each


> subscription to use a freshly generated `Uuid().v4()` as its `id` instead of the id


> from the file. Use `sub.copyWith(id: const Uuid().v4())` for each item.


> Import `package:uuid/uuid.dart` (already a project dependency).


>


> Do not change the export logic, the `DataTransferService`, or anything else.




---


## Fix 5 — Input Length Limits on Free-Text Fields


**Audit finding:** The `name`, `paymentSource`, and `notes` fields in
`lib/features/subscriptions/presentation/widgets/subscription_form.dart` accept unlimited
input length. There are no `maxLength` constraints or validator length checks. Extremely long


values can cause UI layout issues and inflate stored data size.



**Prompt:**

> Add length constraints to the three free-text fields in


> `lib/features/subscriptions/presentation/widgets/subscription_form.dart`.


>


> - **Name field** (`name_input`): add `maxLength: 100` to the `TextFormField`. Update its


>   validator to also return `'Name is too long (max 100 characters)'` if


>   `v.trim().length > 100` (the `maxLength` enforces this in the UI, but the validator


>   guards programmatic/imported values).


> - **Payment Source field** (`payment_source_input`): add `maxLength: 100`. No validator


>   change needed (field is optional).


> - **Notes field** (`notes_input`): add `maxLength: 500`. No validator change needed


>   (field is optional).


>


> Use Flutter's built-in `maxLength` property on `TextFormField` (this displays a character


> counter). Do not add any other changes to the form.