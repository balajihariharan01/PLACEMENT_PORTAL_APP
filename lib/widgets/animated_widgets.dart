import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animated Widgets Library
/// Reusable animated components for the entire application

// ========== ANIMATED CARD ==========
/// Card with hover/tap scale and elevation animation
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final int delayMs;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.delayMs = 0,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
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
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.defaultCurve),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Staggered entrance animation
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) {
        _controller.forward();
      }
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
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(scale: _scaleAnimation.value, child: child),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppTheme.fastDuration,
          curve: AppTheme.defaultCurve,
          margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 6),
          padding: widget.padding ?? const EdgeInsets.all(16),
          transform: Matrix4.diagonal3Values(
            _isPressed ? 0.98 : 1.0,
            _isPressed ? 0.98 : 1.0,
            1.0,
          ),
          decoration: BoxDecoration(
            color: widget.color ?? Colors.white,
            borderRadius: widget.borderRadius ?? AppTheme.largeRadius,
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: _isPressed
                ? AppTheme.softShadow
                : AppTheme.elevatedShadow,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ========== ANIMATED BUTTON ==========
/// Button with press, release, and disabled state animations
class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isOutlined;
  final double? width;

  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.isOutlined = false,
    this.width,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppTheme.primaryBlue;
    final fgColor = widget.foregroundColor ?? Colors.white;

    return GestureDetector(
      onTapDown: _isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: _isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: _isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: _isEnabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: AppTheme.fastDuration,
        curve: AppTheme.defaultCurve,
        width: widget.width,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        transform: Matrix4.diagonal3Values(
          _isPressed ? 0.96 : 1.0,
          _isPressed ? 0.96 : 1.0,
          1.0,
        ),
        decoration: BoxDecoration(
          color: widget.isOutlined
              ? Colors.transparent
              : (_isEnabled ? bgColor : Colors.grey[300]),
          borderRadius: AppTheme.mediumRadius,
          border: widget.isOutlined
              ? Border.all(
                  color: _isEnabled ? bgColor : Colors.grey[300]!,
                  width: 1.5,
                )
              : null,
          boxShadow: _isPressed || !_isEnabled
              ? null
              : [
                  BoxShadow(
                    color: bgColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(
                    widget.isOutlined ? bgColor : fgColor,
                  ),
                ),
              )
            else ...[
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 20,
                  color: widget.isOutlined
                      ? (_isEnabled ? bgColor : Colors.grey[400])
                      : (_isEnabled ? fgColor : Colors.grey[500]),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.isOutlined
                      ? (_isEnabled ? bgColor : Colors.grey[400])
                      : (_isEnabled ? fgColor : Colors.grey[500]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ========== ANIMATED TAB BAR ==========
/// Pill-style tab bar with smooth indicator animation
class AnimatedTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTabSelected;

  const AnimatedTabBar({
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
              child: _AnimatedTabItem(
                label: tabs[index],
                isSelected: isSelected,
                onTap: () => onTabSelected(index),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _AnimatedTabItem extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedTabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AnimatedTabItem> createState() => _AnimatedTabItemState();
}

class _AnimatedTabItemState extends State<_AnimatedTabItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
            color: widget.isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}

// ========== ANIMATED STATUS BADGE ==========
/// Status badge with pulse/glow animation on load
class AnimatedStatusBadge extends StatefulWidget {
  final String status;
  final String description;
  final Color color;
  final IconData icon;

  const AnimatedStatusBadge({
    super.key,
    required this.status,
    required this.description,
    required this.color,
    required this.icon,
  });

  @override
  State<AnimatedStatusBadge> createState() => _AnimatedStatusBadgeState();
}

class _AnimatedStatusBadgeState extends State<AnimatedStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _glowAnimation = Tween<double>(
      begin: 0.2,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Play pulse animation once on load
    _controller.forward();
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: AppTheme.pillRadius,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(
                        alpha: _glowAnimation.value,
                      ),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      widget.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  size: 12,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  widget.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ========== STAGGERED FADE SLIDE ==========
/// Wrapper for staggered entrance animations
class StaggeredFadeSlide extends StatefulWidget {
  final Widget child;
  final int index;
  final Axis direction;

  const StaggeredFadeSlide({
    super.key,
    required this.child,
    this.index = 0,
    this.direction = Axis.vertical,
  });

  @override
  State<StaggeredFadeSlide> createState() => _StaggeredFadeSlideState();
}

class _StaggeredFadeSlideState extends State<StaggeredFadeSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.slowDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    final slideOffset = widget.direction == Axis.vertical
        ? const Offset(0, 0.2)
        : const Offset(0.2, 0);

    _slideAnimation = Tween<Offset>(begin: slideOffset, end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _controller, curve: AppTheme.defaultCurve),
        );

    // Staggered delay based on index
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
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
        return Opacity(
          opacity: _fadeAnimation.value,
          child: SlideTransition(position: _slideAnimation, child: child),
        );
      },
      child: widget.child,
    );
  }
}

// ========== ANIMATED TEXT FIELD ==========
/// TextField with focus glow and error animation
class AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final bool enabled;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLength;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final bool isRequired;
  final Widget? suffix;

  const AnimatedTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.validator,
    this.keyboardType,
    this.maxLength,
    this.onTap,
    this.onChanged,
    this.isRequired = true,
    this.suffix,
  });

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField> {
  final bool _hasFocus = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            if (widget.isRequired)
              const Text(
                ' *',
                style: TextStyle(color: AppTheme.errorRed, fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: AppTheme.fastDuration,
          decoration: BoxDecoration(
            borderRadius: AppTheme.mediumRadius,
            boxShadow: _hasFocus && _error == null
                ? [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            enabled: widget.enabled,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            maxLength: widget.maxLength,
            onTap: widget.onTap,
            onChanged: (value) {
              if (widget.validator != null) {
                setState(() => _error = widget.validator!(value));
              }
              widget.onChanged?.call(value);
            },
            validator: widget.validator,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _hasFocus
                          ? AppTheme.primaryBlue
                          : (_error != null
                                ? AppTheme.errorRed
                                : Colors.grey[500]),
                      size: 22,
                    )
                  : null,
              suffix: widget.suffix,
              counterText: '',
              filled: true,
              fillColor: widget.enabled ? Colors.grey[50] : Colors.grey[100],
            ),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
          ),
        ),
        // Error with animation
        AnimatedSize(
          duration: AppTheme.fastDuration,
          child: _error != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 6, left: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 14,
                        color: AppTheme.errorRed,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _error!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.errorRed,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ========== ANIMATED BOTTOM NAV ==========
/// Bottom navigation with animated icon transitions
class AnimatedBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AnimatedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_filled,
                label: 'Drives',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.work_outline_rounded,
                activeIcon: Icons.work_rounded,
                label: 'Placed',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppTheme.normalDuration,
        curve: AppTheme.defaultCurve,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: AppTheme.pillRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: AppTheme.fastDuration,
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected),
                color: isSelected ? Colors.white : Colors.grey[500],
                size: isSelected ? 26 : 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: AppTheme.fastDuration,
              style: TextStyle(
                fontSize: isSelected ? 12 : 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[500],
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== SHIMMER LOADING ==========
/// Shimmer effect for loading states
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? AppTheme.smallRadius,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.grey[300]!, Colors.grey[100]!, Colors.grey[300]!],
              stops: [
                _animation.value - 1,
                _animation.value,
                _animation.value + 1,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}
