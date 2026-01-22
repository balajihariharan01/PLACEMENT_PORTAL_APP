import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/student.dart';
import '../services/student_service.dart';
import '../widgets/admin_text_field.dart';
import '../widgets/admin_button.dart';
import '../widgets/dialogs.dart';

/// Student Form Screen
/// Add or Edit student information
/// SECURITY: Protected by AdminRouteGuard (via navigation)
class StudentFormScreen extends StatefulWidget {
  final Student? student;

  const StudentFormScreen({super.key, this.student});

  bool get isEditing => student != null;

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentService = StudentService();

  late TextEditingController _nameController;
  late TextEditingController _registerController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cgpaController;

  String? _selectedDepartment;
  int _selectedYear = 1;
  PlacementStatus _selectedStatus = PlacementStatus.notPlaced;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final student = widget.student;
    _nameController = TextEditingController(text: student?.name ?? '');
    _registerController = TextEditingController(
      text: student?.registerNumber ?? '',
    );
    _emailController = TextEditingController(text: student?.email ?? '');
    _phoneController = TextEditingController(text: student?.phone ?? '');
    _cgpaController = TextEditingController(
      text: student?.cgpa != null ? student!.cgpa.toString() : '',
    );
    _selectedDepartment = student?.department;
    _selectedYear = student?.year ?? 1;
    _selectedStatus = student?.placementStatus ?? PlacementStatus.notPlaced;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _registerController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cgpaController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a department'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final student = Student(
      id: widget.student?.id ?? '',
      name: _nameController.text.trim(),
      registerNumber: _registerController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      department: _selectedDepartment!,
      year: _selectedYear,
      placementStatus: _selectedStatus,
      cgpa: double.tryParse(_cgpaController.text) ?? 0.0,
      assignedDriveIds: widget.student?.assignedDriveIds ?? [],
      createdAt: widget.student?.createdAt ?? DateTime.now(),
    );

    final response = widget.isEditing
        ? await _studentService.updateStudent(student)
        : await _studentService.createStudent(student);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (response.success) {
      await SuccessDialog.show(
        context: context,
        title: widget.isEditing ? 'Student Updated' : 'Student Added',
        message: widget.isEditing
            ? 'Student information has been updated successfully.'
            : 'New student has been added successfully.',
      );
      if (mounted) Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'An error occurred'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldLight,
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Student' : 'Add Student'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Tooltip(
            message: 'Back to Home',
            child: IconButton(
              icon: const Icon(Icons.home_rounded),
              onPressed: () {
                final nav = Navigator.of(context);
                if (nav.canPop()) {
                  nav.popUntil((route) => route.isFirst);
                }
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personal Information Section
                _buildSectionHeader('Personal Information'),
                const SizedBox(height: 16),

                AdminTextField(
                  label: 'Full Name',
                  hint: 'Enter student name',
                  controller: _nameController,
                  isRequired: true,
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: Colors.grey[500],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                AdminTextField(
                  label: 'Register Number',
                  hint: 'e.g., CS2021001',
                  controller: _registerController,
                  isRequired: true,
                  prefixIcon: Icon(
                    Icons.badge_outlined,
                    color: Colors.grey[500],
                  ),
                  enabled: !widget.isEditing, // Can't change register number
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Register number is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                AdminTextField(
                  label: 'Email',
                  hint: 'student@college.edu',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  isRequired: true,
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Colors.grey[500],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                AdminTextField(
                  label: 'Phone Number',
                  hint: '+91 98765 43210',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 24),

                // Academic Information Section
                _buildSectionHeader('Academic Information'),
                const SizedBox(height: 16),

                // Department Dropdown
                _buildDropdownField(
                  label: 'Department',
                  isRequired: true,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedDepartment,
                    decoration: InputDecoration(
                      hintText: 'Select department',
                      border: OutlineInputBorder(
                        borderRadius: AppTheme.mediumRadius,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: Departments.all
                        .map(
                          (dept) => DropdownMenuItem(
                            value: dept,
                            child: Text(
                              dept,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedDepartment = value),
                  ),
                ),
                const SizedBox(height: 16),

                // Year Selector
                _buildDropdownField(
                  label: 'Year',
                  isRequired: true,
                  child: DropdownButtonFormField<int>(
                    initialValue: _selectedYear,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: AppTheme.mediumRadius,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: [1, 2, 3, 4]
                        .map(
                          (year) => DropdownMenuItem(
                            value: year,
                            child: Text(
                              _getYearDisplay(year),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedYear = value!),
                  ),
                ),
                const SizedBox(height: 16),

                AdminTextField(
                  label: 'CGPA',
                  hint: 'e.g., 8.5',
                  controller: _cgpaController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefixIcon: Icon(
                    Icons.grade_outlined,
                    color: Colors.grey[500],
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final cgpa = double.tryParse(value);
                      if (cgpa == null || cgpa < 0 || cgpa > 10) {
                        return 'Enter a valid CGPA (0-10)';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Placement Status Section
                _buildSectionHeader('Placement Status'),
                const SizedBox(height: 12),
                _buildStatusSelector(),
                const SizedBox(height: 32),

                // Submit Button
                AdminButton(
                  text: widget.isEditing ? 'Update Student' : 'Add Student',
                  icon: widget.isEditing ? Icons.save : Icons.person_add,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _handleSubmit,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required Widget child,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text('*', style: TextStyle(color: AppTheme.errorRed)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildStatusSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PlacementStatus.values.map((status) {
        final isSelected = _selectedStatus == status;
        Color color;
        switch (status) {
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

        return GestureDetector(
          onTap: () => setState(() => _selectedStatus = status),
          child: AnimatedContainer(
            duration: AppTheme.fastDuration,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.15)
                  : Colors.grey[100],
              borderRadius: AppTheme.pillRadius,
              border: Border.all(
                color: isSelected ? color : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              status.displayName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : Colors.grey[700],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getYearDisplay(int year) {
    switch (year) {
      case 1:
        return '1st Year';
      case 2:
        return '2nd Year';
      case 3:
        return '3rd Year';
      case 4:
        return '4th Year';
      default:
        return '$year Year';
    }
  }
}
