import 'package:flutter/material.dart';
import 'package:flutter_app/features/home/utility.dart';
import 'package:flutter_app/services/zoom_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final crossAxisCount = screenWidth < 600 ? 2 : 4;

    return Scaffold(
      appBar: Utility.buildAppBar(context),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          children: [
            // GRID
            Expanded(
              child: GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: screenWidth / (screenHeight / 2),
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

            // BUTTON
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final userData = await ZoomService.fetchUserInfo();
                  print("Kullanıcı Bilgisi:");
                  print(userData);
                },
                icon: const Icon(Icons.person),
                label: const Text(
                  "Fetch User Info",
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blueAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable method to build a card with an icon and a label
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
