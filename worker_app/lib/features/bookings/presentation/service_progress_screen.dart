import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:worker_app/core/theme/app_colors.dart';
import 'package:worker_app/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_app/features/dashboard/presentation/worker_state.dart';
import 'package:worker_app/features/bookings/presentation/job_summary_screen.dart';
import 'package:worker_app/features/bookings/presentation/full_screen_viewer.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

class ServiceProgressScreen extends ConsumerStatefulWidget {
  const ServiceProgressScreen({super.key});

  @override
  ConsumerState<ServiceProgressScreen> createState() =>
      _ServiceProgressScreenState();
}

class _ServiceProgressScreenState extends ConsumerState<ServiceProgressScreen> {
  late Timer _timer;
  int _seconds = 0;
  bool _isRiskHigh = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _seconds++);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final workerState = ref.watch(workerProvider);
    final activeJob = workerState.activeJob!;
    _isRiskHigh = activeJob.riskLevel == 'HIGH';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job In Progress'),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              LucideIcons.alertTriangle,
              color: AppColors.emergencyCrimson,
            ),
            onPressed: () => _showSOSDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimerCard(),
            const SizedBox(height: 32),
            _buildJobDetails(activeJob),
            const SizedBox(height: 32),
            _buildPhotoSection(activeJob, isBefore: true),
            const SizedBox(height: 24),
            _buildPhotoSection(activeJob, isBefore: false),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => _handleComplete(context, ref, activeJob),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.liveTeal,
                foregroundColor: AppColors.midnightNavy,
              ),
              child: const Text('COMPLETE SERVICE'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.warmCharcoal,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.mutedSteel),
      ),
      child: Column(
        children: [
          Text('SERVICE TIME', style: AppTextStyles.chipLabel),
          const SizedBox(height: 8),
          Text(
            _formatDuration(_seconds),
            style: AppTextStyles.heroAmount.copyWith(
              color: AppColors.saffronAmber,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.activity,
                color: AppColors.liveTeal,
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                'LIVE TRACKING ON',
                style: AppTextStyles.monoSmall.copyWith(
                  color: AppColors.liveTeal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobDetails(ActiveJob job) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('JOB INFO', style: AppTextStyles.chipLabel),
            if (_isRiskHigh)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.emergencyCrimson.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.emergencyCrimson),
                ),
                child: Text(
                  'HIGH RISK',
                  style: AppTextStyles.monoSmall.copyWith(
                    color: AppColors.emergencyCrimson,
                    fontSize: 8,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(job.serviceType, style: AppTextStyles.titleMedium),
        Text(
          job.customerName,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mutedFog),
        ),
      ],
    );
  }

  Widget _buildPhotoSection(ActiveJob job, {required bool isBefore}) {
    final photos = isBefore ? job.beforePhotos : job.afterPhotos;
    final isMandatory = _isRiskHigh;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              isBefore ? 'BEFORE WORK' : 'AFTER WORK',
              style: AppTextStyles.chipLabel,
            ),
            if (isMandatory)
              Text(
                ' * MANDATORY',
                style: AppTextStyles.monoSmall.copyWith(
                  color: AppColors.emergencyCrimson,
                  fontSize: 8,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...photos.map(
                (p) => _buildPhotoThumbnail(
                  p,
                  isBefore ? 'Before Photo' : 'After Photo',
                ),
              ),
              _buildAddPhotoButton(isBefore),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoThumbnail(String path, String label) {
    bool isFile = path.contains('/') || path.contains('\\');
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                FullScreenViewer(imagePath: path, title: label),
          ),
        );
      },
      child: Hero(
        tag: path,
        child: Container(
          width: 80,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: AppColors.elevatedGraphite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.mutedSteel),
            image: isFile
                ? DecorationImage(
                    image: FileImage(File(path)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: isFile
              ? null
              : const Icon(
                  LucideIcons.image,
                  color: AppColors.mutedFog,
                  size: 20,
                ),
        ),
      ),
    );
  }

  Widget _buildAddPhotoButton(bool isBefore) {
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 70,
        );
        if (image != null) {
          ref
              .read(workerProvider.notifier)
              .addJobPhoto(image.path, isBefore: isBefore);
        }
      },
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          color: AppColors.midnightNavy,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.mutedSteel,
            style: BorderStyle.solid,
          ),
        ),
        child: const Icon(
          LucideIcons.camera,
          color: AppColors.saffronAmber,
          size: 24,
        ),
      ),
    );
  }

  void _handleComplete(BuildContext context, WidgetRef ref, ActiveJob job) {
    if (_isRiskHigh && (job.beforePhotos.isEmpty || job.afterPhotos.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mandatory before & after photos required for high risk jobs.',
          ),
          backgroundColor: AppColors.emergencyCrimson,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.warmCharcoal,
        title: Text('Finish Service?', style: AppTextStyles.titleMedium),
        content: Text(
          'Marking this as complete will notify the customer for final payment of ₹${(job.agreedAmount * (1 - job.advancePercentage)).toInt()}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(workerProvider.notifier).completeJob();
              Navigator.pop(context);
              // Use push instead of pushReplacement
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const JobSummaryScreen(),
                ),
              );
            },
            child: const Text('SUBMIT'),
          ),
        ],
      ),
    );
  }

  void _showSOSDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.emergencyCrimson.withOpacity(0.9),
        title: Text(
          'EMERGENCY SOS',
          style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
        ),
        content: const Text(
          'This will share your live location with Neara Safety Hub and local authorities. Only use in real danger.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.emergencyCrimson,
            ),
            child: const Text('TRIGGER SOS'),
          ),
        ],
      ),
    );
  }
}
