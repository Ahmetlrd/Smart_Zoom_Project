import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/firebase_options.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/providers/locale_provider.dart';
import 'package:flutter_app/services/secure_storage_service.dart' as SecureStorageService;
import 'package:flutter_app/services/zoom_recording_helper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_app/gen_l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_app/services/notifications_service.dart';
import 'package:flutter/services.dart';
import 'routes.dart';

Future<void> handleIncomingLinks(WidgetRef ref, BuildContext context) async {
  final appLinks = AppLinks();

  // AppLinks ile gelen bağlantılar
  appLinks.uriLinkStream.listen((Uri? uri) async {
    debugPrint("🔗 URI from stream: $uri");
    if (uri != null) await _processZoomUri(uri, ref, context);
  });

  // macOS için MethodChannel üzerinden gelen linkler
  if (Platform.isMacOS) {
    const MethodChannel('app.channel.shared.data')
        .setMethodCallHandler((call) async {
      if (call.method == "deep-link") {
        final uri = Uri.tryParse(call.arguments);
        debugPrint("🧭 macOS deep-link yakalandı: $uri");
        if (uri != null) await _processZoomUri(uri, ref, context);
      }
    });
  }
}
Future<void> _processZoomUri(Uri uri, WidgetRef ref, BuildContext context) async {
  if (uri.scheme == 'zoomai') {
    final jwt = uri.queryParameters['token'];
    final accessToken = uri.queryParameters['access_token'];
    final refreshToken = uri.queryParameters['refresh_token'];

    debugPrint('🪪 JWT: $jwt');
    debugPrint('🔐 Access Token: $accessToken');
    debugPrint('🔁 Refresh Token: $refreshToken');

    if (accessToken != null) {
      await SecureStorageService.saveAccessToken(accessToken);
      if (refreshToken != null) {
        await SecureStorageService.saveRefreshToken(refreshToken);
      }

      await ref.read(authProvider.notifier).loginWithToken(accessToken);
      ref.read(routerProvider).go('/home');
    } else {
      debugPrint('❌ Access token eksik');
    }
  }
}





void main() async {
  watchZoomFolder();
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

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  bool _listenerAttached = false;

  @override
  
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // İlk açılışta test bildirimi
    NotificationService.show(
      title: 'uygulama ilk açıldı test bildirimi',
      body: 'Notification permission working!',
    );

    _attachLinkListenerOnce(); // İlk açılışta listener
  }

  void _attachLinkListenerOnce() {
    if (!_listenerAttached) {
      debugPrint('🧲 AppLinks listener attached (init)');
      handleIncomingLinks(ref,context);
      _listenerAttached = true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('🚀 App resumed – checking deep links again');
      handleIncomingLinks(ref,context); // Yeniden bağla
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

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
