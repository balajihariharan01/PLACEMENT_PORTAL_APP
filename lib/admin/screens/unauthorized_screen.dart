import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../widgets/admin_button.dart';

/// Unauthorized Access Screen
/// Displayed when a user attempts to access admin pages without proper authorization
class UnauthorizedScreen extends StatelessWidget {
  final String? message;
  final VoidCallback? onGoBack;

  const UnauthorizedScreen({super.key, this.message, this.onGoBack});

  @override
  Widget build(BuildContext context) {
    // Prevent screenshots on this screen for security
    // Note: This is platform-specific and may require native implementation

    return PopScope(
      // Prevent back navigation
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Security Icon with animation
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.errorRed.withValues(alpha: 0.3),
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.shield_outlined,
                        size: 64,
                        color: AppTheme.errorRed,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Title
                  const Text(
                    'Access Denied',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Message
                  Text(
                    message ??
                        'You do not have permission to access this area.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Security Notice
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: AppTheme.mediumRadius,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This incident has been logged for security purposes.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Exit Button
                  if (onGoBack != null)
                    AdminButton(
                      text: 'Exit',
                      icon: Icons.exit_to_app,
                      style: AdminButtonStyle.outline,
                      onPressed: onGoBack,
                    )
                  else
                    AdminButton(
                      text: 'Close Application',
                      icon: Icons.power_settings_new,
                      style: AdminButtonStyle.danger,
                      onPressed: () {
                        // Exit the app
                        SystemNavigator.pop();
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Session Expired Screen
/// Displayed when admin session has expired
class SessionExpiredScreen extends StatelessWidget {
  final VoidCallback onReLogin;

  const SessionExpiredScreen({super.key, required this.onReLogin});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.warningOrange.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.timer_off_outlined,
                      size: 56,
                      color: AppTheme.warningOrange,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Session Expired',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your session has expired for security reasons.\nPlease log in again to continue.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  AdminButton(
                    text: 'Login Again',
                    icon: Icons.login,
                    onPressed: onReLogin,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
