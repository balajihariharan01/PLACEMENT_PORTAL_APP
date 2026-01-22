import '../models/drive_model.dart';

class DriveService {
  // Mock Data
  static final List<Drive> _mockDrives = [
    Drive(
      id: '1',
      companyName: 'EPAM',
      title: 'EPAM Off Campus Drive',
      description: 'Software Engineer role for fresh graduates.',
      logoUrl: 'assets/images/companies/epam.png', // Placeholder
      salary: '8L PA',
      stipend: '20k per month',
      location: 'Hyderabad',
      domain: 'IT',
      jobType: 'Full-Time',
      isOnCampus: false,
      applyDate: DateTime(2026, 1, 21),
      status: DriveStatus.applied,
      aboutCompany:
          'EPAM Systems is a leading global provider of digital platform engineering and development services.',
    ),
    Drive(
      id: '2',
      companyName: 'AmZetta Technologies',
      title: 'AmZetta On Campus drive',
      description: 'Hiring for Software Developer Interns.',
      logoUrl: 'assets/images/companies/amzetta.png', // Placeholder
      salary: '4L PA',
      stipend: '15k per month',
      location: 'Chennai',
      domain: 'IT',
      jobType: 'Internship and Full-Time',
      isOnCampus: true,
      applyDate: DateTime(2026, 1, 21, 10, 0),
      status: DriveStatus.applied,
      aboutCompany:
          'AmZetta, headquartered in Georgia, USA and having its Corporate Offices in USA, India and Taiwan...\n\nAmZetta Technologies was established in April 2019 as a spinoff from American Megatrends (better known as AMI).',
      rounds: [
        DriveRound(
          name: 'Round 1',
          description: 'Online Screening/Aptitude Test',
          startDate: DateTime(2025, 5, 14, 0, 0),
          endDate: DateTime(2025, 5, 14, 12, 0),
          mode: 'Online',
          venue: 'Not mentioned',
        ),
        DriveRound(
          name: 'Round 2',
          description: 'Technical Interview',
          startDate: DateTime(2025, 5, 14, 12, 0),
          endDate: DateTime(2025, 5, 14, 12, 0),
          mode: 'Offline',
          venue: 'Not mentioned',
        ),
      ],
    ),
    Drive(
      id: '3',
      companyName: 'Besant Technologies',
      title: 'Besant Technologies',
      description: 'Placement drive for multiple roles.',
      logoUrl: 'assets/images/companies/besant.png',
      salary: '5L PA',
      stipend: 'Not Applicable',
      location: 'Chennai',
      domain: 'IT Services',
      jobType: 'Full-Time',
      isOnCampus: true,
      applyDate: DateTime(2026, 1, 22),
      status: DriveStatus.eligible, // Show Opt-In/Opt-Out
    ),
    Drive(
      id: '4',
      companyName: 'Webberax Solutions',
      title: 'Webberax Solutions Private Limited',
      description: 'Web Development roles.',
      logoUrl: 'assets/images/companies/webberax.png',
      salary: '3L PA',
      stipend: '10k per month',
      location: 'Chennai',
      domain: 'IT',
      jobType: 'Full-Time',
      isOnCampus: false,
      applyDate: DateTime(2025, 11, 11),
      status: DriveStatus.applied,
    ),
    Drive(
      id: '5',
      companyName: 'Levarus Solutions',
      title: 'Levarus Solutions',
      description: 'Core engineering roles.',
      logoUrl: 'assets/images/companies/levarus.png',
      salary: '4L PA',
      stipend: '12k per month',
      location: 'Bangalore',
      domain: 'Core',
      jobType: 'Full-Time',
      isOnCampus: true,
      applyDate: DateTime(2025, 9, 12),
      status: DriveStatus.applied,
    ),
    Drive(
      id: '6',
      companyName: 'Propel Technology',
      title: 'Propel Inc Oncampus drive',
      description: 'Software Engineer Trainee.',
      logoUrl: 'assets/images/companies/propel.png',
      salary: '5L PA',
      stipend: '18k per month',
      location: 'Coimbatore',
      domain: 'IT',
      jobType: 'Full-Time',
      isOnCampus: true,
      applyDate: DateTime(2025, 9, 12),
      status: DriveStatus.applied,
    ),
    Drive(
      id: '7',
      companyName: 'Tap Academy',
      title: 'Tap EdTech Private Limited',
      description: 'Business Development Executive.',
      logoUrl: 'assets/images/companies/tap.png',
      salary: '5L PA',
      stipend: '20k per month',
      location: 'Bangalore',
      domain: 'EdTech',
      jobType: 'Full-Time',
      isOnCampus: false,
      applyDate: DateTime(2025, 8, 30),
      status: DriveStatus.optedOut,
    ),
  ];

  Future<List<Drive>> getDrives() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockDrives;
  }

  Future<void> optIn(String driveId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockDrives.indexWhere((d) => d.id == driveId);
    if (index != -1) {
      // In a real app we would update the server
      // Here we just update the local mock object (requires a mutable model or a copy)
      // Since our model is immutable, we can't 'change' it in place easily without re-creating logic
      // For now, let's just pretend default success
    }
  }

  Future<void> optOut(String driveId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
