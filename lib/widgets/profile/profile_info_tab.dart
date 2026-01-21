import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/validators.dart';

/// Profile Info Tab with Full Field Validation
/// All required fields show * and inline error messages
/// Save button disabled until validation passes
class ProfileInfoTab extends StatefulWidget {
  final Function(String) onNameChanged;
  final String initialName;

  const ProfileInfoTab({
    super.key,
    required this.onNameChanged,
    this.initialName = '',
  });

  @override
  State<ProfileInfoTab> createState() => _ProfileInfoTabState();
}

class _ProfileInfoTabState extends State<ProfileInfoTab> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _tenthMarkController = TextEditingController();
  final _twelfthMarkController = TextEditingController();
  final _diplomaMarkController = TextEditingController();
  final _ugMarkController = TextEditingController();
  final _pgMarkController = TextEditingController();
  final _backlogsController = TextEditingController();

  DateTime? _selectedDOB;
  String? _selectedGender;
  final bool _isEmailVerified = false; // Simulated verification status

  // Error states
  String? _dobError;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    // Validate name and update parent if valid
    final error = ProfileValidators.validateName(_nameController.text);
    if (error == null && _nameController.text.trim().isNotEmpty) {
      widget.onNameChanged(_nameController.text.trim());
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _tenthMarkController.dispose();
    _twelfthMarkController.dispose();
    _diplomaMarkController.dispose();
    _ugMarkController.dispose();
    _pgMarkController.dispose();
    _backlogsController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    // Check all required fields
    if (ProfileValidators.validateName(_nameController.text) != null) {
      return false;
    }
    if (ProfileValidators.validateEmail(_emailController.text) != null) {
      return false;
    }
    if (ProfileValidators.validateMobile(_mobileController.text) != null) {
      return false;
    }
    if (ProfileValidators.validateDOB(_selectedDOB) != null) {
      return false;
    }
    if (ProfileValidators.validateGender(_selectedGender) != null) {
      return false;
    }
    if (ProfileValidators.validatePercentage(_tenthMarkController.text) !=
        null) {
      return false;
    }
    if (ProfileValidators.validatePercentage(_twelfthMarkController.text) !=
        null) {
      return false;
    }
    if (ProfileValidators.validatePercentage(
          _diplomaMarkController.text,
          required: false,
        ) !=
        null) {
      return false;
    }
    if (ProfileValidators.validateCGPA(_ugMarkController.text) != null) {
      return false;
    }
    if (ProfileValidators.validateCGPA(
          _pgMarkController.text,
          required: false,
        ) !=
        null) {
      return false;
    }
    if (ProfileValidators.validateBacklogs(_backlogsController.text) != null) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        autovalidateMode: _isEditing
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Edit Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Profile Info',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                _buildEditButton(),
              ],
            ),
            const SizedBox(height: 8),
            // Info message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fields marked with * are required',
                      style: TextStyle(fontSize: 13, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Personal Information Section
            _buildSectionTitle('Personal Information'),
            const SizedBox(height: 16),

            // Full Name
            _buildValidatedTextField(
              label: 'Full Name',
              controller: _nameController,
              hint: 'Enter your full name',
              icon: Icons.person_outline,
              validator: ProfileValidators.validateName,
              enabled: _isEditing,
              isRequired: true,
            ),

            // Email (with lock indicator if verified)
            _buildValidatedTextField(
              label: 'Email Address',
              controller: _emailController,
              hint: 'Enter your email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: ProfileValidators.validateEmail,
              enabled: _isEditing && !_isEmailVerified,
              isRequired: true,
              isLocked: _isEmailVerified,
              lockMessage: 'Email verified - cannot be changed',
            ),

            // Mobile Number
            _buildValidatedTextField(
              label: 'Mobile Number',
              controller: _mobileController,
              hint: 'Enter 10-digit mobile number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              validator: ProfileValidators.validateMobile,
              enabled: _isEditing,
              isRequired: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            // Date of Birth
            _buildDatePicker(
              label: 'Date of Birth',
              value: _selectedDOB,
              hint: 'Select your date of birth',
              icon: Icons.calendar_today_outlined,
              enabled: _isEditing,
              isRequired: true,
              error: _dobError,
              onChanged: (date) {
                setState(() {
                  _selectedDOB = date;
                  _dobError = ProfileValidators.validateDOB(date);
                });
              },
            ),

            // Gender Dropdown
            _buildValidatedDropdown(
              label: 'Gender',
              value: _selectedGender,
              items: _genderOptions,
              hint: 'Select your gender',
              icon: Icons.wc_outlined,
              enabled: _isEditing,
              isRequired: true,
              validator: (v) => ProfileValidators.validateGender(v),
              onChanged: (value) {
                setState(() => _selectedGender = value);
              },
            ),

            const SizedBox(height: 24),

            // Academic Information Section
            _buildSectionTitle('Academic Information'),
            const SizedBox(height: 16),

            // 10th Percentage
            _buildValidatedTextField(
              label: '10th Percentage',
              controller: _tenthMarkController,
              hint: 'Enter 10th mark (0-100)',
              icon: Icons.school_outlined,
              keyboardType: TextInputType.number,
              suffix: '%',
              validator: (v) => ProfileValidators.validatePercentage(v),
              enabled: _isEditing,
              isRequired: true,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
            ),

            // 12th Percentage
            _buildValidatedTextField(
              label: '12th Percentage',
              controller: _twelfthMarkController,
              hint: 'Enter 12th mark (0-100)',
              icon: Icons.school_outlined,
              keyboardType: TextInputType.number,
              suffix: '%',
              validator: (v) => ProfileValidators.validatePercentage(v),
              enabled: _isEditing,
              isRequired: true,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
            ),

            // Diploma Percentage (Optional)
            _buildValidatedTextField(
              label: 'Diploma Percentage',
              controller: _diplomaMarkController,
              hint: 'Enter diploma mark or leave empty',
              icon: Icons.school_outlined,
              keyboardType: TextInputType.number,
              suffix: '%',
              validator: (v) =>
                  ProfileValidators.validatePercentage(v, required: false),
              enabled: _isEditing,
              isRequired: false,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
            ),

            // UG CGPA
            _buildValidatedTextField(
              label: 'UG Overall CGPA',
              controller: _ugMarkController,
              hint: 'Enter UG CGPA (0-10)',
              icon: Icons.grade_outlined,
              keyboardType: TextInputType.number,
              validator: (v) => ProfileValidators.validateCGPA(v),
              enabled: _isEditing,
              isRequired: true,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
            ),

            // PG CGPA (Optional)
            _buildValidatedTextField(
              label: 'PG Overall CGPA',
              controller: _pgMarkController,
              hint: 'Enter PG CGPA (if applicable)',
              icon: Icons.grade_outlined,
              keyboardType: TextInputType.number,
              validator: (v) =>
                  ProfileValidators.validateCGPA(v, required: false),
              enabled: _isEditing,
              isRequired: false,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
            ),

            // Current Backlogs
            _buildValidatedTextField(
              label: 'Current Backlogs',
              controller: _backlogsController,
              hint: 'Enter number of backlogs',
              icon: Icons.warning_amber_outlined,
              keyboardType: TextInputType.number,
              validator: ProfileValidators.validateBacklogs,
              enabled: _isEditing,
              isRequired: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            const SizedBox(height: 24),

            // Save Button (visible when editing)
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isFormValid ? _handleSave : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFormValid
                        ? const Color(0xFF1976D2)
                        : Colors.grey[300],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_isFormValid ? Icons.save : Icons.block, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _isFormValid
                            ? 'Save Changes'
                            : 'Complete All Required Fields',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    return GestureDetector(
      onTap: () {
        setState(() => _isEditing = !_isEditing);
        if (!_isEditing) {
          // Reset form when canceling
          _formKey.currentState?.reset();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _isEditing ? Colors.red.shade50 : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isEditing ? Icons.close : Icons.edit_outlined,
              size: 18,
              color: _isEditing ? Colors.red : Colors.blue[600],
            ),
            const SizedBox(width: 6),
            Text(
              _isEditing ? 'Cancel' : 'Edit',
              style: TextStyle(
                fontSize: 14,
                color: _isEditing ? Colors.red : Colors.blue[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF1976D2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildValidatedTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    int? maxLength,
    String? suffix,
    bool enabled = true,
    bool isRequired = true,
    bool isLocked = false,
    String? lockMessage,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              if (isLocked) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, size: 12, color: Colors.green[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (isLocked && lockMessage != null) ...[
            const SizedBox(height: 2),
            Text(
              lockMessage,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            maxLength: maxLength,
            inputFormatters: inputFormatters,
            validator: validator,
            onChanged: (_) =>
                setState(() {}), // Trigger rebuild for button state
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: Icon(icon, color: Colors.grey[500], size: 22),
              suffixText: suffix,
              suffixStyle: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              counterText: '',
              filled: true,
              fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF1976D2),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? value,
    required String hint,
    required IconData icon,
    required bool enabled,
    required bool isRequired,
    required String? error,
    required Function(DateTime?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: enabled
                ? () => _selectDate(context, value, onChanged)
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: enabled ? Colors.grey[50] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: error != null ? Colors.red : Colors.grey.shade300,
                  width: error != null ? 1 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.grey[500], size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value != null
                          ? '${value.day.toString().padLeft(2, '0')}-${_getMonthName(value.month)}-${value.year}'
                          : hint,
                      style: TextStyle(
                        fontSize: 14,
                        color: value != null
                            ? Colors.black87
                            : Colors.grey[400],
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.grey[500]),
                ],
              ),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const SizedBox(width: 12),
                Text(
                  error,
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildValidatedDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required String hint,
    required IconData icon,
    required bool enabled,
    required bool isRequired,
    required String? Function(String?) validator,
    required Function(String?) onChanged,
  }) {
    final error = _isEditing ? validator(value) : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: enabled ? Colors.grey[50] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: error != null && _isEditing
                    ? Colors.red
                    : Colors.grey.shade300,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Row(
                  children: [
                    Icon(icon, color: Colors.grey[500], size: 22),
                    const SizedBox(width: 12),
                    Text(
                      hint,
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: Colors.grey[500]),
                items: items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Row(
                      children: [
                        Icon(icon, color: Colors.grey[500], size: 22),
                        const SizedBox(width: 12),
                        Text(item),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: enabled
                    ? (val) {
                        onChanged(val);
                        setState(() {});
                      }
                    : null,
              ),
            ),
          ),
          if (error != null && _isEditing) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const SizedBox(width: 12),
                Text(
                  error,
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime? currentValue,
    Function(DateTime?) onChanged,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentValue ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF1976D2)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isEditing = false);
      // Update name in parent
      widget.onNameChanged(_nameController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Profile information saved successfully'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
