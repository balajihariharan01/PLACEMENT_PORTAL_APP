import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Admin Button Widget
/// Reusable button with various styles and states
class AdminButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final AdminButtonStyle style;
  final bool fullWidth;
  final EdgeInsets? padding;

  const AdminButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.style = AdminButtonStyle.primary,
    this.fullWidth = true,
    this.padding,
  });

  @override
  State<AdminButton> createState() => _AdminButtonState();
}

class _AdminButtonState extends State<AdminButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: isEnabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: AppTheme.fastDuration,
        curve: AppTheme.defaultCurve,
        width: widget.fullWidth ? double.infinity : null,
        padding:
            widget.padding ??
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        transform: Matrix4.diagonal3Values(
          _isPressed ? 0.98 : 1.0,
          _isPressed ? 0.98 : 1.0,
          1.0,
        ),
        decoration: _getDecoration(isEnabled),
        child: Row(
          mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.isLoading) ...[
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(_getTextColor(isEnabled)),
                ),
              ),
            ] else ...[
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20, color: _getTextColor(isEnabled)),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _getTextColor(isEnabled),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  BoxDecoration _getDecoration(bool isEnabled) {
    switch (widget.style) {
      case AdminButtonStyle.primary:
        return BoxDecoration(
          gradient: isEnabled ? AppTheme.primaryGradient : null,
          color: isEnabled ? null : Colors.grey[300],
          borderRadius: AppTheme.mediumRadius,
          boxShadow: isEnabled && !_isPressed
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        );

      case AdminButtonStyle.secondary:
        return BoxDecoration(
          color: isEnabled
              ? AppTheme.primaryBlue.withValues(alpha: 0.1)
              : Colors.grey[100],
          borderRadius: AppTheme.mediumRadius,
          border: Border.all(
            color: isEnabled ? AppTheme.primaryBlue : Colors.grey[300]!,
          ),
        );

      case AdminButtonStyle.danger:
        return BoxDecoration(
          color: isEnabled ? AppTheme.errorRed : Colors.grey[300],
          borderRadius: AppTheme.mediumRadius,
          boxShadow: isEnabled && !_isPressed
              ? [
                  BoxShadow(
                    color: AppTheme.errorRed.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        );

      case AdminButtonStyle.success:
        return BoxDecoration(
          color: isEnabled ? AppTheme.successGreen : Colors.grey[300],
          borderRadius: AppTheme.mediumRadius,
          boxShadow: isEnabled && !_isPressed
              ? [
                  BoxShadow(
                    color: AppTheme.successGreen.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        );

      case AdminButtonStyle.outline:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: AppTheme.mediumRadius,
          border: Border.all(
            color: isEnabled ? Colors.grey[400]! : Colors.grey[300]!,
          ),
        );

      case AdminButtonStyle.text:
        return const BoxDecoration();
    }
  }

  Color _getTextColor(bool isEnabled) {
    if (!isEnabled) return Colors.grey[500]!;

    switch (widget.style) {
      case AdminButtonStyle.primary:
      case AdminButtonStyle.danger:
      case AdminButtonStyle.success:
        return Colors.white;
      case AdminButtonStyle.secondary:
      case AdminButtonStyle.text:
        return AppTheme.primaryBlue;
      case AdminButtonStyle.outline:
        return Colors.black87;
    }
  }
}

enum AdminButtonStyle { primary, secondary, danger, success, outline, text }
