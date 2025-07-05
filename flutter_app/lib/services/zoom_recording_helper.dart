import 'dart:io';
import 'package:flutter_app/services/openai_service.dart';
import 'package:flutter_app/services/notifications_service.dart';

String? latestSummary;
String? latestTranscript;

/// Zoom klasöründeki en son klasörü bulur ve ilk .m4a dosyasını getirir
Future<File?> findLatestZoomAudioFile() async {
  final zoomFolder =
      Directory('/Users/${Platform.environment['USER']}/Documents/Zoom');

  if (!await zoomFolder.exists()) {
    print("❌ Zoom klasörü bulunamadı.");
    return null;
  }

  final subDirs = zoomFolder.listSync().whereType<Directory>().toList();

  if (subDirs.isEmpty) {
    print("❌ Zoom klasöründe alt klasör yok.");
    return null;
  }

  subDirs
      .sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

  for (final dir in subDirs) {
    final audioFiles = dir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.toLowerCase().endsWith('.m4a'))
        .toList();

    if (audioFiles.isNotEmpty) {
      print("🎯 Ses dosyası bulundu: ${audioFiles.first.path}");
      return audioFiles.first;
    }
  }

  print("❌ Hiçbir .m4a dosyası bulunamadı.");
  return null;
}

/// Tüm süreci çalıştırır: klasör bul > .m4a dosyasını al > transkribe > özetle
Future<void> runDirectZoomSummaryFlow() async {
  final file = await findLatestZoomAudioFile();

  if (file == null || !await file.exists()) {
    print("❌ Ses dosyası bulunamadı.");
    return;
  }

  print("✅ Ses dosyası bulundu: ${file.path}");

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
  latestTranscript = transcript;
  latestSummary = summary;

  print("🧾 Özet:\n$summary");
}

void watchZoomFolder() {
  final zoomDir =
      Directory('/Users/${Platform.environment['USER']}/Documents/Zoom');

  if (!zoomDir.existsSync()) {
    print("❌ Zoom klasörü bulunamadı.");
    return;
  }

  zoomDir.watch(recursive: true).listen((event) async {
    if (event.type == FileSystemEvent.create &&
        event.path.toLowerCase().endsWith('.m4a')) {
      print("🆕 Yeni .m4a dosyası algılandı: ${event.path}");

      // Dosyanın tamamen yazılmasını bekle
      await Future.delayed(Duration(seconds: 2));

      // 🔔 Yeni eklenen adım: "özet hazırlanıyor" bildirimi
      await NotificationService.show(
        title: 'Özet hazırlanıyor',
        body: 'Ses dosyası alındı, analiz başlıyor...',
      );

      // Ardından özet çıkarma süreci başlasın
      await runDirectZoomSummaryFlow();

      // 🔔 Mevcut: Özet hazır bildirimi
      await NotificationService.show(
        title: 'Zoom özeti hazır!',
        body: 'Yeni toplantı otomatik özetlendi.',
      );
    }
  });

  print("📡 Zoom klasörü izleniyor...");
}
