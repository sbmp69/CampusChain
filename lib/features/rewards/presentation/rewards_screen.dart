import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/providers/providers.dart';
import '../../../core/models/models.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final missions = ref.watch(missionsProvider);
    final leaderboard = ref.watch(leaderboardProvider);

    return SafeArea(
      child: Column(
        children: [
          // ─── Header ───
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Text('Rewards & Missions', style: AppTypography.displaySmall),
              ],
            ).animate().fadeIn(duration: 400.ms),
          ),

          const SizedBox(height: 16),

          // ─── Tab Bar ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.glassFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
                dividerColor: Colors.transparent,
                labelStyle: AppTypography.labelMedium,
                unselectedLabelStyle: AppTypography.labelMedium,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                tabs: const [
                  Tab(text: '🎯 Missions'),
                  Tab(text: '🏆 Leaderboard'),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
          ),

          const SizedBox(height: 16),

          // ─── Tab Views ───
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Missions tab
                _MissionsTab(missions: missions),
                // Leaderboard tab
                _LeaderboardTab(leaderboard: leaderboard),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionsTab extends StatelessWidget {
  final List<Mission> missions;

  const _MissionsTab({required this.missions});

  @override
  Widget build(BuildContext context) {
    final claimable = missions.where((m) => m.isCompleted && !m.isClaimed).toList();
    final active = missions.where((m) => !m.isCompleted).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Claimable rewards
        if (claimable.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('🎉 Ready to Claim', style: AppTypography.headlineSmall),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _MissionCard(
                    mission: claimable[index],
                    isClaimable: true,
                  ).animate().fadeIn(duration: 400.ms, delay: (index * 80).ms),
                );
              },
              childCount: claimable.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],

        // Active missions
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Active Missions', style: AppTypography.headlineSmall),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _MissionCard(mission: active[index])
                    .animate()
                    .fadeIn(duration: 400.ms, delay: ((claimable.length + index) * 80).ms),
              );
            },
            childCount: active.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _MissionCard extends StatelessWidget {
  final Mission mission;
  final bool isClaimable;

  const _MissionCard({
    required this.mission,
    this.isClaimable = false,
  });

  Color get _tokenColor {
    return switch (mission.rewardType) {
      TokenType.academic => AppColors.tokenAcademic,
      TokenType.utility => AppColors.tokenUtility,
      TokenType.impact => AppColors.tokenImpact,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      borderColor: isClaimable
          ? AppColors.accentGold.withValues(alpha: 0.3)
          : null,
      gradient: isClaimable
          ? LinearGradient(
              colors: [
                AppColors.accentGold.withValues(alpha: 0.1),
                AppColors.glassFill,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(mission.title, style: AppTypography.headlineSmall),
                        const SizedBox(width: 8),
                        GlassChip(
                          label: mission.category,
                          color: _tokenColor,
                          isSmall: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mission.description,
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _tokenColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '${mission.rewardTokens}',
                      style: AppTypography.statNumber.copyWith(color: _tokenColor),
                    ),
                    Text(
                      mission.rewardType.emoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar
          Row(
            children: [
              Expanded(
                child: LinearPercentIndicator(
                  padding: EdgeInsets.zero,
                  lineHeight: 8,
                  percent: mission.progressPercent.clamp(0, 1),
                  backgroundColor: AppColors.glassFill,
                  linearGradient: LinearGradient(
                    colors: isClaimable
                        ? [AppColors.accentGold, AppColors.accentGoldEnd]
                        : [_tokenColor, _tokenColor.withValues(alpha: 0.6)],
                  ),
                  barRadius: const Radius.circular(4),
                  animation: true,
                  animationDuration: 1000,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${mission.currentProgress}/${mission.targetProgress}',
                style: AppTypography.labelMedium.copyWith(
                  color: _tokenColor,
                ),
              ),
            ],
          ),
          if (isClaimable) ...[
            const SizedBox(height: 14),
            GlassButton(
              label: 'Claim Reward',
              icon: Icons.card_giftcard_rounded,
              gradient: AppColors.gradientGold,
              isSmall: true,
              onPressed: () {},
            ),
          ],
          if (mission.deadline != null && !isClaimable) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(
                  '${mission.deadline!.difference(DateTime.now()).inDays} days left',
                  style: AppTypography.labelSmall,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LeaderboardTab extends StatelessWidget {
  final List<LeaderboardEntry> leaderboard;

  const _LeaderboardTab({required this.leaderboard});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Top 3 podium
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (leaderboard.length > 1)
                  _PodiumItem(
                    entry: leaderboard[1],
                    height: 100,
                    color: const Color(0xFFC0C0C0),
                    medal: '🥈',
                  ),
                if (leaderboard.isNotEmpty)
                  _PodiumItem(
                    entry: leaderboard[0],
                    height: 130,
                    color: AppColors.accentGold,
                    medal: '🥇',
                  ),
                if (leaderboard.length > 2)
                  _PodiumItem(
                    entry: leaderboard[2],
                    height: 80,
                    color: const Color(0xFFCD7F32),
                    medal: '🥉',
                  ),
              ],
            ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
          ),
        ),

        // Remaining entries
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final actualIndex = index + 3;
              if (actualIndex >= leaderboard.length) return null;
              final entry = leaderboard[actualIndex];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  borderRadius: 14,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        child: Text(
                          '#${entry.rank}',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.accentPrimary.withValues(alpha: 0.2),
                        child: Text(
                          entry.name.split(' ').map((e) => e[0]).join(),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.accentPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.name, style: AppTypography.labelMedium),
                            Text(entry.department, style: AppTypography.labelSmall),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${entry.reputationScore}',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.accentGold,
                            ),
                          ),
                          Text(
                            '${entry.totalTokens} CC',
                            style: AppTypography.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: (300 + index * 80).ms),
              );
            },
            childCount: (leaderboard.length - 3).clamp(0, leaderboard.length),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final double height;
  final Color color;
  final String medal;

  const _PodiumItem({
    required this.entry,
    required this.height,
    required this.color,
    required this.medal,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(medal, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Text(
              entry.name.split(' ').map((e) => e[0]).join(),
              style: AppTypography.labelMedium.copyWith(color: color),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            entry.name.split(' ').first,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
          ),
          const SizedBox(height: 8),
          Container(
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.3),
                  color.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${entry.reputationScore}',
                    style: AppTypography.statNumber.copyWith(color: color),
                  ),
                  Text(
                    '${entry.totalTokens}',
                    style: AppTypography.labelSmall.copyWith(
                      color: color.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
