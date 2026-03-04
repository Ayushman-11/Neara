class Booking {
  final String id;
  final String workerName;
  final String category;
  final String status;
  final String date;
  final double totalAmount;
  final double rating;

  const Booking({
    required this.id,
    required this.workerName,
    required this.category,
    required this.status,
    required this.date,
    required this.totalAmount,
    required this.rating,
  });
}
