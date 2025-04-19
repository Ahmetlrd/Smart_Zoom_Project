import 'package:flutter/material.dart';
import 'package:flutter_app/features/home/utility.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/providers/auth_provider.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({super.key});

  @override
  ConsumerState<Settings> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<Settings> {
  List<String> languages = ['English', 'Türkçe', 'Français', 'Deutsch'];
  String selectedLanguage = "English";
  bool switchControl = true;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(authProvider);

    return Scaffold(
      appBar: Utility.buildAppBar(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Dil Seçimi
            Row(
              children: [
                const SizedBox(width: 50),
                const Icon(Icons.language, size: 60),
                const SizedBox(width: 20),
                const Text("Language: ", style: TextStyle(fontSize: 20)),
                const SizedBox(width: 35),
                SizedBox(
                  width: 120,
                  child: DropdownButton<String>(
                    value: selectedLanguage,
                    isExpanded: true,
                    items: languages
                        .map((lang) => DropdownMenuItem(
                              value: lang,
                              child: Text(lang),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedLanguage = value!;
                      });
                    },
                  ),
                ),
              ],
            ),

            // Bildirimler
            Row(
              children: [
                const SizedBox(width: 50),
                const Icon(Icons.notifications, size: 60),
                const SizedBox(width: 20),
                const SizedBox(
                  width: 180,
                  child: Text("Notifications", style: TextStyle(fontSize: 20)),
                ),
                Switch(
                  value: switchControl,
                  onChanged: (val) {
                    setState(() {
                      switchControl = val;
                    });
                  },
                ),
              ],
            ),

            // Logout Butonu
            if (isLoggedIn)
              ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', false);
                  ref.read(authProvider.notifier).state = false;
                  context.go('/login');
                },
                child: const Text('LOGOUT'),
              ),
          ],
        ),
      ),
    );
  }
}
