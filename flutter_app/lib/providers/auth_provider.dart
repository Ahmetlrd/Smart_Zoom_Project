import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider =
    StateNotifierProvider<AuthNotifier, bool>((ref) => AuthNotifier());

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false);

  Stream<bool> get stream async* {
    yield state;
  }

  void login() {
    state = true;
  }

  void logout() {
    state = false;
  }
}
