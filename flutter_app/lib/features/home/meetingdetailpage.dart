import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MeetingDetailPage extends StatelessWidget {
  MeetingDetailPage({super.key});
  var number = 10;
  @override
  Widget build(BuildContext context) {
    var d = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Meeting Details")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildOption(context, "👥 ${d!.participants}$number"),
            _buildOption(context, "📄 ${d!.transcription}$number"),
            _buildOption(context, "🧠 ${d!.summary}$number"),
            _buildOption(context, "📝 ${d!.notes}$number"),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Clicked: $label")));
        },
        child: Text(label, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
