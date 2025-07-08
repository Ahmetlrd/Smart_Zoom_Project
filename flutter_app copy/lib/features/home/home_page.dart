import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/features/home/utility.dart';
import 'package:flutter_app/gen_l10n/app_localizations.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/services/macos_folder_service.dart';
import 'package:flutter_app/services/secure_storage_service.dart' as SecureStorageService;
import 'package:flutter_app/services/zoom_permission_service.dart';
import 'package:flutter_app/services/notifications_service.dart';
import 'package:flutter_app/providers/folder_provider.dart';
import 'package:flutter_app/providers/summary_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:window_size/window_size.dart';

final meetingStatusProvider = StreamProvider.family<bool, String>((ref, userEmail) {
  final userId = userEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
  final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
  return docRef.snapshots().map((doc) {
    final data = doc.data();
    if (data == null) return false;
    final meetingStatus = data['meetingStatus'] as Map<String, dynamic>?;
    return meetingStatus?['isJoined'] == true;
  });
});

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _hasNotified = false;
  bool _checkingZoomFolder = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isMacOS || Platform.isWindows) {
      setWindowMinSize(const Size(800, 600));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkZoomFolderPermission();
    });
  }

  Future<void> _checkZoomFolderPermission() async {
    if (_checkingZoomFolder) return;
    _checkingZoomFolder = true;

    while (Platform.isMacOS && mounted) {
      final folderPath = await MacOSFolderService.getSavedFolder();
      final isValid = await ZoomPermissionService.validateZoomFolder(folderPath);

      if (isValid) {
        print("✅ Geçerli Zoom klasörü bulundu: $folderPath");
        break;
      }

      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Zoom Klasörü Gerekli"),
          content: const Text(
            "Toplantı ses kayıtlarını analiz edebilmemiz için Zoom'un ses kayıtlarını tuttuğu klasöre erişmemiz gerekiyor.\n\n"
            "Lütfen 'Zoom' adındaki klasörü seçin. Bu klasör içinde .m4a uzantılı ses dosyalarının bulunduğu alt klasörler yer almalıdır.",
          ),
          actions: [
            TextButton(
              child: const Text("Klasör Seç"),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );

      if (result != true) break;

      final selected = await MacOSFolderService.selectFolderAndSaveBookmark();
      final isNowValid = await ZoomPermissionService.validateZoomFolder(selected);

      if (isNowValid) {
        ref.invalidate(zoomFolderProvider);
        break;
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    _checkingZoomFolder = false;
  }

  @override
  Widget build(BuildContext context) {
    final d = AppLocalizations.of(context);
    final summary = ref.watch(summaryProvider);

    return FutureBuilder<String?>(
      future: SecureStorageService.readUserEmail(),
      builder: (context, snapshot) {
        final userEmail = snapshot.data;
        if (userEmail == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final meetingStatusAsync = ref.watch(meetingStatusProvider(userEmail));

        return meetingStatusAsync.when(
          data: (isJoined) {
            if (!isJoined) _hasNotified = false;

            if (isJoined && Platform.isMacOS && !_hasNotified) {
              NotificationService.show(
                title: d!.joinedmeeting,
                body: d.wannapsummarize,
              );
              _hasNotified = true;
            }

            return Scaffold(
              appBar: Utility.buildAppBar(context),
              backgroundColor: const Color(0xFFF7F7FC),
              body: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  child: Row(
                    key: ValueKey(summary != null && summary.trim().isNotEmpty),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCard(
                        icon: Icons.calendar_today,
                        label: d!.meetinglist,
                        onTap: () => context.push('/meetinglist'),
                      ),
                      if (summary != null && summary.trim().isNotEmpty)
                        const SizedBox(width: 24),
                      if (summary != null && summary.trim().isNotEmpty)
                        _buildCard(
                          icon: Icons.auto_awesome,
                          label: d.nlpsummary,
                          onTap: () => context.push('/nlp'),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, st) => Scaffold(body: Center(child: Text("Meeting status error: $e"))),
        );
      },
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(12),
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blueAccent),
            const SizedBox(height: 20),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
