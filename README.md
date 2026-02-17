# SubSentry

**Financial Clarity for Subscriptions.**

SubSentry is a premium Flutter application designed to help you track, manage, and optimize your recurring subscription expenses. With a focus on privacy and local-first data, SubSentry provides clear insights into your spending habits without connecting to your bank accounts.

## 🚀 Key Features

*   **📊 Insightful Dashboard:** Visualize your monthly spending "Pulse" and see exactly where your money goes with category breakdowns.
*   **🔔 Smart Notifications:** Never miss a renewal again. Get timely alerts for:
    *   Trial expirations (5 days, 3 days, 1 day before, and day-of).
    *   Annual & Quarterly renewals (1 week and 1 day before).
*   **📅 Flexible Billing:** Supports Weekly, Monthly, Quarterly, and Yearly billing cycles.
*   **🎨 Beautiful Design:** A polished, dark-mode-ready UI with smooth animations and intuitive interactions.
*   **🔒 Privacy First:** All data is stored locally on your device using Hive. No external servers or bank connections required.
*   **⚙️ Customizable:**
    *   Support for multiple currencies (GBP, USD, EUR).
    *   Light & Dark themes.
    *   Configurable Pay Days for cash flow planning.

## 🛠️ Tech Stack

Built with ❤️ using **Flutter**.

*   **State Management:** [Riverpod](https://riverpod.dev/)
*   **Navigation:** [GoRouter](https://pub.dev/packages/go_router)
*   **Local Database:** [Hive](https://docs.hivedb.dev/)
*   **Charting:** [fl_chart](https://pub.dev/packages/fl_chart)
*   **Notifications:** [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
*   **Date Handling:** [intl](https://pub.dev/packages/intl) & [timezone](https://pub.dev/packages/timezone)

## 🏁 Getting Started

### Prerequisites

*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.2.0 or higher)
*   Android Studio / VS Code with Flutter extensions.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/jimmybeer/sub-sentry.git
    cd sub-sentry
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the app:**
    ```bash
    flutter run
    ```

## 🧪 Testing

SubSentry includes a suite of unit and widget tests to ensure reliability.

To run tests:
```bash
flutter test
```

## 📂 Project Structure

The project follows a feature-first architecture for scalability and maintainability:

```
lib/
├── app/                 # App-wide configuration (Theme, Router)
├── core/                # Core logic, constants, and utilities
├── features/            # Feature modules
│   ├── analysis/        # Charts and spending breakdown
│   ├── dashboard/       # Main home screen
│   ├── notifications/   # Notification services and logic
│   ├── onboarding/      # First-time user experience
│   ├── settings/        # App configuration (Currency, Theme, Data)
│   └── subscriptions/   # Subscription CRUD and domain logic
└── shared/              # Shared widgets and error handling
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1.  Fork the project
2.  Create your feature branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## 👤 Author

**Jimmy Beer**
- GitHub: [@jimmybeer](https://github.com/jimmybeer)

---

*Verified locally on Android (Pixel 9 Pro).*
