import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/widgets/widgets.dart';
import '../core/providers/providers.dart';
import '../core/services/blockchain_service.dart';
import 'theme/app_colors.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/wallet/presentation/wallet_screen.dart';
import '../features/rewards/presentation/rewards_screen.dart';
import '../features/governance/presentation/governance_screen.dart';
import '../features/marketplace/presentation/marketplace_screen.dart';
import '../features/ai_assistant/presentation/ai_assistant_screen.dart';
import '../features/profile/presentation/profile_screen.dart';

/// Blockchain connectivity status provider
final blockchainStatusProvider =
    StateProvider<BlockchainStatus>((ref) => BlockchainStatus.syncing);

/// Main app shell with bottom navigation and animated gradient
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final _screens = const [
    DashboardScreen(),
    WalletScreen(),
    RewardsScreen(),
    GovernanceScreen(),
    MarketplaceScreen(),
  ];

  bool _showAiAssistant = false;
  bool _showProfile = false;

  @override
  void initState() {
    super.initState();
    _checkBlockchainStatus();
  }

  Future<void> _checkBlockchainStatus() async {
    try {
      ref.read(blockchainStatusProvider.notifier).state =
          BlockchainStatus.syncing;
      await blockchainService.getTokenBalance(0);
      if (mounted) {
        ref.read(blockchainStatusProvider.notifier).state =
            BlockchainStatus.connected;
      }
    } catch (_) {
      if (mounted) {
        ref.read(blockchainStatusProvider.notifier).state =
            BlockchainStatus.offline;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(currentTabProvider);
    final blockchainStatus = ref.watch(blockchainStatusProvider);

    Widget body;
    if (_showAiAssistant) {
      body = const AiAssistantScreen();
    } else if (_showProfile) {
      body = const ProfileScreen();
    } else {
      body = IndexedStack(
        index: currentTab,
        children: _screens,
      );
    }

    return Scaffold(
      extendBody: true,
      body: AnimatedGradientBackground(
        child: Column(
          children: [
            // ─── Blockchain Status Banner ───
            BlockchainStatusBanner(status: blockchainStatus),

            // ─── Main Content ───
            Expanded(
              child: Stack(
                children: [
                  body,

                  // ─── Bottom Nav + FAB ───
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // AI + Profile row above nav
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Profile button
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showProfile = !_showProfile;
                                    _showAiAssistant = false;
                                  });
                                },
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: _showProfile
                                        ? AppColors.accentPrimary
                                            .withValues(alpha: 0.2)
                                        : AppColors.surfaceCard
                                            .withValues(alpha: 0.9),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _showProfile
                                          ? AppColors.accentPrimary
                                              .withValues(alpha: 0.4)
                                          : AppColors.glassBorder,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.person_outline_rounded,
                                    color: _showProfile
                                        ? AppColors.accentPrimary
                                        : AppColors.textSecondary,
                                    size: 22,
                                  ),
                                ),
                              ),
                              // AI FAB
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showAiAssistant = !_showAiAssistant;
                                    _showProfile = false;
                                  });
                                },
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: _showAiAssistant
                                        ? null
                                        : AppColors.gradientPrimary,
                                    color: _showAiAssistant
                                        ? AppColors.accentPrimary
                                            .withValues(alpha: 0.2)
                                        : null,
                                    shape: BoxShape.circle,
                                    boxShadow: _showAiAssistant
                                        ? null
                                        : [
                                            BoxShadow(
                                              color: AppColors.accentPrimary
                                                  .withValues(alpha: 0.4),
                                              blurRadius: 20,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                  ),
                                  child: Icon(
                                    _showAiAssistant
                                        ? Icons.close_rounded
                                        : Icons.auto_awesome_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        GlassNavBar(
                          currentIndex: currentTab,
                          onTap: (index) {
                            ref.read(currentTabProvider.notifier).state = index;
                            setState(() {
                              _showAiAssistant = false;
                              _showProfile = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


