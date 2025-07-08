import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> saveSummaryToFirestore({
  required WidgetRef ref,
  required String summary,
  required String? transcript,
}) async {
  if (transcript == null || transcript.trim().isEmpty) return;

  final email = ref.read(authProvider.notifier).userInfo?['email'];
  if (email == null || summary.trim().isEmpty) return;

 String title = 'Untitled';
try {
  final lines = summary.split('\n');
  final titleLine = lines.firstWhere(
    (line) => line.toLowerCase().contains('title:'),
    orElse: () => '',
  );

  if (titleLine.isNotEmpty) {
    title = titleLine.split(':').sublist(1).join(':').trim();
    title = title.replaceAll(RegExp(r'^["“”]+|["“”]+$'), ''); 
  }
} catch (e) {
  print('⚠️ Başlık ayrıştırılamadı: $e');
}


  final collectionRef = FirebaseFirestore.instance
    .collection('summaries')
    .doc(email)
    .collection('history');

await collectionRef.add({
  'title': title,
  'text': summary,
  'transcript': transcript,
  'timestamp': DateTime.now().toIso8601String(),
  'isNew': true,
  'isReviewed': false,
});


  print('💾 Firestore\'a yeni özet eklendi (auto ID ile)');
}
