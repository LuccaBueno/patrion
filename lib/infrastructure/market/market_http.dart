import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import '../../core/errors/app_error.dart';

final _log = Logger('mercado');

/// Regras de acesso a um provedor (SPEC §4: timeout, retentativa com
/// backoff, limites).
class HttpPolicy {
  const HttpPolicy({
    this.minInterval = const Duration(milliseconds: 500),
    this.timeout = const Duration(seconds: 20),
    this.maxAttempts = 3,
    this.maxRetryAfter = const Duration(seconds: 60),
  });

  /// Intervalo mínimo entre duas requisições ao mesmo provedor. As
  /// requisições de um provedor são feitas uma de cada vez.
  final Duration minInterval;
  final Duration timeout;

  /// Tentativas no total (1 = sem retentativa).
  final int maxAttempts;

  /// Espera máxima pedida por um `Retry-After`; acima disso, falha.
  final Duration maxRetryAfter;
}

/// Resposta com erro HTTP que não adianta repetir (4xx exceto 429).
class HttpStatusError implements Exception {
  const HttpStatusError(this.provider, this.statusCode, this.body);

  final String provider;
  final int statusCode;

  /// Início do corpo da resposta (sem cabeçalhos nem URL, que podem ter a
  /// chave).
  final String body;

  @override
  String toString() => 'HttpStatusError($provider, $statusCode)';
}

/// Acesso HTTP dos adaptadores de mercado.
///
/// - Uma fila por provedor, com intervalo mínimo entre requisições.
/// - Requisições iguais em andamento são feitas uma vez só.
/// - Falha de rede, tempo esgotado, 5xx e 429: até [HttpPolicy.maxAttempts]
///   tentativas, com espera de 1 s, 2 s, 4 s… ou o `Retry-After` do 429.
/// - Erros viram [NetworkError] (sem conexão, fora do ar) ou
///   [HttpStatusError] (4xx); nenhuma mensagem leva a URL completa nem os
///   cabeçalhos, onde ficam as chaves (regra 7).
class MarketHttp {
  MarketHttp({
    Dio? dio,
    this._policies = const {},
    Future<void> Function(Duration)? sleep,
  }) : _dio = dio ?? Dio(),
       _sleep = sleep ?? Future<void>.delayed;

  final Dio _dio;
  final Map<String, HttpPolicy> _policies;
  final Future<void> Function(Duration) _sleep;

  final _queues = <String, Future<void>>{};
  final _lastAt = <String, DateTime>{};
  final _inFlight = <String, Future<Object>>{};

  HttpPolicy policyOf(String provider) =>
      _policies[provider] ?? const HttpPolicy();

  /// Texto da resposta (UTF-8, ou Latin-1 com [latin1]).
  ///
  /// [retryIf] marca respostas 2xx que são falha passageira do provedor (o
  /// SGS às vezes responde uma página de erro com status 200): elas são
  /// repetidas como um 5xx e, esgotadas as tentativas, a última volta para o
  /// adaptador recusar.
  Future<String> getText(
    String provider,
    Uri uri, {
    Map<String, String> headers = const {},
    bool latin1 = false,
    bool Function(String text)? retryIf,
  }) async {
    final attempts = policyOf(provider).maxAttempts;
    for (var n = 1; ; n++) {
      final bytes = await getBytes(provider, uri, headers: headers);
      final text = latin1
          ? const Latin1Codec(allowInvalid: true).decode(bytes)
          : const Utf8Codec(allowMalformed: true).decode(bytes);
      if (retryIf == null || n >= attempts || !retryIf(text)) return text;
      final wait = Duration(seconds: 1 << (n - 1));
      _log.info('$provider: resposta inválida; nova tentativa em $wait');
      await _sleep(wait);
    }
  }

  Future<Uint8List> getBytes(
    String provider,
    Uri uri, {
    Map<String, String> headers = const {},
  }) async {
    final key = '$provider ${uri.toString()} ${headers.hashCode}';
    final running = _inFlight[key];
    if (running != null) return (await running) as Uint8List;
    final future = _queued(provider, () => _fetch(provider, uri, headers));
    _inFlight[key] = future;
    try {
      return (await future) as Uint8List;
    } finally {
      _inFlight.remove(key)?.ignore();
    }
  }

  /// Baixa [uri] direto para o arquivo [target] (arquivos grandes, como o
  /// COTAHIST). Em falha, o arquivo parcial é apagado.
  ///
  /// [lane] separa a fila do provedor: o download longo de um arquivo anual
  /// não faz a atualização diária esperar (M-08). [onProgress] recebe o
  /// percentual já baixado, quando o servidor informa o tamanho.
  Future<void> download(
    String provider,
    Uri uri,
    String target, {
    Map<String, String> headers = const {},
    Duration timeout = const Duration(minutes: 10),
    String? lane,
    void Function(int percent)? onProgress,
  }) => _queued(lane == null ? provider : '$provider/$lane', () async {
    final policy = policyOf(provider);
    await _retrying(provider, policy, uri, () async {
      try {
        final response = await _dio.download(
          uri.toString(),
          target,
          onReceiveProgress: onProgress == null
              ? null
              : (received, total) {
                  if (total > 0) onProgress((received * 100) ~/ total);
                },
          options: Options(
            headers: headers,
            receiveTimeout: timeout,
            sendTimeout: policy.timeout,
            validateStatus: (_) => true,
          ),
        );
        _checkStatus(provider, response, _readTail(target));
      } catch (_) {
        final f = File(target);
        if (f.existsSync()) f.deleteSync();
        rethrow;
      }
      return Uint8List(0);
    });
    return Uint8List(0);
  });

