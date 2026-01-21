// Validation Utilities for Profile Page
// Contains all validation logic for form fields - Frontend only, no backend

class ProfileValidators {
  // ========== NAME VALIDATION ==========
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    // Only alphabets and spaces
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Only alphabets and spaces allowed';
    }
    return null;
  }

  // ========== EMAIL VALIDATION ==========
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    // Email regex pattern
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // ========== MOBILE NUMBER VALIDATION ==========
  static String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
      return 'Only numbers allowed';
    }
    if (value.trim().length != 10) {
      return 'Must be exactly 10 digits';
    }
    return null;
  }

  // ========== DATE OF BIRTH VALIDATION ==========
  static String? validateDOB(DateTime? value) {
    if (value == null) {
      return 'Date of birth is required';
    }
    if (value.isAfter(DateTime.now())) {
      return 'Cannot select future date';
    }
    // Check if age is reasonable (between 15 and 60)
    final age = DateTime.now().year - value.year;
    if (age < 15) {
      return 'Age must be at least 15 years';
    }
    if (age > 60) {
      return 'Please enter valid date of birth';
    }
    return null;
  }

  // ========== GENDER VALIDATION ==========
  static String? validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Gender is required';
    }
    return null;
  }

  // ========== PERCENTAGE VALIDATION (0-100) ==========
  static String? validatePercentage(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'This field is required' : null;
    }
    final numValue = double.tryParse(value.trim());
    if (numValue == null) {
      return 'Enter a valid number';
    }
    if (numValue < 0 || numValue > 100) {
      return 'Must be between 0 and 100';
    }
    return null;
  }

  // ========== CGPA VALIDATION (0-10) ==========
  static String? validateCGPA(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'This field is required' : null;
    }
    final numValue = double.tryParse(value.trim());
    if (numValue == null) {
      return 'Enter a valid number';
    }
    if (numValue < 0 || numValue > 10) {
      return 'Must be between 0 and 10';
    }
    return null;
  }

  // ========== GPA VALIDATION (0-10) ==========
  static String? validateGPA(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'GPA is required' : null;
    }
    final numValue = double.tryParse(value.trim());
    if (numValue == null) {
      return 'Enter valid GPA';
    }
    if (numValue < 0 || numValue > 10) {
      return 'GPA must be 0-10';
    }
    return null;
  }

  // ========== BACKLOGS VALIDATION ==========
  static String? validateBacklogs(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    final numValue = int.tryParse(value.trim());
    if (numValue == null) {
      return 'Enter a valid number';
    }
    if (numValue < 0) {
      return 'Cannot be negative';
    }
    return null;
  }

  // ========== YEAR OF PASSING VALIDATION ==========
  static String? validateYearOfPassing(String? value) {
    if (value == null || value.isEmpty) {
      return 'Year is required';
    }
    final year = int.tryParse(value);
    if (year == null) {
      return 'Enter valid year';
    }
    if (year > DateTime.now().year) {
      return 'Cannot be future year';
    }
    if (year < 1980) {
      return 'Enter valid year';
    }
    return null;
  }

  // ========== REQUIRED TEXT VALIDATION ==========
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // ========== PASSWORD VALIDATION ==========
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Minimum 6 characters required';
    }
    return null;
  }

  // ========== DROPDOWN VALIDATION ==========
  static String? validateDropdown(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please select $fieldName';
    }
    return null;
  }
}

/// Enum for Profile Approval Status
enum ProfileStatus {
  pending,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case ProfileStatus.pending:
        return 'Pending';
      case ProfileStatus.approved:
        return 'Approved';
      case ProfileStatus.rejected:
        return 'Rejected';
    }
  }

  String get description {
    switch (this) {
      case ProfileStatus.pending:
        return 'Awaiting admin verification';
      case ProfileStatus.approved:
        return 'Verified by Admin';
      case ProfileStatus.rejected:
        return 'Rejected by Admin';
    }
  }
}
