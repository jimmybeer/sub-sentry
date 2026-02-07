# 09. Development Checklist (Implementation Plan)

## Phase 1: Foundation (Current)
- [x] **1.1 Project Setup**: Initialize Flutter, Folder Structure, Themes.
- [x] **1.2 Dependencies**: Validated `pubspec.yaml` and ran `pub get`.
- [x] **1.3 Routing**: Setup `GoRouter` and Screen Placeholders.

## Phase 2: Domain & Data (The "Engine")
- [x] **2.1 Domain Entities**: Create `Subscription` class.
- [x] **2.2 Logic Engines**: Implement `BillingCalculator` (Pure Dart logic for "Next Bill Date").
- [x] **2.3 Unit Tests**: Verify `BillingCalculator` handles leap years and edge cases correctly.
- [x] **2.4 Hive Setup**: Create `SubscriptionModel` (HiveObject), TypeAdapters, and `SubscriptionRepository`.

## Phase 3: Core Features (The "Vault")
- [ ] **3.1 Global State**: Create `SubscriptionController` (Riverpod AsyncNotifier) for CRUD operations.
- [ ] **3.2 Add Subscription UI**: Build the form with inputs: Name, Cost, Cycle, Date.
- [ ] **3.3 Edit Subscription UI**: Pre-fill form, add Delete button.
- [ ] **3.4 List View**: Implement the "Vault" card list on Dashboard.

## Phase 4: Insights & Polish (The "Premium" Feel)
- [ ] **4.1 Stats Logic**: Calculate "Total Monthly", "Projected Daily Spend".
- [ ] **4.2 Pulse Chart**: Implement `fl_chart` Bar/Line combo.
- [ ] **4.3 Settings**: Currency toggle, Theme toggle, Data Wipe.
- [ ] **4.4 Onboarding**: Implement First-Run Wizard.

## Phase 5: Production Readiness
- [ ] **5.1 App Icon**: Generate launcher icons.
- [ ] **5.2 Splash Screen**: Configure native splash.
- [ ] **5.3 Release Build**: Verify `--release` build works on Android/iOS.
