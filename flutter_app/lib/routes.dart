import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_app/features/home/meetingdetailpage.dart';
import 'package:flutter_app/features/home/nlp.dart';
import 'package:flutter_app/features/home/saved.dart';
import 'package:flutter_app/features/home/meetinglist.dart';
import 'package:flutter_app/features/home/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/home/login.dart';
import 'features/home/home_page.dart';
import 'providers/auth_provider.dart';
import 'package:flutter_app/splash.dart';

// This provider creates a GoRouter instance to handle app navigation
final routerProvider = Provider<GoRouter>((ref) {
  // Check login status from the authProvider
  final isLoggedIn = ref.watch(authProvider);

  return GoRouter(
    // Initial route when the app launches
    initialLocation: '/',

    // Tells GoRouter to rebuild when auth state changes
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authProvider.notifier).stream,
    ),

    // Define all the app routes
    routes: [
      // If user is logged in, go to HomePage; otherwise go to Login screen
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      // Define other static routes
      
      GoRoute(path: '/login', builder: (context, state) => const Login()),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(path: '/settings', builder: (context, state) => const Settings()),
      GoRoute(path: '/meetinglist', builder: (context, state) => const Meetinglist()),
      GoRoute(path: '/saved', builder: (context, state) => const Saved()),
      GoRoute(path: '/nlp', builder: (context, state) => const Nlp()),

      // Meeting details page (dynamic or detailed content can be passed here)
      GoRoute(
        path: '/meetingdetailpage',
        builder: (context, state) => MeetingDetailPage(),
      ),
    ],
  );
});

// A class that listens to changes in the authProvider's stream and notifies GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners(); // Notify listeners initially
    _subscription = stream.asBroadcastStream().listen((event) {
      notifyListeners(); // Notify on every new event
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel(); // Cancel the stream subscription when disposed
    super.dispose();
  }
}
