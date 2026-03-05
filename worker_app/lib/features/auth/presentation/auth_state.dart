import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus { authenticated, unauthenticated, initial }

class AuthState {
  final AuthStatus status;
  final String? phoneNumber;

  AuthState({required this.status, this.phoneNumber});

  factory AuthState.initial() => AuthState(status: AuthStatus.initial);
  factory AuthState.authenticated(String phone) =>
      AuthState(status: AuthStatus.authenticated, phoneNumber: phone);
  factory AuthState.unauthenticated() =>
      AuthState(status: AuthStatus.unauthenticated);
}

class AuthNotifier extends Notifier<AuthState> {
  static const String _authKey = 'is_logged_in';
  static const String _phoneKey = 'user_phone';

  @override
  AuthState build() {
    _loadAuthState();
    return AuthState.initial();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_authKey) ?? false;
    final phone = prefs.getString(_phoneKey);

    if (isLoggedIn && phone != null) {
      state = AuthState.authenticated(phone);
    } else {
      state = AuthState.unauthenticated();
    }
  }

  Future<void> login(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authKey, true);
    await prefs.setString(_phoneKey, phone);
    state = AuthState.authenticated(phone);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authKey);
    await prefs.remove(_phoneKey);
    state = AuthState.unauthenticated();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
