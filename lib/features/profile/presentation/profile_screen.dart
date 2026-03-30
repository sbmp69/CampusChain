import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/providers/providers.dart';


class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(studentProvider);
    final tokensAsync = ref.watch(tokenBalancesProvider);

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
                  Text('Profile', style: AppTypography.displaySmall),
                  const Spacer(),
                  GlassCard(
                    padding: const EdgeInsets.all(10),
                    borderRadius: 14,
                    child: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── Profile Card ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GlassCard(
                padding: const EdgeInsets.all(24),
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentPrimary.withValues(alpha: 0.12),
                    AppColors.glassFill,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.gradientPrimary,
                        border: Border.all(
                          color: AppColors.glassBorder,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          student.name.split(' ').map((e) => e[0]).join(),
                          style: AppTypography.headlineLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(student.name, style: AppTypography.headlineLarge),
                    const SizedBox(height: 4),
                    Text(
                      '${student.department} • ${student.year}',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fingerprint_rounded, size: 14, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          student.walletAddress,
                          style: AppTypography.labelSmall.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Reputation ring
                    CircularPercentIndicator(
                      radius: 48,
                      lineWidth: 6,
                      percent: student.reputationScore / 100,
                      center: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            student.reputationScore.toStringAsFixed(1),
                            style: AppTypography.statNumber.copyWith(
                              color: AppColors.accentGold,
                            ),
                          ),
                          Text(
                            'Reputation',
                            style: TextStyle(
                              fontSize: 8,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      progressColor: AppColors.accentGold,
                      backgroundColor: AppColors.glassFill,
                      circularStrokeCap: CircularStrokeCap.round,
                      animation: true,
                      animationDuration: 1200,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ─── Stats Grid ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _StatCard(
                    label: 'Milestones',
                    value: '${student.academicMilestones}',
                    icon: Icons.emoji_events_rounded,
                    color: AppColors.accentGold,
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    label: 'Total Tokens',
                    value: tokensAsync.valueOrNull != null
                        ? tokensAsync.valueOrNull!.fold(0.0, (sum, t) => sum + t.balance).toStringAsFixed(0)
                        : '...',
                    icon: Icons.token_rounded,
                    color: AppColors.accentPrimary,
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    label: 'Member Since',
                    value: '2024',
                    icon: Icons.calendar_month_rounded,
                    color: AppColors.accentSecondary,
                  ),
                ],
              ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── Menu Items ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Account', style: AppTypography.headlineSmall),
                  const SizedBox(height: 12),
                  _MenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Wallet Identity',
                    subtitle: 'Blockchain address & keys',
                    color: AppColors.accentPrimary,
                  ),
                  _MenuItem(
                    icon: Icons.security_rounded,
                    label: 'Security',
                    subtitle: 'Biometric & 2FA settings',
                    color: AppColors.accentSecondary,
                  ),
                  _MenuItem(
                    icon: Icons.history_rounded,
                    label: 'Contribution History',
                    subtitle: 'Your campus impact',
                    color: AppColors.tokenImpact,
                  ),
                  _MenuItem(
                    icon: Icons.school_outlined,
                    label: 'Academic Records',
                    subtitle: 'Grades, attendance, milestones',
                    color: AppColors.accentGold,
                  ),
                  _MenuItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    subtitle: 'Alert preferences',
                    color: AppColors.warning,
                  ),
                  _MenuItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & Support',
                    subtitle: 'FAQ, contact, feedback',
                    color: AppColors.info,
                  ),
                ].animate(interval: 80.ms).fadeIn(duration: 300.ms, delay: 300.ms).slideX(begin: 0.03),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        borderRadius: 14,
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value, style: AppTypography.statNumber.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      borderRadius: 14,
      onTap: () {},
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.labelMedium),
                Text(subtitle, style: AppTypography.labelSmall),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
            size: 22,
          ),
        ],
      ),
    );
  }
}
