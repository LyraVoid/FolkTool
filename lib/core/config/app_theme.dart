import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'app_semantic_colors.dart';

/// Centralized Material 3 theme definitions for Light and Dark modes.
///
/// Design intent:
///  * one seeded, accessible [ColorScheme] per brightness (contrast-checked),
///  * a small, shared radius/spacing scale ([AppRadius], [AppSpacing]),
///  * desktop-appropriate density: compact controls, thin scrollbars,
///    horizontal page transitions instead of mobile-style fades,
///  * semantic colours (success/warning/terminal) exposed through
///    [AppSemanticColors] so widgets never hard-code `Colors.green` again.
class AppTheme {
  static const Color _seedColor = Color(0xFF2563EB);

  static ThemeData light() => _buildTheme(Brightness.light);

  static ThemeData dark() => _buildTheme(Brightness.dark);

  /// Rebuilds [ColorScheme] with an explicitly readable set of container
  /// colours. `ColorScheme.fromSeed` can produce low-contrast pairs on some
  /// seeds; these overrides keep text readable in both themes.
  static ColorScheme _colorScheme(Brightness brightness) {
    final base = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    );

    return base.copyWith(
      surfaceContainerLowest: brightness == Brightness.dark
          ? const Color(0xFF0E1116)
          : const Color(0xFFFFFFFF),
      surfaceContainerLow: brightness == Brightness.dark
          ? const Color(0xFF161A20)
          : const Color(0xFFF8F9FB),
      surfaceContainer: brightness == Brightness.dark
          ? const Color(0xFF1B2027)
          : const Color(0xFFF1F3F7),
      surfaceContainerHigh: brightness == Brightness.dark
          ? const Color(0xFF222831)
          : const Color(0xFFE9ECF2),
      outlineVariant: brightness == Brightness.dark
          ? const Color(0xFF3A424E)
          : const Color(0xFFD5DAE3),
      errorContainer: brightness == Brightness.dark
          ? const Color(0xFF4A1F22)
          : const Color(0xFFFCE4E5),
      onErrorContainer: brightness == Brightness.dark
          ? const Color(0xFFFFD9DA)
          : const Color(0xFF3B0A10),
    );
  }

  static const Map<TargetPlatform, PageTransitionsBuilder> _transitions = {
    // `FadeForwardsPageTransitionsBuilder` is the Material 3 "expressive"
    // transition: a short horizontal slide + fade. It is snappier than the
    // old FadeUpwards builder and no longer feels mobile-ish on desktop.
    TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
    TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
    TargetPlatform.fuchsia: FadeForwardsPageTransitionsBuilder(),
    TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
  };

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = _colorScheme(brightness);
    final semantic =
        isDark ? AppSemanticColors.dark : AppSemanticColors.light;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
    );

    const shapeMd = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
    );
    const shapeLg = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
    );

    return base.copyWith(
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      visualDensity: VisualDensity.compact,
      // InkRipple is far cheaper to paint than InkSparkle's shader-based splash
      // and looks correct on desktop.
      splashFactory: InkRipple.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(builders: _transitions),
      extensions: <ThemeExtension<dynamic>>[semantic],

      textTheme: _textTheme(base.textTheme, colorScheme),

      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: colorScheme.surfaceTint,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: colorScheme.onSurface,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        color: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),

      // One shared shape for every button family keeps the UI coherent.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: shapeMd,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: shapeMd,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: shapeMd,
          side: BorderSide(color: colorScheme.outlineVariant),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: shapeMd,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHigh,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),

      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: shapeLg,
      ),
      popupMenuTheme: PopupMenuThemeData(
        elevation: 2,
        color: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: shapeMd,
        textStyle: TextStyle(fontSize: 13, color: colorScheme.onSurface),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 2,
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        shape: shapeMd,
        contentTextStyle: TextStyle(
          fontSize: 13,
          color: colorScheme.onInverseSurface,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 500),
        textStyle: TextStyle(fontSize: 12, color: colorScheme.onInverseSurface),
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        shape: shapeMd,
        dense: true,
        iconColor: colorScheme.onSurfaceVariant,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: shapeMd,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        linearMinHeight: 6,
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHigh,
      ),
      // Thin, hover-revealing desktop scrollbars; avoids the chunky default.
      scrollbarTheme: ScrollbarThemeData(
        thickness: const WidgetStatePropertyAll(6),
        radius: const Radius.circular(3),
        thumbVisibility: const WidgetStatePropertyAll(false),
        trackVisibility: const WidgetStatePropertyAll(false),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.dragged) ||
              states.contains(WidgetState.hovered)) {
            return colorScheme.onSurfaceVariant.withValues(alpha: 0.55);
          }
          return colorScheme.onSurfaceVariant.withValues(alpha: 0.3);
        }),
      ),
    );
  }

  /// Tightens headings and gives the UI a consistent type ramp.
  static TextTheme _textTheme(TextTheme base, ColorScheme colorScheme) {
    TextStyle? semibold(TextStyle? style, double size, double spacing) {
      return style?.copyWith(
        fontSize: size,
        fontWeight: FontWeight.w600,
        letterSpacing: spacing,
        color: colorScheme.onSurface,
      );
    }

    return base.copyWith(
      titleLarge: semibold(base.titleLarge, 20, -0.4),
      titleMedium: semibold(base.titleMedium, 15, -0.1),
      titleSmall: semibold(base.titleSmall, 13, 0),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 13.5, height: 1.45),
      bodySmall: base.bodySmall?.copyWith(fontSize: 12, height: 1.4),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
