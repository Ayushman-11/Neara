class Worker {
  final String id;
  final String name;
  final String category;
  final String? categoryId; // needed for service_requests.category_id
  final double rating;
  final double distanceKm;
  final int jobsCompleted;
  final bool isOnline;
  final String avatarInitials;
  final String location;
  final String about;
  final List<String> services;
  final int reviewCount;

  const Worker({
    required this.id,
    required this.name,
    required this.category,
    this.categoryId,
    required this.rating,
    required this.distanceKm,
    required this.jobsCompleted,
    required this.isOnline,
    required this.avatarInitials,
    required this.location,
    required this.about,
    required this.services,
    required this.reviewCount,
  });
}
