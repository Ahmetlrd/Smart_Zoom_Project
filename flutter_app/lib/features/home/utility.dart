import 'package:flutter/material.dart'; // Flutter UI components
import 'package:go_router/go_router.dart'; // Navigation and routing
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Localization (not used here, but imported)

// Utility class for reusable UI components
class Utility {
  // Static method that returns a customized AppBar widget
  static AppBar buildAppBar(BuildContext context) {
    // Get the current route name to conditionally style the settings icon
    final routeName = ModalRoute.of(context)?.settings.name;

    // Screen width is used to adjust font and icon size responsively
    final screenWidth = MediaQuery.of(context).size.width;
    final titleFontSize =
        screenWidth * 0.07; // Responsive font size (e.g., 40 at 570px)
    final settingsIconSize =
        screenWidth * 0.07; // Icon size adjusts with screen width

    return AppBar(
      centerTitle: true, // Center the title text
      title: Text(
        "Zoom Project", // Fixed title text
        style: TextStyle(
          fontSize: titleFontSize, // Dynamic font size based on screen width
          fontWeight: FontWeight.bold, // Bold text
          color: Colors.white, // White color text
        ),
      ),
      actions: [
        // Settings icon on the right of the AppBar
        IconButton(
          icon: Icon(
            Icons.settings,
            size: settingsIconSize, // Dynamic icon size
            // If the current route is /settings, show the icon in grey (disabled)
            color: (routeName == '/settings' || routeName == '/userinfo') ? Colors.grey[400] : Colors.white,
          ),
          onPressed: (routeName == '/settings' || routeName == '/userinfo')
              ? null
              : () {
                  context.push('/settings');
                },
        ),
      ],
      backgroundColor: Colors.blue, // AppBar background color
    );
  }
}
