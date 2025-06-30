import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_app/services/openai_service.dart';

/// Kullanıcıya Zoom klasörünü seçtirir
Future<String?> selectZoomFolderWithFileSelector() async {
  final directory = await getDirectoryPath(
    confirmButtonText: 'Seç',
    initialDirectory: '/Users/${Platform.environment['USER']}/Documents/Zoom',
  );

  if (directory == null) {
    print("❌ Kullanıcı klasör seçmedi.");
    return null;
  }

  print("📂 Seçilen klasör: $directory");
  return directory;
}

/// Seçilen klasördeki ilk .m4a dosyasını döner
Future<File?> getFirstM4aFile(String folderPath) async {
  final dir = Directory(folderPath);
  if (!await dir.exists()) return null;

  final m4aFiles = dir
      .listSync()
      .whereType<File>()
      .where((file) => file.path.toLowerCase().endsWith('.m4a'))
      .toList();

  return m4aFiles.isNotEmpty ? m4aFiles.first : null;
}

/// Tüm süreci çalıştırır: klasör seç > m4a bul > transkribe > özetle


Future<void> runDirectZoomSummaryFlow() async {
  final path = "/Users/ahmetcavusoglu/Documents/Zoom/2023-12-25 21.19.42 Ahmet Çavuşoğlu (Student)'s Zoom Meeting/audio5033074858.m4a";
  final file = File(path);

  if (!await file.exists()) {
    print("❌ Dosya bulunamadı: $path");
    return;
  }

  print("✅ Ses dosyası bulundu: $path");

  final service = OpenAIService();

  print("🎧 Whisper’a gönderiliyor...");
  final transcript = await service.transcribeAudio(file);
  if (transcript == null) {
    print("❌ Transkript başarısız.");
    return;
  }
  print("📄 Transcript:\n$transcript");

  print("🧠 GPT-4 ile özetleniyor...");
  final summary = await service.summarizeText(transcript);
  if (summary == null) {
    print("❌ Özetleme başarısız.");
    return;
  }
  print("🧾 Özet:\n$summary");
}
