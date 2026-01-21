import '../models/student.dart';
import 'admin_auth_service.dart';

/// Mock Student Management Service
/// Simulates CRUD operations for students
///
/// TODO: Replace mock implementation with actual HTTP calls to backend
class StudentService {
  // Simulated network delay
  static const Duration _networkDelay = Duration(milliseconds: 500);

  // Mock student data storage
  static final List<Student> _mockStudents = [
    Student(
      id: 'student_001',
      name: 'Rahul Sharma',
      registerNumber: 'CS2021001',
      email: 'rahul.sharma@college.edu',
      phone: '+91 98765 43210',
      department: 'Computer Science',
      year: 4,
      placementStatus: PlacementStatus.placed,
      assignedDriveIds: ['drive_001', 'drive_002'],
      cgpa: 8.5,
      createdAt: DateTime(2021, 8, 1),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Student(
      id: 'student_002',
      name: 'Priya Patel',
      registerNumber: 'IT2021045',
      email: 'priya.patel@college.edu',
      phone: '+91 98765 43211',
      department: 'Information Technology',
      year: 4,
      placementStatus: PlacementStatus.inProcess,
      assignedDriveIds: ['drive_002', 'drive_005'],
      cgpa: 7.8,
      createdAt: DateTime(2021, 8, 1),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Student(
      id: 'student_003',
      name: 'Amit Kumar',
      registerNumber: 'CS2021023',
      email: 'amit.kumar@college.edu',
      phone: '+91 98765 43212',
      department: 'Computer Science',
      year: 4,
      placementStatus: PlacementStatus.notPlaced,
      assignedDriveIds: ['drive_001'],
      cgpa: 6.5,
      createdAt: DateTime(2021, 8, 1),
    ),
    Student(
      id: 'student_004',
      name: 'Sneha Gupta',
      registerNumber: 'ECE2021012',
      email: 'sneha.gupta@college.edu',
      phone: '+91 98765 43213',
      department: 'Electronics & Communication',
      year: 3,
      placementStatus: PlacementStatus.notPlaced,
      assignedDriveIds: [],
      cgpa: 8.9,
      createdAt: DateTime(2022, 8, 1),
    ),
    Student(
      id: 'student_005',
      name: 'Vikram Singh',
      registerNumber: 'ME2021078',
      email: 'vikram.singh@college.edu',
      phone: '+91 98765 43214',
      department: 'Mechanical Engineering',
      year: 4,
      placementStatus: PlacementStatus.placed,
      assignedDriveIds: ['drive_003'],
      cgpa: 7.2,
      createdAt: DateTime(2021, 8, 1),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Student(
      id: 'student_006',
      name: 'Ananya Reddy',
      registerNumber: 'CS2022015',
      email: 'ananya.reddy@college.edu',
      phone: '+91 98765 43215',
      department: 'Computer Science',
      year: 3,
      placementStatus: PlacementStatus.notEligible,
      assignedDriveIds: [],
      cgpa: 5.8,
      createdAt: DateTime(2022, 8, 1),
    ),
    Student(
      id: 'student_007',
      name: 'Karthik Nair',
      registerNumber: 'IT2021089',
      email: 'karthik.nair@college.edu',
      phone: '+91 98765 43216',
      department: 'Information Technology',
      year: 4,
      placementStatus: PlacementStatus.placed,
      assignedDriveIds: ['drive_002', 'drive_004'],
      cgpa: 8.1,
      createdAt: DateTime(2021, 8, 1),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Student(
      id: 'student_008',
      name: 'Deepika Iyer',
      registerNumber: 'CS2022034',
      email: 'deepika.iyer@college.edu',
      phone: '+91 98765 43217',
      department: 'Computer Science',
      year: 3,
      placementStatus: PlacementStatus.inProcess,
      assignedDriveIds: ['drive_005'],
      cgpa: 9.2,
      createdAt: DateTime(2022, 8, 1),
    ),
  ];

  /// Get all students with optional filtering
  ///
  /// TODO: Integrate with actual backend API
  /// Endpoint: GET /api/admin/students
  /// Query params: department, year, status, search, page, limit
  /// Headers: Authorization: Bearer `<token>`
  Future<ApiResponse<List<Student>>> getAllStudents({
    String? department,
    int? year,
    PlacementStatus? status,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(_networkDelay);

    var students = List<Student>.from(_mockStudents);

    // Filter by department
    if (department != null && department.isNotEmpty) {
      students = students.where((s) => s.department == department).toList();
    }

    // Filter by year
    if (year != null) {
      students = students.where((s) => s.year == year).toList();
    }

    // Filter by status
    if (status != null) {
      students = students.where((s) => s.placementStatus == status).toList();
    }

    // Filter by search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      students = students.where((s) {
        return s.name.toLowerCase().contains(query) ||
            s.registerNumber.toLowerCase().contains(query) ||
            s.email.toLowerCase().contains(query);
      }).toList();
    }

    // Sort by name
    students.sort((a, b) => a.name.compareTo(b.name));

    return ApiResponse.success(students);
  }

  /// Get student by ID
  ///
  /// TODO: Integrate with actual backend API
  /// Endpoint: GET /api/admin/students/:id
  /// Headers: Authorization: Bearer `<token>`
  Future<ApiResponse<Student>> getStudentById(String id) async {
    await Future.delayed(_networkDelay);

    final student = _mockStudents.firstWhere(
      (s) => s.id == id,
      orElse: () => Student.empty(),
    );

    if (student.id.isEmpty) {
      return ApiResponse.error('Student not found', errorCode: 'NOT_FOUND');
    }

    return ApiResponse.success(student);
  }

  /// Create new student
  ///
  /// TODO: Integrate with actual backend API
  /// Endpoint: POST /api/admin/students
  /// Body: Student JSON
  /// Headers: Authorization: Bearer `<token>`
  Future<ApiResponse<Student>> createStudent(Student student) async {
    await Future.delayed(_networkDelay);

    // Validate required fields
    if (student.name.isEmpty) {
      return ApiResponse.error('Student name is required');
    }
    if (student.registerNumber.isEmpty) {
      return ApiResponse.error('Register number is required');
    }
    if (student.email.isEmpty) {
      return ApiResponse.error('Email is required');
    }

    // Check for duplicate register number
    final exists = _mockStudents.any(
      (s) =>
          s.registerNumber.toLowerCase() ==
          student.registerNumber.toLowerCase(),
    );
    if (exists) {
      return ApiResponse.error('Register number already exists');
    }

    // Generate new ID (mock)
    final newStudent = student.copyWith(
      id: 'student_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _mockStudents.insert(0, newStudent);

    return ApiResponse.success(
      newStudent,
      message: 'Student added successfully',
    );
  }

  /// Update existing student
  ///
  /// TODO: Integrate with actual backend API
  /// Endpoint: PUT /api/admin/students/:id
  /// Body: Student JSON
  /// Headers: Authorization: Bearer `<token>`
  Future<ApiResponse<Student>> updateStudent(Student student) async {
    await Future.delayed(_networkDelay);

    final index = _mockStudents.indexWhere((s) => s.id == student.id);
    if (index == -1) {
      return ApiResponse.error('Student not found', errorCode: 'NOT_FOUND');
    }

    final updatedStudent = student.copyWith(updatedAt: DateTime.now());
    _mockStudents[index] = updatedStudent;

    return ApiResponse.success(
      updatedStudent,
      message: 'Student updated successfully',
    );
  }

  /// Delete student
  ///
  /// TODO: Integrate with actual backend API
  /// Endpoint: DELETE /api/admin/students/:id
  /// Headers: Authorization: Bearer `<token>`
  Future<ApiResponse<void>> deleteStudent(String id) async {
    await Future.delayed(_networkDelay);

    final index = _mockStudents.indexWhere((s) => s.id == id);
    if (index == -1) {
      return ApiResponse.error('Student not found', errorCode: 'NOT_FOUND');
    }

    _mockStudents.removeAt(index);

    return ApiResponse.success(null, message: 'Student deleted successfully');
  }

  /// Get student statistics
  ///
  /// TODO: Integrate with actual backend API
  /// Endpoint: GET /api/admin/students/stats
  /// Headers: Authorization: Bearer `<token>`
  Future<ApiResponse<Map<String, int>>> getStudentStats() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final stats = {
      'total': _mockStudents.length,
      'placed': _mockStudents
          .where((s) => s.placementStatus == PlacementStatus.placed)
          .length,
      'notPlaced': _mockStudents
          .where((s) => s.placementStatus == PlacementStatus.notPlaced)
          .length,
      'inProcess': _mockStudents
          .where((s) => s.placementStatus == PlacementStatus.inProcess)
          .length,
      'notEligible': _mockStudents
          .where((s) => s.placementStatus == PlacementStatus.notEligible)
          .length,
    };

    return ApiResponse.success(stats);
  }

  /// Assign student to drive
  ///
  /// TODO: Integrate with actual backend API
  /// Endpoint: POST /api/admin/students/:id/assign-drive
  /// Body: { driveId: string }
  /// Headers: Authorization: Bearer `<token>`
  Future<ApiResponse<Student>> assignToDrive(
    String studentId,
    String driveId,
  ) async {
    await Future.delayed(_networkDelay);

    final index = _mockStudents.indexWhere((s) => s.id == studentId);
    if (index == -1) {
      return ApiResponse.error('Student not found', errorCode: 'NOT_FOUND');
    }

    final student = _mockStudents[index];
    if (student.assignedDriveIds.contains(driveId)) {
      return ApiResponse.error('Student already assigned to this drive');
    }

    final updatedStudent = student.copyWith(
      assignedDriveIds: [...student.assignedDriveIds, driveId],
      updatedAt: DateTime.now(),
    );
    _mockStudents[index] = updatedStudent;

    return ApiResponse.success(
      updatedStudent,
      message: 'Student assigned to drive',
    );
  }
}
