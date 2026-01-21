import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable Branded Header for both Admin and Student Portals
/// Ensures visual consistency and alignment across the app
class BrandedHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final List<Widget>? actions;
  final bool showLogo;
  final bool showBackButton;
  final VoidCallback? onBack;

  const BrandedHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.actions,
    this.showLogo = true,
    this.showBackButton = false,
    this.onBack,
  });

  void _handleLogoTap(BuildContext context) {
    // SECURITY: Logo click clears intermediate stack and goes to module Home
    // Since Home is pushed as replacement from Login, route.isFirst is Home
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showBackButton) ...[
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                      ),
                      onPressed: onBack ?? () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (showLogo)
                    GestureDetector(
                      onTap: () => _handleLogoTap(context),
                      child: Hero(
                        tag: 'app_logo',
                        child: Image.asset(
                          'assets/images/logo.jpg',
                          height: 32,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 32),
                ],
              ),
              if (actions != null)
                Row(mainAxisSize: MainAxisSize.min, children: actions!)
              else if (trailing != null)
                trailing!,
            ],
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.headingLarge.copyWith(
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: AppTheme.bodyMedium.copyWith(
                  color: const Color(0xFF666666),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A simpler header for sub-pages
class SubPageHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const SubPageHeader({super.key, required this.title, this.onBack});

  void _handleLogoTap(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: onBack ?? () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          GestureDetector(
            onTap: () => _handleLogoTap(context),
            child: Image.asset(
              'assets/images/logo.jpg',
              height: 24,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: AppTheme.headingSmall.copyWith(letterSpacing: -0.5),
          ),
        ],
      ),
    );
  }
}
