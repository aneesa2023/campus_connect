import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = "cognito_access_token"; // Key for token storage
  static const _userIdKey = "user_id"; // Key for storing user_id

  // Save Cognito Access Token (JWT)
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    // Extract user_id from token and save it
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String userId = decodedToken['sub']; // Extracting user ID from token
    await saveUserId(userId);
  }

  // Retrieve Cognito Access Token (JWT) - Used for API Calls
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Save Cognito User ID
  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  // Retrieve Cognito User ID - Used for API Calls
  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  // Clear Authentication Data (Logout)
  static Future<void> logout() async {
    await _storage.deleteAll();
  }
}
