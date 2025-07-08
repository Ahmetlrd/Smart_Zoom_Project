import 'package:flutter_app/services/firestore_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

// FirestoreService provider to access Firestore methods
final firestoreServiceProvider = Provider((ref) => FirestoreService());

// Token provider to manage access token state
final tokenProvider = StateNotifierProvider<TokenNotifier, String?>((ref) {
  return TokenNotifier(ref);
});

// TokenNotifier handles loading and updating access tokens from Firestore
class TokenNotifier extends StateNotifier<String?> {
  final Ref ref;

  TokenNotifier(this.ref) : super(null);

  // Loads token from Firestore and updates the state
  Future<void> loadToken() async {
    final userEmail = ref.read(authProvider.notifier).userInfo?['email'];
    if (userEmail == null) {
      print('No user email found. Cannot load token.');
      return;
    }

    final userId = FirestoreService.normalizeEmail(userEmail);
    final data = await ref.read(firestoreServiceProvider).getTokens(userId);
    state = data?['accessToken'];
  }

  // Updates the token in Firestore and updates local state
  Future<void> updateToken({
    required String accessToken,
    required String refreshToken,
    required DateTime accessExpiry,
    required DateTime refreshExpiry,
  }) async {
    final userEmail = ref.read(authProvider.notifier).userInfo?['email'];
    if (userEmail == null) {
      print('No user email found. Cannot update token.');
      return;
    }

    await ref.read(firestoreServiceProvider).saveTokens(
      userEmail: userEmail,
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessExpiry: accessExpiry,
      refreshExpiry: refreshExpiry,
    );
    state = accessToken;
  }
}
