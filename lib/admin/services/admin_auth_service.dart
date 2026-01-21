import '../models/admin_user.dart';
import '../security/admin_session_manager.dart';

/// API Response wrapper for consistent error handling
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? errorCode;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errorCode,
  });

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(success: true, data: data, message: message);
  }

  factory ApiResponse.error(String message, {String? errorCode}) {
    return ApiResponse(success: false, message: message, errorCode: errorCode);
  }
}

/// Mock Admin Authentication Service
/// Simulates authentication API calls with security measures
///
/// SECURITY NOTES:
/// - Uses AdminSessionManager for state management
/// - Credentials are mock only - replace with actual backend
/// - Error messages are generic for security
///
/// TODO: Replace mock implementation with actual HTTP calls to backend
class AdminAuthService {
  // Simulated delay to mimic network latency
  static const Duration _networkDelay = Duration(milliseconds: 800);

  // Session manager instance
  final _sessionManager = AdminSessionManager();

  // Mock admin credentials for testing
  // SECURITY: In production, this would be validated by backend
  static const Map<String, String> _mockCredentials = {
    'admin@college.edu': 'admin123',
    'superadmin@college.edu': 'super123',
  };

  // Mock admin user data
  static final Map<String, AdminUser> _mockUsers = {
    'admin@college.edu': AdminUser(
      id: 'admin_001',
      name: 'Admin User',
      email: 'admin@college.edu',
      role: 'Admin',
      createdAt: DateTime(2024, 1, 1),
      lastLogin: DateTime.now(),
    ),
    'superadmin@college.edu': AdminUser(
      id: 'admin_002',
      name: 'Super Admin',
      email: 'superadmin@college.edu',
      role: 'Super Admin',
      createdAt: DateTime(2023, 6, 15),
      lastLogin: DateTime.now(),
    ),
  };

  /// Get current logged in admin from session
  AdminUser? get currentAdmin => _sessionManager.currentAdmin;

  /// Check if admin is logged in and session is valid
  bool get isLoggedIn => _sessionManager.isAuthenticated;

  /// Check if current user has admin role
  bool get isAdmin => _sessionManager.isAdmin;

  /// Login with email and password
  /// Returns ApiResponse with AdminUser on success
  ///
  /// SECURITY NOTES:
  /// - Generic error messages to prevent enumeration attacks
  /// - Uses session manager for secure state storage
  ///
  /// TODO: Integrate with actual backend API
  /// Endpoint: POST /api/admin/login
  /// Body: { email: string, password: string }
  /// Response: { success: bool, data: AdminUser, token: string }
  Future<ApiResponse<AdminUser>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    // Simulate network delay
    await Future.delayed(_networkDelay);

    // Validate input
    if (email.isEmpty) {
      return ApiResponse.error('Email is required', errorCode: 'EMPTY_EMAIL');
    }
    if (password.isEmpty) {
      return ApiResponse.error(
        'Password is required',
        errorCode: 'EMPTY_PASSWORD',
      );
    }

    // Check credentials
    final storedPassword = _mockCredentials[email.toLowerCase()];
    if (storedPassword == null || storedPassword != password) {
      // Generic error message for security
      return ApiResponse.error(
        'Invalid credentials. Please try again.',
        errorCode: 'INVALID_CREDENTIALS',
      );
    }

    // Get admin user
    final admin = _mockUsers[email.toLowerCase()]!;

    // Generate mock token (in production this comes from backend)
    final mockToken = 'admin_token_${DateTime.now().millisecondsSinceEpoch}';

    // Start secure session
    _sessionManager.startSession(admin: admin, token: mockToken);

    // TODO: Store auth token securely for rememberMe
    // if (rememberMe) {
    //   await FlutterSecureStorage().write(key: 'admin_token', value: mockToken);
    // }

    return ApiResponse.success(admin, message: 'Login successful');
  }

  /// Logout current admin
  ///
  /// TODO: Integrate with actual backend API
  /// Endpoint: POST /api/admin/logout
  /// Headers: Authorization: Bearer `<token>`
  Future<ApiResponse<void>> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Clear session securely
    _sessionManager.endSession();

    // TODO: Clear stored auth token
    // await FlutterSecureStorage().delete(key: 'admin_token');

    return ApiResponse.success(null, message: 'Logged out successfully');
  }

  /// Verify session is still valid
  ///
  /// TODO: Integrate with actual backend API
  /// Endpoint: GET /api/admin/verify-token
  /// Headers: Authorization: Bearer `<token>`
  Future<ApiResponse<AdminUser>> verifySession() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final validationError = _sessionManager.verifySession();
    if (validationError != null) {
      return ApiResponse.error(validationError, errorCode: 'SESSION_INVALID');
    }

    return ApiResponse.success(_sessionManager.currentAdmin!);
  }

  /// Force logout - used for security violations
  void forceLogout() {
    _sessionManager.endSession();
  }

  /// Update session activity (call on user interactions)
  void updateActivity() {
    _sessionManager.updateActivity();
  }
}
