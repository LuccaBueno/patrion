import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/ids/id_generator.dart';

void main() {
  const ids = IdGenerator();

  test('gera UUID v7 minúsculo com hífens', () {
    final id = ids.newId();
    expect(IdGenerator.isValid(id), isTrue, reason: id);
    expect(id, id.toLowerCase());
    expect(id[14], '7');
  });

  test('não repete em 10 mil gerações', () {
    final set = {for (var i = 0; i < 10000; i++) ids.newId()};
    expect(set.length, 10000);
  });

  test('isValid recusa outros formatos', () {
    expect(IdGenerator.isValid('7d444840-9dc0-11d1-b245-5ffdce74fad2'), false);
    expect(IdGenerator.isValid('0192A2B3-0000-7000-8000-000000000000'), false);
    expect(IdGenerator.isValid('1'), false);
  });
}
