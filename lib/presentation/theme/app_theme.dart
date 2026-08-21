import 'package:flutter/material.dart';

class AppDesignTokens {
  static const primary = Color(0xFF2F6B45);
  static const saffron = Color(0xFFD59624);
  static const terracotta = Color(0xFFB85C38);
  static const lightSurface = Color(0xFFFFF9F1);
  static const darkSurface = Color(0xFF121712);

  static const space8 = 8.0;
  static const space12 = 12.0;
  static const space16 = 16.0;
  static const space24 = 24.0;
  static const space32 = 32.0;

  static const radius12 = 12.0;
  static const radius16 = 16.0;
  static const radius20 = 20.0;
}

enum AppWindowClass { compact, medium, expanded }

class AppBreakpoints {
  static const medium = 600.0;
  static const expanded = 840.0;
  static const wide = 1280.0;

  static const readableContent = 760.0;
  static const standardContent = 1100.0;
  static const wideContent = 1280.0;

  // Classifies the current app window.
  static AppWindowClass windowClass(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= expanded) return AppWindowClass.expanded;
    if (width >= medium) return AppWindowClass.medium;
    return AppWindowClass.compact;
  }

  // Returns the responsive page gutter.
  static double gutter(BuildContext context) {
    return windowClass(context) == AppWindowClass.compact ? 16 : 24;
  }
}

class AppMotion {
  static const press = Duration(milliseconds: 120);
  static const state = Duration(milliseconds: 180);
  static const entrance = Duration(milliseconds: 240);
  static const route = Duration(milliseconds: 260);
  static const entranceCurve = Curves.easeOutCubic;
  static const stateCurve = Curves.easeInOutCubic;

  // Returns no duration when reduced motion is requested.
  static Duration duration(BuildContext context, Duration value) {
    return MediaQuery.maybeOf(context)?.disableAnimations == true ? Duration.zero : value;
  }
}

class AppRoute {
  // Builds the shared fade-and-rise route.
  static Route<T> build<T>(BuildContext context, Widget page) {
    final duration = AppMotion.duration(context, AppMotion.route);
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: AppMotion.entranceCurve,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.025),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

ThemeData buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: AppDesignTokens.primary,
    brightness: brightness,
    primary: isDark ? const Color(0xFF98D5AA) : AppDesignTokens.primary,
    secondary: isDark ? const Color(0xFFFFC46B) : AppDesignTokens.saffron,
    tertiary: isDark ? const Color(0xFFFFB59A) : AppDesignTokens.terracotta,
    surface: isDark ? AppDesignTokens.darkSurface : AppDesignTokens.lightSurface,
  );
  final base = ThemeData(
    colorScheme: scheme,
    brightness: brightness,
    useMaterial3: true,
    fontFamily: 'Manrope',
    scaffoldBackgroundColor: scheme.surface,
  );
  final textTheme = base.textTheme.copyWith(
    displayLarge: base.textTheme.displayLarge?.copyWith(fontFamily: 'Fraunces'),
    displayMedium: base.textTheme.displayMedium?.copyWith(fontFamily: 'Fraunces'),
    displaySmall: base.textTheme.displaySmall?.copyWith(fontFamily: 'Fraunces'),
    headlineLarge: base.textTheme.headlineLarge?.copyWith(fontFamily: 'Fraunces'),
    headlineMedium: base.textTheme.headlineMedium?.copyWith(fontFamily: 'Fraunces'),
    headlineSmall: base.textTheme.headlineSmall?.copyWith(fontFamily: 'Fraunces'),
    titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    titleMedium: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
  );
  final rounded16 = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppDesignTokens.radius16),
  );

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.headlineSmall?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainer,
      indicatorColor: scheme.primaryContainer,
      height: 72,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return textTheme.labelMedium?.copyWith(
          color: states.contains(WidgetState.selected) ? scheme.primary : scheme.onSurfaceVariant,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
        );
      }),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: scheme.surfaceContainer,
      indicatorColor: scheme.primaryContainer,
      selectedIconTheme: IconThemeData(color: scheme.primary),
      selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
        color: scheme.primary,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      groupAlignment: -0.72,
      labelType: NavigationRailLabelType.all,
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: rounded16,
      clipBehavior: Clip.antiAlias,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.all(AppDesignTokens.space16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: rounded16,
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(48, 52),
        elevation: 0,
        shape: rounded16,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size.square(48)),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
      ),
      side: BorderSide(color: scheme.outlineVariant),
      labelStyle: textTheme.labelLarge,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDesignTokens.radius20),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: rounded16,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: scheme.onInverseSurface,
      ),
      shape: rounded16,
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant),
  );
}
