import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/student.dart';

/// Student Card Widget
/// Mobile-optimized card for displaying student information in lists
class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final int animationIndex;

  const StudentCard({
    super.key,
    required this.student,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (animationIndex * 50)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppTheme.mediumRadius,
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Avatar, Name, Status
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        student.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and Register Number
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          student.registerNumber,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  _buildStatusBadge(),
                ],
              ),
              const SizedBox(height: 12),
              // Info row: Department, Year, CGPA
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      icon: Icons.business,
                      text: student.department,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(icon: Icons.school, text: student.yearDisplay),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.grade,
                    text: 'CGPA ${student.cgpa.toStringAsFixed(1)}',
                  ),
                ],
              ),
              // Actions row
              if (onEdit != null || onDelete != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      _buildActionButton(
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        color: AppTheme.primaryBlue,
                        onTap: onEdit!,
                      ),
                    if (onEdit != null && onDelete != null)
                      const SizedBox(width: 16),
                    if (onDelete != null)
                      _buildActionButton(
                        icon: Icons.delete_outline,
                        label: 'Delete',
                        color: AppTheme.errorRed,
                        onTap: onDelete!,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    switch (student.placementStatus) {
      case PlacementStatus.placed:
        color = AppTheme.successGreen;
        break;
      case PlacementStatus.inProcess:
        color = AppTheme.warningOrange;
        break;
      case PlacementStatus.notPlaced:
        color = Colors.grey;
        break;
      case PlacementStatus.notEligible:
        color = AppTheme.errorRed;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppTheme.pillRadius,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        student.placementStatus.shortName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
