import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey = "sk-proj-qIyDnZQ3FwyTG3sfoWeDT3BlbkFJGAJEgqiTN721FkSbgnZ9";

  Future<String> generateMCQs(String text) async {
    final url = Uri.parse("https://api.openai.com/v1/completions");

    final response = await http.post(url,
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "text-davinci-003",
          "prompt": "Generate 5 MCQs from the following text:\n$text",
          "max_tokens": 400,
        }));

    final data = jsonDecode(response.body);
    return data["choices"][0]["text"];
  }
}
