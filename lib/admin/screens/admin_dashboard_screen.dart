import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:flutter/services.dart';
import '../models/dashboard_stats.dart';
import '../services/admin_auth_service.dart';
import '../services/dashboard_service.dart';
import '../security/admin_route_guard.dart';
import '../../utils/logout_helper.dart';
import '../widgets/stats_card.dart';
import '../widgets/state_widgets.dart';
import 'drive_management_screen.dart';
import 'student_management_screen.dart';
import 'calendar_screen.dart';

import '../../widgets/branded_header.dart';

/// Admin Dashboard Screen
/// SECURITY: Protected by AdminRouteGuard - requires valid admin session
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  final _dashboardService = DashboardService();
  final _authService = AdminAuthService();

  DashboardStats? _stats;
  List<Map<String, dynamic>>? _activities;
  bool _isLoading = true;
  String? _error;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  DateTime? _lastBackPressTime;

  Future<bool> _handleBackPress() async {
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Press back again to exit'),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: AppTheme.smallRadius),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final statsResponse = await _dashboardService.getDashboardStats();
      final activitiesResponse = await _dashboardService.getRecentActivities();

      if (!mounted) return;

      if (statsResponse.success) {
        setState(() {
          _stats = statsResponse.data;
          _activities = activitiesResponse.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = statsResponse.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load dashboard data';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    await LogoutHelper.logout(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldLight,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final shouldPop = await _handleBackPress();
          if (shouldPop && mounted) {
            SystemNavigator.pop();
          }
        },
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadDashboardData,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.white,
                    flexibleSpace: FlexibleSpaceBar(
                      background: BrandedHeader(
                        title: 'Admin Console',
                        subtitle: 'Centralized management & analytics',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.notifications_none_rounded,
                              ),
                              onPressed: () {},
                            ),
                            _buildUserMenu(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content
                  if (_isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_error != null)
                    SliverFillRemaining(
                      child: ErrorStateWidget(
                        message: _error!,
                        onRetry: _loadDashboardData,
                      ),
                    )
                  else ...[
                    // Overview Section
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Performance Overview',
                              style: AppTheme.headingSmall.copyWith(
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildStatsGrid(),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Actions',
                              style: AppTheme.headingSmall.copyWith(
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildQuickActions(),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recent Activity',
                              style: AppTheme.headingSmall.copyWith(
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildActivityList(),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserMenu() {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.person_rounded,
          size: 22,
          color: AppTheme.primaryBlue,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: AppTheme.largeRadius),
      offset: const Offset(0, 48),
      onSelected: (value) {
        if (value == 'logout') _handleLogout();
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _authService.currentAdmin?.name ?? 'Admin',
                style: AppTheme.labelBold,
              ),
              Text(
                _authService.currentAdmin?.email ?? 'admin@college.edu',
                style: AppTheme.caption,
              ),
              const Divider(),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings_outlined, size: 20),
              SizedBox(width: 12),
              Text('System Settings'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 20, color: AppTheme.errorRed),
              SizedBox(width: 12),
              Text('Sign Out', style: TextStyle(color: AppTheme.errorRed)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    if (_stats == null) return const SizedBox.shrink();

    // MOBILE-FIRST: Using Column + Row instead of GridView
    // This prevents fixed height constraints and adapts to content
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // First row of cards
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Total Drives',
                value: '${_stats!.totalDrives}',
                icon: Icons.campaign_outlined,
                color: AppTheme.primaryBlue,
                animationIndex: 0,
                onTap: () => _navigateToDrives(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Active Drives',
                value: '${_stats!.activeDrives}',
                icon: Icons.play_circle_outline,
                color: AppTheme.successGreen,
                animationIndex: 1,
                onTap: () => _navigateToDrives(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Second row of cards
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Completed',
                value: '${_stats!.completedDrives}',
                icon: Icons.check_circle_outline,
                color: Colors.grey,
                animationIndex: 2,
                onTap: () => _navigateToDrives(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Students Placed',
                value: '${_stats!.placedStudents}',
                icon: Icons.school_outlined,
                color: AppTheme.warningOrange,
                animationIndex: 3,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.largeRadius,
        boxShadow: AppTheme.softShadow,
      ),
      // MOBILE-FIRST: Use IntrinsicHeight for proper divider sizing
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _buildQuickActionItem(
                Icons.add_circle_outline,
                'Add Drive',
                AppTheme.primaryBlue,
                () => _navigateToDrives(addNew: true),
              ),
            ),
            VerticalDivider(width: 1, thickness: 1, color: Colors.grey[200]),
            Expanded(
              child: _buildQuickActionItem(
                Icons.school_outlined,
                'Students',
                AppTheme.successGreen,
                _navigateToStudents,
              ),
            ),
            VerticalDivider(width: 1, thickness: 1, color: Colors.grey[200]),
            Expanded(
              child: _buildQuickActionItem(
                Icons.calendar_month,
                'Calendar',
                AppTheme.warningOrange,
                _navigateToCalendar,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    if (_activities == null || _activities!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.largeRadius,
        ),
        child: Center(
          child: Text(
            'No recent activities',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.largeRadius,
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: _activities!.asMap().entries.map((entry) {
          final index = entry.key;
          final activity = entry.value;
          final isLast = index == _activities!.length - 1;

          return _buildActivityItem(activity, isLast, index);
        }).toList(),
      ),
    );
  }

  Widget _buildActivityItem(
    Map<String, dynamic> activity,
    bool isLast,
    int index,
  ) {
    IconData icon;
    Color color;

    switch (activity['type']) {
      case 'drive_created':
        icon = Icons.add_circle;
        color = AppTheme.primaryBlue;
        break;
      case 'student_placed':
        icon = Icons.celebration;
        color = AppTheme.successGreen;
        break;
      case 'drive_status':
        icon = Icons.update;
        color = AppTheme.warningOrange;
        break;
      case 'new_company':
        icon = Icons.business;
        color = Colors.purple;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(20 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: Colors.grey[100]!)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity['description'] ?? '',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Text(
              _formatTimestamp(activity['timestamp']),
              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';

    final date = DateTime.tryParse(timestamp);
    if (date == null) return '';

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  void _navigateToDrives({bool addNew = false}) {
    // SECURITY: Use protected route navigation
    AdminRouteMiddleware.navigateTo(
      context,
      DriveManagementScreen(openAddForm: addNew),
    );
  }

  void _navigateToStudents() {
    // SECURITY: Use protected route navigation
    AdminRouteMiddleware.navigateTo(context, const StudentManagementScreen());
  }

  void _navigateToCalendar() {
    // SECURITY: Use protected route navigation
    AdminRouteMiddleware.navigateTo(context, const CalendarScreen());
  }
}
