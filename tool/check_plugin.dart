import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.cancel(id: 1);
}
