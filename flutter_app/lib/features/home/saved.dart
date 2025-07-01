import 'package:flutter/material.dart';
import 'package:flutter_app/features/home/utility.dart';
import 'package:flutter_app/gen_l10n/app_localizations.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class Saved extends ConsumerWidget {
  const Saved({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.read(authProvider.notifier).userInfo?['email'];
    final d = AppLocalizations.of(context);

    if (email == null) {
      context.go('/login');
      return const Scaffold(
        body: Center(child: Text("Lütfen giriş yapınız.")),
        
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE8F1FF), // Mavi tonlu arka plan
      appBar: Utility.buildAppBar(context),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('summaries')
            .doc(email)
            .collection('history')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text("Kayıtlı özet bulunamadı."),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Özet';
              final text = data['text'] ?? '';
              final time = DateTime.tryParse(data['timestamp'] ?? '');
              final formatted = time != null
                  ? "${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} ${time.hour}:${time.minute.toString().padLeft(2, '0')}"
                  : '';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                child: ListTile(
                  title: Text("Title: $title", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(formatted),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) => Dialog(
                        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Title: $title", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(formatted, style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 16),
                              Text(text, style: const TextStyle(fontSize: 16)),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: dialogContext,
                                        builder: (BuildContext confirmContext) => AlertDialog(
                                          title: const Text("Silmek istiyor musunuz?"),
                                          content: const Text("Bu işlem kalıcıdır ve geri alınamaz. Devam edilsin mi?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(confirmContext, false),
                                              child: const Text("Vazgeç"),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(confirmContext, true),
                                              child: const Text("Sil", style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        await doc.reference.delete();
                                        Navigator.pop(dialogContext); // Close detail dialog
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Özet silindi.")),
                                        );
                                      }
                                    },
                                    child: const Text("Sil", style: TextStyle(color: Colors.red)),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(),
                                    child: const Text("Kapat"),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