  Future<Object> _queued(String provider, Future<Object> Function() run) {
    final previous = _queues[provider] ?? Future<void>.value();
    final completer = Completer<Object>();
    final next = previous.then((_) async {
      final policy = policyOf(provider);
      final last = _lastAt[provider];
      if (last != null) {
        final wait = policy.minInterval - DateTime.now().difference(last);
        if (wait > Duration.zero) await _sleep(wait);
      }
      try {
        completer.complete(await run());
      } catch (error, stack) {
        completer.completeError(error, stack);
      } finally {
        _lastAt[provider] = DateTime.now();
      }
    });
    _queues[provider] = next;
    return completer.future;
  }

  Future<Object> _fetch(String provider, Uri uri, Map<String, String> headers) {
    final policy = policyOf(provider);
    return _retrying(provider, policy, uri, () async {
      final response = await _dio.getUri<List<int>>(
        uri,
        options: Options(
          headers: headers,
          responseType: ResponseType.bytes,
          receiveTimeout: policy.timeout,
          sendTimeout: policy.timeout,
          validateStatus: (_) => true,
        ),
      );
      final data = Uint8List.fromList(response.data ?? const []);
      _checkStatus(provider, response, data);
      return data;
    });
  }

  Future<Uint8List> _retrying(
    String provider,
    HttpPolicy policy,
    Uri uri,
    Future<Uint8List> Function() attempt,
  ) async {
    final where = '${uri.host}${uri.path}';
    for (var n = 1; ; n++) {
      try {
        final result = await attempt();
        _log.fine('$provider: $where ok');
        return result;
      } on _Retry catch (retry) {
        if (n >= policy.maxAttempts) {
          _log.warning('$provider: $where falhou (${retry.reason})');
          throw retry.toError(provider);
        }
        final wait = retry.after ?? Duration(seconds: 1 << (n - 1));
        if (wait > policy.maxRetryAfter) {
          _log.warning('$provider: limite atingido, espera de $wait');
          throw retry.toError(provider);
        }
        _log.info('$provider: ${retry.reason}; nova tentativa em $wait');
        await _sleep(wait);
      } on DioException catch (error) {
        final reason = _describe(error);
        if (n >= policy.maxAttempts) {
          _log.warning('$provider: $where falhou ($reason)');
          throw NetworkError(
            'Não foi possível acessar ${_hostOf(uri)} ($reason). Verifique a '
            'conexão; os dados já baixados continuam disponíveis.',
          );
        }
        await _sleep(Duration(seconds: 1 << (n - 1)));
      }
    }
  }

  void _checkStatus(
    String provider,
    Response<Object?> response,
    List<int> data,
  ) {
    final status = response.statusCode ?? 0;
    if (status >= 200 && status < 300) return;
    if (status == 429) {
      throw _Retry('limite de requisições (429)', _retryAfter(response));
    }
    if (status >= 500) throw _Retry('erro $status no provedor', null);
    final body = const Utf8Codec(allowMalformed: true)
        .decode(data.length > 300 ? data.sublist(0, 300) : data);
    _log.warning('$provider: resposta $status');
    throw HttpStatusError(provider, status, body);
  }

  static List<int> _readTail(String path) {
    final f = File(path);
    if (!f.existsSync() || f.lengthSync() > 4096) return const [];
    return f.readAsBytesSync();
  }

  static Duration? _retryAfter(Response<Object?> response) {
    final value = response.headers.value('retry-after');
    if (value == null) return null;
    final seconds = int.tryParse(value.trim());
    if (seconds != null) return Duration(seconds: seconds);
    try {
      final at = HttpDate.parse(value);
      final wait = at.difference(DateTime.now());
      return wait.isNegative ? Duration.zero : wait;
    } on FormatException {
      return null;
    }
  }

  static String _describe(DioException e) => switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout => 'tempo esgotado',
    DioExceptionType.connectionError => 'sem conexão',
    DioExceptionType.badCertificate => 'certificado inválido',
    DioExceptionType.cancel => 'cancelado',
    _ => e.error is SocketException ? 'sem conexão' : 'falha de rede',
  };

  static String _hostOf(Uri uri) => uri.host;

  void close() => _dio.close(force: true);
}

class _Retry implements Exception {
  const _Retry(this.reason, this.after);

  final String reason;
  final Duration? after;

  AppError toError(String provider) => NetworkError(
    'O provedor $provider não respondeu ($reason). Tente de novo mais '
    'tarde; os dados já baixados continuam disponíveis.',
  );
}
