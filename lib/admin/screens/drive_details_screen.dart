import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/drive.dart';
import '../services/drive_service.dart';
import '../widgets/admin_button.dart';
import '../widgets/dialogs.dart';
import 'drive_form_screen.dart';

/// Drive Details Screen
/// Full drive information display with actions
class DriveDetailsScreen extends StatefulWidget {
  final Drive drive;

  const DriveDetailsScreen({super.key, required this.drive});

  @override
  State<DriveDetailsScreen> createState() => _DriveDetailsScreenState();
}

class _DriveDetailsScreenState extends State<DriveDetailsScreen>
    with SingleTickerProviderStateMixin {
  final _driveService = DriveService();

  late Drive _drive;
  bool _isStatusUpdating = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _drive = widget.drive;

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    switch (_drive.status) {
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
    switch (_drive.status) {
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

  Future<void> _handleEdit() async {
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DriveFormScreen(drive: _drive),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: AppTheme.defaultCurve,
                  ),
                ),
            child: child,
          );
        },
        transitionDuration: AppTheme.normalDuration,
      ),
    );

    if (result == true) {
      // Refresh drive data
      final response = await _driveService.getDriveById(_drive.id);
      if (response.success && response.data != null) {
        setState(() => _drive = response.data!);
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await ConfirmationDialog.showDelete(
      context: context,
      itemName: 'drive',
    );

    if (confirmed == true) {
      final response = await _driveService.deleteDrive(_drive.id);

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Drive deleted successfully'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.successGreen,
            shape: RoundedRectangleBorder(borderRadius: AppTheme.smallRadius),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to delete drive'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.errorRed,
            shape: RoundedRectangleBorder(borderRadius: AppTheme.smallRadius),
          ),
        );
      }
    }
  }

  Future<void> _handleStatusChange(DriveStatus newStatus) async {
    if (_drive.status == newStatus) return;

    setState(() => _isStatusUpdating = true);

    final response = await _driveService.updateDriveStatus(
      _drive.id,
      newStatus,
    );

    if (!mounted) return;

    setState(() => _isStatusUpdating = false);

    if (response.success && response.data != null) {
      setState(() => _drive = response.data!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to ${newStatus.displayName}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.successGreen,
          shape: RoundedRectangleBorder(borderRadius: AppTheme.smallRadius),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Failed to update status'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.errorRed,
          shape: RoundedRectangleBorder(borderRadius: AppTheme.smallRadius),
        ),
      );
    }
  }

  void _showStatusSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Update Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ...DriveStatus.values.map((status) {
              final isSelected = _drive.status == status;
              Color color;

              switch (status) {
                case DriveStatus.active:
                  color = AppTheme.successGreen;
                  break;
                case DriveStatus.closed:
                  color = Colors.grey;
                  break;
                case DriveStatus.upcoming:
                  color = AppTheme.primaryBlue;
                  break;
                case DriveStatus.onHold:
                  color = AppTheme.warningOrange;
                  break;
              }

              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _handleStatusChange(status);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.1)
                        : Colors.grey[50],
                    borderRadius: AppTheme.mediumRadius,
                    border: Border.all(
                      color: isSelected ? color : Colors.grey[200]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getStatusIcon(status),
                          color: color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          status.displayName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (isSelected) Icon(Icons.check_circle, color: color),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(DriveStatus status) {
    switch (status) {
      case DriveStatus.active:
        return Icons.play_circle_outline;
      case DriveStatus.closed:
        return Icons.check_circle_outline;
      case DriveStatus.upcoming:
        return Icons.schedule;
      case DriveStatus.onHold:
        return Icons.pause_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldLight,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar with Header
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppTheme.primaryBlue,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  onPressed: _handleEdit,
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.mediumRadius,
                  ),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _handleDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: AppTheme.errorRed,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Delete Drive',
                            style: TextStyle(color: AppTheme.errorRed),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(background: _buildHeader()),
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Status Update Section
                  _buildStatusSection(),
                  const SizedBox(height: 24),

                  // Drive Info Section
                  _buildInfoSection(),
                  const SizedBox(height: 24),

                  // Statistics Section
                  _buildStatisticsSection(),
                  const SizedBox(height: 24),

                  // Eligibility Section
                  _buildEligibilitySection(),
                  const SizedBox(height: 24),

                  // Description Section
                  _buildDescriptionSection(),
                  const SizedBox(height: 32),

                  // Action Buttons
                  AdminButton(
                    text: 'Edit Drive',
                    icon: Icons.edit,
                    onPressed: _handleEdit,
                  ),
                  const SizedBox(height: 12),
                  AdminButton(
                    text: 'Delete Drive',
                    icon: Icons.delete_outline,
                    style: AdminButtonStyle.danger,
                    onPressed: _handleDelete,
                  ),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: AppTheme.mediumRadius,
                    ),
                    child: Center(
                      child: Text(
                        _drive.companyName.isNotEmpty
                            ? _drive.companyName[0].toUpperCase()
                            : 'C',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _drive.companyName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _drive.driveName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.largeRadius,
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Status',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusBgColor(),
                        borderRadius: AppTheme.pillRadius,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isStatusUpdating)
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  _getStatusColor(),
                                ),
                              ),
                            )
                          else
                            Icon(
                              _getStatusIcon(_drive.status),
                              size: 16,
                              color: _getStatusColor(),
                            ),
                          const SizedBox(width: 6),
                          Text(
                            _drive.status.displayName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _showStatusSheet,
            icon: const Icon(Icons.sync, size: 18),
            label: const Text('Change'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: AppTheme.mediumRadius,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.largeRadius,
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.work_outline, 'Job Role', _drive.jobRole),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Date & Time',
            '${_formatDate(_drive.dateTime)} at ${_formatTime(_drive.dateTime)}',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.location_on_outlined,
            'Location',
            _drive.location,
          ),
          if (_drive.salaryPackage != null) ...[
            const Divider(height: 24),
            _buildInfoRow(
              Icons.payments_outlined,
              'Package',
              _drive.salaryPackage!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: AppTheme.smallRadius,
          ),
          child: Icon(icon, size: 18, color: AppTheme.primaryBlue),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Registered',
            '${_drive.registeredCount ?? 0}',
            Icons.people_outline,
            AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Placed',
            '${_drive.placedCount ?? 0}',
            Icons.emoji_events_outlined,
            AppTheme.successGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.largeRadius,
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildEligibilitySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.largeRadius,
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.checklist, color: AppTheme.primaryBlue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Eligibility Criteria',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _drive.eligibilityCriteria,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.largeRadius,
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _drive.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
