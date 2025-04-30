import 'package:flutter/material.dart'; // Core Flutter UI components (widgets, themes, etc.)
import 'package:flutter_app/features/home/utility.dart'; // Custom utility functions like building app bar
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod for state management
import 'package:go_router/go_router.dart'; // GoRouter for managing navigation and routing
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Generated localization class for multi-language support

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get localized strings for the current locale
    var d = AppLocalizations.of(context);

    return Scaffold(
      // Use a custom app bar from Utility
      appBar: Utility.buildAppBar(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            shrinkWrap: true, // Only take as much height as needed
            crossAxisCount: 2, // 2 columns in the grid
            crossAxisSpacing: 16, // Horizontal spacing between items
            mainAxisSpacing: 16, // Vertical spacing between items
            children: [
              // Card for "Meeting List"
              _buildCard(
                icon: Icons.calendar_today,
                label: d!.meetinglist,
                onTap: () => context.push('/meetinglist'),
              ),
              // Card for "Meeting Details"
              _buildCard(
                icon: Icons.connect_without_contact,
                label: d.meetingdetails,
                onTap: () => context.push('/meetingdetailpage'),
              ),
              // Card for "NLP Summary"
              _buildCard(
                icon: Icons.auto_awesome,
                label: d.nlpsummary,
                onTap: () => context.push('/nlp'),
              ),
              // Card for "Saved Summaries"
              _buildCard(
                icon: Icons.note,
                label: d.saved,
                onTap: () => context.push('/saved'),
              ),
            ],
          ),
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
      onTap: onTap, // Handle tap interaction
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Rounded corners
        ),
        elevation: 4, // Shadow effect
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Colors.blue),
              const SizedBox(height: 12),
              Text(label, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
