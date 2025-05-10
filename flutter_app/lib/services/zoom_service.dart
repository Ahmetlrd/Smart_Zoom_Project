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

    print("Access token: $token"); 

    if (token == null) {
      print("No token found.");
      return null;
    }

    final response = await http.get(
      Uri.parse('https://api.zoom.us/v2/users/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print("Zoom /users/me status code: ${response.statusCode}");
    print("Zoom response body: ${response.body}");

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("Failed to fetch user info");
      return null;
    }
  }
}
