import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  /// 🔁 FCM token'ı backend'e gönderir
  static Future<void> sendTokenToBackend(String email) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) {
      print("⛔ FCM token alınamadı.");
      return;
    }

    final url = Uri.parse('http://75.101.195.165:8000/save-token');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: '{"email": "$email", "token": "$fcmToken"}',
    );

    if (response.statusCode == 200) {
      print("✅ FCM token backend'e gönderildi.");
    } else {
      print("⛔ Backend token kaydı başarısız: ${response.body}");
    }
  }

  /// 🚀 Bildirim altyapısını başlatır ve gelen mesajları yakalar
  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: android, iOS: iOS);

    await _notifications.initialize(initSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;

      _notifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'zoom_ai_channel',
            'Zoom Notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    });
  }

  /// 🧪 Test amaçlı manuel bildirim gösterir
  static Future<void> show({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'zoom_ai_channel',
      'Zoom Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }
}
