import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

/// A reusable status chip for service states and availability indicators.
class StatusChip extends StatelessWidget {
  final String label;
  final StatusChipType type;

  const StatusChip({super.key, required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor.withAlpha(30),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _bgColor, width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.chipLabel.copyWith(color: _bgColor),
      ),
    );
  }

  Color get _bgColor {
    switch (type) {
      case StatusChipType.online:
        return AppColors.liveTeal;
      case StatusChipType.warning:
        return AppColors.warningAmber;
      case StatusChipType.success:
        return AppColors.safeGreen;
      case StatusChipType.error:
        return AppColors.emergencyCrimson;
      case StatusChipType.accent:
        return AppColors.saffronAmber;
      case StatusChipType.muted:
        return AppColors.mutedFog;
    }
  }
}

enum StatusChipType { online, warning, success, error, accent, muted }
