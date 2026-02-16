import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sub_sentry/features/settings/presentation/providers/settings_controller.dart';
import 'package:sub_sentry/features/notifications/services/notification_service.dart';
import 'package:sub_sentry/features/notifications/providers/notification_provider.dart';
import 'package:sub_sentry/features/subscriptions/domain/repository/subscription_repository.dart';
import 'package:sub_sentry/features/subscriptions/domain/subscription.dart';
import 'package:sub_sentry/features/subscriptions/presentation/providers/subscription_controller.dart';

class MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

class MockNotificationService extends Mock implements NotificationService {}

class FakeSettingsController extends AsyncNotifier<SettingsState>
    implements SettingsController {
  @override
  Future<SettingsState> build() async {
    return const SettingsState(
      weeklySummaryEnabled: true,
      weeklySummaryDay: DateTime.monday,
      weeklySummaryTime: '09:00',
      trialAlertsEnabled: true,
    );
  }

  @override
  Future<void> toggleTheme(bool isDark) async {}

  @override
  Future<void> setCurrency(String code) async {}

  @override
  Future<void> setPayDays(List<int> days) async {}

  @override
  Future<void> toggleAutoShiftWeekendPayments(bool value) async {}

  @override
  Future<void> completeOnboarding() async {}

  @override
  Future<void> wipeData() async {}

  @override
  Future<void> toggleWeeklySummary(bool value) async {}

  @override
  Future<void> setWeeklySummaryTime(int day, String time) async {}

  @override
  Future<void> toggleTrialAlerts(bool value) async {}
}

void main() {
  setUpAll(() {
    registerFallbackValue(Subscription(
      id: 'dummy',
      name: 'dummy',
      cost: 0,
      cycle: BillingCycle.monthly,
      firstBillDate: DateTime.now(),
      category: SubCategory.other,
      colorHex: '#000',
      status: SubStatus.active,
    ));
  });

  late MockSubscriptionRepository mockRepo;
  late MockNotificationService mockNotify;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockSubscriptionRepository();
    mockNotify = MockNotificationService();

    // Stub repo calls
    when(() => mockRepo.getAllSubscriptions()).thenAnswer((_) async => []);
    when(() => mockRepo.saveSubscription(any())).thenAnswer((_) async {});
    when(() => mockRepo.deleteSubscription(any())).thenAnswer((_) async {});

    // Stub notification calls
    when(() => mockNotify.cancelAll()).thenAnswer((_) async {});
    when(() => mockNotify.scheduleWeeklySummary(
          title: any(named: 'title'),
          body: any(named: 'body'),
          day: any(named: 'day'),
          hour: any(named: 'hour'),
          minute: any(named: 'minute'),
        )).thenAnswer((_) async {});
    when(() => mockNotify.scheduleTrialAlert(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
        )).thenAnswer((_) async {});

    container = ProviderContainer(overrides: [
      subscriptionRepositoryProvider.overrideWithValue(mockRepo),
      notificationServiceProvider.overrideWithValue(mockNotify),
      settingsControllerProvider.overrideWith(() => FakeSettingsController()),
    ]);
  });

  test('addSubscription triggers alert scheduling', () async {
    // Calculate next Monday to ensure it falls in the summary window
    DateTime now = DateTime.now();
    DateTime nextMonday = DateTime(now.year, now.month, now.day, 9, 0);
    while (nextMonday.weekday != DateTime.monday || nextMonday.isBefore(now)) {
      nextMonday = nextMonday.add(const Duration(days: 1));
    }

    final sub = Subscription(
      id: '1',
      name: 'Test',
      cost: 10,
      cycle: BillingCycle.monthly,
      firstBillDate: nextMonday, // Ensure it's due in the summary week
      category: SubCategory.other,
      colorHex: '#000',
      status: SubStatus.active,
      includeInWeeklySummary: true,
      isTrial: false,
    );

    // Initial load
    await container.read(subscriptionControllerProvider.future);

    // Stub repo to return the added sub on refresh
    when(() => mockRepo.getAllSubscriptions()).thenAnswer((_) async => [sub]);

    // Add sub
    await container
        .read(subscriptionControllerProvider.notifier)
        .addSubscription(sub);

    // Wait for the async build (invalidateSelf triggers rebuild)
    await container.read(subscriptionControllerProvider.future);

    // Verify notifications were rescheduled
    // We expect cancelAll...
    verify(() => mockNotify.cancelAll()).called(greaterThanOrEqualTo(1));

    // We expect Weekly Summary as a Trial Alert (One-off) with ID 888888
    verify(() => mockNotify.scheduleTrialAlert(
          id: 888888, // Weekly Summary ID
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
        )).called(greaterThanOrEqualTo(1));
  });
}
