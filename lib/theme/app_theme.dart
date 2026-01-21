import 'package:flutter/material.dart';

/// App Theme Configuration
/// Centralized theme & color management with gradients and modern styling
class AppTheme {
  // ========== PRIMARY COLORS ==========
  static const Color primaryBlue = Color(0xFF007DC5);
  static const Color primaryDark = Color(0xFF005A8D);
  static const Color primaryLight = Color(0xFF3397D1);
  static const Color accentColor = Color(0xFF8CC63F);

  // ========== BACKGROUND COLORS ==========
  static const Color scaffoldLight = Color(0xFFF5F9FA);
  static const Color scaffoldDark = Color(0xFF0F1116);
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF181B21);
  static const Color adminSidebarDark = Color(0xFF14171C);
  static const Color adminSidebarLight = Colors.white;
  static const Color adminAccent = Color(0xFF007DC5);

  // ========== STATUS COLORS ==========
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFF44336);
  static const Color infoBlue = Color(0xFF2196F3);

  // ========== GRADIENTS ==========
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF007DC5), Color(0xFF8CC63F)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE3F2FD), Color(0xFFF1F8E9), Colors.white],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FBFF)],
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFB8C00), Color(0xFFFFB74D)],
  );

  // ========== SHADOWS ==========
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: primaryBlue.withValues(alpha: 0.3),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];

  // ========== BORDER RADIUS ==========
  static BorderRadius get smallRadius => BorderRadius.circular(8);
  static BorderRadius get mediumRadius => BorderRadius.circular(12);
  static BorderRadius get largeRadius => BorderRadius.circular(16);
  static BorderRadius get xlRadius => BorderRadius.circular(24);
  static BorderRadius get pillRadius => BorderRadius.circular(50);

  // ========== DURATIONS ==========
  static const Duration fastDuration = Duration(milliseconds: 150);
  static const Duration normalDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);
  static const Duration staggerDuration = Duration(milliseconds: 100);

  // ========== CURVES ==========
  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeInOutCubic;

  // ========== SPACING & PADDING ==========
  static const double horizontalPadding = 20.0;
  static const double verticalPadding = 16.0;
  static const double cardMargin = 12.0;
  static const double itemSpacing = 16.0;

  // ========== TEXT STYLES (STRICT HIERARCHY) ==========
  static const TextStyle headingLarge = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1A1A1A),
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1A1A1A),
    height: 1.3,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1A1A1A),
    letterSpacing: -0.2,
  );

  static const TextStyle adminTabLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Color(0xFF333333),
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFF666666),
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0xFF757575),
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: Color(0xFF9E9E9E),
    letterSpacing: 0.2,
  );

  static const TextStyle labelBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1A1A1A),
    letterSpacing: 0.5,
  );

  // ========== THEME DATA ==========
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: scaffoldLight,
    fontFamily: 'Inter', // Modern font
    colorScheme: ColorScheme.light(
      primary: primaryBlue,
      secondary: accentColor,
      surface: cardLight,
      error: errorRed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: Color(0xFF1A1A1A)),
      titleTextStyle: TextStyle(
        color: Color(0xFF1A1A1A),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: largeRadius),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: mediumRadius),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryBlue,
        side: const BorderSide(color: primaryBlue),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: mediumRadius),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: mediumRadius,
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: mediumRadius,
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: mediumRadius,
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: mediumRadius,
        borderSide: const BorderSide(color: errorRed),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 16,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryLight,
    scaffoldBackgroundColor: scaffoldDark,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.dark(
      primary: primaryLight,
      secondary: accentColor,
      surface: cardDark,
      error: errorRed,
    ),
  );
}
