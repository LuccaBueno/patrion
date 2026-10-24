/// Dados fixos do app.
///
/// [version] acompanha o `version` do `pubspec.yaml` (um teste confere).
abstract final class AppInfo {
  static const name = 'Patrion';
  static const subtitle = 'Investimentos e Patrimônio';
  static const version = '1.4.0';

  /// Repositório do GitHub com as Releases, no formato `dono/nome`. É o
  /// único lugar do código com o repositório (SPEC §19; DECISIONS D-07).
  static const releasesRepository = 'LuccaBueno/patrion';

  /// Página das Releases, para quem quiser baixar manualmente.
  static const releasesPage = 'https://github.com/$releasesRepository/releases';
}
