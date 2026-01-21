/// Admin Module Exports
/// Provides a single import point for all admin module components
///
/// SECURITY NOTES:
/// - Admin module is completely isolated from user module
/// - All routes are protected by AdminRouteGuard
/// - Session management is handled by AdminSessionManager
/// - Entry points are restricted and hidden

// Models
export 'models/admin_user.dart';
export 'models/drive.dart';
export 'models/dashboard_stats.dart';

// Services
export 'services/admin_auth_service.dart';
export 'services/drive_service.dart';
export 'services/dashboard_service.dart';

// Security (Core)
export 'security/admin_session_manager.dart';
export 'security/admin_route_guard.dart';
export 'security/admin_entry_point.dart';

// Widgets
export 'widgets/admin_text_field.dart';
export 'widgets/admin_button.dart';
export 'widgets/stats_card.dart';
export 'widgets/admin_drive_card.dart';
export 'widgets/state_widgets.dart';
export 'widgets/dialogs.dart';

// Screens
export 'screens/admin_login_screen.dart';
export 'screens/admin_dashboard_screen.dart';
export 'screens/drive_management_screen.dart';
export 'screens/drive_form_screen.dart';
export 'screens/drive_details_screen.dart';
export 'screens/unauthorized_screen.dart';
