import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message_model.dart'; // For LlmApiResponse

// Replace with your actual backend URL
const String _chatBaseUrl = "http://localhost:8080/api/chat";

class LlmRepository {
  final http.Client _client;

  LlmRepository({http.Client? client}) : _client = client ?? http.Client();

  // The Go backend is expected to handle calls to both LLMs
  // and return a list of their responses.
  Future<List<LlmApiResponse>> sendPromptToBackend({
    required String prompt,
    String? userToken, // Optional: if your backend requires auth for this
  }) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (userToken != null) {
      headers['Authorization'] = 'Bearer $userToken';
    }

    final response = await _client.post(
      Uri.parse('$_chatBaseUrl/prompt'),
      headers: headers,
      body: json.encode({'prompt': prompt}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData.map((data) => LlmApiResponse.fromJson(data)).toList();
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['error'] ?? 'Failed to get LLM responses');
    }
  }

// Placeholder for saving chosen responses (if you implement it)
// Future<void> saveChosenResponse(...) async { ... }
}