import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/presentation/theme/app_theme.dart';

/// Regras de cor da SPEC §16 e da DECISIONS D-18.
void main() {
  double luminance(Color c) => c.computeLuminance();

  double contrast(Color a, Color b) {
    final la = luminance(a), lb = luminance(b);
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  /// Diferença entre o maior e o menor canal (0 a 255). Zero = cinza puro.
  int chroma(Color c) {
    final channels = [c.r, c.g, c.b].map((v) => (v * 255).round());
    return channels.reduce(math.max) - channels.reduce(math.min);
  }

  final themes = {
    'escuro': (AppTheme.dark(), NeutralPalette.dark, SemanticColors.dark),
    'claro': (AppTheme.light(), NeutralPalette.light, SemanticColors.light),
  };

  for (final MapEntry(key: name, value: (theme, n, semantic))
      in themes.entries) {
    group('tema $name', () {
      final s = theme.colorScheme;

      test('fundos, superfícies, bordas e textos são neutros', () {
        for (final c in [
          n.background,
          n.surface,
          n.surfaceRaised,
          n.border,
          n.text,
          n.textSecondary,
          s.surface,
          s.surfaceContainerLow,
          s.surfaceContainer,
          s.surfaceContainerHigh,
          s.surfaceContainerHighest,
          s.outline,
          s.outlineVariant,
          theme.scaffoldBackgroundColor,
        ]) {
          // Até 12 de 255 (tons grafite levemente frios); verde nenhum.
          expect(chroma(c), lessThanOrEqualTo(12), reason: '$c');
          expect(
            (c.g * 255).round() - (c.r * 255).round(),
            lessThanOrEqualTo(6),
            reason: 'tom verde em $c',
          );
        }
      });

      test('sem tinta de elevação', () {
        expect(s.surfaceTint.a, 0);
      });

      test('o dourado não entra nos componentes automáticos', () {
        expect(s.tertiary, isNot(BrandColors.gold));
        expect(s.primary, isNot(BrandColors.gold));
        expect(s.secondary, isNot(BrandColors.gold));
      });

      test('contrastes mínimos (WCAG AA)', () {
        expect(contrast(n.text, n.background), greaterThanOrEqualTo(7));
        expect(contrast(n.text, n.surface), greaterThanOrEqualTo(7));
        expect(
          contrast(n.textSecondary, n.background),
          greaterThanOrEqualTo(4.5),
        );
        expect(contrast(n.textSecondary, n.surface), greaterThanOrEqualTo(4.5));
        expect(contrast(s.onPrimary, s.primary), greaterThanOrEqualTo(4.5));
        expect(
          contrast(s.onSecondaryContainer, s.secondaryContainer),
          greaterThanOrEqualTo(4.5),
        );
        expect(contrast(s.primary, n.background), greaterThanOrEqualTo(3));
        for (final c in [semantic.gain, semantic.loss, semantic.hypothetical]) {
          expect(
            contrast(c, n.surface),
            greaterThanOrEqualTo(4.5),
            reason: '$c',
          );
        }
        expect(
          contrast(semantic.brandAccent, n.background),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('ganho é distinguível do verde da marca', () {
        final gain = HSLColor.fromColor(semantic.gain);
        final primary = HSLColor.fromColor(s.primary);
        final hueDiff = (gain.hue - primary.hue).abs();
        final satDiff = (gain.saturation - primary.saturation).abs();
        expect(
          hueDiff >= 12 || satDiff >= 0.25,
          isTrue,
          reason: 'ganho ${semantic.gain} x primária ${s.primary}',
        );
      });
    });
  }
}
