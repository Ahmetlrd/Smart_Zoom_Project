// Gerekli paketleri import ediyorum
import 'package:flutter/material.dart';
import 'package:flutter_app/features/home/utility.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Settings (Ayarlar) sayfası, kullanıcı giriş yaptıysa logout işlemi yapılabiliyor
class Settings extends ConsumerStatefulWidget {
  const Settings({super.key});

  @override
  ConsumerState<Settings> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<Settings> {
  // Dil seçenekleri listesi
  List<String> languages = ['English', 'Türkçe', 'Français', 'Deutsch'];
  String selectedLanguage = "English";

  // Bildirimler için switch kontrolü
  bool switchControl = true;

  @override
  Widget build(BuildContext context) {
    // Kullanıcının login olup olmadığını kontrol ediyorum
    final isLoggedIn = ref.watch(authProvider);

    return Scaffold(
      appBar: Utility.buildAppBar(context), // Üst app bar'ı utility dosyasından alıyorum
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            // 🔤 Dil seçimi dropdown
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

            // 🔔 Bildirimler switch butonu
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

            // 🚪 Kullanıcı giriş yaptıysa LOGOUT butonu
            if (isLoggedIn)
              ElevatedButton(
                onPressed: () async {
                  // local storage'dan isLoggedIn'i false yapıyorum
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', false);

                  // Riverpod state'i false yapıyorum (çıkış yapmış sayılıyor)
                  ref.read(authProvider.notifier).state = false;

                  // Kullanıcıyı login ekranına yönlendiriyorum
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
