import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_radii.dart';

class CountBadge extends StatelessWidget {
  final int count;
  final bool isCompact;

  const CountBadge({
    super.key,
    required this.count,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 5 : 6,
        vertical: isCompact ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.blueBackground,
        borderRadius: BorderRadius.circular(AppRadii.medium),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: isCompact ? 10 : 11,
          fontWeight: FontWeight.w600,
          color: AppColors.blueText,
        ),
      ),
    );
  }
}
