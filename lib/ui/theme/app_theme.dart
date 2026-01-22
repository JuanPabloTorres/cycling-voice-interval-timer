import 'package:flutter/material.dart';

/// App color palette optimized for cycling context:
/// - RidePulse brand colors from logo
/// - High contrast for outdoor visibility
/// - Blue/green cycling energy
abstract class AppColors {
  // Primary palette - Blue principal (branding, botones principales)
  static const Color primary = Color(0xFF0183BF);
  static const Color primaryLight = Color(0xFF4BA8D4);
  static const Color primaryDark = Color(0xFF025BA6);
  
  // Secondary palette - Verde pulso (acentos, progreso, estado activo)
  static const Color secondary = Color(0xFF0F8B6E);
  static const Color secondaryLight = Color(0xFF3AAF91);
  static const Color secondaryDark = Color(0xFF2E5C22);
  
  // Accent - Verde energía (ritmo, intervalos, highlights)
  static const Color accent = Color(0xFF449C38);
  static const Color accentLight = Color(0xFF6BBF5E);
  
  // Semantic colors
  static const Color success = Color(0xFF449C38);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF0183BF);
  
  // Action colors - cycling themed
  static const Color play = Color(0xFF0F8B6E);
  static const Color pause = Color(0xFFFFB800);
  static const Color stop = Color(0xFFFF5252);
  static const Color reset = Color(0xFF90A4AE);
  
  // Backgrounds - Dark UI with brand colors
  static const Color backgroundDark = Color(0xFF093F73);
  static const Color surfaceDark = Color(0xFF0A4A85);
  static const Color cardDark = Color(0xFF0C5596);
  
  static const Color backgroundLight = Color(0xFFF5FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  
  // Gradient colors
  static const Color gradientStart = Color(0xFF0183BF);
  static const Color gradientEnd = Color(0xFF0F8B6E);
  static const Color gradientAccent = Color(0xFF449C38);
  
  // Text
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB8D4E8);
  static const Color textDisabledDark = Color(0xFF5F8AAB);
  
  static const Color textPrimaryLight = Color(0xFF093F73);
  static const Color textSecondaryLight = Color(0xFF4A7A9E);
  static const Color textDisabledLight = Color(0xFFBDD0DE);
  
  // Cycling specific
  static const Color rider = Color(0xFF093F73);
  static const Color road = Color(0xFF90A4AE);
  static const Color pulse = Color(0xFF0F8B6E);
}

/// Standard dimensions for consistent spacing and sizing.
abstract class AppDimens {
  // Spacing
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  
  // Border radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;
  
  // Touch targets (minimum 48dp for cycling context)
  static const double touchTargetMin = 48.0;
  static const double touchTargetMd = 56.0;
  static const double touchTargetLg = 64.0;
  
  // Icon sizes
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  
  // Button heights
  static const double buttonHeight = 52.0;
  static const double buttonHeightSm = 40.0;
}

/// Animation durations for consistent motion.
abstract class AppDurations {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration slower = Duration(milliseconds: 500);
}

/// App theme configuration.
class AppTheme {
  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);
  
  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: isDark ? AppColors.primaryDark : AppColors.primaryLight,
      onPrimaryContainer: isDark ? Colors.white : AppColors.primaryDark,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: isDark ? AppColors.secondaryDark : AppColors.secondaryLight,
      onSecondaryContainer: isDark ? Colors.white : AppColors.secondaryDark,
      error: AppColors.error,
      onError: Colors.white,
      surface: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      onSurface: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      outline: isDark ? Colors.white24 : Colors.black12,
    );
    
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      
      // App Bar
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      
      // Cards
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          side: BorderSide(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(double.infinity, AppDimens.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, AppDimens.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          ),
          side: BorderSide(color: AppColors.primary),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.md,
          vertical: AppDimens.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
      
      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        ),
      ),
      
      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      
      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: isDark ? Colors.white24 : Colors.black12,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.2),
      ),
      
      // Progress indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: Colors.white10,
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        thickness: 1,
      ),
      
      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF323232) : const Color(0xFF323232),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        ),
      ),
    );
  }
}

/// Custom page route with fade + slide transition.
class AppPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  
  AppPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: AppDurations.fast,
          reverseTransitionDuration: AppDurations.fast,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(begin: const Offset(0.0, 0.05), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeOut));
            final fadeTween = Tween(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: Curves.easeOut));
            
            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: SlideTransition(
                position: animation.drive(tween),
                child: child,
              ),
            );
          },
        );
}
