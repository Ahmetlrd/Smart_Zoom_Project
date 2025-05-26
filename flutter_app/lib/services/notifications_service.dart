import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// 🔑 Alınan cihaz FCM token'ını döndürür
  static Future<String?> getFcmToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    print("📡 FCM token alındı: $token");
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
      print("🔁 Backend response: ${response.body}");
    } else {
      print("⛔ Token alınamadı, backend'e gönderilmedi.");
    }
  }

  /// 🔔 Bildirim sistemini başlatır ve gelen mesajları dinler
  static Future<void> init(GlobalKey<NavigatorState> navKey) async {
    // FCM mesajları geldiğinde heads-up olarak göster
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final data = message.data;

      if (notification != null) {
        _plugin.show(
          0,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'zoomai_channel',
              'ZoomAI Notifications',
              channelDescription: 'Zoom AI bildirimleri',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
              enableLights: true,
              visibility: NotificationVisibility.public,
              ticker: 'ticker',
            ),
            iOS: DarwinNotificationDetails(),
          ),
          payload: data['action'],
        );
      }
    });

    // Bildirim kanalı başlat
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
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    } else if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  /// 📤 Manuel olarak heads-up bildirim göstermek için
  static Future<void> show({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'zoomai_channel',
      'ZoomAI Notifications',
      channelDescription: 'Zoom AI bildirimleri',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      visibility: NotificationVisibility.public,
      ticker: 'ticker',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(0, title, body, details);
  }
}
