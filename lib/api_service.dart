import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiKey =
      ''; // Vervang dit door jouw OpenAI API-key
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';

  /// Analyseer een afbeelding met een prompt
  Future<String> analyzeImageWithPrompt(File imageFile, String prompt) async {
    try {
      // Verwerk de afbeelding naar Base64 om deze te verzenden
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // API-aanroep
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {
              "role": "user",
              "content": [
                {"type": "text", "text": prompt},
                {
                  "type": "image_url",
                  "image_url": {"url": "data:image/jpeg;base64,$base64Image"}
                }
              ]
            }
          ],
          "max_tokens": 300,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to analyze image: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
