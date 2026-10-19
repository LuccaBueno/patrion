import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:patrion/infrastructure/system/single_instance.dart';

void main() {
  late Directory dir;

  setUp(() async => dir = await Directory.systemTemp.createTemp('instance'));
  tearDown(() async {
    if (dir.existsSync()) await dir.delete(recursive: true);
  });

  const fast = Duration(milliseconds: 20);

  test('a segunda instância da mesma pasta não consegue a trava', () async {
    final first = await InstanceGate.acquire(dir.path, pollInterval: fast);
    expect(first, isNotNull);
    expect(await InstanceGate.acquire(dir.path), isNull);
    await first!.close();
    // Liberada a trava, outra instância pode abrir.
    final again = await InstanceGate.acquire(dir.path);
    expect(again, isNotNull);
    await again!.close();
  });

  test('pastas de dados diferentes abrem ao mesmo tempo', () async {
    final a = await InstanceGate.acquire(p.join(dir.path, 'a'));
    final b = await InstanceGate.acquire(p.join(dir.path, 'b'));
    expect(a, isNotNull);
    expect(b, isNotNull);
    await a!.close();
    await b!.close();
  });

  test('os arquivos encaminhados chegam à instância principal', () async {
    final gate = await InstanceGate.acquire(dir.path, pollInterval: fast);
    final received = gate!.requests.take(2).toList();
    final save = p.join(dir.path, 'Patrion_PC_2026-10-18.invsave');
    await InstanceGate.forward(dir.path, [save]);
    await InstanceGate.forward(dir.path, const []);
    expect(await received.timeout(const Duration(seconds: 5)), [
      [save],
      <String>[],
    ]);
    // O pedido lido é apagado.
    final inbox = Directory(p.join(dir.path, InstanceGate.inboxFolder));
    expect(inbox.listSync(), isEmpty);
    await gate.close();
  });

  test('pedidos antigos, de uma instância anterior, são descartados', () async {
    final inbox = Directory(p.join(dir.path, InstanceGate.inboxFolder))
      ..createSync(recursive: true);
    final old = File(p.join(inbox.path, '1-1.json'))
      ..writeAsStringSync('{"files":["C:\\\\velho.invsave"]}');
    old.setLastModifiedSync(DateTime.now().subtract(const Duration(hours: 1)));
    final gate = await InstanceGate.acquire(dir.path, pollInterval: fast);
    final got = <List<String>>[];
    final sub = gate!.requests.listen(got.add);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(got, isEmpty);
    expect(old.existsSync(), isFalse);
    await sub.cancel();
    await gate.close();
  });
}
