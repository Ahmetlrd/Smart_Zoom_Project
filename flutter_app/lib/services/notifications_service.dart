import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/navigator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// 🔑 Alınan cihaz FCM token'ını döndürür
  static Future<String?> getFcmToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    print("📡 FCM token alındı: $token"); // ← EKLENDİ
    return token;
  }

  /// 🛰️ Cihaz FCM token'ını backend'e kaydeder
  static Future<void> sendTokenToBackend(String email) async {
    final token = await getFcmToken();
    if (token != null) {
      final response = await http.post(
        Uri.parse('http://75.101.195.165:8000/save-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'token': token}),
      );
      print("✅ Token sent to backend: $token");
      print("🔁 Backend response: ${response.body}"); // ← EKLENDİ
    } else {
      print("⛔ Token alınamadı, backend'e gönderilmedi.");
    }
  }

  /// 🔔 Bildirim sistemini başlatır
  static Future<void> init(GlobalKey<NavigatorState> navKey) async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final data = message.data;

      if (notification != null) {
        _plugin.show(
          0,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'zoomai_channel',
              'ZoomAI Notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          payload: data['action'],
        );
      }
    });

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(settings);
    await _requestPermissions();
  }

  /// 📱 Kullanıcıdan bildirim izni ister
  static Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
    } else if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  /// 📤 Uygulama içinden manuel bildirim göstermek için
  static Future<void> show({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'zoomai_channel',
      'ZoomAI Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(0, title, body, details);
  }
}
