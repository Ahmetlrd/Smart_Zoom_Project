import 'package:flutter/material.dart'; // Flutter's material design library
import 'package:flutter_app/features/home/utility.dart'; // Custom utility functions (e.g., for app bars)
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Localization support for multi-language strings

// A stateless widget representing the NLP (Natural Language Processing) page
class Nlp extends StatelessWidget {
  const Nlp({super.key}); // Constructor with optional widget key

  @override
  Widget build(BuildContext context) {
    var d = AppLocalizations.of(context); // Loads localized text resources for the current locale

    // Returns a page layout with just a custom app bar for now
    return Scaffold(
      appBar: Utility.buildAppBar(context), // Custom app bar created using Utility class
    );
  }
}
