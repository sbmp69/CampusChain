import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/services/blockchain_service.dart';

void showReceiveSheet(BuildContext context) {
  HapticFeedback.selectionClick();
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _ReceiveSheet(),
  );
}

void showScanSheet(BuildContext context) {
  HapticFeedback.selectionClick();
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _ScanSheet(),
  );
}

void showConvertSheet(BuildContext context) {
  HapticFeedback.selectionClick();
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _ConvertSheet(),
  );
}

// ─── Receive Sheet ───
class _ReceiveSheet extends StatelessWidget {
  const _ReceiveSheet();

  @override
  Widget build(BuildContext context) {
    final address = blockchainService.currentWallet.toString();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Receive Tokens', style: AppTypography.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Scan QR or share your address',
              style: AppTypography.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: 30),
          
          Text('Address', style: AppTypography.labelMedium),
          const SizedBox(height: 8),
          // Address box
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.glassFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      address,
                      style: AppTypography.bodySmall.copyWith(
                        fontFamily: 'monospace',
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.glassBorder,
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: address));
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Address copied to clipboard!'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: Container(
                    width: 50,
                    alignment: Alignment.center,
                    child: Icon(Icons.copy_rounded, color: AppColors.textSecondary, size: 20),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // QR Code
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImageView(
                data: address,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(child: Divider(color: AppColors.glassBorder)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Or', style: AppTypography.labelSmall),
              ),
              Expanded(child: Divider(color: AppColors.glassBorder)),
            ],
          ),
          
          const SizedBox(height: 20),
          GlassButton(
            label: 'Share Address',
            icon: Icons.share_rounded,
            onPressed: () {
              HapticFeedback.mediumImpact();
              // Mock share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing sheet opened!')),
              );
            },
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, duration: 350.ms, curve: Curves.easeOutCubic);
  }
}

// ─── Scan Sheet ───
class _ScanSheet extends StatelessWidget {
  const _ScanSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Scan QR Code', style: AppTypography.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text("Scan a peer's address or a smart contract",
              style: AppTypography.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: 40),
          
          // Mock Camera View
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentPrimary.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Corner brackets
                  Positioned(top: 20, left: 20, child: _corner(0)),
                  Positioned(top: 20, right: 20, child: _corner(1)),
                  Positioned(bottom: 20, right: 20, child: _corner(2)),
                  Positioned(bottom: 20, left: 20, child: _corner(3)),
                  
                  // Scanning line
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: -100.0, end: 100.0),
                    duration: const Duration(seconds: 2),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, value),
                        child: Container(
                          width: 200,
                          height: 2,
                          decoration: BoxDecoration(
                            color: AppColors.accentPrimary,
                            boxShadow: [
                              BoxShadow(color: AppColors.accentPrimary, blurRadius: 10, spreadRadius: 2),
                            ],
                          ),
                        ),
                      );
                    },
                    onEnd: () {
                      // Just re-run or loop (this is a simple un-looped tween, we use a trick below)
                    },
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true)),
                  
                  const Icon(Icons.camera_alt_rounded, color: Colors.white24, size: 60),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          GlassButton(
            label: 'Demo Scan Success',
            gradient: AppColors.gradientSecondary,
            onPressed: () {
              Navigator.pop(context);
              TxFeedback.showOnOverlay(
                Overlay.of(context),
                state: TxState.confirmed,
                title: 'QR Scanned!',
                message: 'Address recognized. Ready to transfer.',
              );
            },
          ),
          const SizedBox(height: 12),
          GlassButton(
            label: 'Cancel',
            isSmall: true,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, duration: 350.ms, curve: Curves.easeOutCubic);
  }

  Widget _corner(int index) {
    return RotatedBox(
      quarterTurns: index,
      child: CustomPaint(
        size: const Size(30, 30),
        painter: _BracketPainter(),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentPrimary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Convert Sheet ───
class _ConvertSheet extends StatefulWidget {
  const _ConvertSheet();

  @override
  State<_ConvertSheet> createState() => _ConvertSheetState();
}

class _ConvertSheetState extends State<_ConvertSheet> {
  bool _isConverting = false;

  void _doConvert() async {
    setState(() => _isConverting = true);
    HapticFeedback.mediumImpact();
    
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      Navigator.pop(context);
      TxFeedback.showOnOverlay(
        Overlay.of(context),
        state: TxState.confirmed,
        title: 'Conversion Complete',
        message: 'Successfully swapped tokens.',
        txHash: '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Swap Tokens', style: AppTypography.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Exchange Academic, Utility, or Impact tokens instantly via DEX.',
              style: AppTypography.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: 30),
          
          // From Card
          _TokenSelectorBox(label: 'You pay', defaultToken: 'Academic Tokens', defaultAmount: '100', color: AppColors.tokenAcademic),
          
          // Swap icon
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.glassFill,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: const Icon(Icons.swap_vert_rounded, color: AppColors.accentPrimary),
            ),
          ),
          
          // To Card
          _TokenSelectorBox(label: 'You receive (est)', defaultToken: 'Utility Tokens', defaultAmount: '98', color: AppColors.tokenUtility),
          
          const SizedBox(height: 30),
          
          GlassButton(
            label: _isConverting ? 'Processing Swap...' : 'Confirm Swap',
            icon: _isConverting ? Icons.hourglass_top_rounded : Icons.sync_alt_rounded,
            gradient: AppColors.gradientPrimary,
            onPressed: _isConverting ? null : _doConvert,
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, duration: 350.ms, curve: Curves.easeOutCubic);
  }
}

class _TokenSelectorBox extends StatelessWidget {
  final String label;
  final String defaultToken;
  final String defaultAmount;
  final Color color;

  const _TokenSelectorBox({
    required this.label,
    required this.defaultToken,
    required this.defaultAmount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                defaultAmount,
                style: AppTypography.displaySmall.copyWith(color: AppColors.textPrimary),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(defaultToken, style: AppTypography.labelMedium),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down_rounded, color: AppColors.textTertiary),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
