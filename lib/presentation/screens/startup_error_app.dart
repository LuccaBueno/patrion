import 'package:flutter/material.dart';

import '../../core/config/app_info.dart';
import '../theme/app_theme.dart';

/// Tela mostrada quando o app não consegue iniciar (pasta de dados
/// inacessível, banco corrompido, argumento inválido).
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({required this.message, this.logsDir, super.key});

  final String message;
  final String? logsDir;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'O ${AppInfo.name} não conseguiu iniciar',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  SelectableText(message),
                  if (logsDir != null) ...[
                    const SizedBox(height: 16),
                    SelectableText('Detalhes no log: $logsDir'),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
