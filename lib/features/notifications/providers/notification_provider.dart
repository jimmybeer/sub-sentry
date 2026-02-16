import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/notification_service.dart';

part 'notification_provider.g.dart';

@Riverpod(keepAlive: true)
Future<NotificationService> notificationService(
    NotificationServiceRef ref) async {
  final service = NotificationService();
  await service.init();
  return service;
}
