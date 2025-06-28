import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  final String _apiKey = dotenv.env['smartZoomOpenAIKey'] ?? '';

  Future<String?> summarizeText(String text) async {
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-4",
        "messages": [
          {
            "role": "system",
            "content": "You are a helpful assistant that summarizes transcripts."
          },
          {
            "role": "user",
            "content": "Please summarize this meeting transcript in turkish :\n$text"
          }
        ],
        "temperature": 0.5,
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded["choices"][0]["message"]["content"];
    } else {
      print("OpenAI error: ${response.body}");
      return null;
    }
  }
}
