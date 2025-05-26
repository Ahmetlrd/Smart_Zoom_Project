import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SummaryPromptPage extends StatefulWidget {
  @override
  _SummaryPromptPageState createState() => _SummaryPromptPageState();
}

class _SummaryPromptPageState extends State<SummaryPromptPage> {
  bool alwaysSave = false;

  void handleChoice(bool save) {
    if (save) {
      // Özeti başlat ve Firestore’a kaydet
    }
    if (alwaysSave) {
      // Firebase'e işaretle → tekrar sorma
      sendFollowUpNotification();
    }
    Navigator.pop(context);
  }

  void sendFollowUpNotification() {
    FlutterLocalNotificationsPlugin().show(
      1,
      "Tamamdır!",
      "Toplantıya girdiniz gibi görünüyor, özeti bitince çıkaracağım.",
      const NotificationDetails(
        android: AndroidNotificationDetails('zoomai_channel', 'ZoomAI'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Özet çıkarılsın mı?")),
      body: Column(
        children: [
          Text("Bu toplantıya katıldınız, sizin için özet çıkaralım mı?"),
          CheckboxListTile(
            title: Text("Her zaman otomatik çıkar"),
            value: alwaysSave,
            onChanged: (val) => setState(() => alwaysSave = val!),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: () => handleChoice(true), child: Text("Kaydet")),
              OutlinedButton(onPressed: () => handleChoice(false), child: Text("Kaydetme")),
            ],
          )
        ],
      ),
    );
  }
}
