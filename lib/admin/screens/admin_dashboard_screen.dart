import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/dashboard_stats.dart';
import '../services/admin_auth_service.dart';
import '../services/dashboard_service.dart';
import '../security/admin_route_guard.dart';
import '../widgets/stats_card.dart';
import '../widgets/state_widgets.dart';
import '../widgets/dialogs.dart';
import 'drive_management_screen.dart';
import 'admin_login_screen.dart';

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
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      icon: Icons.logout,
    );

    if (confirmed == true) {
      await _authService.logout();
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // MOBILE-FIRST: Calculate responsive header height
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = screenHeight < 700 ? 160.0 : 180.0;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldLight,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar with responsive height
            SliverAppBar(
              expandedHeight: headerHeight,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(background: _buildHeader()),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notifications coming soon'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.mediumRadius,
                  ),
                  onSelected: (value) {
                    if (value == 'logout') {
                      _handleLogout();
                    } else if (value == 'settings') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settings coming soon'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(Icons.settings_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('Settings'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Logout', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
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
              // Stats Grid
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatsGrid(),
                    ],
                  ),
                ),
              ),

              // Quick Actions
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildQuickActions(),
                    ],
                  ),
                ),
              ),

              // Recent Activities
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Activity',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildActivityList(),
                    ],
                  ),
                ),
              ),

              // Bottom Padding
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          // Reduced padding for mobile
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Welcome back!',
                          style: TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _authService.currentAdmin?.name ?? 'Admin User',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: AppTheme.pillRadius,
                ),
                child: Text(
                  _authService.currentAdmin?.role ?? 'Administrator',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
                Icons.list_alt,
                'All Drives',
                AppTheme.successGreen,
                () => _navigateToDrives(),
              ),
            ),
            VerticalDivider(width: 1, thickness: 1, color: Colors.grey[200]),
            Expanded(
              child: _buildQuickActionItem(
                Icons.analytics_outlined,
                'Reports',
                AppTheme.warningOrange,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reports coming soon'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
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
}
