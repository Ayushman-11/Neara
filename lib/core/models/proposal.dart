class Proposal {
  final String workerId;
  final double inspectionFee;
  final double estimatedRepair;
  final int advancePercent;
  final String notes;
  final int expirySeconds;

  double get advanceAmount => estimatedRepair * advancePercent / 100;
  double get balanceAmount => estimatedRepair - advanceAmount;

  const Proposal({
    required this.workerId,
    required this.inspectionFee,
    required this.estimatedRepair,
    required this.advancePercent,
    required this.notes,
    required this.expirySeconds,
  });
}
