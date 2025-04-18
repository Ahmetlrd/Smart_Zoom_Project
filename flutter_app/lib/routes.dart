import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_app/features/home/meetings.dart';
import 'package:flutter_app/features/home/nlp.dart';
import 'package:flutter_app/features/home/notes.dart';
import 'package:flutter_app/features/home/saved.dart';
import 'package:flutter_app/features/home/settings.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/home/login.dart';
import 'features/home/home_page.dart';
import 'providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authProvider.notifier).stream,
    ),
    routes: [
      GoRoute(
        path: '/',
        builder:
            (context, state) => isLoggedIn ? const HomePage() : const Login(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const Login()),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(path: '/settings', builder: (context, state) => const Settings()),
      GoRoute(path: '/saved', builder: (context, state) => const Saved()),

      GoRoute(path: '/notes', builder: (context, state) => const Notes()),

      GoRoute(path: '/nlp', builder: (context, state) => const Nlp()),

      GoRoute(path: '/meetings', builder: (context, state) => const Meetings()),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((event) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
