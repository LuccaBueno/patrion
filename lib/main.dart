import 'package:flutter/material.dart';

void main() {
  runApp(const PatrionApp());
}

/// App vazio da Fase 1. Camadas, tema e navegação chegam na Fase 2.
class PatrionApp extends StatelessWidget {
  const PatrionApp({super.key});

  // Paleta de partida (SPEC §16).
  static const _background = Color(0xFF0E1A16);
  static const _primary = Color(0xFF1F6B4F);
  static const _gold = Color(0xFFC9A86A);
  static const _ivory = Color(0xFFF2E9D8);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patrion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primary,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: _background,
      ),
      home: const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PATRION',
                style: TextStyle(
                  color: _gold,
                  fontSize: 48,
                  letterSpacing: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Investimentos e Patrimônio',
                style: TextStyle(color: _ivory, fontSize: 16, letterSpacing: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
