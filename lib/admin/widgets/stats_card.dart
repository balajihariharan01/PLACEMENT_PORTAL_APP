import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Stats Card Widget
/// Mobile-optimized animated card for displaying dashboard statistics
/// MOBILE-FIRST: Uses flexible height with mainAxisSize.min
class StatsCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final int animationIndex;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.backgroundColor,
    this.onTap,
    this.animationIndex = 0,
  });

  @override
  State<StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.slowDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Staggered animation
    Future.delayed(Duration(milliseconds: widget.animationIndex * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(opacity: _fadeAnimation.value, child: child),
        );
      },
      child: GestureDetector(
        onTapDown: widget.onTap != null
            ? (_) => setState(() => _isPressed = true)
            : null,
        onTapUp: widget.onTap != null
            ? (_) => setState(() => _isPressed = false)
            : null,
        onTapCancel: widget.onTap != null
            ? () => setState(() => _isPressed = false)
            : null,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppTheme.fastDuration,
          transform: Matrix4.diagonal3Values(
            _isPressed ? 0.95 : 1.0,
            _isPressed ? 0.95 : 1.0,
            1.0,
          ),
          // MOBILE-FIRST: Reduced padding for smaller screens
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.white,
            borderRadius: AppTheme.largeRadius,
            boxShadow: AppTheme.softShadow,
            border: Border.all(color: widget.color.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // CRITICAL: Prevents fixed height - adapts to content
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon row with arrow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    // Smaller icon container for mobile
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.1),
                      borderRadius: AppTheme.smallRadius,
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 20),
                  ),
                  if (widget.onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.grey[400],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Value text - responsive font size
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              // Title text with ellipsis
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
