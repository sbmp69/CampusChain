import 'dart:ui';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Glassmorphic container with frosted blur effect
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blur;
  final Color? fillColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.blur = 12,
    this.fillColor,
    this.borderColor,
    this.width,
    this.height,
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: gradient ??
                LinearGradient(
                  colors: [
                    fillColor ?? AppColors.glassFill,
                    (fillColor ?? AppColors.glassFill).withValues(alpha: 0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? AppColors.glassBorder,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            splashColor: AppColors.accentPrimary.withValues(alpha: 0.1),
            highlightColor: Colors.white.withValues(alpha: 0.05),
            child: card,
          ),
        ),
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: card,
    );
  }
}
