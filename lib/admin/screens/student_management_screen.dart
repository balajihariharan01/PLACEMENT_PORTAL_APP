import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/student.dart';
import '../services/student_service.dart';
import '../widgets/student_card.dart';
import '../widgets/state_widgets.dart';
import '../widgets/dialogs.dart';
import '../security/admin_route_guard.dart';
import 'student_form_screen.dart';
import 'student_details_screen.dart';
import '../../widgets/branded_header.dart';

/// Student Management Screen
/// SECURITY: Protected by AdminRouteGuard
/// Mobile-first design with search and filter capabilities
class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() =>
      _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final _studentService = StudentService();
  final _searchController = TextEditingController();

  List<Student>? _students;
  bool _isLoading = true;
  String? _error;

  // Filters
  String? _selectedDepartment;
  PlacementStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await _studentService.getAllStudents(
      department: _selectedDepartment,
      status: _selectedStatus,
      searchQuery: _searchController.text,
    );

    if (!mounted) return;

    if (response.success) {
      setState(() {
        _students = response.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = response.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteStudent(Student student) async {
    final confirmed = await ConfirmationDialog.showDelete(
      context: context,
      itemName: student.name,
    );

    if (confirmed != true) return;

    final response = await _studentService.deleteStudent(student.id);

    if (!mounted) return;

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Student deleted successfully'),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadStudents();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Failed to delete student'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToAddStudent() {
    AdminRouteMiddleware.navigateTo(context, const StudentFormScreen()).then((
      result,
    ) {
      if (result == true) _loadStudents();
    });
  }

  void _navigateToEditStudent(Student student) {
    AdminRouteMiddleware.navigateTo(
      context,
      StudentFormScreen(student: student),
    ).then((result) {
      if (result == true) _loadStudents();
    });
  }

  void _navigateToStudentDetails(Student student) {
    AdminRouteMiddleware.navigateTo(
      context,
      StudentDetailsScreen(studentId: student.id),
    ).then((result) {
      if (result == true) _loadStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldLight,
      body: SafeArea(
        child: Column(
          children: [
            BrandedHeader(
              title: 'Student Directory',
              subtitle: 'Manage student profiles and placement status',
              showBackButton: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: _loadStudents,
                ),
              ],
            ),
            // Search and Filter Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: AppTheme.mediumRadius,
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => _loadStudents(),
                      decoration: InputDecoration(
                        hintText: 'Search students...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _loadStudents();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterDropdown<String>(
                          value: _selectedDepartment,
                          hint: 'Department',
                          items: Departments.all
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(
                                    d,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedDepartment = value);
                            _loadStudents();
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildFilterDropdown<PlacementStatus>(
                          value: _selectedStatus,
                          hint: 'Status',
                          items: PlacementStatus.values
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    s.shortName,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedStatus = value);
                            _loadStudents();
                          },
                        ),
                        if (_selectedDepartment != null ||
                            _selectedStatus != null) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDepartment = null;
                                _selectedStatus = null;
                              });
                              _loadStudents();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.errorRed.withValues(alpha: 0.1),
                                borderRadius: AppTheme.pillRadius,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.clear,
                                    size: 14,
                                    color: AppTheme.errorRed,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Clear',
                                    style: TextStyle(
                                      color: AppTheme.errorRed,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Student List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadStudents,
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddStudent,
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Student', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildFilterDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: value != null
            ? Colors.white
            : Colors.white.withValues(alpha: 0.2),
        borderRadius: AppTheme.pillRadius,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              color: value != null ? Colors.grey[600] : Colors.white,
              fontSize: 13,
            ),
          ),
          items: items,
          onChanged: onChanged,
          style: TextStyle(color: Colors.grey[800], fontSize: 13),
          icon: Icon(
            Icons.arrow_drop_down,
            color: value != null ? Colors.grey[600] : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: LoadingSkeleton(height: 140),
        ),
      );
    }

    if (_error != null) {
      return ErrorStateWidget(message: _error!, onRetry: _loadStudents);
    }

    if (_students == null || _students!.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.school_outlined,
        title: 'No Students Found',
        subtitle:
            _searchController.text.isNotEmpty ||
                _selectedDepartment != null ||
                _selectedStatus != null
            ? 'Try adjusting your search or filters'
            : 'Add your first student to get started',
        buttonText: 'Add Student',
        onButtonPressed: _navigateToAddStudent,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _students!.length,
      itemBuilder: (context, index) {
        final student = _students![index];
        return StudentCard(
          student: student,
          animationIndex: index,
          onTap: () => _navigateToStudentDetails(student),
          onEdit: () => _navigateToEditStudent(student),
          onDelete: () => _deleteStudent(student),
        );
      },
    );
  }
}
