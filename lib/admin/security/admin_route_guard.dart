import 'package:flutter/material.dart';
import 'admin_session_manager.dart';
import '../screens/unauthorized_screen.dart';

/// Admin Route Guard Widget
/// Wraps admin screens to verify authentication before rendering
///
/// SECURITY FEATURES:
/// - Verifies admin session before showing content
/// - Redirects to unauthorized screen if not authenticated
/// - Prevents back navigation to protected content
/// - Updates activity timestamp on each access
class AdminRouteGuard extends StatefulWidget {
  final Widget child;
  final String? requiredRole;

  const AdminRouteGuard({super.key, required this.child, this.requiredRole});

  @override
  State<AdminRouteGuard> createState() => _AdminRouteGuardState();
}

class _AdminRouteGuardState extends State<AdminRouteGuard> {
  final _sessionManager = AdminSessionManager();
  bool _isAuthorized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _verifyAccess();
    _sessionManager.addListener(_onSessionChange);
  }

  @override
  void dispose() {
    _sessionManager.removeListener(_onSessionChange);
    super.dispose();
  }

  void _onSessionChange() {
    if (mounted) {
      _verifyAccess();
    }
  }

  void _verifyAccess() {
    final validationError = _sessionManager.verifySession();

    if (validationError != null) {
      setState(() {
        _isAuthorized = false;
        _errorMessage = validationError;
      });
      return;
    }

    // Additional role check if required
    if (widget.requiredRole != null) {
      final userRole = _sessionManager.currentAdmin?.role.toLowerCase() ?? '';
      if (!userRole.contains(widget.requiredRole!.toLowerCase())) {
        setState(() {
          _isAuthorized = false;
          _errorMessage = 'Insufficient permissions for this action';
        });
        return;
      }
    }

    // Update activity
    _sessionManager.updateActivity();

    setState(() {
      _isAuthorized = true;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthorized) {
      return UnauthorizedScreen(
        message: _errorMessage,
        onGoBack: () {
          // Force logout and navigate to app root
          _sessionManager.endSession();
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      );
    }

    return widget.child;
  }
}

/// Admin Protected Route
/// A route configuration that includes authentication check
class AdminProtectedRoute<T> extends MaterialPageRoute<T> {
  AdminProtectedRoute({required WidgetBuilder builder, super.settings})
    : super(
        builder: (context) {
          // Check authentication before building
          final sessionManager = AdminSessionManager();

          if (!sessionManager.isAuthenticated) {
            return UnauthorizedScreen(
              message: 'Please login to access admin area',
              onGoBack: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            );
          }

          return AdminRouteGuard(child: builder(context));
        },
      );
}

/// Admin Route Middleware
/// Utility class for route protection
class AdminRouteMiddleware {
  static final _sessionManager = AdminSessionManager();

  /// Check if navigation to admin route should be allowed
  static bool canNavigate() {
    return _sessionManager.isAuthenticated && _sessionManager.isAdmin;
  }

  /// Navigate to admin route with protection
  static Future<T?> navigateTo<T>(
    BuildContext context,
    Widget page, {
    bool replaceAll = false,
  }) {
    if (!canNavigate()) {
      // Log unauthorized access attempt
      debugPrint('[SECURITY] Unauthorized admin navigation attempt blocked');

      return Navigator.push<T>(
        context,
        MaterialPageRoute(
          builder: (_) => UnauthorizedScreen(
            message: 'Unauthorized access attempt detected',
            onGoBack: () => Navigator.pop(context),
          ),
        ),
      );
    }

    // Update activity
    _sessionManager.updateActivity();

    if (replaceAll) {
      return Navigator.pushAndRemoveUntil<T>(
        context,
        AdminProtectedRoute(builder: (_) => page),
        (route) => false,
      );
    }

    return Navigator.push<T>(
      context,
      AdminProtectedRoute(builder: (_) => page),
    );
  }

  /// Navigate and replace current route
  static Future<T?> navigateReplace<T extends Object?, TO extends Object?>(
    BuildContext context,
    Widget page,
  ) {
    if (!canNavigate()) {
      return Navigator.pushReplacement<T, TO>(
        context,
        MaterialPageRoute(
          builder: (_) => UnauthorizedScreen(
            message: 'Unauthorized access attempt detected',
            onGoBack: () => Navigator.pop(context),
          ),
        ),
      );
    }

    _sessionManager.updateActivity();

    return Navigator.pushReplacement<T, TO>(
      context,
      AdminProtectedRoute(builder: (_) => page),
    );
  }
}
