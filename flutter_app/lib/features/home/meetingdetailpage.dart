import 'package:flutter/material.dart';

class MeetingDetailPage extends StatelessWidget {
  const MeetingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meeting Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildOption(context, "👥 Participants"),
            _buildOption(context, "📄 Transcription"),
            _buildOption(context, "🧠 Summary (AI)"),
            _buildOption(context, "📝 Notes"),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Clicked: $label")),
          );
        },
        child: Text(label, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
