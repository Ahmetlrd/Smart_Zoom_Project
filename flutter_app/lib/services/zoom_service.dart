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

  static Future<Map<String, dynamic>?> fetchUserInfo() async {
    final token = await readAccessToken();

    if (token == null) return null;

    final response = await http.get(
      Uri.parse('https://api.zoom.us/v2/users/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }
}
