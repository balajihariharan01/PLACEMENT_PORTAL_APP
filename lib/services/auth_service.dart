/// Unified Authentication Service
/// Handles both Admin and Student authentication with role-based redirection
///
/// SECURITY NOTES:
/// - Single entry point for all authentication
/// - Role is determined by backend response
/// - Admin credentials are validated strictly
/// - Generic error messages for security
///
/// TODO: Replace mock implementation with actual HTTP calls to backend
library;

import 'package:flutter/foundation.dart';
import '../admin/security/admin_session_manager.dart';
import '../admin/models/admin_user.dart';

/// User Role Enum
enum UserRole { admin, student, unknown }

/// Auth Response containing user data and role
class AuthResult {
  final bool success;
  final UserRole role;
  final String? userId;
  final String? userName;
  final String? email;
  final String? token;
  final String? errorMessage;

  const AuthResult({
    required this.success,
    required this.role,
    this.userId,
    this.userName,
    this.email,
    this.token,
    this.errorMessage,
  });

  factory AuthResult.success({
    required UserRole role,
    required String userId,
    required String userName,
    required String email,
    required String token,
  }) {
    return AuthResult(
      success: true,
      role: role,
      userId: userId,
      userName: userName,
      email: email,
      token: token,
    );
  }

  factory AuthResult.error(String message) {
    return AuthResult(
      success: false,
      role: UserRole.unknown,
      errorMessage: message,
    );
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isStudent => role == UserRole.student;
}

/// Unified Authentication Service
/// Single service for both Admin and Student login
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Session state
  AuthResult? _currentUser;
  final _adminSessionManager = AdminSessionManager();

  // Simulated network delay
  static const Duration _networkDelay = Duration(milliseconds: 800);

  // Mock credentials database
  // TODO: Backend will validate credentials and return role
  static const Map<String, Map<String, dynamic>> _mockUsers = {
    // Admin users
    'admin@college.edu': {
      'password': 'admin123',
      'role': 'ADMIN',
      'id': 'admin_001',
      'name': 'Admin User',
    },
    'superadmin@college.edu': {
      'password': 'super123',
      'role': 'ADMIN',
      'id': 'admin_002',
      'name': 'Super Admin',
    },
    // Student users
    'student@college.edu': {
      'password': '123456',
      'role': 'STUDENT',
      'id': 'student_001',
      'name': 'John Doe',
    },
    'rahul@college.edu': {
      'password': 'password',
      'role': 'STUDENT',
      'id': 'student_002',
      'name': 'Rahul Sharma',
    },
  };

  /// Get current authenticated user
  AuthResult? get currentUser => _currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => _currentUser != null && _currentUser!.success;

  /// Check if current user is admin
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  /// Check if current user is student
  bool get isStudent => _currentUser?.isStudent ?? false;

  /// Get current user role
  UserRole get currentRole => _currentUser?.role ?? UserRole.unknown;

  /// Unified Login Method
  /// Validates credentials and returns role-based result
  ///
  /// TODO: Integrate with actual backend API
  /// Endpoint: POST /api/auth/login
  /// Body: { email: string, password: string }
  /// Response: { success: bool, role: string, user: UserData, token: string }
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(_networkDelay);

    // Validate input
    if (email.isEmpty || password.isEmpty) {
      return AuthResult.error('Please enter email and password');
    }

    // Normalize email
    final normalizedEmail = email.toLowerCase().trim();

    // Check credentials
    final userData = _mockUsers[normalizedEmail];
    if (userData == null || userData['password'] != password) {
      // Generic error message for security (prevents user enumeration)
      return AuthResult.error('Invalid credentials. Please try again.');
    }

    // Determine role
    final roleString = userData['role'] as String;
    final role = roleString == 'ADMIN' ? UserRole.admin : UserRole.student;

    // Generate mock token
    final token = 'auth_token_${DateTime.now().millisecondsSinceEpoch}';

    // Create auth result
    final result = AuthResult.success(
      role: role,
      userId: userData['id'] as String,
      userName: userData['name'] as String,
      email: normalizedEmail,
      token: token,
    );

    // Store current user
    _currentUser = result;

    // If admin, also initialize admin session
    if (role == UserRole.admin) {
      final adminUser = AdminUser(
        id: userData['id'] as String,
        name: userData['name'] as String,
        email: normalizedEmail,
        role: 'Admin',
        createdAt: DateTime(2024, 1, 1),
        lastLogin: DateTime.now(),
      );
      _adminSessionManager.startSession(admin: adminUser, token: token);
    }

    return result;
  }

  /// Logout current user
  /// SECURITY: Ensures all session data is fully cleared
  Future<void> logout() async {
    // Simulate network delay for UI feedback
    await Future.delayed(const Duration(milliseconds: 500));

    // 1. Clear admin session if applicable
    _adminSessionManager.endSession();

    // 2. Clear current user state
    _currentUser = null;

    // 3. Log event for security monitoring
    debugPrint('[AUTH] User session terminated successfully');
  }

  /// Verify current session is valid
  /// Returns error message if invalid, null if valid
  String? verifySession() {
    if (_currentUser == null || !_currentUser!.success) {
      return 'Not authenticated';
    }

    // If admin, also verify admin session
    if (_currentUser!.isAdmin) {
      return _adminSessionManager.verifySession();
    }

    return null;
  }

  /// Validate admin role explicitly
  /// Used for admin route guards
  bool validateAdminRole() {
    if (_currentUser == null) return false;
    if (!_currentUser!.success) return false;
    if (_currentUser!.role != UserRole.admin) return false;

    // Also verify admin session is valid
    return _adminSessionManager.isAuthenticated;
  }

  /// Update activity (for session timeout management)
  void updateActivity() {
    if (_currentUser?.isAdmin ?? false) {
      _adminSessionManager.updateActivity();
    }
  }
}
