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

enum _BuyState { idle, processing, success }

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  static const _categories = ['All', 'Notes', 'Tutoring', 'Events', 'Resources', 'Volunteering'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MarketListing> _applyFilters(List<MarketListing> listings) {
    return listings.where((l) {
      final matchesCategory = _selectedCategory == 'All' || l.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          l.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.seller.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final listings = ref.watch(marketListingsProvider);
    final filtered = _applyFilters(listings);

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
                    child: Text('Marketplace', style: AppTypography.displaySmall),
                  ),
                  GlassButton(
                    label: 'Sell',
                    icon: Icons.add_rounded,
                    isSmall: true,
                    gradient: AppColors.gradientSecondary,
                    onPressed: () => _showSellDialog(context),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ─── Search Bar ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                borderRadius: 14,
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: AppTypography.bodyMedium,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Search services, notes, tutoring...',
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          setState(() => _searchQuery = '');
                          _searchController.clear();
                        },
                        child: Icon(Icons.close_rounded,
                            color: AppColors.textSecondary, size: 18),
                      ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ─── Category Filter (hidden when searching) ───
          SliverToBoxAdapter(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _searchQuery.isNotEmpty
                  ? const SizedBox.shrink()
                  : SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _categories.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final isSelected = cat == _selectedCategory;

                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedCategory = cat);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                gradient: isSelected ? AppColors.gradientPrimary : null,
                                color: isSelected ? null : AppColors.glassFill,
                                borderRadius: BorderRadius.circular(10),
                                border: isSelected
                                    ? null
                                    : Border.all(color: AppColors.glassBorder),
                              ),
                              child: Center(
                                child: Text(
                                  cat,
                                  style: AppTypography.labelMedium.copyWith(
                                    color: isSelected ? Colors.white : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                    ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ─── Result Count ───
          if (_searchQuery.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  '${filtered.length} result${filtered.length == 1 ? '' : 's'} for "$_searchQuery"',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.accentPrimary),
                ),
              ),
            ),

          // ─── Listings ───
          filtered.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded,
                            color: AppColors.textTertiary, size: 48),
                        const SizedBox(height: 12),
                        Text('No listings found', style: AppTypography.headlineSmall),
                        const SizedBox(height: 4),
                        Text('Try a different search or category',
                            style: AppTypography.bodySmall),
                      ],
                    ).animate().fadeIn(duration: 400.ms),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Padding(
                          key: ValueKey(filtered[index].id),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _ListingCard(
                            listing: filtered[index],
                            onBuy: () => _showPurchaseFlow(context, filtered[index]),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: (index * 60).ms)
                              .slideY(begin: 0.03),
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showPurchaseFlow(BuildContext context, MarketListing listing) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PurchaseSheet(listing: listing),
    );
  }

  void _showSellDialog(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SellSheet(),
    );
  }
}

// ─── Listing Card ───
class _ListingCard extends StatefulWidget {
  final MarketListing listing;
  final VoidCallback onBuy;

  const _ListingCard({required this.listing, required this.onBuy});

