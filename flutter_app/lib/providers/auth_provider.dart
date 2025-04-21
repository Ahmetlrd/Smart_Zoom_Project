// Riverpod ve local storage için gerekli paketleri alıyorum
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// authProvider: uygulama genelinde login durumunu yönetiyor
final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});

// AuthNotifier: login state'ini tutan sınıf
class AuthNotifier extends StateNotifier<bool> {
  // Başlangıçta login değil olarak başlatıyorum
  AuthNotifier() : super(false) {
    _loadLoginStatus(); // uygulama açıldığında login bilgisi var mı kontrol et
  }

  // Uygulama ilk açıldığında login durumu local storage'tan okunur
  Future<void> _loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('isLoggedIn') ?? false;
  }

  // Kullanıcı login olursa hem state değişiyor hem de kalıcı olarak kaydediliyor
  Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    state = true;
  }

  // Kullanıcı logout olursa hem local storage temizleniyor hem de state false oluyor
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    state = false;
  }

  // Zoom'dan token geldiğinde giriş yapılmış kabul ediyorum
  void loginWithToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    state = true;
  }
}
