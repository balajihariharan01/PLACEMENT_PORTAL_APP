/// Drive Status Enum
enum DriveStatus { active, closed, upcoming, onHold }

/// Extension for DriveStatus
extension DriveStatusExtension on DriveStatus {
  String get displayName {
    switch (this) {
      case DriveStatus.active:
        return 'Active';
      case DriveStatus.closed:
        return 'Closed';
      case DriveStatus.upcoming:
        return 'Upcoming';
      case DriveStatus.onHold:
        return 'On Hold';
    }
  }

  static DriveStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return DriveStatus.active;
      case 'closed':
        return DriveStatus.closed;
      case 'upcoming':
        return DriveStatus.upcoming;
      case 'onhold':
      case 'on_hold':
        return DriveStatus.onHold;
      default:
        return DriveStatus.active;
    }
  }
}

/// Drive Model
/// Represents a placement drive in the system
class Drive {
  final String id;
  final String driveName;
  final String companyName;
  final DateTime dateTime;
  final String location;
  final String eligibilityCriteria;
  final String jobRole;
  final String description;
  final DriveStatus status;
  final String? companyLogo;
  final String? salaryPackage;
  final int? registeredCount;
  final int? placedCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Drive({
    required this.id,
    required this.driveName,
    required this.companyName,
    required this.dateTime,
    required this.location,
    required this.eligibilityCriteria,
    required this.jobRole,
    required this.description,
    required this.status,
    this.companyLogo,
    this.salaryPackage,
    this.registeredCount,
    this.placedCount,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON (for API response)
  factory Drive.fromJson(Map<String, dynamic> json) {
    return Drive(
      id: json['id'] ?? '',
      driveName: json['driveName'] ?? json['drive_name'] ?? '',
      companyName: json['companyName'] ?? json['company_name'] ?? '',
      dateTime:
          DateTime.tryParse(json['dateTime'] ?? json['date_time'] ?? '') ??
          DateTime.now(),
      location: json['location'] ?? '',
      eligibilityCriteria:
          json['eligibilityCriteria'] ?? json['eligibility_criteria'] ?? '',
      jobRole: json['jobRole'] ?? json['job_role'] ?? '',
      description: json['description'] ?? '',
      status: DriveStatusExtension.fromString(json['status'] ?? 'active'),
      companyLogo: json['companyLogo'] ?? json['company_logo'],
      salaryPackage: json['salaryPackage'] ?? json['salary_package'],
      registeredCount: json['registeredCount'] ?? json['registered_count'],
      placedCount: json['placedCount'] ?? json['placed_count'],
      createdAt:
          DateTime.tryParse(json['createdAt'] ?? json['created_at'] ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] ?? json['updated_at'] ?? '') ??
          DateTime.now(),
    );
  }

  /// Convert to JSON (for API request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driveName': driveName,
      'companyName': companyName,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'eligibilityCriteria': eligibilityCriteria,
      'jobRole': jobRole,
      'description': description,
      'status': status.name,
      'companyLogo': companyLogo,
      'salaryPackage': salaryPackage,
      'registeredCount': registeredCount,
      'placedCount': placedCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with modifications
  Drive copyWith({
    String? id,
    String? driveName,
    String? companyName,
    DateTime? dateTime,
    String? location,
    String? eligibilityCriteria,
    String? jobRole,
    String? description,
    DriveStatus? status,
    String? companyLogo,
    String? salaryPackage,
    int? registeredCount,
    int? placedCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Drive(
      id: id ?? this.id,
      driveName: driveName ?? this.driveName,
      companyName: companyName ?? this.companyName,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      eligibilityCriteria: eligibilityCriteria ?? this.eligibilityCriteria,
      jobRole: jobRole ?? this.jobRole,
      description: description ?? this.description,
      status: status ?? this.status,
      companyLogo: companyLogo ?? this.companyLogo,
      salaryPackage: salaryPackage ?? this.salaryPackage,
      registeredCount: registeredCount ?? this.registeredCount,
      placedCount: placedCount ?? this.placedCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create an empty drive for form initialization
  factory Drive.empty() {
    return Drive(
      id: '',
      driveName: '',
      companyName: '',
      dateTime: DateTime.now().add(const Duration(days: 7)),
      location: '',
      eligibilityCriteria: '',
      jobRole: '',
      description: '',
      status: DriveStatus.upcoming,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
