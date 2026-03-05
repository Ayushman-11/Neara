import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'dart:io';

class ServiceRequestService {
  final SupabaseClient _client = Supabase.instance.client;

  String? get _currentUserId => _client.auth.currentUser?.id;

  /// Create a new service request and return the generated request ID
  Future<String> createRequest({
    required String workerId,
    String? categoryId,
    required String problemDescription,
    required String urgency,
    double? locationLat,
    double? locationLng,
    String? addressId,
    String? addressSnapshot,
  }) async {
    final uid = _currentUserId;
    double? finalLat = locationLat;
    double? finalLng = locationLng;

    // If locations are null, attempt to geocode the address string to avoid mock values
    if ((finalLat == null || finalLng == null) && addressSnapshot != null) {
      Future<void> tryGeocode(String queryText) async {
        if (finalLat != null) return; // already found
        try {
          final query = Uri.encodeComponent(queryText.trim());
          final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1');
          final request = await HttpClient().getUrl(url);
          request.headers.set('User-Agent', 'NearaApp/1.0 (Contact: local@example.com)');
          final response = await request.close();
          if (response.statusCode == 200) {
            final responseBody = await response.transform(utf8.decoder).join();
            final data = jsonDecode(responseBody) as List;
            if (data.isNotEmpty) {
              finalLat = double.tryParse(data[0]['lat'].toString());
              finalLng = double.tryParse(data[0]['lon'].toString());
            }
          }
        } catch (e) {
          debugPrint('[ServiceRequestService] Geocode error for "$queryText": $e');
        }
      }

      await tryGeocode(addressSnapshot);

      // If full address fails, fallback to extracting just city/pincode (last 1-2 parts)
      if (finalLat == null || finalLng == null) {
        final parts = addressSnapshot.split(',');
        if (parts.length > 1) {
          final fallbackQuery = parts.skip(parts.length > 2 ? parts.length - 2 : 1).join(', ');
          await tryGeocode(fallbackQuery);
        }
      }
    }

    // Fallback to Pune coordinates if geocoding entirely fails, to satisfy the db constraints
    finalLat ??= 18.5204;
    finalLng ??= 73.8567;

    final response = await _client.from('service_requests').insert({
      'customer_id': uid,
      'worker_id': workerId,
      if (categoryId != null) 'category_id': categoryId,
      'problem_description': problemDescription,
      'urgency': urgency == 'urgent' ? 'emergency' : urgency,
      'status': 'REQUEST_SENT',
      'location_lat': finalLat,
      'location_lng': finalLng,
      if (addressId != null) 'address_id': addressId,
      if (addressSnapshot != null) 'address_snapshot': addressSnapshot,
    }).select('id').single();

    final id = response['id'] as String;
    debugPrint('[ServiceRequestService] Request created: $id');
    return id;
  }

  /// Fetch all requests made by the current customer
  Future<List<Map<String, dynamic>>> getMyRequests() async {
    final uid = _currentUserId;
    if (uid == null) return [];

    final response = await _client
        .from('service_requests')
        .select('*, profiles!worker_id(full_name), service_categories!category_id(name)')
        .eq('customer_id', uid)
        .order('created_at', ascending: false);

    return (response as List).cast<Map<String, dynamic>>();
  }

  /// Get a single request by ID
  Future<Map<String, dynamic>?> getRequestById(String id) async {
    final response = await _client
        .from('service_requests')
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }
}
