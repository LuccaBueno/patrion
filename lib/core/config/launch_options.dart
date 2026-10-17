/// Opções de linha de comando do app (DECISIONS D-05).
///
/// - `--data-dir <pasta>`: troca a pasta de dados (banco, backups e logs).
/// - `--cache-dir <pasta>`: troca a pasta de cache.
///
/// Também aceita a forma `--data-dir=<pasta>`. Argumentos desconhecidos são
/// ignorados, para não impedir a abertura do app (por exemplo, um `.invsave`
/// passado pelo Windows na F7).
class LaunchOptions {
  const LaunchOptions({this.dataDir, this.cacheDir});

  factory LaunchOptions.parse(List<String> args) {
    String? dataDir;
    String? cacheDir;
    for (var i = 0; i < args.length; i++) {
      final arg = args[i];
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
        if (value.trim().isEmpty) {
          throw FormatException('Pasta vazia em $name');
        }
        if (name == '--data-dir') {
          dataDir = value;
        } else {
          cacheDir = value;
        }
      }
    }
    return LaunchOptions(dataDir: dataDir, cacheDir: cacheDir);
  }

  final String? dataDir;
  final String? cacheDir;
}
