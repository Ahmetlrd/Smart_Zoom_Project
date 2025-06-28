import 'package:flutter/material.dart';
import 'package:flutter_app/services/openai_service.dart';

class Nlp extends StatefulWidget {
  const Nlp({super.key});

  @override
  State<Nlp> createState() => _NlpState();
}

class _NlpState extends State<Nlp> {
  final _openAI = OpenAIService(); // .env’den alacak
  String _summary = '';
  bool _isLoading = false;

  void _summarizeText() async {
    setState(() {
      _isLoading = true;
    });

    const transcript = '''
    denemek için bir transkript örneği yazıldı sonrasında recording örneği eklenecek
  
    ''';

    final result = await _openAI.summarizeText(transcript);

    setState(() {
      _summary = result ?? 'No summary could be generated.';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("NLP Summary")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _summarizeText,
              child: const Text("Generate Summary"),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Text(
                    _summary,
                    style: const TextStyle(fontSize: 16),
                  ),
          ],
        ),
      ),
    );
  }
}
