import 'package:flutter/material.dart';

/// Cores da marca (SPEC §16, DECISIONS D-18).
///
/// Elas aparecem em pouco lugar: o esmeralda só em destaques (item
/// selecionado, botão principal, foco, toggles, links) e o dourado só no
/// símbolo, no nome PATRION e, no máximo, em um destaque por tela.
abstract final class BrandColors {
  /// Verde-esmeralda da marca (símbolo, botão principal no tema claro).
  static const emerald = Color(0xFF1F6B4F);

  /// Dourado da marca. Nunca em texto comum nem em dado.
  static const gold = Color(0xFFC9A86A);
}

/// Tons neutros de cada tema: sem matiz verde (DECISIONS D-18).
class NeutralPalette {
  const NeutralPalette({
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.border,
    required this.text,
    required this.textSecondary,
  });

  static const dark = NeutralPalette(
    background: Color(0xFF0F1113),
    surface: Color(0xFF16191C),
    surfaceRaised: Color(0xFF1D2125),
    border: Color(0xFF2A2F34),
    text: Color(0xFFECEDEE),
    textSecondary: Color(0xFF9BA1A6),
  );

  static const light = NeutralPalette(
    background: Color(0xFFF4F5F6),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFECEEF0),
    border: Color(0xFFD9DDE1),
    text: Color(0xFF16191C),
    textSecondary: Color(0xFF565C61),
  );

  /// Fundo da janela.
  final Color background;

  /// Cartões e navegação lateral.
  final Color surface;

  /// Elementos sobre uma superfície (campos, menus, diálogos).
  final Color surfaceRaised;

  /// Bordas e divisórias sutis.
  final Color border;

  final Color text;
  final Color textSecondary;
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
    gain: Color(0xFF167A33),
    loss: Color(0xFFB3261E),
    hypothetical: Color(0xFF6A4FB3),
    brandAccent: Color(0xFF7E6329),
  );

  static const dark = SemanticColors(
    gain: Color(0xFF4ADE6F),
    loss: Color(0xFFFF7B72),
    hypothetical: Color(0xFFB9A6F2),
    brandAccent: BrandColors.gold,
  );

  /// Verde de ganho: mais amarelado e saturado que o esmeralda da marca,
  /// para não ser confundido com um destaque de interface.
  final Color gain;
  final Color loss;

  /// Identidade visual das telas de simulação (SPEC §16).
  final Color hypothetical;

  /// Dourado legível no tema (no claro, um tom mais escuro). Só para o
  /// símbolo, o nome PATRION e no máximo um destaque por tela.
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
  /// Esquema do tema escuro. O esmeralda fica mais claro que o da marca para
  /// ter contraste sobre o fundo quase preto; o texto sobre ele é escuro.
  static final ColorScheme darkScheme = _scheme(
    brightness: Brightness.dark,
    n: NeutralPalette.dark,
    primary: const Color(0xFF3DAA80),
    onPrimary: const Color(0xFF0F1113),
    selection: const Color(0xFF1F6B4F),
    onSelection: const Color(0xFFECEDEE),
    error: const Color(0xFFFF7B72),
    onError: const Color(0xFF0F1113),
  );

  static final ColorScheme lightScheme = _scheme(
    brightness: Brightness.light,
    n: NeutralPalette.light,
    primary: BrandColors.emerald,
    onPrimary: const Color(0xFFFFFFFF),
    selection: const Color(0xFFD4EBE1),
    onSelection: const Color(0xFF0F3D2C),
    error: const Color(0xFFB3261E),
    onError: const Color(0xFFFFFFFF),
  );

  static ThemeData light() =>
      _base(lightScheme, NeutralPalette.light, SemanticColors.light);

  static ThemeData dark() =>
      _base(darkScheme, NeutralPalette.dark, SemanticColors.dark);

  /// Monta o esquema à mão, sem `ColorScheme.fromSeed`: a geração a partir
  /// da semente tinge fundos e superfícies com a cor da marca.
  static ColorScheme _scheme({
    required Brightness brightness,
    required NeutralPalette n,
    required Color primary,
    required Color onPrimary,
    required Color selection,
    required Color onSelection,
    required Color error,
    required Color onError,
  }) {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      // Indicador do item selecionado, segmento escolhido, chips marcados.
      primaryContainer: selection,
      onPrimaryContainer: onSelection,
      secondary: primary,
      onSecondary: onPrimary,
      secondaryContainer: selection,
      onSecondaryContainer: onSelection,
      // Terciária neutra: o dourado não entra em componentes automáticos.
      tertiary: n.textSecondary,
      onTertiary: n.background,
      tertiaryContainer: n.surfaceRaised,
      onTertiaryContainer: n.text,
      error: error,
      onError: onError,
      errorContainer: n.surfaceRaised,
      onErrorContainer: error,
      surface: n.background,
      onSurface: n.text,
      onSurfaceVariant: n.textSecondary,
      surfaceDim: n.background,
      surfaceBright: n.surfaceRaised,
      surfaceContainerLowest: n.background,
      surfaceContainerLow: n.surface,
      surfaceContainer: n.surface,
      surfaceContainerHigh: n.surfaceRaised,
      surfaceContainerHighest: n.surfaceRaised,
      outline: n.border,
      outlineVariant: n.border,
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      inverseSurface: n.text,
      onInverseSurface: n.background,
      inversePrimary: primary,
      // Sem tinta de elevação: ela também esverdearia as superfícies.
      surfaceTint: const Color(0x00000000),
    );
  }

  static ThemeData _base(
    ColorScheme scheme,
    NeutralPalette n,
    SemanticColors semantic,
  ) {
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: n.background,
      canvasColor: n.background,
      dividerColor: n.border,
      visualDensity: VisualDensity.standard,
      extensions: [semantic],
      dividerTheme: DividerThemeData(color: n.border, space: 1, thickness: 1),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: n.surface,
        indicatorColor: scheme.secondaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.onSecondaryContainer),
        unselectedIconTheme: IconThemeData(color: n.textSecondary),
        selectedLabelTextStyle: TextStyle(
          color: n.text,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TextStyle(color: n.textSecondary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: n.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: n.border),
        ),
      ),
      iconTheme: IconThemeData(color: n.textSecondary),
      listTileTheme: ListTileThemeData(
        iconColor: n.textSecondary,
        subtitleTextStyle: TextStyle(color: n.textSecondary),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStatePropertyAll(BorderSide(color: n.border)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: n.surfaceRaised,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: n.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: n.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: n.surfaceRaised,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: n.border),
        ),
        textStyle: TextStyle(color: n.text),
      ),
    );
  }
}
