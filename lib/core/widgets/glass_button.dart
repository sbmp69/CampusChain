import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// Gradient-bordered interactive button
class GlassButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient? gradient;
  final bool isSmall;
  final bool isOutlined;
  final double? width;

  const GlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.gradient,
    this.isSmall = false,
    this.isOutlined = false,
    this.width,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grad = widget.gradient ?? AppColors.gradientPrimary;
    final vertPad = widget.isSmall ? 10.0 : 14.0;
    final horizPad = widget.isSmall ? 20.0 : 28.0;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onPressed?.call();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          width: widget.width,
          padding: EdgeInsets.symmetric(
            vertical: vertPad,
            horizontal: horizPad,
          ),
          decoration: BoxDecoration(
            gradient: widget.isOutlined ? null : grad,
            borderRadius: BorderRadius.circular(14),
            border: widget.isOutlined
                ? Border.all(
                    color: AppColors.accentPrimary.withValues(alpha: 0.5),
                    width: 1.5,
                  )
                : null,
            boxShadow: widget.isOutlined
                ? null
                : [
                    BoxShadow(
                      color: AppColors.accentPrimary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: widget.isSmall ? 16 : 20,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: (widget.isSmall
                        ? AppTypography.labelMedium
                        : AppTypography.labelLarge)
                    .copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
