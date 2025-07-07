import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/providers/summary_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:flutter_app/gen_l10n/app_localizations.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/providers/folder_provider.dart';
import 'package:flutter_app/services/openai_service.dart';
import 'package:flutter_app/services/macos_folder_service.dart';
import 'package:flutter_app/services/zoom_permission_service.dart';
import 'package:flutter_app/services/secure_storage_service.dart';
import 'package:window_size/window_size.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedMeetingProvider = StateProvider<DocumentSnapshot?>((ref) => null);
final selectedTabProvider = StateProvider<String>((ref) => 'summary');

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _checkingZoomFolder = false;
  bool isLoading = false;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _searchController.addListener(() {
      ref.read(searchQueryProvider.notifier).state =
          _searchController.text.trim().toLowerCase();
    });
    if (Platform.isMacOS || Platform.isWindows) {
      setWindowMinSize(const Size(1000, 600));
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
      final isValid =
          await ZoomPermissionService.validateZoomFolder(folderPath);
      if (isValid) break;

      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Zoom Klasörü Gerekli"),
          content: const Text(
              "Lütfen Zoom klasörünü seçin. Bu klasör içinde .m4a dosyaları olmalıdır."),
          actions: [
            TextButton(
                child: const Text("Klasör Seç"),
                onPressed: () => Navigator.pop(context, true)),
          ],
        ),
      );

      if (result != true) break;
      final selected = await MacOSFolderService.selectFolderAndSaveBookmark();
      final isNowValid =
          await ZoomPermissionService.validateZoomFolder(selected);
      if (isNowValid) {
        ref.invalidate(zoomFolderProvider);
        break;
      }
    }

    _checkingZoomFolder = false;
  }

  @override
  Widget build(BuildContext context) {
    final d = AppLocalizations.of(context)!;
    final email = ref.watch(authProvider.notifier).userInfo?['email'];
    final selected = ref.watch(selectedMeetingProvider);
    final selectedTab = ref.watch(selectedTabProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        leadingWidth: 108,
        leading: Row(
          children: [
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () => context.push('/settings'),
            ),
          ],
        ),
        title: const Text("Smart Zoom",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
                color: Colors.white)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(selectedTabProvider.notifier).state = 'summary',
            style: TextButton.styleFrom(
              backgroundColor: selectedTab == 'summary'
                  ? Colors.indigo[900]
                  : Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            child: Text("Summary",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: selectedTab == 'summary'
                        ? FontWeight.bold
                        : FontWeight.normal)),
          ),
          TextButton(
            onPressed: () =>
                ref.read(selectedTabProvider.notifier).state = 'transcript',
            style: TextButton.styleFrom(
              backgroundColor: selectedTab == 'transcript'
                  ? Colors.indigo[900]
                  : Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            child: Text("Transcript",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: selectedTab == 'transcript'
                        ? FontWeight.bold
                        : FontWeight.normal)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: email == null
          ? const Center(child: Text("Giriş yapılmadı."))
          : Row(
              children: [
                Expanded(flex: 2, child: _buildMeetingList(email)),
                const VerticalDivider(width: 1),
                Expanded(flex: 4, child: _buildDetailPanel(context)),
              ],
            ),
    );
  }

  Widget _buildMeetingList(String email) {
    final selected = ref.watch(selectedMeetingProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Toplantı başlığı ara...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Consumer(builder: (context, ref, _) {
                final selected = ref.watch(selectedMeetingProvider);
                if (selected == null) return const SizedBox.shrink();
                return IconButton(
                  icon:
                      const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Toplantıyı sil"),
                        content: const Text(
                            "Bu toplantı kaydını silmek istediğinizden emin misiniz?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text("İptal"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text("Sil",
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await selected.reference.delete();
                      ref.invalidate(selectedMeetingProvider);
                    }
                  },
                );
              }),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('summaries')
                .doc(email)
                .collection('history')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final title = (data['title'] ?? '').toString().toLowerCase();
                return title.contains(searchQuery);
              }).toList();

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final title = data['title'] ?? 'Toplantı';
                  final isReviewed = data['isReviewed'] == true;
                  final timestampStr = data['timestamp'];
                  final timestamp =
                      DateTime.tryParse(timestampStr ?? '') ?? DateTime.now();
                  final formatted =
                      "${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}";
                  final ago = timeago.format(timestamp, locale: 'tr');
                  final isSelected = selected?.id == doc.id;

                  return ListTile(
                    tileColor: isSelected ? const Color.fromARGB(255, 195, 224, 245) : null,
                    title: Row(
                      children: [
                        Expanded(
                            child:
                                Text(title, overflow: TextOverflow.ellipsis)),
                        if (!isReviewed)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: CircleAvatar(
                                radius: 5, backgroundColor: Colors.red),
                          ),
                      ],
                    ),
                    subtitle: Text("$formatted ($ago)"),
                    onTap: () =>
                        ref.read(selectedMeetingProvider.notifier).state = doc,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailPanel(BuildContext context) {
    final d = AppLocalizations.of(context)!;
    final selected = ref.watch(selectedMeetingProvider);
    final selectedTab = ref.watch(selectedTabProvider);

    if (selected == null)
      return const Center(child: Text("Bir toplantı seçin."));

    return StreamBuilder<DocumentSnapshot>(
      stream: selected.reference.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final summary = data['text'] ?? '';
        final transcript = data['transcript'] ?? '';
        final isReviewed = data['isReviewed'] == true;

        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedTab == 'summary') ...[
                        Text(
                          summary.startsWith("Title:")
                              ? summary
                                  .split('\n')
                                  .first
                                  .replaceFirst("Title:", "")
                                  .trim()
                              : 'Başlıksız',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          summary.contains('\n')
                              ? summary
                                  .substring(summary.indexOf('\n') + 1)
                                  .trim()
                              : '',
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ] else
                        Text(
                          transcript,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (!isReviewed)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F7FC),
                  border:
                      Border(top: BorderSide(color: Colors.grey, width: 0.3)),
                ),
                child: Column(
                  children: [
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Center(
                          child: Text("Generating...",
                              style: TextStyle(color: Colors.blueAccent)),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            decoration: InputDecoration(
                              hintText:
                                  isLoading ? 'Generating...' : d.writeprompt,
                              border: const OutlineInputBorder(),
                              prefixIcon:
                                  const Icon(Icons.tips_and_updates_outlined),
                              suffixIcon: IconButton(
                                icon: isLoading
                                    ? const Icon(Icons.stop_circle_outlined,
                                        color: Colors.blueAccent)
                                    : Icon(
                                        _controller.text.trim().isNotEmpty
                                            ? Icons.arrow_circle_up
                                            : Icons.arrow_circle_up_outlined,
                                        color:
                                            _controller.text.trim().isNotEmpty
                                                ? Colors.blueAccent
                                                : Colors.grey,
                                      ),
                                onPressed: (!isLoading &&
                                        _controller.text.trim().isNotEmpty)
                                    ? _handlePromptSubmission
                                    : null,
                              ),
                            ),
                            onSubmitted: (_) {
                              if (_controller.text.trim().isNotEmpty) {
                                _handlePromptSubmission();
                              }
                            },
                            minLines: 1,
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) {
                                return AlertDialog(
                                  title: Text(d.wannasave),
                                  content: Text(d.savetofirestore),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext)
                                              .pop(false),
                                      child: Text(d.cancel),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(true),
                                      child: Text(d.save),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm != true) return;

                            final newSummary = ref.read(summaryProvider);
                            await selected.reference.update({
                              'text': newSummary,
                              'isReviewed': true,
                            });
                            ref.invalidate(selectedMeetingProvider);
                          },
                          icon: const Icon(Icons.save_alt),
                          label: Text(d.save),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  void _handlePromptSubmission() async {
    final selected = ref.read(selectedMeetingProvider);
    if (selected == null || _controller.text.trim().isEmpty) return;

    final data = selected.data() as Map<String, dynamic>;
    final summary = data['text'] ?? '';
    final transcript = data['transcript'] ?? '';

    setState(() => isLoading = true);

    final prompt = """
Aşağıdaki Zoom toplantısı transkriptine göre yeni bir özet oluştur.

İlk olarak transkripti analiz ederek bir başlık üret. Bu başlık şu kurala uygun olmalı:
- Sadece 1 satır
- \"Title: \" ile başlamalı
- Maksimum 5 kelime
- Tırnak kullanılmamalı

Sonrasında, başlık satırının altına toplantının içeriğini kullanıcı isteğine göre yeniden özetle. Bu özet:
- Bilgi odaklı ve kısa olmalı
- Gündemi ve önemli kararları içermeli
- Kullanıcının talebine uygun olmalı

TRANSKRİPT:
$transcript

ÖNCEKİ ÖZET:
$summary

KULLANICININ YENİ İSTEĞİ:
\"${_controller.text}\"

Çıktı formatın şuna benzemeli:

Title: Pazarlama Toplantısı Özeti

Görüşmede, yeni dijital stratejilerin...
""";

    final service = OpenAIService();
    final newSummary = await service.summarizeText(prompt);

    if (newSummary != null) {
  String title = 'Başlıksız';
  try {
    final lines = newSummary.split('\n');
    final titleLine = lines.firstWhere(
      (line) => line.toLowerCase().contains('title:'),
      orElse: () => '',
    );

    if (titleLine.isNotEmpty) {
      title = titleLine.split(':').sublist(1).join(':').trim();
      title = title.replaceAll(RegExp(r'^["“”]+|["“”]+$'), '');
    }
  } catch (e) {
    print('⚠️ Başlık ayrıştırılamadı: $e');
  }

  await selected.reference.update({
    'title': title,
    'text': newSummary,
    'isReviewed': false,
  });
}


    setState(() => isLoading = false);
    _controller.clear();
    _focusNode.unfocus();
  }
}
