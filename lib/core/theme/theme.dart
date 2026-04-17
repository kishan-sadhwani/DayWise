import 'package:flutter/material.dart';
import '../../shared/theme/colors.dart';
import '../../shared/theme/typography.dart';
import '../../branding/theme/brand_theme.dart';

class AppTheme {
  static ThemeData get light {
    final extensions = [BrandThemeExtension.light()];
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: SharedColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: SharedColors.textPrimaryLight,
        surface: SharedColors.surfaceLight,
      ),
      textTheme: const TextTheme(
        displayLarge: SharedTypography.title,
        bodyLarge: SharedTypography.body,
        bodyMedium: SharedTypography.caption,
      ).apply(
        bodyColor: SharedColors.textPrimaryLight,
        displayColor: SharedColors.textPrimaryLight,
      ),
      extensions: extensions,
    );
  }

  static ThemeData get dark {
    final extensions = [BrandThemeExtension.dark()];
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SharedColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: SharedColors.textPrimaryDark,
        surface: SharedColors.surfaceDark,
      ),
      textTheme: const TextTheme(
        displayLarge: SharedTypography.title,
        bodyLarge: SharedTypography.body,
        bodyMedium: SharedTypography.caption,
      ).apply(
        bodyColor: SharedColors.textPrimaryDark,
        displayColor: SharedColors.textPrimaryDark,
      ),
      extensions: extensions,
    );
  }
}
