import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../animated_widgets.dart';

/// Animated Drive Summary Tab
/// Grid and list views with animated number counters and staggered entrance
class DriveSummaryTab extends StatefulWidget {
  const DriveSummaryTab({super.key});

  @override
  State<DriveSummaryTab> createState() => _DriveSummaryTabState();
}

class _DriveSummaryTabState extends State<DriveSummaryTab> {
  final List<Map<String, dynamic>> _summaryItems = [
    {
      'label': 'Eligible',
      'value': '--',
      'icon': Icons.check_circle_outline,
      'color': AppTheme.successGreen,
    },
    {
      'label': 'Opted-In',
      'value': '--',
      'icon': Icons.how_to_reg_outlined,
      'color': AppTheme.primaryBlue,
    },
    {
      'label': 'Opted-Out',
      'value': '--',
      'icon': Icons.logout,
      'color': AppTheme.warningOrange,
    },
    {
      'label': 'Placed',
      'value': '--',
      'icon': Icons.workspace_premium,
      'color': const Color(0xFF9C27B0),
    },
    {
      'label': 'Not Applied',
      'value': '--',
      'icon': Icons.pending_actions_outlined,
      'color': Colors.grey,
    },
    {
      'label': 'Not Eligible',
      'value': '--',
      'icon': Icons.block_outlined,
      'color': AppTheme.errorRed,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with animation
          StaggeredFadeSlide(
            index: 0,
            child: Row(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: AppTheme.mediumRadius,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.analytics_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Placement Statistics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Your placement drive status details',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Detailed List Items
          ...List.generate(_summaryItems.length, (index) {
            final item = _summaryItems[index];
            return _AnimatedListItem(
              index: index + 1,
              label: item['label'],
              value: item['value'],
              icon: item['icon'],
              color: item['color'],
            );
          }),
        ],
      ),
    );
  }
}

/// Animated List Item
class _AnimatedListItem extends StatefulWidget {
  final int index;
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _AnimatedListItem({
    required this.index,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.normalDuration,
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: AppTheme.defaultCurve),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Staggered entrance
    Future.delayed(Duration(milliseconds: widget.index * 60), () {
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
        return SlideTransition(
          position: _slideAnimation,
          child: Opacity(opacity: _fadeAnimation.value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.mediumRadius,
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: AppTheme.smallRadius,
              ),
              child: Icon(widget.icon, color: widget.color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: AppTheme.pillRadius,
              ),
              child: Text(
                widget.value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
