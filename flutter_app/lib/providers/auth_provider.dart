// Import necessary packages for state management (Riverpod) and persistent storage
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define a Riverpod provider to manage the user's login state across the app
final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});

// AuthNotifier handles the authentication logic and state
class AuthNotifier extends StateNotifier<bool> {
  // Initialize with false, meaning user is not logged in by default
  AuthNotifier() : super(false) {
    _loadLoginStatus(); // Load saved login state when app starts
  }

  // Loads login status from local storage (SharedPreferences) during app startup
  Future<void> _loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // If no value is saved, default to false (not logged in)
    state = prefs.getBool('isLoggedIn') ?? false;
  }

  // When user logs in, update state and save login status to storage
  Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true); // Save login state
    state = true; // Update the state to logged in
  }

  // When user logs out, clear login status from storage and update state
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false); // Clear login state
    state = false; // Update the state to logged out
  }

  // If we receive a token (e.g., from Zoom login), mark the user as logged in
  void loginWithToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true); // Save login state
    state = true; // Update the state to logged in
  }
}
