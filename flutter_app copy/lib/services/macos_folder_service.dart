import 'dart:convert';
import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MacOSFolderService {
  static const MethodChannel _channel =
      MethodChannel('smartzoom.macos.bookmark');
  static const _bookmarkKey = 'zoom_folder_path';

  /// Kullanıcıdan klasör seçmesini ister ve Swift'e kaydettirir
  static Future<String?> selectFolderAndSaveBookmark() async {
  final path = await getDirectoryPath();
  if (path == null) return null;

  final dir = Directory(path);
  final folderName = dir.path.split(Platform.pathSeparator).last;

  // Zoom klasörü adını kontrol et
  final isCorrectName = folderName.toLowerCase() == 'zoom';

  // Alt klasörlerde ses dosyası var mı kontrol et
  bool hasAudioInSubdirs = false;
  try {
    final subdirs = dir.listSync().whereType<Directory>();
    for (final sub in subdirs) {
      final hasAudio = sub
          .listSync()
          .whereType<File>()
          .any((f) => f.path.endsWith('.m4a') || f.path.endsWith('.mp4'));
      if (hasAudio) {
        hasAudioInSubdirs = true;
        break;
      }
    }
  } catch (e) {
    print("🚨 Alt klasörleri tararken hata: $e");
  }

  if (isCorrectName && hasAudioInSubdirs) {
    // Swift tarafına kaydet
    try {
      final result = await _channel.invokeMethod('saveBookmark', {'path': path});
      if (result == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_bookmarkKey, path);
        print('✅ Bookmark başarıyla kaydedildi.');
        return path;
      }
    } catch (e) {
      print('⚠️ Bookmark kayıt hatası: $e');
    }
  } else {
    print("❌ Seçilen klasör geçerli bir Zoom klasörü değil: $path");
  }

  return null;
}


  /// Daha önce kaydedilmiş klasör yolunu döner (bookmark erişimi Swift'te açılır)
  static Future<String?> getSavedFolder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_bookmarkKey);
  }
}
