import '../../../core/ai/gemini_service.dart';

class Worker {
  final String id;
  final String name;
  final ServiceCategory primaryCategory;
  final List<String> skills;
  final double rating;
  final int jobCount;
  final double distanceKm;
  final int etaMinutes;
  final bool verified;

  Worker({
    required this.id,
    required this.name,
    required this.primaryCategory,
    required this.skills,
    required this.rating,
    required this.jobCount,
    required this.distanceKm,
    required this.etaMinutes,
    required this.verified,
  });
}
