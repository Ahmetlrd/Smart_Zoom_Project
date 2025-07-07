import 'package:flutter/material.dart';
import 'package:flutter_app/features/home/utility.dart';
import 'package:flutter_app/gen_l10n/app_localizations.dart';
import 'package:flutter_app/services/zoom_recording_helper.dart';
import 'package:flutter_app/services/openai_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/providers/summary_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String? lastSavedSummary;

class Nlp extends ConsumerStatefulWidget {
  const Nlp({super.key});

  @override
  ConsumerState<Nlp> createState() => _NlpState();
}

class _NlpState extends ConsumerState<Nlp> {
  String? summary;
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;

  @override
void initState() {
  super.initState();
  summary = latestSummary;

  if (summary != null && summary!.trim().isNotEmpty) {
    Future.microtask(() async {
      ref.read(summaryProvider.notifier).state = summary;
      print("✅ summaryProvider güncellendi (initState): $summary");

      // ✅ Firestore'a otomatik kaydetme bloğu
      if (summary != lastSavedSummary) {
        final email = ref.read(authProvider.notifier).userInfo?['email'];
        if (email != null) {
          String title = 'Başlıksız';
          try {
            final titleLine = summary!
                .split('\n')
                .firstWhere((line) => line.startsWith('Title:'), orElse: () => '');
            if (titleLine.isNotEmpty) {
              title = titleLine.replaceFirst('Title:', '').replaceAll('"', '').trim();
            }
          } catch (e) {
            debugPrint('⚠️ Başlık ayrıştırılamadı: $e');
          }

          final docRef = FirebaseFirestore.instance
              .collection('summaries')
              .doc(email)
              .collection('history')
              .doc('latest_summary'); // sabit ID ile yaz (opsiyonel)

          await docRef.set({
            'title': title,
            'text': summary,
            'transcript': latestTranscript,
            'timestamp': DateTime.now().toIso8601String(),
            'isNew': true,
            'isReviewed': false,
          });

          lastSavedSummary = summary;
          print('💾 NLP özeti otomatik kaydedildi');
        }
      }
    });
  }
}


  void regenerateSummaryWithUserInput() async {
    if (summary == null) return;
    final extra = _controller.text.trim();
    if (extra.isEmpty) return;

    setState(() => isLoading = true);
    final service = OpenAIService();
    final prompt = """
Aşağıdaki Zoom toplantısı transkriptini kullanarak bir özet oluştur:(başlık kurallarını aynen uygulamayı unutma)
---
$latestTranscript bu toplantının transkripti
$latestSummary bu da son yapılan özet çıktı
---

Kullanıcının isteği:
\"$extra\"

Lütfen özeti bu yeni isteğe göre oluştur. Kısa, öz ve bilgi odaklı yaz.
""";

    final newSummary = await service.summarizeText(prompt);
    setState(() {
      summary = newSummary ?? summary;
      latestSummary = summary;
      isLoading = false;
    });

    ref.read(summaryProvider.notifier).state = summary;
    print("✅ summaryProvider güncellendi (güncelle sonrası): $summary");
  }

  Future<void> confirmAndSave() async {
    if (summary != null &&
        summary != lastSavedSummary &&
        summary != "null" &&
        summary!.trim().isNotEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          final d = AppLocalizations.of(dialogContext)!;
          return AlertDialog(
            title: Text(d.wannasave),
            content: Text(d.savetofirestore),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(d.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(d.save),
              ),
            ],
          );
        },
      );

      if (confirm != true) return;

      final email = ref.read(authProvider.notifier).userInfo?['email'];
      if (email == null) return;

      String title = 'Başlıksız';
      try {
        final titleLine = summary!
            .split('\n')
            .firstWhere((line) => line.startsWith('Title:'), orElse: () => '');
        if (titleLine.isNotEmpty) {
          title =
              titleLine.replaceFirst('Title:', '').replaceAll('"', '').trim();
        }
      } catch (e) {
        debugPrint('⚠️ Başlık ayrıştırılamadı: $e');
      }

      final docRef =
          FirebaseFirestore.instance.collection('summaries').doc(email);
      final historyRef = docRef.collection('history');

      await historyRef.add({
        'title': title,
        'text': summary,
        'transcript': latestTranscript,
        'timestamp': DateTime.now().toIso8601String(),
        'isReviewed': false, 
      });

      setState(() {
        lastSavedSummary = summary;
        summary = null;
        latestSummary = null;
      });

      ref.read(summaryProvider.notifier).state = null;
      print("🧹 summaryProvider sıfırlandı (save)");

      final d = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(d.savedsuccesfully)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = AppLocalizations.of(context);

    return Scaffold(
      appBar: Utility.buildAppBar(context),
      backgroundColor: const Color(0xFFF7F7FC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              d!.summary,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            if (summary != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  summary!,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              )
            else
              Column(
                children: [
                  const Icon(Icons.info_outline, size: 60, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    d.nosummaryyet,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            const SizedBox(height: 32),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: d.writeprompt,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.tips_and_updates_outlined),
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const CircularProgressIndicator()
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: confirmAndSave,
                    icon: const Icon(Icons.save_alt),
                    label: Text(d.save),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: regenerateSummaryWithUserInput,
                    icon: const Icon(Icons.edit_note_outlined),
                    label: Text(d.update),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (summary != null) {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(d.abouttodelete),
                            content: Text(d.areyousuretodelete),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text(d.cancel),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text(
                                  d.delete,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                         ),
                        );
                        print("🧪 Silme onayı sonucu: $confirm");
                        if (confirm == true) {
                          setState(() {
                            summary = null;
                            latestSummary = null;
                          });
                          ref.read(summaryProvider.notifier).state = null;
                          print("🧹 summaryProvider sıfırlandı (delete)");

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(d.summarydeleted)),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: Text(d.delete),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
