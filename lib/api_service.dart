import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiKey =
      ''; // Vervang dit met jouw OpenAI API-key
  final String openAiApiUrl = 'https://api.openai.com/v1/chat/completions';

  /// Genereer een versimpelde uitleg voor een woord
  Future<String> generateSimplifiedExplanation(String word) async {
    try {
      final response = await http.post(
        Uri.parse(openAiApiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content':
                  'Je bent een assistent in een apotheek die ingewikkelde termen uitlegd in simpel Nederlands'
            },
            {
              'role': 'user',
              'content':
                  "Leg uit wat het woord '$word' betekent in de context van een medische verpakking. Gebruik taal op simpel A1-niveau maar sla geen kritische informatie over, leg uit wat belangrijk is, maximaal 35 woorden."
            }
          ],
          'max_tokens': 150,
          'temperature': 0.1,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(
            'API Response (Generate Simplified Explanation): $data'); // Debug: Controleer API-respons
        return data['choices'][0]['message']['content']
            .trim(); // Zorg dat alleen de tekst wordt geretourneerd
      } else {
        throw Exception('Failed to generate explanation: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
