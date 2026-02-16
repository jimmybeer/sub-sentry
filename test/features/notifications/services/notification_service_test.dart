import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sub_sentry/features/notifications/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

void main() {
  late NotificationService service;
  late MockFlutterLocalNotificationsPlugin mockPlugin;

  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
    registerFallbackValue(tz.TZDateTime.now(tz.local));
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(AndroidScheduleMode.exact);
    registerFallbackValue(DateTimeComponents.time);
  });

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    service = NotificationService(plugin: mockPlugin);

    // Default mock response for zonedSchedule (returns Future<void>)
    when(() => mockPlugin.zonedSchedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          payload: any(named: 'payload'),
        )).thenAnswer((_) async {});

    when(() => mockPlugin.cancel(id: any(named: 'id')))
        .thenAnswer((_) async {});
  });

  group('NotificationService', () {
    // TC4: Recurring Schedule
    test('scheduleWeeklySummary schedules recurring notification', () async {
      await service.scheduleWeeklySummary(
        title: 'Summary',
        body: 'Body',
        day: DateTime.monday,
        hour: 9,
        minute: 0,
      );

      verify(() => mockPlugin.zonedSchedule(
            id: NotificationService.weeklySummaryId, // ID
            title: 'Summary',
            body: 'Body',
            scheduledDate:
                any(named: 'scheduledDate', that: isA<tz.TZDateTime>()),
            notificationDetails: any(
                named: 'notificationDetails', that: isA<NotificationDetails>()),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            payload: any(named: 'payload'),
          )).called(1);
    });

    // Validating Trial Alerts scheduling
    test('scheduleTrialAlert schedules a one-off notification', () async {
      final date = DateTime.now().add(const Duration(days: 1));
      await service.scheduleTrialAlert(
        id: 100,
        title: 'Trial',
        body: 'Ending soon',
        scheduledDate: date,
      );

      verify(() => mockPlugin.zonedSchedule(
            id: 100,
            title: 'Trial',
            body: 'Ending soon',
            scheduledDate:
                any(named: 'scheduledDate', that: isA<tz.TZDateTime>()),
            notificationDetails: any(
                named: 'notificationDetails', that: isA<NotificationDetails>()),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            payload: any(named: 'payload'),
          )).called(1);
    });

    test('cancelNotification calls plugin.cancel', () async {
      await service.cancelNotification(123);
      verify(() => mockPlugin.cancel(id: 123)).called(1);
    });
  });
}
