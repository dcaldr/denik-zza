import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';

class FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool implemented;
  final bool emphasize;

  const FeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.implemented = true,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: emphasize ? 4 : 1,
      color: implemented ? null : AppColors.greyBackground,
      child: InkWell(
        onTap: implemented ? onTap : null,
        borderRadius: AppRadii.buttonRadius,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon,
                  size: 32,
                  color: implemented
                      ? Theme.of(context).colorScheme.primary
                      : AppColors.greyIcon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        implemented ? null : AppColors.greyText,
                                  )),
                        ),
                        if (!implemented)
                          Tooltip(
                            message: 'Funkce zatím není implementována',
                            child: Icon(Icons.lock,
                                size: 18, color: AppColors.greyIcon),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: implemented
                                  ? Theme.of(context).colorScheme.onSurface
                                  : AppColors.greyText,
                            )),
                  ],
                ),
              ),
              if (implemented)
                const Icon(Icons.chevron_right)
              else
                const SizedBox(width: 24),
            ],
          ),
        ),
      ),
    );

    return implemented
        ? card
        : Opacity(
            opacity: 0.75,
            child: AbsorbPointer(child: card),
          );
  }
}
