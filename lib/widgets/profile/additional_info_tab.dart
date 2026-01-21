import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/validators.dart';

/// Additional Info Tab with UG + PG Validation
/// Supports both Arts and Engineering students with conditional fields
/// PG section is optional but if any field is filled, all become required
class AdditionalInfoTab extends StatefulWidget {
  const AdditionalInfoTab({super.key});

  @override
  State<AdditionalInfoTab> createState() => _AdditionalInfoTabState();
}

class _AdditionalInfoTabState extends State<AdditionalInfoTab> {
  bool _isEditing = false;
  bool _showPGSection = false;
  final _formKey = GlobalKey<FormState>();

  // UG Controllers
  final _ugInstitutionController = TextEditingController();
  final _ugSpecializationController = TextEditingController();
  String? _selectedUGDegree;
  String? _selectedUGMode;
  String? _selectedUGYear;

  // UG Semester GPA Controllers
  final _ugSem1Controller = TextEditingController();
  final _ugSem2Controller = TextEditingController();
  final _ugSem3Controller = TextEditingController();
  final _ugSem4Controller = TextEditingController();
  final _ugSem5Controller = TextEditingController();
  final _ugSem6Controller = TextEditingController();
  final _ugSem7Controller = TextEditingController();
  final _ugSem8Controller = TextEditingController();

  // PG Controllers
  final _pgInstitutionController = TextEditingController();
  final _pgSpecializationController = TextEditingController();
  String? _selectedPGDegree;
  String? _selectedPGYear;

  // PG Semester GPA Controllers
  final _pgSem1Controller = TextEditingController();
  final _pgSem2Controller = TextEditingController();
  final _pgSem3Controller = TextEditingController();
  final _pgSem4Controller = TextEditingController();

  // Dropdown Options
  final List<String> _ugArtsOptions = ['BA', 'BSc', 'BCom', 'BBA', 'BCA'];
  final List<String> _ugEnggOptions = ['BE', 'BTech', 'BSc Engineering'];
  final List<String> _ugModeOptions = ['Arts & Science', 'Engineering'];
  final List<String> _pgOptions = [
    'MA',
    'MSc',
    'MCom',
    'MBA',
    'MCA',
    'MTech',
    'ME',
  ];

  List<String> get _yearOptions {
    final currentYear = DateTime.now().year;
    return List.generate(15, (i) => '${currentYear - 10 + i}');
  }

  List<String> get _ugDegreeOptions {
    if (_selectedUGMode == 'Engineering') {
      return _ugEnggOptions;
    }
    return _ugArtsOptions;
  }

  bool get _isEngineering => _selectedUGMode == 'Engineering';

  // Check if any PG field is filled
  bool get _hasPGData {
    return _pgInstitutionController.text.isNotEmpty ||
        _pgSpecializationController.text.isNotEmpty ||
        _selectedPGDegree != null ||
        _selectedPGYear != null ||
        _pgSem1Controller.text.isNotEmpty ||
        _pgSem2Controller.text.isNotEmpty ||
        _pgSem3Controller.text.isNotEmpty ||
        _pgSem4Controller.text.isNotEmpty;
  }

  bool get _isUGFormValid {
    if (ProfileValidators.validateDropdown(_selectedUGMode, 'UG Mode') !=
        null) {
      return false;
    }
    if (ProfileValidators.validateRequired(
          _ugInstitutionController.text,
          'Institution',
        ) !=
        null) {
      return false;
    }
    if (ProfileValidators.validateDropdown(_selectedUGDegree, 'Degree') !=
        null) {
      return false;
    }
    if (ProfileValidators.validateRequired(
          _ugSpecializationController.text,
          'Specialization',
        ) !=
        null) {
      return false;
    }
    if (ProfileValidators.validateYearOfPassing(_selectedUGYear) != null) {
      return false;
    }

    // Validate all required semester GPAs
    if (ProfileValidators.validateGPA(_ugSem1Controller.text) != null) {
      return false;
    }
    if (ProfileValidators.validateGPA(_ugSem2Controller.text) != null) {
      return false;
    }
    if (ProfileValidators.validateGPA(_ugSem3Controller.text) != null) {
      return false;
    }
    if (ProfileValidators.validateGPA(_ugSem4Controller.text) != null) {
      return false;
    }
    if (ProfileValidators.validateGPA(_ugSem5Controller.text) != null) {
      return false;
    }
    if (ProfileValidators.validateGPA(_ugSem6Controller.text) != null) {
      return false;
    }

    // Engineering requires 7 & 8
    if (_isEngineering) {
      if (ProfileValidators.validateGPA(_ugSem7Controller.text) != null) {
        return false;
      }
      if (ProfileValidators.validateGPA(_ugSem8Controller.text) != null) {
        return false;
      }
    }

    return true;
  }

