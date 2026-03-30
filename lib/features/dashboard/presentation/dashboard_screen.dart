import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/providers/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/services/blockchain_service.dart';

enum _EarnState { idle, loading, success }

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  _EarnState _earnState = _EarnState.idle;

  Future<void> _handleEarn() async {
    if (_earnState != _EarnState.idle) return;
    HapticFeedback.mediumImpact();

    setState(() => _earnState = _EarnState.loading);

    // Show submitting toast
    if (!mounted) return;
    final overlayState = Overlay.of(context);
    TxFeedback.showOnOverlay(
      overlayState,
      state: TxState.submitting,
      title: 'Submitting Transaction',
      message: 'Minting 50 Academic Tokens on-chain...',
    );

    await Future.delayed(const Duration(milliseconds: 600));

    // Show confirming
    if (!mounted) return;
    TxFeedback.showOnOverlay(
      overlayState,
      state: TxState.confirming,
      title: 'Waiting for Block',
      message: 'Transaction is pending confirmation...',
    );

    try {
      await blockchainService.earnTokens(0, 50);
      if (!mounted) return;

      TxFeedback.showOnOverlay(
        overlayState,
        state: TxState.confirmed,
        title: 'Tokens Minted!',
        message: '+50 Academic Tokens added to your wallet.',
        txHash: '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
      );
      setState(() => _earnState = _EarnState.success);
      ref.invalidate(tokenBalancesProvider);

      await Future.delayed(const Duration(milliseconds: 1800));
    } catch (e) {
      if (!mounted) return;
      TxFeedback.showOnOverlay(
        overlayState,
        state: TxState.failed,
        title: 'Transaction Failed',
        message: 'Could not connect to the blockchain node.',
      );
    }

    if (mounted) setState(() => _earnState = _EarnState.idle);
  }

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(studentProvider);
    final tokensAsync = ref.watch(tokenBalancesProvider);
    final totalBalanceAsync = ref.watch(totalBalanceProvider);
    final activities = ref.watch(activityFeedProvider);
    final contracts = ref.watch(smartContractsProvider);

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Header ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.gradientPrimary,
                      border: Border.all(color: AppColors.glassBorder, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        student.name.split(' ').map((e) => e[0]).join(),
                        style: AppTypography.labelLarge.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back,', style: AppTypography.bodySmall),
                        Text(student.name, style: AppTypography.headlineMedium),
                      ],
                    ),
                  ),
                  // Notification bell with pulse dot
                  GlassCard(
                    padding: const EdgeInsets.all(10),
                    borderRadius: 14,
                    child: Stack(
                      children: [
                        const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.8, end: 1.2),
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeInOut,
                            onEnd: () => setState(() {}),
                            builder: (_, v, __) => Transform.scale(
                              scale: v,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.accentPrimary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── Balance Card ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GlassCard(
                padding: const EdgeInsets.all(24),
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentPrimary.withValues(alpha: 0.15),
                    AppColors.accentPrimaryEnd.withValues(alpha: 0.08),
                    AppColors.glassFill,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Total Balance', style: AppTypography.bodySmall),
                        const Spacer(),
                        GlassChip(
                          label: 'Rep: ${student.reputationScore.toStringAsFixed(1)}',
                          icon: Icons.star_rounded,
                          color: AppColors.accentGold,
                          isSmall: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // CountUp balance
                    totalBalanceAsync.when(
                      data: (balance) => CountUpText(
                        value: balance,
                        suffix: ' CC',
                        style: AppTypography.displayMedium,
                      ),
                      loading: () => const SizedBox(
                        height: 40,
                        width: 150,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      error: (_, __) => Text(
                        'unavailable',
                        style: AppTypography.displayMedium.copyWith(color: AppColors.error),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.trending_up_rounded, size: 16, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text(
                          '+5.2% today',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.success),
                        ),
                        const Spacer(),
                        // Last updated
                        StreamBuilder<DateTime>(
                          stream: Stream.periodic(
                            const Duration(seconds: 30),
                            (_) => DateTime.now(),
                          ).map((_) => DateTime.now()),
                          builder: (_, snap) => Text(
                            'Updated just now',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Quick Actions
                    Row(
                      children: [
                        _QuickActionButton(
                          icon: _earnState == _EarnState.loading
                              ? null
                              : _earnState == _EarnState.success
                                  ? Icons.check_circle_rounded
                                  : Icons.auto_awesome_rounded,
                          label: _earnState == _EarnState.success ? 'Minted!' : 'Earn',
                          color: _earnState == _EarnState.success
                              ? AppColors.success
                              : AppColors.accentPrimary,
                          isLoading: _earnState == _EarnState.loading,
                          onTap: _handleEarn,
                        ),
                        const SizedBox(width: 12),
                        _QuickActionButton(
                          icon: Icons.arrow_downward_rounded,
                          label: 'Receive',
                          color: AppColors.accentSecondary,
                          onTap: () => _showComingSoon(context, 'Receive'),
                        ),
                        const SizedBox(width: 12),
                        _QuickActionButton(
                          icon: Icons.qr_code_scanner_rounded,
                          label: 'Scan',
                          color: AppColors.accentGold,
                          onTap: () => _showComingSoon(context, 'QR Scan'),
                        ),
                        const SizedBox(width: 12),
                        _QuickActionButton(
                          icon: Icons.swap_horiz_rounded,
                          label: 'Convert',
                          color: AppColors.tokenImpact,
                          onTap: () => _showComingSoon(context, 'Convert'),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: 0.05),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── Token Breakdown ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Tokens', style: AppTypography.headlineSmall),
                  const SizedBox(height: 12),
                  tokensAsync.when(
                    data: (tokens) => Row(
                      children: tokens.map((token) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: token != tokens.last ? 10 : 0),
                            child: _TokenMiniCard(token: token),
                          ),
                        );
                      }).toList(),
                    ),
                    loading: () => const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => const Text('Failed to load tokens'),
                  ),
                ],
              ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.05),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── Active Contracts ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Smart Contracts', style: AppTypography.headlineSmall),
                      const Spacer(),
                      Text(
                        'See all',
                        style: AppTypography.labelMedium.copyWith(color: AppColors.accentPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 130,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: contracts.where((c) => c.status != ContractStatus.completed).length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final active = contracts.where((c) => c.status != ContractStatus.completed).toList();
                        return _ContractCard(contract: active[index]);
                      },
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.05),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── Activity Feed ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text('Live Activity', style: AppTypography.headlineSmall),
                  const SizedBox(width: 8),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.3, 1.3), duration: 800.ms),
                  const Spacer(),
                  Text(
                    'View all',
                    style: AppTypography.labelMedium.copyWith(color: AppColors.accentPrimary),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final activity = activities[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _ActivityTile(activity: activity)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: (400 + index * 80).ms)
                      .slideX(begin: 0.08),
                );
              },
              childCount: activities.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.construction_rounded, color: AppColors.accentGold, size: 18),
            const SizedBox(width: 10),
            Text('$feature — coming soon', style: AppTypography.labelMedium),
          ],
        ),
        backgroundColor: AppColors.surfaceCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.glassBorder),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ─── Quick Action Button ───
