import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/services/openai_service.dart';
import 'package:flutter_app/services/notifications_service.dart';
import 'package:flutter_app/providers/summary_provider.dart';

String? latestSummary;
String? latestTranscript;

Future<File?> findLatestZoomAudioFile() async {
  final zoomFolder = Directory('/Users/${Platform.environment['USER']}/Documents/Zoom');
  if (!await zoomFolder.exists()) {
    print("❌ Zoom klasörü bulunamadı.");
    return null;
  }

  final subDirs = zoomFolder.listSync().whereType<Directory>().toList();
  if (subDirs.isEmpty) {
    print("❌ Zoom klasöründe alt klasör yok.");
    return null;
  }

  subDirs.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

  for (final dir in subDirs) {
    final audioFiles = dir.listSync().whereType<File>().where((file) => file.path.toLowerCase().endsWith('.m4a')).toList();
    if (audioFiles.isNotEmpty) {
      print("🎯 Ses dosyası bulundu: ${audioFiles.first.path}");
      return audioFiles.first;
    }
  }

  print("❌ Hiçbir .m4a dosyası bulunamadı.");
  return null;
}

Future<void> runDirectZoomSummaryFlow(WidgetRef ref) async {
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

  // 🧠 HomePage’i tetikleyecek!
  ref.read(summaryProvider.notifier).state = summary;
  print("✅ summaryProvider güncellendi: $summary");
}

void watchZoomFolder(WidgetRef ref) {
  final zoomDir = Directory('/Users/${Platform.environment['USER']}/Documents/Zoom');

  if (!zoomDir.existsSync()) {
    print("❌ Zoom klasörü bulunamadı.");
    return;
  }

  zoomDir.watch(recursive: true).listen((event) async {
    if (event.type == FileSystemEvent.create && event.path.toLowerCase().endsWith('.m4a')) {
      print("🆕 Yeni .m4a dosyası algılandı: ${event.path}");

      await Future.delayed(const Duration(seconds: 2));

      await NotificationService.show(
        title: 'Özet hazırlanıyor',
        body: 'Ses dosyası alındı, analiz başlıyor...',
      );

      await runDirectZoomSummaryFlow(ref);

      await NotificationService.show(
        title: 'Zoom özeti hazır!',
        body: 'Yeni toplantı otomatik özetlendi.',
      );
    }
  });

  print("📡 Zoom klasörü izleniyor...");
}
