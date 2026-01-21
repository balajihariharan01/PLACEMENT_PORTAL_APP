import '../models/dashboard_stats.dart';
import 'admin_auth_service.dart';

/// Mock Dashboard Service
/// Provides statistics and summary data for admin dashboard
/// TODO: Replace mock implementation with actual HTTP calls to backend
class DashboardService {
  // Simulated network delay
  static const Duration _networkDelay = Duration(milliseconds: 500);

  /// Get dashboard statistics
  ///
  /// TODO: Integrate with actual backend API
  /// Endpoint: GET /api/admin/dashboard/stats
  /// Headers: Authorization: Bearer `<token>`
  Future<ApiResponse<DashboardStats>> getDashboardStats() async {
    await Future.delayed(_networkDelay);

    // Mock statistics
    const stats = DashboardStats(
      totalDrives: 28,
      activeDrives: 8,
      completedDrives: 15,
      upcomingDrives: 5,
      totalStudents: 1250,
      placedStudents: 485,
      totalCompanies: 42,
    );

    return ApiResponse.success(stats);
  }

  /// Get recent activities
  ///
  /// TODO: Integrate with actual backend API
  /// Endpoint: GET /api/admin/dashboard/activities
  /// Headers: Authorization: Bearer `<token>`
  Future<ApiResponse<List<Map<String, dynamic>>>> getRecentActivities() async {
    await Future.delayed(_networkDelay);

    final activities = [
      {
        'id': '1',
        'type': 'drive_created',
        'title': 'New drive created',
        'description': 'TCS Campus Recruitment 2026',
        'timestamp': DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
      },
      {
        'id': '2',
        'type': 'student_placed',
        'title': '15 students placed',
        'description': 'In Infosys Off-Campus Drive',
        'timestamp': DateTime.now()
            .subtract(const Duration(hours: 5))
            .toIso8601String(),
      },
      {
        'id': '3',
        'type': 'drive_status',
        'title': 'Drive status updated',
        'description': 'Wipro Elite NLTH marked as completed',
        'timestamp': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
      },
      {
        'id': '4',
        'type': 'new_company',
        'title': 'New company registered',
        'description': 'Google India Pvt Ltd',
        'timestamp': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
      },
    ];

    return ApiResponse.success(activities);
  }

  /// Get quick action counts
  ///
  /// TODO: Integrate with actual backend API
  /// Endpoint: GET /api/admin/dashboard/pending-actions
  /// Headers: Authorization: Bearer `<token>`
  Future<ApiResponse<Map<String, int>>> getPendingActions() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final pendingActions = {
      'pendingApprovals': 12,
      'newApplications': 45,
      'unreadMessages': 8,
      'scheduledDrives': 3,
    };

    return ApiResponse.success(pendingActions);
  }
}
