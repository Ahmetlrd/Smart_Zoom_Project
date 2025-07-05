import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/features/home/utility.dart';
import 'package:flutter_app/gen_l10n/app_localizations.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/services/macos_folder_service.dart';
import 'package:flutter_app/services/secure_storage_service.dart' as SecureStorageService;
import 'package:flutter_app/services/zoom_permission_service.dart';
import 'package:flutter_app/providers/folder_provider.dart';
import 'package:flutter_app/services/notifications_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:window_size/window_size.dart';
import 'package:flutter_app/providers/summary_provider.dart';

enum SummaryPreference { always, once, never }

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
  SummaryPreference summaryPreference = SummaryPreference.once;
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
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 1 : screenWidth < 1000 ? 2 : 3;

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

            final List<Widget> cards = [
              _buildCard(
                icon: Icons.calendar_today,
                label: d!.meetinglist,
                onTap: () => context.push('/meetinglist'),
              ),
            ];

            if (summary != null && summary.trim().isNotEmpty) {
              cards.add(
                _buildCard(
                  icon: Icons.auto_awesome,
                  label: d.nlpsummary,
                  onTap: () => context.push('/nlp'),
                ),
              );
            }

            return Scaffold(
              appBar: Utility.buildAppBar(context),
              body: Container(
                color: const Color(0xFFF7F7FC),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: GridView.count(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 32,
                      crossAxisSpacing: 32,
                      childAspectRatio: 1,
                      children: cards,
                    ),
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
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.blueAccent),
              const SizedBox(height: 20),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
