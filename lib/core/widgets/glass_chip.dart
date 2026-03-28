import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Gradient chip for token types and status badges
class GlassChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Gradient? gradient;
  final Color? color;
  final bool isSmall;

  const GlassChip({
    super.key,
    required this.label,
    this.icon,
    this.gradient,
    this.color,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.accentPrimary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null
            ? chipColor.withValues(alpha: 0.15)
            : null,
        borderRadius: BorderRadius.circular(isSmall ? 8 : 10),
        border: Border.all(
          color: chipColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: isSmall ? 12 : 14,
              color: chipColor,
            ),
            SizedBox(width: isSmall ? 4 : 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }
}
