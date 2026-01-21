import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';

class AdminSidebar extends StatefulWidget {
  final String currentRoute;
  final Function(String) onNavigate;
  final bool isCollapsed;
  final VoidCallback onToggle;

  const AdminSidebar({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppTheme.adminSidebarDark
        : AppTheme.adminSidebarLight;
    final borderColor = isDark
        ? Colors.white10
        : Colors.black.withValues(alpha: 0.05);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: widget.isCollapsed ? 80 : 260,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(right: BorderSide(color: borderColor)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildNavItem(
                  Icons.dashboard_rounded,
                  'Dashboard',
                  'dashboard',
                ),
                _buildNavItem(Icons.school_rounded, 'Students', 'students'),
                _buildNavItem(Icons.campaign_rounded, 'Drives', 'drives'),
                _buildNavItem(
                  Icons.business_rounded,
                  'Departments',
                  'departments',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  child: Divider(color: Colors.white12),
                ),
                _buildNavItem(Icons.analytics_rounded, 'Reports', 'reports'),
                _buildNavItem(
                  Icons.notifications_rounded,
                  'Notifications',
                  'notifications',
                ),
                _buildNavItem(Icons.settings_rounded, 'Settings', 'settings'),
              ],
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Row(
        mainAxisAlignment: widget.isCollapsed
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceBetween,
        children: [
          if (!widget.isCollapsed)
            AppLogo.adaptive(context: context, height: 32),
          IconButton(
            icon: Icon(
              widget.isCollapsed ? Icons.menu_rounded : Icons.menu_open_rounded,
              color: AppTheme.primaryBlue,
            ),
            onPressed: widget.onToggle,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, String route) {
    final isSelected = widget.currentRoute == route;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => widget.onNavigate(route),
        borderRadius: AppTheme.mediumRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCollapsed ? 0 : 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryBlue.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: AppTheme.mediumRadius,
          ),
          child: Row(
            mainAxisAlignment: widget.isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppTheme.primaryBlue
                    : (isDark ? Colors.white60 : Colors.black54),
                size: 22,
              ),
              if (!widget.isCollapsed) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: AppTheme.adminTabLabel.copyWith(
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: widget.isCollapsed
          ? const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/images/logo.jpg'),
            )
          : Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.05),
                borderRadius: AppTheme.largeRadius,
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage('assets/images/logo.jpg'),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Admin',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Manage Portal',
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.logout_rounded, size: 18, color: Colors.red[400]),
                ],
              ),
            ),
    );
  }
}
