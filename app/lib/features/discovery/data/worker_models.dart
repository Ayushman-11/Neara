import '../../../core/ai/gemini_service.dart';

class Worker {
  final String id;
  final String name;
  final ServiceCategory primaryCategory;
  final List<String> skills;
  final double rating;
  final int jobCount;
  final bool verified;
  final double latitude;
  final double longitude;

  Worker({
    required this.id,
    required this.name,
    required this.primaryCategory,
    required this.skills,
    required this.rating,
    required this.jobCount,
    required this.verified,
    required this.latitude,
    required this.longitude,
  });
}
