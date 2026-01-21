import 'package:flutter/material.dart';
import '../../utils/validators.dart';
import '../../theme/app_theme.dart';
import '../animated_widgets.dart';

/// Animated Profile Header Widget
/// Features gradient background, animated status badge, and smooth transitions
class ProfileHeader extends StatefulWidget {
  final String studentName;
  final ProfileStatus status;
  final VoidCallback? onLogoutTap;
  final VoidCallback? onProfileImageTap;

  const ProfileHeader({
    super.key,
    required this.studentName,
    required this.status,
    this.onLogoutTap,
    this.onProfileImageTap,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.slowDuration,
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -30, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.defaultCurve),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                // Logout Icon Row
                Align(
                  alignment: Alignment.topRight,
                  child: _buildAnimatedLogoutButton(),
                ),
                const SizedBox(height: 8),
                // Profile Row
                Row(
                  children: [
                    // Animated Profile Image
                    _buildAnimatedProfileImage(),
                    const SizedBox(width: 16),
                    // Name and Status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Animated Name
                          _buildAnimatedName(),
                          const SizedBox(height: 10),
                          // Animated Status Badge
                          _buildStatusBadge(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogoutButton() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: AppTheme.slowDuration,
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: GestureDetector(
        onTap: widget.onLogoutTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Icons.logout_rounded,
            color: Colors.black87,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedProfileImage() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.5, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: GestureDetector(
        onTap: widget.onProfileImageTap,
        child: Stack(
          children: [
            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                child: widget.studentName.isNotEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryBlue.withValues(alpha: 0.1),
                              AppTheme.accentColor.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.studentName.isNotEmpty
                                ? widget.studentName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      )
                    : Icon(Icons.person, size: 50, color: Colors.grey[400]),
              ),
            ),
            // Animated Camera Badge
            Positioned(
              bottom: 0,
              left: 0,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00BFA5), Color(0xFF00E5CC)],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00BFA5).withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedName() {
    return AnimatedSwitcher(
      duration: AppTheme.normalDuration,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        widget.studentName.isNotEmpty ? widget.studentName : 'Enter Your Name',
        key: ValueKey(widget.studentName),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: widget.studentName.isNotEmpty
              ? Colors.black87
              : Colors.grey[500],
          fontStyle: widget.studentName.isNotEmpty
              ? FontStyle.normal
              : FontStyle.italic,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    String description;
    IconData icon;

    switch (widget.status) {
      case ProfileStatus.approved:
        bgColor = AppTheme.successGreen;
        description = 'Verified by Admin';
        icon = Icons.verified;
        break;
      case ProfileStatus.pending:
        bgColor = AppTheme.warningOrange;
        description = 'Awaiting admin verification';
        icon = Icons.pending;
        break;
      case ProfileStatus.rejected:
        bgColor = AppTheme.errorRed;
        description = 'Rejected by Admin';
        icon = Icons.cancel;
        break;
    }

    return AnimatedStatusBadge(
      status: widget.status.displayName,
      description: description,
      color: bgColor,
      icon: icon,
    );
  }
}
