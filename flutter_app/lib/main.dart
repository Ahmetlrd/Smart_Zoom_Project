import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/firebase_options.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/providers/locale_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_app/gen_l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_app/services/notifications_service.dart';
import 'package:flutter/services.dart';
import 'routes.dart';

Future<void> handleIncomingLinks(WidgetRef ref) async {
  final router = ref.read(routerProvider);

  if (Platform.isAndroid || Platform.isIOS) {
    final appLinks = AppLinks();
    appLinks.uriLinkStream.listen((Uri? uri) async {
      if (uri != null && uri.scheme == 'zoomai') {
        final token = uri.queryParameters['token'];
        final refresh = uri.queryParameters['refresh_token'];
        if (token != null) {
          await ref.read(authProvider.notifier).loginWithToken(token, refreshToken: refresh);
          router.go('/home');
        }
      }
    });
  } else if (Platform.isMacOS) {
    const MethodChannel channel = MethodChannel('deep_link_channel');
    channel.setMethodCallHandler((call) async {
      debugPrint('🔥 MethodChannel called with: ${call.arguments}');

      if (call.method == 'incomingLink') {
        final uri = Uri.tryParse(call.arguments as String? ?? '');
        debugPrint('✅ Parsed URI: $uri');

        if (uri != null && uri.scheme == 'zoomai') {
          final token = uri.queryParameters['token'];
          final refresh = uri.queryParameters['refresh_token'];
          debugPrint('🔐 Extracted token: $token');

          if (token != null) {
            await ref.read(authProvider.notifier).loginWithToken(token, refreshToken: refresh);
            router.go('/home');
          }
        }
      }

      return null;
    });
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  await NotificationService.init();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() => handleIncomingLinks(ref)); // ← güvenli
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
