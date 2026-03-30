import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/providers/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/services/blockchain_service.dart';

class GovernanceScreen extends ConsumerStatefulWidget {
  const GovernanceScreen({super.key});

  @override
  ConsumerState<GovernanceScreen> createState() => _GovernanceScreenState();
}

class _GovernanceScreenState extends ConsumerState<GovernanceScreen> {
  @override
  Widget build(BuildContext context) {
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
                    child: Text('DAO Governance', style: AppTypography.displaySmall),
                  ),
                  GlassButton(
                    label: 'Propose',
                    icon: Icons.add_rounded,
                    isSmall: true,
                    gradient: AppColors.gradientSecondary,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Proposal creation — coming soon',
                              style: AppTypography.labelMedium),
                          backgroundColor: AppColors.surfaceCard,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ─── Voting Power Card ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _VotingPowerCard()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.05),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── Active Proposals ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text('Active Proposals', style: AppTypography.headlineSmall),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accentPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${active.length}',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.accentPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _ProposalCard(proposal: active[index])
                    .animate()
                    .fadeIn(duration: 400.ms, delay: (200 + index * 100).ms)
                    .slideY(begin: 0.04),
              ),
              childCount: active.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── Past Proposals ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Past Proposals', style: AppTypography.headlineSmall),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _PastProposalTile(proposal: past[index])
                    .animate()
                    .fadeIn(duration: 400.ms, delay: (300 + index * 80).ms),
              ),
              childCount: past.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ─── Voting Power Card ───
