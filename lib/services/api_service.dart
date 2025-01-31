import 'dart:convert';
import 'package:campus_connect/config/api_config.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<Map<String, dynamic>> postRequest(
      String endpoint, Map<String, dynamic> body) async {
    final Uri url = Uri.parse("${ApiConfig.authBaseUrl}/$endpoint");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          "Error: ${jsonDecode(response.body)['message'] ?? response.body}",
        );
      }
    } catch (e) {
      throw Exception("Failed to connect to server: $e");
    }
  }

  static Future<Map<String, dynamic>> getRequest(String endpoint,
      {Map<String, String>? headers}) async {
    final Uri url = Uri.parse("${ApiConfig.authBaseUrl}$endpoint");

    try {
      final response = await http.get(
        url,
        headers: headers ?? {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Error: ${response.body}");
      }
    } catch (e) {
      throw Exception("Failed to connect to server: $e");
    }
  }
}
