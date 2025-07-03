import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_selector/file_selector.dart';

class ZoomPermissionService {
  static const _zoomPathKey = 'zoom_folder_path';

  /// İlk kullanımda kullanıcıdan klasörü seçtirir veya kayıtlı klasörü doğrular
  static Future<String?> getValidZoomPathOrReselectIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString(_zoomPathKey);

    if (savedPath != null) {
      final dir = Directory(savedPath);
      try {
        dir.listSync(); // Deniyoruz
        print("📂 Kaydedilen Zoom klasörüne erişildi.");
        return savedPath;
      } catch (e) {
        print("🚫 Kayıtlı klasöre erişilemedi. İzin reddedilmiş olabilir.");
      }
    }

    // Kullanıcıya yeniden seçtir
    final reselectedPath = await getDirectoryPath(
      confirmButtonText: 'Zoom klasörünü seç',
      initialDirectory: '/Users/${Platform.environment['USER']}/Documents',
    );

    if (reselectedPath != null) {
      try {
        final dir = Directory(reselectedPath);
        dir.listSync(); // Erişilebilir mi test et
        await prefs.setString(_zoomPathKey, reselectedPath);
        print("✅ Yeni klasör seçildi ve kayıt edildi: $reselectedPath");
        return reselectedPath;
      } catch (e) {
        print("❌ Seçilen klasöre erişilemedi: $e");
        return null;
      }
    }

    return null;
  }
}
