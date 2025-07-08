import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/features/home/utility.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/gen_l10n/app_localizations.dart'; // Custom utility functions (e.g., for app bars)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

class Meetinglist extends ConsumerWidget {
  const Meetinglist({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.read(authProvider.notifier).userInfo?['email'];
    final d = AppLocalizations.of(context);

    if (email == null) {
      context.go('/login');
      return Scaffold(
        body: Center(child: Text(d!.pleaselogin)),
      );
    }

    return Scaffold(
      appBar: Utility.buildAppBar(context),
      backgroundColor: const Color(0xFFF3F6FB),
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
            return Center(child: Text(d!.nomeetingfound));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final title =
                  (data.containsKey('title') && data['title'] is String)
                      ? data['title']
                      : 'Toplantı';
              final summary =
                  (data.containsKey('text') && data['text'] is String)
                      ? data['text']
                      : '';
              final transcript = (data.containsKey('transcript') &&
                      data['transcript'] is String)
                  ? data['transcript']
                  : '';
              final timestampStr = data['timestamp'];
              final timestamp =
                  DateTime.tryParse(timestampStr ?? '') ?? DateTime.now();
              final formattedDate =
                  "${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}";
              final relative = timeago.format(timestamp, locale: 'tr');

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                child: ExpansionTile(
                  title: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("$formattedDate ($relative)"),
                  trailing: const Icon(Icons.folder),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.article_outlined),
                      title: Text(d!.transcription),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) => AlertDialog(
                            title: Text(d!.transcription),
                            content: SingleChildScrollView(
                                child: Text(transcript.isNotEmpty
                                    ? transcript
                                    : d!.notranscriptfound)),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(),
                                child: Text(d!.close),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.summarize_outlined),
                      title: Text(d!.summary),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) => AlertDialog(
                            title: Text(d!.summary),
                            content: SingleChildScrollView(
                                child: Text(summary.isNotEmpty
                                    ? summary
                                    : d!.nosummaryfound)),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(),
                                child: Text(d!.close),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16, bottom: 12),
                        child: TextButton(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext confirmContext) =>
                                  AlertDialog(
                                title: Text(d.wannadeletemeeting),
                                content: Text(d.areyousuretocont),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(confirmContext, false),
                                    child: Text(d.cancel),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(confirmContext, true),
                                    child: Text(d.delete,
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await doc.reference.delete();

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(d.meetingdeleted)),
                                );
                              }
                            }
                          },
                          child: Text(d.delete,
                              style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
