import 'package:flutter/material.dart';

import '../../app/localization/generated/app_localizations.dart';
import '../../app/theme/app_colors.dart';
import '../../core/extensions/responsive_context.dart';

/// Elegant site footer with brand, navigation links, and social section.
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMobile = context.isMobile;

    return Container(
      color: AppColors.primaryDark,
      child: Column(
        children: [
          // ── Main content ──
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 56,
              vertical: 40,
            ),
            child: isMobile
                ? _MobileContent(l10n: l10n)
                : _DesktopContent(l10n: l10n),
          ),

          // ── Divider ──
          Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),

          // ── Bottom bar ──
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 6,
              children: [
                Text(
                  '© ${DateTime.now().year} ${l10n.appName}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 12,
                  ),
                ),
                Text(
                  '·',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.25),
                    fontSize: 12,
                  ),
                ),
                Text(
                  l10n.footerRights,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Desktop layout ────────────────────────────────────────────────────────────

class _DesktopContent extends StatelessWidget {
  const _DesktopContent({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand column
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BrandBlock(l10n: l10n),
              const SizedBox(height: 20),
              Text(
                l10n.tagline,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  height: 1.6,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              const _SocialRow(),
            ],
          ),
        ),

        const SizedBox(width: 48),

        // Links columns
        Expanded(
          child: _LinkColumn(
            title: 'روابط مفيدة',
            items: [l10n.footerAbout, l10n.footerHelp, l10n.footerContact],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _LinkColumn(
            title: 'قانوني',
            items: [l10n.footerTerms, l10n.footerPrivacy],
          ),
        ),
      ],
    );
  }
}

// ── Mobile layout ─────────────────────────────────────────────────────────────

class _MobileContent extends StatelessWidget {
  const _MobileContent({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(child: _BrandBlock(l10n: l10n, centered: true)),
        const SizedBox(height: 10),
        Text(
          l10n.tagline,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        const _SocialRow(centered: true),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          runSpacing: 10,
          children: [
            for (final item in [
              l10n.footerAbout,
              l10n.footerHelp,
              l10n.footerTerms,
              l10n.footerPrivacy,
              l10n.footerContact,
            ])
              Text(
                item,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 13,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _BrandBlock extends StatelessWidget {
  const _BrandBlock({required this.l10n, this.centered = false});
  final AppLocalizations l10n;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: centered
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      mainAxisSize: centered ? MainAxisSize.min : MainAxisSize.max,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: AppColors.amberGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.storefront_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          l10n.appName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SocialRow extends StatelessWidget {
  const _SocialRow({this.centered = false});
  final bool centered;

  static const _icons = [
    Icons.facebook_rounded,
    Icons.telegram,
    Icons.phone_rounded,
    Icons.email_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: centered
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: _icons.map((icon) {
        return Container(
          margin: const EdgeInsetsDirectional.only(end: 8),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Icon(icon, color: Colors.white70, size: 18),
        );
      }).toList(),
    );
  }
}

class _LinkColumn extends StatelessWidget {
  const _LinkColumn({required this.title, required this.items});
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 16),
        for (final item in items) ...[
          Text(
            item,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
