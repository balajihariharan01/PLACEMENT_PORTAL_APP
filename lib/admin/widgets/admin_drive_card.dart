import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/drive.dart';

/// Admin Drive Card Widget
/// Displays drive information in a list item format
class AdminDriveCard extends StatefulWidget {
  final Drive drive;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final int animationIndex;

  const AdminDriveCard({
    super.key,
    required this.drive,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.animationIndex = 0,
  });

  @override
  State<AdminDriveCard> createState() => _AdminDriveCardState();
}

class _AdminDriveCardState extends State<AdminDriveCard>
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
        Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: AppTheme.defaultCurve),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.animationIndex * 80), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    switch (widget.drive.status) {
      case DriveStatus.active:
        return AppTheme.successGreen;
      case DriveStatus.closed:
        return Colors.grey;
      case DriveStatus.upcoming:
        return AppTheme.primaryBlue;
      case DriveStatus.onHold:
        return AppTheme.warningOrange;
    }
  }

  Color _getStatusBgColor() {
    switch (widget.drive.status) {
      case DriveStatus.active:
        return const Color(0xFFE8F5E9);
      case DriveStatus.closed:
        return Colors.grey[100]!;
      case DriveStatus.upcoming:
        return const Color(0xFFE3F2FD);
      case DriveStatus.onHold:
        return const Color(0xFFFFF3E0);
    }
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
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppTheme.largeRadius,
            boxShadow: AppTheme.softShadow,
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Company Logo Placeholder
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: AppTheme.mediumRadius,
                    ),
                    child: Center(
                      child: Text(
                        widget.drive.companyName.isNotEmpty
                            ? widget.drive.companyName[0].toUpperCase()
                            : 'C',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Drive Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.drive.driveName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.drive.companyName,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusBgColor(),
                      borderRadius: AppTheme.pillRadius,
                    ),
                    child: Text(
                      widget.drive.status.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Details Row
              Row(
                children: [
                  _buildInfoChip(Icons.work_outline, widget.drive.jobRole),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    Icons.calendar_today_outlined,
                    _formatDate(widget.drive.dateTime),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Stats and Actions Row
              Row(
                children: [
                  if (widget.drive.salaryPackage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withValues(alpha: 0.1),
                        borderRadius: AppTheme.smallRadius,
                      ),
                      child: Text(
                        widget.drive.salaryPackage!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.successGreen,
                        ),
                      ),
                    ),
                  ],
                  if (widget.drive.registeredCount != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${widget.drive.registeredCount} registered',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                  const Spacer(),
                  // Action Buttons
                  if (widget.onEdit != null)
                    _buildActionButton(
                      Icons.edit_outlined,
                      AppTheme.primaryBlue,
                      widget.onEdit!,
                    ),
                  if (widget.onDelete != null) ...[
                    const SizedBox(width: 8),
                    _buildActionButton(
                      Icons.delete_outline,
                      AppTheme.errorRed,
                      widget.onDelete!,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: AppTheme.smallRadius,
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
