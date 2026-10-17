/// Hybrid Logical Clock (DECISIONS D-10).
///
/// Um HLC combina o relógio físico (milissegundos UTC) com um contador
/// lógico. Ele cresce sempre, mesmo que o relógio do PC volte no tempo, e
/// avança ao receber um HLC maior de outro dispositivo. Isso permite ordenar
/// alterações feitas em PCs diferentes mesmo com relógios dessincronizados
/// (SPEC §10.4).
///
/// Formato em texto, ordenável lexicograficamente:
/// `<ms UTC com 15 dígitos>-<contador com 5 dígitos>-<device_id>`.
/// A comparação de texto já resolve o empate pelo `device_id`.
library;

class Hlc implements Comparable<Hlc> {
  const Hlc(this.millis, this.counter, this.deviceId)
    : assert(millis >= 0 && millis <= maxMillis),
      assert(counter >= 0 && counter <= maxCounter);

  /// HLC inicial de um dispositivo que nunca emitiu nenhum.
  const Hlc.zero(String deviceId) : this(0, 0, deviceId);

  /// Interpreta o texto gerado por [toString].
  ///
  /// Lança [FormatException] se o texto não seguir o formato.
  factory Hlc.parse(String text) {
    final match = _pattern.firstMatch(text);
    if (match == null) {
      throw FormatException('HLC inválido', text);
    }
    return Hlc(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      match.group(3)!,
    );
  }

  /// Maior instante representável com 15 dígitos (ano ~33658).
  static const int maxMillis = 999999999999999;

  /// Maior contador representável com 5 dígitos.
  static const int maxCounter = 99999;

  static final _pattern = RegExp(r'^(\d{15})-(\d{5})-(.+)$');

  final int millis;
  final int counter;
  final String deviceId;

  @override
  int compareTo(Hlc other) {
    final byMillis = millis.compareTo(other.millis);
    if (byMillis != 0) return byMillis;
    final byCounter = counter.compareTo(other.counter);
    if (byCounter != 0) return byCounter;
    return deviceId.compareTo(other.deviceId);
  }

  bool operator <(Hlc other) => compareTo(other) < 0;
  bool operator >(Hlc other) => compareTo(other) > 0;

  @override
  bool operator ==(Object other) =>
      other is Hlc &&
      other.millis == millis &&
      other.counter == counter &&
      other.deviceId == deviceId;

  @override
  int get hashCode => Object.hash(millis, counter, deviceId);

  @override
  String toString() =>
      '${millis.toString().padLeft(15, '0')}-'
      '${counter.toString().padLeft(5, '0')}-'
      '$deviceId';
}

/// Emite HLCs para um dispositivo.
///
/// Não é seguro para uso concorrente entre isolates: o app tem um único
/// relógio por banco, guardado pela camada de dados (`dev_identity.last_hlc`).
class HlcClock {
  HlcClock({required this.deviceId, required this._nowMillis, Hlc? last})
    : _last = last == null
          ? Hlc.zero(deviceId)
          : Hlc(last.millis, last.counter, deviceId);

  final String deviceId;
  final int Function() _nowMillis;
  Hlc _last;

  /// Último HLC emitido ou recebido por este relógio.
  Hlc get last => _last;

  /// HLC para uma alteração local.
  Hlc send() {
    final wall = _nowMillis();
    if (wall > _last.millis) {
      _last = Hlc(wall, 0, deviceId);
    } else {
      _last = _increment(_last.millis, _last.counter);
    }
    return _last;
  }

  /// Ajusta o relógio ao receber o HLC [remote] de outro dispositivo e
  /// devolve o novo HLC local, maior que ambos.
  ///
  /// Um relógio remoto adiantado puxa este relógio para a frente: as próximas
  /// alterações locais continuam vencendo as anteriores (SPEC §10.4,
  /// "relógios").
  Hlc receive(Hlc remote) {
    final wall = _nowMillis();
    final millis = [
      wall,
      _last.millis,
      remote.millis,
    ].reduce((a, b) => a > b ? a : b);
    if (millis == _last.millis && millis == remote.millis) {
      final counter = _last.counter > remote.counter
          ? _last.counter
          : remote.counter;
      _last = _increment(millis, counter);
    } else if (millis == _last.millis) {
      _last = _increment(millis, _last.counter);
    } else if (millis == remote.millis) {
      _last = _increment(millis, remote.counter);
    } else {
      _last = Hlc(millis, 0, deviceId);
    }
    return _last;
  }

  /// Próximo HLC depois de (millis, counter). Se o contador estourar os 5
  /// dígitos, avança 1 ms e zera o contador: a ordem continua estrita.
  Hlc _increment(int millis, int counter) {
    if (counter < Hlc.maxCounter) return Hlc(millis, counter + 1, deviceId);
    return Hlc(millis + 1, 0, deviceId);
  }
}
