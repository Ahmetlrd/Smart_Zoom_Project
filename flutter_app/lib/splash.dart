import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/secure_storage_service.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final localToken = await readAccessToken();

    // First try local token from secure storage
    if (localToken != null) {
      ref.read(authProvider.notifier).loginWithToken(localToken);
      context.go('/home');
      return;
    }

    // Try Firestore token if no local token found
    final userEmail = ref.read(authProvider.notifier).userInfo?['email'];
    if (userEmail != null) {
      final userId = FirestoreService.normalizeEmail(userEmail);
      final tokenData = await FirestoreService().getTokens(userId);

      if (tokenData != null) {
        final now = DateTime.now();
        final accessExpiry = (tokenData['accessTokenExpiry'] as Timestamp).toDate();
        final refreshExpiry = (tokenData['refreshTokenExpiry'] as Timestamp).toDate();

        if (now.isBefore(accessExpiry)) {
          await saveAccessToken(tokenData['accessToken']);
          ref.read(authProvider.notifier).loginWithToken(tokenData['accessToken']);
          context.go('/home');
          return;
        }

        if (now.isBefore(refreshExpiry)) {
          final newAccessToken = await AuthService.refreshAccessToken(tokenData['refreshToken']);
          if (newAccessToken != null) {
            await saveAccessToken(newAccessToken);
            await FirestoreService().saveTokens(
              userEmail: userEmail,
              accessToken: newAccessToken,
              refreshToken: tokenData['refreshToken'],
              accessExpiry: DateTime.now().add(Duration(hours: 1)),
              refreshExpiry: refreshExpiry,
            );
            ref.read(authProvider.notifier).loginWithToken(newAccessToken);
            context.go('/home');
            return;
          }
        }
      }
    }

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white10,
    );
  }
}
