import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/student.dart';
import '../services/student_service.dart';
import '../widgets/admin_button.dart';
import '../widgets/dialogs.dart';
import '../widgets/state_widgets.dart';
import '../security/admin_route_guard.dart';
import 'student_form_screen.dart';

/// Student Details Screen
/// Displays comprehensive student information
/// SECURITY: Protected by AdminRouteGuard (via navigation)
class StudentDetailsScreen extends StatefulWidget {
  final String studentId;

  const StudentDetailsScreen({super.key, required this.studentId});

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  final _studentService = StudentService();

  Student? _student;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  Future<void> _loadStudent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await _studentService.getStudentById(widget.studentId);

    if (!mounted) return;

    if (response.success) {
      setState(() {
        _student = response.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = response.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await ConfirmationDialog.showDelete(
      context: context,
      itemName: _student?.name ?? 'this student',
    );

    if (confirmed != true) return;

    final response = await _studentService.deleteStudent(widget.studentId);

    if (!mounted) return;

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Student deleted successfully'),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Failed to delete'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToEdit() {
    AdminRouteMiddleware.navigateTo(
      context,
      StudentFormScreen(student: _student),
    ).then((result) {
      if (result == true) _loadStudent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldLight,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? ErrorStateWidget(message: _error!, onRetry: _loadStudent)
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_student == null) {
      return const ErrorStateWidget(message: 'Student not found');
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: GestureDetector(
            onTap: () {
              final nav = Navigator.of(context);
              if (nav.canPop()) nav.popUntil((r) => r.isFirst);
            },
            child: Image.asset(
              'assets/images/logo.jpg',
              height: 24,
              fit: BoxFit.contain,
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(background: _buildHeader()),
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card
                _buildStatusCard(),
                const SizedBox(height: 20),

                // Contact Information
                _buildSection(
                  title: 'Contact Information',
                  children: [
                    _buildInfoRow(
                      Icons.email_outlined,
                      'Email',
                      _student!.email,
                    ),
                    _buildInfoRow(
                      Icons.phone_outlined,
                      'Phone',
                      _student!.phone,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Academic Information
                _buildSection(
                  title: 'Academic Information',
                  children: [
                    _buildInfoRow(
                      Icons.business,
                      'Department',
                      _student!.department,
                    ),
                    _buildInfoRow(
                      Icons.school_outlined,
                      'Year',
                      _student!.yearDisplay,
                    ),
                    _buildInfoRow(
                      Icons.grade_outlined,
                      'CGPA',
                      _student!.cgpa.toStringAsFixed(2),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Assigned Drives
                _buildSection(
                  title: 'Assigned Drives',
                  children: [
                    if (_student!.assignedDriveIds.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No drives assigned',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      ...(_student!.assignedDriveIds.map(
                        (id) => ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: AppTheme.smallRadius,
                            ),
                            child: Icon(
                              Icons.campaign_outlined,
                              color: AppTheme.primaryBlue,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            'Drive $id',
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                          ),
                          onTap: () {
                            // Navigate to drive details
                          },
                        ),
                      )),
                  ],
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: AdminButton(
                        text: 'Edit',
                        icon: Icons.edit_outlined,
                        style: AdminButtonStyle.outline,
                        onPressed: _navigateToEdit,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AdminButton(
                        text: 'Delete',
                        icon: Icons.delete_outline,
                        style: AdminButtonStyle.danger,
                        onPressed: _handleDelete,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _student!.initials,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _student!.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _student!.registerNumber,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    Color color;
    IconData icon;
    switch (_student!.placementStatus) {
      case PlacementStatus.placed:
        color = AppTheme.successGreen;
        icon = Icons.check_circle;
        break;
      case PlacementStatus.inProcess:
        color = AppTheme.warningOrange;
        icon = Icons.pending;
        break;
      case PlacementStatus.notPlaced:
        color = Colors.grey;
        icon = Icons.hourglass_empty;
        break;
      case PlacementStatus.notEligible:
        color = AppTheme.errorRed;
        icon = Icons.block;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppTheme.mediumRadius,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Placement Status',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  _student!.placementStatus.displayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.mediumRadius,
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[500]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? '-' : value,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
