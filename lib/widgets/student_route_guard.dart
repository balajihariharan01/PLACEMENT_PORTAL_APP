import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';

/// Student Route Guard
/// Ensures only authenticated students can access student-specific pages
class StudentRouteGuard extends StatelessWidget {
  final Widget child;

  const StudentRouteGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    // Verify if user is logged in and has student role
    if (!authService.isLoggedIn || !authService.isStudent) {
      // Security: Redirect to login if unauthorized
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      });

      // Return empty container while redirecting
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return child;
  }
}
