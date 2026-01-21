import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/drive.dart';
import '../services/drive_service.dart';
import '../widgets/state_widgets.dart';
import '../security/admin_route_guard.dart';
import 'drive_details_screen.dart';

/// Calendar Screen
/// Displays drives on a calendar view with month navigation
/// SECURITY: Protected by AdminRouteGuard (via navigation)
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _driveService = DriveService();

  List<Drive>? _drives;
  bool _isLoading = true;
  String? _error;

  late DateTime _currentMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _selectedDate = DateTime.now();
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

  bool _hasEventsOnDate(DateTime date) {
    return _getDrivesForDate(date).isNotEmpty;
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _goToToday() {
    setState(() {
      _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
      _selectedDate = DateTime.now();
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _navigateToDriveDetails(Drive drive) {
    AdminRouteMiddleware.navigateTo(
      context,
      DriveDetailsScreen(driveId: drive.id),
    ).then((result) {
      if (result == true) _loadDrives();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldLight,
      appBar: AppBar(
        title: const Text('Drive Calendar'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: _goToToday,
            tooltip: 'Today',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? ErrorStateWidget(message: _error!, onRetry: _loadDrives)
          : SafeArea(
              child: Column(
                children: [
                  // Calendar Widget
                  _buildCalendar(),
                  const SizedBox(height: 8),
                  // Legend
                  _buildLegend(),
                  const SizedBox(height: 8),
                  // Selected Date Events
                  Expanded(child: _buildSelectedDateEvents()),
                ],
              ),
            ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.largeRadius,
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month Navigation
          _buildMonthNavigation(),
          // Weekday Headers
          _buildWeekdayHeaders(),
          // Calendar Grid
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation() {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _previousMonth,
            icon: const Icon(Icons.chevron_left),
            style: IconButton.styleFrom(backgroundColor: Colors.grey[100]),
          ),
          Text(
            '${months[_currentMonth.month - 1]} ${_currentMonth.year}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          IconButton(
            onPressed: _nextMonth,
            icon: const Icon(Icons.chevron_right),
            style: IconButton.styleFrom(backgroundColor: Colors.grey[100]),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: weekdays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    final today = DateTime.now();
    List<Widget> cells = [];

    // Empty cells before first day
    for (int i = 0; i < firstWeekday; i++) {
      cells.add(const SizedBox());
    }

    // Day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final isToday =
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final isSelected =
          _selectedDate != null &&
          date.year == _selectedDate!.year &&
          date.month == _selectedDate!.month &&
          date.day == _selectedDate!.day;
      final hasEvents = _hasEventsOnDate(date);
      final drivesOnDate = _getDrivesForDate(date);

      cells.add(
        _buildDayCell(
          day: day,
          date: date,
          isToday: isToday,
          isSelected: isSelected,
          hasEvents: hasEvents,
          drives: drivesOnDate,
        ),
      );
    }

    // Calculate rows needed
    final totalCells = cells.length;
    final rows = (totalCells / 7).ceil();

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
      child: Column(
        children: List.generate(rows, (rowIndex) {
          final start = rowIndex * 7;
          final end = (start + 7).clamp(0, totalCells);
          final rowCells = cells.sublist(start, end);

          // Pad the last row if needed
          while (rowCells.length < 7) {
            rowCells.add(const SizedBox());
          }

          return Row(
            children: rowCells.map((cell) => Expanded(child: cell)).toList(),
          );
        }),
      ),
    );
  }

  Widget _buildDayCell({
    required int day,
    required DateTime date,
    required bool isToday,
    required bool isSelected,
    required bool hasEvents,
    required List<Drive> drives,
  }) {
    // Get primary event color for date
    Color? eventColor;
    if (drives.isNotEmpty) {
      final statuses = drives.map((d) => d.status).toSet();
      if (statuses.contains(DriveStatus.active)) {
        eventColor = AppTheme.successGreen;
      } else if (statuses.contains(DriveStatus.upcoming)) {
        eventColor = AppTheme.primaryBlue;
      } else if (statuses.contains(DriveStatus.closed)) {
        eventColor = Colors.grey;
      } else {
        eventColor = AppTheme.warningOrange;
      }
    }

    return GestureDetector(
      onTap: () => _selectDate(date),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue
              : isToday
              ? AppTheme.primaryBlue.withValues(alpha: 0.1)
              : null,
          borderRadius: BorderRadius.circular(8),
          border: isToday && !isSelected
              ? Border.all(color: AppTheme.primaryBlue, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 4),
            Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday || isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: isSelected
                    ? Colors.white
                    : isToday
                    ? AppTheme.primaryBlue
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            // Event indicator dots
            if (hasEvents)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : eventColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (drives.length > 1) ...[
                    const SizedBox(width: 2),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.6)
                            : Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              )
            else
              const SizedBox(height: 6),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(AppTheme.primaryBlue, 'Upcoming'),
          const SizedBox(width: 16),
          _buildLegendItem(AppTheme.successGreen, 'Active'),
          const SizedBox(width: 16),
          _buildLegendItem(Colors.grey, 'Completed'),
          const SizedBox(width: 16),
          _buildLegendItem(AppTheme.warningOrange, 'On Hold'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSelectedDateEvents() {
    final drives = _selectedDate != null
        ? _getDrivesForDate(_selectedDate!)
        : <Drive>[];
    final dateStr = _selectedDate != null
        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
        : 'Select a date';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.largeRadius,
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.event, size: 20, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  'Drives on $dateStr',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                if (drives.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: AppTheme.pillRadius,
                    ),
                    child: Text(
                      '${drives.length} ${drives.length == 1 ? 'Drive' : 'Drives'}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Events List
          Expanded(
            child: drives.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 48,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No drives scheduled',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: drives.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final drive = drives[index];
                      return _buildDriveEventCard(drive);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriveEventCard(Drive drive) {
    Color statusColor;
    switch (drive.status) {
      case DriveStatus.active:
        statusColor = AppTheme.successGreen;
        break;
      case DriveStatus.upcoming:
        statusColor = AppTheme.primaryBlue;
        break;
      case DriveStatus.closed:
        statusColor = Colors.grey;
        break;
      case DriveStatus.onHold:
        statusColor = AppTheme.warningOrange;
        break;
    }

    return GestureDetector(
      onTap: () => _navigateToDriveDetails(drive),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: AppTheme.mediumRadius,
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            // Time
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: AppTheme.smallRadius,
              ),
              child: Column(
                children: [
                  Text(
                    _formatTime(drive.dateTime),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drive.driveName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${drive.companyName} • ${drive.location}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: AppTheme.pillRadius,
              ),
              child: Text(
                drive.status.displayName,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}
