import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/drive_model.dart';
import '../services/drive_service.dart';
import '../widgets/dashboard/enhanced_drive_card.dart';
import '../widgets/dashboard/filter_modal.dart';
import '../theme/app_theme.dart';
import 'placed_drives_tab.dart';
import 'profile_screen.dart';
import 'drive_detail_screen.dart';
import '../widgets/no_data_widget.dart';
import '../widgets/branded_header.dart';
import '../widgets/animated_widgets.dart';
import '../utils/logout_helper.dart';

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

  // Data
  final DriveService _driveService = DriveService();
  List<Drive> _allDrives = [];
  List<Drive> _filteredDrives = [];
  bool _isLoading = true;

  // Tabs
  String _selectedTab = "Upcoming";
  final List<String> _tabs = [
    "Upcoming",
    "Ongoing",
    "Completed",
    "On Hold",
    "Reopened",
    "All",
    "Not Eligible",
  ];

  // Sorting
  String _selectedSort = "Apply Date Ascending";
  final List<String> _sortOptions = [
    "A to Z",
    "Z to A",
    "Apply Date Ascending",
    "Apply Date Descending",
  ];

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
      duration: AppTheme.normalDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();

    _loadDrives();
  }

  Future<void> _loadDrives() async {
    final drives = await _driveService.getDrives();
    if (mounted) {
      setState(() {
        _allDrives = drives;
        _isLoading = false;
        _applyFilters();
      });
    }
  }

  void _applyFilters() {
    // Basic Tab Filtering
    List<Drive> temp = [];

    switch (_selectedTab) {
      case "All":
        temp = List.from(_allDrives);
        break;
      case "Upcoming":
        temp = _allDrives
            .where(
              (d) =>
                  d.status != DriveStatus.closed &&
                  d.status != DriveStatus.notEligible,
            )
            .toList(); // Simplified logic
        break;
      case "Ongoing":
        // Mock logic: All drives are essentially 'ongoing' in this demo unless closed
        temp = _allDrives
            .where(
              (d) =>
                  d.status == DriveStatus.applied ||
                  d.status == DriveStatus.eligible,
            )
            .toList();
        break;
      case "Completed":
        temp = _allDrives
            .where(
              (d) =>
                  d.status == DriveStatus.placed ||
                  d.status == DriveStatus.closed,
            )
            .toList();
        break;
      case "Not Eligible":
        temp = _allDrives
            .where((d) => d.status == DriveStatus.notEligible)
            .toList();
        break;
      default:
        temp = _allDrives; // Fallback
    }

    // Sorting
    temp.sort((a, b) {
      switch (_selectedSort) {
        case "A to Z":
          return a.companyName.compareTo(b.companyName);
        case "Z to A":
          return b.companyName.compareTo(a.companyName);
        case "Apply Date Ascending":
          return a.applyDate.compareTo(b.applyDate);
        case "Apply Date Descending":
          return b.applyDate.compareTo(a.applyDate);
        default:
          return 0;
      }
    });

    setState(() {
      _filteredDrives = temp;
    });
  }

  void _onTabChanged(int index) {
    if (_selectedIndex != index) {
      _fadeController.reset();
      setState(() => _selectedIndex = index);
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Very light grey background
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
              // Header
              if (_selectedIndex != 2)
                BrandedHeader(
                  title: _selectedIndex == 0
                      ? 'Placement Drives'
                      : 'My Successes',
                  subtitle: _selectedIndex == 0
                      ? 'Find your dream job'
                      : 'Track your achievements',
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search_rounded),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: AppTheme.errorRed,
                      ),
                      onPressed: () => LogoutHelper.logout(context),
                      tooltip: 'Logout',
                    ),
                  ],
                ),

              // Content
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
        // 1. Horizontal Scrollable Tabs
        Container(
          height: 60,
          color: Colors.white,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _tabs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final tab = _tabs[index];
              final isSelected = _selectedTab == tab;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTab = tab;
                    _applyFilters();
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black87 : Colors.grey[100],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tab,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      if (tab == "Ongoing" || tab == "Upcoming") ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            tab == "Ongoing" ? "30" : "0", // Mock counts
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // 2. Sort and Filter Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Sort Dropdown
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSort,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                      ),
                      isExpanded: true,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      items: _sortOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedSort = newValue;
                            _applyFilters();
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Filter Button
              GestureDetector(
                onTap: _showFilterModal,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: const [
                      Text(
                        "Filter",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.tune_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3. Drive List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredDrives.isEmpty
              ? const NoDataWidget()
              : RefreshIndicator(
                  onRefresh: _loadDrives,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredDrives.length,
                    itemBuilder: (context, index) {
                      final drive = _filteredDrives[index];
                      return EnhancedDriveCard(
                        drive: drive,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DriveDetailScreen(drive: drive),
                            ),
                          );
                        },
                        onOptIn: () => _handleOptIn(drive),
                        onOptOut: () => _handleOptOut(drive),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: FilterModal(
          onApply: () {
            Navigator.pop(context);
            // In a real app, you'd pass filter state back and re-apply
          },
          onClear: () {
            // Clear filters logic
          },
        ),
      ),
    );
  }

  void _handleOptIn(Drive drive) async {
    await _driveService.optIn(drive.id);
    _loadDrives(); // Reload to see status change
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opted in to ${drive.companyName}')),
      );
    }
  }

  void _handleOptOut(Drive drive) async {
    await _driveService.optOut(drive.id);
    // Reload or manually update list if service was real
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opted out of ${drive.companyName}')),
      );
    }
  }
}
