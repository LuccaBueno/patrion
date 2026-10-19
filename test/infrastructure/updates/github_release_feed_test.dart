import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/application/updates/update_checker.dart';
import 'package:patrion/infrastructure/updates/github_release_feed.dart';

import '../../helpers/fake_http.dart';

FakeReply _json(Object body, {int status = 200}) => FakeReply(
  status,
  utf8.encode(jsonEncode(body)),
  headers: {
    'content-type': ['application/json; charset=utf-8'],
  },
);

Map<String, Object?> _release(
  String tag, {
  bool prerelease = false,
  bool draft = false,
  String? url,
}) => {
  'tag_name': tag,
  'name': 'Patrion $tag',
  'body': '## Novidades\n- algo',
  'html_url': url ?? 'https://github.com/dono/patrion/releases/tag/$tag',
  'prerelease': prerelease,
  'draft': draft,
  'published_at': '2026-10-20T12:00:00Z',
};

void main() {
  late FakeHttpAdapter http;
  late GitHubReleaseFeed feed;

  setUp(() {
    http = FakeHttpAdapter();
    feed = GitHubReleaseFeed(
      dio: Dio()..httpClientAdapter = http,
      repository: 'dono/patrion',
      appVersion: '1.0.0',
    );
  });

  test(
    'versão estável: consulta /latest sem token, só com o nome do app',
    () async {
      http.on('/releases/latest', _json(_release('v1.2.0')));
      final r = await feed.latest(includePrerelease: false);
      expect(r!.version.toString(), '1.2.0');
      expect(r.tag, 'v1.2.0');
      expect(r.notes, contains('Novidades'));
      expect(r.publishedAt, DateTime.utc(2026, 10, 20, 12));
      expect(
        http.urls.single,
        'https://api.github.com/repos/dono/patrion/releases/latest',
      );
      final headers = http.requests.single.headers;
      expect(headers['User-Agent'], 'Patrion/1.0.0');
      expect(
        headers.keys.map((k) => k.toLowerCase()),
        isNot(contains('authorization')),
      );
    },
  );

  test('sem nenhuma Release publicada (404), devolve nulo', () async {
    http.on('/releases/latest', _json({'message': 'Not Found'}, status: 404));
    expect(await feed.latest(includePrerelease: false), isNull);
  });

  test('com pré-lançamentos: maior versão, sem rascunhos', () async {
    http.on(
      '/releases?per_page=30',
      _json([
        _release('v1.1.0'),
        _release('v2.0.0', draft: true),
        _release('v1.2.0-rc.1', prerelease: true),
        _release('nao-e-versao'),
      ]),
    );
    final r = await feed.latest(includePrerelease: true);
    expect(r!.version.toString(), '1.2.0-rc.1');
    expect(r.prerelease, isTrue);
  });

  test('link fora do repositório é trocado pela página da tag', () async {
    http.on(
      '/releases/latest',
      _json(_release('v1.2.0', url: 'https://exemplo.com/malicioso')),
    );
    final r = await feed.latest(includePrerelease: false);
    expect(
      r!.page.toString(),
      'https://github.com/dono/patrion/releases/tag/v1.2.0',
    );
  });

  test('sem internet e limite do GitHub viram falhas com mensagem', () async {
    http.offline = true;
    await expectLater(
      feed.latest(includePrerelease: false),
      throwsA(
        isA<UpdateCheckFailure>().having((e) => e.offline, 'offline', isTrue),
      ),
    );
    http
      ..offline = false
      ..on('/releases/latest', _json({'message': 'rate limit'}, status: 403));
    await expectLater(
      feed.latest(includePrerelease: false),
      throwsA(
        isA<UpdateCheckFailure>().having(
          (e) => e.message,
          'message',
          contains('limitou'),
        ),
      ),
    );
  });
}
