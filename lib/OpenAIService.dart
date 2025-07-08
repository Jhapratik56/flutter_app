import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey = "sk-proj-....."; // Keep this secret in production

  Future<String> generateMCQs(String text) async {
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {
            "role": "system",
            "content": "You are a quiz generator. Generate 5 MCQs from given academic text. Each question should have 4 options and clearly mark the correct answer."
          },
          {
            "role": "user",
            "content": text
          }
        ],
        "temperature": 0.7,
        "max_tokens": 500,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["choices"][0]["message"]["content"];
    } else {
      print("Error: ${response.statusCode} ${response.body}");
      return "Failed to generate MCQs.";
    }
  }
}
