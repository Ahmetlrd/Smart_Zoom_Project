import 'dart:convert'; // For decoding JSON response
import 'package:http/http.dart' as http; // HTTP requests package
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For loading environment variables

class AuthService {
  // This method refreshes the Zoom access token using a refresh token
  static Future<String?> refreshAccessToken(String refreshToken) async {
    final clientId = dotenv.env['CLIENT_ID']; // Read client ID from .env
    final clientSecret = dotenv.env['CLIENT_SECRET']; // Read client secret from .env

    final response = await http.post(
      Uri.parse('https://zoom.us/oauth/token'), // Zoom token endpoint
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'refresh_token', // Required by Zoom OAuth
        'refresh_token': refreshToken,
        'client_id': clientId,
        'client_secret': clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); // Parse JSON response
      return data['access_token']; // Return the new access token
    } else {
      print("Refresh token failed: ${response.body}"); // Log error for debugging
      return null; // Return null on failure
    }
  }
}
