import 'package:flutter/foundation.dart';
import '../models/admin_user.dart';

/// Admin Session Manager
/// Handles admin authentication state with security measures
///
/// SECURITY NOTES:
/// - Admin state is stored in memory only (clears on app restart)
/// - For production, integrate with secure storage (flutter_secure_storage)
/// - All admin routes must verify session before rendering
///
/// TODO: Integrate with actual backend for:
/// - Token-based authentication
/// - Token refresh mechanism
/// - Secure token storage
class AdminSessionManager {
  // Singleton pattern
  static final AdminSessionManager _instance = AdminSessionManager._internal();
  factory AdminSessionManager() => _instance;
  AdminSessionManager._internal();

  // Private state - not accessible directly
  AdminUser? _currentAdmin;
  String? _authToken;
  DateTime? _sessionStartTime;
  DateTime? _lastActivityTime;

  // Session timeout duration (configurable)
  static const Duration sessionTimeout = Duration(minutes: 30);
  static const Duration inactivityTimeout = Duration(minutes: 15);

  // Listeners for session changes
  final List<VoidCallback> _sessionListeners = [];

  /// Check if admin is currently authenticated
  bool get isAuthenticated {
    if (_currentAdmin == null || _authToken == null) {
      return false;
    }

    // Check session timeout
    if (_sessionStartTime != null) {
      final elapsed = DateTime.now().difference(_sessionStartTime!);
      if (elapsed > sessionTimeout) {
        _clearSession();
        return false;
      }
    }

    // Check inactivity timeout
    if (_lastActivityTime != null) {
      final elapsed = DateTime.now().difference(_lastActivityTime!);
      if (elapsed > inactivityTimeout) {
        _clearSession();
        return false;
      }
    }

    return true;
  }

  /// Get current admin user (null if not authenticated)
  AdminUser? get currentAdmin => isAuthenticated ? _currentAdmin : null;

  /// Get auth token for API calls
  String? get authToken => isAuthenticated ? _authToken : null;

  /// Validate admin role
  bool get isAdmin {
    if (!isAuthenticated) return false;
    // Additional role check
    return _currentAdmin?.role.toLowerCase().contains('admin') ?? false;
  }

  /// Start admin session after successful login
  ///
  /// TODO: Backend integration point
  /// - Store token in secure storage
  /// - Set up token refresh timer
  void startSession({required AdminUser admin, required String token}) {
    _currentAdmin = admin;
    _authToken = token;
    _sessionStartTime = DateTime.now();
    _lastActivityTime = DateTime.now();
    _notifyListeners();

    // Log session start (for audit)
    debugPrint('[ADMIN SESSION] Session started for: ${admin.email}');
  }

  /// Update last activity time (call on user interaction)
  void updateActivity() {
    if (isAuthenticated) {
      _lastActivityTime = DateTime.now();
    }
  }

  /// End admin session (logout)
  void endSession() {
    debugPrint('[ADMIN SESSION] Session ended for: ${_currentAdmin?.email}');
    _clearSession();
    _notifyListeners();
  }

  /// Clear all session data
  void _clearSession() {
    _currentAdmin = null;
    _authToken = null;
    _sessionStartTime = null;
    _lastActivityTime = null;
  }

  /// Add listener for session changes
  void addListener(VoidCallback listener) {
    _sessionListeners.add(listener);
  }

  /// Remove listener
  void removeListener(VoidCallback listener) {
    _sessionListeners.remove(listener);
  }

  /// Notify all listeners
  void _notifyListeners() {
    for (final listener in _sessionListeners) {
      listener();
    }
  }

  /// Verify session is still valid
  /// Returns error message if invalid, null if valid
  String? verifySession() {
    if (_currentAdmin == null) {
      return 'No active session';
    }

    if (_authToken == null) {
      return 'Authentication token missing';
    }

    if (_sessionStartTime != null) {
      final elapsed = DateTime.now().difference(_sessionStartTime!);
      if (elapsed > sessionTimeout) {
        _clearSession();
        return 'Session has expired';
      }
    }

    if (_lastActivityTime != null) {
      final elapsed = DateTime.now().difference(_lastActivityTime!);
      if (elapsed > inactivityTimeout) {
        _clearSession();
        return 'Session timed out due to inactivity';
      }
    }

    return null; // Session is valid
  }

  /// Get remaining session time
  Duration? get remainingSessionTime {
    if (!isAuthenticated || _sessionStartTime == null) return null;

    final elapsed = DateTime.now().difference(_sessionStartTime!);
    final remaining = sessionTimeout - elapsed;

    return remaining.isNegative ? Duration.zero : remaining;
  }
}
