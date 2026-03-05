import 'package:flutter_riverpod/flutter_riverpod.dart';

enum JobStatus {
  idle,
  negotiating,
  waitingEscrow,
  escrowSigning,
  coming, // Navigation
  arrived,
  started,
  completing,
  waitingFinalPayment,
  closed,
}

class ActiveJob {
  final String id;
  final String customerName;
  final String serviceType;
  final String customerAddress;
  final double agreedAmount;
  final double advancePercentage;
  final String riskLevel;
  final List<String> beforePhotos;
  final List<String> afterPhotos;
  final DateTime? startedAt;

  ActiveJob({
    required this.id,
    required this.customerName,
    required this.serviceType,
    this.customerAddress = '123, Luxury Enclave, Mumbai',
    required this.agreedAmount,
    this.advancePercentage = 0.20,
    this.riskLevel = 'NORMAL',
    this.beforePhotos = const [],
    this.afterPhotos = const [],
    this.startedAt,
  });

  ActiveJob copyWith({
    String? id,
    String? customerName,
    String? serviceType,
    String? customerAddress,
    double? agreedAmount,
    double? advancePercentage,
    String? riskLevel,
    List<String>? beforePhotos,
    List<String>? afterPhotos,
    DateTime? startedAt,
  }) {
    return ActiveJob(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      serviceType: serviceType ?? this.serviceType,
      customerAddress: customerAddress ?? this.customerAddress,
      agreedAmount: agreedAmount ?? this.agreedAmount,
      advancePercentage: advancePercentage ?? this.advancePercentage,
      riskLevel: riskLevel ?? this.riskLevel,
      beforePhotos: beforePhotos ?? this.beforePhotos,
      afterPhotos: afterPhotos ?? this.afterPhotos,
      startedAt: startedAt ?? this.startedAt,
    );
  }
}

class ServiceRequest {
  final String id;
  final String title;
  final String category;
  final String distance;
  final String tag;
  final DateTime createdAt;

  ServiceRequest({
    required this.id,
    required this.title,
    required this.category,
    required this.distance,
    required this.tag,
    required this.createdAt,
  });
}

class PastJob {
  final String id;
  final String customerName;
  final String serviceType;
  final double amount;
  final DateTime date;
  final String status; // COMPLETED, CANCELLED

  PastJob({
    required this.id,
    required this.customerName,
    required this.serviceType,
    required this.amount,
    required this.date,
    required this.status,
  });
}

class WorkerState {
  final String name;
  final String? photoPath;
  final bool isOnline;
  final bool notificationsEnabled;
  final double serviceRadius;
  final List<String> selectedCategories;
  final double walletBalance;
  final List<ServiceRequest> nearbyRequests;
  final List<PastJob> jobHistory;

  // New Polish Fields
  final double baseInspectionFee;
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String workingHours;
  final double rating;
  final int completedJobs;
  final String language;
  final String kycStatus; // Approved, Pending, Under Review
  final String verifiedDate;

  // Job Lifecycle
  final JobStatus jobStatus;
  final ActiveJob? activeJob;

  WorkerState({
    required this.name,
    this.photoPath,
    required this.isOnline,
    required this.notificationsEnabled,
    required this.serviceRadius,
    required this.selectedCategories,
    required this.walletBalance,
    required this.nearbyRequests,
    required this.jobHistory,
    required this.baseInspectionFee,
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.workingHours,
    required this.rating,
    required this.completedJobs,
    required this.language,
    required this.kycStatus,
    required this.verifiedDate,
    this.jobStatus = JobStatus.idle,
    this.activeJob,
  });

  WorkerState copyWith({
    String? name,
    String? photoPath,
    bool? isOnline,
    bool? notificationsEnabled,
    double? serviceRadius,
    List<String>? selectedCategories,
    double? walletBalance,
    List<ServiceRequest>? nearbyRequests,
    List<PastJob>? jobHistory,
    double? baseInspectionFee,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? workingHours,
    double? rating,
    int? completedJobs,
    String? language,
    String? kycStatus,
    String? verifiedDate,
    JobStatus? jobStatus,
    ActiveJob? activeJob,
  }) {
    return WorkerState(
      name: name ?? this.name,
      photoPath: photoPath ?? this.photoPath,
      isOnline: isOnline ?? this.isOnline,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      serviceRadius: serviceRadius ?? this.serviceRadius,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      walletBalance: walletBalance ?? this.walletBalance,
      nearbyRequests: nearbyRequests ?? this.nearbyRequests,
      jobHistory: jobHistory ?? this.jobHistory,
      baseInspectionFee: baseInspectionFee ?? this.baseInspectionFee,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      workingHours: workingHours ?? this.workingHours,
      rating: rating ?? this.rating,
      completedJobs: completedJobs ?? this.completedJobs,
      language: language ?? this.language,
      kycStatus: kycStatus ?? this.kycStatus,
      verifiedDate: verifiedDate ?? this.verifiedDate,
      jobStatus: jobStatus ?? this.jobStatus,
      activeJob: activeJob ?? this.activeJob,
    );
  }
}

