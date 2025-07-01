import 'package:flutter/material.dart';
import 'package:flutter_app/features/home/utility.dart';
import 'package:flutter_app/gen_l10n/app_localizations.dart';
import 'package:flutter_app/services/zoom_recording_helper.dart';
import 'package:flutter_app/services/openai_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String? lastSavedSummary; // Local olarak en son kaydedilen özet

class Nlp extends ConsumerStatefulWidget {
  const Nlp({super.key});

  @override
  ConsumerState<Nlp> createState() => _NlpState();
}

class _NlpState extends ConsumerState<Nlp> {
  String? summary = latestSummary;
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;

  void regenerateSummaryWithUserInput() async {
    if (summary == null) return;
    final extra = _controller.text.trim();
    if (extra.isEmpty) return;

    setState(() => isLoading = true);
    final service = OpenAIService();
    final prompt = """
Aşağıdaki Zoom toplantısı transkriptini kullanarak bir özet oluştur:
---
$latestTranscript
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
  }

  Future<void> confirmAndSave() async {
    if (summary != null && summary != lastSavedSummary) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Kaydetmek istiyor musunuz?"),
          content: const Text(
              "Bu özeti Firestore'a kaydedeceksiniz. Devam edilsin mi?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Hayır"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Evet"),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      final email = ref.read(authProvider.notifier).userInfo?['email'];
      if (email == null || summary == null) return;

      final title = summary!.split(" ").take(5).join(" ") + "...";
      final docRef = FirebaseFirestore.instance.collection('summaries').doc(email);
      final historyRef = docRef.collection('history');

      await historyRef.add({
        'title': title,
        'text': summary,
        'timestamp': DateTime.now().toIso8601String(),
      });

      setState(() {
        lastSavedSummary = summary;
        summary = null;
        latestSummary = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Özet başarıyla kaydedildi.")),
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
            const Text(
              "Özet",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                children: const [
                  Icon(Icons.info_outline, size: 60, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    "Henüz bir toplantı özeti oluşturulmadı.",
                    style: TextStyle(
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
              decoration: const InputDecoration(
                hintText: "Özete eklenecek isteğinizi yazın...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tips_and_updates_outlined),
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
                    label: const Text("Kaydet"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: regenerateSummaryWithUserInput,
                    icon: const Icon(Icons.edit_note_outlined),
                    label: const Text("Geliştir"),
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
                            title: const Text("Özeti silmek üzeresiniz"),
                            content: const Text(
                                "Bu işlem geri alınamaz. Özeti silmek istediğinize emin misiniz?"),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text("Vazgeç"),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text("Sil",
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          setState(() {
                            summary = null;
                            latestSummary = null;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Özet silindi.")),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text("Sil"),
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
