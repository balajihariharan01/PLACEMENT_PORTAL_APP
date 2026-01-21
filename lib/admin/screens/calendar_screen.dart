import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/drive.dart';
import '../services/drive_service.dart';
import '../widgets/state_widgets.dart';
import '../security/admin_route_guard.dart';
import '../../widgets/branded_header.dart';
import 'drive_details_screen.dart';
import 'package:intl/intl.dart';

/// Premium Admin Calendar Screen
/// Redesigned for visual consistency and modern mobile-first UX
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _driveService = DriveService();
  final _today = DateTime.now();

  List<Drive>? _drives;
  bool _isLoading = true;
  String? _error;

  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(_today.year, _today.month);
    _loadDrives();
  }

  Future<void> _loadDrives() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await _driveService.getAllDrives();

    if (!mounted) return;

    if (response.success) {
      setState(() {
        _drives = response.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = response.message;
        _isLoading = false;
      });
    }
  }

  List<Drive> _getDrivesForDate(DateTime date) {
    if (_drives == null) return [];
    return _drives!.where((drive) {
      return drive.dateTime.year == date.year &&
          drive.dateTime.month == date.month &&
          drive.dateTime.day == date.day;
    }).toList();
  }

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + offset,
      );
    });
  }

  void _navigateToDriveDetails(Drive drive) {
    AdminRouteMiddleware.navigateTo(
      context,
      DriveDetailsScreen(drive: drive),
    ).then((result) {
      if (result == true) _loadDrives();
    });
  }

  Color _getStatusColor(DriveStatus status) {
    switch (status) {
      case DriveStatus.active:
        return AppTheme.successGreen;
      case DriveStatus.upcoming:
        return AppTheme.primaryBlue;
      case DriveStatus.closed:
        return Colors.grey[600]!;
      case DriveStatus.onHold:
        return AppTheme.warningOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldLight,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(elevation: 0, backgroundColor: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            BrandedHeader(
              title: 'Drive Calendar',
              subtitle: 'Track all recruitment events',
              showBackButton: true,
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.today_rounded,
                    color: AppTheme.primaryBlue,
                  ),
                  onPressed: () => setState(
                    () => _currentMonth = DateTime(_today.year, _today.month),
                  ),
                  tooltip: 'Today',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: _loadDrives,
                ),
              ],
            ),

            // Month Switcher
            _buildMonthSwitcher(),

            // Calendar Body
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? ErrorStateWidget(message: _error!, onRetry: _loadDrives)
                  : _buildCalendarContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSwitcher() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.pillRadius,
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon: const Icon(Icons.chevron_left_rounded, size: 28),
            color: Colors.black87,
          ),
          Text(
            DateFormat('MMMM yyyy').format(_currentMonth),
            style: AppTheme.headingSmall.copyWith(letterSpacing: 0),
          ),
          IconButton(
            onPressed: () => _changeMonth(1),
            icon: const Icon(Icons.chevron_right_rounded, size: 28),
            color: Colors.black87,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarContent() {
    return Column(
      children: [
        // Weekday Legend
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: AppTheme.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
        // Grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildCalendarGrid(),
          ),
        ),
        // Status Legend at bottom
        _buildBottomLegend(),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startPadding = firstDay.weekday % 7;
    final totalDays = lastDay.day;

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.65, // Taller cells for drive info
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: 42, // Fix to 6 rows (7*6)
      itemBuilder: (context, index) {
        final dayOffset = index - startPadding;
        if (dayOffset < 0 || dayOffset >= totalDays) {
          return const SizedBox.shrink(); // Empty padding cell
        }

        final date = DateTime(
          _currentMonth.year,
          _currentMonth.month,
          dayOffset + 1,
        );
        return _buildDateCell(date);
      },
    );
  }

  Widget _buildDateCell(DateTime date) {
    final isToday =
        date.year == _today.year &&
        date.month == _today.month &&
        date.day == _today.day;
    final drives = _getDrivesForDate(date);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.mediumRadius,
        border: Border.all(
          color: isToday ? AppTheme.primaryBlue : Colors.grey[100]!,
          width: isToday ? 1.5 : 1,
        ),
        boxShadow: isToday ? AppTheme.softShadow : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day Number
          Padding(
            padding: const EdgeInsets.all(6),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: isToday
                  ? const BoxDecoration(
                      color: AppTheme.primaryBlue,
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                  color: isToday ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),

          // Drives inside cell
          Expanded(
            child: Column(
              children: [
                ...drives.take(2).map((d) => _buildDriveIndicator(d)),
                if (drives.length > 2)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '+${drives.length - 2} more',
                      style: AppTheme.caption.copyWith(
                        fontSize: 8,
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriveIndicator(Drive drive) {
    final color = _getStatusColor(drive.status);

    return GestureDetector(
      onTap: () => _navigateToDriveDetails(drive),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(2, 0, 2, 3),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
        ),
        child: Text(
          drive.companyName,
          style: TextStyle(
            color: color,
            fontSize: 7.5,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildBottomLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem(AppTheme.primaryBlue, 'Upcoming'),
          _buildLegendItem(AppTheme.successGreen, 'Active'),
          _buildLegendItem(Colors.grey[600]!, 'Closed'),
          _buildLegendItem(AppTheme.warningOrange, 'On Hold'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTheme.caption.copyWith(color: Colors.black54)),
      ],
    );
  }
}
