import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../services/admin_auth_service.dart';
import '../security/admin_route_guard.dart';
import 'admin_dashboard_screen.dart';

/// Admin Login Screen
/// SECURITY: Isolated admin entry point
/// - NOT accessible from user login page
/// - Separate authentication flow
/// - Generic error messages
/// - No "Sign up" option
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adminAuthService = AdminAuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  int _loginAttempts = 0;

  // Security: Lock after 5 failed attempts
  static const int maxLoginAttempts = 5;
  bool get _isLocked => _loginAttempts >= maxLoginAttempts;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Check if already authenticated
    if (_adminAuthService.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToDashboard();
      });
    }

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: AppTheme.defaultCurve,
          ),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLocked) {
      _showLockedMessage();
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _adminAuthService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (response.success) {
      _loginAttempts = 0;
      _navigateToDashboard();
    } else {
      _loginAttempts++;
      setState(() {
        // Generic error message for security
        _errorMessage = _isLocked
            ? 'Too many failed attempts. Please try again later.'
            : 'Invalid credentials. Please try again.';
      });

      // Log failed attempt (for security monitoring)
      debugPrint('[SECURITY] Failed admin login attempt #$_loginAttempts');
    }
  }

  void _showLockedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Account temporarily locked. Contact support.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.errorRed,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.smallRadius),
      ),
    );
  }

  void _navigateToDashboard() {
    // Use protected route for navigation
    AdminRouteMiddleware.navigateTo(
      context,
      const AdminDashboardScreen(),
      replaceAll: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dark admin theme for visual distinction
      backgroundColor: const Color(0xFF1A1A2E),
      body: Stack(
        children: [
          // Dark gradient background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A1A2E),
                    Color(0xFF16213E),
                    Color(0xFF0F3460),
                  ],
                ),
              ),
            ),
          ),

          // Subtle pattern overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" width="60" height="60"><circle cx="30" cy="30" r="1" fill="white"/></svg>',
                    ),
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 40,
                  ),
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),

                        // Admin Logo with security badge
                        _buildSecureAdminLogo(),
                        const SizedBox(height: 40),

                        // Title
                        const Text(
                          'Admin Access',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Authorized personnel only',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Error Message
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.errorRed.withValues(alpha: 0.15),
                              borderRadius: AppTheme.mediumRadius,
                              border: Border.all(
                                color: AppTheme.errorRed.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: AppTheme.errorRed,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Email Field (dark theme)
                        _buildDarkTextField(
                          label: 'Admin Email',
                          hint: 'Enter your email',
                          controller: _emailController,
                          icon: Icons.person_outline,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !_isLocked,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password Field (dark theme)
                        _buildDarkTextField(
                          label: 'Password',
                          hint: 'Enter your password',
                          controller: _passwordController,
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          enabled: !_isLocked,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.white54,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 40),

                        // Login Button
                        _buildLoginButton(),
                        const SizedBox(height: 32),

                        // Security Notice
                        Container(
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
                                Icons.security,
                                size: 20,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'All login attempts are monitored and logged.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white54),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  SystemNavigator.pop();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecureAdminLogo() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow effect
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          // Main logo
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF3F51B5), const Color(0xFF1976D2)],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              size: 48,
              color: Colors.white,
            ),
          ),
          // Security badge
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.successGreen,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1A1A2E), width: 3),
              ),
              child: const Icon(
                Icons.verified_user,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool enabled = true,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          style: const TextStyle(color: Colors.white),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            prefixIcon: Icon(icon, color: Colors.white54),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            border: OutlineInputBorder(
              borderRadius: AppTheme.mediumRadius,
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppTheme.mediumRadius,
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppTheme.mediumRadius,
              borderSide: const BorderSide(
                color: AppTheme.primaryBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppTheme.mediumRadius,
              borderSide: BorderSide(color: AppTheme.errorRed),
            ),
            errorStyle: TextStyle(color: AppTheme.errorRed),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoading || _isLocked ? null : _handleLogin,
      child: AnimatedContainer(
        duration: AppTheme.fastDuration,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: _isLoading || _isLocked
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF3F51B5), Color(0xFF1976D2)],
                ),
          color: _isLoading || _isLocked ? Colors.grey[700] : null,
          borderRadius: AppTheme.mediumRadius,
          boxShadow: _isLoading || _isLocked
              ? null
              : [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            else ...[
              Icon(
                _isLocked ? Icons.lock : Icons.login,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                _isLocked ? 'Locked' : 'Sign In',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
