import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/errors/app_error.dart';
import 'package:patrion/domain/sync/invsave_codec.dart';
import 'package:patrion/domain/sync/save_manifest.dart';

/// Formato do arquivo `.invsave` (SPEC §10.1).
void main() {
  const device = '0199f2a0-0000-7000-8000-000000000001';
  const hlc = '001760702400000-00001-$device';
  final row = {
    'id': 'r1',
    'created_at': '2026-10-17T12:00:00.000Z',
    'updated_at': '2026-10-17T12:00:00.000Z',
    'hlc': hlc,
    'device_id': device,
    'deleted_at': null,
    'key': 'moeda',
    'value_json': '"BRL"',
  };
  const manifest = SaveManifest(
    appVersion: '0.1.0',
    schemaVersion: 3,
    deviceId: device,
    deviceName: 'PC-A',
    createdAt: '2026-10-17T12:00:00.000Z',
    maxHlc: hlc,
    counts: {'shared_settings': 1, 'operations': 0},
  );

  test('ida e volta: mesmo conteúdo, com SHA-256 de cada arquivo', () {
    final bytes = InvsaveCodec.encode(manifest, {
      'shared_settings': [row],
      'operations': [],
    });
    final package = InvsaveCodec.decode(bytes);
    expect(package.tables['shared_settings'], [row]);
    expect(package.tables['operations'], isEmpty);
    expect(package.manifest.files.keys, {
      'data/operations.jsonl',
      'data/shared_settings.jsonl',
    });
    expect(package.manifest.encryption, 'none');
    expect(package.manifest.deviceName, 'PC-A');
  });

  Archive unzip(List<int> bytes) => ZipDecoder().decodeBytes(bytes);

  List<int> rezip(Archive archive, String name, List<int> content) {
    final out = Archive();
    for (final f in archive.files) {
      out.addFile(
        ArchiveFile.bytes(f.name, f.name == name ? content : f.readBytes()!),
      );
    }
    return ZipEncoder().encodeBytes(out);
  }

  test('conteúdo alterado (mesmo com ZIP válido) é recusado', () {
    final bytes = InvsaveCodec.encode(manifest, {
      'shared_settings': [row],
      'operations': [],
    });
    final archive = unzip(bytes);
    final changed = rezip(
      archive,
      'data/shared_settings.jsonl',
      utf8.encode('${jsonEncode({...row, 'value_json': '"USD"'})}\n'),
    );
    expect(
      () => InvsaveCodec.decode(changed),
      throwsA(
        isA<DataError>().having((e) => e.message, 'm', contains('checksum')),
      ),
    );
  });

  test('manifesto alterado sem atualizar o checksum é recusado', () {
    final bytes = InvsaveCodec.encode(manifest, {
      'shared_settings': [row],
      'operations': [],
    });
    final archive = unzip(bytes);
    final json = jsonDecode(
      utf8.decode(archive.findFile('manifest.json')!.readBytes()!),
    ) as Map<String, Object?>;
    final changed = rezip(
      archive,
      'manifest.json',
      utf8.encode(jsonEncode({...json, 'schemaVersion': 2})),
    );
    expect(() => InvsaveCodec.decode(changed), throwsA(isA<DataError>()));
  });

  test('formato mais novo e formato desconhecido são recusados', () {
    expect(
      () => SaveManifest.fromJson({...manifest.toJson(), 'formatVersion': 2}),
      throwsA(
        isA<DataError>().having((e) => e.message, 'm', contains('mais novo')),
      ),
    );
    expect(
      () => SaveManifest.fromJson({...manifest.toJson(), 'format': 'outro'}),
      throwsA(isA<DataError>()),
    );
  });

  test('contagem diferente da do manifesto é recusada', () {
    final wrong = SaveManifest(
      appVersion: manifest.appVersion,
      schemaVersion: manifest.schemaVersion,
      deviceId: manifest.deviceId,
      deviceName: manifest.deviceName,
      createdAt: manifest.createdAt,
      maxHlc: manifest.maxHlc,
      counts: const {'shared_settings': 2},
    );
    final bytes = InvsaveCodec.encode(wrong, {
      'shared_settings': [row],
    });
    expect(() => InvsaveCodec.decode(bytes), throwsA(isA<DataError>()));
  });
}
