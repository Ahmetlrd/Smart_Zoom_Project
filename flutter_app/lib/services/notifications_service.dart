import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse details) {
  print("🔕 (BG) Bildirime tıklandı: ${details.payload}");
}

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  /// 📡 Cihaz platform bilgisini backend'e gönderir
  static Future<void> sendPlatformToBackend(String email) async {
    final url = Uri.parse('http://75.101.195.165:8000/save-platform');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: '{"email": "$email", "platform": "${Platform.operatingSystem}"}',
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

  /// 🚀 Bildirim altyapısını başlatır (mobil + macOS destekli)
  static Future<void> init() async {
    if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      print(
          "🔕 Bildirim sistemi ${Platform.operatingSystem} için desteklenmiyor");
      return;
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const mac = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: android,
      iOS: ios,
      macOS: mac,
    );

    await _notifications.initialize(
  initSettings,
  onDidReceiveNotificationResponse: (details) {
    print("🔔 Bildirime tıklandı: ${details.payload}");
  },
  onDidReceiveBackgroundNotificationResponse: notificationTapBackground, // ✅ düzeltildi
);


    // 🔔 Firebase mesajlarını dinle (mobil/macOS için)
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      try {
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          final notification = message.notification;
          if (notification == null) return;

          _notifications.show(
            notification.hashCode,
            notification.title,
            notification.body,
            _platformNotificationDetails(),
          );
        });
      } catch (e) {
        print("⚠️ Firebase mesaj dinleme başlatılamadı: $e");
      }
    }
  }

  /// 🧪 Her platformda kullanılabilen genel local notification
  static Future<void> show({
    required String title,
    required String body,
  }) async {
    final enabled = await isEnabled();
    if (!enabled) {
      print("🔕 Bildirim tercihi kapalı olduğu için gösterilmedi: $title");
      return;
    }

    if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      print(
          "🔕 Test bildirimi \${Platform.operatingSystem} için desteklenmiyor");
      return;
    }

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      _platformNotificationDetails(),
    );
  }

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  static Future<void> toggle(bool enable) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('notifications_enabled', enable);
  print(enable ? "🔔 Bildirimler açıldı" : "🔕 Bildirimler kapatıldı");
}


  /// 🎛 Platforma uygun NotificationDetails
  static NotificationDetails _platformNotificationDetails() {
    const android = AndroidNotificationDetails(
      'zoom_ai_channel',
      'Zoom Notifications',
      channelDescription: 'Zoom toplantı bildirimleri',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    const mac = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    return const NotificationDetails(
      android: android,
      iOS: ios,
      macOS: mac,
    );
  }
}
