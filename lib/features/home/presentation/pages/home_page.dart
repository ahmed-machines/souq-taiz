import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/responsive_context.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/controllers/category_providers.dart';
import '../../../categories/presentation/widgets/category_card.dart';
import '../../../listings/presentation/controllers/listing_providers.dart';
import '../../../listings/presentation/widgets/listing_grid.dart';

/// Marketplace home page — professional layout with hero, stats, categories,
/// featured listings, promo card, and footer.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final categories = ref.watch(topCategoriesProvider);
    final featured = ref.watch(featuredListingsProvider);
    final latest = ref.watch(latestListingsProvider);
    final recommended = ref.watch(recommendedListingsProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero banner ──────────────────────────────────────
          const _HeroBanner(),

          // ── Stats strip ──────────────────────────────────────
          const _StatsStrip(),

          const SizedBox(height: 28),

          // ── Categories ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SectionHeader(
              title: l10n.homePopularCategories,
              icon: Icons.grid_view_rounded,
            ),
          ),
          const SizedBox(height: 14),
          _CategoriesRow(categories: categories),

          const SizedBox(height: 32),

          // ── Featured listings ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SectionHeader(
              title: l10n.homeFeatured,
              icon: Icons.star_rounded,
              iconColor: AppColors.secondary,
              onSeeAll: () => context.go('${RouteNames.search}?featured=1'),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AsyncListingGrid(
              listings: featured,
              onRetry: () => ref.invalidate(featuredListingsProvider),
            ),
          ),

          const SizedBox(height: 32),

          // ── Promo card ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _PromoCard(),
          ),

          const SizedBox(height: 32),

          // ── Recommended ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SectionHeader(
              title: l10n.homeRecommended,
              icon: Icons.thumb_up_alt_rounded,
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AsyncListingGrid(
              listings: recommended,
              onRetry: () => ref.invalidate(recommendedListingsProvider),
            ),
          ),

          const SizedBox(height: 32),

          // ── Latest ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SectionHeader(
              title: l10n.homeLatest,
              icon: Icons.access_time_filled_rounded,
              onSeeAll: () => context.go(RouteNames.search),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AsyncListingGrid(
              listings: latest,
              onRetry: () => ref.invalidate(latestListingsProvider),
            ),
          ),

          const SizedBox(height: 32),

          // ── Featured shops ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SectionHeader(
              title: l10n.homeFeaturedShops,
              icon: Icons.storefront_rounded,
            ),
          ),
          const SizedBox(height: 14),
          const _FeaturedShopsRow(),

          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

// ── Hero Banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMobile = context.isMobile;

    return Container(
      width: double.infinity,
      height: isMobile ? 270 : 380,
      decoration: const BoxDecoration(gradient: AppColors.heroBgGradient),
      child: Stack(
        children: [
          // Decorative background circles
          const PositionedDirectional(
            end: -50,
            top: -50,
            child: _Circle(size: 220, opacity: 0.06),
          ),
          const PositionedDirectional(
            start: -30,
            bottom: -40,
            child: _Circle(
              size: 180,
              color: AppColors.secondary,
              opacity: 0.10,
            ),
          ),
          const PositionedDirectional(
            end: 70,
            bottom: 50,
            child: _Circle(size: 90, opacity: 0.07),
          ),
          const PositionedDirectional(
            start: 60,
            top: 30,
            child: _Circle(size: 60, opacity: 0.05),
          ),

          // Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 22 : 56,
              vertical: isMobile ? 30 : 52,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Location badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.secondary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'تعز · اليمن',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Headline
                Text(
                  l10n.homeBannerTitle,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: isMobile ? 24 : 34,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 10),

                // Sub-text
                Text(
                  l10n.tagline,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 26),

                // CTA buttons
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    // Primary CTA
                    GestureDetector(
                      onTap: () => context.go(RouteNames.sellerNew),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.amberGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add_circle_outline_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.navSell,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Secondary CTA
                    GestureDetector(
                      onTap: () => context.go(RouteNames.search),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.search,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

class _Circle extends StatelessWidget {
  const _Circle({required this.size, this.color, this.opacity = 0.08});
  final double size;
  final Color? color;
  final double opacity;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: (color ?? Colors.white).withValues(alpha: opacity),
    ),
  );
}

// ── Stats strip ───────────────────────────────────────────────────────────────

class _StatsStrip extends StatelessWidget {
  const _StatsStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.inventory_2_rounded,
            value: '+٥٠٠٠',
            label: 'إعلان نشط',
          ),
          _VerticalDivider(),
          _StatItem(
            icon: Icons.people_alt_rounded,
            value: '+٢٠٠٠',
            label: 'مستخدم',
          ),
          _VerticalDivider(),
          _StatItem(
            icon: Icons.location_city_rounded,
            value: '١٠+',
            label: 'منطقة',
          ),
          _VerticalDivider(),
          _StatItem(icon: Icons.category_rounded, value: '١٠', label: 'تصنيف'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: AppColors.primary, size: 22),
      const SizedBox(height: 4),
      Text(
        value,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) =>
      Container(height: 36, width: 1, color: AppColors.divider);
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    this.iconColor,
    this.onSeeAll,
  });
  final String title;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        // Accent bar
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.seeAll,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Categories row ────────────────────────────────────────────────────────────

class _CategoriesRow extends StatelessWidget {
  const _CategoriesRow({required this.categories});
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (ctx, i) {
          final c = categories[i];
          return CategoryCard(
            category: c,
            onTap: () => context.go(RouteNames.searchPath(category: c.id)),
          );
        },
      ),
    );
  }
}

// ── Promo card ────────────────────────────────────────────────────────────────

class _PromoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.amberGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أضف إعلانك مجاناً',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'بيع منتجاتك وخدماتك بسهولة وسرعة لآلاف المشترين في تعز',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () => context.go(RouteNames.sellerNew),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.secondary,
                          size: 17,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.navSell,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Featured shops ────────────────────────────────────────────────────────────

class _FeaturedShopsRow extends StatelessWidget {
  const _FeaturedShopsRow();

  static const _shops = [
    (
      name: 'متجر الأمين',
      icon: Icons.phone_android_rounded,
      color: Color(0xFF5C6BC0),
    ),
    (
      name: 'سيارات العرب',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF26A69A),
    ),
    (
      name: 'الإلكترونيات',
      icon: Icons.computer_rounded,
      color: Color(0xFFEF5350),
    ),
    (name: 'عقارات تعز', icon: Icons.home_rounded, color: Color(0xFF66BB6A)),
    (
      name: 'ملابس فاشون',
      icon: Icons.checkroom_rounded,
      color: Color(0xFFAB47BC),
    ),
    (
      name: 'بيت الأثاث',
      icon: Icons.chair_alt_rounded,
      color: Color(0xFFFF7043),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _shops.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (ctx, i) {
          final s = _shops[i];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: s.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: s.color.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: s.color.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(s.icon, color: s.color, size: 30),
              ),
              const SizedBox(height: 8),
              Text(
                s.name,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
