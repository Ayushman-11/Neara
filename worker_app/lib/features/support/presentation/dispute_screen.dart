import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:worker_app/core/theme/app_colors.dart';
import 'package:worker_app/core/theme/app_theme.dart';

class DisputeResponseScreen extends StatelessWidget {
  const DisputeResponseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resolve Dispute')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAlertBox(),
            const SizedBox(height: 32),
            Text('DISPUTE CASE #45218', style: AppTextStyles.chipLabel),
            const SizedBox(height: 8),
            Text(
              'Customer claiming job was incomplete.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 32),
            Text('YOUR RESPONSE', style: AppTextStyles.titleSmall),
            const SizedBox(height: 12),
            TextField(
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Explain your side of the story...',
              ),
            ),
            const SizedBox(height: 32),
            Text('EVIDENCE PHOTOS', style: AppTextStyles.titleSmall),
            const SizedBox(height: 12),
            _buildEvidenceUpload(),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Response submitted to Neara Resolution Center.',
                    ),
                  ),
                );
              },
              child: const Text('SUBMIT RESPONSE'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.emergencyCrimson.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.emergencyCrimson),
      ),
      child: const Row(
        children: [
          Icon(
            LucideIcons.alertCircle,
            color: AppColors.emergencyCrimson,
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Escrow funds for this job are currently locked.',
              style: TextStyle(
                color: AppColors.emergencyCrimson,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceUpload() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.elevatedGraphite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.mutedSteel,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            LucideIcons.camera,
            color: AppColors.saffronAmber,
            size: 32,
          ),
          const SizedBox(height: 16),
          Text('Tap to Upload Evidence', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
