import '../models/drive.dart';
import 'admin_auth_service.dart';

/// Mock Drive Management Service
/// Simulates CRUD operations for placement drives
/// TODO: Replace mock implementation with actual HTTP calls to backend
class DriveService {
  // Simulated network delay
  static const Duration _networkDelay = Duration(milliseconds: 600);

  // Mock drive data storage
  static final List<Drive> _mockDrives = [
    Drive(
      id: 'drive_001',
      driveName: 'TCS Campus Recruitment 2026',
      companyName: 'Tata Consultancy Services',
      dateTime: DateTime(2026, 2, 15, 10, 0),
      location: 'Main Auditorium, Block A',
      eligibilityCriteria: 'CGPA >= 7.0, No active backlogs',
      jobRole: 'Software Developer',
      description:
          'TCS is hiring fresh graduates for Software Developer positions. '
          'The selection process includes aptitude test, technical interview, and HR interview.',
      status: DriveStatus.upcoming,
      salaryPackage: '₹ 7 LPA',
      registeredCount: 245,
      placedCount: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Drive(
      id: 'drive_002',
      driveName: 'Infosys Off-Campus Drive',
      companyName: 'Infosys Limited',
      dateTime: DateTime(2026, 1, 25, 9, 30),
      location: 'Seminar Hall, Block B',
      eligibilityCriteria: 'CGPA >= 6.5, All branches eligible',
      jobRole: 'Systems Engineer',
      description:
          'Infosys is conducting an off-campus drive for Systems Engineer role. '
          'Candidates will go through InfyTQ assessment and interviews.',
      status: DriveStatus.active,
      salaryPackage: '₹ 3.6 LPA',
      registeredCount: 380,
      placedCount: 45,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Drive(
      id: 'drive_003',
      driveName: 'Wipro Elite NLTH 2026',
      companyName: 'Wipro Technologies',
      dateTime: DateTime(2026, 1, 10, 11, 0),
      location: 'Computer Lab, Block C',
      eligibilityCriteria: 'CGPA >= 6.0, B.Tech/B.E./MCA eligible',
      jobRole: 'Project Engineer',
      description:
          'Wipro Elite NLTH program for exceptional engineering graduates. '
          'Selection includes online test and technical + HR rounds.',
      status: DriveStatus.closed,
      salaryPackage: '₹ 3.5 LPA',
      registeredCount: 290,
      placedCount: 78,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Drive(
      id: 'drive_004',
      driveName: 'Cognizant GenC 2026',
      companyName: 'Cognizant Technology Solutions',
      dateTime: DateTime(2026, 3, 5, 10, 0),
      location: 'Placement Cell, Admin Block',
      eligibilityCriteria: 'CGPA >= 6.5, CS/IT/ECE branches',
      jobRole: 'Programmer Analyst',
      description:
          'Cognizant GenC program for 2026 batch graduates. '
          'Includes online assessment, technical interview, and HR discussion.',
      status: DriveStatus.upcoming,
      salaryPackage: '₹ 4 LPA',
      registeredCount: 0,
      placedCount: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
    ),
    Drive(
      id: 'drive_005',
      driveName: 'Microsoft SDE Internship',
      companyName: 'Microsoft India',
      dateTime: DateTime(2026, 2, 28, 9, 0),
      location: 'Video Conference',
      eligibilityCriteria: 'CGPA >= 8.0, Pre-final year students',
      jobRole: 'Software Development Engineer Intern',
      description:
          'Microsoft is hiring SDE interns for summer 2026. '
          'Selection involves coding rounds, system design, and behavioral interview.',
      status: DriveStatus.active,
      salaryPackage: '₹ 80,000/month',
      registeredCount: 120,
      placedCount: 8,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now(),
    ),
    Drive(
      id: 'drive_006',
      driveName: 'Accenture Campus Hiring',
      companyName: 'Accenture',
      dateTime: DateTime(2025, 12, 15, 10, 0),
      location: 'Main Auditorium',
      eligibilityCriteria: 'CGPA >= 6.0, All branches',
      jobRole: 'Associate Software Engineer',
      description: 'Accenture campus drive completed successfully.',
      status: DriveStatus.closed,
      salaryPackage: '₹ 4.5 LPA',
      registeredCount: 450,
      placedCount: 120,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  /// Get all drives with optional filtering
  ///
  /// TODO: Integrate with actual backend API
  /// Endpoint: GET /api/admin/drives
  /// Query params: status, page, limit, search
  /// Headers: Authorization: Bearer <token>
  Future<ApiResponse<List<Drive>>> getAllDrives({
    DriveStatus? status,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(_networkDelay);

    var drives = List<Drive>.from(_mockDrives);

    // Filter by status
    if (status != null) {
      drives = drives.where((d) => d.status == status).toList();
    }

    // Filter by search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      drives = drives.where((d) {
        return d.driveName.toLowerCase().contains(query) ||
            d.companyName.toLowerCase().contains(query) ||
            d.jobRole.toLowerCase().contains(query);
      }).toList();
    }

    // Sort by date (most recent first)
    drives.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return ApiResponse.success(drives);
  }

  /// Get drive by ID
  ///
  /// TODO: Integrate with actual backend API
  /// Endpoint: GET /api/admin/drives/:id
  /// Headers: Authorization: Bearer <token>
  Future<ApiResponse<Drive>> getDriveById(String id) async {
    await Future.delayed(_networkDelay);

    final drive = _mockDrives.firstWhere(
      (d) => d.id == id,
      orElse: () => Drive.empty(),
    );

    if (drive.id.isEmpty) {
      return ApiResponse.error('Drive not found', errorCode: 'NOT_FOUND');
    }

    return ApiResponse.success(drive);
  }

  /// Create new drive
  ///
  /// TODO: Integrate with actual backend API
  /// Endpoint: POST /api/admin/drives
  /// Body: Drive JSON
  /// Headers: Authorization: Bearer <token>
  Future<ApiResponse<Drive>> createDrive(Drive drive) async {
    await Future.delayed(_networkDelay);

    // Validate required fields
    if (drive.driveName.isEmpty) {
      return ApiResponse.error('Drive name is required');
    }
    if (drive.companyName.isEmpty) {
      return ApiResponse.error('Company name is required');
    }

    // Generate new ID (mock)
    final newDrive = drive.copyWith(
      id: 'drive_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _mockDrives.insert(0, newDrive);

    return ApiResponse.success(newDrive, message: 'Drive created successfully');
  }

  /// Update existing drive
  ///
  /// TODO: Integrate with actual backend API
  /// Endpoint: PUT /api/admin/drives/:id
  /// Body: Drive JSON
  /// Headers: Authorization: Bearer <token>
  Future<ApiResponse<Drive>> updateDrive(Drive drive) async {
    await Future.delayed(_networkDelay);

    final index = _mockDrives.indexWhere((d) => d.id == drive.id);
    if (index == -1) {
      return ApiResponse.error('Drive not found', errorCode: 'NOT_FOUND');
    }

    final updatedDrive = drive.copyWith(updatedAt: DateTime.now());
    _mockDrives[index] = updatedDrive;

    return ApiResponse.success(
      updatedDrive,
      message: 'Drive updated successfully',
    );
  }

  /// Delete drive
  ///
  /// TODO: Integrate with actual backend API
  /// Endpoint: DELETE /api/admin/drives/:id
  /// Headers: Authorization: Bearer <token>
  Future<ApiResponse<void>> deleteDrive(String id) async {
    await Future.delayed(_networkDelay);

    final index = _mockDrives.indexWhere((d) => d.id == id);
    if (index == -1) {
      return ApiResponse.error('Drive not found', errorCode: 'NOT_FOUND');
    }

    _mockDrives.removeAt(index);

    return ApiResponse.success(null, message: 'Drive deleted successfully');
  }

  /// Update drive status
  ///
  /// TODO: Integrate with actual backend API
  /// Endpoint: PATCH /api/admin/drives/:id/status
  /// Body: { status: string }
  /// Headers: Authorization: Bearer <token>
  Future<ApiResponse<Drive>> updateDriveStatus(
    String id,
    DriveStatus status,
  ) async {
    await Future.delayed(_networkDelay);

    final index = _mockDrives.indexWhere((d) => d.id == id);
    if (index == -1) {
      return ApiResponse.error('Drive not found', errorCode: 'NOT_FOUND');
    }

    final updatedDrive = _mockDrives[index].copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    _mockDrives[index] = updatedDrive;

    return ApiResponse.success(
      updatedDrive,
      message: 'Status updated successfully',
    );
  }

  /// Get drive statistics
  ///
  /// TODO: Integrate with actual backend API
  /// Endpoint: GET /api/admin/drives/stats
  /// Headers: Authorization: Bearer <token>
  Future<ApiResponse<Map<String, int>>> getDriveStats() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final stats = {
      'total': _mockDrives.length,
      'active': _mockDrives.where((d) => d.status == DriveStatus.active).length,
      'closed': _mockDrives.where((d) => d.status == DriveStatus.closed).length,
      'upcoming': _mockDrives
          .where((d) => d.status == DriveStatus.upcoming)
          .length,
      'onHold': _mockDrives.where((d) => d.status == DriveStatus.onHold).length,
    };

    return ApiResponse.success(stats);
  }
}
