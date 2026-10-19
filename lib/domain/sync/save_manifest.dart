import '../../core/errors/app_error.dart';
import '../../core/ids/id_generator.dart';
import '../../core/sync/hlc.dart';
import '../../core/time/instant_format.dart';

/// O que o autor de um save sabe de outro dispositivo: o maior HLC recebido
/// dele. Serve para o destino saber quais alterações suas o autor já tinha
/// visto (detecção de conflitos, SPEC §10.4).
class KnownPeer {
  const KnownPeer({required this.deviceId, required this.lastHlcReceived});

  final String deviceId;
  final String lastHlcReceived;
}

/// `manifest.json` do arquivo de save (SPEC §10.1, `docs/SINCRONIZACAO.md`).
class SaveManifest {
  const SaveManifest({
    required this.appVersion,
    required this.schemaVersion,
    required this.deviceId,
    required this.deviceName,
    required this.createdAt,
    required this.maxHlc,
    required this.counts,
    this.files = const {},
    this.knownPeers = const [],
    this.encryption = encryptionNone,
    this.encryptionParams = const {},
    this.marketIncluded = false,
    this.marketCounts = const {},
    this.formatVersion = currentFormatVersion,
  });

  /// Identificador do formato.
  static const formatId = 'patrion-invsave';

  /// Versão do formato do arquivo (independente do schema do banco). A 2
  /// acrescentou a pasta `market/` (DECISIONS D-36); um save sem ela sai
  /// como versão 1, que as versões anteriores do app ainda leem.
  static const currentFormatVersion = 2;

  /// Versão do formato sem a pasta `market/`.
  static const formatWithoutMarket = 1;

  /// Sem criptografia.
  static const encryptionNone = 'none';

  /// Protegido por senha (F5B, DECISIONS D-32).
  static const encryptionAesGcm = 'aes-256-gcm';

  final int formatVersion;
  final String appVersion;
  final int schemaVersion;
  final String deviceId;
  final String deviceName;

  /// Instante UTC da geração (ISO-8601 com ms).
  final String createdAt;

  /// Maior HLC entre os registros do save; nulo se o save não tem registros.
  final String? maxHlc;

  /// Registros por tabela (inclui tombstones).
  final Map<String, int> counts;

  /// SHA-256 (hexadecimal) de cada arquivo do save, pelo caminho no ZIP.
  final Map<String, String> files;
  final List<KnownPeer> knownPeers;

  /// Esquema de criptografia do conteúdo: `none` ou `aes-256-gcm`.
  final String encryption;

  /// Parâmetros da criptografia (KDF e nonce), ao lado de `scheme`.
  final Map<String, Object?> encryptionParams;

  /// Se a pasta `market/` (dados de mercado, SPEC §10.1) foi incluída.
  final bool marketIncluded;

  /// Registros por tabela de mercado (`mkt_`), quando incluída.
  final Map<String, int> marketCounts;

  SaveManifest copyWith({
    Map<String, String>? files,
    bool? marketIncluded,
    Map<String, int>? marketCounts,
    int? formatVersion,
  }) => SaveManifest(
    appVersion: appVersion,
    schemaVersion: schemaVersion,
    deviceId: deviceId,
    deviceName: deviceName,
    createdAt: createdAt,
    maxHlc: maxHlc,
    counts: counts,
    files: files ?? this.files,
    knownPeers: knownPeers,
    encryption: encryption,
    encryptionParams: encryptionParams,
    marketIncluded: marketIncluded ?? this.marketIncluded,
    marketCounts: marketCounts ?? this.marketCounts,
    formatVersion: formatVersion ?? this.formatVersion,
  );

  /// HLC que o autor do save já recebeu deste dispositivo, se recebeu.
  String? knownHlcOf(String deviceId) {
    for (final p in knownPeers) {
      if (p.deviceId == deviceId) return p.lastHlcReceived;
    }
    return null;
  }

  Map<String, Object?> toJson() => {
    'format': formatId,
    'formatVersion': formatVersion,
    'appVersion': appVersion,
    'schemaVersion': schemaVersion,
    'device': {'id': deviceId, 'name': deviceName},
    'createdAt': createdAt,
    'maxHlc': maxHlc,
    'counts': {for (final k in counts.keys.toList()..sort()) k: counts[k]},
    'files': {for (final k in files.keys.toList()..sort()) k: files[k]},
    'knownPeers': [
      for (final p in knownPeers)
        {'deviceId': p.deviceId, 'lastHlcReceived': p.lastHlcReceived},
    ],
    'encryption': {...encryptionParams, 'scheme': encryption},
    'market': {
      'included': marketIncluded,
      if (marketIncluded)
        'counts': {
          for (final k in marketCounts.keys.toList()..sort())
            k: marketCounts[k],
        },
    },
  };

