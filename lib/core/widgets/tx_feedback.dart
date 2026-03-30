import 'dart:ui';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

// ─── Transaction State ───
enum TxState { submitting, confirming, confirmed, failed }

/// Global overlay-based transaction feedback
class TxFeedback {
  static OverlayEntry? _entry;

  static void show(
    BuildContext context, {
    required TxState state,
    String? title,
    String? message,
    String? txHash,
    Duration duration = const Duration(seconds: 3),
  }) {
    showOnOverlay(
      Overlay.of(context),
      state: state,
      title: title,
      message: message,
      txHash: txHash,
      duration: duration,
    );
  }

  static void showOnOverlay(
    OverlayState overlayState, {
    required TxState state,
    String? title,
    String? message,
    String? txHash,
    Duration duration = const Duration(seconds: 3),
  }) {
    _dismiss();

    _entry = OverlayEntry(
      builder: (_) => _TxToast(
        state: state,
        title: title ?? _defaultTitle(state),
        message: message ?? _defaultMessage(state),
        txHash: txHash,
        onDismiss: _dismiss,
      ),
    );

    overlayState.insert(_entry!);

    if (state == TxState.confirmed || state == TxState.failed) {
      Future.delayed(duration, _dismiss);
    }
  }

  static void _dismiss() {
    _entry?.remove();
    _entry = null;
  }

  static String _defaultTitle(TxState state) => switch (state) {
        TxState.submitting => 'Submitting Transaction',
        TxState.confirming => 'Waiting for Confirmation',
        TxState.confirmed  => 'Transaction Confirmed',
        TxState.failed     => 'Transaction Failed',
      };

  static String _defaultMessage(TxState state) => switch (state) {
        TxState.submitting => 'Signing and broadcasting to the network...',
        TxState.confirming => 'Waiting for block inclusion...',
        TxState.confirmed  => 'Your transaction was confirmed on-chain.',
        TxState.failed     => 'Something went wrong. Please try again.',
      };
}

class _TxToast extends StatefulWidget {
  final TxState state;
  final String title;
  final String message;
  final String? txHash;
  final VoidCallback onDismiss;

  const _TxToast({
    required this.state,
    required this.title,
    required this.message,
    this.txHash,
    required this.onDismiss,
  });

  @override
  State<_TxToast> createState() => _TxToastState();
}

class _TxToastState extends State<_TxToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<double>(begin: -80, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _stateColor => switch (widget.state) {
        TxState.submitting => AppColors.accentPrimary,
        TxState.confirming => AppColors.warning,
        TxState.confirmed  => AppColors.success,
        TxState.failed     => AppColors.error,
      };

  IconData get _stateIcon => switch (widget.state) {
        TxState.submitting => Icons.upload_rounded,
        TxState.confirming => Icons.hourglass_top_rounded,
        TxState.confirmed  => Icons.check_circle_rounded,
        TxState.failed     => Icons.error_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, _slideAnim.value),
          child: Opacity(opacity: _fadeAnim.value, child: child),
        ),
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _stateColor.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: _stateColor.withValues(alpha: 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon / Spinner
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _stateColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: widget.state == TxState.submitting ||
                              widget.state == TxState.confirming
                          ? Padding(
                              padding: const EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation(_stateColor),
                              ),
                            )
                          : Icon(_stateIcon, color: _stateColor, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.title,
                              style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text(widget.message,
                              style: AppTypography.labelSmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          if (widget.txHash != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'TX: ${widget.txHash!.substring(0, 18)}...',
                              style: AppTypography.labelSmall.copyWith(
                                fontFamily: 'monospace',
                                color: _stateColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onDismiss,
                      child: Icon(Icons.close_rounded,
                          color: AppColors.textTertiary, size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Typing Indicator for AI ───
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                final phase = (_controller.value - i * 0.2).clamp(0.0, 1.0);
                final scale = 1.0 + 0.5 * (1 - (2 * phase - 1).abs());
                return Transform.scale(
                  scale: scale.clamp(1.0, 1.5),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.accentPrimary.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

// ─── CountUp Text ───
class CountUpText extends StatelessWidget {
  final double value;
  final String suffix;
  final TextStyle style;
  final Duration duration;

  const CountUpText({
    super.key,
    required this.value,
    this.suffix = '',
    required this.style,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutExpo,
      builder: (_, val, __) => Text(
        '${val.toStringAsFixed(2)}$suffix',
        style: style,
      ),
    );
  }
}

// ─── Blockchain Status Banner ───
enum BlockchainStatus { connected, syncing, offline }

class BlockchainStatusBanner extends StatefulWidget {
  final BlockchainStatus status;

  const BlockchainStatusBanner({super.key, required this.status});

  @override
  State<BlockchainStatusBanner> createState() => _BlockchainStatusBannerState();
}

class _BlockchainStatusBannerState extends State<BlockchainStatusBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _color => switch (widget.status) {
        BlockchainStatus.connected => AppColors.success,
        BlockchainStatus.syncing   => AppColors.warning,
        BlockchainStatus.offline   => AppColors.error,
      };

  String get _label => switch (widget.status) {
        BlockchainStatus.connected => 'Blockchain synced · Live',
        BlockchainStatus.syncing   => 'Syncing with network...',
        BlockchainStatus.offline   => 'Offline · Showing cached data',
      };

  @override
  Widget build(BuildContext context) {
    final isConnected = widget.status == BlockchainStatus.connected;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: isConnected
          ? const SizedBox.shrink()
          : Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: _color.withValues(alpha: 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, __) => Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: _color.withValues(
                            alpha: 0.5 + 0.5 * _pulseController.value),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _label,
                    style: AppTypography.labelSmall.copyWith(color: _color),
                  ),
                ],
              ),
            ),
    );
  }
}
