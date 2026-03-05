import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => _client.auth.currentUser != null;

  /// Send OTP to the given phone number (E.164 format, e.g. +919876543210)
  Future<void> signInWithPhone(String phone) async {
    debugPrint('[AuthService] Sending OTP to $phone');
    await _client.auth.signInWithOtp(phone: phone);
  }

  /// Verify OTP and sign in. Returns true if successful.
  Future<bool> verifyOtp(String phone, String token) async {
    try {
      debugPrint('[AuthService] Verifying OTP for $phone');
      final response = await _client.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );
      debugPrint('[AuthService] Session: ${response.session?.user.id}');
      return response.session != null;
    } catch (e) {
      debugPrint('[AuthService] OTP verification error: $e');
      rethrow;
    }
  }

  /// Check if the logged-in user already has a profile row
  Future<bool> hasProfile() async {
    final uid = currentUser?.id;
    if (uid == null) return false;
    final result = await _client
        .from('profiles')
        .select('id')
        .eq('id', uid)
        .maybeSingle();
    return result != null;
  }

  /// Upsert the user's profile row after first login
  Future<void> saveProfile(String fullName, {String? city}) async {
    final uid = currentUser?.id;
    final phone = currentUser?.phone;
    if (uid == null) return;

    debugPrint('[AuthService] Saving profile for $uid');
    await _client.from('profiles').upsert({
      'id': uid,
      'full_name': fullName,
      'phone_number': phone,
      'role': 'customer',
      if (city != null && city.isNotEmpty) 'city': city,
    });
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