  /// Lê e valida o manifesto. Lança [DataError] se ele não for de um save do
  /// Patrion, estiver incompleto ou for de um formato mais novo.
  factory SaveManifest.fromJson(Object? json) {
    Never invalid(String detail) => throw DataError(
      'O arquivo não é um save válido do Patrion (manifesto: $detail).',
    );

    if (json is! Map<String, Object?>) invalid('não é um objeto');
    if (json['format'] != formatId) invalid('formato desconhecido');
    final formatVersion = json['formatVersion'];
    if (formatVersion is! int || formatVersion < 1) invalid('versão');
    if (formatVersion > currentFormatVersion) {
      throw DataError(
        'Este save usa um formato mais novo (versão $formatVersion) do que '
        'esta versão do Patrion conhece. Atualize o aplicativo.',
      );
    }

    T field<T>(Map<String, Object?> map, String key) {
      final value = map[key];
      if (value is! T) invalid(key);
      return value;
    }

    final device = field<Map<String, Object?>>(json, 'device');
    final deviceId = field<String>(device, 'id');
    if (!IdGenerator.isValid(deviceId)) invalid('device.id');
    final createdAt = field<String>(json, 'createdAt');
    try {
      parseInstant(createdAt);
    } on FormatException {
      invalid('createdAt');
    }
    final maxHlc = json['maxHlc'];
    if (maxHlc != null && (maxHlc is! String || !_isHlc(maxHlc))) {
      invalid('maxHlc');
    }
    final schemaVersion = field<int>(json, 'schemaVersion');
    if (schemaVersion < 1) invalid('schemaVersion');

    final counts = <String, int>{};
    for (final e in field<Map<String, Object?>>(json, 'counts').entries) {
      final v = e.value;
      if (v is! int || v < 0) invalid('counts');
      counts[e.key] = v;
    }
    final files = <String, String>{};
    for (final e in field<Map<String, Object?>>(json, 'files').entries) {
      final v = e.value;
      if (v is! String || !_sha256Pattern.hasMatch(v)) invalid('files');
      files[e.key] = v;
    }
    final peers = <KnownPeer>[];
    for (final p in field<List<Object?>>(json, 'knownPeers')) {
      if (p is! Map<String, Object?>) invalid('knownPeers');
      final id = p['deviceId'];
      final hlc = p['lastHlcReceived'];
      if (id is! String || hlc is! String || !_isHlc(hlc)) {
        invalid('knownPeers');
      }
      peers.add(KnownPeer(deviceId: id, lastHlcReceived: hlc));
    }
    final encryptionJson = field<Map<String, Object?>>(json, 'encryption');
    final encryption = field<String>(encryptionJson, 'scheme');
    final market = json['market'];
    final marketIncluded = market is Map<String, Object?>
        ? market['included'] == true
        : false;
    final marketCounts = <String, int>{};
    if (marketIncluded) {
      final c = market['counts'];
      if (c is! Map<String, Object?>) invalid('market.counts');
      for (final e in c.entries) {
        final v = e.value;
        if (v is! int || v < 0) invalid('market.counts');
        marketCounts[e.key] = v;
      }
    }

    return SaveManifest(
      formatVersion: formatVersion,
      appVersion: field<String>(json, 'appVersion'),
      schemaVersion: schemaVersion,
      deviceId: deviceId,
      deviceName: field<String>(device, 'name'),
      createdAt: createdAt,
      maxHlc: maxHlc as String?,
      counts: counts,
      files: files,
      knownPeers: peers,
      encryption: encryption,
      encryptionParams: {
        for (final e in encryptionJson.entries)
          if (e.key != 'scheme') e.key: e.value,
      },
      marketIncluded: marketIncluded,
      marketCounts: marketCounts,
    );
  }

  static final _sha256Pattern = RegExp(r'^[0-9a-f]{64}$');

  static bool _isHlc(String text) {
    try {
      Hlc.parse(text);
      return true;
    } on FormatException {
      return false;
    }
  }
}
