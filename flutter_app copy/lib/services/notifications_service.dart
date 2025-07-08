import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  /// 🔁 FCM token'ı backend'e gönderir (sadece Android/iOS'ta çalışır)
  static Future<void> sendPlatformToBackend(String email) async {
  final url = Uri.parse('http://75.101.195.165:8000/save-platform');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: '{"email": "$email", "platform": "macos"}',
    );

    if (response.statusCode == 200) {
      print("✅ Platform bilgisi backend'e gönderildi.");
    } else {
      print("⛔ Platform bilgisi gönderilemedi: ${response.body}");
    }
  } catch (e) {
    print("🔥 Platform gönderme hatası: $e");
  }
}


  /// 🚀 Bildirim altyapısını başlatır (platforma göre)
  static Future<void> init() async {
    if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      print("🔕 Bildirim sistemi ${Platform.operatingSystem} platformunda desteklenmiyor");
      return;
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    const macOS = DarwinInitializationSettings(); // macOS da Darwin kullanır

    const initSettings = InitializationSettings(
      android: android,
      iOS: iOS,
      macOS: macOS,
    );

    await _notifications.initialize(initSettings);

    // 🔔 Firebase mesajlarını sadece mobilde dinle
    if (Platform.isAndroid || Platform.isIOS||Platform.isMacOS) {
      try {
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
      } catch (e) {
        print("⚠️ Firebase dinleme başlatılamadı: $e");
      }
    } else if (Platform.isMacOS) {
      print("🍎 macOS'ta sadece local notification destekleniyor");
    }
  }

  /// 🧪 Test amaçlı manuel local notification (her platformda)
  static Future<void> show({
    required String title,
    required String body,
  }) async {
    if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      print("🔕 Test bildirimi ${Platform.operatingSystem} için desteklenmiyor");
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'zoom_ai_channel',
      'Zoom Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const macDetails = DarwinNotificationDetails(); // Aynı sınıf

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: macDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }
}
