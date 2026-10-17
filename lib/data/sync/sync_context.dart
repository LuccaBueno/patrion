import 'package:clock/clock.dart';

import '../../core/ids/id_generator.dart';
import '../../core/sync/hlc.dart';
import '../../core/time/instant_format.dart';
import 'device_identity_store.dart';

/// Carimbo de uma escrita: instante, HLC e dispositivo.
class SyncStamp {
  const SyncStamp({required this.at, required this.hlc});

  /// Instante UTC já formatado (ISO-8601 com ms).
  final String at;
  final Hlc hlc;

  String get deviceId => hlc.deviceId;
}

/// Tudo o que um repositório precisa para preencher os campos de
/// sincronização: ids, relógio físico, HLC e dispositivo.
///
/// Há uma instância por banco aberto.
class SyncContext {
  SyncContext({
    required DeviceIdentity identity,
    required this._store,
    Clock wallClock = const Clock(),
    this._ids = const IdGenerator(),
  }) : _wallClock = wallClock,
       _hlc = HlcClock(
         deviceId: identity.deviceId,
         nowMillis: () => wallClock.now().millisecondsSinceEpoch,
         last: identity.lastHlc,
       );

  final DeviceIdentityStore _store;
  final Clock _wallClock;
  final IdGenerator _ids;
  final HlcClock _hlc;

  String get deviceId => _hlc.deviceId;

  /// Último HLC emitido ou recebido.
  Hlc get lastHlc => _hlc.last;

  String newId() => _ids.newId();

  /// Avança o HLC para uma escrita local e grava o último HLC no banco.
  ///
  /// Deve ser chamado dentro da transação da escrita: se ela falhar, o HLC
  /// gravado volta junto. O HLC em memória pode ter avançado mesmo assim,
  /// o que é inofensivo (só pula valores).
  Future<SyncStamp> nextStamp() async {
    final hlc = _hlc.send();
    await _store.saveLastHlc(hlc);
    return SyncStamp(at: formatInstant(_wallClock.now()), hlc: hlc);
  }

  /// Ajusta o HLC ao receber um registro de outro dispositivo (save, F5).
  Future<Hlc> receive(Hlc remote) async {
    final hlc = _hlc.receive(remote);
    await _store.saveLastHlc(hlc);
    return hlc;
  }
}
