import 'dart:convert';
import 'dart:io';
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
            "content":
                "You are a helpful assistant that summarizes transcripts."
          },
          {
            "role": "user",
            "content": """
Aşağıda bir Zoom toplantısının transkripti bulunmaktadır.
ilk 3 kelimesi benim için önemli o yüzden (3 kelimelik özet) olarak başla.

Bu transkripti incele ve toplantının içeriğini profesyonelce özetle.  
Kullanıcı bu özeti okuduğunda toplantıya katılmadan ne konuşulduğunu net şekilde anlayabilsin. Toplantıyı tekrar izlemeye ihtiyaç duymasın.

Özette şu başlıkları mutlaka ele al:

- Toplantının amacı ve ana gündemi
- Konuşan kişi(ler) kimlerdi? (isim varsa belirt)
- Görüşülen önemli konular, sorunlar, fikirler
- Alınan kararlar ve varılan sonuçlar
- Eylem maddeleri (kim, ne zaman, ne yapacak)
- Dikkat çeken ifadeler veya önemli vurgular

Özeti Türkçe yaz ve sade, akıcı paragraflarla sun.  
Maddeleme gerekiyorsa yap ama yapay hissettirmesin.  
Bilgi eksikse "bilgi eksik" deme, olanı özetle.

TRANSKRİPT:
$text
"""
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

  Future<String?> transcribeAudio(File audioFile, {String? forceLanguage}) async {
  final url = Uri.parse("https://api.openai.com/v1/audio/transcriptions");

  final request = http.MultipartRequest('POST', url)
    ..headers['Authorization'] = 'Bearer $_apiKey'
    ..fields['model'] = 'whisper-1'
    ..fields['response_format'] = 'verbose_json'
    ..files.add(await http.MultipartFile.fromPath('file', audioFile.path));

  // 🔁 Eğer kullanıcı dili zorla vermek istiyorsa, uygula
  if (forceLanguage != null) {
    request.fields['language'] = forceLanguage;
  }

  final response = await request.send();

  if (response.statusCode == 200) {
    final responseBody = await response.stream.bytesToString();
    final json = jsonDecode(responseBody);
    print("🗣️ Whisper algıladığı dil: ${json['language']}");
    return json['text'];
  } else {
    final error = await response.stream.bytesToString();
    print("Whisper API error: $error");
    return null;
  }
}


}
