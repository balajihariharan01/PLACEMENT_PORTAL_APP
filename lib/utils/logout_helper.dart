import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../theme/app_theme.dart';

/// Secure Logout Helper
/// Handles session termination and navigation reset across the app
class LogoutHelper {
  /// Unified logout implementation
  /// 1. Shows confirmation dialog
  /// 2. Performs secure state cleanup
  /// 3. Resets navigation stack to LoginScreen
  static Future<void> logout(BuildContext context) async {
    // 1. Confirm logout
    final confirmed = await _showConfirmationDialog(context);
    if (confirmed != true) return;

    // 2. Show loading overlay
    if (!context.mounted) return;
    _showLoadingDialog(context);

    try {
      // 3. Terminate session securely
      final authService = AuthService();
      await authService.logout();

      // 4. Reset Navigation (Crucial for security)
      // Removes all routes from stack to prevent back-navigation to protected screens
      if (context.mounted) {
        // Pop loading dialog first
        Navigator.of(context, rootNavigator: true).pop();

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
            settings: const RouteSettings(name: '/login'),
          ),
          (route) => false, // Discards all previous routes
        );
      }
    } catch (e) {
      // Handle rare logout failures
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  /// Show loading overlay during session termination
  static void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing during cleanup
      builder: (context) => PopScope(
        canPop: false, // Disable back button
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppTheme.mediumRadius,
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryBlue,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Logging out safely...',
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Private confirmation dialog
  static Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.largeRadius),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppTheme.errorRed),
            const SizedBox(width: 12),
            const Text('Sign Out'),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out? You will need to login again to access your dashboard.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
