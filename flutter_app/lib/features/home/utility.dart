import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Utility {
  static AppBar buildAppBar(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;

    return AppBar(
      title: Text(
        "Zoom Project",
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.settings,
            color: routeName == '/settings' ? Colors.grey[400] : Colors.white,
          ),
          onPressed:
              routeName == '/settings'
                  ? null
                  : () {
                    context.push('/settings');
                  },
        ),
      ],
      backgroundColor: Colors.blue,
    );
  }
}
