import 'package:http/http.dart' as http;
import 'dart:convert';
import 'secure_storage_service.dart';

class ZoomService {
  static Future<bool> isAccessTokenValid(String token) async {
    final response = await http.get(
      Uri.parse('https://api.zoom.us/v2/users/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>?> fetchUserInfoWithToken(
      String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.zoom.us/v2/users/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('⚠️ Zoom API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exception in fetchUserInfoWithToken: $e');
      return null;
    }
  }
}
