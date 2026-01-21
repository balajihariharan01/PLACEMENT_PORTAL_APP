import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/admin_sidebar.dart';

class AdminScaffold extends StatefulWidget {
  final Widget body;
  final String currentRoute;
  final Function(String) onNavigate;

  const AdminScaffold({
    super.key,
    required this.body,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      drawer: isMobile
          ? AdminSidebar(
              currentRoute: widget.currentRoute,
              onNavigate: (route) {
                Navigator.pop(context);
                widget.onNavigate(route);
              },
              isCollapsed: false,
              onToggle: () {},
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            AdminSidebar(
              currentRoute: widget.currentRoute,
              onNavigate: widget.onNavigate,
              isCollapsed: _isCollapsed,
              onToggle: () => setState(() => _isCollapsed = !_isCollapsed),
            ),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(isMobile),
                Expanded(child: widget.body),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white10
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search anything...',
                  hintStyle: TextStyle(fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, size: 20),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
          _buildProfileDropdown(),
        ],
      ),
    );
  }

  Widget _buildProfileDropdown() {
    return PopupMenuButton(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: AppTheme.mediumRadius),
      child: const CircleAvatar(
        radius: 18,
        backgroundImage: AssetImage('assets/images/logo.jpg'),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(child: Text('Profile')),
        const PopupMenuItem(child: Text('Settings')),
        const PopupMenuItem(
          child: Text('Logout', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
