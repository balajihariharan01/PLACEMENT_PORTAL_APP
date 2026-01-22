import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A reusable back button widget that navigates to the home screen
///
/// This widget provides consistent back-to-home navigation across all modules.
/// It uses `popUntil((route) => route.isFirst)` to ensure proper navigation
/// to the home/dashboard screen regardless of the navigation stack depth.
class HomeBackButton extends StatelessWidget {
  /// Optional callback to execute before navigating home
  final VoidCallback? onBeforeNavigate;

  /// Custom icon to display (defaults to back arrow)
  final IconData icon;

  /// Color of the button
  final Color? color;

  /// Size of the icon
  final double size;

  /// Whether to show a tooltip
  final bool showTooltip;

  const HomeBackButton({
    super.key,
    this.onBeforeNavigate,
    this.icon = Icons.arrow_back_ios_new_rounded,
    this.color,
    this.size = 20,
    this.showTooltip = true,
  });

  void _navigateHome(BuildContext context) {
    onBeforeNavigate?.call();
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      icon: Icon(icon, size: size),
      color: color ?? Colors.black87,
      onPressed: () => _navigateHome(context),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );

    if (showTooltip) {
      return Tooltip(message: 'Back to Home', child: button);
    }
    return button;
  }
}

/// A styled container version of the back button with background
class HomeBackButtonCard extends StatelessWidget {
  final VoidCallback? onBeforeNavigate;
  final Color? backgroundColor;
  final Color? iconColor;

  const HomeBackButtonCard({
    super.key,
    this.onBeforeNavigate,
    this.backgroundColor,
    this.iconColor,
  });

  void _navigateHome(BuildContext context) {
    onBeforeNavigate?.call();
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Back to Home',
      child: GestureDetector(
        onTap: () => _navigateHome(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                backgroundColor ?? AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: iconColor ?? AppTheme.primaryBlue,
          ),
        ),
      ),
    );
  }
}

/// A floating action button style back to home button
class FloatingHomeButton extends StatelessWidget {
  final VoidCallback? onBeforeNavigate;

  const FloatingHomeButton({super.key, this.onBeforeNavigate});

  void _navigateHome(BuildContext context) {
    onBeforeNavigate?.call();
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: 'home_back_button',
      backgroundColor: AppTheme.primaryBlue,
      onPressed: () => _navigateHome(context),
      tooltip: 'Back to Home',
      child: const Icon(Icons.home_rounded, color: Colors.white),
    );
  }
}