  bool get _isPGFormValid {
    if (!_showPGSection) {
      return true;
    }
    if (!_hasPGData) {
      return true; // PG is optional if nothing is filled
    }

    // If any PG field is filled, all become required
    if (ProfileValidators.validateRequired(
          _pgInstitutionController.text,
          'Institution',
        ) !=
        null) {
      return false;
    }
    if (ProfileValidators.validateDropdown(_selectedPGDegree, 'Degree') !=
        null) {
      return false;
    }
    if (ProfileValidators.validateRequired(
          _pgSpecializationController.text,
          'Specialization',
        ) !=
        null) {
      return false;
    }
    if (ProfileValidators.validateYearOfPassing(_selectedPGYear) != null) {
      return false;
    }
    if (ProfileValidators.validateGPA(_pgSem1Controller.text) != null) {
      return false;
    }
    if (ProfileValidators.validateGPA(_pgSem2Controller.text) != null) {
      return false;
    }
    if (ProfileValidators.validateGPA(_pgSem3Controller.text) != null) {
      return false;
    }
    if (ProfileValidators.validateGPA(_pgSem4Controller.text) != null) {
      return false;
    }

    return true;
  }

  bool get _isFormValid => _isUGFormValid && _isPGFormValid;

  @override
  void dispose() {
    _ugInstitutionController.dispose();
    _ugSpecializationController.dispose();
    _ugSem1Controller.dispose();
    _ugSem2Controller.dispose();
    _ugSem3Controller.dispose();
    _ugSem4Controller.dispose();
    _ugSem5Controller.dispose();
    _ugSem6Controller.dispose();
    _ugSem7Controller.dispose();
    _ugSem8Controller.dispose();
    _pgInstitutionController.dispose();
    _pgSpecializationController.dispose();
    _pgSem1Controller.dispose();
    _pgSem2Controller.dispose();
    _pgSem3Controller.dispose();
    _pgSem4Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Edit Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Additional Info',
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
            if (_showPGSection && _hasPGData)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade100),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      size: 18,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'PG fields detected - All PG fields are now required',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // ========== UG DETAILS SECTION ==========
            _buildExpandableSection(
              title: 'UG Details',
              subtitle: 'Undergraduate information',
              icon: Icons.school_outlined,
              initiallyExpanded: true,
              child: Column(
                children: [
                  // UG Mode (Arts / Engineering)
                  _buildValidatedDropdown(
                    label: 'UG Mode',
                    value: _selectedUGMode,
                    items: _ugModeOptions,
                    hint: 'Select UG mode (Arts / Engineering)',
                    icon: Icons.category_outlined,
                    enabled: _isEditing,
                    isRequired: true,
                    onChanged: (value) {
                      setState(() {
                        _selectedUGMode = value;
                        _selectedUGDegree = null;
                      });
                    },
                  ),

                  // UG Institution
                  _buildValidatedTextField(
                    label: 'UG Institution Name',
                    controller: _ugInstitutionController,
                    hint: 'Enter your college/university name',
                    icon: Icons.business_outlined,
                    enabled: _isEditing,
                    isRequired: true,
                    validator: (v) =>
                        ProfileValidators.validateRequired(v, 'Institution'),
                  ),

                  // UG Degree
                  _buildValidatedDropdown(
                    label: 'UG Degree Type',
                    value: _selectedUGDegree,
                    items: _ugDegreeOptions,
                    hint: _selectedUGMode == null
                        ? 'Select UG Mode first'
                        : 'Select your degree',
                    icon: Icons.school_outlined,
                    enabled: _isEditing && _selectedUGMode != null,
                    isRequired: true,
                    onChanged: (value) {
                      setState(() => _selectedUGDegree = value);
                    },
                  ),

                  // UG Specialization
                  _buildValidatedTextField(
                    label: 'UG Department / Specialization',
                    controller: _ugSpecializationController,
                    hint: 'e.g., Computer Science, IT',
                    icon: Icons.subject_outlined,
                    enabled: _isEditing,
                    isRequired: true,
                    validator: (v) =>
                        ProfileValidators.validateRequired(v, 'Specialization'),
                  ),

                  // UG Year of Passing
                  _buildValidatedDropdown(
                    label: 'UG Year of Passing',
                    value: _selectedUGYear,
                    items: _yearOptions,
                    hint: 'Select year',
                    icon: Icons.calendar_month_outlined,
                    enabled: _isEditing,
                    isRequired: true,
                    onChanged: (value) {
                      setState(() => _selectedUGYear = value);
                    },
                    customValidator: ProfileValidators.validateYearOfPassing,
                  ),

                  const SizedBox(height: 16),
                  _buildSubSectionTitle('Semester-wise GPA (0-10)'),
                  const SizedBox(height: 12),

                  // Semester GPAs in rows of 2
                  Row(
                    children: [
                      Expanded(
                        child: _buildGPAField(
                          label: 'Sem 1 *',
                          controller: _ugSem1Controller,
                          enabled: _isEditing,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildGPAField(
                          label: 'Sem 2 *',
                          controller: _ugSem2Controller,
                          enabled: _isEditing,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGPAField(
                          label: 'Sem 3 *',
                          controller: _ugSem3Controller,
                          enabled: _isEditing,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildGPAField(
                          label: 'Sem 4 *',
                          controller: _ugSem4Controller,
                          enabled: _isEditing,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGPAField(
                          label: 'Sem 5 *',
                          controller: _ugSem5Controller,
                          enabled: _isEditing,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildGPAField(
                          label: 'Sem 6 *',
                          controller: _ugSem6Controller,
                          enabled: _isEditing,
                        ),
                      ),
                    ],
                  ),

                  // Semesters 7 & 8 (Engineering only)
                  if (_isEngineering) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.engineering,
                            size: 16,
                            color: Colors.blue[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Engineering: Semester 7 & 8 required',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildGPAField(
                            label: 'Sem 7 *',
                            controller: _ugSem7Controller,
                            enabled: _isEditing,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGPAField(
                            label: 'Sem 8 *',
                            controller: _ugSem8Controller,
                            enabled: _isEditing,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Toggle PG Section
            GestureDetector(
              onTap: () {
                setState(() => _showPGSection = !_showPGSection);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: _showPGSection
                      ? Colors.purple.shade50
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _showPGSection
                        ? Colors.purple.shade100
                        : Colors.blue.shade100,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _showPGSection
                          ? Icons.remove_circle_outline
                          : Icons.add_circle_outline,
                      color: _showPGSection
                          ? Colors.purple[600]
                          : Colors.blue[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _showPGSection
                          ? 'Hide PG Details'
                          : 'Add PG Details (Optional)',
                      style: TextStyle(
                        color: _showPGSection
                            ? Colors.purple[600]
                            : Colors.blue[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ========== PG DETAILS SECTION ==========
            if (_showPGSection) ...[
              const SizedBox(height: 16),
              _buildExpandableSection(
                title: 'PG Details',
                subtitle: _hasPGData
                    ? 'All fields required'
                    : 'Optional section',
                icon: Icons.workspace_premium_outlined,
                initiallyExpanded: true,
                child: Column(
                  children: [
                    // PG Institution
                    _buildValidatedTextField(
                      label: 'PG Institution Name',
                      controller: _pgInstitutionController,
                      hint: 'Enter your PG college/university name',
                      icon: Icons.business_outlined,
                      enabled: _isEditing,
                      isRequired: _hasPGData,
                      validator: (v) => _hasPGData
                          ? ProfileValidators.validateRequired(v, 'Institution')
                          : null,
                    ),

                    // PG Degree
                    _buildValidatedDropdown(
                      label: 'PG Degree',
                      value: _selectedPGDegree,
                      items: _pgOptions,
                      hint: 'Select your PG degree',
                      icon: Icons.school_outlined,
                      enabled: _isEditing,
                      isRequired: _hasPGData,
                      onChanged: (value) {
                        setState(() => _selectedPGDegree = value);
                      },
                    ),

                    // PG Specialization
                    _buildValidatedTextField(
                      label: 'PG Specialization',
                      controller: _pgSpecializationController,
                      hint: 'e.g., Data Science, Software Engineering',
                      icon: Icons.subject_outlined,
                      enabled: _isEditing,
                      isRequired: _hasPGData,
                      validator: (v) => _hasPGData
                          ? ProfileValidators.validateRequired(
                              v,
                              'Specialization',
                            )
                          : null,
                    ),

                    // PG Year of Passing
                    _buildValidatedDropdown(
                      label: 'PG Year of Passing',
                      value: _selectedPGYear,
                      items: _yearOptions,
                      hint: 'Select year',
                      icon: Icons.calendar_month_outlined,
                      enabled: _isEditing,
                      isRequired: _hasPGData,
                      onChanged: (value) {
                        setState(() => _selectedPGYear = value);
                      },
                      customValidator: _hasPGData
                          ? ProfileValidators.validateYearOfPassing
                          : null,
                    ),

                    const SizedBox(height: 16),
                    _buildSubSectionTitle('PG Semester-wise GPA (0-10)'),
                    const SizedBox(height: 12),

                    // PG Semester GPAs
                    Row(
                      children: [
                        Expanded(
                          child: _buildGPAField(
                            label: _hasPGData ? 'Sem 1 *' : 'Sem 1',
                            controller: _pgSem1Controller,
                            enabled: _isEditing,
                            required: _hasPGData,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGPAField(
                            label: _hasPGData ? 'Sem 2 *' : 'Sem 2',
                            controller: _pgSem2Controller,
                            enabled: _isEditing,
                            required: _hasPGData,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildGPAField(
                            label: _hasPGData ? 'Sem 3 *' : 'Sem 3',
                            controller: _pgSem3Controller,
                            enabled: _isEditing,
                            required: _hasPGData,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGPAField(
                            label: _hasPGData ? 'Sem 4 *' : 'Sem 4',
                            controller: _pgSem4Controller,
                            enabled: _isEditing,
                            required: _hasPGData,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

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
                            : 'Complete Required Fields',
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

  Widget _buildSubSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
    bool initiallyExpanded = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue[600], size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          children: [child],
        ),
      ),
    );
  }

  Widget _buildValidatedTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool enabled,
    required bool isRequired,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            enabled: enabled,
            validator: _isEditing ? validator : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
              filled: true,
              fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF1976D2),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
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
    required Function(String?) onChanged,
    String? Function(String?)? customValidator,
  }) {
    String? error;
    if (_isEditing) {
      if (customValidator != null) {
        error = customValidator(value);
      } else if (isRequired && (value == null || value.isEmpty)) {
        error = 'Please select $label';
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: enabled ? Colors.grey[50] : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: error != null ? Colors.red : Colors.grey.shade300,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Row(
                  children: [
                    Icon(icon, color: Colors.grey[500], size: 20),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        hint,
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
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
                        Icon(icon, color: Colors.grey[500], size: 20),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(item, overflow: TextOverflow.ellipsis),
                        ),
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
          if (error != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                error,
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGPAField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    bool required = true,
  }) {
    String? error;
    if (_isEditing && controller.text.isNotEmpty) {
      error = ProfileValidators.validateGPA(
        controller.text,
        required: required,
      );
    } else if (_isEditing && required && controller.text.isEmpty) {
      error = 'Required';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          textAlign: TextAlign.center,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: '0.0',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: error != null ? Colors.red : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: error != null ? Colors.red : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: error != null ? Colors.red : const Color(0xFF1976D2),
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 2),
          Text(error, style: const TextStyle(fontSize: 10, color: Colors.red)),
        ],
      ],
    );
  }

  void _handleSave() {
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Additional information saved successfully'),
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
