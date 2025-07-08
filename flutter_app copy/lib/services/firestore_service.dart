import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save access, refresh and FCM tokens to Firestore
  Future<void> saveTokens({
    required String userEmail,
    required String accessToken,
    required String refreshToken,
    required DateTime accessExpiry,
    required DateTime refreshExpiry,
    String? fcmToken, // Optional
    String? timezone,
    String? hostId,
  }) async {
    final userId = normalizeEmail(userEmail);
    final userDoc = _firestore.collection('users').doc(userId);

    final data = {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'accessTokenExpiry': Timestamp.fromDate(accessExpiry),
      'refreshTokenExpiry': Timestamp.fromDate(refreshExpiry),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (fcmToken != null) {
      data['fcmToken'] = fcmToken;
    }
    if (timezone != null) data['timezone'] = timezone;
    if (hostId != null) data['hostId'] = hostId;
    await userDoc.set(data, SetOptions(merge: true));
  }

  // Update only FCM token
  Future<void> updateFcmToken(String userEmail, String? token) async {
    if (token == null) return;
    final userId = normalizeEmail(userEmail);
    final userDoc = _firestore.collection('users').doc(userId);
    await userDoc.update({
      'fcmToken': token,
      'fcmUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Retrieve token and FCM data
  Future<Map<String, dynamic>?> getTokens(String userEmail) async {
    final userId = normalizeEmail(userEmail);
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.exists ? doc.data() : null;
  }

  // Add a new summary under user's summaries subcollection
  Future<void> addSummary(String userEmail, String text) async {
    final userId = normalizeEmail(userEmail);
    final summariesCol =
        _firestore.collection('users').doc(userId).collection('summaries');
    await summariesCol.add({
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Permanently delete a user document
  Future<void> deleteUser(String userEmail) async {
    final userId = normalizeEmail(userEmail);
    await _firestore.collection('users').doc(userId).delete();
  }

  // Normalize email to be used as document ID (safe Firestore key)
  static String normalizeEmail(String email) {
    return email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
  }
}
