import 'package:flutter/material.dart';
import '../../shared/theme/colors.dart';
import 'brand_colors.dart';

class BrandThemeExtension extends ThemeExtension<BrandThemeExtension> {
  final Color primaryColor;
  final Color cardBackground;
  final Color textColor;
  final Color textMuted;
  final Color borderColor;
  final Color scaffoldBackground;

  const BrandThemeExtension({
    required this.primaryColor,
    required this.cardBackground,
    required this.textColor,
    required this.textMuted,
    required this.borderColor,
    required this.scaffoldBackground,
  });

  factory BrandThemeExtension.light() => const BrandThemeExtension(
        primaryColor: BrandColors.primary,
        cardBackground: SharedColors.surfaceLight,
        textColor: SharedColors.textPrimaryLight,
        textMuted: SharedColors.textSecondaryLight,
        borderColor: SharedColors.borderLight,
        scaffoldBackground: SharedColors.backgroundLight,
      );

  factory BrandThemeExtension.dark() => const BrandThemeExtension(
        primaryColor: BrandColors.primary,
        cardBackground: SharedColors.surfaceDark,
        textColor: SharedColors.textPrimaryDark,
        textMuted: SharedColors.textSecondaryDark,
        borderColor: SharedColors.borderDark,
        scaffoldBackground: SharedColors.backgroundDark,
      );

  @override
  ThemeExtension<BrandThemeExtension> copyWith({
    Color? primaryColor,
    Color? cardBackground,
    Color? textColor,
    Color? textMuted,
    Color? borderColor,
    Color? scaffoldBackground,
  }) {
    return BrandThemeExtension(
      primaryColor: primaryColor ?? this.primaryColor,
      cardBackground: cardBackground ?? this.cardBackground,
      textColor: textColor ?? this.textColor,
      textMuted: textMuted ?? this.textMuted,
      borderColor: borderColor ?? this.borderColor,
      scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
    );
  }

  @override
  ThemeExtension<BrandThemeExtension> lerp(
      covariant ThemeExtension<BrandThemeExtension>? other, double t) {
    if (other is! BrandThemeExtension) {
      return this;
    }
    return BrandThemeExtension(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      scaffoldBackground: Color.lerp(scaffoldBackground, other.scaffoldBackground, t)!,
    );
  }
}
