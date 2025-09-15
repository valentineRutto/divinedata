
import 'dart:convert';
import 'package:http/http.dart' as http;


class GptService {

  final String apiKey;
  GptService(this.apiKey);

  Future<String> explainVerse(String verse) async {
    const endpoint = "https://api.openai.com/v1/chat/completions";

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini", // or gpt-5 if available
        "messages": [
          {"role": "system", "content": "You are a scholarly assistant that explains Bible passages in a neutral, academic way."},
          {"role": "user", "content": "Explain this verse: $verse"}
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception("GPT API error: ${response.body}");
    }
  }
}
