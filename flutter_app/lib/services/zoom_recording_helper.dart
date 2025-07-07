import 'dart:io';
import 'package:flutter_app/services/summary_saver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/services/openai_service.dart';
import 'package:flutter_app/services/notifications_service.dart';
import 'package:flutter_app/providers/summary_provider.dart';

String? latestSummary;
String? latestTranscript;

Future<List<File>> findAllZoomAudioFilesInLatestFolder() async {
  final zoomFolder = Directory('/Users/${Platform.environment['USER']}/Documents/Zoom');
  if (!await zoomFolder.exists()) {
    print("❌ Zoom klasörü bulunamadı.");
    return [];
  }

  final subDirs = zoomFolder.listSync().whereType<Directory>().toList();
  if (subDirs.isEmpty) {
    print("❌ Zoom klasöründe alt klasör yok.");
    return [];
  }

  subDirs.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
  final latestDir = subDirs.first;

  final audioFiles = latestDir
      .listSync()
      .whereType<File>()
      .where((file) => file.path.toLowerCase().endsWith('.m4a'))
      .toList();

  return audioFiles;
}

Future<void> runDirectZoomSummaryFlow(WidgetRef ref) async {
  final files = await findAllZoomAudioFilesInLatestFolder();
  if (files.isEmpty) {
    print("❌ Ses dosyası bulunamadı.");
    return;
  }

  print("✅ ${files.length} ses dosyası bulundu.");
  final service = OpenAIService();

  print("🎧 Tüm ses dosyaları Whisper’a gönderiliyor...");
  final List<String> transcripts = [];

  for (final file in files) {
    final transcript = await service.transcribeAudio(file);
    if (transcript != null) {
      transcripts.add(transcript);
    }
  }

  if (transcripts.isEmpty) {
    print("❌ Hiçbir transkript oluşturulamadı.");
    return;
  }

  final combinedTranscript = transcripts.join("\n\n");
  print("📄 Birleştirilmiş Transcript:\n$combinedTranscript");

  print("🧠 GPT-4 ile özetleniyor...");
  final summary = await service.summarizeText(combinedTranscript);

  if (summary == null) {
    print("❌ Özetleme başarısız.");
    return;
  }

  latestTranscript = combinedTranscript;
  latestSummary = summary;

  await saveSummaryToFirestore(
    ref: ref,
    summary: summary,
    transcript: latestTranscript,
  );

  ref.read(summaryProvider.notifier).state = summary;
  print("✅ summaryProvider güncellendi: $summary");
}

bool isSummarizing = false;

void watchZoomFolder(WidgetRef ref) {
  final zoomDir = Directory('/Users/${Platform.environment['USER']}/Documents/Zoom');

  if (!zoomDir.existsSync()) {
    print("❌ Zoom klasörü bulunamadı.");
    return;
  }

  zoomDir.watch(recursive: true).listen((event) async {
    if (event.type == FileSystemEvent.create && event.path.toLowerCase().endsWith('.m4a')) {
      if (isSummarizing) {
        print("⏳ Özetleme zaten devam ediyor, yeni istek beklemeye alındı.");
        return;
      }

      isSummarizing = true;
      print("🆕 Yeni .m4a dosyası algılandı: ${event.path}");

      await Future.delayed(const Duration(seconds: 2));

      await NotificationService.show(
        title: 'Özet hazırlanıyor',
        body: 'Ses dosyaları alındı, analiz başlıyor...',
      );

      await runDirectZoomSummaryFlow(ref);

      await NotificationService.show(
        title: 'Zoom özeti hazır!',
        body: 'Yeni toplantı otomatik özetlendi.',
      );

      isSummarizing = false;
    }
  });

  print("📡 Zoom klasörü izleniyor...");
}
