import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/gemini_service.dart';
import '../../../core/ai/ai_providers.dart';
import 'worker_models.dart';

final workersProvider = Provider<List<Worker>>((ref) {
  // TODO: Replace with Firestore-backed repository.
  return [
    Worker(
      id: '1',
      name: 'Sanjay Patil',
      primaryCategory: ServiceCategory.plumber,
      skills: const ['Leak repair', 'Bathroom fitting'],
      rating: 4.7,
      jobCount: 120,
      distanceKm: 2.3,
      etaMinutes: 12,
      verified: true,
    ),
    Worker(
      id: '2',
      name: 'Priya Sharma',
      primaryCategory: ServiceCategory.electrician,
      skills: const ['Wiring', 'Appliance install'],
      rating: 4.8,
      jobCount: 200,
      distanceKm: 3.1,
      etaMinutes: 15,
      verified: true,
    ),
  ];
});

final filteredWorkersProvider = Provider<List<Worker>>((ref) {
  final all = ref.watch(workersProvider);
  final filters = ref.watch(searchFiltersProvider);

  return all.where((w) {
    if (filters.serviceCategory != null &&
        w.primaryCategory != filters.serviceCategory) {
      return false;
    }
    if (w.rating < filters.minRating) return false;
    if (filters.verifiedOnly && !w.verified) return false;
    if (w.distanceKm > filters.radiusKm) return false;
    return true;
  }).toList();
});
