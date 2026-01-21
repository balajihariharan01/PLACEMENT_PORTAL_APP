import 'package:flutter/material.dart';
import '../widgets/drive_card.dart';
import '../widgets/animated_widgets.dart';
import '../theme/app_theme.dart';
import 'placed_drives_tab.dart';
import 'profile_screen.dart';
import '../widgets/no_data_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // -- Drives Tab Data --
  String _drivesSelectedTab = "All";
  final List<String> _drivesTabs = [
    "Opened (0)",
    "All (0)",
    "Not Eligible (0)",
    "Reopened (0)",
    "OnHold (0)",
  ];

  final List<Map<String, dynamic>> _drives = [];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: AppTheme.normalDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    if (_selectedIndex != index) {
      _fadeController.reset();
      setState(() => _selectedIndex = index);
      _fadeController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldLight,
      appBar: _selectedIndex == 2
          ? null // No app bar for profile (has its own header)
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: _buildPremiumTitle(),
              actions: [
                _buildAnimatedIconButton(
                  icon: Icons.qr_code_scanner,
                  onPressed: () => _showSnackBar('QR Scanner'),
                ),
                _buildAnimatedIconButton(
                  icon: Icons.search,
                  onPressed: () => _showSnackBar('Search'),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildAnimatedIconButton(
                      icon: Icons.notifications_none,
                      onPressed: () => _showSnackBar('Notifications'),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: AppTheme.slowDuration,
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(scale: value, child: child);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: const Text(
                            '1',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
              ],
            ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildDrivesTab(),
            const PlacedDrivesTab(),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onTabChanged,
      ),
    );
  }

  Widget _buildAnimatedIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.0),
      duration: AppTheme.fastDuration,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: IconButton(
        icon: Icon(icon, color: Colors.black),
        onPressed: onPressed,
        splashRadius: 24,
      ),
    );
  }

  Widget _buildPremiumTitle() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: AppTheme.slowDuration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(-20 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Placement Portal',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Find your dream career',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrivesTab() {
    return Column(
      children: [
        // Animated Filter Tabs
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _drivesTabs.asMap().entries.map((entry) {
                int index = entry.key;
                String tab = entry.value;
                bool isSelected = tab.startsWith(_drivesSelectedTab);

                return Padding(
                  padding: EdgeInsets.only(
                    right: index < _drivesTabs.length - 1 ? 8 : 0,
                  ),
                  child: _buildAnimatedFilterTab(tab, isSelected),
                );
              }).toList(),
            ),
          ),
        ),

        // Drives List with Staggered Animation
        Expanded(
          child: _drives.isEmpty
              ? _buildNoDataFound()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _drives.length,
                  itemBuilder: (context, index) {
                    final drive = _drives[index];
                    return StaggeredFadeSlide(
                      index: index,
                      child: DriveCard(
                        companyName: drive['company'],
                        industry: drive['subtitle'],
                        salary: drive['salary'],
                        lastDate: drive['date'],
                        status: drive['status'],
                        statusColor: drive['statusColor'],
                        statusBgColor: drive['statusBgColor'],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAnimatedFilterTab(String tab, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _drivesSelectedTab = tab.split(' ')[0];
        });
      },
      child: AnimatedContainer(
        duration: AppTheme.normalDuration,
        curve: AppTheme.defaultCurve,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[100],
          borderRadius: AppTheme.pillRadius,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          tab,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildNoDataFound() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: AppTheme.slowDuration,
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: child,
            ),
          );
        },
        child: const NoDataWidget(),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$message tapped (UI only)'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
