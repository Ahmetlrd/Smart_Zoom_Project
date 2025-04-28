import 'package:flutter/material.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/providers/locale_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> handleIncomingLinks(WidgetRef ref, BuildContext context) async {
  uriLinkStream.listen((Uri? uri) {
    if (uri != null && uri.scheme == 'zoomai') {
      final token = uri.queryParameters['token'];
      if (token != null) {
        ref.read(authProvider.notifier).loginWithToken(token);
        context.go('/home'); // başarılı login sonrası yönlendirme
      }
    }
  });
}

void listenForZoomCallback(WidgetRef ref) {
  uriLinkStream.listen((Uri? uri) {
    if (uri != null && uri.scheme == 'zoomai') {
      final token = uri.queryParameters['token'];
      if (token != null) {
        // ✅ Burada login() veya token saklama işlemini yap
        ref.read(authProvider.notifier).login();
      }
    }
  });
}

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Uygulama açıldığında linkleri dinle
    handleIncomingLinks(ref, context);

    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const[
          Locale("en",""),
          Locale("tr",""),
          Locale("de",""),
          Locale("fr",""),
        ],
      routerConfig: router,
    );
  }
}
