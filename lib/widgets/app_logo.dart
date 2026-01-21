import 'package:flutter/material.dart';

enum LogoVariant { fullColor, white, dark }

class AppLogo extends StatelessWidget {
  final double height;
  final LogoVariant variant;
  final bool animate;
  final String assetPath;

  const AppLogo({
    super.key,
    this.height = 40,
    this.variant = LogoVariant.fullColor,
    this.animate = true,
    this.assetPath =
        'assets/images/admin_logo.png', // Default to the new sharp logo
  });

  /// Factory to automatically determine variant based on background brightness
  factory AppLogo.adaptive({
    required BuildContext context,
    double height = 40,
    bool isTransparent = false,
    String? assetPath,
  }) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark || isTransparent;

    return AppLogo(
      height: height,
      assetPath: assetPath ?? 'assets/images/admin_logo.png',
      variant: isDark ? LogoVariant.white : LogoVariant.fullColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget image;

    switch (variant) {
      case LogoVariant.white:
        image = Image.asset(
          assetPath,
          height: height,
          color: Colors.white,
          colorBlendMode: BlendMode.srcIn,
          filterQuality: FilterQuality.high,
        );
        break;
      case LogoVariant.dark:
        image = Image.asset(
          assetPath,
          height: height,
          color: Colors.black,
          colorBlendMode: BlendMode.srcIn,
          filterQuality: FilterQuality.high,
        );
        break;
      case LogoVariant.fullColor:
        image = Image.asset(
          assetPath,
          height: height,
          filterQuality: FilterQuality.high,
        );
        break;
    }

    if (!animate) return image;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Container(key: ValueKey('${assetPath}_$variant'), child: image),
    );
  }
}
