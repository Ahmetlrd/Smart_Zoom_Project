import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

class OpenAIService {
  final String _apiKey = dotenv.env['smartZoomOpenAIKey'] ?? '';

  Future<String?> summarizeText(String text, Locale locale) async {
    final prompt = _generatePrompt(locale.languageCode, text);
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
            "content": prompt,
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

  String _generatePrompt(String lang, String transcript) {
    switch (lang) {
      case 'en':
        return "Your task has two parts:\n\n1. **Generate a meeting title**: Analyze the transcript below and generate a concise, meaningful title of no more than 5 words. Return it in this exact format:\nTitle: Your Title Here\n\n2. **Generate a meeting summary**: The transcript below consists of segments from multiple audio recordings of a Zoom meeting. Each line or paragraph may represent a different part of the discussion. Your task is to combine these parts into a coherent and clear summary.\n\nThe summary should allow the reader to understand the meeting's key content without having attended. Write in a professional, academic tone using clear, simple English.\n\nYour summary must address:\n- The meeting's purpose and main agenda\n- Speaker(s) involved (mention names if available)\n- Key points, discussions, issues, and ideas\n- Decisions made and conclusions reached\n- Action items (who will do what and when)\n- Noteworthy statements or highlights\n\nSome parts may be short or incomplete. Do not mention missing info—summarize only what's present.\n\n> Note: Although the transcript may be split into segments, treat them as one continuous meeting.\n\n$transcript";
      case 'de':
        return "Deine Aufgabe besteht aus zwei Teilen:\n\n1. **Erzeuge einen Besprechungstitel**: Analysiere das untenstehende Transkript und generiere einen prägnanten, aussagekräftigen Titel mit maximal 5 Wörtern. Gib ihn in folgendem Format zurück:\nTitle: Titel hier\n\n2. **Erzeuge eine Zusammenfassung**: Das folgende Transkript besteht aus Segmenten mehrerer Audioaufnahmen eines Zoom-Meetings. Jeder Absatz kann einen anderen Gesprächsabschnitt darstellen. Kombiniere diese Inhalte zu einer zusammenhängenden und verständlichen Zusammenfassung.\n\nDie Zusammenfassung soll es dem Leser ermöglichen, die wichtigsten Inhalte des Treffens zu verstehen, auch ohne daran teilgenommen zu haben. Verwende einen professionellen, sachlichen Ton in klarem und einfachem Deutsch.\n\nDeine Zusammenfassung soll folgende Punkte enthalten:\n- Ziel und Hauptagenda der Besprechung\n- Beteiligte Sprecher (Namen angeben, falls vorhanden)\n- Besprochene Themen, Probleme, Ideen\n- Getroffene Entscheidungen und Ergebnisse\n- Maßnahmen (wer macht was bis wann)\n- Wichtige Aussagen oder Betonungen\n\nEinige Passagen können kurz oder unvollständig sein. Erwähne fehlende Informationen nicht, fasse nur das Gegebene zusammen.\n\n> Hinweis: Auch wenn das Transkript segmentiert ist, soll es als ein einziges Meeting behandelt werden.\n\n$transcript";
      case 'fr':
        return "Votre tâche comporte deux volets :\n\n1. **Générer un titre de réunion** : Analysez la transcription ci-dessous et créez un titre concis et pertinent ne dépassant pas 5 mots. Retournez-le dans ce format exact :\nTitle: Titre ici\n\n2. **Générer un résumé de réunion** : La transcription ci-dessous provient de plusieurs enregistrements audio d'une réunion Zoom. Chaque paragraphe peut représenter une partie différente de la discussion. Assemblez ces parties en un résumé clair et cohérent.\n\nCe résumé doit permettre au lecteur de comprendre les points clés de la réunion sans y avoir assisté. Adoptez un ton professionnel et académique, en français clair et simple.\n\nLe résumé doit inclure :\n- L’objectif et l’ordre du jour principal\n- Les intervenants (noms si disponibles)\n- Les sujets importants, problèmes ou idées abordés\n- Les décisions prises et les conclusions tirées\n- Les actions à entreprendre (qui, quoi, quand)\n- Les phrases marquantes ou points saillants\n\nCertains passages peuvent être incomplets. Ne mentionnez pas les absences d’informations ; concentrez-vous sur ce qui est fourni.\n\n> Remarque : Bien que la transcription soit segmentée, elle doit être traitée comme une seule réunion.\n\n$transcript";
      default:
        return "Senin görevin iki bölümlü olacak:\n\n1. **Toplantı başlığı** üret: Aşağıdaki transkripti analiz ederek en fazla 5 kelimeden oluşan, net ve anlamlı bir başlık oluştur. Bu başlığı yalnızca şu formatta döndür:\nTitle: Başlık Buraya\n\n2. **Toplantı özeti** üret: Aşağıda bir Zoom toplantısına ait birden fazla ses kaydından oluşturulmuş transkriptler bulunmaktadır. Her satır veya paragraf, farklı bir konuşma bölümünü temsil edebilir. Konular bazen dağınık gelebilir; bu yüzden parçaları anlamlı şekilde birleştirerek bütüncül ve anlaşılır bir özet oluşturman beklenmektedir.\n\nKullanıcının bu özeti okuduğunda toplantıya hiç katılmamış olsa bile tüm önemli içerikleri anlayabilmesi gerekir. Özeti profesyonel ve akademik bir üslupla, sade ve açık bir Türkçe ile oluştur.\n\nAşağıdaki başlıkları mutlaka değerlendir:\n- Toplantının amacı ve ana gündemi\n- Konuşan kişi(ler) kimdi? (isim varsa belirt)\n- Görüşülen önemli konular, sorunlar, fikirler\n- Alınan kararlar ve varılan sonuçlar\n- Eylem maddeleri (kim, ne zaman, ne yapacak)\n- Dikkat çeken ifadeler veya önemli vurgular\n\nBazı parçalar eksik veya kısa olabilir. Ancak sen tüm parçaları bir araya getirerek en anlamlı yapıyı kurmaya çalış. Bilgi eksikse bunu belirtmeden sadece mevcut içerikten faydalan.\n\n> Not: Transkript parçalara bölünmüş olsa da tüm metinleri birleştirerek tek bir toplantının özeti olarak yaz.\n\n$transcript";
    }
  }

  Future<String?> transcribeAudio(File audioFile,
      {String? forceLanguage}) async {
    final url = Uri.parse("https://api.openai.com/v1/audio/transcriptions");

    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $_apiKey'
      ..fields['model'] = 'whisper-1'
      ..fields['response_format'] = 'verbose_json'
      ..files.add(await http.MultipartFile.fromPath('file', audioFile.path));

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
