import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/providers/providers.dart';
import '../../../core/models/models.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  String _selectedCategory = 'All';

  static const _categories = ['All', 'Notes', 'Tutoring', 'Events', 'Resources', 'Volunteering'];

  @override
  Widget build(BuildContext context) {
    final listings = ref.watch(marketListingsProvider);
    final filtered = _selectedCategory == 'All'
        ? listings
        : listings.where((l) => l.category == _selectedCategory).toList();

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
                    onPressed: () {},
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
                        style: AppTypography.bodyMedium,
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
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ─── Category Filter ───
          SliverToBoxAdapter(
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                separatorBuilder: (context2, index2) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
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
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ─── Listings ───
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _ListingCard(listing: filtered[index])
                      .animate()
                      .fadeIn(duration: 400.ms, delay: (300 + index * 80).ms)
                      .slideY(begin: 0.03),
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
}

class _ListingCard extends StatelessWidget {
  final MarketListing listing;

  const _ListingCard({required this.listing});

  Color get _tokenColor {
    return switch (listing.priceTokenType) {
      TokenType.academic => AppColors.tokenAcademic,
      TokenType.utility => AppColors.tokenUtility,
      TokenType.impact => AppColors.tokenImpact,
    };
  }

  String get _timeAgo {
    final diff = DateTime.now().difference(listing.postedAt);
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GlassChip(
                label: listing.category,
                color: _tokenColor,
                isSmall: true,
              ),
              const Spacer(),
              Text(_timeAgo, style: AppTypography.labelSmall),
            ],
          ),
          const SizedBox(height: 10),
          Text(listing.title, style: AppTypography.headlineSmall),
          const SizedBox(height: 6),
          Text(
            listing.description,
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
                  listing.seller.split(' ').map((e) => e[0]).join(),
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
                    listing.seller,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 12, color: AppColors.accentGold),
                      const SizedBox(width: 2),
                      Text(
                        listing.sellerReputation.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.accentGold,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              // Price
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _tokenColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _tokenColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      listing.price == 0
                          ? 'Free'
                          : listing.price.toStringAsFixed(0),
                      style: AppTypography.labelLarge.copyWith(
                        color: _tokenColor,
                      ),
                    ),
                    if (listing.price > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        listing.priceTokenType.emoji,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
