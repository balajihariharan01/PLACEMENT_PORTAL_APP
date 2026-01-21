import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../models/dashboard_stats.dart';
import '../services/dashboard_service.dart';
import '../../widgets/app_logo.dart';
import '../../utils/logout_helper.dart';
import 'drive_management_screen.dart';
import 'student_management_screen.dart';
import 'calendar_screen.dart';

/// Admin Dashboard Screen - Mobile-First Native Design
/// 100% optimized for touch-based mobile interfaces
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _dashboardService = DashboardService();
  int _currentIndex = 0;
  DashboardStats? _stats;
  bool _isLoading = true;
  DateTime? _lastBackPress;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final statsResponse = await _dashboardService.getDashboardStats();
      if (!mounted) return;
      setState(() {
        _stats = statsResponse.data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _handleBackPress() async {
    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Press back again to exit'),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _handleBackPress();
        if (shouldPop && mounted) SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: SafeArea(
          child: Column(
            children: [
              _buildCompactAppBar(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildCompactAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo
          AppLogo.adaptive(context: context, height: 28),
          const SizedBox(width: 10),
          // Title
          const Expanded(
            child: Text(
              'Command Center',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          // Notification
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            icon: Badge(
              smallSize: 6,
              child: Icon(
                Icons.notifications_none_rounded,
                color: Colors.grey[600],
                size: 22,
              ),
            ),
            onPressed: () {},
          ),
          // Profile
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            icon: CircleAvatar(
              radius: 14,
              backgroundColor: AppTheme.primaryBlue,
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
            offset: const Offset(0, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'logout') LogoutHelper.logout(context);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Text('Profile')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const StudentManagementScreen();
      case 2:
        return const DriveManagementScreen();
      case 3:
        return const CalendarScreen();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: AppTheme.primaryBlue,
      child: _isLoading ? _buildLoadingState() : _buildMainContent(),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(
        4,
        (i) => Container(
          height: 80,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.all(16),
      children: [
        _buildWelcomeBanner(),
        const SizedBox(height: 20),
        _buildKPIGrid(),
        const SizedBox(height: 24),
        _buildQuickActionsRow(),
        const SizedBox(height: 24),
        _buildDriveActivitySection(),
        const SizedBox(height: 80), // Bottom padding for nav
      ],
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF007DC5), Color(0xFF00A3E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.waving_hand, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome, Admin!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Today\'s placement overview',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                '1,240',
                'Students',
                Icons.people_alt_rounded,
                AppTheme.primaryBlue,
                '+12%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                '${_stats?.activeDrives ?? 8}',
                'Active Drives',
                Icons.campaign_rounded,
                AppTheme.accentColor,
                'Live',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                '78%',
                'Placed',
                Icons.check_circle_rounded,
                Colors.orange,
                '+5.4%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                '₹6.5L',
                'Avg. CTC',
                Icons.payments_rounded,
                Colors.purple,
                'Good',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKPICard(
    String value,
    String label,
    IconData icon,
    Color color,
    String trend,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trend,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickAction(
            Icons.add_circle_outline,
            'Add Drive',
            AppTheme.primaryBlue,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const DriveManagementScreen(openAddForm: true),
                ),
              );
            },
          ),
          _buildQuickAction(
            Icons.person_add_alt_1_outlined,
            'Add Student',
            AppTheme.accentColor,
            () {
              setState(() => _currentIndex = 1);
            },
          ),
          _buildQuickAction(
            Icons.calendar_month_outlined,
            'Calendar',
            Colors.orange,
            () {
              setState(() => _currentIndex = 3);
            },
          ),
          _buildQuickAction(
            Icons.analytics_outlined,
            'Reports',
            Colors.purple,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriveActivitySection() {
    final activities = [
      {
        'company': 'TCS',
        'drive': 'Campus Drive 2026',
        'action': 'stage_updated',
        'details': 'Technical Round',
        'students': 42,
        'time': '2h ago',
      },
      {
        'company': 'Infosys',
        'drive': 'Fresher Hiring',
        'action': 'shortlisted',
        'details': 'Written Test',
        'students': 128,
        'time': '5h ago',
      },
      {
        'company': 'Wipro',
        'drive': 'Elite Program',
        'action': 'created',
        'details': 'Registration Open',
        'students': 0,
        'time': '8h ago',
      },
      {
        'company': 'Cognizant',
        'drive': 'GenC Next',
        'action': 'placed',
        'details': 'Completed',
        'students': 23,
        'time': '1d ago',
      },
      {
        'company': 'Accenture',
        'drive': 'ASE Hiring',
        'action': 'closed',
        'details': 'Interview Phase',
        'students': 85,
        'time': '1d ago',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.campaign_rounded,
                    color: AppTheme.primaryBlue,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Drive Activity',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => setState(() => _currentIndex = 2),
              child: Text(
                'See All',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...activities.map((a) => _buildDriveCard(a)),
      ],
    );
  }

  Widget _buildDriveCard(Map<String, dynamic> activity) {
    final action = activity['action'] as String;
    IconData icon;
    Color color;
    String label;

    switch (action) {
      case 'created':
        icon = Icons.add_circle_rounded;
        color = AppTheme.primaryBlue;
        label = 'New Drive Created';
        break;
      case 'stage_updated':
        icon = Icons.arrow_forward_rounded;
        color = AppTheme.accentColor;
        label = 'Stage → ${activity['details']}';
        break;
      case 'shortlisted':
        icon = Icons.how_to_reg_rounded;
        color = AppTheme.warningOrange;
        label = 'Students Shortlisted';
        break;
      case 'placed':
        icon = Icons.celebration_rounded;
        color = AppTheme.successGreen;
        label = 'Students Placed';
        break;
      case 'closed':
        icon = Icons.lock_clock_rounded;
        color = Colors.purple;
        label = 'Registration Closed';
        break;
      default:
        icon = Icons.update_rounded;
        color = Colors.grey;
        label = 'Updated';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _currentIndex = 2),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${activity['company']} – ${activity['drive']}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if ((activity['students'] as int) > 0) ...[
                            Icon(
                              Icons.people_alt_rounded,
                              size: 10,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${activity['students']} students',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              ' · ',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ],
                          Icon(
                            Icons.access_time_rounded,
                            size: 10,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${activity['time']}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[300],
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.dashboard_rounded, 'Dashboard'),
              _buildNavItem(1, Icons.school_rounded, 'Students'),
              _buildNavItem(2, Icons.campaign_rounded, 'Drives'),
              _buildNavItem(3, Icons.calendar_month_rounded, 'Calendar'),
              _buildNavItem(4, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryBlue : Colors.grey,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.primaryBlue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
