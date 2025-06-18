import 'package:flutter/material.dart'; // Flutter's material design components
import 'package:flutter_app/features/home/utility.dart'; // Custom utility class (e.g., for building app bars)
import 'package:flutter_app/gen_l10n/app_localizations.dart'; // Custom utility functions (e.g., for app bars)
// A stateless widget that represents the meeting list page
class Meetinglist extends StatelessWidget {
  const Meetinglist({super.key}); // Constructor with optional key for widget identity

  @override
  Widget build(BuildContext context) {
    var d = AppLocalizations.of(context); // Loads localized strings based on current locale

    // Returns a Scaffold with a custom app bar. Body is currently empty.
    return Scaffold(
      appBar: Utility.buildAppBar(context), // Custom app bar from Utility class
    );
  }
}
