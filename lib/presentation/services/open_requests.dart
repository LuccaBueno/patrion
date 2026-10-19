import 'package:flutter/foundation.dart';

/// Arquivos `.invsave` que o app recebeu para abrir (duplo clique no
/// Explorador ou encaminhados por uma segunda instância; DECISIONS D-39).
///
/// Vive fora da sessão do banco: o pedido espera o desbloqueio, se o
/// bloqueio estiver ativo, e a tela de Sincronização o consome.
class OpenRequests extends ChangeNotifier {
  final _pending = <String>[];

  bool get hasPending => _pending.isNotEmpty;

  void addAll(Iterable<String> files) {
    final before = _pending.length;
    _pending.addAll(files);
    if (_pending.length != before) notifyListeners();
  }

  /// Retira o próximo arquivo da fila.
  String? take() => _pending.isEmpty ? null : _pending.removeAt(0);
}
