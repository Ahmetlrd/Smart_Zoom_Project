import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/features/home/utility.dart';
import 'package:flutter_app/services/openai_service.dart';
import 'package:flutter_app/services/secure_storage_service.dart'
    as SecureStorageService;
import 'package:flutter_app/services/zoom_recording_helper.dart';
import 'package:flutter_app/services/zoom_service.dart';
import 'package:flutter_app/services/notifications_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/gen_l10n/app_localizations.dart';
import 'dart:io';
import 'package:flutter_app/services/zoom_permission_service.dart';
import 'package:window_size/window_size.dart';

enum SummaryPreference { always, once, never }

final meetingStatusProvider =
    StreamProvider.family<bool, String>((ref, userEmail) {
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

  @override
  void initState() {
    super.initState();
    if (Platform.isMacOS || Platform.isWindows) {
      setWindowMinSize(const Size(800, 600));
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final crossAxisCount = screenWidth < 600 ? 2 : 4;

    return FutureBuilder<String?>(
      future: SecureStorageService.readUserEmail(),
      builder: (context, snapshot) {
        final userEmail = snapshot.data;
        if (userEmail == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final meetingStatusAsync = ref.watch(meetingStatusProvider(userEmail));

        return meetingStatusAsync.when(
          data: (isJoined) {
            if (!isJoined) {
              _hasNotified = false;
            }

            if (isJoined && Platform.isMacOS && !_hasNotified) {
              NotificationService.show(
                title: "Toplantıya Katıldınız",
                body: "Özet çıkarmak ister misiniz?",
              );
              _hasNotified = true;
            }

            return Scaffold(
                    appBar: Utility.buildAppBar(context), // Adds a custom top app bar

              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: Column(
                      children: [
                        if (isJoined)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Card(
                              elevation: 6,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    const Text(
                                      "Şu an toplantıdasın!",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "Özet Tercihi: ${_preferenceLabel(summaryPreference)}",
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      onPressed: () => _showSummaryOptions(context),
                                      icon: const Icon(Icons.edit),
                                      label: const Text("Tercihi Değiştir"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                            childAspectRatio: 0.9,
                            children: [
                              _buildCard(
                                icon: Icons.calendar_today,
                                label: d!.meetinglist,
                                onTap: () => context.push('/meetinglist'),
                              ),
                              _buildCard(
                                icon: Icons.connect_without_contact,
                                label: d.meetingdetails,
                                onTap: () => context.push('/meetingdetailpage'),
                              ),
                              _buildCard(
                                icon: Icons.auto_awesome,
                                label: d.nlpsummary,
                                onTap: () => context.push('/nlp'),
                              ),
                              _buildCard(
                                icon: Icons.note,
                                label: d.saved,
                                onTap: () => context.push('/saved'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.person, color: Colors.grey),
                              tooltip: "Fetch User Info",
                              onPressed: () async {
                                final token = await SecureStorageService.readAccessToken();
                                final userData = await ZoomService.fetchUserInfoWithToken(token!);
                                print("Kullanıcı Bilgisi:");
                                print(userData);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.play_circle, color: Colors.grey),
                              tooltip: "Zoom (otomatik path) ile özetle",
                              onPressed: runDirectZoomSummaryFlow,
                            ),
                            IconButton(
                              icon: const Icon(Icons.folder_open, color: Colors.grey),
                              tooltip: "Zoom ses klasörünü gör",
                              onPressed: () async {
                                final zoomPath = await ZoomPermissionService.getValidZoomPathOrReselectIfNeeded();
                                if (zoomPath == null) {
                                  print("⚠️ Zoom klasörününe erişim sağlanamadı.");
                                  return;
                                }
                                final files = Directory(zoomPath)
                                    .listSync()
                                    .whereType<File>()
                                    .where((f) => f.path.endsWith('.m4a'))
                                    .toList();
                                if (files.isEmpty) {
                                  print("❌ Hiç .m4a dosyası bulunamadı.");
                                } else {
                                  print("✅ İlk ses dosyası: ${files.first.path}");
                                }
                              },
                            ),
                          ],
                        ),
                      ],
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

  String _preferenceLabel(SummaryPreference pref) {
    switch (pref) {
      case SummaryPreference.always:
        return "Her zaman çıkar";
      case SummaryPreference.once:
        return "Bu seferlik çıkar";
      case SummaryPreference.never:
        return "Bu seferlik çıkarma";
    }
  }

  void _showSummaryOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Her zaman özet çıkar"),
              onTap: () {
                setState(() => summaryPreference = SummaryPreference.always);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Yalnızca bu seferlik özet çıkar"),
              onTap: () {
                setState(() => summaryPreference = SummaryPreference.once);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Bu seferlik çıkarma"),
              onTap: () {
                setState(() => summaryPreference = SummaryPreference.never);
                Navigator.pop(context);
              },
            ),
          ],
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.blue),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
