import 'package:flutter/material.dart'; // Flutter UI components
import 'package:go_router/go_router.dart'; // Navigation and routing
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Localization (not used here, but imported)

// Utility class for reusable UI components
class Utility {
  // Static method that returns a customized AppBar widget
  static AppBar buildAppBar(BuildContext context) {
    // Get the current route name to conditionally style the settings icon
    final routeName = ModalRoute.of(context)?.settings.name;

    return AppBar(
      centerTitle: true, // Center the title text
      title: Text(
        "Zoom Project", // Fixed title text
        style: TextStyle(
          fontSize: 40, // Large font size
          fontWeight: FontWeight.bold, // Bold text
          color: Colors.white, // White color text
        ),
      ),
      actions: [
        // Settings icon on the right of the AppBar
        IconButton(
          icon: Icon(
            Icons.settings,
            // If the current route is /settings, show the icon in grey (disabled)
            color: routeName == '/settings' ? Colors.grey[400] : Colors.white,
          ),
          onPressed: routeName == '/settings'
              ? null // Disable if already on settings page
              : () {
                  context.push('/settings'); // Navigate to settings page
                },
        ),
      ],
      backgroundColor: Colors.blue, // AppBar background color
    );
  }
}
