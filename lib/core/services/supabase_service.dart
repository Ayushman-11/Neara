import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/worker.dart';

// Fallback mock workers shown when network is unavailable
const _mockWorkers = [
  {
    'id': '11111111-1111-1111-1111-111111111111',
    'full_name': 'Ramesh Kumar',
    'category': 'Plumber',
    'rating_avg': '4.8',
    'completed_jobs': 120,
    'availability_status': 'available',
  },
  {
    'id': '22222222-2222-2222-2222-222222222222',
    'full_name': 'Rajesh Sharma',
    'category': 'Electrician',
    'rating_avg': '4.5',
    'completed_jobs': 85,
    'availability_status': 'available',
  },
  {
    'id': '33333333-3333-3333-3333-333333333333',
    'full_name': 'Suresh Patel',
    'category': 'Mechanic',
    'rating_avg': '4.9',
    'completed_jobs': 210,
    'availability_status': 'available',
  },
  {
    'id': '44444444-4444-4444-4444-444444444444',
    'full_name': 'Mahesh Yadav',
    'category': 'Plumber',
    'rating_avg': '4.2',
    'completed_jobs': 35,
    'availability_status': 'available',
  },
];

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Worker>> getNearbyWorkers() async {
    try {
      debugPrint('[SupabaseService] Fetching workers from Supabase...');

      final response = await _client
          .from('profiles')
          .select()
          .eq('role', 'worker')
          .timeout(const Duration(seconds: 8));

      final List<dynamic> data = response as List<dynamic>;
      debugPrint('[SupabaseService] Got ${data.length} workers from DB');

      if (data.isEmpty) {
        debugPrint('[SupabaseService] DB returned empty — using mock fallback');
        return _buildMockWorkers();
      }

      // Fetch categories
      final categories = await _client
          .from('service_categories')
          .select()
          .timeout(const Duration(seconds: 8)) as List<dynamic>;
      
      final categoryMap = <String, String>{
        for (final cat in categories)
          (cat as Map<String, dynamic>)['id'].toString(): cat['name'].toString()
      };

      return data
          .map((d) => _mapToWorker(d as Map<String, dynamic>, categoryMap))
          .toList();
    } catch (e, stack) {
      debugPrint('[SupabaseService] Network error (using mock fallback): $e');
      debugPrint('[SupabaseService] Stack: $stack');
      return _buildMockWorkers();
    }
  }

  List<Worker> _buildMockWorkers() {
    return _mockWorkers.map((data) {
      final name = data['full_name'] as String;
      final parts = name.split(' ');
      final initials = parts.length >= 2
          ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
          : name[0].toUpperCase();
      final category = data['category'] as String;
      final jobs = data['completed_jobs'] as int;
      final rating = double.tryParse(data['rating_avg'].toString()) ?? 0.0;

      return Worker(
        id: data['id'] as String,
        name: name,
        category: category,
        rating: rating,
        distanceKm: 1.5,
        jobsCompleted: jobs,
        isOnline: data['availability_status'] == 'available',
        avatarInitials: initials,
        location: 'Pune',
        about: 'Verified $category worker on Neara. $jobs jobs completed.',
        services: [category],
        reviewCount: jobs ~/ 2,
      );
    }).toList();
  }

  Worker _mapToWorker(Map<String, dynamic> data, Map<String, String> categoryMap) {
    final catId = data['service_category_id']?.toString() ?? '';
    final category = categoryMap[catId] ?? 'General';
    final name = data['full_name']?.toString() ?? 'Unknown';
    final parts = name.split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (name.isNotEmpty ? name[0].toUpperCase() : '?');
    final rating = double.tryParse(data['rating_avg']?.toString() ?? '0') ?? 0.0;
    final jobs = data['completed_jobs'] is int
        ? data['completed_jobs'] as int
        : int.tryParse(data['completed_jobs']?.toString() ?? '0') ?? 0;

    return Worker(
      id: data['id'].toString(),
      name: name,
      category: category,
      categoryId: catId.isNotEmpty ? catId : null,
      rating: rating,
      distanceKm: 1.5,
      jobsCompleted: jobs,
      isOnline: data['availability_status'] == 'available',
      avatarInitials: initials,
      location: 'Pune',
      about: 'Verified $category worker on Neara. $jobs jobs completed.',
      services: [category],
      reviewCount: jobs ~/ 2,
    );
  }
}
