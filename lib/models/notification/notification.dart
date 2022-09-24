import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CustomNotification {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future showNotification(
      {int id = 0, String? title, String? body, String? payload}) async {
    return _notifications.show(id, title, body, await _notificationDetail(),
        payload: payload);
  }

  static Future _notificationDetail() async {
    return NotificationDetails(
        android: AndroidNotificationDetails("channelId", "channelName",
            importance: Importance.max),
        iOS: DarwinNotificationDetails());
  }
}
