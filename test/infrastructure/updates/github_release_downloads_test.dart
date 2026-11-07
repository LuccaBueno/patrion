import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/application/updates/update_installer.dart';
import 'package:patrion/infrastructure/updates/github_release_downloads.dart';
import 'package:path/path.dart' as p;

import '../../helpers/fake_http.dart';

/// Corpo que entrega parte dos bytes e então falha, para.
class _BrokenAdapter implements HttpClientAdapter {
  _BrokenAdapter(this.body, this.total);

  final Stream<Uint8List> Function() body;
  final int total;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody(
    body(),
    200,
    headers: {
      'content-length': ['$total'],
    },
  );

  @override
  void close({bool force = false}) {}
}

const _release = 'https://github.com/dono/patrion/releases/download/v2.0.0';

void main() {
  late Directory dir;
  late FakeHttpAdapter http;
  late GitHubReleaseDownloads downloads;
  String target() => p.join(dir.path, 'a.part');

  setUp(() {
    dir = Directory.systemTemp.createTempSync('patrion_dl');
    http = FakeHttpAdapter();
    downloads = GitHubReleaseDownloads(
      dio: Dio()..httpClientAdapter = http,
      appVersion: '1.0.0',
    );
  });
  tearDown(() => dir.deleteSync(recursive: true));

  Matcher failsWith(UpdateFailureKind kind) =>
      throwsA(isA<UpdateFailure>().having((e) => e.kind, 'kind', kind));

  FakeReply redirect(String to) => FakeReply(
    302,
    const [],
    headers: {
      'location': [to],
    },
  );

  test('segue o redirecionamento do GitHub, sem nada da carteira', () async {
    http
      ..on(
        'github.com/dono',
        redirect('https://objects.githubusercontent.com/x'),
      )
      ..on('objects.githubusercontent.com/x', FakeReply.text('conteúdo'));
    final bytes = await downloads.fetch(Uri.parse('$_release/SHA256SUMS.txt'));
    expect(utf8.decode(bytes!), 'conteúdo');
    expect(http.requests.first.headers['User-Agent'], 'Patrion/1.0.0');
    expect(http.requests.first.headers, isNot(contains('Authorization')));
  });

  test('404 é arquivo inexistente', () async {
    http.on('github.com', FakeReply.text('', status: 404));
    expect(await downloads.fetch(Uri.parse('$_release/x')), isNull);
  });

  test('recusa endereço sem HTTPS ou fora do GitHub', () async {
    await expectLater(
      downloads.fetch(Uri.parse('http://github.com/x')),
      failsWith(UpdateFailureKind.unavailable),
    );
    await expectLater(
      downloads.fetch(Uri.parse('https://github.com.evil.example/x')),
      failsWith(UpdateFailureKind.unavailable),
    );
    expect(http.requests, isEmpty);
  });

  test('recusa redirecionamento para fora do GitHub ou sem HTTPS', () async {
    http.on('github.com/dono', redirect('https://evil.example/x'));
    await expectLater(
      downloads.fetch(Uri.parse('$_release/x')),
      failsWith(UpdateFailureKind.unavailable),
    );
    http.rules.clear();
    http.on('github.com/dono', redirect('http://github.com/y'));
    await expectLater(
      downloads.fetch(Uri.parse('$_release/x')),
      failsWith(UpdateFailureKind.unavailable),
    );
    expect(http.urls.where((u) => u.contains('evil')), isEmpty);
  });

  test('redirecionamento sem fim é recusado', () async {
    http.on('github.com', redirect('https://github.com/dono/de-novo'));
    await expectLater(
      downloads.fetch(Uri.parse('$_release/x')),
      failsWith(UpdateFailureKind.unavailable),
    );
    expect(http.requests, hasLength(GitHubReleaseDownloads.maxRedirects + 1));
  });

  test('sem internet', () async {
    http.offline = true;
    await expectLater(
      downloads.download(Uri.parse('$_release/x'), target()),
      failsWith(UpdateFailureKind.offline),
    );
  });

  test('download grava o arquivo e informa o progresso', () async {
    http.on(
      'github.com',
      FakeReply(
        200,
        [1, 2, 3, 4],
        headers: {
          'content-length': ['4'],
        },
      ),
    );
    final progress = <(int, int?)>[];
    await downloads.download(
      Uri.parse('$_release/x'),
      target(),
      onProgress: (r, t) => progress.add((r, t)),
    );
    expect(File(target()).readAsBytesSync(), [1, 2, 3, 4]);
    expect(progress.last, (4, 4));
  });

  group('download interrompido', () {
    GitHubReleaseDownloads broken(
      Stream<Uint8List> Function() body, {
      int total = 10,
      Duration stall = const Duration(seconds: 60),
    }) => GitHubReleaseDownloads(
      dio: Dio()..httpClientAdapter = _BrokenAdapter(body, total),
      stallTimeout: stall,
    );

    test('a conexão cai no meio', () async {
      Stream<Uint8List> body() async* {
        yield Uint8List.fromList([1, 2, 3]);
        throw const SocketException('conexão perdida');
      }

      await expectLater(
        broken(body).download(Uri.parse('$_release/x'), target()),
        failsWith(UpdateFailureKind.interrupted),
      );
    });

    test('a conexão fecha antes do tamanho anunciado', () async {
      await expectLater(
        broken(() => Stream.value(Uint8List.fromList([1, 2, 3])))
            .download(Uri.parse('$_release/x'), target()),
        failsWith(UpdateFailureKind.interrupted),
      );
    });

    test('os dados param de chegar', () async {
      final stalled = StreamController<Uint8List>();
      addTearDown(stalled.close);
      await expectLater(
        broken(
          () => stalled.stream,
          stall: const Duration(milliseconds: 20),
        ).download(Uri.parse('$_release/x'), target()),
        failsWith(UpdateFailureKind.interrupted),
      );
    });

    test('cancelar para o download', () async {
      final cancel = UpdateCancel();
      Stream<Uint8List> body() async* {
        yield Uint8List.fromList([1]);
        cancel.cancel();
        yield Uint8List.fromList([2]);
      }

      await expectLater(
        broken(body)
            .download(Uri.parse('$_release/x'), target(), cancel: cancel),
        failsWith(UpdateFailureKind.cancelled),
      );
    });
  });
}
