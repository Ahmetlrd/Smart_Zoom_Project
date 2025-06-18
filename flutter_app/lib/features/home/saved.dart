import 'package:flutter/material.dart'; // Flutter's core UI toolkit
import 'package:flutter_app/features/home/utility.dart'; // Utility class for shared UI components like AppBar
import 'package:flutter_app/gen_l10n/app_localizations.dart'; // Custom utility functions (e.g., for app bars)
// A stateless widget representing the Saved Summaries page
class Saved extends StatelessWidget {
  const Saved({super.key}); // Constructor with optional key

  @override
  Widget build(BuildContext context) {
    var d = AppLocalizations.of(context); // Access localized text for the current language

    // Returns a simple scaffold with a custom app bar (no body content yet)
    return Scaffold(
      appBar: Utility.buildAppBar(context), // App bar defined in Utility class
    );
  }
}
