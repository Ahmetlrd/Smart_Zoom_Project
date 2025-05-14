// secure_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Create a singleton secure storage instance
const _secureStorage = FlutterSecureStorage();

/// Saves the access token securely
Future<void> saveAccessToken(String token) async {
  await _secureStorage.write(key: 'access_token', value: token);
}

/// Saves the refresh token securely
Future<void> saveRefreshToken(String token) async {
  await _secureStorage.write(key: 'refresh_token', value: token);
}

/// Reads the access token from secure storage
Future<String?> readAccessToken() async {
  return await _secureStorage.read(key: 'access_token');
}

/// Reads the refresh token from secure storage
Future<String?> readRefreshToken() async {
  return await _secureStorage.read(key: 'refresh_token');
}

/// Deletes all stored tokens (used on logout)
/// Deletes all stored tokens (used on logout)
Future<void> clearAllTokens() async {
  await _secureStorage.delete(key: 'access_token');
  await _secureStorage.delete(key: 'refresh_token');
  await _secureStorage.delete(key: 'jwt_token'); // Ensure JWT is also cleared
}
Future<void> saveJwtToken(String token) async {
  final storage = FlutterSecureStorage();
  await storage.write(key: 'jwt_token', value: token);
}
Future<void> saveUserEmail(String email) async {
  await _secureStorage.write(key: 'user_email', value: email);
}

Future<String?> readUserEmail() async {
  return await _secureStorage.read(key: 'user_email');
}
