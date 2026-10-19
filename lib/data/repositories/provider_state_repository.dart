import 'package:drift/drift.dart';

import '../../core/time/instant_format.dart';
import '../../domain/market/provider_catalog.dart';
import '../db/app_database.dart';

/// Estado de um provedor neste PC.
class ProviderState {
  const ProviderState({
    required this.info,
    required this.enabled,
    this.lastSuccessAt,
    this.lastErrorAt,
    this.lastError,
    this.quotaUsed = 0,
    this.quotaPeriod,
  });

  final ProviderInfo info;
  final bool enabled;
  final String? lastSuccessAt;
  final String? lastErrorAt;

  /// Mensagem para o usuário, sem URL nem chave.
  final String? lastError;
  final int quotaUsed;
  final String? quotaPeriod;

  /// O último acesso falhou (depois do último sucesso).
  bool get failing =>
      lastErrorAt != null &&
      (lastSuccessAt == null || lastErrorAt!.compareTo(lastSuccessAt!) > 0);
}

/// `dev_provider_state`: ligado ou desligado, último sucesso e erro, uso da
/// cota (SPEC §5: registro da última atualização e sinalização de erros).
/// Nunca vai no save.
class ProviderStateRepository {
  const ProviderStateRepository(this._db);

  final AppDatabase _db;

  Future<List<ProviderState>> all() async =>
      _merge(await _db.select(_db.devProviderState).get());

  Stream<List<ProviderState>> watchAll() =>
      _db.select(_db.devProviderState).watch().map(_merge);

  Future<ProviderState> of(String code) async {
    final row = await (_db.select(
      _db.devProviderState,
    )..where((t) => t.provider.equals(code))).getSingleOrNull();
    return _merge([?row]).firstWhere((s) => s.info.code == code);
  }

  Future<bool> isEnabled(String code) async => (await of(code)).enabled;

  Future<void> setEnabled(String code, bool enabled) =>
      _upsert(code, (c) => c.copyWith(enabled: Value(enabled)));

  Future<void> recordSuccess(String code, DateTime at) =>
      _upsert(code, (c) => c.copyWith(lastSuccessAt: Value(formatInstant(at))));

  Future<void> recordError(String code, DateTime at, String message) => _upsert(
    code,
    (c) => c.copyWith(
      lastErrorAt: Value(formatInstant(at)),
      lastError: Value(message),
    ),
  );

  /// Soma [n] requisições à cota do mês de [at] e devolve o total do mês.
  Future<int> addQuota(String code, DateTime at, {int n = 1}) async {
    final period = '${at.year}-${at.month.toString().padLeft(2, '0')}';
    final current = await of(code);
    final used = current.quotaPeriod == period ? current.quotaUsed + n : n;
    await _upsert(
      code,
      (c) => c.copyWith(quotaUsed: Value(used), quotaPeriod: Value(period)),
    );
    return used;
  }

  Future<void> _upsert(
    String code,
    DevProviderStateCompanion Function(DevProviderStateCompanion) change,
  ) async {
    final current = await of(code);
    final base = DevProviderStateCompanion.insert(
      provider: code,
      enabled: current.enabled,
      lastSuccessAt: Value(current.lastSuccessAt),
      lastErrorAt: Value(current.lastErrorAt),
      lastError: Value(current.lastError),
      quotaUsed: Value(current.quotaUsed),
      quotaPeriod: Value(current.quotaPeriod),
    );
    await _db.into(_db.devProviderState).insertOnConflictUpdate(change(base));
  }

  static List<ProviderState> _merge(List<DevProviderStateRow> rows) {
    final byCode = {for (final r in rows) r.provider: r};
    return [
      for (final info in ProviderCatalog.all)
        if (byCode[info.code] case final r?)
          ProviderState(
            info: info,
            enabled: r.enabled,
            lastSuccessAt: r.lastSuccessAt,
            lastErrorAt: r.lastErrorAt,
            lastError: r.lastError,
            quotaUsed: r.quotaUsed,
            quotaPeriod: r.quotaPeriod,
          )
        else
          ProviderState(info: info, enabled: info.defaultEnabled),
    ];
  }
}
