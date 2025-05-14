import 'package:flutter_app/services/secure_storage_service.dart' as SecureStorageService;
import 'package:flutter_app/services/zoom_service.dart';
import 'package:flutter_app/services/firestore_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Define a Riverpod provider to manage the user's login state across the app
final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});

// AuthNotifier handles authentication state and Firestore token management
class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false) {
    _loadLoginStatus();
  }

  Map<String, dynamic>? _userInfo;
  Map<String, dynamic>? get userInfo => _userInfo;

  Future<void> _loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    state = true;
  }

  Future<void> loginWithToken(String token) async {
    state = true;
    final info = await ZoomService.fetchUserInfo();
    _userInfo = info;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    await SecureStorageService.clearAllTokens();

    final userEmail = _userInfo?['email'];
    if (userEmail != null) {
      final userId = FirestoreService.normalizeEmail(userEmail);
      await FirestoreService().saveTokens(
        userEmail: userEmail,
        accessToken: '',
        refreshToken: '',
        accessExpiry: DateTime.fromMillisecondsSinceEpoch(0),
        refreshExpiry: DateTime.fromMillisecondsSinceEpoch(0),
      );
    }

    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}

    _userInfo = null;
    state = false;
  }
}