  @override
  State<_ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<_ListingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 100.ms);
    _scale = Tween(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _tokenColor {
    return switch (widget.listing.priceTokenType) {
      TokenType.academic => AppColors.tokenAcademic,
      TokenType.utility  => AppColors.tokenUtility,
      TokenType.impact   => AppColors.tokenImpact,
    };
  }

  String get _timeAgo {
    final diff = DateTime.now().difference(widget.listing.postedAt);
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
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
          widget.onBuy();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: GlassCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          borderRadius: 16,
          borderColor: _tokenColor.withValues(alpha: 0.12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GlassChip(
                    label: widget.listing.category,
                    color: _tokenColor,
                    isSmall: true,
                  ),
                  const Spacer(),
                  Text(_timeAgo, style: AppTypography.labelSmall),
                ],
              ),
              const SizedBox(height: 10),
              Text(widget.listing.title, style: AppTypography.headlineSmall),
              const SizedBox(height: 6),
              Text(
                widget.listing.description,
                style: AppTypography.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  // Seller info
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.accentSecondary.withValues(alpha: 0.15),
                    child: Text(
                      widget.listing.seller.split(' ').map((e) => e[0]).join(),
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.accentSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.listing.seller,
                        style: AppTypography.labelSmall.copyWith(color: AppColors.textPrimary),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, size: 12, color: AppColors.accentGold),
                          const SizedBox(width: 2),
                          Text(
                            widget.listing.sellerReputation.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.accentGold,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // Verified badge for high rep
                          if (widget.listing.sellerReputation >= 90) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.verified_rounded,
                                size: 11, color: AppColors.accentPrimary),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Price + Tap hint
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _tokenColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _tokenColor.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.listing.price == 0
                                  ? 'Free'
                                  : widget.listing.price.toStringAsFixed(0),
                              style: AppTypography.labelLarge.copyWith(color: _tokenColor),
                            ),
                            if (widget.listing.price > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                widget.listing.priceTokenType.emoji,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to ${widget.listing.price == 0 ? "register" : "buy"}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Purchase Sheet ───
class _PurchaseSheet extends ConsumerStatefulWidget {
  final MarketListing listing;
  const _PurchaseSheet({required this.listing});

  @override
  ConsumerState<_PurchaseSheet> createState() => _PurchaseSheetState();
}

class _PurchaseSheetState extends ConsumerState<_PurchaseSheet> {
  _BuyState _state = _BuyState.idle;

  Color get _tokenColor => switch (widget.listing.priceTokenType) {
        TokenType.academic => AppColors.tokenAcademic,
        TokenType.utility  => AppColors.tokenUtility,
        TokenType.impact   => AppColors.tokenImpact,
      };

  Future<void> _purchase() async {
    HapticFeedback.mediumImpact();
    setState(() => _state = _BuyState.processing);

    final overlayState = Overlay.of(context);
    TxFeedback.showOnOverlay(
      overlayState,
      state: TxState.submitting,
      title: 'Processing Purchase',
      message: 'Initiating token transfer on-chain...',
    );

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;
    TxFeedback.showOnOverlay(
      overlayState,
      state: TxState.confirming,
      title: 'Confirming Transfer',
      message: 'Waiting for blockchain confirmation...',
    );

    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      final tokenId = widget.listing.priceTokenType.index;
      await blockchainService.spendTokens(tokenId, widget.listing.price);
      ref.invalidate(tokenBalancesProvider);

      setState(() => _state = _BuyState.success);
      TxFeedback.showOnOverlay(
        overlayState,
        state: TxState.confirmed,
        title: 'Purchase Complete!',
        message: 'You bought "${widget.listing.title}" from ${widget.listing.seller}.',
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          GlassChip(label: widget.listing.category, color: _tokenColor, isSmall: true),
          const SizedBox(height: 12),
          Text(widget.listing.title, style: AppTypography.headlineMedium),
          const SizedBox(height: 8),
          Text(widget.listing.description, style: AppTypography.bodySmall),
          const SizedBox(height: 20),
          // Seller row
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.accentSecondary.withValues(alpha: 0.15),
                child: Text(
                  widget.listing.seller.split(' ').map((e) => e[0]).join(),
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.accentSecondary,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.listing.seller, style: AppTypography.labelMedium),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 12, color: AppColors.accentGold),
                      const SizedBox(width: 3),
                      Text(
                        '${widget.listing.sellerReputation.toStringAsFixed(1)} reputation',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.accentGold),
                      ),
                    ],
                  ),
                ],
              ),
              if (widget.listing.sellerReputation >= 90) ...[
                const Spacer(),
                GlassChip(label: '✓ Verified', color: AppColors.success, isSmall: true),
              ],
            ],
          ),
          const SizedBox(height: 24),
          // Price row
          Row(
            children: [
              Text('Total Cost', style: AppTypography.labelMedium),
              const Spacer(),
              Text(
                widget.listing.price == 0
                    ? 'Free'
                    : '${widget.listing.price.toStringAsFixed(0)} ${widget.listing.priceTokenType.emoji}',
                style: AppTypography.headlineMedium.copyWith(color: _tokenColor),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Action button
          SizedBox(
            width: double.infinity,
            child: AnimatedSwitcher(
              duration: 300.ms,
              child: _state == _BuyState.success
                  ? Container(
                      key: const ValueKey('success'),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.success, size: 22),
                          const SizedBox(width: 10),
                          Text('Purchase Successful!',
                              style: AppTypography.labelLarge.copyWith(color: AppColors.success)),
                        ],
                      ),
                    ).animate().scale(begin: const Offset(0.9, 0.9), duration: 300.ms, curve: Curves.elasticOut)
                  : GlassButton(
                      key: const ValueKey('buy'),
                      label: _state == _BuyState.processing ? 'Processing...' : 'Confirm Purchase',
                      icon: _state == _BuyState.processing
                          ? Icons.hourglass_top_rounded
                          : Icons.shopping_cart_rounded,
                      width: double.infinity,
                      onPressed: _state == _BuyState.idle ? _purchase : null,
                    ),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, duration: 350.ms, curve: Curves.easeOutCubic);
  }
}

// ─── Sell Sheet ───
class _SellSheet extends StatelessWidget {
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Text('Create Listing', style: AppTypography.headlineMedium),
          const SizedBox(height: 8),
          Text('Peer-to-peer token marketplace listings coming soon.',
              style: AppTypography.bodySmall),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.construction_rounded, color: AppColors.warning),
              const SizedBox(width: 8),
              Text('Feature in development', style: AppTypography.labelMedium.copyWith(color: AppColors.warning)),
            ],
          ),
          const SizedBox(height: 20),
          GlassButton(
            label: 'Got It',
            width: double.infinity,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, duration: 350.ms, curve: Curves.easeOutCubic);
  }
}
