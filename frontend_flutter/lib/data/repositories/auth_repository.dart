import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

const String _baseUrl = "http://localhost:8080/api/auth"; //private

class AuthRepository {
  final http.Client _client;
// client object use krke actual HTTP request hogi
  AuthRepository({http.Client? client}) : _client = client ?? http.Client(); // : separates constructor from initializer list, it means before finalizing the parameters consider this
  // toh _client is client if it has been passed, or default to http.Client() if null
// {} means client is a named parameter and later we would have to client:...
  // ? means client can be null

  Future<User> signup({
    required String email,
    required String password,
    String? username,
  }) async {
    final Map<String, String?> body = {
      'email': email,
      'password': password,
    };
    if (username != null && username.isNotEmpty) {
      body['username'] = username;
    }

    final response = await _client.post(
      Uri.parse('$_baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );


    // response returns a Future<http.Response> object
    if (response.statusCode == 201 || response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['error'] ?? 'Failed to sign up');
    }
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['error'] ?? 'Failed to login');
    }
  }
}