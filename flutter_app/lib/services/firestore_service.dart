import 'package:cloud_firestore/cloud_firestore.dart';

// FirestoreService handles token and summary operations with Firestore database
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Saves access and refresh tokens to Firestore under the user's document
  Future<void> saveTokens({
    required String userEmail,
    required String accessToken,
    required String refreshToken,
    required DateTime accessExpiry,
    required DateTime refreshExpiry,
  }) async {
    final userId = normalizeEmail(userEmail);
    final userDoc = _firestore.collection('users').doc(userId);

    await userDoc.set({
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'accessTokenExpiry': Timestamp.fromDate(accessExpiry),
      'refreshTokenExpiry': Timestamp.fromDate(refreshExpiry),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Retrieves token data from Firestore for the given userId
  Future<Map<String, dynamic>?> getTokens(String userEmail) async {
    final userId = normalizeEmail(userEmail);
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.exists ? doc.data() : null;
  }

  // Adds a new summary document under the user's summaries subcollection
  Future<void> addSummary(String userEmail, String text) async {
    final userId = normalizeEmail(userEmail);
    final summariesCol = _firestore.collection('users').doc(userId).collection('summaries');
    await summariesCol.add({
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Normalizes the email to be used as Firestore document ID
  static String normalizeEmail(String email) {
    return email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
  }
}
