import 'package:flutter/material.dart';
import '../screens/admin_login_screen.dart';
import '../../theme/app_theme.dart';

/// Admin Entry Point
///
/// SECURITY: This provides methods to access the admin portal.
/// In production, admin access should be through:
/// 1. A completely separate app (recommended)
/// 2. A hidden gesture (for development/testing only)
/// 3. A specific URL scheme (for web-based admin access)
///
/// NEVER expose admin entry points in user-facing UI.
class AdminEntryPoint {
  /// Navigate to admin login using a secure method
  /// This should only be called from authorized entry points
  static void navigateToAdminLogin(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AdminLoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: AppTheme.normalDuration,
      ),
    );
  }

  /// Hidden gesture detector for development access
  /// SECURITY: Remove or disable this in production builds
  ///
  /// Usage: Wrap any widget with this to enable hidden admin access
  /// Requires 5 quick taps to activate
  static Widget secretGestureDetector({
    required Widget child,
    required BuildContext context,
  }) {
    int tapCount = 0;
    DateTime? lastTapTime;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        final now = DateTime.now();

        // Reset if more than 2 seconds since last tap
        if (lastTapTime != null &&
            now.difference(lastTapTime!) > const Duration(seconds: 2)) {
          tapCount = 0;
        }

        lastTapTime = now;
        tapCount++;

        // Navigate after 5 quick taps
        if (tapCount >= 5) {
          tapCount = 0;
          navigateToAdminLogin(context);
        }
      },
      child: child,
    );
  }

  /// Check if running in debug mode
  /// Admin entry points should be more restricted in production
  static bool get isDebugMode {
    bool debugMode = false;
    assert(() {
      debugMode = true;
      return true;
    }());
    return debugMode;
  }
}

/// Secret Admin Access Widget
///
/// SECURITY: This widget provides a hidden entry point for admin access
/// It requires a specific gesture pattern to activate
///
/// WARNING: Consider disabling in production builds using:
/// if (kReleaseMode) return child;
class SecretAdminAccess extends StatefulWidget {
  final Widget child;
  final int requiredTaps;
  final Duration timeout;

  const SecretAdminAccess({
    super.key,
    required this.child,
    this.requiredTaps = 7,
    this.timeout = const Duration(seconds: 3),
  });

  @override
  State<SecretAdminAccess> createState() => _SecretAdminAccessState();
}

class _SecretAdminAccessState extends State<SecretAdminAccess> {
  int _tapCount = 0;
  DateTime? _lastTapTime;

  void _handleTap() {
    final now = DateTime.now();

    // Reset if timeout exceeded
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) > widget.timeout) {
      _tapCount = 0;
    }

    _lastTapTime = now;
    _tapCount++;

    // Navigate when required taps reached
    if (_tapCount >= widget.requiredTaps) {
      _tapCount = 0;
      _showAdminAccessDialog();
    }
  }

  void _showAdminAccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.largeRadius),
        title: Row(
          children: [
            Icon(Icons.security, color: AppTheme.warningOrange),
            const SizedBox(width: 12),
            const Text('Admin Access'),
          ],
        ),
        content: const Text(
          'You are about to enter the admin portal. This area is restricted to authorized personnel only.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AdminEntryPoint.navigateToAdminLogin(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            child: const Text('Proceed', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: AdminEntryPoint.isDebugMode ? _handleTap : null,
      child: widget.child,
    );
  }
}
