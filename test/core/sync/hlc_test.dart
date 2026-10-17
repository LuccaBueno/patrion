import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/sync/hlc.dart';

const devA = '01920000-0000-7000-8000-00000000000a';
const devB = '01920000-0000-7000-8000-00000000000b';

/// Relógio de parede controlado pelo teste.
class FakeWall {
  FakeWall(this.millis);

  int millis;

  int call() => millis;
}

void main() {
  group('Hlc: texto', () {
    test('formato com 15 dígitos de ms, 5 de contador e device_id', () {
      const hlc = Hlc(1760722200000, 7, devA);
      expect(hlc.toString(), '001760722200000-00007-$devA');
    });

    test('parse é o inverso de toString', () {
      const hlc = Hlc(1760722200123, 99999, devB);
      expect(Hlc.parse(hlc.toString()), hlc);
    });

    test('parse recusa texto fora do formato', () {
      for (final text in [
        '',
        '1760722200000-00007-$devA',
        '001760722200000-7-$devA',
        '001760722200000-00007-',
        'abc',
      ]) {
        expect(() => Hlc.parse(text), throwsFormatException, reason: text);
      }
    });

    test('ordem do texto é a mesma da comparação', () {
      final values = [
        const Hlc(5, 0, devB),
        const Hlc(1760722200000, 1, devA),
        const Hlc(1760722200000, 0, devB),
        const Hlc(1760722200000, 0, devA),
        const Hlc(999, 99999, devA),
        const Hlc(1000, 0, devA),
      ];
      final byCompare = [...values]..sort();
      final byText = [...values]
        ..sort((a, b) => a.toString().compareTo(b.toString()));
      expect(byText, byCompare);
    });

    test('empate de ms e contador é decidido pelo device_id', () {
      expect(const Hlc(10, 1, devA) < const Hlc(10, 1, devB), isTrue);
      expect(const Hlc(10, 2, devA) > const Hlc(10, 1, devB), isTrue);
    });
  });

  group('HlcClock.send', () {
    test('usa o relógio físico quando ele avança', () {
      final wall = FakeWall(1000);
      final clock = HlcClock(deviceId: devA, nowMillis: wall.call);
      expect(clock.send(), const Hlc(1000, 0, devA));
      wall.millis = 2000;
      expect(clock.send(), const Hlc(2000, 0, devA));
    });

    test('mesmo milissegundo incrementa o contador', () {
      final wall = FakeWall(1000);
      final clock = HlcClock(deviceId: devA, nowMillis: wall.call);
      expect(clock.send(), const Hlc(1000, 0, devA));
      expect(clock.send(), const Hlc(1000, 1, devA));
      expect(clock.send(), const Hlc(1000, 2, devA));
    });

    test('relógio que volta no tempo não faz o HLC diminuir', () {
      final wall = FakeWall(5000);
      final clock = HlcClock(deviceId: devA, nowMillis: wall.call);
      final first = clock.send();
      wall.millis = 1000; // relógio do Windows ajustado para trás
      final second = clock.send();
      final third = clock.send();
      expect(second > first, isTrue);
      expect(third > second, isTrue);
      expect(second, const Hlc(5000, 1, devA));
    });

    test('estouro do contador avança 1 ms', () {
      final wall = FakeWall(1000);
      final clock = HlcClock(
        deviceId: devA,
        nowMillis: wall.call,
        last: const Hlc(1000, Hlc.maxCounter, devA),
      );
      expect(clock.send(), const Hlc(1001, 0, devA));
    });

    test('continua crescendo a partir do último HLC salvo', () {
      final wall = FakeWall(1000);
      final clock = HlcClock(
        deviceId: devA,
        nowMillis: wall.call,
        last: const Hlc(9000, 3, devA),
      );
      expect(clock.send(), const Hlc(9000, 4, devA));
    });

    test('mil emissões seguidas são estritamente crescentes', () {
      final wall = FakeWall(1000);
      final clock = HlcClock(deviceId: devA, nowMillis: wall.call);
      var previous = clock.send();
      for (var i = 0; i < 1000; i++) {
        if (i % 7 == 0) wall.millis += 1;
        if (i % 50 == 0) wall.millis -= 20;
        final next = clock.send();
        expect(next > previous, isTrue);
        previous = next;
      }
    });
  });

  group('HlcClock.receive', () {
    test('HLC remoto adiantado puxa o relógio local', () {
      final wall = FakeWall(1000);
      final clock = HlcClock(deviceId: devA, nowMillis: wall.call);
      clock.send();
      final remote = const Hlc(50000, 3, devB); // PC B com relógio adiantado
      final received = clock.receive(remote);
      expect(received, const Hlc(50000, 4, devA));
      expect(received > remote, isTrue);
      // A próxima alteração local vence a remota mesmo com o relógio atrasado.
      final local = clock.send();
      expect(local > remote, isTrue);
    });

    test('HLC remoto atrasado não faz o relógio local voltar', () {
      final wall = FakeWall(1000);
      final clock = HlcClock(
        deviceId: devA,
        nowMillis: wall.call,
        last: const Hlc(9000, 5, devA),
      );
      expect(clock.receive(const Hlc(10, 0, devB)), const Hlc(9000, 6, devA));
    });

    test('mesmo ms local e remoto usa o maior contador', () {
      final wall = FakeWall(10);
      final clock = HlcClock(
        deviceId: devA,
        nowMillis: wall.call,
        last: const Hlc(9000, 2, devA),
      );
      expect(clock.receive(const Hlc(9000, 8, devB)), const Hlc(9000, 9, devA));
    });

    test('relógio físico à frente de ambos zera o contador', () {
      final wall = FakeWall(20000);
      final clock = HlcClock(
        deviceId: devA,
        nowMillis: wall.call,
        last: const Hlc(9000, 2, devA),
      );
      expect(
        clock.receive(const Hlc(9500, 8, devB)),
        const Hlc(20000, 0, devA),
      );
    });

    test('dois PCs com relógios dessincronizados ordenam a causalidade', () {
      final wallA = FakeWall(100000); // PC A adiantado
      final wallB = FakeWall(1000); // PC B atrasado
      final a = HlcClock(deviceId: devA, nowMillis: wallA.call);
      final b = HlcClock(deviceId: devB, nowMillis: wallB.call);

      final editA = a.send();
      b.receive(editA); // B importa o save de A
      final editB = b.send(); // B altera o mesmo registro depois
      expect(editB > editA, isTrue);

      a.receive(editB); // A importa o save de B
      final editA2 = a.send();
      expect(editA2 > editB, isTrue);
    });
  });
}
