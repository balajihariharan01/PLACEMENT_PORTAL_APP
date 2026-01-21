import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  int _step = 0; // 0: Email, 1: Password
  final TextEditingController _emailController = TextEditingController(
    text: "student@college.edu",
  );
  final TextEditingController _passwordController = TextEditingController(
    text: "123456",
  );
  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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

  void _handleNext() {
    if (_emailController.text.isNotEmpty) {
      _slideController.reset();
      setState(() {
        _step = 1;
      });
      _slideController.forward();
    }
  }

  void _handleChangeEmail() {
    _slideController.reset();
    setState(() {
      _step = 0;
      _passwordController.clear();
    });
    _slideController.forward();
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);

    // Simulate loading for UI demo
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const DashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: AppTheme.defaultCurve,
                      ),
                    ),
                child: child,
              ),
            );
          },
          transitionDuration: AppTheme.normalDuration,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldLight,
      body: Stack(
        children: [
          // Animated Background Gradient
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(seconds: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _step == 0
                      ? [
                          const Color(0xFFE0F7FA),
                          const Color(0xFFF5F9FA),
                          Colors.white,
                        ]
                      : [
                          const Color(0xFFE8F5E9),
                          const Color(0xFFF5F9FA),
                          Colors.white,
                        ],
                ),
              ),
            ),
          ),

          // Decorative Circles
          Positioned(
            top: -100,
            right: -100,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1.0),
              duration: const Duration(seconds: 2),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value * 0.1,
                  child: Transform.scale(scale: value, child: child),
                );
              },
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -150,
            left: -100,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1.0),
              duration: const Duration(seconds: 2),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value * 0.05,
                  child: Transform.scale(scale: value, child: child),
                );
              },
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentColor,
                ),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 40.0,
                  ),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Center(
                        child: AnimatedSwitcher(
                          duration: AppTheme.normalDuration,
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: _step == 0
                              ? _buildNeoPatLogo()
                              : _buildCollegeLogo(),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Animated Welcome Text
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(-30 * (1 - value), 0),
                              child: child,
                            ),
                          );
                        },
                        child: const Text(
                          "Welcome",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(opacity: value, child: child);
                        },
                        child: Text(
                          _step == 0
                              ? "Let's proceed with logging into your account."
                              : "Enter your password to continue",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      AnimatedSwitcher(
                        duration: AppTheme.normalDuration,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.1, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: _step == 0
                            ? _buildEmailStep()
                            : _buildPasswordStep(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeoPatLogo() {
    return TweenAnimationBuilder<double>(
      key: const ValueKey('neopat'),
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'neo',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'sans-serif',
                ),
              ),
              WidgetSpan(
                child: Padding(
                  padding: EdgeInsets.only(left: 2.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF4081), Color(0xFFFF6B9D)],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 2.0,
                      ),
                      child: Text(
                        'PAT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollegeLogo() {
    return TweenAnimationBuilder<double>(
      key: const ValueKey('college'),
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.successGreen.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Icon(
          Icons.school_rounded,
          size: 50,
          color: AppTheme.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildEmailStep() {
    return Column(
      key: const ValueKey('email_step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: "Email",
          hint: "Enter your email address",
          controller: _emailController,
        ),
        const SizedBox(height: 40),
        _buildAnimatedButton(
          text: "Next",
          icon: Icons.arrow_forward,
          onPressed: _handleNext,
        ),
        // SECURITY: Admin login link removed
        // Admin access is through a separate, isolated entry point
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      key: const ValueKey('password_step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Email",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: AppTheme.softShadow,
          ),
          child: Row(
            children: [
              Icon(Icons.email_outlined, color: Colors.grey[400], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _emailController.text.isEmpty
                      ? "user@example.com"
                      : _emailController.text,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: _handleChangeEmail,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: AppTheme.pillRadius,
                  ),
                  child: Text(
                    "Change",
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Password",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            GestureDetector(
              onTap: () => _showSnackBar('Forgot password tapped'),
              child: Text(
                "Forgot Password?",
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CustomTextField(
          hint: "Enter your password",
          controller: _passwordController,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: AnimatedSwitcher(
              duration: AppTheme.fastDuration,
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                key: ValueKey(_obscurePassword),
                color: Colors.grey,
              ),
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        const SizedBox(height: 40),
        _buildAnimatedButton(
          text: _isLoading ? "Logging in..." : "Login",
          icon: _isLoading ? null : Icons.login,
          onPressed: _isLoading ? null : _handleLogin,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildAnimatedButton({
    required String text,
    IconData? icon,
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: AppTheme.fastDuration,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: onPressed != null ? AppTheme.primaryGradient : null,
          color: onPressed == null ? Colors.grey[300] : null,
          borderRadius: AppTheme.pillRadius,
          boxShadow: onPressed != null
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            else ...[
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                text,
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
