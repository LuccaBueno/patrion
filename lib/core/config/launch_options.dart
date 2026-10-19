/// Opções de linha de comando do app (DECISIONS D-05 e D-39).
///
/// - `--data-dir <pasta>`: troca a pasta de dados (banco, backups e logs).
/// - `--cache-dir <pasta>`: troca a pasta de cache.
/// - Qualquer outro argumento que não comece com `-` é um arquivo para abrir
///   (o Windows passa o caminho do `.invsave` no duplo clique).
///
/// Também aceita a forma `--data-dir=<pasta>`. Opções desconhecidas são
/// ignoradas, para não impedir a abertura do app.
class LaunchOptions {
  const LaunchOptions({this.dataDir, this.cacheDir, this.files = const []});

  factory LaunchOptions.parse(List<String> args) {
    String? dataDir;
    String? cacheDir;
    final files = <String>[];
    for (var i = 0; i < args.length; i++) {
      final arg = args[i];
      var matched = false;
      for (final name in const ['--data-dir', '--cache-dir']) {
        String? value;
        if (arg == name) {
          if (i + 1 >= args.length) {
            throw FormatException('Falta a pasta depois de $name');
          }
          value = args[++i];
        } else if (arg.startsWith('$name=')) {
          value = arg.substring(name.length + 1);
        }
        if (value == null) continue;
        matched = true;
        if (value.trim().isEmpty) {
          throw FormatException('Pasta vazia em $name');
        }
        if (name == '--data-dir') {
          dataDir = value;
        } else {
          cacheDir = value;
        }
      }
      if (!matched && !arg.startsWith('-') && arg.trim().isNotEmpty) {
        files.add(arg);
      }
    }
    return LaunchOptions(
      dataDir: dataDir,
      cacheDir: cacheDir,
      files: List.unmodifiable(files),
    );
  }

  final String? dataDir;
  final String? cacheDir;

  /// Arquivos para abrir, na ordem recebida.
  final List<String> files;
}
