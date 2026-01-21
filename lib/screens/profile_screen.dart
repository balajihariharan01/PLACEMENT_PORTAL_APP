import 'package:flutter/material.dart';
import '../utils/validators.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_tabs.dart';
import '../widgets/profile/resume_tab.dart';
import '../widgets/profile/profile_info_tab.dart';
import '../widgets/profile/additional_info_tab.dart';
import '../widgets/profile/drive_summary_tab.dart';
import '../widgets/profile/account_settings_tab.dart';

/// Profile Screen with State Management
/// Manages student name across all tabs
/// Status is admin-verified and READ-ONLY for students
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTabIndex = 0;

  // Student name - managed centrally and reflected across UI
  String _studentName = '';

  // Profile status - READ-ONLY, verified by admin
  // Students CANNOT change this - it's display only
  final ProfileStatus _profileStatus = ProfileStatus.pending;

  // Tab names
  final List<String> _tabs = [
    'Resume',
    'Profile Info',
    'Additional Info',
    'Drive Summary',
    'Account Settings',
  ];

  void _updateStudentName(String name) {
    setState(() {
      _studentName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FA),
      body: Column(
        children: [
          // Profile Header with Gradient
          // Name is dynamically reflected from Profile Info
          // Status is READ-ONLY - admin verified
          ProfileHeader(
            studentName: _studentName,
            status: _profileStatus,
            onLogoutTap: _handleLogout,
            onProfileImageTap: _handleProfileImageTap,
          ),

          // Profile Tabs
          ProfileTabs(
            tabs: _tabs,
            selectedIndex: _selectedTabIndex,
            onTabSelected: (index) {
              setState(() {
                _selectedTabIndex = index;
              });
            },
          ),

          // Tab Content
          Expanded(
            child: Container(color: Colors.white, child: _buildTabContent()),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        // Resume tab receives student name for dynamic filename
        return ResumeTab(studentName: _studentName);
      case 1:
        // Profile Info updates name across the app
        return ProfileInfoTab(
          onNameChanged: _updateStudentName,
          initialName: _studentName,
        );
      case 2:
        return const AdditionalInfoTab();
      case 3:
        return const DriveSummaryTab();
      case 4:
        return const AccountSettingsTab();
      default:
        return ResumeTab(studentName: _studentName);
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red[600]),
            const SizedBox(width: 8),
            const Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSnackBar('Logout confirmed (UI only)');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _handleProfileImageTap() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Change Profile Photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.camera_alt, color: Colors.blue[600]),
              ),
              title: const Text('Take Photo'),
              subtitle: const Text('Use your camera'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Camera would open here');
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.photo_library, color: Colors.green[600]),
              ),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select from your photos'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Gallery would open here');
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_outline, color: Colors.red[600]),
              ),
              title: const Text('Remove Photo'),
              subtitle: const Text('Use default avatar'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Photo removed (UI only)');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
