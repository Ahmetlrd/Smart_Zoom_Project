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

    try {
      final result = await _channel.invokeMethod('saveBookmark', {'path': path});
      if (result == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_bookmarkKey, path);
        print('✅ Bookmark başarıyla kaydedildi.');
        return path;
      } else {
        print('❌ Bookmark kaydedilemedi.');
        return null;
      }
    } catch (e) {
      print('⚠️ Bookmark kayıt hatası: $e');
      return null;
    }
  }

  /// Daha önce kaydedilmiş klasör yolunu döner (bookmark erişimi Swift'te açılır)
  static Future<String?> getSavedFolder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_bookmarkKey);
  }
}
