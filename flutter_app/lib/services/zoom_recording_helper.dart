import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/openai_service.dart';
import 'package:flutter_app/services/summary_saver.dart';
import 'package:flutter_app/services/notifications_service.dart';
import 'package:flutter_app/providers/summary_provider.dart';
import 'package:flutter_app/providers/locale_provider.dart';

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

  print("🎧 Ses dosyaları Whisper’a gönderiliyor...");
  final List<String> transcripts = [];

  for (final file in files) {
    final transcript = await service.transcribeAudio(file);
    if (transcript != null) transcripts.add(transcript);
  }

  if (transcripts.isEmpty) {
    print("❌ Hiçbir transkript oluşturulamadı.");
    return;
  }

  final combinedTranscript = transcripts.join("\n\n");
  print("📄 Birleştirilmiş transcript:\n$combinedTranscript");

  final locale = ref.read(localeProvider) ?? const Locale('tr');
  print("🌐 Aktif dil: ${locale.languageCode}");

  print("🧠 GPT-4 ile özetleniyor...");
  final summary = await service.summarizeText(combinedTranscript, locale);

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
  print("✅ summaryProvider güncellendi.");
}

bool isSummarizing = false;

void watchZoomFolder(WidgetRef ref, Locale locale) {
  final zoomDir = Directory('/Users/${Platform.environment['USER']}/Documents/Zoom');

  if (!zoomDir.existsSync()) {
    print("❌ Zoom klasörü bulunamadı.");
    return;
  }

  zoomDir.watch(recursive: true).listen((event) async {
    if (event.type == FileSystemEvent.create && event.path.toLowerCase().endsWith('.m4a')) {
      if (isSummarizing) {
        print("⏳ Özetleme zaten devam ediyor.");
        return;
      }

      isSummarizing = true;
      print("🆕 Yeni .m4a dosyası algılandı: ${event.path}");

      await Future.delayed(const Duration(seconds: 2));

      final lang = locale.languageCode;
      print("🌍 Bildirimler şu dilde gösterilecek: ${locale.languageCode}");

      final preparingTitle = {
        'tr': 'Özet hazırlanıyor',
        'en': 'Summary is being prepared',
        'fr': 'Résumé en préparation',
        'de': 'Zusammenfassung wird vorbereitet',
      }[lang] ?? 'Summary is being prepared';

      final preparingBody = {
        'tr': 'Ses dosyaları alındı, analiz başlıyor...',
        'en': 'Audio files received, analysis starting...',
        'fr': 'Fichiers audio reçus, analyse en cours...',
        'de': 'Audiodateien empfangen, Analyse beginnt...',
      }[lang] ?? 'Audio files received, analysis starting...';

      await NotificationService.show(
        title: preparingTitle,
        body: preparingBody,
      );

      await runDirectZoomSummaryFlow(ref);

      final readyTitle = {
        'tr': 'Zoom özeti hazır!',
        'en': 'Zoom Summary Ready!',
        'fr': 'Résumé Zoom prêt !',
        'de': 'Zoom-Zusammenfassung fertig!',
      }[lang] ?? 'Zoom Summary Ready!';

      final readyBody = {
        'tr': 'Yeni toplantı otomatik özetlendi.',
        'en': 'New meeting has been summarized automatically.',
        'fr': 'Nouvelle réunion résumée automatiquement.',
        'de': 'Neues Meeting wurde automatisch zusammengefasst.',
      }[lang] ?? 'New meeting has been summarized automatically.';

      await NotificationService.show(
        title: readyTitle,
        body: readyBody,
      );

      isSummarizing = false;
    }
  });

  print("📡 Zoom klasörü izleniyor...");
}
