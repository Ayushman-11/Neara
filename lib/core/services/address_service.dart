import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerAddress {
  final String id;
  final String label;
  final String addressLine;
  final String? city;
  final String? pincode;
  final double? locationLat;
  final double? locationLng;
  final bool isDefault;

  const CustomerAddress({
    required this.id,
    required this.label,
    required this.addressLine,
    this.city,
    this.pincode,
    this.locationLat,
    this.locationLng,
    this.isDefault = false,
  });

  factory CustomerAddress.fromMap(Map<String, dynamic> m) => CustomerAddress(
        id: m['id'] as String,
        label: m['label'] as String,
        addressLine: m['address_line'] as String,
        city: m['city'] as String?,
        pincode: m['pincode'] as String?,
        locationLat: _parseDouble(m['location_lat']),
        locationLng: _parseDouble(m['location_lng']),
        isDefault: m['is_default'] as bool? ?? false,
      );

  static double? _parseDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val);
    return null;
  }

  String get displayText =>
      [addressLine, city, pincode].where((e) => e != null && e.isNotEmpty).join(', ');

  String get shortDisplay => '$label • $addressLine';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerAddress && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class AddressService {
  final SupabaseClient _client = Supabase.instance.client;

  String? get _uid => _client.auth.currentUser?.id;

  Future<List<CustomerAddress>> getMyAddresses() async {
    final uid = _uid;
    if (uid == null) return [];
    final res = await _client
        .from('customer_addresses')
        .select()
        .eq('customer_id', uid)
        .order('is_default', ascending: false)
        .order('created_at');
    return (res as List)
        .cast<Map<String, dynamic>>()
        .map(CustomerAddress.fromMap)
        .toList();
  }

  Future<CustomerAddress> addAddress({
    required String label,
    required String addressLine,
    String? city,
    String? pincode,
    double? locationLat,
    double? locationLng,
    bool isDefault = false,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');

    if (isDefault) {
      // Clear existing default
      await _client
          .from('customer_addresses')
          .update({'is_default': false})
          .eq('customer_id', uid);
    }

    final res = await _client.from('customer_addresses').insert({
      'customer_id': uid,
      'label': label,
      'address_line': addressLine,
      if (city != null && city.isNotEmpty) 'city': city,
      if (pincode != null && pincode.isNotEmpty) 'pincode': pincode,
      if (locationLat != null) 'location_lat': locationLat,
      if (locationLng != null) 'location_lng': locationLng,
      'is_default': isDefault,
    }).select().single();

    debugPrint('[AddressService] Added address: ${res['id']}');
    return CustomerAddress.fromMap(res);
  }

  Future<void> deleteAddress(String id) async {
    await _client.from('customer_addresses').delete().eq('id', id);
  }

  Future<void> setDefault(String id) async {
    final uid = _uid;
    if (uid == null) return;
    await _client
        .from('customer_addresses')
        .update({'is_default': false})
        .eq('customer_id', uid);
    await _client
        .from('customer_addresses')
        .update({'is_default': true})
        .eq('id', id);
  }
}
