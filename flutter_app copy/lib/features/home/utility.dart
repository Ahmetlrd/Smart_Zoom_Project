import 'package:flutter/material.dart'; // Flutter UI components
import 'package:go_router/go_router.dart'; // Navigation and routing
import 'package:flutter_app/gen_l10n/app_localizations.dart'; // Custom utility functions (e.g., for app bars)

// Utility class for reusable UI components
class Utility {
  // Static method that returns a customized AppBar widget
  static AppBar buildAppBar(BuildContext context,
      {bool disableSettings = false}) {
    final routeName = ModalRoute.of(context)?.settings.name;
    final screenWidth = MediaQuery.of(context).size.width;

    final titleFontSize = screenWidth.clamp(400, 1000) / 25;
    final iconSize = screenWidth.clamp(400, 1000) / 30;

    return AppBar(
      centerTitle: true,
      elevation: 3,
      backgroundColor: Colors.blueAccent,
      title: Text(
        "Smart Zoom",
        style: TextStyle(
          fontSize: titleFontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
          color: Colors.white,
        ),
      ),
      actions: disableSettings
          ? []
          : [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: IconButton(
                  icon: Icon(
                    Icons.settings_outlined,
                    size: iconSize,
                    color:
                        (routeName == '/settings' || routeName == '/userinfo')
                            ? Colors.grey[300]
                            : Colors.white,
                  ),
                  tooltip: 'Ayarlar',
                  onPressed:
                      (routeName == '/settings' || routeName == '/userinfo')
                          ? null
                          : () => context.push('/settings'),
                ),
              ),
            ],
    );
  }
}