class _QuickActionButton extends StatefulWidget {
  final IconData? icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isLoading;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 100.ms);
    _scale = Tween(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _scale,
          builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
          child: Column(
            children: [
              AnimatedContainer(
                duration: 200.ms,
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: widget.color.withValues(alpha: 0.25)),
                ),
                child: widget.isLoading
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(widget.color),
                        ),
                      )
                    : AnimatedSwitcher(
                        duration: 200.ms,
                        child: Icon(widget.icon, color: widget.color, size: 22,
                            key: ValueKey(widget.icon)),
                      ),
              ),
              const SizedBox(height: 6),
              AnimatedSwitcher(
                duration: 200.ms,
                child: Text(
                  widget.label,
                  key: ValueKey(widget.label),
                  style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Token Mini Card ───
class _TokenMiniCard extends StatelessWidget {
  final TokenBalance token;
  const _TokenMiniCard({required this.token});

  Color get _color => switch (token.type) {
        TokenType.academic => AppColors.tokenAcademic,
        TokenType.utility  => AppColors.tokenUtility,
        TokenType.impact   => AppColors.tokenImpact,
      };

  @override
  Widget build(BuildContext context) {
    final isPositive = token.changePercent24h >= 0;

    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      borderColor: _color.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(token.type.emoji, style: const TextStyle(fontSize: 16)),
              const Spacer(),
              if (token.multiplier > 1.0)
                GlassChip(label: '${token.multiplier}x', color: AppColors.accentGold, isSmall: true),
            ],
          ),
          const SizedBox(height: 8),
          // Utility token: live expiry countdown
          if (token.type == TokenType.utility && token.expiresAt != null)
            StreamBuilder<Duration>(
              stream: Stream.periodic(
                const Duration(seconds: 1),
                (_) => token.expiresAt!.difference(DateTime.now()),
              ),
              builder: (_, snap) => Text(
                token.balance.toStringAsFixed(0),
                style: AppTypography.statNumber.copyWith(color: _color),
              ),
            )
          else
            CountUpText(
              value: token.balance,
              suffix: '',
              style: AppTypography.statNumber.copyWith(color: _color),
              duration: const Duration(milliseconds: 900),
            ),
          const SizedBox(height: 2),
          // Utility: show live countdown instead of static label
          if (token.type == TokenType.utility && token.expiresAt != null)
            StreamBuilder<Duration>(
              stream: Stream.periodic(
                const Duration(seconds: 1),
                (_) => token.expiresAt!.difference(DateTime.now()),
              ),
              builder: (_, snap) {
                final d = snap.data ?? token.expiresAt!.difference(DateTime.now());
                final isUrgent = d.inDays < 3;
                return AnimatedDefaultTextStyle(
                  duration: 300.ms,
                  style: AppTypography.labelSmall.copyWith(
                    color: isUrgent ? AppColors.error : AppColors.warning,
                    fontSize: 9,
                  ),
                  child: Text(
                    'Expires: ${d.inDays}d ${d.inHours.remainder(24)}h',
                  ),
                );
              },
            )
          else
            Text(token.type.label, style: AppTypography.labelSmall),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                size: 12,
                color: isPositive ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 2),
              Text(
                '${isPositive ? '+' : ''}${token.changePercent24h.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 10,
                  color: isPositive ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Contract Card ───
class _ContractCard extends StatelessWidget {
  final SmartContractCondition contract;
  const _ContractCard({required this.contract});

  @override
  Widget build(BuildContext context) {
    final isUpcoming = contract.status == ContractStatus.upcoming;
    return GlassCard(
      width: 220,
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 18,
                color: isUpcoming ? AppColors.textSecondary : AppColors.accentPrimary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  contract.title,
                  style: AppTypography.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: contract.progress,
              minHeight: 4,
              backgroundColor: AppColors.glassFill,
              valueColor: AlwaysStoppedAnimation(
                isUpcoming ? AppColors.textTertiary : AppColors.accentPrimary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text('${(contract.progress * 100).toInt()}% complete', style: AppTypography.labelSmall),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.card_giftcard_rounded, size: 14, color: AppColors.accentGold),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  contract.reward,
                  style: AppTypography.labelSmall.copyWith(color: AppColors.accentGold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Activity Tile ───
class _ActivityTile extends StatelessWidget {
  final ActivityItem activity;
  const _ActivityTile({required this.activity});

  IconData get _icon => switch (activity.iconType) {
        IconType.attendance  => Icons.school_rounded,
        IconType.payment     => Icons.restaurant_rounded,
        IconType.reward      => Icons.emoji_events_rounded,
        IconType.scholarship => Icons.workspace_premium_rounded,
        IconType.governance  => Icons.how_to_vote_rounded,
        IconType.marketplace => Icons.storefront_rounded,
        IconType.transfer    => Icons.swap_horiz_rounded,
      };

  Color get _iconColor => switch (activity.iconType) {
        IconType.attendance  => AppColors.tokenAcademic,
        IconType.payment     => AppColors.tokenUtility,
        IconType.reward      => AppColors.accentGold,
        IconType.scholarship => AppColors.accentGold,
        IconType.governance  => AppColors.accentPrimary,
        IconType.marketplace => AppColors.tokenImpact,
        IconType.transfer    => AppColors.accentSecondary,
      };

  String _timeAgo() {
    final diff = DateTime.now().difference(activity.timestamp);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: _iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title, style: AppTypography.labelMedium,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(activity.subtitle, style: AppTypography.labelSmall,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (activity.amount != null)
                Text(
                  '${activity.amount! > 0 ? '+' : ''}${activity.amount!.toStringAsFixed(0)}',
                  style: AppTypography.labelMedium.copyWith(
                    color: activity.amount! > 0 ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              // Live time-ago updates every 30s
              StreamBuilder<int>(
                stream: Stream.periodic(const Duration(seconds: 30), (i) => i),
                builder: (_, __) => Text(_timeAgo(), style: AppTypography.labelSmall),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
