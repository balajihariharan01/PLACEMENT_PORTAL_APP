import 'package:flutter/material.dart';
import '../utils/validators.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_tabs.dart';
import '../widgets/profile/resume_tab.dart';
import '../widgets/profile/profile_info_tab.dart';
import '../widgets/profile/additional_info_tab.dart';
import '../widgets/profile/drive_summary_tab.dart';
import '../widgets/profile/account_settings_tab.dart';
import '../utils/logout_helper.dart';

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

  void _handleLogout() async {
    await LogoutHelper.logout(context);
  }

  void _handleProfileImageTap() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Change Profile Photo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  dense: true,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.blue[600],
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Take Photo',
                    style: TextStyle(fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Use your camera',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showSnackBar('Camera would open here');
                  },
                ),
                ListTile(
                  dense: true,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.photo_library,
                      color: Colors.green[600],
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Select from your photos',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showSnackBar('Gallery would open here');
                  },
                ),
                ListTile(
                  dense: true,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red[600],
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Use default avatar',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showSnackBar('Photo removed (UI only)');
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
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