class WorkerNotifier extends Notifier<WorkerState> {
  @override
  WorkerState build() {
    return WorkerState(
      name: 'Rajesh Kumar',
      isOnline: true,
      notificationsEnabled: true,
      serviceRadius: 5.0,
      selectedCategories: ['Plumber', 'Electrician'],
      walletBalance: 12840.50,
      baseInspectionFee: 250.0,
      bankName: 'HDFC Bank',
      accountNumber: 'XXXX XXXX 4242',
      ifscCode: 'HDFC0001234',
      workingHours: '9:00 AM - 7:00 PM',
      rating: 4.8,
      completedJobs: 124,
      language: 'English',
      kycStatus: 'Approved',
      verifiedDate: 'Jan 12, 2026',
      jobHistory: [
        PastJob(
          id: '101',
          customerName: 'Priya M.',
          serviceType: 'Fan Installation',
          amount: 450.0,
          date: DateTime.now().subtract(const Duration(days: 1)),
          status: 'COMPLETED',
        ),
        PastJob(
          id: '102',
          customerName: 'Suresh K.',
          serviceType: 'Leaking Tap Repair',
          amount: 250.0,
          date: DateTime.now().subtract(const Duration(days: 2)),
          status: 'COMPLETED',
        ),
        PastJob(
          id: '103',
          customerName: 'Anjali R.',
          serviceType: 'Switchboard Repair',
          amount: 350.0,
          date: DateTime.now().subtract(const Duration(days: 5)),
          status: 'CANCELLED',
        ),
      ],
      nearbyRequests: [
        ServiceRequest(
          id: '1',
          title: 'Leaking Kitchen Tap',
          category: 'Plumbing',
          distance: '1.2 km away',
          tag: 'URGENT',
          createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        ServiceRequest(
          id: '2',
          title: 'Water Heater Repair',
          category: 'Electrician',
          distance: '2.5 km away',
          tag: 'FAST RESPONSE',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        ServiceRequest(
          id: '3',
          title: 'Clogged Drain',
          category: 'Plumbing',
          distance: '0.8 km away',
          tag: 'NORMAL',
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
      ],
    );
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void toggleOnline(bool value) {
    state = state.copyWith(isOnline: value);
  }

  void toggleNotifications(bool value) {
    state = state.copyWith(notificationsEnabled: value);
  }

  void updateRadius(double radius) {
    state = state.copyWith(serviceRadius: radius);
  }

  void updateCategories(List<String> categories) {
    state = state.copyWith(selectedCategories: categories);
  }

  void updateFees(double fee) {
    state = state.copyWith(baseInspectionFee: fee);
  }

  void updateWorkingHours(String hours) {
    state = state.copyWith(workingHours: hours);
  }

  void updateBankDetails(String bank, String acc, String ifsc) {
    state = state.copyWith(bankName: bank, accountNumber: acc, ifscCode: ifsc);
  }

  void updateLanguage(String lang) {
    state = state.copyWith(language: lang);
  }

  void ignoreRequest(String id) {
    state = state.copyWith(
      nearbyRequests: state.nearbyRequests.where((r) => r.id != id).toList(),
    );
  }

  void withdrawFunds(double amount) {
    if (state.walletBalance >= amount) {
      state = state.copyWith(walletBalance: state.walletBalance - amount);
    }
  }

  // Lifecycle Transitions
  void startNegotiation(ServiceRequest request, double agreedAmount) {
    state = state.copyWith(
      jobStatus: JobStatus.negotiating,
      activeJob: ActiveJob(
        id: request.id,
        customerName: 'Amit Kumar',
        serviceType: request.title,
        agreedAmount: agreedAmount,
        riskLevel: request.tag == 'URGENT' ? 'HIGH' : 'NORMAL',
      ),
      nearbyRequests: state.nearbyRequests
          .where((r) => r.id != request.id)
          .toList(),
    );
  }

  void updateJobStatus(JobStatus status) {
    state = state.copyWith(jobStatus: status);
  }

  void updateAgreedAmount(double amount) {
    if (state.activeJob != null) {
      state = state.copyWith(
        activeJob: state.activeJob!.copyWith(agreedAmount: amount),
      );
    }
  }

  void addJobPhoto(String path, {bool isBefore = true}) {
    if (state.activeJob != null) {
      final photos = isBefore
          ? [...state.activeJob!.beforePhotos, path]
          : [...state.activeJob!.afterPhotos, path];
      state = state.copyWith(
        activeJob: isBefore
            ? state.activeJob!.copyWith(beforePhotos: photos)
            : state.activeJob!.copyWith(afterPhotos: photos),
      );
    }
  }

  void completeJob() {
    if (state.activeJob != null) {
      final total = state.activeJob!.agreedAmount;
      state = state.copyWith(
        walletBalance: state.walletBalance + total,
        completedJobs: state.completedJobs + 1,
        jobStatus: JobStatus.closed,
      );
    }
  }

  void resetJob() {
    state = state.copyWith(jobStatus: JobStatus.idle, activeJob: null);
  }
}

final workerProvider = NotifierProvider<WorkerNotifier, WorkerState>(() {
  return WorkerNotifier();
});
