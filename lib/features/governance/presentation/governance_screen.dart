import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/providers/providers.dart';
import '../../../core/models/models.dart';

class GovernanceScreen extends ConsumerWidget {
  const GovernanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposals = ref.watch(proposalsProvider);
    final active = proposals.where((p) => p.status == ProposalStatus.active).toList();
    final past = proposals.where((p) => p.status != ProposalStatus.active).toList();

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
                  Expanded(
                    child: Text('Governance', style: AppTypography.displaySmall),
                  ),
                  GlassButton(
                    label: 'Propose',
                    icon: Icons.add_rounded,
                    isSmall: true,
                    onPressed: () {},
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ─── Voting Power ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: 16,
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentPrimary.withValues(alpha: 0.1),
                    AppColors.glassFill,
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.accentPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.how_to_vote_rounded,
                        color: AppColors.accentPrimary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your Voting Power', style: AppTypography.labelMedium),
                          const SizedBox(height: 2),
                          Text(
                            '1.3x weight (87.5 reputation)',
                            style: AppTypography.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '130 VP',
                        style: AppTypography.labelLarge.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── Active Proposals ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Active Proposals', style: AppTypography.headlineSmall),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _ProposalCard(
                    proposal: active[index],
                    isActive: true,
                  ).animate().fadeIn(duration: 400.ms, delay: (200 + index * 80).ms),
                );
              },
              childCount: active.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── Past Proposals ───
          if (past.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Past Proposals', style: AppTypography.headlineSmall),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _ProposalCard(proposal: past[index])
                        .animate()
                        .fadeIn(duration: 400.ms, delay: (400 + index * 80).ms),
                  );
                },
                childCount: past.length,
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  final Proposal proposal;
  final bool isActive;

  const _ProposalCard({
    required this.proposal,
    this.isActive = false,
  });

  Color get _statusColor {
    return switch (proposal.status) {
      ProposalStatus.active => AppColors.accentPrimary,
      ProposalStatus.passed => AppColors.success,
      ProposalStatus.rejected => AppColors.error,
      ProposalStatus.pending => AppColors.warning,
    };
  }

  String get _statusLabel {
    return switch (proposal.status) {
      ProposalStatus.active => 'Active',
      ProposalStatus.passed => 'Passed',
      ProposalStatus.rejected => 'Rejected',
      ProposalStatus.pending => 'Pending',
    };
  }

  @override
  Widget build(BuildContext context) {
    final totalVotes = proposal.votesFor + proposal.votesAgainst;
    final forPercent = totalVotes > 0 ? proposal.votesFor / totalVotes : 0.0;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      borderRadius: 16,
      borderColor: isActive
          ? AppColors.accentPrimary.withValues(alpha: 0.15)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GlassChip(
                label: proposal.category,
                color: AppColors.accentSecondary,
                isSmall: true,
              ),
              const Spacer(),
              GlassChip(
                label: _statusLabel,
                color: _statusColor,
                isSmall: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(proposal.title, style: AppTypography.headlineSmall),
          const SizedBox(height: 6),
          Text(
            proposal.description,
            style: AppTypography.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),

          // Vote bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'For: ${proposal.votesFor}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                        Text(
                          'Against: ${proposal.votesAgainst}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearPercentIndicator(
                      padding: EdgeInsets.zero,
                      lineHeight: 6,
                      percent: forPercent.clamp(0.0, 1.0),
                      backgroundColor: AppColors.error.withValues(alpha: 0.3),
                      progressColor: AppColors.success,
                      barRadius: const Radius.circular(3),
                      animation: true,
                      animationDuration: 1000,
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (isActive) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    label: 'Vote For',
                    icon: Icons.thumb_up_outlined,
                    isSmall: true,
                    gradient: const LinearGradient(
                      colors: [AppColors.success, Color(0xFF00C853)],
                    ),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GlassButton(
                    label: 'Vote Against',
                    icon: Icons.thumb_down_outlined,
                    isSmall: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.error,
                        AppColors.error.withValues(alpha: 0.7),
                      ],
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(
                  '${proposal.endDate.difference(DateTime.now()).inDays} days remaining',
                  style: AppTypography.labelSmall,
                ),
                const Spacer(),
                Text(
                  'by ${proposal.author}',
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
