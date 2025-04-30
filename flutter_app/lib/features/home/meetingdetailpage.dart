import 'package:flutter/material.dart'; // Core Flutter UI library
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Localization helper (auto-generated from .arb files)

// A stateless widget to display meeting details
class MeetingDetailPage extends StatelessWidget {
  MeetingDetailPage({super.key});
  
  // Example static number, used for demonstration in button labels
  var number = 10;

  @override
  Widget build(BuildContext context) {
    // Access the localization instance for the current context
    var d = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Meeting Details")), // Top app bar with title
      body: Padding(
        padding: const EdgeInsets.all(24.0), // Adds spacing around the content
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Vertically centers the children
          children: [
            // Four buttons with localized labels and emoji
            _buildOption(context, "👥 ${d!.participants}$number"),
            _buildOption(context, "📄 ${d.transcription}$number"),
            _buildOption(context, "🧠 ${d.summary}$number"),
            _buildOption(context, "📝 ${d.notes}$number"),
          ],
        ),
      ),
    );
  }

  // A reusable function that creates an elevated button with given label
  Widget _buildOption(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0), // Adds vertical spacing between buttons
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)), // Full-width button
        onPressed: () {
          // Shows a small notification at the bottom when button is clicked
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Clicked: $label")),
          );
        },
        child: Text(label, style: const TextStyle(fontSize: 18)), // Button label style
      ),
    );
  }
}
