import 'package:flutter/material.dart';
import 'package:flutter_app/features/home/utility.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

String selectedLanguage = "English";
var switchControl = true;

class _SettingsState extends State<Settings> {
  List<String> languages = ['English', 'Türkçe', 'Français', 'Deutsch'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utility.buildAppBar(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                SizedBox(width: 50),

                Icon(Icons.language, size: 60),
                SizedBox(width: 20),

                Text("Language: ", style: TextStyle(fontSize: 20)),
                SizedBox(width: 35),

                SizedBox(
                  width: 100,
                  child: DropdownButton<String>(
                    value: selectedLanguage,
                    isExpanded: true,
                    items:
                        languages.map((lang) {
                          return DropdownMenuItem(
                            value: lang,
                            child: Text(lang),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedLanguage = value!;
                      });
                    },
                  ),
                ),

                SizedBox(width: 20),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 50),

                Icon(Icons.notifications, size: 60),
                SizedBox(width: 20),

                SizedBox(
                  width: 180,
                  child: Text("Notifications", style: TextStyle(fontSize: 20)),
                ),

                SizedBox(
                  width: 20,
                  child: SwitchListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: switchControl,
                    onChanged: (a) {
                      setState(() {
                        switchControl = a;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
