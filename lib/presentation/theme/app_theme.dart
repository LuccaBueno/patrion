import 'package:flutter/material.dart';

/// Paleta da marca (SPEC §16, DECISIONS D-13).
abstract final class BrandColors {
  /// Verde quase preto: fundo do tema escuro e do símbolo.
  static const background = Color(0xFF0E1A16);

  /// Verde-esmeralda: cor primária.
  static const emerald = Color(0xFF1F6B4F);

  /// Verde-esmeralda claro: faces iluminadas do símbolo.
  static const emeraldLight = Color(0xFF2A8A64);

  /// Dourado: cor de marca, nunca de dado (ganho/perda têm cores próprias).
  static const gold = Color(0xFFC9A86A);

  /// Marfim: texto sobre o fundo escuro.
  static const ivory = Color(0xFFF2E9D8);
}

/// Cores com significado, ajustadas a cada tema.
///
/// A cor nunca é o único indicador (SPEC §16): ganho e perda também levam
/// sinal e ícone, e telas de simulação levam o rótulo "Hipotético".
@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  const SemanticColors({
    required this.gain,
    required this.loss,
    required this.hypothetical,
    required this.brandAccent,
  });

  static const light = SemanticColors(
    gain: Color(0xFF1B7F4B),
    loss: Color(0xFFB3261E),
    hypothetical: Color(0xFF6A4FB3),
    brandAccent: Color(0xFF8A6D2F),
  );

  static const dark = SemanticColors(
    gain: Color(0xFF6FD39B),
    loss: Color(0xFFFF8A80),
    hypothetical: Color(0xFFB9A6F2),
    brandAccent: BrandColors.gold,
  );

  final Color gain;
  final Color loss;

  /// Identidade visual das telas de simulação (SPEC §16).
  final Color hypothetical;

  /// Dourado legível no tema (no claro, um tom mais escuro).
  final Color brandAccent;

  static SemanticColors of(BuildContext context) =>
      Theme.of(context).extension<SemanticColors>()!;

  @override
  SemanticColors copyWith({
    Color? gain,
    Color? loss,
    Color? hypothetical,
    Color? brandAccent,
  }) => SemanticColors(
    gain: gain ?? this.gain,
    loss: loss ?? this.loss,
    hypothetical: hypothetical ?? this.hypothetical,
    brandAccent: brandAccent ?? this.brandAccent,
  );

  @override
  SemanticColors lerp(SemanticColors? other, double t) {
    if (other == null) return this;
    return SemanticColors(
      gain: Color.lerp(gain, other.gain, t)!,
      loss: Color.lerp(loss, other.loss, t)!,
      hypothetical: Color.lerp(hypothetical, other.hypothetical, t)!,
      brandAccent: Color.lerp(brandAccent, other.brandAccent, t)!,
    );
  }
}

abstract final class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: BrandColors.emerald,
      brightness: Brightness.light,
    ).copyWith(primary: BrandColors.emerald, tertiary: const Color(0xFF8A6D2F));
    return _base(scheme, SemanticColors.light);
  }

  static ThemeData dark() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: BrandColors.emerald,
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF7FD3AE),
          tertiary: BrandColors.gold,
          surface: BrandColors.background,
          onSurface: BrandColors.ivory,
          surfaceContainerLowest: const Color(0xFF0A1411),
          surfaceContainerLow: const Color(0xFF12211C),
          surfaceContainer: const Color(0xFF162720),
          surfaceContainerHigh: const Color(0xFF1B2E27),
          surfaceContainerHighest: const Color(0xFF21362E),
        );
    return _base(scheme, SemanticColors.dark);
  }

  static ThemeData _base(ColorScheme scheme, SemanticColors semantic) {
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      visualDensity: VisualDensity.standard,
      extensions: [semantic],
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.secondaryContainer,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