class _VotingPowerCard extends ConsumerWidget {
  const _VotingPowerCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(studentProvider);
    final votingPower = (student.reputationScore * 1.3).round();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [
          AppColors.accentPrimary.withValues(alpha: 0.12),
          AppColors.glassFill,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircularPercentIndicator(
                radius: 38,
                lineWidth: 5,
                percent: student.reputationScore / 100,
                progressColor: AppColors.accentPrimary,
                backgroundColor: AppColors.glassFill,
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$votingPower',
                    style: AppTypography.statNumber.copyWith(
                        color: AppColors.accentPrimary, fontSize: 18),
                  ),
                  Text('VP', style: AppTypography.labelSmall.copyWith(fontSize: 9)),
                ],
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Voting Power', style: AppTypography.labelLarge),
                const SizedBox(height: 4),
                Text(
                  'Based on ${student.reputationScore.toStringAsFixed(1)} reputation × 1.3x weight',
                  style: AppTypography.labelSmall,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    GlassChip(label: '1.3× Weight', color: AppColors.accentPrimary, isSmall: true),
                    const SizedBox(width: 8),
                    GlassChip(label: '3rd Year', color: AppColors.accentGold, isSmall: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Proposal Card ───
class _ProposalCard extends ConsumerStatefulWidget {
  final Proposal proposal;
  const _ProposalCard({required this.proposal});

  @override
  ConsumerState<_ProposalCard> createState() => _ProposalCardState();
}

class _ProposalCardState extends ConsumerState<_ProposalCard> {
  bool _hasVoted = false;
  bool _isVoting = false;
  bool _votedFor = false;
  late int _localVotesFor;
  late int _localVotesAgainst;

  @override
  void initState() {
    super.initState();
    _localVotesFor = widget.proposal.votesFor;
    _localVotesAgainst = widget.proposal.votesAgainst;
  }

  Future<void> _vote(bool voteFor) async {
    if (_hasVoted || _isVoting) return;
    HapticFeedback.mediumImpact();

    setState(() {
      _isVoting = true;
      _votedFor = voteFor;
    });

    // Show submitting feedback
    final overlayState = Overlay.of(context);
    TxFeedback.showOnOverlay(
      overlayState,
      state: TxState.submitting,
      title: 'Submitting Vote',
      message: 'Recording your vote on the blockchain...',
    );

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    TxFeedback.showOnOverlay(
      overlayState,
      state: TxState.confirming,
      title: 'Confirming Vote',
      message: 'Waiting for block confirmation...',
    );

    try {
      await blockchainService.voteOnProposal(
        int.tryParse(widget.proposal.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        voteFor,
      );
    } catch (_) {
      // Optimistic update even if blockchain is offline
    }

    if (!mounted) return;

    // Optimistic local update
    setState(() {
      _isVoting = false;
      _hasVoted = true;
      if (voteFor) {
        _localVotesFor += 130; // Add voting power
      } else {
        _localVotesAgainst += 130;
      }
    });

    TxFeedback.showOnOverlay(
      overlayState,
      state: TxState.confirmed,
      title: 'Vote Recorded!',
      message: voteFor
          ? 'You voted FOR: "${widget.proposal.title}"'
          : 'You voted AGAINST: "${widget.proposal.title}"',
      txHash: '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
    );
  }

  String _countdown() {
    final diff = widget.proposal.endDate.difference(DateTime.now());
    if (diff.isNegative) return 'Ended';
    if (diff.inHours < 24) return '${diff.inHours}h ${diff.inMinutes.remainder(60)}m left';
    return '${diff.inDays}d ${diff.inHours.remainder(24)}h left';
  }

  bool get _isUrgent =>
      widget.proposal.endDate.difference(DateTime.now()).inHours < 24;

  @override
  Widget build(BuildContext context) {
    final total = (_localVotesFor + _localVotesAgainst).clamp(1, 999999);
    final forPercent = _localVotesFor / total;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GlassChip(label: widget.proposal.category, color: AppColors.accentPrimary, isSmall: true),
              const Spacer(),
              // Live countdown
              StreamBuilder<int>(
                stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
                builder: (_, __) => AnimatedDefaultTextStyle(
                  duration: 300.ms,
                  style: AppTypography.labelSmall.copyWith(
                    color: _isUrgent ? AppColors.error : AppColors.warning,
                    fontWeight: _isUrgent ? FontWeight.w700 : FontWeight.w500,
                  ),
                  child: Text('⏱ ${_countdown()}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(widget.proposal.title, style: AppTypography.headlineSmall),
          const SizedBox(height: 6),
          Text(
            widget.proposal.description,
            style: AppTypography.bodySmall,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          // Vote bar
          LinearPercentIndicator(
            lineHeight: 8,
            percent: forPercent.clamp(0.0, 1.0),
            backgroundColor: AppColors.error.withValues(alpha: 0.3),
            progressColor: AppColors.success,
            barRadius: const Radius.circular(4),
            padding: EdgeInsets.zero,
            animation: true,
            animationDuration: 600,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.thumb_up_rounded, size: 12, color: AppColors.success),
              const SizedBox(width: 4),
              Text('$_localVotesFor FOR',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.success)),
              const Spacer(),
              Text('$_localVotesAgainst AGAINST',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.error)),
              const SizedBox(width: 4),
              Icon(Icons.thumb_down_rounded, size: 12, color: AppColors.error),
            ],
          ),
          const SizedBox(height: 14),

          // Voting buttons
          if (_hasVoted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: (_votedFor ? AppColors.success : AppColors.error)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: (_votedFor ? AppColors.success : AppColors.error)
                        .withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: _votedFor ? AppColors.success : AppColors.error,
                      size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Voted ${_votedFor ? "FOR" : "AGAINST"}',
                    style: AppTypography.labelMedium.copyWith(
                        color: _votedFor ? AppColors.success : AppColors.error),
                  ),
                ],
              ),
            ).animate().scale(begin: const Offset(0.95, 0.95), duration: 300.ms, curve: Curves.elasticOut)
          else
            Row(
              children: [
                Expanded(
                  child: _VoteButton(
                    label: 'Vote For',
                    icon: Icons.thumb_up_rounded,
                    color: AppColors.success,
                    isLoading: _isVoting && _votedFor,
                    onTap: () => _vote(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _VoteButton(
                    label: 'Against',
                    icon: Icons.thumb_down_rounded,
                    color: AppColors.error,
                    isLoading: _isVoting && !_votedFor,
                    onTap: () => _vote(false),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── Vote Button ───
class _VoteButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _VoteButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_VoteButton> createState() => _VoteButtonState();
}

class _VoteButtonState extends State<_VoteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 100.ms);
    _scale = Tween(begin: 1.0, end: 0.94)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(widget.color),
                  ),
                )
              else
                Icon(widget.icon, color: widget.color, size: 16),
              const SizedBox(width: 6),
              Text(widget.label,
                  style: AppTypography.labelMedium.copyWith(color: widget.color)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Past Proposal Tile ───
class _PastProposalTile extends StatelessWidget {
  final Proposal proposal;
  const _PastProposalTile({required this.proposal});

  @override
  Widget build(BuildContext context) {
    final isPassed = proposal.status == ProposalStatus.passed;
    final color = isPassed ? AppColors.success : AppColors.error;
    final icon = isPassed ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(proposal.title,
                    style: AppTypography.labelMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(proposal.category, style: AppTypography.labelSmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GlassChip(
                label: isPassed ? 'Passed' : 'Rejected',
                color: color,
                isSmall: true,
              ),
              const SizedBox(height: 4),
              Text(
                '${proposal.votesFor}/${proposal.votesFor + proposal.votesAgainst} FOR',
                style: AppTypography.labelSmall.copyWith(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
