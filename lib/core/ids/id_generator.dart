import 'package:uuid/uuid.dart';

/// Gera identificadores dos registros sincronizáveis: UUID v7 em texto
/// minúsculo com hífens (DECISIONS D-10).
///
/// O UUID v7 começa pelo instante em milissegundos, então ids criados depois
/// tendem a ordenar depois, o que ajuda os índices do SQLite. A identidade não
/// depende dessa ordem: quem ordena alterações é o HLC.
class IdGenerator {
  const IdGenerator();

  static const _uuid = Uuid();

  String newId() => _uuid.v7();

  static final _v7Pattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  /// Indica se [id] é um UUID v7 no formato canônico do app.
  static bool isValid(String id) => _v7Pattern.hasMatch(id);
}
