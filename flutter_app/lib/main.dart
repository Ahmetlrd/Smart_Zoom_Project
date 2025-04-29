import 'package:flutter/material.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/providers/locale_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';

Future<void> handleIncomingLinks(WidgetRef ref, BuildContext context) async {
  final appLinks = AppLinks();
  appLinks.uriLinkStream.listen((Uri? uri) {
    if (uri != null && uri.scheme == 'zoomai') {
      final token = uri.queryParameters['token'];
      if (token != null) {
        ref.read(authProvider.notifier).loginWithToken(token);

        // router henüz hazır değilse bu hataya düşer
        Future.delayed(Duration(milliseconds: 100), () {
          context.go('/home');
        });
      }
    }
  });
}


void listenForZoomCallback(WidgetRef ref) {
  final appLinks = AppLinks();

  appLinks.uriLinkStream.listen((Uri? uri) {
    if (uri != null && uri.scheme == 'zoomai') {
      final token = uri.queryParameters['token'];
      if (token != null) {
        ref.read(authProvider.notifier).login();
      }
    }
  });
}

  
void main() async {
  
  runApp(const ProviderScope(child: MyApp()));
}




class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Build tamamlandıktan sonra çalışsın
    WidgetsBinding.instance.addPostFrameCallback((_) {
      handleIncomingLinks(ref, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      locale: locale ?? WidgetsBinding.instance.platformDispatcher.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale("en", ""),
        Locale("tr", ""),
        Locale("de", ""),
        Locale("fr", ""),
      ],
      routerConfig: router,
    );
  }
}
