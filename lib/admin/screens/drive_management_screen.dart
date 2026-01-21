import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/drive.dart';
import '../services/drive_service.dart';
import '../widgets/admin_drive_card.dart';
import '../widgets/state_widgets.dart';
import '../widgets/dialogs.dart';
import 'drive_form_screen.dart';
import 'drive_details_screen.dart';

/// Drive Management Screen
/// List view with filtering, search, and CRUD operations
class DriveManagementScreen extends StatefulWidget {
  final bool openAddForm;

  const DriveManagementScreen({super.key, this.openAddForm = false});

  @override
  State<DriveManagementScreen> createState() => _DriveManagementScreenState();
}

class _DriveManagementScreenState extends State<DriveManagementScreen>
    with SingleTickerProviderStateMixin {
  final _driveService = DriveService();
  final _searchController = TextEditingController();

  List<Drive> _drives = [];
  bool _isLoading = true;
  String? _error;
  DriveStatus? _selectedStatus;
  String _searchQuery = '';

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
    _loadDrives();

    // Open add form if requested
    if (widget.openAddForm) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToForm();
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDrives() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await _driveService.getAllDrives(
      status: _selectedStatus,
      searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
    );

    if (!mounted) return;

    if (response.success) {
      setState(() {
        _drives = response.data ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = response.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleDeleteDrive(Drive drive) async {
    final confirmed = await ConfirmationDialog.showDelete(
      context: context,
      itemName: 'drive',
    );

    if (confirmed == true) {
      final response = await _driveService.deleteDrive(drive.id);

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Drive deleted successfully'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.successGreen,
            shape: RoundedRectangleBorder(borderRadius: AppTheme.smallRadius),
          ),
        );
        _loadDrives();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to delete drive'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.errorRed,
            shape: RoundedRectangleBorder(borderRadius: AppTheme.smallRadius),
          ),
        );
      }
    }
  }

  void _navigateToForm({Drive? drive}) async {
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DriveFormScreen(drive: drive),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: AppTheme.defaultCurve,
                  ),
                ),
            child: child,
          );
        },
        transitionDuration: AppTheme.normalDuration,
      ),
    );

    if (result == true) {
      _loadDrives();
    }
  }

  void _navigateToDetails(Drive drive) async {
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DriveDetailsScreen(drive: drive),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: AppTheme.defaultCurve,
                  ),
                ),
            child: child,
          );
        },
        transitionDuration: AppTheme.normalDuration,
      ),
    );

    if (result == true) {
      _loadDrives();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Drive Management',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadDrives,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Search and Filter Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                      // Debounced search
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (_searchQuery == value) {
                          _loadDrives();
                        }
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search drives...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                                _loadDrives();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: AppTheme.pillRadius,
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', null),
                        const SizedBox(width: 8),
                        _buildFilterChip('Active', DriveStatus.active),
                        const SizedBox(width: 8),
                        _buildFilterChip('Upcoming', DriveStatus.upcoming),
                        const SizedBox(width: 8),
                        _buildFilterChip('Closed', DriveStatus.closed),
                        const SizedBox(width: 8),
                        _buildFilterChip('On Hold', DriveStatus.onHold),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Drives List
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _error != null
                  ? ErrorStateWidget(message: _error!, onRetry: _loadDrives)
                  : _drives.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.campaign_outlined,
                      title: 'No drives found',
                      subtitle: _searchQuery.isNotEmpty
                          ? 'Try a different search term'
                          : 'Create your first drive to get started',
                      buttonText: 'Add Drive',
                      onButtonPressed: () => _navigateToForm(),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadDrives,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        itemCount: _drives.length,
                        itemBuilder: (context, index) {
                          final drive = _drives[index];
                          return AdminDriveCard(
                            drive: drive,
                            animationIndex: index,
                            onTap: () => _navigateToDetails(drive),
                            onEdit: () => _navigateToForm(drive: drive),
                            onDelete: () => _handleDeleteDrive(drive),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Drive',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, DriveStatus? status) {
    final isSelected = _selectedStatus == status;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedStatus = status);
        _loadDrives();
      },
      child: AnimatedContainer(
        duration: AppTheme.fastDuration,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.grey[100],
          borderRadius: AppTheme.pillRadius,
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => const DriveCardSkeleton(),
    );
  }
}
