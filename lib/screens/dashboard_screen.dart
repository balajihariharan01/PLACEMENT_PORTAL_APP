import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/drive_card.dart';
import '../widgets/animated_widgets.dart';
import '../theme/app_theme.dart';
import 'placed_drives_tab.dart';
import 'profile_screen.dart';
import '../widgets/no_data_widget.dart';
import '../widgets/branded_header.dart';

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

  // -- Drives Tab Data --
  String _drivesSelectedTab = "All";
  final List<String> _drivesTabs = ["Opened", "All", "Eligible", "Applied"];

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
          child: Column(
            children: [
              if (_selectedIndex != 2)
                BrandedHeader(
                  title: _selectedIndex == 0
                      ? 'Placement Drives'
                      : 'My Successes',
                  subtitle: _selectedIndex == 0
                      ? 'Discover top career opportunities'
                      : 'Track your career milestones',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search_rounded),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_none_rounded),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: FadeTransition(
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
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onTabChanged,
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
}
