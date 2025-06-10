import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final meetingStatusProvider = StreamProvider.family<bool, String>((ref, userEmail) {
  final userId = userEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
  final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
  return docRef.snapshots().map((doc) {
    final data = doc.data();
    if (data == null) return false;
    final meetingStatus = data['meetingStatus'] as Map<String, dynamic>?;
    return meetingStatus?['isJoined'] == true;
  });
});