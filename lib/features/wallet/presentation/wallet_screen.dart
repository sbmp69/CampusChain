import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/providers/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/data/mock_data.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTokenIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tokensAsync = ref.watch(tokenBalancesProvider);
    final transactions = ref.watch(transactionsProvider);
    final chartData = ref.watch(chartDataProvider);

    return SafeArea(
      child: tokensAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading wallet: $err')),
        data: (tokens) => CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
          // ─── Header ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text('Wallet', style: AppTypography.displaySmall)
                  .animate()
                  .fadeIn(duration: 400.ms),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ─── Token Tabs ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: List.generate(tokens.length, (i) {
                  final t = tokens[i];
                  final isSelected = i == _selectedTokenIndex;
                  final color = _tokenColor(t.type);

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTokenIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: EdgeInsets.only(right: i < tokens.length - 1 ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: 0.15)
                              : AppColors.glassFill,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? color.withValues(alpha: 0.4)
                                : AppColors.glassBorder,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(t.type.emoji, style: const TextStyle(fontSize: 20)),
                            const SizedBox(height: 4),
                            Text(
                              t.type.label,
                              style: AppTypography.labelSmall.copyWith(
                                color: isSelected ? color : AppColors.textSecondary,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ─── Selected Token Details ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                borderColor: _tokenColor(tokens[_selectedTokenIndex].type)
                    .withValues(alpha: 0.2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${tokens[_selectedTokenIndex].type.emoji} ${tokens[_selectedTokenIndex].type.label} Tokens',
                          style: AppTypography.headlineSmall,
                        ),
                        const Spacer(),
                        if (tokens[_selectedTokenIndex].multiplier > 1.0)
                          GlassChip(
                            label: '${tokens[_selectedTokenIndex].multiplier}x Boost',
                            icon: Icons.bolt_rounded,
                            color: AppColors.accentGold,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tokens[_selectedTokenIndex].balance.toStringAsFixed(2),
                      style: AppTypography.displayLarge.copyWith(
                        color: _tokenColor(tokens[_selectedTokenIndex].type),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          tokens[_selectedTokenIndex].changePercent24h >= 0
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 16,
                          color: tokens[_selectedTokenIndex].changePercent24h >= 0
                              ? AppColors.success
                              : AppColors.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${tokens[_selectedTokenIndex].changePercent24h >= 0 ? '+' : ''}${tokens[_selectedTokenIndex].changePercent24h.toStringAsFixed(1)}% past 24h',
                          style: AppTypography.labelSmall.copyWith(
                            color: tokens[_selectedTokenIndex].changePercent24h >= 0
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                        if (tokens[_selectedTokenIndex].expiresAt != null) ...[
                          const Spacer(),
                          Icon(Icons.timer_outlined, size: 14, color: AppColors.warning),
                          const SizedBox(width: 4),
                          Text(
                            'Expires in ${tokens[_selectedTokenIndex].expiresAt!.difference(DateTime.now()).inDays}d',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ─── Chart ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('7-Day Trend', style: AppTypography.headlineSmall),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 160,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() < MockData.chartLabels.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        MockData.chartLabels[value.toInt()],
                                        style: AppTypography.labelSmall,
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: chartData.asMap().entries.map((e) {
                                return FlSpot(e.key.toDouble(), e.value);
                              }).toList(),
                              isCurved: true,
                              curveSmoothness: 0.3,
                              color: _tokenColor(tokens[_selectedTokenIndex].type),
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, bar, index) {
                                  return FlDotCirclePainter(
                                    radius: 3,
                                    color: _tokenColor(tokens[_selectedTokenIndex].type),
                                    strokeWidth: 2,
                                    strokeColor: AppColors.surfaceDark,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    _tokenColor(tokens[_selectedTokenIndex].type)
                                        .withValues(alpha: 0.3),
                                    _tokenColor(tokens[_selectedTokenIndex].type)
                                        .withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── Transaction History ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Transaction History', style: AppTypography.headlineSmall),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final tx = transactions[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _TransactionTile(transaction: tx)
                      .animate()
                      .fadeIn(duration: 300.ms, delay: (400 + index * 60).ms)
                      .slideX(begin: 0.03),
                );
              },
              childCount: transactions.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      ),
    );
  }

  Color _tokenColor(TokenType type) {
    return switch (type) {
      TokenType.academic => AppColors.tokenAcademic,
      TokenType.utility => AppColors.tokenUtility,
      TokenType.impact => AppColors.tokenImpact,
    };
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const _TransactionTile({required this.transaction});

  IconData get _icon {
    return switch (transaction.type) {
      TransactionType.earned => Icons.arrow_downward_rounded,
      TransactionType.spent => Icons.arrow_upward_rounded,
      TransactionType.received => Icons.call_received_rounded,
      TransactionType.sent => Icons.call_made_rounded,
    };
  }

  Color get _color {
    return switch (transaction.type) {
      TransactionType.earned => AppColors.success,
      TransactionType.spent => AppColors.error,
      TransactionType.received => AppColors.accentSecondary,
      TransactionType.sent => AppColors.warning,
    };
  }

  String get _timeAgo {
    final diff = DateTime.now().difference(transaction.timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      borderRadius: 14,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: _color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        transaction.title,
                        style: AppTypography.labelMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (transaction.isAutomatic)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: GlassChip(
                          label: 'AUTO',
                          color: AppColors.accentSecondary,
                          isSmall: true,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.description,
                  style: AppTypography.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.amount > 0 ? '+' : ''}${transaction.amount.toStringAsFixed(0)}',
                style: AppTypography.labelLarge.copyWith(
                  color: transaction.amount > 0 ? AppColors.success : AppColors.error,
                ),
              ),
              Text(_timeAgo, style: AppTypography.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}
