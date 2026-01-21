import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/drive.dart';
import '../services/drive_service.dart';
import '../widgets/state_widgets.dart';
import '../../widgets/app_logo.dart';
import 'drive_form_screen.dart';
import 'drive_details_screen.dart';

/// Drive Management Screen - Mobile-First Native Design
class DriveManagementScreen extends StatefulWidget {
  final bool openAddForm;
  const DriveManagementScreen({super.key, this.openAddForm = false});

  @override
  State<DriveManagementScreen> createState() => _DriveManagementScreenState();
}

class _DriveManagementScreenState extends State<DriveManagementScreen> {
  final _driveService = DriveService();
  final _searchController = TextEditingController();

  List<Drive> _drives = [];
  bool _isLoading = true;
  DriveStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadDrives();
    if (widget.openAddForm) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _navigateToAdd());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDrives() async {
    setState(() => _isLoading = true);
    final response = await _driveService.getAllDrives(
      status: _selectedStatus,
      searchQuery: _searchController.text.isNotEmpty
          ? _searchController.text
          : null,
    );
    if (!mounted) return;
    setState(() {
      _drives = response.data ?? [];
      _isLoading = false;
    });
  }

  void _navigateToDetails(Drive drive) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DriveDetailsScreen(drive: drive)),
    ).then((result) {
      if (result == true) _loadDrives();
    });
  }

  void _navigateToAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DriveFormScreen()),
    ).then((result) {
      if (result == true) _loadDrives();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),
            _buildFilterChips(),
            Expanded(child: _buildDriveList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAdd,
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Drive', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppLogo.adaptive(context: context, height: 32),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Recruitment Drives',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${_drives.length} drives found',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: AppTheme.mediumRadius,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _loadDrives(),
              decoration: InputDecoration(
                hintText: 'Search drives...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadDrives();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade100,
          borderRadius: AppTheme.pillRadius,
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

  Widget _buildDriveList() {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildShimmerCard(),
        ),
      );
    }

    if (_drives.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.campaign_outlined,
        title: 'No Drives Found',
        subtitle: 'Create your first recruitment drive',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDrives,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: _drives.length,
        itemBuilder: (context, index) {
          final drive = _drives[index];
          return _buildDriveCard(drive, index);
        },
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: AppTheme.mediumRadius,
      ),
    );
  }

  Widget _buildDriveCard(Drive drive, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.largeRadius,
          boxShadow: AppTheme.softShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _navigateToDetails(drive),
            borderRadius: AppTheme.largeRadius,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.business,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              drive.companyName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              drive.jobRole,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(drive.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoItem(
                        Icons.calendar_today,
                        _formatDate(drive.dateTime),
                      ),
                      const SizedBox(width: 20),
                      _buildInfoItem(
                        Icons.currency_rupee,
                        drive.salaryPackage ?? 'Not specified',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoItem(
                        Icons.people,
                        '${drive.registeredCount ?? 0} Applied',
                      ),
                      const SizedBox(width: 20),
                      _buildInfoItem(
                        Icons.check_circle_outline,
                        '${drive.placedCount ?? 0} Selected',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  Widget _buildStatusBadge(DriveStatus status) {
    Color color;
    switch (status) {
      case DriveStatus.active:
        color = AppTheme.successGreen;
        break;
      case DriveStatus.upcoming:
        color = AppTheme.primaryBlue;
        break;
      case DriveStatus.onHold:
        color = AppTheme.warningOrange;
        break;
      case DriveStatus.closed:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppTheme.pillRadius,
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
