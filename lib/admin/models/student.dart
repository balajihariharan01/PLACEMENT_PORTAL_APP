/// Student Model
/// Represents a student entity in the placement system
///
/// TODO: Sync with backend schema
/// Backend endpoint: GET /api/admin/students
class Student {
  final String id;
  final String name;
  final String registerNumber;
  final String email;
  final String phone;
  final String department;
  final int year;
  final PlacementStatus placementStatus;
  final List<String> assignedDriveIds;
  final double cgpa;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Student({
    required this.id,
    required this.name,
    required this.registerNumber,
    required this.email,
    required this.phone,
    required this.department,
    required this.year,
    this.placementStatus = PlacementStatus.notPlaced,
    this.assignedDriveIds = const [],
    this.cgpa = 0.0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create empty student for form initialization
  factory Student.empty() {
    return Student(
      id: '',
      name: '',
      registerNumber: '',
      email: '',
      phone: '',
      department: '',
      year: 1,
      createdAt: DateTime.now(),
    );
  }

  /// Create student from JSON (for API integration)
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      registerNumber: json['registerNumber'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      department: json['department'] ?? '',
      year: json['year'] ?? 1,
      placementStatus: PlacementStatus.values.firstWhere(
        (s) => s.name == json['placementStatus'],
        orElse: () => PlacementStatus.notPlaced,
      ),
      assignedDriveIds: List<String>.from(json['assignedDriveIds'] ?? []),
      cgpa: (json['cgpa'] ?? 0.0).toDouble(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  /// Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'registerNumber': registerNumber,
      'email': email,
      'phone': phone,
      'department': department,
      'year': year,
      'placementStatus': placementStatus.name,
      'assignedDriveIds': assignedDriveIds,
      'cgpa': cgpa,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create copy with updated fields
  Student copyWith({
    String? id,
    String? name,
    String? registerNumber,
    String? email,
    String? phone,
    String? department,
    int? year,
    PlacementStatus? placementStatus,
    List<String>? assignedDriveIds,
    double? cgpa,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      registerNumber: registerNumber ?? this.registerNumber,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      year: year ?? this.year,
      placementStatus: placementStatus ?? this.placementStatus,
      assignedDriveIds: assignedDriveIds ?? this.assignedDriveIds,
      cgpa: cgpa ?? this.cgpa,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get initials for avatar
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Get year with suffix
  String get yearDisplay {
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

/// Placement Status Enum
enum PlacementStatus { notPlaced, placed, inProcess, notEligible }

/// Extension for PlacementStatus display
extension PlacementStatusExtension on PlacementStatus {
  String get displayName {
    switch (this) {
      case PlacementStatus.notPlaced:
        return 'Not Placed';
      case PlacementStatus.placed:
        return 'Placed';
      case PlacementStatus.inProcess:
        return 'In Process';
      case PlacementStatus.notEligible:
        return 'Not Eligible';
    }
  }

  String get shortName {
    switch (this) {
      case PlacementStatus.notPlaced:
        return 'Not Placed';
      case PlacementStatus.placed:
        return 'Placed';
      case PlacementStatus.inProcess:
        return 'In Process';
      case PlacementStatus.notEligible:
        return 'Ineligible';
    }
  }
}

/// Department constants
class Departments {
  static const List<String> all = [
    'Computer Science',
    'Information Technology',
    'Electronics & Communication',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Chemical Engineering',
    'Biotechnology',
  ];
}
