/// Dashboard Statistics Model
/// Represents summary statistics for the admin dashboard
class DashboardStats {
  final int totalDrives;
  final int activeDrives;
  final int completedDrives;
  final int upcomingDrives;
  final int totalStudents;
  final int placedStudents;
  final int totalCompanies;

  const DashboardStats({
    required this.totalDrives,
    required this.activeDrives,
    required this.completedDrives,
    required this.upcomingDrives,
    required this.totalStudents,
    required this.placedStudents,
    required this.totalCompanies,
  });

  /// Create from JSON (for API response)
  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalDrives: json['totalDrives'] ?? json['total_drives'] ?? 0,
      activeDrives: json['activeDrives'] ?? json['active_drives'] ?? 0,
      completedDrives: json['completedDrives'] ?? json['completed_drives'] ?? 0,
      upcomingDrives: json['upcomingDrives'] ?? json['upcoming_drives'] ?? 0,
      totalStudents: json['totalStudents'] ?? json['total_students'] ?? 0,
      placedStudents: json['placedStudents'] ?? json['placed_students'] ?? 0,
      totalCompanies: json['totalCompanies'] ?? json['total_companies'] ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalDrives': totalDrives,
      'activeDrives': activeDrives,
      'completedDrives': completedDrives,
      'upcomingDrives': upcomingDrives,
      'totalStudents': totalStudents,
      'placedStudents': placedStudents,
      'totalCompanies': totalCompanies,
    };
  }

  /// Empty stats for initial state
  factory DashboardStats.empty() {
    return const DashboardStats(
      totalDrives: 0,
      activeDrives: 0,
      completedDrives: 0,
      upcomingDrives: 0,
      totalStudents: 0,
      placedStudents: 0,
      totalCompanies: 0,
    );
  }
}
