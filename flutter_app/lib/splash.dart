import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/services/secure_storage_service.dart';
import 'package:go_router/go_router.dart';

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
    final token = await readAccessToken();
    final isLoggedIn = token != null;

    if (isLoggedIn) {
      ref.read(authProvider.notifier).loginWithToken(token!);
      context.go('/home');
    } else {
      Future.microtask(() => context.go('/login'));

    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white10,
      
    );
  }
}