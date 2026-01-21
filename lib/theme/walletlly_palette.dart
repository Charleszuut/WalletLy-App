import 'package:flutter/material.dart';

@immutable
class WalletllyPalette extends ThemeExtension<WalletllyPalette> {
  const WalletllyPalette({
    required this.primaryDark,
    required this.primaryBase,
    required this.primaryLight,
    required this.accent,
    required this.accentSoft,
    required this.success,
    required this.successContainer,
    required this.error,
    required this.errorSoft,
  });

  final Color primaryDark;
  final Color primaryBase;
  final Color primaryLight;
  final Color accent;
  final Color accentSoft;
  final Color success;
  final Color successContainer;
  final Color error;
  final Color errorSoft;

  static WalletllyPalette of(BuildContext context) =>
      Theme.of(context).extension<WalletllyPalette>()!;

  @override
  WalletllyPalette copyWith({
    Color? primaryDark,
    Color? primaryBase,
    Color? primaryLight,
    Color? accent,
    Color? accentSoft,
    Color? success,
    Color? successContainer,
    Color? error,
    Color? errorSoft,
  }) {
    return WalletllyPalette(
      primaryDark: primaryDark ?? this.primaryDark,
      primaryBase: primaryBase ?? this.primaryBase,
      primaryLight: primaryLight ?? this.primaryLight,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      error: error ?? this.error,
      errorSoft: errorSoft ?? this.errorSoft,
    );
  }

  @override
  WalletllyPalette lerp(WalletllyPalette? other, double t) {
    if (other == null) return this;
    return WalletllyPalette(
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryBase: Color.lerp(primaryBase, other.primaryBase, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      error: Color.lerp(error, other.error, t)!,
      errorSoft: Color.lerp(errorSoft, other.errorSoft, t)!,
    );
  }
}
