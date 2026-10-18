import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:patrion/infrastructure/market/market_http.dart';

/// Resposta de mentira.
class FakeReply {
  FakeReply(this.status, List<int> body, {this.headers = const {}})
    : body = Uint8List.fromList(body);

  factory FakeReply.text(String text, {int status = 200}) =>
      FakeReply(status, utf8.encode(text));

  factory FakeReply.file(String path) =>
      FakeReply(200, File(path).readAsBytesSync());

  final int status;
  final Uint8List body;
  final Map<String, List<String>> headers;
}

/// Adaptador HTTP de mentira para o Dio: responde pela primeira regra cujo
/// trecho aparece na URL e registra todas as requisições.
class FakeHttpAdapter implements HttpClientAdapter {
  final rules = <(String, Object)>[];
  final requests = <RequestOptions>[];

  /// [reply] é uma [FakeReply], uma lista delas (uma por chamada; a última
  /// se repete) ou uma exceção para lançar.
  void on(String urlPart, Object reply) => rules.add((urlPart, reply));

  final _calls = <String, int>{};

  /// Simula falta de rede em todas as requisições.
  bool offline = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (offline) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
        error: const SocketException('offline'),
      );
    }
    final url = options.uri.toString();
    for (final (part, reply) in rules) {
      if (!url.contains(part)) continue;
      final n = _calls[part] = (_calls[part] ?? 0) + 1;
      Object chosen = reply;
      if (reply is List<FakeReply>) {
        chosen = reply[n - 1 < reply.length ? n - 1 : reply.length - 1];
      }
      if (chosen is Exception) throw chosen;
      final r = chosen as FakeReply;
      return ResponseBody.fromBytes(r.body, r.status, headers: r.headers);
    }
    return ResponseBody.fromBytes(utf8.encode('não mapeado: $url'), 404);
  }

  @override
  void close({bool force = false}) {}

  /// URLs pedidas (sem os cabeçalhos).
  List<String> get urls => [for (final r in requests) r.uri.toString()];
}

/// [MarketHttp] sobre o adaptador de mentira, sem esperas reais.
MarketHttp fakeMarketHttp(FakeHttpAdapter adapter, {List<Duration>? sleeps}) {
  final dio = Dio()..httpClientAdapter = adapter;
  return MarketHttp(dio: dio, sleep: (d) async => sleeps?.add(d));
}

String fixture(String name) => 'test/fixtures/market/$name';
