import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/drive.dart';
import '../services/drive_service.dart';
import '../widgets/admin_text_field.dart';
import '../widgets/admin_button.dart';
import '../widgets/dialogs.dart';

/// Drive Form Screen
/// Create or edit a placement drive
class DriveFormScreen extends StatefulWidget {
  final Drive? drive;

  const DriveFormScreen({super.key, this.drive});

  @override
  State<DriveFormScreen> createState() => _DriveFormScreenState();
}

class _DriveFormScreenState extends State<DriveFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _driveService = DriveService();

  late TextEditingController _driveNameController;
  late TextEditingController _companyNameController;
  late TextEditingController _locationController;
  late TextEditingController _eligibilityController;
  late TextEditingController _jobRoleController;
  late TextEditingController _descriptionController;
  late TextEditingController _salaryController;

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  DriveStatus _selectedStatus = DriveStatus.upcoming;

  bool _isLoading = false;
  bool get _isEditing => widget.drive != null;

  @override
  void initState() {
    super.initState();

    final drive = widget.drive;
    _driveNameController = TextEditingController(text: drive?.driveName ?? '');
    _companyNameController = TextEditingController(
      text: drive?.companyName ?? '',
    );
    _locationController = TextEditingController(text: drive?.location ?? '');
    _eligibilityController = TextEditingController(
      text: drive?.eligibilityCriteria ?? '',
    );
    _jobRoleController = TextEditingController(text: drive?.jobRole ?? '');
    _descriptionController = TextEditingController(
      text: drive?.description ?? '',
    );
    _salaryController = TextEditingController(text: drive?.salaryPackage ?? '');

    if (drive != null) {
      _selectedDate = drive.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(drive.dateTime);
      _selectedStatus = drive.status;
    }
  }

  @override
  void dispose() {
    _driveNameController.dispose();
    _companyNameController.dispose();
    _locationController.dispose();
    _eligibilityController.dispose();
    _jobRoleController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppTheme.primaryBlue),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final drive = Drive(
      id: widget.drive?.id ?? '',
      driveName: _driveNameController.text.trim(),
      companyName: _companyNameController.text.trim(),
      dateTime: dateTime,
      location: _locationController.text.trim(),
      eligibilityCriteria: _eligibilityController.text.trim(),
      jobRole: _jobRoleController.text.trim(),
      description: _descriptionController.text.trim(),
      status: _selectedStatus,
      salaryPackage: _salaryController.text.trim().isNotEmpty
          ? _salaryController.text.trim()
          : null,
      createdAt: widget.drive?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final response = _isEditing
        ? await _driveService.updateDrive(drive)
        : await _driveService.createDrive(drive);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (response.success) {
      await SuccessDialog.show(
        context: context,
        title: _isEditing ? 'Drive Updated!' : 'Drive Created!',
        message: response.message ?? 'Operation completed successfully',
        onPressed: () {
          Navigator.pop(context, true);
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Operation failed'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.errorRed,
          shape: RoundedRectangleBorder(borderRadius: AppTheme.smallRadius),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Drive' : 'Add New Drive',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section: Basic Information
              _buildSectionHeader('Basic Information'),
              const SizedBox(height: 16),

              AdminTextField(
                label: 'Drive Name',
                hint: 'e.g., TCS Campus Recruitment 2026',
                controller: _driveNameController,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Drive name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              AdminTextField(
                label: 'Company Name',
                hint: 'e.g., Tata Consultancy Services',
                controller: _companyNameController,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Company name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              AdminTextField(
                label: 'Job Role',
                hint: 'e.g., Software Developer',
                controller: _jobRoleController,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Job role is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              AdminTextField(
                label: 'Salary Package',
                hint: 'e.g., ₹ 7 LPA',
                controller: _salaryController,
              ),
              const SizedBox(height: 32),

              // Section: Schedule
              _buildSectionHeader('Schedule'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildDateTimePicker(
                      label: 'Date',
                      value: _formatDate(_selectedDate),
                      icon: Icons.calendar_today_outlined,
                      onTap: _selectDate,
                      isRequired: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateTimePicker(
                      label: 'Time',
                      value: _selectedTime.format(context),
                      icon: Icons.access_time_outlined,
                      onTap: _selectTime,
                      isRequired: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              AdminTextField(
                label: 'Location',
                hint: 'e.g., Main Auditorium, Block A',
                controller: _locationController,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Location is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Section: Details
              _buildSectionHeader('Drive Details'),
              const SizedBox(height: 16),

              AdminTextField(
                label: 'Eligibility Criteria',
                hint: 'e.g., CGPA >= 7.0, No active backlogs',
                controller: _eligibilityController,
                maxLines: 2,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Eligibility criteria is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              AdminTextField(
                label: 'Description',
                hint: 'Describe the drive, selection process, etc.',
                controller: _descriptionController,
                maxLines: 4,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Section: Status
              _buildSectionHeader('Status'),
              const SizedBox(height: 16),
              _buildStatusSelector(),
              const SizedBox(height: 40),

              // Submit Button
              AdminButton(
                text: _isLoading
                    ? 'Saving...'
                    : (_isEditing ? 'Update Drive' : 'Create Drive'),
                icon: _isLoading ? null : Icons.check,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _handleSubmit,
              ),
              const SizedBox(height: 16),

              // Cancel Button
              AdminButton(
                text: 'Cancel',
                style: AdminButtonStyle.outline,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
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
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.errorRed,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: AppTheme.mediumRadius,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Colors.grey[500]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey[500]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: DriveStatus.values.map((status) {
        final isSelected = _selectedStatus == status;
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
          onTap: () => setState(() => _selectedStatus = status),
          child: AnimatedContainer(
            duration: AppTheme.fastDuration,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              borderRadius: AppTheme.mediumRadius,
              border: Border.all(
                color: isSelected ? color : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  Icon(Icons.check_circle, size: 18, color: Colors.white),
                  const SizedBox(width: 6),
                ],
                Text(
                  status.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
