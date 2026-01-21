import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Animated Profile Tabs
/// Horizontal scrollable pill-style tabs with smooth animations
class ProfileTabs extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTabSelected;

  const ProfileTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = index == selectedIndex;
            return Padding(
              padding: EdgeInsets.only(right: index < tabs.length - 1 ? 8 : 0),
              child: _AnimatedTabPill(
                label: tabs[index],
                isSelected: isSelected,
                index: index,
                onTap: () => onTabSelected(index),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _AnimatedTabPill extends StatefulWidget {
  final String label;
  final bool isSelected;
  final int index;
  final VoidCallback onTap;

  const _AnimatedTabPill({
    required this.label,
    required this.isSelected,
    required this.index,
    required this.onTap,
  });

  @override
  State<_AnimatedTabPill> createState() => _AnimatedTabPillState();
}

class _AnimatedTabPillState extends State<_AnimatedTabPill>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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

    // Staggered entrance
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
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
          child: Opacity(opacity: _controller.value, child: child),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppTheme.normalDuration,
          curve: AppTheme.defaultCurve,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          transform: Matrix4.diagonal3Values(
            _isPressed ? 0.95 : 1.0,
            _isPressed ? 0.95 : 1.0,
            1.0,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? Colors.black
                : (_isPressed ? Colors.grey[200] : Colors.grey[100]),
            borderRadius: AppTheme.pillRadius,
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isSelected)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: AppTheme.normalDuration,
                    builder: (context, value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: Icon(
                      _getTabIcon(widget.label),
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: widget.isSelected
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: widget.isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTabIcon(String label) {
    switch (label) {
      case 'Resume':
        return Icons.description_outlined;
      case 'Profile Info':
        return Icons.person_outline;
      case 'Additional Info':
        return Icons.school_outlined;
      case 'Drive Summary':
        return Icons.analytics_outlined;
      case 'Account Settings':
        return Icons.settings_outlined;
      default:
        return Icons.circle;
    }
  }
}
