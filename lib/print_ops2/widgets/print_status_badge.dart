import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';

class PrintStatusBadge extends StatelessWidget {
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final String label;
  final IconData icon;
  final double fontSize;
  final double iconSize;
  final EdgeInsets padding;
  final bool enabled;
  final VoidCallback? onTap;
  final Color? borderColor;

  const PrintStatusBadge({
    super.key,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.label,
    required this.icon,
    this.fontSize = 11,
    this.iconSize = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    this.enabled = true,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppRadii.small),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppRadii.small),
            border:
                borderColor != null ? Border.all(color: borderColor!) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: iconSize, color: iconColor),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
