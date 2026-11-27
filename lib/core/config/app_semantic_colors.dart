import 'package:flutter/material.dart';

/// Semantic colours that Material 3's [ColorScheme] does not provide
/// (success, warning, terminal surfaces).
///
/// Registered as a [ThemeExtension] so every widget reads the same tokens in
/// light and dark mode instead of hard-coding `Colors.green` / `Colors.orange`.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;

  final Color info;
  final Color infoContainer;
  final Color onInfoContainer;

  /// Background of the log console. Kept deliberately "terminal" in both
  /// themes, but tuned so it is never pure black or a jarring slab in light mode.
  final Color terminalBackground;
  final Color terminalHeader;
  final Color terminalForeground;

  const AppSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.terminalBackground,
    required this.terminalHeader,
    required this.terminalForeground,
  });

  static const AppSemanticColors light = AppSemanticColors(
    success: Color(0xFF1B7F4B),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFD5F3E1),
    onSuccessContainer: Color(0xFF06301B),
    warning: Color(0xFF9A5B00),
    onWarning: Color(0xFFFFFFFF),
    warningContainer: Color(0xFFFDEBC8),
    onWarningContainer: Color(0xFF3D2600),
    info: Color(0xFF1D5FD0),
    infoContainer: Color(0xFFDCE7FF),
    onInfoContainer: Color(0xFF0A1F45),
    terminalBackground: Color(0xFFF6F7F9),
    terminalHeader: Color(0xFFECEEF2),
    terminalForeground: Color(0xFF1F2328),
  );

  static const AppSemanticColors dark = AppSemanticColors(
    success: Color(0xFF5FD79B),
    onSuccess: Color(0xFF00391E),
    successContainer: Color(0xFF0E3A26),
    onSuccessContainer: Color(0xFFB7F2D1),
    warning: Color(0xFFFFC46B),
    onWarning: Color(0xFF402B00),
    warningContainer: Color(0xFF463000),
    onWarningContainer: Color(0xFFFFDFA8),
    info: Color(0xFF9CC4FF),
    infoContainer: Color(0xFF17294A),
    onInfoContainer: Color(0xFFD7E4FF),
    terminalBackground: Color(0xFF14171C),
    terminalHeader: Color(0xFF1D2128),
    terminalForeground: Color(0xFFE4E7EC),
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? terminalBackground,
    Color? terminalHeader,
    Color? terminalForeground,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      terminalBackground: terminalBackground ?? this.terminalBackground,
      terminalHeader: terminalHeader ?? this.terminalHeader,
      terminalForeground: terminalForeground ?? this.terminalForeground,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer:
          Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
      terminalBackground:
          Color.lerp(terminalBackground, other.terminalBackground, t)!,
      terminalHeader: Color.lerp(terminalHeader, other.terminalHeader, t)!,
      terminalForeground:
          Color.lerp(terminalForeground, other.terminalForeground, t)!,
    );
  }
}

/// Convenience accessor: `context.semantic.success`.
extension AppSemanticColorsX on BuildContext {
  AppSemanticColors get semantic {
    final theme = Theme.of(this);
    return theme.extension<AppSemanticColors>() ??
        (theme.brightness == Brightness.dark
            ? AppSemanticColors.dark
            : AppSemanticColors.light);
  }
}

/// Shared spacing scale so padding/margins stay visually consistent.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Maximum content width for the centred page column.
  static const double contentMaxWidth = 880;
}

/// Shared corner radii.
abstract final class AppRadius {
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 10;
  static const double lg = 14;
  static const double xl = 18;
}
