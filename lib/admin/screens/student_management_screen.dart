import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/student.dart';
import '../services/student_service.dart';
import '../widgets/state_widgets.dart';
import '../../widgets/app_logo.dart';
import 'student_form_screen.dart';
import 'student_details_screen.dart';

/// Student Management Screen - Mobile-First Native Design
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
  PlacementStatus? _selectedFilter;

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
    setState(() => _isLoading = true);
    final response = await _studentService.getAllStudents(
      status: _selectedFilter,
      searchQuery: _searchController.text.isNotEmpty
          ? _searchController.text
          : null,
    );
    if (!mounted) return;
    setState(() {
      _students = response.data;
      _isLoading = false;
    });
  }

  void _navigateToDetails(Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentDetailsScreen(studentId: student.id),
      ),
    ).then((result) {
      if (result == true) _loadStudents();
    });
  }

  void _navigateToAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StudentFormScreen()),
    ).then((result) {
      if (result == true) _loadStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),
            _buildFilterChips(),
            Expanded(child: _buildStudentList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAdd,
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Student', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppLogo.adaptive(context: context, height: 32),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Students',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${_students?.length ?? 0} students registered',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: AppTheme.mediumRadius,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _loadStudents(),
              decoration: InputDecoration(
                hintText: 'Search by name, USN...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
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
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildFilterChip('All', null),
            const SizedBox(width: 8),
            _buildFilterChip('Placed', PlacementStatus.placed),
            const SizedBox(width: 8),
            _buildFilterChip('Not Placed', PlacementStatus.notPlaced),
            const SizedBox(width: 8),
            _buildFilterChip('In Process', PlacementStatus.inProcess),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, PlacementStatus? status) {
    final isSelected = _selectedFilter == status;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = status);
        _loadStudents();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade100,
          borderRadius: AppTheme.pillRadius,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildShimmerCard(),
        ),
      );
    }

    if (_students == null || _students!.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.school_outlined,
        title: 'No Students Found',
        subtitle: 'Add your first student to get started',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStudents,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: _students!.length,
        itemBuilder: (context, index) {
          final student = _students![index];
          return _buildStudentCard(student, index);
        },
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: AppTheme.mediumRadius,
      ),
    );
  }

  Widget _buildStudentCard(Student student, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.mediumRadius,
          boxShadow: AppTheme.softShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _navigateToDetails(student),
            borderRadius: AppTheme.mediumRadius,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primaryBlue.withValues(
                      alpha: 0.1,
                    ),
                    child: Text(
                      student.initials,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${student.department} • ${student.yearDisplay}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _buildInfoChip(
                              'CGPA: ${student.cgpa.toStringAsFixed(1)}',
                            ),
                            const SizedBox(width: 8),
                            _buildStatusChip(student.placementStatus),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildStatusChip(PlacementStatus status) {
    Color color;
    switch (status) {
      case PlacementStatus.placed:
        color = AppTheme.successGreen;
        break;
      case PlacementStatus.inProcess:
        color = AppTheme.warningOrange;
        break;
      case PlacementStatus.notEligible:
        color = Colors.grey;
        break;
      default:
        color = AppTheme.errorRed;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.shortName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
