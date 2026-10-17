/// Preferência que vale em todos os PCs e vai no save (SPEC §10.1).
///
/// O valor é JSON em texto; quem usa a preferência interpreta o conteúdo.
class SharedSetting {
  const SharedSetting({
    required this.id,
    required this.key,
    required this.valueJson,
  });

  final String id;
  final String key;
  final String valueJson;
}
