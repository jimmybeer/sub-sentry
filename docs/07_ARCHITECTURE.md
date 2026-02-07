# 07. Technical Architecture

> **Guiding Principle**: "Keep it boring." Use proven, stable packages. No experimental rewrites for v1.0.

## 1. High-Level Architecture
We follow a **Feature-First Clean Architecture**. Each major feature (e.g., `subscription`, `settings`) serves as a self-contained module with its own Data, Domain, and Presentation layers.

### 1.1 Layer Responsibilities
*   **Presentation (UI)**: Widgets, Riverpod Controllers (`@riverpod`). **No business logic.**
*   **Domain (Business Rules)**: Pure Dart classes. `Subscription` entity, `BillingCalculator` logic. **No Flutter dependencies.**
*   **Data (Infrastructure)**: Hive Repositories, DTOs (Data Transfer Objects). **Handles storage details.**

## 2. Project Structure
```text
lib/
├── app/                        # App-wide configuration
│   ├── app.dart                # Root widget (MaterialApp)
│   ├── theme/                  # AppTheme, text_styles, colors
│   └── router/                 # GoRouter configuration
├── core/                       # Shared utilities
│   ├── constants/              # Asset paths, default values
│   ├── utils/                  # CurrencyFormatter, DateFormatter
│   └── logic/                  # BillingCycleCalculator (Pure Dart)
├── features/
│   ├── dashboard/              # Dashboard Feature
│   │   ├── presentation/       # DashboardScreen, PulseChartWidget
│   │   └── providers/          # dashboard_controller.dart
│   ├── subscriptions/          # The Core Domain
│   │   ├── data/
│   │   │   ├── model/          # SubscriptionHiveModel (HiveObject)
│   │   │   └── repository/     # SubscriptionRepository
│   │   ├── domain/
│   │   │   └── subscription.dart # Pure Entity
│   │   └── presentation/
│   │       ├── add_edit_sheet.dart
│   │       └── widgets/
│   └── settings/
│       └── ...
└── main.dart                   # Entry point, Hive init, ProviderScope
```

## 3. Tech Stack & Dependencies

### 3.1 Core Dependencies (`pubspec.yaml`)
*   **Framework**: Flutter SDK (Stable)
*   **State Management**: `flutter_riverpod: ^2.5.1`, `riverpod_annotation: ^2.3.5`
*   **Navigation**: `go_router: ^13.2.0`
*   **Local DB**: `hive_flutter: ^1.1.0` (Fast NoSQL)
*   **UI Assets**: `fl_chart: ^0.66.0` (Charts), `google_fonts: ^6.1.0` (Typography)
*   **Utilities**: `intl: ^0.19.0` (Date formatting), `uuid: ^4.3.3` (Unique IDs)
*   **Icons**: `flutter_launcher_icons` (Dev dep)

### 3.2 Code Generation (Dev Deps)
*   `build_runner`
*   `riverpod_generator`
*   `hive_generator`

## 4. Data Models (Domain Layer)

### 4.1 Subscription Entity (`domain/subscription.dart`)
```dart
enum BillingCycle { weekly, monthly, quarterly, yearly }
enum SubCategory { entertainment, utilities, software, gym, finance, other }
enum SubStatus { active, paused, canceled }

class Subscription {
  final String id;
  final String name;
  final double cost;
  final BillingCycle cycle;
  final DateTime firstBillDate;
  final DateTime? nextBillOverride; // User manual override
  final SubCategory category;
  final String colorHex; // '#FF0000'
  final SubStatus status;
  final String? paymentSource; // 'Monzo'
  final String? cancellationUrl;
  final bool isTrial;
  final DateTime? trialEndDate;
  final DateTime? contractEndDate;
  final String? notes;

  // Computed Props
  DateTime get nextBillDate => ... // Logic in extension or separate calculator
}
```

## 5. Billing Logic (The "Brain")
The critical logic resides in `core/logic/billing_calculator.dart`. This pure Dart class must cover:
*   **Leap Years**: Feb 29th handling.
*   **Short Months**: Starting a monthly sub on Jan 31st -> Due Feb 28th (or 29th).
*   **Overrides**: If `nextBillOverride` is set, use it. Else calculate from `firstBillDate` + `n * cycle`.

## 6. Local Storage Strategy (Hive)
*   **Box 1**: `subscriptions` (List of all objects).
*   **Box 2**: `settings` (Preferences like Currency, ThemeMode).
*   **Initialization**: `await Hive.initFlutter();` in `main.dart`.
*   **Adapter**: Must generate TypeAdapters for all Enums to store them cleanly.

## 7. Platform Considerations
### 7.1 iOS
*   **UI**: Use `CupertinoModalSheet` (wobbly sheet) for the "Add Subscription" modal.
*   **Permissions**: Request Notification permissions on first launch (or first "Remind Me" toggle).

### 7.2 Android
*   **UI**: Use `showModalBottomSheet` with Material 3 radius.
*   **Back Button**: Ensure physical back button closes sheets/dialogs properly.

## 8. Development Phases (Implementation Order)
1.  **Skeleton**: Project init, assets, theme, router.
2.  **Domain**: Core Logic (Calculator + Tests). **CRITICAL: Test this first.**
3.  **Data**: Hive repositories.
4.  **UI - List**: Display dummy data.
5.  **UI - Add**: Wiring up the form.
6.  **Stats**: Implementing the Charts.
