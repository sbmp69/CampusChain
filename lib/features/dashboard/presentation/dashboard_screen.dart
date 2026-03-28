import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/providers/providers.dart';
import '../../../core/models/models.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(studentProvider);
    final tokens = ref.watch(tokenBalancesProvider);
    final totalBalance = ref.watch(totalBalanceProvider);
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
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.gradientPrimary,
                      border: Border.all(
                        color: AppColors.glassBorder,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        student.name.split(' ').map((e) => e[0]).join(),
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: AppTypography.bodySmall,
                        ),
                        Text(
                          student.name,
                          style: AppTypography.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                  // Notification bell
                  GlassCard(
                    padding: const EdgeInsets.all(10),
                    borderRadius: 14,
                    child: Badge(
                      smallSize: 8,
                      backgroundColor: AppColors.accentPrimary,
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
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
                        Text(
                          'Total Balance',
                          style: AppTypography.bodySmall,
                        ),
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
                    Text(
                      '${totalBalance.toStringAsFixed(2)} CC',
                      style: AppTypography.displayMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+5.2% today',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Quick Actions
                    Row(
                      children: [
                        _QuickActionButton(
                          icon: Icons.arrow_upward_rounded,
                          label: 'Send',
                          color: AppColors.accentPrimary,
                        ),
                        const SizedBox(width: 12),
                        _QuickActionButton(
                          icon: Icons.arrow_downward_rounded,
                          label: 'Receive',
                          color: AppColors.accentSecondary,
                        ),
                        const SizedBox(width: 12),
                        _QuickActionButton(
                          icon: Icons.qr_code_scanner_rounded,
                          label: 'Scan',
                          color: AppColors.accentGold,
                        ),
                        const SizedBox(width: 12),
                        _QuickActionButton(
                          icon: Icons.swap_horiz_rounded,
                          label: 'Convert',
                          color: AppColors.tokenImpact,
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
                  Row(
                    children: tokens.map((token) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: token != tokens.last ? 10 : 0,
                          ),
                          child: _TokenMiniCard(token: token),
                        ),
                      );
                    }).toList(),
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
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.accentPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 130,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: contracts.where((c) => c.status != ContractStatus.completed).length,
                      separatorBuilder: (context2, index2) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final activeContracts = contracts.where((c) => c.status != ContractStatus.completed).toList();
                        return _ContractCard(contract: activeContracts[index]);
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
                  Text('Smart Activity', style: AppTypography.headlineSmall),
                  const Spacer(),
                  Text(
                    'View all',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.accentPrimary,
                    ),
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
                      .slideX(begin: 0.05),
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
}

// ─── Quick Action Button ───
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Token Mini Card ───
class _TokenMiniCard extends StatelessWidget {
  final TokenBalance token;

  const _TokenMiniCard({required this.token});

  Color get _color {
    return switch (token.type) {
      TokenType.academic => AppColors.tokenAcademic,
      TokenType.utility => AppColors.tokenUtility,
      TokenType.impact => AppColors.tokenImpact,
    };
  }

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
                GlassChip(
                  label: '${token.multiplier}x',
                  color: AppColors.accentGold,
                  isSmall: true,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            token.balance.toStringAsFixed(0),
            style: AppTypography.statNumber.copyWith(color: _color),
          ),
          const SizedBox(height: 2),
          Text(
            token.type.label,
            style: AppTypography.labelSmall,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
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
                color: isUpcoming
                    ? AppColors.textSecondary
                    : AppColors.accentPrimary,
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
          // Progress bar
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
          Text(
            '${(contract.progress * 100).toInt()}% complete',
            style: AppTypography.labelSmall,
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                Icons.card_giftcard_rounded,
                size: 14,
                color: AppColors.accentGold,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  contract.reward,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.accentGold,
                  ),
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

  IconData get _icon {
    return switch (activity.iconType) {
      IconType.attendance => Icons.school_rounded,
      IconType.payment => Icons.restaurant_rounded,
      IconType.reward => Icons.emoji_events_rounded,
      IconType.scholarship => Icons.workspace_premium_rounded,
      IconType.governance => Icons.how_to_vote_rounded,
      IconType.marketplace => Icons.storefront_rounded,
      IconType.transfer => Icons.swap_horiz_rounded,
    };
  }

  Color get _iconColor {
    return switch (activity.iconType) {
      IconType.attendance => AppColors.tokenAcademic,
      IconType.payment => AppColors.tokenUtility,
      IconType.reward => AppColors.accentGold,
      IconType.scholarship => AppColors.accentGold,
      IconType.governance => AppColors.accentPrimary,
      IconType.marketplace => AppColors.tokenImpact,
      IconType.transfer => AppColors.accentSecondary,
    };
  }

  String get _timeAgo {
    final diff = DateTime.now().difference(activity.timestamp);
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
                Text(
                  activity.title,
                  style: AppTypography.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  activity.subtitle,
                  style: AppTypography.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
                    color: activity.amount! > 0
                        ? AppColors.success
                        : AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              Text(
                _timeAgo,
                style: AppTypography.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
