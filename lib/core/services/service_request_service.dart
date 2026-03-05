import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    if (uid == null) throw Exception('Not authenticated');

    debugPrint('[ServiceRequestService] Creating request: $problemDescription');

    final response = await _client.from('service_requests').insert({
      'customer_id': uid,
      'worker_id': workerId,
      if (categoryId != null) 'category_id': categoryId,
      'problem_description': problemDescription,
      'urgency': urgency,
      'status': 'pending',
      if (locationLat != null) 'location_lat': locationLat,
      if (locationLng != null) 'location_lng': locationLng,
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
        .select('*, profiles!worker_id(full_name)')
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
