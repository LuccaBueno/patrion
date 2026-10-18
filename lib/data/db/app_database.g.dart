// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DevIdentityTable extends DevIdentity
    with TableInfo<$DevIdentityTable, DevIdentityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevIdentityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceNameMeta = const VerificationMeta(
    'deviceName',
  );
  @override
  late final GeneratedColumn<String> deviceName = GeneratedColumn<String>(
    'device_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastHlcMeta = const VerificationMeta(
    'lastHlc',
  );
  @override
  late final GeneratedColumn<String> lastHlc = GeneratedColumn<String>(
    'last_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    deviceId,
    deviceName,
    createdAt,
    lastHlc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dev_identity';
  @override
  VerificationContext validateIntegrity(
    Insertable<DevIdentityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('device_name')) {
      context.handle(
        _deviceNameMeta,
        deviceName.isAcceptableOrUnknown(data['device_name']!, _deviceNameMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_hlc')) {
      context.handle(
        _lastHlcMeta,
        lastHlc.isAcceptableOrUnknown(data['last_hlc']!, _lastHlcMeta),
      );
    } else if (isInserting) {
      context.missing(_lastHlcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId};
  @override
  DevIdentityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DevIdentityRow(
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      deviceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      lastHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_hlc'],
      )!,
    );
  }

  @override
  $DevIdentityTable createAlias(String alias) {
    return $DevIdentityTable(attachedDatabase, alias);
  }
}

class DevIdentityRow extends DataClass implements Insertable<DevIdentityRow> {
  final String deviceId;
  final String deviceName;
  final String createdAt;

  /// Último HLC emitido ou recebido, para o relógio continuar crescendo
  /// depois de reiniciar o app.
  final String lastHlc;
  const DevIdentityRow({
    required this.deviceId,
    required this.deviceName,
    required this.createdAt,
    required this.lastHlc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    map['device_name'] = Variable<String>(deviceName);
    map['created_at'] = Variable<String>(createdAt);
    map['last_hlc'] = Variable<String>(lastHlc);
    return map;
  }

  DevIdentityCompanion toCompanion(bool nullToAbsent) {
    return DevIdentityCompanion(
      deviceId: Value(deviceId),
      deviceName: Value(deviceName),
      createdAt: Value(createdAt),
      lastHlc: Value(lastHlc),
    );
  }

  factory DevIdentityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DevIdentityRow(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deviceName: serializer.fromJson<String>(json['deviceName']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      lastHlc: serializer.fromJson<String>(json['lastHlc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'deviceName': serializer.toJson<String>(deviceName),
      'createdAt': serializer.toJson<String>(createdAt),
      'lastHlc': serializer.toJson<String>(lastHlc),
    };
  }

  DevIdentityRow copyWith({
    String? deviceId,
    String? deviceName,
    String? createdAt,
    String? lastHlc,
  }) => DevIdentityRow(
    deviceId: deviceId ?? this.deviceId,
    deviceName: deviceName ?? this.deviceName,
    createdAt: createdAt ?? this.createdAt,
    lastHlc: lastHlc ?? this.lastHlc,
  );
  DevIdentityRow copyWithCompanion(DevIdentityCompanion data) {
    return DevIdentityRow(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deviceName: data.deviceName.present
          ? data.deviceName.value
          : this.deviceName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastHlc: data.lastHlc.present ? data.lastHlc.value : this.lastHlc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DevIdentityRow(')
          ..write('deviceId: $deviceId, ')
          ..write('deviceName: $deviceName, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastHlc: $lastHlc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(deviceId, deviceName, createdAt, lastHlc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DevIdentityRow &&
          other.deviceId == this.deviceId &&
          other.deviceName == this.deviceName &&
          other.createdAt == this.createdAt &&
          other.lastHlc == this.lastHlc);
}

class DevIdentityCompanion extends UpdateCompanion<DevIdentityRow> {
  final Value<String> deviceId;
  final Value<String> deviceName;
  final Value<String> createdAt;
  final Value<String> lastHlc;
  final Value<int> rowid;
  const DevIdentityCompanion({
    this.deviceId = const Value.absent(),
    this.deviceName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastHlc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevIdentityCompanion.insert({
    required String deviceId,
    required String deviceName,
    required String createdAt,
    required String lastHlc,
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId),
       deviceName = Value(deviceName),
       createdAt = Value(createdAt),
       lastHlc = Value(lastHlc);
  static Insertable<DevIdentityRow> custom({
    Expression<String>? deviceId,
    Expression<String>? deviceName,
    Expression<String>? createdAt,
    Expression<String>? lastHlc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (deviceName != null) 'device_name': deviceName,
      if (createdAt != null) 'created_at': createdAt,
      if (lastHlc != null) 'last_hlc': lastHlc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevIdentityCompanion copyWith({
    Value<String>? deviceId,
    Value<String>? deviceName,
    Value<String>? createdAt,
    Value<String>? lastHlc,
    Value<int>? rowid,
  }) {
    return DevIdentityCompanion(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      createdAt: createdAt ?? this.createdAt,
      lastHlc: lastHlc ?? this.lastHlc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deviceName.present) {
      map['device_name'] = Variable<String>(deviceName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (lastHlc.present) {
      map['last_hlc'] = Variable<String>(lastHlc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevIdentityCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('deviceName: $deviceName, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastHlc: $lastHlc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DevSettingsTable extends DevSettings
    with TableInfo<$DevSettingsTable, DevSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueJsonMeta = const VerificationMeta(
    'valueJson',
  );
  @override
  late final GeneratedColumn<String> valueJson = GeneratedColumn<String>(
    'value_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, valueJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dev_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<DevSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value_json')) {
      context.handle(
        _valueJsonMeta,
        valueJson.isAcceptableOrUnknown(data['value_json']!, _valueJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_valueJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  DevSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DevSettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      valueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DevSettingsTable createAlias(String alias) {
    return $DevSettingsTable(attachedDatabase, alias);
  }
}

class DevSettingRow extends DataClass implements Insertable<DevSettingRow> {
  final String key;
  final String valueJson;
  final String updatedAt;
  const DevSettingRow({
    required this.key,
    required this.valueJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value_json'] = Variable<String>(valueJson);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  DevSettingsCompanion toCompanion(bool nullToAbsent) {
    return DevSettingsCompanion(
      key: Value(key),
      valueJson: Value(valueJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory DevSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DevSettingRow(
      key: serializer.fromJson<String>(json['key']),
      valueJson: serializer.fromJson<String>(json['valueJson']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'valueJson': serializer.toJson<String>(valueJson),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  DevSettingRow copyWith({String? key, String? valueJson, String? updatedAt}) =>
      DevSettingRow(
        key: key ?? this.key,
        valueJson: valueJson ?? this.valueJson,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DevSettingRow copyWithCompanion(DevSettingsCompanion data) {
    return DevSettingRow(
      key: data.key.present ? data.key.value : this.key,
      valueJson: data.valueJson.present ? data.valueJson.value : this.valueJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DevSettingRow(')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, valueJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DevSettingRow &&
          other.key == this.key &&
          other.valueJson == this.valueJson &&
          other.updatedAt == this.updatedAt);
}

class DevSettingsCompanion extends UpdateCompanion<DevSettingRow> {
  final Value<String> key;
  final Value<String> valueJson;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const DevSettingsCompanion({
    this.key = const Value.absent(),
    this.valueJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevSettingsCompanion.insert({
    required String key,
    required String valueJson,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       valueJson = Value(valueJson),
       updatedAt = Value(updatedAt);
  static Insertable<DevSettingRow> custom({
    Expression<String>? key,
    Expression<String>? valueJson,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (valueJson != null) 'value_json': valueJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? valueJson,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return DevSettingsCompanion(
      key: key ?? this.key,
      valueJson: valueJson ?? this.valueJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (valueJson.present) {
      map['value_json'] = Variable<String>(valueJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevSettingsCompanion(')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SharedSettingsTable extends SharedSettings
    with TableInfo<$SharedSettingsTable, SharedSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SharedSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueJsonMeta = const VerificationMeta(
    'valueJson',
  );
  @override
  late final GeneratedColumn<String> valueJson = GeneratedColumn<String>(
    'value_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    hlc,
    deviceId,
    deletedAt,
    key,
    valueJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shared_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SharedSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value_json')) {
      context.handle(
        _valueJsonMeta,
        valueJson.isAcceptableOrUnknown(data['value_json']!, _valueJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_valueJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SharedSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SharedSettingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      valueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_json'],
      )!,
    );
  }

  @override
  $SharedSettingsTable createAlias(String alias) {
    return $SharedSettingsTable(attachedDatabase, alias);
  }
}

class SharedSettingRow extends DataClass
    implements Insertable<SharedSettingRow> {
  /// UUID v7 gerado no app.
  final String id;

  /// Instante UTC da criação (ISO-8601 com ms).
  final String createdAt;

  /// Instante UTC da última escrita.
  final String updatedAt;

  /// HLC da última alteração.
  final String hlc;

  /// Dispositivo que fez a última alteração.
  final String deviceId;

  /// Tombstone: preenchido na exclusão lógica.
  final String? deletedAt;
  final String key;
  final String valueJson;
  const SharedSettingRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.hlc,
    required this.deviceId,
    this.deletedAt,
    required this.key,
    required this.valueJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['hlc'] = Variable<String>(hlc);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['key'] = Variable<String>(key);
    map['value_json'] = Variable<String>(valueJson);
    return map;
  }

  SharedSettingsCompanion toCompanion(bool nullToAbsent) {
    return SharedSettingsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      hlc: Value(hlc),
      deviceId: Value(deviceId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      key: Value(key),
      valueJson: Value(valueJson),
    );
  }

  factory SharedSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SharedSettingRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      key: serializer.fromJson<String>(json['key']),
      valueJson: serializer.fromJson<String>(json['valueJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'hlc': serializer.toJson<String>(hlc),
      'deviceId': serializer.toJson<String>(deviceId),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'key': serializer.toJson<String>(key),
      'valueJson': serializer.toJson<String>(valueJson),
    };
  }

  SharedSettingRow copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? hlc,
    String? deviceId,
    Value<String?> deletedAt = const Value.absent(),
    String? key,
    String? valueJson,
  }) => SharedSettingRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    hlc: hlc ?? this.hlc,
    deviceId: deviceId ?? this.deviceId,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    key: key ?? this.key,
    valueJson: valueJson ?? this.valueJson,
  );
  SharedSettingRow copyWithCompanion(SharedSettingsCompanion data) {
    return SharedSettingRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      key: data.key.present ? data.key.value : this.key,
      valueJson: data.valueJson.present ? data.valueJson.value : this.valueJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SharedSettingRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hlc: $hlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    hlc,
    deviceId,
    deletedAt,
    key,
    valueJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SharedSettingRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.hlc == this.hlc &&
          other.deviceId == this.deviceId &&
          other.deletedAt == this.deletedAt &&
          other.key == this.key &&
          other.valueJson == this.valueJson);
}

class SharedSettingsCompanion extends UpdateCompanion<SharedSettingRow> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> hlc;
  final Value<String> deviceId;
  final Value<String?> deletedAt;
  final Value<String> key;
  final Value<String> valueJson;
  final Value<int> rowid;
  const SharedSettingsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.key = const Value.absent(),
    this.valueJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SharedSettingsCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    required String hlc,
    required String deviceId,
    this.deletedAt = const Value.absent(),
    required String key,
    required String valueJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       hlc = Value(hlc),
       deviceId = Value(deviceId),
       key = Value(key),
       valueJson = Value(valueJson);
  static Insertable<SharedSettingRow> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? hlc,
    Expression<String>? deviceId,
    Expression<String>? deletedAt,
    Expression<String>? key,
    Expression<String>? valueJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (hlc != null) 'hlc': hlc,
      if (deviceId != null) 'device_id': deviceId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (key != null) 'key': key,
      if (valueJson != null) 'value_json': valueJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SharedSettingsCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? hlc,
    Value<String>? deviceId,
    Value<String?>? deletedAt,
    Value<String>? key,
    Value<String>? valueJson,
    Value<int>? rowid,
  }) {
    return SharedSettingsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hlc: hlc ?? this.hlc,
      deviceId: deviceId ?? this.deviceId,
      deletedAt: deletedAt ?? this.deletedAt,
      key: key ?? this.key,
      valueJson: valueJson ?? this.valueJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (valueJson.present) {
      map['value_json'] = Variable<String>(valueJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SharedSettingsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hlc: $hlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InstitutionsTable extends Institutions
    with TableInfo<$InstitutionsTable, InstitutionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstitutionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameKeyMeta = const VerificationMeta(
    'nameKey',
  );
  @override
  late final GeneratedColumn<String> nameKey = GeneratedColumn<String>(
    'name_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    hlc,
    deviceId,
    deletedAt,
    name,
    nameKey,
    kind,
    country,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'institutions';
  @override
  VerificationContext validateIntegrity(
    Insertable<InstitutionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_key')) {
      context.handle(
        _nameKeyMeta,
        nameKey.isAcceptableOrUnknown(data['name_key']!, _nameKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_nameKeyMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    } else if (isInserting) {
      context.missing(_countryMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InstitutionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstitutionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_key'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $InstitutionsTable createAlias(String alias) {
    return $InstitutionsTable(attachedDatabase, alias);
  }
}

class InstitutionRow extends DataClass implements Insertable<InstitutionRow> {
  /// UUID v7 gerado no app.
  final String id;

  /// Instante UTC da criação (ISO-8601 com ms).
  final String createdAt;

  /// Instante UTC da última escrita.
  final String updatedAt;

  /// HLC da última alteração.
  final String hlc;

  /// Dispositivo que fez a última alteração.
  final String deviceId;

  /// Tombstone: preenchido na exclusão lógica.
  final String? deletedAt;
  final String name;

  /// Nome normalizado: chave natural para detectar duplicatas.
  final String nameKey;
  final String kind;
  final String country;
  final String? notes;
  const InstitutionRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.hlc,
    required this.deviceId,
    this.deletedAt,
    required this.name,
    required this.nameKey,
    required this.kind,
    required this.country,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['hlc'] = Variable<String>(hlc);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    map['name_key'] = Variable<String>(nameKey);
    map['kind'] = Variable<String>(kind);
    map['country'] = Variable<String>(country);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  InstitutionsCompanion toCompanion(bool nullToAbsent) {
    return InstitutionsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      hlc: Value(hlc),
      deviceId: Value(deviceId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      nameKey: Value(nameKey),
      kind: Value(kind),
      country: Value(country),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory InstitutionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstitutionRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      nameKey: serializer.fromJson<String>(json['nameKey']),
      kind: serializer.fromJson<String>(json['kind']),
      country: serializer.fromJson<String>(json['country']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'hlc': serializer.toJson<String>(hlc),
      'deviceId': serializer.toJson<String>(deviceId),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'nameKey': serializer.toJson<String>(nameKey),
      'kind': serializer.toJson<String>(kind),
      'country': serializer.toJson<String>(country),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  InstitutionRow copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? hlc,
    String? deviceId,
    Value<String?> deletedAt = const Value.absent(),
    String? name,
    String? nameKey,
    String? kind,
    String? country,
    Value<String?> notes = const Value.absent(),
  }) => InstitutionRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    hlc: hlc ?? this.hlc,
    deviceId: deviceId ?? this.deviceId,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    nameKey: nameKey ?? this.nameKey,
    kind: kind ?? this.kind,
    country: country ?? this.country,
    notes: notes.present ? notes.value : this.notes,
  );
  InstitutionRow copyWithCompanion(InstitutionsCompanion data) {
    return InstitutionRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      nameKey: data.nameKey.present ? data.nameKey.value : this.nameKey,
      kind: data.kind.present ? data.kind.value : this.kind,
      country: data.country.present ? data.country.value : this.country,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstitutionRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hlc: $hlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey, ')
          ..write('kind: $kind, ')
          ..write('country: $country, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    hlc,
    deviceId,
    deletedAt,
    name,
    nameKey,
    kind,
    country,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstitutionRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.hlc == this.hlc &&
          other.deviceId == this.deviceId &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.nameKey == this.nameKey &&
          other.kind == this.kind &&
          other.country == this.country &&
          other.notes == this.notes);
}

class InstitutionsCompanion extends UpdateCompanion<InstitutionRow> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> hlc;
  final Value<String> deviceId;
  final Value<String?> deletedAt;
  final Value<String> name;
  final Value<String> nameKey;
  final Value<String> kind;
  final Value<String> country;
  final Value<String?> notes;
  final Value<int> rowid;
  const InstitutionsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.nameKey = const Value.absent(),
    this.kind = const Value.absent(),
    this.country = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstitutionsCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    required String hlc,
    required String deviceId,
    this.deletedAt = const Value.absent(),
    required String name,
    required String nameKey,
    required String kind,
    required String country,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       hlc = Value(hlc),
       deviceId = Value(deviceId),
       name = Value(name),
       nameKey = Value(nameKey),
       kind = Value(kind),
       country = Value(country);
  static Insertable<InstitutionRow> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? hlc,
    Expression<String>? deviceId,
    Expression<String>? deletedAt,
    Expression<String>? name,
    Expression<String>? nameKey,
    Expression<String>? kind,
    Expression<String>? country,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (hlc != null) 'hlc': hlc,
      if (deviceId != null) 'device_id': deviceId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (nameKey != null) 'name_key': nameKey,
      if (kind != null) 'kind': kind,
      if (country != null) 'country': country,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstitutionsCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? hlc,
    Value<String>? deviceId,
    Value<String?>? deletedAt,
    Value<String>? name,
    Value<String>? nameKey,
    Value<String>? kind,
    Value<String>? country,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return InstitutionsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hlc: hlc ?? this.hlc,
      deviceId: deviceId ?? this.deviceId,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      nameKey: nameKey ?? this.nameKey,
      kind: kind ?? this.kind,
      country: country ?? this.country,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameKey.present) {
      map['name_key'] = Variable<String>(nameKey.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstitutionsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hlc: $hlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey, ')
          ..write('kind: $kind, ')
          ..write('country: $country, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountsTable extends Accounts
    with TableInfo<$AccountsTable, AccountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _institutionIdMeta = const VerificationMeta(
    'institutionId',
  );
  @override
  late final GeneratedColumn<String> institutionId = GeneratedColumn<String>(
    'institution_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES institutions (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<String> archivedAt = GeneratedColumn<String>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    hlc,
    deviceId,
    deletedAt,
    institutionId,
    name,
    kind,
    currency,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('institution_id')) {
      context.handle(
        _institutionIdMeta,
        institutionId.isAcceptableOrUnknown(
          data['institution_id']!,
          _institutionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_institutionIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      institutionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}institution_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class AccountRow extends DataClass implements Insertable<AccountRow> {
  /// UUID v7 gerado no app.
  final String id;

  /// Instante UTC da criação (ISO-8601 com ms).
  final String createdAt;

  /// Instante UTC da última escrita.
  final String updatedAt;

  /// HLC da última alteração.
  final String hlc;

  /// Dispositivo que fez a última alteração.
  final String deviceId;

  /// Tombstone: preenchido na exclusão lógica.
  final String? deletedAt;
  final String institutionId;
  final String name;
  final String kind;
  final String currency;
  final String? archivedAt;
  const AccountRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.hlc,
    required this.deviceId,
    this.deletedAt,
    required this.institutionId,
    required this.name,
    required this.kind,
    required this.currency,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['hlc'] = Variable<String>(hlc);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['institution_id'] = Variable<String>(institutionId);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<String>(archivedAt);
    }
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      hlc: Value(hlc),
      deviceId: Value(deviceId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      institutionId: Value(institutionId),
      name: Value(name),
      kind: Value(kind),
      currency: Value(currency),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory AccountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      institutionId: serializer.fromJson<String>(json['institutionId']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      currency: serializer.fromJson<String>(json['currency']),
      archivedAt: serializer.fromJson<String?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'hlc': serializer.toJson<String>(hlc),
      'deviceId': serializer.toJson<String>(deviceId),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'institutionId': serializer.toJson<String>(institutionId),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'currency': serializer.toJson<String>(currency),
      'archivedAt': serializer.toJson<String?>(archivedAt),
    };
  }

  AccountRow copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? hlc,
    String? deviceId,
    Value<String?> deletedAt = const Value.absent(),
    String? institutionId,
    String? name,
    String? kind,
    String? currency,
    Value<String?> archivedAt = const Value.absent(),
  }) => AccountRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    hlc: hlc ?? this.hlc,
    deviceId: deviceId ?? this.deviceId,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    institutionId: institutionId ?? this.institutionId,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    currency: currency ?? this.currency,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  AccountRow copyWithCompanion(AccountsCompanion data) {
    return AccountRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      institutionId: data.institutionId.present
          ? data.institutionId.value
          : this.institutionId,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      currency: data.currency.present ? data.currency.value : this.currency,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hlc: $hlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('institutionId: $institutionId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('currency: $currency, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    hlc,
    deviceId,
    deletedAt,
    institutionId,
    name,
    kind,
    currency,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.hlc == this.hlc &&
          other.deviceId == this.deviceId &&
          other.deletedAt == this.deletedAt &&
          other.institutionId == this.institutionId &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.currency == this.currency &&
          other.archivedAt == this.archivedAt);
}

class AccountsCompanion extends UpdateCompanion<AccountRow> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> hlc;
  final Value<String> deviceId;
  final Value<String?> deletedAt;
  final Value<String> institutionId;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> currency;
  final Value<String?> archivedAt;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.institutionId = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.currency = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    required String hlc,
    required String deviceId,
    this.deletedAt = const Value.absent(),
    required String institutionId,
    required String name,
    required String kind,
    required String currency,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       hlc = Value(hlc),
       deviceId = Value(deviceId),
       institutionId = Value(institutionId),
       name = Value(name),
       kind = Value(kind),
       currency = Value(currency);
  static Insertable<AccountRow> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? hlc,
    Expression<String>? deviceId,
    Expression<String>? deletedAt,
    Expression<String>? institutionId,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? currency,
    Expression<String>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (hlc != null) 'hlc': hlc,
      if (deviceId != null) 'device_id': deviceId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (institutionId != null) 'institution_id': institutionId,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (currency != null) 'currency': currency,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? hlc,
    Value<String>? deviceId,
    Value<String?>? deletedAt,
    Value<String>? institutionId,
    Value<String>? name,
    Value<String>? kind,
    Value<String>? currency,
    Value<String?>? archivedAt,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hlc: hlc ?? this.hlc,
      deviceId: deviceId ?? this.deviceId,
      deletedAt: deletedAt ?? this.deletedAt,
      institutionId: institutionId ?? this.institutionId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      currency: currency ?? this.currency,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (institutionId.present) {
      map['institution_id'] = Variable<String>(institutionId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<String>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hlc: $hlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('institutionId: $institutionId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('currency: $currency, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssetsTable extends Assets with TableInfo<$AssetsTable, AssetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marketMeta = const VerificationMeta('market');
  @override
  late final GeneratedColumn<String> market = GeneratedColumn<String>(
    'market',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assetClassMeta = const VerificationMeta(
    'assetClass',
  );
  @override
  late final GeneratedColumn<String> assetClass = GeneratedColumn<String>(
    'asset_class',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isinMeta = const VerificationMeta('isin');
  @override
  late final GeneratedColumn<String> isin = GeneratedColumn<String>(
    'isin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sectorMeta = const VerificationMeta('sector');
  @override
  late final GeneratedColumn<String> sector = GeneratedColumn<String>(
    'sector',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _segmentMeta = const VerificationMeta(
    'segment',
  );
  @override
  late final GeneratedColumn<String> segment = GeneratedColumn<String>(
    'segment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _liquidityMeta = const VerificationMeta(
    'liquidity',
  );
  @override
  late final GeneratedColumn<String> liquidity = GeneratedColumn<String>(
    'liquidity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceSourceMeta = const VerificationMeta(
    'priceSource',
  );
  @override
  late final GeneratedColumn<String> priceSource = GeneratedColumn<String>(
    'price_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    hlc,
    deviceId,
    deletedAt,
    symbol,
    market,
    assetClass,
    name,
    currency,
    country,
    isin,
    sector,
    segment,
    liquidity,
    priceSource,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('market')) {
      context.handle(
        _marketMeta,
        market.isAcceptableOrUnknown(data['market']!, _marketMeta),
      );
    } else if (isInserting) {
      context.missing(_marketMeta);
    }
    if (data.containsKey('asset_class')) {
      context.handle(
        _assetClassMeta,
        assetClass.isAcceptableOrUnknown(data['asset_class']!, _assetClassMeta),
      );
    } else if (isInserting) {
      context.missing(_assetClassMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    } else if (isInserting) {
      context.missing(_countryMeta);
    }
    if (data.containsKey('isin')) {
      context.handle(
        _isinMeta,
        isin.isAcceptableOrUnknown(data['isin']!, _isinMeta),
      );
    }
    if (data.containsKey('sector')) {
      context.handle(
        _sectorMeta,
        sector.isAcceptableOrUnknown(data['sector']!, _sectorMeta),
      );
    }
    if (data.containsKey('segment')) {
      context.handle(
        _segmentMeta,
        segment.isAcceptableOrUnknown(data['segment']!, _segmentMeta),
      );
    }
    if (data.containsKey('liquidity')) {
      context.handle(
        _liquidityMeta,
        liquidity.isAcceptableOrUnknown(data['liquidity']!, _liquidityMeta),
      );
    }
    if (data.containsKey('price_source')) {
      context.handle(
        _priceSourceMeta,
        priceSource.isAcceptableOrUnknown(
          data['price_source']!,
          _priceSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_priceSourceMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      market: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}market'],
      )!,
      assetClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_class'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      )!,
      isin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isin'],
      ),
      sector: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sector'],
      ),
      segment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}segment'],
      ),
      liquidity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}liquidity'],
      ),
      priceSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}price_source'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $AssetsTable createAlias(String alias) {
    return $AssetsTable(attachedDatabase, alias);
  }
}

class AssetRow extends DataClass implements Insertable<AssetRow> {
  /// UUID v7 gerado no app.
  final String id;

  /// Instante UTC da criação (ISO-8601 com ms).
  final String createdAt;

  /// Instante UTC da última escrita.
  final String updatedAt;

  /// HLC da última alteração.
  final String hlc;

  /// Dispositivo que fez a última alteração.
  final String deviceId;

  /// Tombstone: preenchido na exclusão lógica.
  final String? deletedAt;
  final String symbol;
  final String market;
  final String assetClass;
  final String name;
  final String currency;
  final String country;
  final String? isin;
  final String? sector;
  final String? segment;
  final String? liquidity;

  /// `market` (cotação dos provedores, F6) ou `manual`.
  final String priceSource;
  final String? notes;
  const AssetRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.hlc,
    required this.deviceId,
    this.deletedAt,
    required this.symbol,
    required this.market,
    required this.assetClass,
    required this.name,
    required this.currency,
    required this.country,
    this.isin,
    this.sector,
    this.segment,
    this.liquidity,
    required this.priceSource,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['hlc'] = Variable<String>(hlc);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['symbol'] = Variable<String>(symbol);
    map['market'] = Variable<String>(market);
    map['asset_class'] = Variable<String>(assetClass);
    map['name'] = Variable<String>(name);
    map['currency'] = Variable<String>(currency);
    map['country'] = Variable<String>(country);
    if (!nullToAbsent || isin != null) {
      map['isin'] = Variable<String>(isin);
    }
    if (!nullToAbsent || sector != null) {
      map['sector'] = Variable<String>(sector);
    }
    if (!nullToAbsent || segment != null) {
      map['segment'] = Variable<String>(segment);
    }
    if (!nullToAbsent || liquidity != null) {
      map['liquidity'] = Variable<String>(liquidity);
    }
    map['price_source'] = Variable<String>(priceSource);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  AssetsCompanion toCompanion(bool nullToAbsent) {
    return AssetsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      hlc: Value(hlc),
      deviceId: Value(deviceId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      symbol: Value(symbol),
      market: Value(market),
      assetClass: Value(assetClass),
      name: Value(name),
      currency: Value(currency),
      country: Value(country),
      isin: isin == null && nullToAbsent ? const Value.absent() : Value(isin),
      sector: sector == null && nullToAbsent
          ? const Value.absent()
          : Value(sector),
      segment: segment == null && nullToAbsent
          ? const Value.absent()
          : Value(segment),
      liquidity: liquidity == null && nullToAbsent
          ? const Value.absent()
          : Value(liquidity),
      priceSource: Value(priceSource),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory AssetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      symbol: serializer.fromJson<String>(json['symbol']),
      market: serializer.fromJson<String>(json['market']),
      assetClass: serializer.fromJson<String>(json['assetClass']),
      name: serializer.fromJson<String>(json['name']),
      currency: serializer.fromJson<String>(json['currency']),
      country: serializer.fromJson<String>(json['country']),
      isin: serializer.fromJson<String?>(json['isin']),
      sector: serializer.fromJson<String?>(json['sector']),
      segment: serializer.fromJson<String?>(json['segment']),
      liquidity: serializer.fromJson<String?>(json['liquidity']),
      priceSource: serializer.fromJson<String>(json['priceSource']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'hlc': serializer.toJson<String>(hlc),
      'deviceId': serializer.toJson<String>(deviceId),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'symbol': serializer.toJson<String>(symbol),
      'market': serializer.toJson<String>(market),
      'assetClass': serializer.toJson<String>(assetClass),
      'name': serializer.toJson<String>(name),
      'currency': serializer.toJson<String>(currency),
      'country': serializer.toJson<String>(country),
      'isin': serializer.toJson<String?>(isin),
      'sector': serializer.toJson<String?>(sector),
      'segment': serializer.toJson<String?>(segment),
      'liquidity': serializer.toJson<String?>(liquidity),
      'priceSource': serializer.toJson<String>(priceSource),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  AssetRow copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? hlc,
    String? deviceId,
    Value<String?> deletedAt = const Value.absent(),
    String? symbol,
    String? market,
    String? assetClass,
    String? name,
    String? currency,
    String? country,
    Value<String?> isin = const Value.absent(),
    Value<String?> sector = const Value.absent(),
    Value<String?> segment = const Value.absent(),
    Value<String?> liquidity = const Value.absent(),
    String? priceSource,
    Value<String?> notes = const Value.absent(),
  }) => AssetRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    hlc: hlc ?? this.hlc,
    deviceId: deviceId ?? this.deviceId,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    symbol: symbol ?? this.symbol,
    market: market ?? this.market,
    assetClass: assetClass ?? this.assetClass,
    name: name ?? this.name,
    currency: currency ?? this.currency,
    country: country ?? this.country,
    isin: isin.present ? isin.value : this.isin,
    sector: sector.present ? sector.value : this.sector,
    segment: segment.present ? segment.value : this.segment,
    liquidity: liquidity.present ? liquidity.value : this.liquidity,
    priceSource: priceSource ?? this.priceSource,
    notes: notes.present ? notes.value : this.notes,
  );
  AssetRow copyWithCompanion(AssetsCompanion data) {
    return AssetRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      market: data.market.present ? data.market.value : this.market,
      assetClass: data.assetClass.present
          ? data.assetClass.value
          : this.assetClass,
      name: data.name.present ? data.name.value : this.name,
      currency: data.currency.present ? data.currency.value : this.currency,
      country: data.country.present ? data.country.value : this.country,
      isin: data.isin.present ? data.isin.value : this.isin,
      sector: data.sector.present ? data.sector.value : this.sector,
      segment: data.segment.present ? data.segment.value : this.segment,
      liquidity: data.liquidity.present ? data.liquidity.value : this.liquidity,
      priceSource: data.priceSource.present
          ? data.priceSource.value
          : this.priceSource,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hlc: $hlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('symbol: $symbol, ')
          ..write('market: $market, ')
          ..write('assetClass: $assetClass, ')
          ..write('name: $name, ')
          ..write('currency: $currency, ')
          ..write('country: $country, ')
          ..write('isin: $isin, ')
          ..write('sector: $sector, ')
          ..write('segment: $segment, ')
          ..write('liquidity: $liquidity, ')
          ..write('priceSource: $priceSource, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    hlc,
    deviceId,
    deletedAt,
    symbol,
    market,
    assetClass,
    name,
    currency,
    country,
    isin,
    sector,
    segment,
    liquidity,
    priceSource,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.hlc == this.hlc &&
          other.deviceId == this.deviceId &&
          other.deletedAt == this.deletedAt &&
          other.symbol == this.symbol &&
          other.market == this.market &&
          other.assetClass == this.assetClass &&
          other.name == this.name &&
          other.currency == this.currency &&
          other.country == this.country &&
          other.isin == this.isin &&
          other.sector == this.sector &&
          other.segment == this.segment &&
          other.liquidity == this.liquidity &&
          other.priceSource == this.priceSource &&
          other.notes == this.notes);
}

class AssetsCompanion extends UpdateCompanion<AssetRow> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> hlc;
  final Value<String> deviceId;
  final Value<String?> deletedAt;
  final Value<String> symbol;
  final Value<String> market;
  final Value<String> assetClass;
  final Value<String> name;
  final Value<String> currency;
  final Value<String> country;
  final Value<String?> isin;
  final Value<String?> sector;
  final Value<String?> segment;
  final Value<String?> liquidity;
  final Value<String> priceSource;
  final Value<String?> notes;
  final Value<int> rowid;
  const AssetsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.symbol = const Value.absent(),
    this.market = const Value.absent(),
    this.assetClass = const Value.absent(),
    this.name = const Value.absent(),
    this.currency = const Value.absent(),
    this.country = const Value.absent(),
    this.isin = const Value.absent(),
    this.sector = const Value.absent(),
    this.segment = const Value.absent(),
    this.liquidity = const Value.absent(),
    this.priceSource = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssetsCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    required String hlc,
    required String deviceId,
    this.deletedAt = const Value.absent(),
    required String symbol,
    required String market,
    required String assetClass,
    required String name,
    required String currency,
    required String country,
    this.isin = const Value.absent(),
    this.sector = const Value.absent(),
    this.segment = const Value.absent(),
    this.liquidity = const Value.absent(),
    required String priceSource,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       hlc = Value(hlc),
       deviceId = Value(deviceId),
       symbol = Value(symbol),
       market = Value(market),
       assetClass = Value(assetClass),
       name = Value(name),
       currency = Value(currency),
       country = Value(country),
       priceSource = Value(priceSource);
  static Insertable<AssetRow> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? hlc,
    Expression<String>? deviceId,
    Expression<String>? deletedAt,
    Expression<String>? symbol,
    Expression<String>? market,
    Expression<String>? assetClass,
    Expression<String>? name,
    Expression<String>? currency,
    Expression<String>? country,
    Expression<String>? isin,
    Expression<String>? sector,
    Expression<String>? segment,
    Expression<String>? liquidity,
    Expression<String>? priceSource,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (hlc != null) 'hlc': hlc,
      if (deviceId != null) 'device_id': deviceId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (symbol != null) 'symbol': symbol,
      if (market != null) 'market': market,
      if (assetClass != null) 'asset_class': assetClass,
      if (name != null) 'name': name,
      if (currency != null) 'currency': currency,
      if (country != null) 'country': country,
      if (isin != null) 'isin': isin,
      if (sector != null) 'sector': sector,
      if (segment != null) 'segment': segment,
      if (liquidity != null) 'liquidity': liquidity,
      if (priceSource != null) 'price_source': priceSource,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssetsCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? hlc,
    Value<String>? deviceId,
    Value<String?>? deletedAt,
    Value<String>? symbol,
    Value<String>? market,
    Value<String>? assetClass,
    Value<String>? name,
    Value<String>? currency,
    Value<String>? country,
    Value<String?>? isin,
    Value<String?>? sector,
    Value<String?>? segment,
    Value<String?>? liquidity,
    Value<String>? priceSource,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return AssetsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hlc: hlc ?? this.hlc,
      deviceId: deviceId ?? this.deviceId,
      deletedAt: deletedAt ?? this.deletedAt,
      symbol: symbol ?? this.symbol,
      market: market ?? this.market,
      assetClass: assetClass ?? this.assetClass,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      country: country ?? this.country,
      isin: isin ?? this.isin,
      sector: sector ?? this.sector,
      segment: segment ?? this.segment,
      liquidity: liquidity ?? this.liquidity,
      priceSource: priceSource ?? this.priceSource,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (market.present) {
      map['market'] = Variable<String>(market.value);
    }
    if (assetClass.present) {
      map['asset_class'] = Variable<String>(assetClass.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (isin.present) {
      map['isin'] = Variable<String>(isin.value);
    }
    if (sector.present) {
      map['sector'] = Variable<String>(sector.value);
    }
    if (segment.present) {
      map['segment'] = Variable<String>(segment.value);
    }
    if (liquidity.present) {
      map['liquidity'] = Variable<String>(liquidity.value);
    }
    if (priceSource.present) {
      map['price_source'] = Variable<String>(priceSource.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hlc: $hlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('symbol: $symbol, ')
          ..write('market: $market, ')
          ..write('assetClass: $assetClass, ')
          ..write('name: $name, ')
          ..write('currency: $currency, ')
          ..write('country: $country, ')
          ..write('isin: $isin, ')
          ..write('sector: $sector, ')
          ..write('segment: $segment, ')
          ..write('liquidity: $liquidity, ')
          ..write('priceSource: $priceSource, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FixedIncomeTermsTable extends FixedIncomeTerms
    with TableInfo<$FixedIncomeTermsTable, FixedIncomeTermsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FixedIncomeTermsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES assets (id)',
    ),
  );
  static const VerificationMeta _productMeta = const VerificationMeta(
    'product',
  );
  @override
  late final GeneratedColumn<String> product = GeneratedColumn<String>(
    'product',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _issuerMeta = const VerificationMeta('issuer');
  @override
  late final GeneratedColumn<String> issuer = GeneratedColumn<String>(
    'issuer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _indexerMeta = const VerificationMeta(
    'indexer',
  );
  @override
  late final GeneratedColumn<String> indexer = GeneratedColumn<String>(
    'indexer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal, String> rate =
      GeneratedColumn<String>(
        'rate',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Decimal>($FixedIncomeTermsTable.$converterrate);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> spread =
      GeneratedColumn<String>(
        'spread',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($FixedIncomeTermsTable.$converterspreadn);
  static const VerificationMeta _dayCountMeta = const VerificationMeta(
    'dayCount',
  );
  @override
  late final GeneratedColumn<String> dayCount = GeneratedColumn<String>(
    'day_count',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _issueDateMeta = const VerificationMeta(
    'issueDate',
  );
  @override
  late final GeneratedColumn<String> issueDate = GeneratedColumn<String>(
    'issue_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maturityDateMeta = const VerificationMeta(
    'maturityDate',
  );
  @override
  late final GeneratedColumn<String> maturityDate = GeneratedColumn<String>(
    'maturity_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _graceUntilMeta = const VerificationMeta(
    'graceUntil',
  );
  @override
  late final GeneratedColumn<String> graceUntil = GeneratedColumn<String>(
    'grace_until',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _liquidityMeta = const VerificationMeta(
    'liquidity',
  );
  @override
  late final GeneratedColumn<String> liquidity = GeneratedColumn<String>(
    'liquidity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taxRegimeMeta = const VerificationMeta(
    'taxRegime',
  );
  @override
  late final GeneratedColumn<String> taxRegime = GeneratedColumn<String>(
    'tax_regime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costsNotesMeta = const VerificationMeta(
    'costsNotes',
  );
  @override
  late final GeneratedColumn<String> costsNotes = GeneratedColumn<String>(
    'costs_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    hlc,
    deviceId,
    deletedAt,
    assetId,
    product,
    issuer,
    indexer,
    rate,
    spread,
    dayCount,
    issueDate,
    maturityDate,
    graceUntil,
    liquidity,
    taxRegime,
    costsNotes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fixed_income_terms';
  @override
  VerificationContext validateIntegrity(
    Insertable<FixedIncomeTermsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('product')) {
      context.handle(
        _productMeta,
        product.isAcceptableOrUnknown(data['product']!, _productMeta),
      );
    } else if (isInserting) {
      context.missing(_productMeta);
    }
    if (data.containsKey('issuer')) {
      context.handle(
        _issuerMeta,
        issuer.isAcceptableOrUnknown(data['issuer']!, _issuerMeta),
      );
    }
    if (data.containsKey('indexer')) {
      context.handle(
        _indexerMeta,
        indexer.isAcceptableOrUnknown(data['indexer']!, _indexerMeta),
      );
    } else if (isInserting) {
      context.missing(_indexerMeta);
    }
    if (data.containsKey('day_count')) {
      context.handle(
        _dayCountMeta,
        dayCount.isAcceptableOrUnknown(data['day_count']!, _dayCountMeta),
      );
    } else if (isInserting) {
      context.missing(_dayCountMeta);
    }
    if (data.containsKey('issue_date')) {
      context.handle(
        _issueDateMeta,
        issueDate.isAcceptableOrUnknown(data['issue_date']!, _issueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_issueDateMeta);
    }
    if (data.containsKey('maturity_date')) {
      context.handle(
        _maturityDateMeta,
        maturityDate.isAcceptableOrUnknown(
          data['maturity_date']!,
          _maturityDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_maturityDateMeta);
    }
    if (data.containsKey('grace_until')) {
      context.handle(
        _graceUntilMeta,
        graceUntil.isAcceptableOrUnknown(data['grace_until']!, _graceUntilMeta),
      );
    }
    if (data.containsKey('liquidity')) {
      context.handle(
        _liquidityMeta,
        liquidity.isAcceptableOrUnknown(data['liquidity']!, _liquidityMeta),
      );
    } else if (isInserting) {
      context.missing(_liquidityMeta);
    }
    if (data.containsKey('tax_regime')) {
      context.handle(
        _taxRegimeMeta,
        taxRegime.isAcceptableOrUnknown(data['tax_regime']!, _taxRegimeMeta),
      );
    } else if (isInserting) {
      context.missing(_taxRegimeMeta);
    }
    if (data.containsKey('costs_notes')) {
      context.handle(
        _costsNotesMeta,
        costsNotes.isAcceptableOrUnknown(data['costs_notes']!, _costsNotesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FixedIncomeTermsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FixedIncomeTermsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_id'],
      )!,
      product: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product'],
      )!,
      issuer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issuer'],
      ),
      indexer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}indexer'],
      )!,
      rate: $FixedIncomeTermsTable.$converterrate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}rate'],
        )!,
      ),
      spread: $FixedIncomeTermsTable.$converterspreadn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}spread'],
        ),
      ),
      dayCount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_count'],
      )!,
      issueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issue_date'],
      )!,
      maturityDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}maturity_date'],
      )!,
      graceUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grace_until'],
      ),
      liquidity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}liquidity'],
      )!,
      taxRegime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tax_regime'],
      )!,
      costsNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}costs_notes'],
      ),
    );
  }

  @override
  $FixedIncomeTermsTable createAlias(String alias) {
    return $FixedIncomeTermsTable(attachedDatabase, alias);
  }

  static TypeConverter<Decimal, String> $converterrate =
      const DecimalTextConverter();
  static TypeConverter<Decimal, String> $converterspread =
      const DecimalTextConverter();
  static TypeConverter<Decimal?, String?> $converterspreadn =
      NullAwareTypeConverter.wrap($converterspread);
}

class FixedIncomeTermsRow extends DataClass
    implements Insertable<FixedIncomeTermsRow> {
  /// UUID v7 gerado no app.
  final String id;

  /// Instante UTC da criação (ISO-8601 com ms).
  final String createdAt;

  /// Instante UTC da última escrita.
  final String updatedAt;

  /// HLC da última alteração.
  final String hlc;

  /// Dispositivo que fez a última alteração.
  final String deviceId;

  /// Tombstone: preenchido na exclusão lógica.
  final String? deletedAt;
  final String assetId;
  final String product;
  final String? issuer;
  final String indexer;
  final Decimal rate;
  final Decimal? spread;
  final String dayCount;
  final String issueDate;
  final String maturityDate;
  final String? graceUntil;
  final String liquidity;
  final String taxRegime;
  final String? costsNotes;
  const FixedIncomeTermsRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.hlc,
    required this.deviceId,
    this.deletedAt,
    required this.assetId,
    required this.product,
    this.issuer,
    required this.indexer,
    required this.rate,
    this.spread,
    required this.dayCount,
    required this.issueDate,
    required this.maturityDate,
    this.graceUntil,
    required this.liquidity,
    required this.taxRegime,
    this.costsNotes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['hlc'] = Variable<String>(hlc);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['asset_id'] = Variable<String>(assetId);
    map['product'] = Variable<String>(product);
    if (!nullToAbsent || issuer != null) {
      map['issuer'] = Variable<String>(issuer);
    }
    map['indexer'] = Variable<String>(indexer);
    {
      map['rate'] = Variable<String>(
        $FixedIncomeTermsTable.$converterrate.toSql(rate),
      );
    }
    if (!nullToAbsent || spread != null) {
      map['spread'] = Variable<String>(
        $FixedIncomeTermsTable.$converterspreadn.toSql(spread),
      );
    }
    map['day_count'] = Variable<String>(dayCount);
    map['issue_date'] = Variable<String>(issueDate);
    map['maturity_date'] = Variable<String>(maturityDate);
    if (!nullToAbsent || graceUntil != null) {
      map['grace_until'] = Variable<String>(graceUntil);
    }
    map['liquidity'] = Variable<String>(liquidity);
    map['tax_regime'] = Variable<String>(taxRegime);
    if (!nullToAbsent || costsNotes != null) {
      map['costs_notes'] = Variable<String>(costsNotes);
    }
    return map;
  }

  FixedIncomeTermsCompanion toCompanion(bool nullToAbsent) {
    return FixedIncomeTermsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      hlc: Value(hlc),
      deviceId: Value(deviceId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      assetId: Value(assetId),
      product: Value(product),
      issuer: issuer == null && nullToAbsent
          ? const Value.absent()
          : Value(issuer),
      indexer: Value(indexer),
      rate: Value(rate),
      spread: spread == null && nullToAbsent
          ? const Value.absent()
          : Value(spread),
      dayCount: Value(dayCount),
      issueDate: Value(issueDate),
      maturityDate: Value(maturityDate),
      graceUntil: graceUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(graceUntil),
      liquidity: Value(liquidity),
      taxRegime: Value(taxRegime),
      costsNotes: costsNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(costsNotes),
    );
  }

  factory FixedIncomeTermsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FixedIncomeTermsRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      assetId: serializer.fromJson<String>(json['assetId']),
      product: serializer.fromJson<String>(json['product']),
      issuer: serializer.fromJson<String?>(json['issuer']),
      indexer: serializer.fromJson<String>(json['indexer']),
      rate: serializer.fromJson<Decimal>(json['rate']),
      spread: serializer.fromJson<Decimal?>(json['spread']),
      dayCount: serializer.fromJson<String>(json['dayCount']),
      issueDate: serializer.fromJson<String>(json['issueDate']),
      maturityDate: serializer.fromJson<String>(json['maturityDate']),
      graceUntil: serializer.fromJson<String?>(json['graceUntil']),
      liquidity: serializer.fromJson<String>(json['liquidity']),
      taxRegime: serializer.fromJson<String>(json['taxRegime']),
      costsNotes: serializer.fromJson<String?>(json['costsNotes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'hlc': serializer.toJson<String>(hlc),
      'deviceId': serializer.toJson<String>(deviceId),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'assetId': serializer.toJson<String>(assetId),
      'product': serializer.toJson<String>(product),
      'issuer': serializer.toJson<String?>(issuer),
      'indexer': serializer.toJson<String>(indexer),
      'rate': serializer.toJson<Decimal>(rate),
      'spread': serializer.toJson<Decimal?>(spread),
      'dayCount': serializer.toJson<String>(dayCount),
      'issueDate': serializer.toJson<String>(issueDate),
      'maturityDate': serializer.toJson<String>(maturityDate),
      'graceUntil': serializer.toJson<String?>(graceUntil),
      'liquidity': serializer.toJson<String>(liquidity),
      'taxRegime': serializer.toJson<String>(taxRegime),
      'costsNotes': serializer.toJson<String?>(costsNotes),
    };
  }

  FixedIncomeTermsRow copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? hlc,
    String? deviceId,
    Value<String?> deletedAt = const Value.absent(),
    String? assetId,
    String? product,
    Value<String?> issuer = const Value.absent(),
    String? indexer,
    Decimal? rate,
    Value<Decimal?> spread = const Value.absent(),
    String? dayCount,
    String? issueDate,
    String? maturityDate,
    Value<String?> graceUntil = const Value.absent(),
    String? liquidity,
    String? taxRegime,
    Value<String?> costsNotes = const Value.absent(),
  }) => FixedIncomeTermsRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    hlc: hlc ?? this.hlc,
    deviceId: deviceId ?? this.deviceId,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    assetId: assetId ?? this.assetId,
    product: product ?? this.product,
    issuer: issuer.present ? issuer.value : this.issuer,
    indexer: indexer ?? this.indexer,
    rate: rate ?? this.rate,
    spread: spread.present ? spread.value : this.spread,
    dayCount: dayCount ?? this.dayCount,
    issueDate: issueDate ?? this.issueDate,
    maturityDate: maturityDate ?? this.maturityDate,
    graceUntil: graceUntil.present ? graceUntil.value : this.graceUntil,
    liquidity: liquidity ?? this.liquidity,
    taxRegime: taxRegime ?? this.taxRegime,
    costsNotes: costsNotes.present ? costsNotes.value : this.costsNotes,
  );
  FixedIncomeTermsRow copyWithCompanion(FixedIncomeTermsCompanion data) {
    return FixedIncomeTermsRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      product: data.product.present ? data.product.value : this.product,
      issuer: data.issuer.present ? data.issuer.value : this.issuer,
      indexer: data.indexer.present ? data.indexer.value : this.indexer,
      rate: data.rate.present ? data.rate.value : this.rate,
      spread: data.spread.present ? data.spread.value : this.spread,
      dayCount: data.dayCount.present ? data.dayCount.value : this.dayCount,
      issueDate: data.issueDate.present ? data.issueDate.value : this.issueDate,
      maturityDate: data.maturityDate.present
          ? data.maturityDate.value
          : this.maturityDate,
      graceUntil: data.graceUntil.present
          ? data.graceUntil.value
          : this.graceUntil,
      liquidity: data.liquidity.present ? data.liquidity.value : this.liquidity,
      taxRegime: data.taxRegime.present ? data.taxRegime.value : this.taxRegime,
      costsNotes: data.costsNotes.present
          ? data.costsNotes.value
          : this.costsNotes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FixedIncomeTermsRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hlc: $hlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('assetId: $assetId, ')
          ..write('product: $product, ')
          ..write('issuer: $issuer, ')
          ..write('indexer: $indexer, ')
          ..write('rate: $rate, ')
          ..write('spread: $spread, ')
          ..write('dayCount: $dayCount, ')
          ..write('issueDate: $issueDate, ')
          ..write('maturityDate: $maturityDate, ')
          ..write('graceUntil: $graceUntil, ')
          ..write('liquidity: $liquidity, ')
          ..write('taxRegime: $taxRegime, ')
          ..write('costsNotes: $costsNotes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    hlc,
    deviceId,
    deletedAt,
    assetId,
    product,
    issuer,
    indexer,
    rate,
    spread,
    dayCount,
    issueDate,
    maturityDate,
    graceUntil,
    liquidity,
    taxRegime,
    costsNotes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FixedIncomeTermsRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.hlc == this.hlc &&
          other.deviceId == this.deviceId &&
          other.deletedAt == this.deletedAt &&
          other.assetId == this.assetId &&
          other.product == this.product &&
          other.issuer == this.issuer &&
          other.indexer == this.indexer &&
          other.rate == this.rate &&
          other.spread == this.spread &&
          other.dayCount == this.dayCount &&
          other.issueDate == this.issueDate &&
          other.maturityDate == this.maturityDate &&
          other.graceUntil == this.graceUntil &&
          other.liquidity == this.liquidity &&
          other.taxRegime == this.taxRegime &&
          other.costsNotes == this.costsNotes);
}

class FixedIncomeTermsCompanion extends UpdateCompanion<FixedIncomeTermsRow> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> hlc;
  final Value<String> deviceId;
  final Value<String?> deletedAt;
  final Value<String> assetId;
  final Value<String> product;
  final Value<String?> issuer;
  final Value<String> indexer;
  final Value<Decimal> rate;
  final Value<Decimal?> spread;
  final Value<String> dayCount;
  final Value<String> issueDate;
  final Value<String> maturityDate;
  final Value<String?> graceUntil;
  final Value<String> liquidity;
  final Value<String> taxRegime;
  final Value<String?> costsNotes;
  final Value<int> rowid;
  const FixedIncomeTermsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.assetId = const Value.absent(),
    this.product = const Value.absent(),
    this.issuer = const Value.absent(),
    this.indexer = const Value.absent(),
    this.rate = const Value.absent(),
    this.spread = const Value.absent(),
    this.dayCount = const Value.absent(),
    this.issueDate = const Value.absent(),
    this.maturityDate = const Value.absent(),
    this.graceUntil = const Value.absent(),
    this.liquidity = const Value.absent(),
    this.taxRegime = const Value.absent(),
    this.costsNotes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FixedIncomeTermsCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    required String hlc,
    required String deviceId,
    this.deletedAt = const Value.absent(),
    required String assetId,
    required String product,
    this.issuer = const Value.absent(),
    required String indexer,
    required Decimal rate,
    this.spread = const Value.absent(),
    required String dayCount,
    required String issueDate,
    required String maturityDate,
    this.graceUntil = const Value.absent(),
    required String liquidity,
    required String taxRegime,
    this.costsNotes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       hlc = Value(hlc),
       deviceId = Value(deviceId),
       assetId = Value(assetId),
       product = Value(product),
       indexer = Value(indexer),
       rate = Value(rate),
       dayCount = Value(dayCount),
       issueDate = Value(issueDate),
       maturityDate = Value(maturityDate),
       liquidity = Value(liquidity),
       taxRegime = Value(taxRegime);
  static Insertable<FixedIncomeTermsRow> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? hlc,
    Expression<String>? deviceId,
    Expression<String>? deletedAt,
    Expression<String>? assetId,
    Expression<String>? product,
    Expression<String>? issuer,
    Expression<String>? indexer,
    Expression<String>? rate,
    Expression<String>? spread,
    Expression<String>? dayCount,
    Expression<String>? issueDate,
    Expression<String>? maturityDate,
    Expression<String>? graceUntil,
    Expression<String>? liquidity,
    Expression<String>? taxRegime,
    Expression<String>? costsNotes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (hlc != null) 'hlc': hlc,
      if (deviceId != null) 'device_id': deviceId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (assetId != null) 'asset_id': assetId,
      if (product != null) 'product': product,
      if (issuer != null) 'issuer': issuer,
      if (indexer != null) 'indexer': indexer,
      if (rate != null) 'rate': rate,
      if (spread != null) 'spread': spread,
      if (dayCount != null) 'day_count': dayCount,
      if (issueDate != null) 'issue_date': issueDate,
      if (maturityDate != null) 'maturity_date': maturityDate,
      if (graceUntil != null) 'grace_until': graceUntil,
      if (liquidity != null) 'liquidity': liquidity,
      if (taxRegime != null) 'tax_regime': taxRegime,
      if (costsNotes != null) 'costs_notes': costsNotes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FixedIncomeTermsCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? hlc,
    Value<String>? deviceId,
    Value<String?>? deletedAt,
    Value<String>? assetId,
    Value<String>? product,
    Value<String?>? issuer,
    Value<String>? indexer,
    Value<Decimal>? rate,
    Value<Decimal?>? spread,
    Value<String>? dayCount,
    Value<String>? issueDate,
    Value<String>? maturityDate,
    Value<String?>? graceUntil,
    Value<String>? liquidity,
    Value<String>? taxRegime,
    Value<String?>? costsNotes,
    Value<int>? rowid,
  }) {
    return FixedIncomeTermsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hlc: hlc ?? this.hlc,
      deviceId: deviceId ?? this.deviceId,
      deletedAt: deletedAt ?? this.deletedAt,
      assetId: assetId ?? this.assetId,
      product: product ?? this.product,
      issuer: issuer ?? this.issuer,
      indexer: indexer ?? this.indexer,
      rate: rate ?? this.rate,
      spread: spread ?? this.spread,
      dayCount: dayCount ?? this.dayCount,
      issueDate: issueDate ?? this.issueDate,
      maturityDate: maturityDate ?? this.maturityDate,
      graceUntil: graceUntil ?? this.graceUntil,
      liquidity: liquidity ?? this.liquidity,
      taxRegime: taxRegime ?? this.taxRegime,
      costsNotes: costsNotes ?? this.costsNotes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (product.present) {
      map['product'] = Variable<String>(product.value);
    }
    if (issuer.present) {
      map['issuer'] = Variable<String>(issuer.value);
    }
    if (indexer.present) {
      map['indexer'] = Variable<String>(indexer.value);
    }
    if (rate.present) {
      map['rate'] = Variable<String>(
        $FixedIncomeTermsTable.$converterrate.toSql(rate.value),
      );
    }
    if (spread.present) {
      map['spread'] = Variable<String>(
        $FixedIncomeTermsTable.$converterspreadn.toSql(spread.value),
      );
    }
    if (dayCount.present) {
      map['day_count'] = Variable<String>(dayCount.value);
    }
    if (issueDate.present) {
      map['issue_date'] = Variable<String>(issueDate.value);
    }
    if (maturityDate.present) {
      map['maturity_date'] = Variable<String>(maturityDate.value);
    }
    if (graceUntil.present) {
      map['grace_until'] = Variable<String>(graceUntil.value);
    }
    if (liquidity.present) {
      map['liquidity'] = Variable<String>(liquidity.value);
    }
    if (taxRegime.present) {
      map['tax_regime'] = Variable<String>(taxRegime.value);
    }
    if (costsNotes.present) {
      map['costs_notes'] = Variable<String>(costsNotes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FixedIncomeTermsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hlc: $hlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('assetId: $assetId, ')
          ..write('product: $product, ')
          ..write('issuer: $issuer, ')
          ..write('indexer: $indexer, ')
          ..write('rate: $rate, ')
          ..write('spread: $spread, ')
          ..write('dayCount: $dayCount, ')
          ..write('issueDate: $issueDate, ')
          ..write('maturityDate: $maturityDate, ')
          ..write('graceUntil: $graceUntil, ')
          ..write('liquidity: $liquidity, ')
          ..write('taxRegime: $taxRegime, ')
          ..write('costsNotes: $costsNotes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OperationsTable extends Operations
    with TableInfo<$OperationsTable, OperationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
    'asset_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES assets (id)',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tradeDateMeta = const VerificationMeta(
    'tradeDate',
  );
  @override
  late final GeneratedColumn<String> tradeDate = GeneratedColumn<String>(
    'trade_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _settlementDateMeta = const VerificationMeta(
    'settlementDate',
  );
  @override
  late final GeneratedColumn<String> settlementDate = GeneratedColumn<String>(
    'settlement_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> quantity =
      GeneratedColumn<String>(
        'quantity',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($OperationsTable.$converterquantityn);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> unitPrice =
      GeneratedColumn<String>(
        'unit_price',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($OperationsTable.$converterunitPricen);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> grossAmount =
      GeneratedColumn<String>(
        'gross_amount',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($OperationsTable.$convertergrossAmountn);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal, String> fees =
      GeneratedColumn<String>(
        'fees',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Decimal>($OperationsTable.$converterfees);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal, String> taxes =
      GeneratedColumn<String>(
        'taxes',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Decimal>($OperationsTable.$convertertaxes);
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> fxRate =
      GeneratedColumn<String>(
        'fx_rate',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($OperationsTable.$converterfxRaten);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> ratioFrom =
      GeneratedColumn<String>(
        'ratio_from',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($OperationsTable.$converterratioFromn);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> ratioTo =
      GeneratedColumn<String>(
        'ratio_to',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($OperationsTable.$converterratioTon);
  static const VerificationMeta _transferGroupIdMeta = const VerificationMeta(
    'transferGroupId',
  );
  @override
  late final GeneratedColumn<String> transferGroupId = GeneratedColumn<String>(
    'transfer_group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relatedOperationIdMeta =
      const VerificationMeta('relatedOperationId');
  @override
  late final GeneratedColumn<String> relatedOperationId =
      GeneratedColumn<String>(
        'related_operation_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES operations (id)',
        ),
      );
  static const VerificationMeta _justificationMeta = const VerificationMeta(
    'justification',
  );
  @override
  late final GeneratedColumn<String> justification = GeneratedColumn<String>(
    'justification',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    hlc,
    deviceId,
    deletedAt,
    accountId,
    assetId,
    type,
    tradeDate,
    settlementDate,
    quantity,
    unitPrice,
    grossAmount,
    fees,
    taxes,
    currency,
    fxRate,
    ratioFrom,
    ratioTo,
    transferGroupId,
    relatedOperationId,
    justification,
    notes,
    origin,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<OperationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('trade_date')) {
      context.handle(
        _tradeDateMeta,
        tradeDate.isAcceptableOrUnknown(data['trade_date']!, _tradeDateMeta),
      );
    } else if (isInserting) {
      context.missing(_tradeDateMeta);
    }
    if (data.containsKey('settlement_date')) {
      context.handle(
        _settlementDateMeta,
        settlementDate.isAcceptableOrUnknown(
          data['settlement_date']!,
          _settlementDateMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('transfer_group_id')) {
      context.handle(
        _transferGroupIdMeta,
        transferGroupId.isAcceptableOrUnknown(
          data['transfer_group_id']!,
          _transferGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('related_operation_id')) {
      context.handle(
        _relatedOperationIdMeta,
        relatedOperationId.isAcceptableOrUnknown(
          data['related_operation_id']!,
          _relatedOperationIdMeta,
        ),
      );
    }
    if (data.containsKey('justification')) {
      context.handle(
        _justificationMeta,
        justification.isAcceptableOrUnknown(
          data['justification']!,
          _justificationMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OperationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OperationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_id'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      tradeDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trade_date'],
      )!,
      settlementDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settlement_date'],
      ),
      quantity: $OperationsTable.$converterquantityn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}quantity'],
        ),
      ),
      unitPrice: $OperationsTable.$converterunitPricen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}unit_price'],
        ),
      ),
      grossAmount: $OperationsTable.$convertergrossAmountn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}gross_amount'],
        ),
      ),
      fees: $OperationsTable.$converterfees.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}fees'],
        )!,
      ),
      taxes: $OperationsTable.$convertertaxes.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}taxes'],
        )!,
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      fxRate: $OperationsTable.$converterfxRaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}fx_rate'],
        ),
      ),
      ratioFrom: $OperationsTable.$converterratioFromn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}ratio_from'],
        ),
      ),
      ratioTo: $OperationsTable.$converterratioTon.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}ratio_to'],
        ),
      ),
      transferGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transfer_group_id'],
      ),
      relatedOperationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_operation_id'],
      ),
      justification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}justification'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
    );
  }

  @override
  $OperationsTable createAlias(String alias) {
    return $OperationsTable(attachedDatabase, alias);
  }

  static TypeConverter<Decimal, String> $converterquantity =
      const DecimalTextConverter();
  static TypeConverter<Decimal?, String?> $converterquantityn =
      NullAwareTypeConverter.wrap($converterquantity);
  static TypeConverter<Decimal, String> $converterunitPrice =
      const DecimalTextConverter();
  static TypeConverter<Decimal?, String?> $converterunitPricen =
      NullAwareTypeConverter.wrap($converterunitPrice);
  static TypeConverter<Decimal, String> $convertergrossAmount =
      const DecimalTextConverter();
  static TypeConverter<Decimal?, String?> $convertergrossAmountn =
      NullAwareTypeConverter.wrap($convertergrossAmount);
  static TypeConverter<Decimal, String> $converterfees =
      const DecimalTextConverter();
  static TypeConverter<Decimal, String> $convertertaxes =
      const DecimalTextConverter();
  static TypeConverter<Decimal, String> $converterfxRate =
      const DecimalTextConverter();
  static TypeConverter<Decimal?, String?> $converterfxRaten =
      NullAwareTypeConverter.wrap($converterfxRate);
  static TypeConverter<Decimal, String> $converterratioFrom =
      const DecimalTextConverter();
  static TypeConverter<Decimal?, String?> $converterratioFromn =
      NullAwareTypeConverter.wrap($converterratioFrom);
  static TypeConverter<Decimal, String> $converterratioTo =
      const DecimalTextConverter();
  static TypeConverter<Decimal?, String?> $converterratioTon =
      NullAwareTypeConverter.wrap($converterratioTo);
}

class OperationRow extends DataClass implements Insertable<OperationRow> {
  /// UUID v7 gerado no app.
  final String id;

  /// Instante UTC da criação (ISO-8601 com ms).
  final String createdAt;

  /// Instante UTC da última escrita.
  final String updatedAt;

  /// HLC da última alteração.
  final String hlc;

  /// Dispositivo que fez a última alteração.
  final String deviceId;

  /// Tombstone: preenchido na exclusão lógica.
  final String? deletedAt;
  final String accountId;

  /// Nulo para movimentos só de caixa.
  final String? assetId;
  final String type;
  final String tradeDate;
  final String? settlementDate;
  final Decimal? quantity;
  final Decimal? unitPrice;
  final Decimal? grossAmount;
  final Decimal fees;
  final Decimal taxes;
  final String currency;
  final Decimal? fxRate;
  final Decimal? ratioFrom;
  final Decimal? ratioTo;
  final String? transferGroupId;
  final String? relatedOperationId;
  final String? justification;
  final String? notes;

  /// `manual`, `csv_import` ou `save_merge`.
  final String origin;
  const OperationRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.hlc,
    required this.deviceId,
    this.deletedAt,
    required this.accountId,
    this.assetId,
    required this.type,
    required this.tradeDate,
    this.settlementDate,
    this.quantity,
    this.unitPrice,
    this.grossAmount,
    required this.fees,
    required this.taxes,
    required this.currency,
    this.fxRate,
    this.ratioFrom,
    this.ratioTo,
    this.transferGroupId,
    this.relatedOperationId,
    this.justification,
    this.notes,
    required this.origin,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['hlc'] = Variable<String>(hlc);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['account_id'] = Variable<String>(accountId);
    if (!nullToAbsent || assetId != null) {
      map['asset_id'] = Variable<String>(assetId);
    }
    map['type'] = Variable<String>(type);
    map['trade_date'] = Variable<String>(tradeDate);
    if (!nullToAbsent || settlementDate != null) {
      map['settlement_date'] = Variable<String>(settlementDate);
    }
    if (!nullToAbsent || quantity != null) {
      map['quantity'] = Variable<String>(
        $OperationsTable.$converterquantityn.toSql(quantity),
      );
    }
    if (!nullToAbsent || unitPrice != null) {
      map['unit_price'] = Variable<String>(
        $OperationsTable.$converterunitPricen.toSql(unitPrice),
      );
    }
    if (!nullToAbsent || grossAmount != null) {
      map['gross_amount'] = Variable<String>(
        $OperationsTable.$convertergrossAmountn.toSql(grossAmount),
      );
    }
    {
      map['fees'] = Variable<String>(
        $OperationsTable.$converterfees.toSql(fees),
      );
    }
    {
      map['taxes'] = Variable<String>(
        $OperationsTable.$convertertaxes.toSql(taxes),
      );
    }
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || fxRate != null) {
      map['fx_rate'] = Variable<String>(
        $OperationsTable.$converterfxRaten.toSql(fxRate),
      );
    }
    if (!nullToAbsent || ratioFrom != null) {
      map['ratio_from'] = Variable<String>(
        $OperationsTable.$converterratioFromn.toSql(ratioFrom),
      );
    }
    if (!nullToAbsent || ratioTo != null) {
      map['ratio_to'] = Variable<String>(
        $OperationsTable.$converterratioTon.toSql(ratioTo),
      );
    }
    if (!nullToAbsent || transferGroupId != null) {
      map['transfer_group_id'] = Variable<String>(transferGroupId);
    }
    if (!nullToAbsent || relatedOperationId != null) {
      map['related_operation_id'] = Variable<String>(relatedOperationId);
    }
    if (!nullToAbsent || justification != null) {
      map['justification'] = Variable<String>(justification);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['origin'] = Variable<String>(origin);
    return map;
  }

  OperationsCompanion toCompanion(bool nullToAbsent) {
    return OperationsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      hlc: Value(hlc),
      deviceId: Value(deviceId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      accountId: Value(accountId),
      assetId: assetId == null && nullToAbsent
          ? const Value.absent()
          : Value(assetId),
      type: Value(type),
      tradeDate: Value(tradeDate),
      settlementDate: settlementDate == null && nullToAbsent
          ? const Value.absent()
          : Value(settlementDate),
      quantity: quantity == null && nullToAbsent
          ? const Value.absent()
          : Value(quantity),
      unitPrice: unitPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(unitPrice),
      grossAmount: grossAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(grossAmount),
      fees: Value(fees),
      taxes: Value(taxes),
      currency: Value(currency),
      fxRate: fxRate == null && nullToAbsent
          ? const Value.absent()
          : Value(fxRate),
      ratioFrom: ratioFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(ratioFrom),
      ratioTo: ratioTo == null && nullToAbsent
          ? const Value.absent()
          : Value(ratioTo),
      transferGroupId: transferGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(transferGroupId),
      relatedOperationId: relatedOperationId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedOperationId),
      justification: justification == null && nullToAbsent
          ? const Value.absent()
          : Value(justification),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      origin: Value(origin),
    );
  }

  factory OperationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OperationRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      accountId: serializer.fromJson<String>(json['accountId']),
      assetId: serializer.fromJson<String?>(json['assetId']),
      type: serializer.fromJson<String>(json['type']),
      tradeDate: serializer.fromJson<String>(json['tradeDate']),
      settlementDate: serializer.fromJson<String?>(json['settlementDate']),
      quantity: serializer.fromJson<Decimal?>(json['quantity']),
      unitPrice: serializer.fromJson<Decimal?>(json['unitPrice']),
      grossAmount: serializer.fromJson<Decimal?>(json['grossAmount']),
      fees: serializer.fromJson<Decimal>(json['fees']),
      taxes: serializer.fromJson<Decimal>(json['taxes']),
      currency: serializer.fromJson<String>(json['currency']),
      fxRate: serializer.fromJson<Decimal?>(json['fxRate']),
      ratioFrom: serializer.fromJson<Decimal?>(json['ratioFrom']),
      ratioTo: serializer.fromJson<Decimal?>(json['ratioTo']),
      transferGroupId: serializer.fromJson<String?>(json['transferGroupId']),
      relatedOperationId: serializer.fromJson<String?>(
        json['relatedOperationId'],
      ),
      justification: serializer.fromJson<String?>(json['justification']),
      notes: serializer.fromJson<String?>(json['notes']),
      origin: serializer.fromJson<String>(json['origin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'hlc': serializer.toJson<String>(hlc),
      'deviceId': serializer.toJson<String>(deviceId),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'accountId': serializer.toJson<String>(accountId),
      'assetId': serializer.toJson<String?>(assetId),
      'type': serializer.toJson<String>(type),
      'tradeDate': serializer.toJson<String>(tradeDate),
      'settlementDate': serializer.toJson<String?>(settlementDate),
      'quantity': serializer.toJson<Decimal?>(quantity),
      'unitPrice': serializer.toJson<Decimal?>(unitPrice),
      'grossAmount': serializer.toJson<Decimal?>(grossAmount),
      'fees': serializer.toJson<Decimal>(fees),
      'taxes': serializer.toJson<Decimal>(taxes),
      'currency': serializer.toJson<String>(currency),
      'fxRate': serializer.toJson<Decimal?>(fxRate),
      'ratioFrom': serializer.toJson<Decimal?>(ratioFrom),
      'ratioTo': serializer.toJson<Decimal?>(ratioTo),
      'transferGroupId': serializer.toJson<String?>(transferGroupId),
      'relatedOperationId': serializer.toJson<String?>(relatedOperationId),
      'justification': serializer.toJson<String?>(justification),
      'notes': serializer.toJson<String?>(notes),
      'origin': serializer.toJson<String>(origin),
    };
  }

  OperationRow copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? hlc,
    String? deviceId,
    Value<String?> deletedAt = const Value.absent(),
    String? accountId,
    Value<String?> assetId = const Value.absent(),
    String? type,
    String? tradeDate,
    Value<String?> settlementDate = const Value.absent(),
    Value<Decimal?> quantity = const Value.absent(),
    Value<Decimal?> unitPrice = const Value.absent(),
    Value<Decimal?> grossAmount = const Value.absent(),
    Decimal? fees,
    Decimal? taxes,
    String? currency,
    Value<Decimal?> fxRate = const Value.absent(),
    Value<Decimal?> ratioFrom = const Value.absent(),
    Value<Decimal?> ratioTo = const Value.absent(),
    Value<String?> transferGroupId = const Value.absent(),
    Value<String?> relatedOperationId = const Value.absent(),
    Value<String?> justification = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? origin,
  }) => OperationRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    hlc: hlc ?? this.hlc,
    deviceId: deviceId ?? this.deviceId,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    accountId: accountId ?? this.accountId,
    assetId: assetId.present ? assetId.value : this.assetId,
    type: type ?? this.type,
    tradeDate: tradeDate ?? this.tradeDate,
    settlementDate: settlementDate.present
        ? settlementDate.value
        : this.settlementDate,
    quantity: quantity.present ? quantity.value : this.quantity,
    unitPrice: unitPrice.present ? unitPrice.value : this.unitPrice,
    grossAmount: grossAmount.present ? grossAmount.value : this.grossAmount,
    fees: fees ?? this.fees,
    taxes: taxes ?? this.taxes,
    currency: currency ?? this.currency,
    fxRate: fxRate.present ? fxRate.value : this.fxRate,
    ratioFrom: ratioFrom.present ? ratioFrom.value : this.ratioFrom,
    ratioTo: ratioTo.present ? ratioTo.value : this.ratioTo,
    transferGroupId: transferGroupId.present
        ? transferGroupId.value
        : this.transferGroupId,
    relatedOperationId: relatedOperationId.present
        ? relatedOperationId.value
        : this.relatedOperationId,
    justification: justification.present
        ? justification.value
        : this.justification,
    notes: notes.present ? notes.value : this.notes,
    origin: origin ?? this.origin,
  );
  OperationRow copyWithCompanion(OperationsCompanion data) {
    return OperationRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      type: data.type.present ? data.type.value : this.type,
      tradeDate: data.tradeDate.present ? data.tradeDate.value : this.tradeDate,
      settlementDate: data.settlementDate.present
          ? data.settlementDate.value
          : this.settlementDate,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      grossAmount: data.grossAmount.present
          ? data.grossAmount.value
          : this.grossAmount,
      fees: data.fees.present ? data.fees.value : this.fees,
      taxes: data.taxes.present ? data.taxes.value : this.taxes,
      currency: data.currency.present ? data.currency.value : this.currency,
      fxRate: data.fxRate.present ? data.fxRate.value : this.fxRate,
      ratioFrom: data.ratioFrom.present ? data.ratioFrom.value : this.ratioFrom,
      ratioTo: data.ratioTo.present ? data.ratioTo.value : this.ratioTo,
      transferGroupId: data.transferGroupId.present
          ? data.transferGroupId.value
          : this.transferGroupId,
      relatedOperationId: data.relatedOperationId.present
          ? data.relatedOperationId.value
          : this.relatedOperationId,
      justification: data.justification.present
          ? data.justification.value
          : this.justification,
      notes: data.notes.present ? data.notes.value : this.notes,
      origin: data.origin.present ? data.origin.value : this.origin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OperationRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hlc: $hlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('accountId: $accountId, ')
          ..write('assetId: $assetId, ')
          ..write('type: $type, ')
          ..write('tradeDate: $tradeDate, ')
          ..write('settlementDate: $settlementDate, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('grossAmount: $grossAmount, ')
          ..write('fees: $fees, ')
          ..write('taxes: $taxes, ')
          ..write('currency: $currency, ')
          ..write('fxRate: $fxRate, ')
          ..write('ratioFrom: $ratioFrom, ')
          ..write('ratioTo: $ratioTo, ')
          ..write('transferGroupId: $transferGroupId, ')
          ..write('relatedOperationId: $relatedOperationId, ')
          ..write('justification: $justification, ')
          ..write('notes: $notes, ')
          ..write('origin: $origin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createdAt,
    updatedAt,
    hlc,
    deviceId,
    deletedAt,
    accountId,
    assetId,
    type,
    tradeDate,
    settlementDate,
    quantity,
    unitPrice,
    grossAmount,
    fees,
    taxes,
    currency,
    fxRate,
    ratioFrom,
    ratioTo,
    transferGroupId,
    relatedOperationId,
    justification,
    notes,
    origin,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OperationRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.hlc == this.hlc &&
          other.deviceId == this.deviceId &&
          other.deletedAt == this.deletedAt &&
          other.accountId == this.accountId &&
          other.assetId == this.assetId &&
          other.type == this.type &&
          other.tradeDate == this.tradeDate &&
          other.settlementDate == this.settlementDate &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.grossAmount == this.grossAmount &&
          other.fees == this.fees &&
          other.taxes == this.taxes &&
          other.currency == this.currency &&
          other.fxRate == this.fxRate &&
          other.ratioFrom == this.ratioFrom &&
          other.ratioTo == this.ratioTo &&
          other.transferGroupId == this.transferGroupId &&
          other.relatedOperationId == this.relatedOperationId &&
          other.justification == this.justification &&
          other.notes == this.notes &&
          other.origin == this.origin);
}

class OperationsCompanion extends UpdateCompanion<OperationRow> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> hlc;
  final Value<String> deviceId;
  final Value<String?> deletedAt;
  final Value<String> accountId;
  final Value<String?> assetId;
  final Value<String> type;
  final Value<String> tradeDate;
  final Value<String?> settlementDate;
  final Value<Decimal?> quantity;
  final Value<Decimal?> unitPrice;
  final Value<Decimal?> grossAmount;
  final Value<Decimal> fees;
  final Value<Decimal> taxes;
  final Value<String> currency;
  final Value<Decimal?> fxRate;
  final Value<Decimal?> ratioFrom;
  final Value<Decimal?> ratioTo;
  final Value<String?> transferGroupId;
  final Value<String?> relatedOperationId;
  final Value<String?> justification;
  final Value<String?> notes;
  final Value<String> origin;
  final Value<int> rowid;
  const OperationsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.accountId = const Value.absent(),
    this.assetId = const Value.absent(),
    this.type = const Value.absent(),
    this.tradeDate = const Value.absent(),
    this.settlementDate = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.grossAmount = const Value.absent(),
    this.fees = const Value.absent(),
    this.taxes = const Value.absent(),
    this.currency = const Value.absent(),
    this.fxRate = const Value.absent(),
    this.ratioFrom = const Value.absent(),
    this.ratioTo = const Value.absent(),
    this.transferGroupId = const Value.absent(),
    this.relatedOperationId = const Value.absent(),
    this.justification = const Value.absent(),
    this.notes = const Value.absent(),
    this.origin = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OperationsCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    required String hlc,
    required String deviceId,
    this.deletedAt = const Value.absent(),
    required String accountId,
    this.assetId = const Value.absent(),
    required String type,
    required String tradeDate,
    this.settlementDate = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.grossAmount = const Value.absent(),
    required Decimal fees,
    required Decimal taxes,
    required String currency,
    this.fxRate = const Value.absent(),
    this.ratioFrom = const Value.absent(),
    this.ratioTo = const Value.absent(),
    this.transferGroupId = const Value.absent(),
    this.relatedOperationId = const Value.absent(),
    this.justification = const Value.absent(),
    this.notes = const Value.absent(),
    required String origin,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       hlc = Value(hlc),
       deviceId = Value(deviceId),
       accountId = Value(accountId),
       type = Value(type),
       tradeDate = Value(tradeDate),
       fees = Value(fees),
       taxes = Value(taxes),
       currency = Value(currency),
       origin = Value(origin);
  static Insertable<OperationRow> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? hlc,
    Expression<String>? deviceId,
    Expression<String>? deletedAt,
    Expression<String>? accountId,
    Expression<String>? assetId,
    Expression<String>? type,
    Expression<String>? tradeDate,
    Expression<String>? settlementDate,
    Expression<String>? quantity,
    Expression<String>? unitPrice,
    Expression<String>? grossAmount,
    Expression<String>? fees,
    Expression<String>? taxes,
    Expression<String>? currency,
    Expression<String>? fxRate,
    Expression<String>? ratioFrom,
    Expression<String>? ratioTo,
    Expression<String>? transferGroupId,
    Expression<String>? relatedOperationId,
    Expression<String>? justification,
    Expression<String>? notes,
    Expression<String>? origin,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (hlc != null) 'hlc': hlc,
      if (deviceId != null) 'device_id': deviceId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (accountId != null) 'account_id': accountId,
      if (assetId != null) 'asset_id': assetId,
      if (type != null) 'type': type,
      if (tradeDate != null) 'trade_date': tradeDate,
      if (settlementDate != null) 'settlement_date': settlementDate,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (grossAmount != null) 'gross_amount': grossAmount,
      if (fees != null) 'fees': fees,
      if (taxes != null) 'taxes': taxes,
      if (currency != null) 'currency': currency,
      if (fxRate != null) 'fx_rate': fxRate,
      if (ratioFrom != null) 'ratio_from': ratioFrom,
      if (ratioTo != null) 'ratio_to': ratioTo,
      if (transferGroupId != null) 'transfer_group_id': transferGroupId,
      if (relatedOperationId != null)
        'related_operation_id': relatedOperationId,
      if (justification != null) 'justification': justification,
      if (notes != null) 'notes': notes,
      if (origin != null) 'origin': origin,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OperationsCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? hlc,
    Value<String>? deviceId,
    Value<String?>? deletedAt,
    Value<String>? accountId,
    Value<String?>? assetId,
    Value<String>? type,
    Value<String>? tradeDate,
    Value<String?>? settlementDate,
    Value<Decimal?>? quantity,
    Value<Decimal?>? unitPrice,
    Value<Decimal?>? grossAmount,
    Value<Decimal>? fees,
    Value<Decimal>? taxes,
    Value<String>? currency,
    Value<Decimal?>? fxRate,
    Value<Decimal?>? ratioFrom,
    Value<Decimal?>? ratioTo,
    Value<String?>? transferGroupId,
    Value<String?>? relatedOperationId,
    Value<String?>? justification,
    Value<String?>? notes,
    Value<String>? origin,
    Value<int>? rowid,
  }) {
    return OperationsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hlc: hlc ?? this.hlc,
      deviceId: deviceId ?? this.deviceId,
      deletedAt: deletedAt ?? this.deletedAt,
      accountId: accountId ?? this.accountId,
      assetId: assetId ?? this.assetId,
      type: type ?? this.type,
      tradeDate: tradeDate ?? this.tradeDate,
      settlementDate: settlementDate ?? this.settlementDate,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      grossAmount: grossAmount ?? this.grossAmount,
      fees: fees ?? this.fees,
      taxes: taxes ?? this.taxes,
      currency: currency ?? this.currency,
      fxRate: fxRate ?? this.fxRate,
      ratioFrom: ratioFrom ?? this.ratioFrom,
      ratioTo: ratioTo ?? this.ratioTo,
      transferGroupId: transferGroupId ?? this.transferGroupId,
      relatedOperationId: relatedOperationId ?? this.relatedOperationId,
      justification: justification ?? this.justification,
      notes: notes ?? this.notes,
      origin: origin ?? this.origin,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (tradeDate.present) {
      map['trade_date'] = Variable<String>(tradeDate.value);
    }
    if (settlementDate.present) {
      map['settlement_date'] = Variable<String>(settlementDate.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<String>(
        $OperationsTable.$converterquantityn.toSql(quantity.value),
      );
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<String>(
        $OperationsTable.$converterunitPricen.toSql(unitPrice.value),
      );
    }
    if (grossAmount.present) {
      map['gross_amount'] = Variable<String>(
        $OperationsTable.$convertergrossAmountn.toSql(grossAmount.value),
      );
    }
    if (fees.present) {
      map['fees'] = Variable<String>(
        $OperationsTable.$converterfees.toSql(fees.value),
      );
    }
    if (taxes.present) {
      map['taxes'] = Variable<String>(
        $OperationsTable.$convertertaxes.toSql(taxes.value),
      );
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (fxRate.present) {
      map['fx_rate'] = Variable<String>(
        $OperationsTable.$converterfxRaten.toSql(fxRate.value),
      );
    }
    if (ratioFrom.present) {
      map['ratio_from'] = Variable<String>(
        $OperationsTable.$converterratioFromn.toSql(ratioFrom.value),
      );
    }
    if (ratioTo.present) {
      map['ratio_to'] = Variable<String>(
        $OperationsTable.$converterratioTon.toSql(ratioTo.value),
      );
    }
    if (transferGroupId.present) {
      map['transfer_group_id'] = Variable<String>(transferGroupId.value);
    }
    if (relatedOperationId.present) {
      map['related_operation_id'] = Variable<String>(relatedOperationId.value);
    }
    if (justification.present) {
      map['justification'] = Variable<String>(justification.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OperationsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hlc: $hlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('accountId: $accountId, ')
          ..write('assetId: $assetId, ')
          ..write('type: $type, ')
          ..write('tradeDate: $tradeDate, ')
          ..write('settlementDate: $settlementDate, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('grossAmount: $grossAmount, ')
          ..write('fees: $fees, ')
          ..write('taxes: $taxes, ')
          ..write('currency: $currency, ')
          ..write('fxRate: $fxRate, ')
          ..write('ratioFrom: $ratioFrom, ')
          ..write('ratioTo: $ratioTo, ')
          ..write('transferGroupId: $transferGroupId, ')
          ..write('relatedOperationId: $relatedOperationId, ')
          ..write('justification: $justification, ')
          ..write('notes: $notes, ')
          ..write('origin: $origin, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ManualValuationsTable extends ManualValuations
    with TableInfo<$ManualValuationsTable, ManualValuationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ManualValuationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES assets (id)',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _refDateMeta = const VerificationMeta(
    'refDate',
  );
  @override
  late final GeneratedColumn<String> refDate = GeneratedColumn<String>(
    'ref_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal, String> value =
      GeneratedColumn<String>(
        'value',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Decimal>($ManualValuationsTable.$convertervalue);
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    hlc,
    deviceId,
    deletedAt,
    assetId,
    accountId,
    refDate,
    kind,
    value,
    currency,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'manual_valuations';
  @override
  VerificationContext validateIntegrity(
    Insertable<ManualValuationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('ref_date')) {
      context.handle(
        _refDateMeta,
        refDate.isAcceptableOrUnknown(data['ref_date']!, _refDateMeta),
      );
    } else if (isInserting) {
      context.missing(_refDateMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ManualValuationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ManualValuationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      ),
      refDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_date'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      value: $ManualValuationsTable.$convertervalue.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}value'],
        )!,
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $ManualValuationsTable createAlias(String alias) {
    return $ManualValuationsTable(attachedDatabase, alias);
  }

  static TypeConverter<Decimal, String> $convertervalue =
      const DecimalTextConverter();
}

class ManualValuationRow extends DataClass
    implements Insertable<ManualValuationRow> {
  /// UUID v7 gerado no app.
  final String id;

  /// Instante UTC da criação (ISO-8601 com ms).
  final String createdAt;

  /// Instante UTC da última escrita.
  final String updatedAt;

  /// HLC da última alteração.
  final String hlc;

  /// Dispositivo que fez a última alteração.
  final String deviceId;

  /// Tombstone: preenchido na exclusão lógica.
  final String? deletedAt;
  final String assetId;

  /// Obrigatório para saldos (`kind = balance`).
  final String? accountId;
  final String refDate;

  /// `unit_price` ou `balance`.
  final String kind;
  final Decimal value;
  final String currency;
  final String? notes;
  const ManualValuationRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.hlc,
    required this.deviceId,
    this.deletedAt,
    required this.assetId,
    this.accountId,
    required this.refDate,
    required this.kind,
    required this.value,
    required this.currency,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['hlc'] = Variable<String>(hlc);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['asset_id'] = Variable<String>(assetId);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    map['ref_date'] = Variable<String>(refDate);
    map['kind'] = Variable<String>(kind);
    {
      map['value'] = Variable<String>(
        $ManualValuationsTable.$convertervalue.toSql(value),
      );
    }
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  ManualValuationsCompanion toCompanion(bool nullToAbsent) {
    return ManualValuationsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      hlc: Value(hlc),
      deviceId: Value(deviceId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      assetId: Value(assetId),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      refDate: Value(refDate),
      kind: Value(kind),
      value: Value(value),
      currency: Value(currency),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory ManualValuationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ManualValuationRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      assetId: serializer.fromJson<String>(json['assetId']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      refDate: serializer.fromJson<String>(json['refDate']),
      kind: serializer.fromJson<String>(json['kind']),
      value: serializer.fromJson<Decimal>(json['value']),
      currency: serializer.fromJson<String>(json['currency']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'hlc': serializer.toJson<String>(hlc),
      'deviceId': serializer.toJson<String>(deviceId),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'assetId': serializer.toJson<String>(assetId),
      'accountId': serializer.toJson<String?>(accountId),
      'refDate': serializer.toJson<String>(refDate),
      'kind': serializer.toJson<String>(kind),
      'value': serializer.toJson<Decimal>(value),
      'currency': serializer.toJson<String>(currency),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  ManualValuationRow copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? hlc,
    String? deviceId,
    Value<String?> deletedAt = const Value.absent(),
    String? assetId,
    Value<String?> accountId = const Value.absent(),
    String? refDate,
    String? kind,
    Decimal? value,
    String? currency,
    Value<String?> notes = const Value.absent(),
  }) => ManualValuationRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    hlc: hlc ?? this.hlc,
    deviceId: deviceId ?? this.deviceId,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    assetId: assetId ?? this.assetId,
    accountId: accountId.present ? accountId.value : this.accountId,
    refDate: refDate ?? this.refDate,
    kind: kind ?? this.kind,
    value: value ?? this.value,
    currency: currency ?? this.currency,
    notes: notes.present ? notes.value : this.notes,
  );
  ManualValuationRow copyWithCompanion(ManualValuationsCompanion data) {
    return ManualValuationRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      refDate: data.refDate.present ? data.refDate.value : this.refDate,
      kind: data.kind.present ? data.kind.value : this.kind,
      value: data.value.present ? data.value.value : this.value,
      currency: data.currency.present ? data.currency.value : this.currency,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ManualValuationRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hlc: $hlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('assetId: $assetId, ')
          ..write('accountId: $accountId, ')
          ..write('refDate: $refDate, ')
          ..write('kind: $kind, ')
          ..write('value: $value, ')
          ..write('currency: $currency, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    hlc,
    deviceId,
    deletedAt,
    assetId,
    accountId,
    refDate,
    kind,
    value,
    currency,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ManualValuationRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.hlc == this.hlc &&
          other.deviceId == this.deviceId &&
          other.deletedAt == this.deletedAt &&
          other.assetId == this.assetId &&
          other.accountId == this.accountId &&
          other.refDate == this.refDate &&
          other.kind == this.kind &&
          other.value == this.value &&
          other.currency == this.currency &&
          other.notes == this.notes);
}

class ManualValuationsCompanion extends UpdateCompanion<ManualValuationRow> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> hlc;
  final Value<String> deviceId;
  final Value<String?> deletedAt;
  final Value<String> assetId;
  final Value<String?> accountId;
  final Value<String> refDate;
  final Value<String> kind;
  final Value<Decimal> value;
  final Value<String> currency;
  final Value<String?> notes;
  final Value<int> rowid;
  const ManualValuationsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.assetId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.refDate = const Value.absent(),
    this.kind = const Value.absent(),
    this.value = const Value.absent(),
    this.currency = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ManualValuationsCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    required String hlc,
    required String deviceId,
    this.deletedAt = const Value.absent(),
    required String assetId,
    this.accountId = const Value.absent(),
    required String refDate,
    required String kind,
    required Decimal value,
    required String currency,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       hlc = Value(hlc),
       deviceId = Value(deviceId),
       assetId = Value(assetId),
       refDate = Value(refDate),
       kind = Value(kind),
       value = Value(value),
       currency = Value(currency);
  static Insertable<ManualValuationRow> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? hlc,
    Expression<String>? deviceId,
    Expression<String>? deletedAt,
    Expression<String>? assetId,
    Expression<String>? accountId,
    Expression<String>? refDate,
    Expression<String>? kind,
    Expression<String>? value,
    Expression<String>? currency,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (hlc != null) 'hlc': hlc,
      if (deviceId != null) 'device_id': deviceId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (assetId != null) 'asset_id': assetId,
      if (accountId != null) 'account_id': accountId,
      if (refDate != null) 'ref_date': refDate,
      if (kind != null) 'kind': kind,
      if (value != null) 'value': value,
      if (currency != null) 'currency': currency,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ManualValuationsCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? hlc,
    Value<String>? deviceId,
    Value<String?>? deletedAt,
    Value<String>? assetId,
    Value<String?>? accountId,
    Value<String>? refDate,
    Value<String>? kind,
    Value<Decimal>? value,
    Value<String>? currency,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return ManualValuationsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hlc: hlc ?? this.hlc,
      deviceId: deviceId ?? this.deviceId,
      deletedAt: deletedAt ?? this.deletedAt,
      assetId: assetId ?? this.assetId,
      accountId: accountId ?? this.accountId,
      refDate: refDate ?? this.refDate,
      kind: kind ?? this.kind,
      value: value ?? this.value,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (refDate.present) {
      map['ref_date'] = Variable<String>(refDate.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(
        $ManualValuationsTable.$convertervalue.toSql(value.value),
      );
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ManualValuationsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hlc: $hlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('assetId: $assetId, ')
          ..write('accountId: $accountId, ')
          ..write('refDate: $refDate, ')
          ..write('kind: $kind, ')
          ..write('value: $value, ')
          ..write('currency: $currency, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssetAliasesTable extends AssetAliases
    with TableInfo<$AssetAliasesTable, AssetAliasRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetAliasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aliasIdMeta = const VerificationMeta(
    'aliasId',
  );
  @override
  late final GeneratedColumn<String> aliasId = GeneratedColumn<String>(
    'alias_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _canonicalIdMeta = const VerificationMeta(
    'canonicalId',
  );
  @override
  late final GeneratedColumn<String> canonicalId = GeneratedColumn<String>(
    'canonical_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    hlc,
    deviceId,
    deletedAt,
    entity,
    aliasId,
    canonicalId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asset_aliases';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssetAliasRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('alias_id')) {
      context.handle(
        _aliasIdMeta,
        aliasId.isAcceptableOrUnknown(data['alias_id']!, _aliasIdMeta),
      );
    } else if (isInserting) {
      context.missing(_aliasIdMeta);
    }
    if (data.containsKey('canonical_id')) {
      context.handle(
        _canonicalIdMeta,
        canonicalId.isAcceptableOrUnknown(
          data['canonical_id']!,
          _canonicalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_canonicalIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssetAliasRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetAliasRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      aliasId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alias_id'],
      )!,
      canonicalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_id'],
      )!,
    );
  }

  @override
  $AssetAliasesTable createAlias(String alias) {
    return $AssetAliasesTable(attachedDatabase, alias);
  }
}

class AssetAliasRow extends DataClass implements Insertable<AssetAliasRow> {
  /// UUID v7 gerado no app.
  final String id;

  /// Instante UTC da criação (ISO-8601 com ms).
  final String createdAt;

  /// Instante UTC da última escrita.
  final String updatedAt;

  /// HLC da última alteração.
  final String hlc;

  /// Dispositivo que fez a última alteração.
  final String deviceId;

  /// Tombstone: preenchido na exclusão lógica.
  final String? deletedAt;

  /// `institution`, `account`, `asset`, `fixed_income_terms` ou
  /// `shared_setting`.
  final String entity;
  final String aliasId;
  final String canonicalId;
  const AssetAliasRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.hlc,
    required this.deviceId,
    this.deletedAt,
    required this.entity,
    required this.aliasId,
    required this.canonicalId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['hlc'] = Variable<String>(hlc);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['entity'] = Variable<String>(entity);
    map['alias_id'] = Variable<String>(aliasId);
    map['canonical_id'] = Variable<String>(canonicalId);
    return map;
  }

  AssetAliasesCompanion toCompanion(bool nullToAbsent) {
    return AssetAliasesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      hlc: Value(hlc),
      deviceId: Value(deviceId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      entity: Value(entity),
      aliasId: Value(aliasId),
      canonicalId: Value(canonicalId),
    );
  }

  factory AssetAliasRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetAliasRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      entity: serializer.fromJson<String>(json['entity']),
      aliasId: serializer.fromJson<String>(json['aliasId']),
      canonicalId: serializer.fromJson<String>(json['canonicalId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'hlc': serializer.toJson<String>(hlc),
      'deviceId': serializer.toJson<String>(deviceId),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'entity': serializer.toJson<String>(entity),
      'aliasId': serializer.toJson<String>(aliasId),
      'canonicalId': serializer.toJson<String>(canonicalId),
    };
  }

  AssetAliasRow copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? hlc,
    String? deviceId,
    Value<String?> deletedAt = const Value.absent(),
    String? entity,
    String? aliasId,
    String? canonicalId,
  }) => AssetAliasRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    hlc: hlc ?? this.hlc,
    deviceId: deviceId ?? this.deviceId,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    entity: entity ?? this.entity,
    aliasId: aliasId ?? this.aliasId,
    canonicalId: canonicalId ?? this.canonicalId,
  );
  AssetAliasRow copyWithCompanion(AssetAliasesCompanion data) {
    return AssetAliasRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      entity: data.entity.present ? data.entity.value : this.entity,
      aliasId: data.aliasId.present ? data.aliasId.value : this.aliasId,
      canonicalId: data.canonicalId.present
          ? data.canonicalId.value
          : this.canonicalId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetAliasRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hlc: $hlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('entity: $entity, ')
          ..write('aliasId: $aliasId, ')
          ..write('canonicalId: $canonicalId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    hlc,
    deviceId,
    deletedAt,
    entity,
    aliasId,
    canonicalId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetAliasRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.hlc == this.hlc &&
          other.deviceId == this.deviceId &&
          other.deletedAt == this.deletedAt &&
          other.entity == this.entity &&
          other.aliasId == this.aliasId &&
          other.canonicalId == this.canonicalId);
}

class AssetAliasesCompanion extends UpdateCompanion<AssetAliasRow> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> hlc;
  final Value<String> deviceId;
  final Value<String?> deletedAt;
  final Value<String> entity;
  final Value<String> aliasId;
  final Value<String> canonicalId;
  final Value<int> rowid;
  const AssetAliasesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.entity = const Value.absent(),
    this.aliasId = const Value.absent(),
    this.canonicalId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssetAliasesCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    required String hlc,
    required String deviceId,
    this.deletedAt = const Value.absent(),
    required String entity,
    required String aliasId,
    required String canonicalId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       hlc = Value(hlc),
       deviceId = Value(deviceId),
       entity = Value(entity),
       aliasId = Value(aliasId),
       canonicalId = Value(canonicalId);
  static Insertable<AssetAliasRow> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? hlc,
    Expression<String>? deviceId,
    Expression<String>? deletedAt,
    Expression<String>? entity,
    Expression<String>? aliasId,
    Expression<String>? canonicalId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (hlc != null) 'hlc': hlc,
      if (deviceId != null) 'device_id': deviceId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (entity != null) 'entity': entity,
      if (aliasId != null) 'alias_id': aliasId,
      if (canonicalId != null) 'canonical_id': canonicalId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssetAliasesCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? hlc,
    Value<String>? deviceId,
    Value<String?>? deletedAt,
    Value<String>? entity,
    Value<String>? aliasId,
    Value<String>? canonicalId,
    Value<int>? rowid,
  }) {
    return AssetAliasesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hlc: hlc ?? this.hlc,
      deviceId: deviceId ?? this.deviceId,
      deletedAt: deletedAt ?? this.deletedAt,
      entity: entity ?? this.entity,
      aliasId: aliasId ?? this.aliasId,
      canonicalId: canonicalId ?? this.canonicalId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (aliasId.present) {
      map['alias_id'] = Variable<String>(aliasId.value);
    }
    if (canonicalId.present) {
      map['canonical_id'] = Variable<String>(canonicalId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetAliasesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hlc: $hlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('entity: $entity, ')
          ..write('aliasId: $aliasId, ')
          ..write('canonicalId: $canonicalId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HypoPortfoliosTable extends HypoPortfolios
    with TableInfo<$HypoPortfoliosTable, HypoPortfolioRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HypoPortfoliosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _objectiveMeta = const VerificationMeta(
    'objective',
  );
  @override
  late final GeneratedColumn<String> objective = GeneratedColumn<String>(
    'objective',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseCurrencyMeta = const VerificationMeta(
    'baseCurrency',
  );
  @override
  late final GeneratedColumn<String> baseCurrency = GeneratedColumn<String>(
    'base_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal, String> initialCapital =
      GeneratedColumn<String>(
        'initial_capital',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Decimal>($HypoPortfoliosTable.$converterinitialCapital);
  static const VerificationMeta _compositionModeMeta = const VerificationMeta(
    'compositionMode',
  );
  @override
  late final GeneratedColumn<String> compositionMode = GeneratedColumn<String>(
    'composition_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _benchmarkJsonMeta = const VerificationMeta(
    'benchmarkJson',
  );
  @override
  late final GeneratedColumn<String> benchmarkJson = GeneratedColumn<String>(
    'benchmark_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rebalanceJsonMeta = const VerificationMeta(
    'rebalanceJson',
  );
  @override
  late final GeneratedColumn<String> rebalanceJson = GeneratedColumn<String>(
    'rebalance_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assumptionsJsonMeta = const VerificationMeta(
    'assumptionsJson',
  );
  @override
  late final GeneratedColumn<String> assumptionsJson = GeneratedColumn<String>(
    'assumptions_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodologyMeta = const VerificationMeta(
    'methodology',
  );
  @override
  late final GeneratedColumn<String> methodology = GeneratedColumn<String>(
    'methodology',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<String> archivedAt = GeneratedColumn<String>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _duplicatedFromIdMeta = const VerificationMeta(
    'duplicatedFromId',
  );
  @override
  late final GeneratedColumn<String> duplicatedFromId = GeneratedColumn<String>(
    'duplicated_from_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    hlc,
    deviceId,
    deletedAt,
    name,
    description,
    objective,
    startDate,
    baseCurrency,
    initialCapital,
    compositionMode,
    benchmarkJson,
    rebalanceJson,
    assumptionsJson,
    methodology,
    archivedAt,
    duplicatedFromId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hypo_portfolios';
  @override
  VerificationContext validateIntegrity(
    Insertable<HypoPortfolioRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('objective')) {
      context.handle(
        _objectiveMeta,
        objective.isAcceptableOrUnknown(data['objective']!, _objectiveMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('base_currency')) {
      context.handle(
        _baseCurrencyMeta,
        baseCurrency.isAcceptableOrUnknown(
          data['base_currency']!,
          _baseCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseCurrencyMeta);
    }
    if (data.containsKey('composition_mode')) {
      context.handle(
        _compositionModeMeta,
        compositionMode.isAcceptableOrUnknown(
          data['composition_mode']!,
          _compositionModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_compositionModeMeta);
    }
    if (data.containsKey('benchmark_json')) {
      context.handle(
        _benchmarkJsonMeta,
        benchmarkJson.isAcceptableOrUnknown(
          data['benchmark_json']!,
          _benchmarkJsonMeta,
        ),
      );
    }
    if (data.containsKey('rebalance_json')) {
      context.handle(
        _rebalanceJsonMeta,
        rebalanceJson.isAcceptableOrUnknown(
          data['rebalance_json']!,
          _rebalanceJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rebalanceJsonMeta);
    }
    if (data.containsKey('assumptions_json')) {
      context.handle(
        _assumptionsJsonMeta,
        assumptionsJson.isAcceptableOrUnknown(
          data['assumptions_json']!,
          _assumptionsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assumptionsJsonMeta);
    }
    if (data.containsKey('methodology')) {
      context.handle(
        _methodologyMeta,
        methodology.isAcceptableOrUnknown(
          data['methodology']!,
          _methodologyMeta,
        ),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    if (data.containsKey('duplicated_from_id')) {
      context.handle(
        _duplicatedFromIdMeta,
        duplicatedFromId.isAcceptableOrUnknown(
          data['duplicated_from_id']!,
          _duplicatedFromIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HypoPortfolioRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HypoPortfolioRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      objective: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}objective'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      )!,
      baseCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_currency'],
      )!,
      initialCapital: $HypoPortfoliosTable.$converterinitialCapital.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}initial_capital'],
        )!,
      ),
      compositionMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}composition_mode'],
      )!,
      benchmarkJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}benchmark_json'],
      ),
      rebalanceJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rebalance_json'],
      )!,
      assumptionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assumptions_json'],
      )!,
      methodology: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}methodology'],
      ),
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}archived_at'],
      ),
      duplicatedFromId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}duplicated_from_id'],
      ),
    );
  }

  @override
  $HypoPortfoliosTable createAlias(String alias) {
    return $HypoPortfoliosTable(attachedDatabase, alias);
  }

  static TypeConverter<Decimal, String> $converterinitialCapital =
      const DecimalTextConverter();
}

class HypoPortfolioRow extends DataClass
    implements Insertable<HypoPortfolioRow> {
  /// UUID v7 gerado no app.
  final String id;

  /// Instante UTC da criação (ISO-8601 com ms).
  final String createdAt;

  /// Instante UTC da última escrita.
  final String updatedAt;

  /// HLC da última alteração.
  final String hlc;

  /// Dispositivo que fez a última alteração.
  final String deviceId;

  /// Tombstone: preenchido na exclusão lógica.
  final String? deletedAt;
  final String name;
  final String? description;
  final String? objective;
  final String startDate;
  final String baseCurrency;
  final Decimal initialCapital;

  /// `weight` ou `quantity`.
  final String compositionMode;
  final String? benchmarkJson;
  final String rebalanceJson;
  final String assumptionsJson;
  final String? methodology;
  final String? archivedAt;
  final String? duplicatedFromId;
  const HypoPortfolioRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.hlc,
    required this.deviceId,
    this.deletedAt,
    required this.name,
    this.description,
    this.objective,
    required this.startDate,
    required this.baseCurrency,
    required this.initialCapital,
    required this.compositionMode,
    this.benchmarkJson,
    required this.rebalanceJson,
    required this.assumptionsJson,
    this.methodology,
    this.archivedAt,
    this.duplicatedFromId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['hlc'] = Variable<String>(hlc);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || objective != null) {
      map['objective'] = Variable<String>(objective);
    }
    map['start_date'] = Variable<String>(startDate);
    map['base_currency'] = Variable<String>(baseCurrency);
    {
      map['initial_capital'] = Variable<String>(
        $HypoPortfoliosTable.$converterinitialCapital.toSql(initialCapital),
      );
    }
    map['composition_mode'] = Variable<String>(compositionMode);
    if (!nullToAbsent || benchmarkJson != null) {
      map['benchmark_json'] = Variable<String>(benchmarkJson);
    }
    map['rebalance_json'] = Variable<String>(rebalanceJson);
    map['assumptions_json'] = Variable<String>(assumptionsJson);
    if (!nullToAbsent || methodology != null) {
      map['methodology'] = Variable<String>(methodology);
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<String>(archivedAt);
    }
    if (!nullToAbsent || duplicatedFromId != null) {
      map['duplicated_from_id'] = Variable<String>(duplicatedFromId);
    }
    return map;
  }

  HypoPortfoliosCompanion toCompanion(bool nullToAbsent) {
    return HypoPortfoliosCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      hlc: Value(hlc),
      deviceId: Value(deviceId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      objective: objective == null && nullToAbsent
          ? const Value.absent()
          : Value(objective),
      startDate: Value(startDate),
      baseCurrency: Value(baseCurrency),
      initialCapital: Value(initialCapital),
      compositionMode: Value(compositionMode),
      benchmarkJson: benchmarkJson == null && nullToAbsent
          ? const Value.absent()
          : Value(benchmarkJson),
      rebalanceJson: Value(rebalanceJson),
      assumptionsJson: Value(assumptionsJson),
      methodology: methodology == null && nullToAbsent
          ? const Value.absent()
          : Value(methodology),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      duplicatedFromId: duplicatedFromId == null && nullToAbsent
          ? const Value.absent()
          : Value(duplicatedFromId),
    );
  }

  factory HypoPortfolioRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HypoPortfolioRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      objective: serializer.fromJson<String?>(json['objective']),
      startDate: serializer.fromJson<String>(json['startDate']),
      baseCurrency: serializer.fromJson<String>(json['baseCurrency']),
      initialCapital: serializer.fromJson<Decimal>(json['initialCapital']),
      compositionMode: serializer.fromJson<String>(json['compositionMode']),
      benchmarkJson: serializer.fromJson<String?>(json['benchmarkJson']),
      rebalanceJson: serializer.fromJson<String>(json['rebalanceJson']),
      assumptionsJson: serializer.fromJson<String>(json['assumptionsJson']),
      methodology: serializer.fromJson<String?>(json['methodology']),
      archivedAt: serializer.fromJson<String?>(json['archivedAt']),
      duplicatedFromId: serializer.fromJson<String?>(json['duplicatedFromId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'hlc': serializer.toJson<String>(hlc),
      'deviceId': serializer.toJson<String>(deviceId),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'objective': serializer.toJson<String?>(objective),
      'startDate': serializer.toJson<String>(startDate),
      'baseCurrency': serializer.toJson<String>(baseCurrency),
      'initialCapital': serializer.toJson<Decimal>(initialCapital),
      'compositionMode': serializer.toJson<String>(compositionMode),
      'benchmarkJson': serializer.toJson<String?>(benchmarkJson),
      'rebalanceJson': serializer.toJson<String>(rebalanceJson),
      'assumptionsJson': serializer.toJson<String>(assumptionsJson),
      'methodology': serializer.toJson<String?>(methodology),
      'archivedAt': serializer.toJson<String?>(archivedAt),
      'duplicatedFromId': serializer.toJson<String?>(duplicatedFromId),
    };
  }

  HypoPortfolioRow copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? hlc,
    String? deviceId,
    Value<String?> deletedAt = const Value.absent(),
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> objective = const Value.absent(),
    String? startDate,
    String? baseCurrency,
    Decimal? initialCapital,
    String? compositionMode,
    Value<String?> benchmarkJson = const Value.absent(),
    String? rebalanceJson,
    String? assumptionsJson,
    Value<String?> methodology = const Value.absent(),
    Value<String?> archivedAt = const Value.absent(),
    Value<String?> duplicatedFromId = const Value.absent(),
  }) => HypoPortfolioRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    hlc: hlc ?? this.hlc,
    deviceId: deviceId ?? this.deviceId,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    objective: objective.present ? objective.value : this.objective,
    startDate: startDate ?? this.startDate,
    baseCurrency: baseCurrency ?? this.baseCurrency,
    initialCapital: initialCapital ?? this.initialCapital,
    compositionMode: compositionMode ?? this.compositionMode,
    benchmarkJson: benchmarkJson.present
        ? benchmarkJson.value
        : this.benchmarkJson,
    rebalanceJson: rebalanceJson ?? this.rebalanceJson,
    assumptionsJson: assumptionsJson ?? this.assumptionsJson,
    methodology: methodology.present ? methodology.value : this.methodology,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    duplicatedFromId: duplicatedFromId.present
        ? duplicatedFromId.value
        : this.duplicatedFromId,
  );
  HypoPortfolioRow copyWithCompanion(HypoPortfoliosCompanion data) {
    return HypoPortfolioRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      objective: data.objective.present ? data.objective.value : this.objective,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      baseCurrency: data.baseCurrency.present
          ? data.baseCurrency.value
          : this.baseCurrency,
      initialCapital: data.initialCapital.present
          ? data.initialCapital.value
          : this.initialCapital,
      compositionMode: data.compositionMode.present
          ? data.compositionMode.value
          : this.compositionMode,
      benchmarkJson: data.benchmarkJson.present
          ? data.benchmarkJson.value
          : this.benchmarkJson,
      rebalanceJson: data.rebalanceJson.present
          ? data.rebalanceJson.value
          : this.rebalanceJson,
      assumptionsJson: data.assumptionsJson.present
          ? data.assumptionsJson.value
          : this.assumptionsJson,
      methodology: data.methodology.present
          ? data.methodology.value
          : this.methodology,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      duplicatedFromId: data.duplicatedFromId.present
          ? data.duplicatedFromId.value
          : this.duplicatedFromId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HypoPortfolioRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hlc: $hlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('objective: $objective, ')
          ..write('startDate: $startDate, ')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('initialCapital: $initialCapital, ')
          ..write('compositionMode: $compositionMode, ')
          ..write('benchmarkJson: $benchmarkJson, ')
          ..write('rebalanceJson: $rebalanceJson, ')
          ..write('assumptionsJson: $assumptionsJson, ')
          ..write('methodology: $methodology, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('duplicatedFromId: $duplicatedFromId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    hlc,
    deviceId,
    deletedAt,
    name,
    description,
    objective,
    startDate,
    baseCurrency,
    initialCapital,
    compositionMode,
    benchmarkJson,
    rebalanceJson,
    assumptionsJson,
    methodology,
    archivedAt,
    duplicatedFromId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HypoPortfolioRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.hlc == this.hlc &&
          other.deviceId == this.deviceId &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.description == this.description &&
          other.objective == this.objective &&
          other.startDate == this.startDate &&
          other.baseCurrency == this.baseCurrency &&
          other.initialCapital == this.initialCapital &&
          other.compositionMode == this.compositionMode &&
          other.benchmarkJson == this.benchmarkJson &&
          other.rebalanceJson == this.rebalanceJson &&
          other.assumptionsJson == this.assumptionsJson &&
          other.methodology == this.methodology &&
          other.archivedAt == this.archivedAt &&
          other.duplicatedFromId == this.duplicatedFromId);
}

class HypoPortfoliosCompanion extends UpdateCompanion<HypoPortfolioRow> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> hlc;
  final Value<String> deviceId;
  final Value<String?> deletedAt;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> objective;
  final Value<String> startDate;
  final Value<String> baseCurrency;
  final Value<Decimal> initialCapital;
  final Value<String> compositionMode;
  final Value<String?> benchmarkJson;
  final Value<String> rebalanceJson;
  final Value<String> assumptionsJson;
  final Value<String?> methodology;
  final Value<String?> archivedAt;
  final Value<String?> duplicatedFromId;
  final Value<int> rowid;
  const HypoPortfoliosCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.objective = const Value.absent(),
    this.startDate = const Value.absent(),
    this.baseCurrency = const Value.absent(),
    this.initialCapital = const Value.absent(),
    this.compositionMode = const Value.absent(),
    this.benchmarkJson = const Value.absent(),
    this.rebalanceJson = const Value.absent(),
    this.assumptionsJson = const Value.absent(),
    this.methodology = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.duplicatedFromId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HypoPortfoliosCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    required String hlc,
    required String deviceId,
    this.deletedAt = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.objective = const Value.absent(),
    required String startDate,
    required String baseCurrency,
    required Decimal initialCapital,
    required String compositionMode,
    this.benchmarkJson = const Value.absent(),
    required String rebalanceJson,
    required String assumptionsJson,
    this.methodology = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.duplicatedFromId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       hlc = Value(hlc),
       deviceId = Value(deviceId),
       name = Value(name),
       startDate = Value(startDate),
       baseCurrency = Value(baseCurrency),
       initialCapital = Value(initialCapital),
       compositionMode = Value(compositionMode),
       rebalanceJson = Value(rebalanceJson),
       assumptionsJson = Value(assumptionsJson);
  static Insertable<HypoPortfolioRow> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? hlc,
    Expression<String>? deviceId,
    Expression<String>? deletedAt,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? objective,
    Expression<String>? startDate,
    Expression<String>? baseCurrency,
    Expression<String>? initialCapital,
    Expression<String>? compositionMode,
    Expression<String>? benchmarkJson,
    Expression<String>? rebalanceJson,
    Expression<String>? assumptionsJson,
    Expression<String>? methodology,
    Expression<String>? archivedAt,
    Expression<String>? duplicatedFromId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (hlc != null) 'hlc': hlc,
      if (deviceId != null) 'device_id': deviceId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (objective != null) 'objective': objective,
      if (startDate != null) 'start_date': startDate,
      if (baseCurrency != null) 'base_currency': baseCurrency,
      if (initialCapital != null) 'initial_capital': initialCapital,
      if (compositionMode != null) 'composition_mode': compositionMode,
      if (benchmarkJson != null) 'benchmark_json': benchmarkJson,
      if (rebalanceJson != null) 'rebalance_json': rebalanceJson,
      if (assumptionsJson != null) 'assumptions_json': assumptionsJson,
      if (methodology != null) 'methodology': methodology,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (duplicatedFromId != null) 'duplicated_from_id': duplicatedFromId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HypoPortfoliosCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? hlc,
    Value<String>? deviceId,
    Value<String?>? deletedAt,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? objective,
    Value<String>? startDate,
    Value<String>? baseCurrency,
    Value<Decimal>? initialCapital,
    Value<String>? compositionMode,
    Value<String?>? benchmarkJson,
    Value<String>? rebalanceJson,
    Value<String>? assumptionsJson,
    Value<String?>? methodology,
    Value<String?>? archivedAt,
    Value<String?>? duplicatedFromId,
    Value<int>? rowid,
  }) {
    return HypoPortfoliosCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hlc: hlc ?? this.hlc,
      deviceId: deviceId ?? this.deviceId,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      description: description ?? this.description,
      objective: objective ?? this.objective,
      startDate: startDate ?? this.startDate,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      initialCapital: initialCapital ?? this.initialCapital,
      compositionMode: compositionMode ?? this.compositionMode,
      benchmarkJson: benchmarkJson ?? this.benchmarkJson,
      rebalanceJson: rebalanceJson ?? this.rebalanceJson,
      assumptionsJson: assumptionsJson ?? this.assumptionsJson,
      methodology: methodology ?? this.methodology,
      archivedAt: archivedAt ?? this.archivedAt,
      duplicatedFromId: duplicatedFromId ?? this.duplicatedFromId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (objective.present) {
      map['objective'] = Variable<String>(objective.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (baseCurrency.present) {
      map['base_currency'] = Variable<String>(baseCurrency.value);
    }
    if (initialCapital.present) {
      map['initial_capital'] = Variable<String>(
        $HypoPortfoliosTable.$converterinitialCapital.toSql(
          initialCapital.value,
        ),
      );
    }
    if (compositionMode.present) {
      map['composition_mode'] = Variable<String>(compositionMode.value);
    }
    if (benchmarkJson.present) {
      map['benchmark_json'] = Variable<String>(benchmarkJson.value);
    }
    if (rebalanceJson.present) {
      map['rebalance_json'] = Variable<String>(rebalanceJson.value);
    }
    if (assumptionsJson.present) {
      map['assumptions_json'] = Variable<String>(assumptionsJson.value);
    }
    if (methodology.present) {
      map['methodology'] = Variable<String>(methodology.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<String>(archivedAt.value);
    }
    if (duplicatedFromId.present) {
      map['duplicated_from_id'] = Variable<String>(duplicatedFromId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HypoPortfoliosCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hlc: $hlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('objective: $objective, ')
          ..write('startDate: $startDate, ')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('initialCapital: $initialCapital, ')
          ..write('compositionMode: $compositionMode, ')
          ..write('benchmarkJson: $benchmarkJson, ')
          ..write('rebalanceJson: $rebalanceJson, ')
          ..write('assumptionsJson: $assumptionsJson, ')
          ..write('methodology: $methodology, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('duplicatedFromId: $duplicatedFromId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HypoHoldingsTable extends HypoHoldings
    with TableInfo<$HypoHoldingsTable, HypoHoldingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HypoHoldingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _portfolioIdMeta = const VerificationMeta(
    'portfolioId',
  );
  @override
  late final GeneratedColumn<String> portfolioId = GeneratedColumn<String>(
    'portfolio_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES hypo_portfolios (id)',
    ),
  );
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES assets (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> weightPct =
      GeneratedColumn<String>(
        'weight_pct',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($HypoHoldingsTable.$converterweightPctn);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> quantity =
      GeneratedColumn<String>(
        'quantity',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($HypoHoldingsTable.$converterquantityn);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> amount =
      GeneratedColumn<String>(
        'amount',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($HypoHoldingsTable.$converteramountn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    hlc,
    deviceId,
    deletedAt,
    portfolioId,
    assetId,
    weightPct,
    quantity,
    amount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hypo_holdings';
  @override
  VerificationContext validateIntegrity(
    Insertable<HypoHoldingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('portfolio_id')) {
      context.handle(
        _portfolioIdMeta,
        portfolioId.isAcceptableOrUnknown(
          data['portfolio_id']!,
          _portfolioIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_portfolioIdMeta);
    }
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HypoHoldingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HypoHoldingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      portfolioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}portfolio_id'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_id'],
      )!,
      weightPct: $HypoHoldingsTable.$converterweightPctn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}weight_pct'],
        ),
      ),
      quantity: $HypoHoldingsTable.$converterquantityn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}quantity'],
        ),
      ),
      amount: $HypoHoldingsTable.$converteramountn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}amount'],
        ),
      ),
    );
  }

  @override
  $HypoHoldingsTable createAlias(String alias) {
    return $HypoHoldingsTable(attachedDatabase, alias);
  }

  static TypeConverter<Decimal, String> $converterweightPct =
      const DecimalTextConverter();
  static TypeConverter<Decimal?, String?> $converterweightPctn =
      NullAwareTypeConverter.wrap($converterweightPct);
  static TypeConverter<Decimal, String> $converterquantity =
      const DecimalTextConverter();
  static TypeConverter<Decimal?, String?> $converterquantityn =
      NullAwareTypeConverter.wrap($converterquantity);
  static TypeConverter<Decimal, String> $converteramount =
      const DecimalTextConverter();
  static TypeConverter<Decimal?, String?> $converteramountn =
      NullAwareTypeConverter.wrap($converteramount);
}

class HypoHoldingRow extends DataClass implements Insertable<HypoHoldingRow> {
  /// UUID v7 gerado no app.
  final String id;

  /// Instante UTC da criação (ISO-8601 com ms).
  final String createdAt;

  /// Instante UTC da última escrita.
  final String updatedAt;

  /// HLC da última alteração.
  final String hlc;

  /// Dispositivo que fez a última alteração.
  final String deviceId;

  /// Tombstone: preenchido na exclusão lógica.
  final String? deletedAt;
  final String portfolioId;
  final String assetId;
  final Decimal? weightPct;
  final Decimal? quantity;
  final Decimal? amount;
  const HypoHoldingRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.hlc,
    required this.deviceId,
    this.deletedAt,
    required this.portfolioId,
    required this.assetId,
    this.weightPct,
    this.quantity,
    this.amount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['hlc'] = Variable<String>(hlc);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['portfolio_id'] = Variable<String>(portfolioId);
    map['asset_id'] = Variable<String>(assetId);
    if (!nullToAbsent || weightPct != null) {
      map['weight_pct'] = Variable<String>(
        $HypoHoldingsTable.$converterweightPctn.toSql(weightPct),
      );
    }
    if (!nullToAbsent || quantity != null) {
      map['quantity'] = Variable<String>(
        $HypoHoldingsTable.$converterquantityn.toSql(quantity),
      );
    }
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<String>(
        $HypoHoldingsTable.$converteramountn.toSql(amount),
      );
    }
    return map;
  }

  HypoHoldingsCompanion toCompanion(bool nullToAbsent) {
    return HypoHoldingsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      hlc: Value(hlc),
      deviceId: Value(deviceId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      portfolioId: Value(portfolioId),
      assetId: Value(assetId),
      weightPct: weightPct == null && nullToAbsent
          ? const Value.absent()
          : Value(weightPct),
      quantity: quantity == null && nullToAbsent
          ? const Value.absent()
          : Value(quantity),
      amount: amount == null && nullToAbsent
          ? const Value.absent()
          : Value(amount),
    );
  }

  factory HypoHoldingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HypoHoldingRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      portfolioId: serializer.fromJson<String>(json['portfolioId']),
      assetId: serializer.fromJson<String>(json['assetId']),
      weightPct: serializer.fromJson<Decimal?>(json['weightPct']),
      quantity: serializer.fromJson<Decimal?>(json['quantity']),
      amount: serializer.fromJson<Decimal?>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'hlc': serializer.toJson<String>(hlc),
      'deviceId': serializer.toJson<String>(deviceId),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'portfolioId': serializer.toJson<String>(portfolioId),
      'assetId': serializer.toJson<String>(assetId),
      'weightPct': serializer.toJson<Decimal?>(weightPct),
      'quantity': serializer.toJson<Decimal?>(quantity),
      'amount': serializer.toJson<Decimal?>(amount),
    };
  }

  HypoHoldingRow copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? hlc,
    String? deviceId,
    Value<String?> deletedAt = const Value.absent(),
    String? portfolioId,
    String? assetId,
    Value<Decimal?> weightPct = const Value.absent(),
    Value<Decimal?> quantity = const Value.absent(),
    Value<Decimal?> amount = const Value.absent(),
  }) => HypoHoldingRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    hlc: hlc ?? this.hlc,
    deviceId: deviceId ?? this.deviceId,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    portfolioId: portfolioId ?? this.portfolioId,
    assetId: assetId ?? this.assetId,
    weightPct: weightPct.present ? weightPct.value : this.weightPct,
    quantity: quantity.present ? quantity.value : this.quantity,
    amount: amount.present ? amount.value : this.amount,
  );
  HypoHoldingRow copyWithCompanion(HypoHoldingsCompanion data) {
    return HypoHoldingRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      portfolioId: data.portfolioId.present
          ? data.portfolioId.value
          : this.portfolioId,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      weightPct: data.weightPct.present ? data.weightPct.value : this.weightPct,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HypoHoldingRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hlc: $hlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('portfolioId: $portfolioId, ')
          ..write('assetId: $assetId, ')
          ..write('weightPct: $weightPct, ')
          ..write('quantity: $quantity, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    hlc,
    deviceId,
    deletedAt,
    portfolioId,
    assetId,
    weightPct,
    quantity,
    amount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HypoHoldingRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.hlc == this.hlc &&
          other.deviceId == this.deviceId &&
          other.deletedAt == this.deletedAt &&
          other.portfolioId == this.portfolioId &&
          other.assetId == this.assetId &&
          other.weightPct == this.weightPct &&
          other.quantity == this.quantity &&
          other.amount == this.amount);
}

class HypoHoldingsCompanion extends UpdateCompanion<HypoHoldingRow> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> hlc;
  final Value<String> deviceId;
  final Value<String?> deletedAt;
  final Value<String> portfolioId;
  final Value<String> assetId;
  final Value<Decimal?> weightPct;
  final Value<Decimal?> quantity;
  final Value<Decimal?> amount;
  final Value<int> rowid;
  const HypoHoldingsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.portfolioId = const Value.absent(),
    this.assetId = const Value.absent(),
    this.weightPct = const Value.absent(),
    this.quantity = const Value.absent(),
    this.amount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HypoHoldingsCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    required String hlc,
    required String deviceId,
    this.deletedAt = const Value.absent(),
    required String portfolioId,
    required String assetId,
    this.weightPct = const Value.absent(),
    this.quantity = const Value.absent(),
    this.amount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       hlc = Value(hlc),
       deviceId = Value(deviceId),
       portfolioId = Value(portfolioId),
       assetId = Value(assetId);
  static Insertable<HypoHoldingRow> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? hlc,
    Expression<String>? deviceId,
    Expression<String>? deletedAt,
    Expression<String>? portfolioId,
    Expression<String>? assetId,
    Expression<String>? weightPct,
    Expression<String>? quantity,
    Expression<String>? amount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (hlc != null) 'hlc': hlc,
      if (deviceId != null) 'device_id': deviceId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (portfolioId != null) 'portfolio_id': portfolioId,
      if (assetId != null) 'asset_id': assetId,
      if (weightPct != null) 'weight_pct': weightPct,
      if (quantity != null) 'quantity': quantity,
      if (amount != null) 'amount': amount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HypoHoldingsCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? hlc,
    Value<String>? deviceId,
    Value<String?>? deletedAt,
    Value<String>? portfolioId,
    Value<String>? assetId,
    Value<Decimal?>? weightPct,
    Value<Decimal?>? quantity,
    Value<Decimal?>? amount,
    Value<int>? rowid,
  }) {
    return HypoHoldingsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hlc: hlc ?? this.hlc,
      deviceId: deviceId ?? this.deviceId,
      deletedAt: deletedAt ?? this.deletedAt,
      portfolioId: portfolioId ?? this.portfolioId,
      assetId: assetId ?? this.assetId,
      weightPct: weightPct ?? this.weightPct,
      quantity: quantity ?? this.quantity,
      amount: amount ?? this.amount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (portfolioId.present) {
      map['portfolio_id'] = Variable<String>(portfolioId.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (weightPct.present) {
      map['weight_pct'] = Variable<String>(
        $HypoHoldingsTable.$converterweightPctn.toSql(weightPct.value),
      );
    }
    if (quantity.present) {
      map['quantity'] = Variable<String>(
        $HypoHoldingsTable.$converterquantityn.toSql(quantity.value),
      );
    }
    if (amount.present) {
      map['amount'] = Variable<String>(
        $HypoHoldingsTable.$converteramountn.toSql(amount.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HypoHoldingsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hlc: $hlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('portfolioId: $portfolioId, ')
          ..write('assetId: $assetId, ')
          ..write('weightPct: $weightPct, ')
          ..write('quantity: $quantity, ')
          ..write('amount: $amount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HypoCashflowRulesTable extends HypoCashflowRules
    with TableInfo<$HypoCashflowRulesTable, HypoCashflowRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HypoCashflowRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _portfolioIdMeta = const VerificationMeta(
    'portfolioId',
  );
  @override
  late final GeneratedColumn<String> portfolioId = GeneratedColumn<String>(
    'portfolio_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES hypo_portfolios (id)',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> amount =
      GeneratedColumn<String>(
        'amount',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($HypoCashflowRulesTable.$converteramountn);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> pct =
      GeneratedColumn<String>(
        'pct',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($HypoCashflowRulesTable.$converterpctn);
  static const VerificationMeta _adjustmentMeta = const VerificationMeta(
    'adjustment',
  );
  @override
  late final GeneratedColumn<String> adjustment = GeneratedColumn<String>(
    'adjustment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    hlc,
    deviceId,
    deletedAt,
    portfolioId,
    kind,
    frequency,
    amount,
    pct,
    adjustment,
    startDate,
    endDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hypo_cashflow_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<HypoCashflowRuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('portfolio_id')) {
      context.handle(
        _portfolioIdMeta,
        portfolioId.isAcceptableOrUnknown(
          data['portfolio_id']!,
          _portfolioIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_portfolioIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('adjustment')) {
      context.handle(
        _adjustmentMeta,
        adjustment.isAcceptableOrUnknown(data['adjustment']!, _adjustmentMeta),
      );
    } else if (isInserting) {
      context.missing(_adjustmentMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HypoCashflowRuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HypoCashflowRuleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      portfolioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}portfolio_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      amount: $HypoCashflowRulesTable.$converteramountn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}amount'],
        ),
      ),
      pct: $HypoCashflowRulesTable.$converterpctn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}pct'],
        ),
      ),
      adjustment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adjustment'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_date'],
      ),
    );
  }

  @override
  $HypoCashflowRulesTable createAlias(String alias) {
    return $HypoCashflowRulesTable(attachedDatabase, alias);
  }

  static TypeConverter<Decimal, String> $converteramount =
      const DecimalTextConverter();
  static TypeConverter<Decimal?, String?> $converteramountn =
      NullAwareTypeConverter.wrap($converteramount);
  static TypeConverter<Decimal, String> $converterpct =
      const DecimalTextConverter();
  static TypeConverter<Decimal?, String?> $converterpctn =
      NullAwareTypeConverter.wrap($converterpct);
}

class HypoCashflowRuleRow extends DataClass
    implements Insertable<HypoCashflowRuleRow> {
  /// UUID v7 gerado no app.
  final String id;

  /// Instante UTC da criação (ISO-8601 com ms).
  final String createdAt;

  /// Instante UTC da última escrita.
  final String updatedAt;

  /// HLC da última alteração.
  final String hlc;

  /// Dispositivo que fez a última alteração.
  final String deviceId;

  /// Tombstone: preenchido na exclusão lógica.
  final String? deletedAt;
  final String portfolioId;

  /// `contribution` ou `withdrawal`.
  final String kind;
  final String frequency;
  final Decimal? amount;
  final Decimal? pct;
  final String adjustment;
  final String startDate;
  final String? endDate;
  const HypoCashflowRuleRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.hlc,
    required this.deviceId,
    this.deletedAt,
    required this.portfolioId,
    required this.kind,
    required this.frequency,
    this.amount,
    this.pct,
    required this.adjustment,
    required this.startDate,
    this.endDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['hlc'] = Variable<String>(hlc);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['portfolio_id'] = Variable<String>(portfolioId);
    map['kind'] = Variable<String>(kind);
    map['frequency'] = Variable<String>(frequency);
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<String>(
        $HypoCashflowRulesTable.$converteramountn.toSql(amount),
      );
    }
    if (!nullToAbsent || pct != null) {
      map['pct'] = Variable<String>(
        $HypoCashflowRulesTable.$converterpctn.toSql(pct),
      );
    }
    map['adjustment'] = Variable<String>(adjustment);
    map['start_date'] = Variable<String>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(endDate);
    }
    return map;
  }

  HypoCashflowRulesCompanion toCompanion(bool nullToAbsent) {
    return HypoCashflowRulesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      hlc: Value(hlc),
      deviceId: Value(deviceId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      portfolioId: Value(portfolioId),
      kind: Value(kind),
      frequency: Value(frequency),
      amount: amount == null && nullToAbsent
          ? const Value.absent()
          : Value(amount),
      pct: pct == null && nullToAbsent ? const Value.absent() : Value(pct),
      adjustment: Value(adjustment),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
    );
  }

  factory HypoCashflowRuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HypoCashflowRuleRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      portfolioId: serializer.fromJson<String>(json['portfolioId']),
      kind: serializer.fromJson<String>(json['kind']),
      frequency: serializer.fromJson<String>(json['frequency']),
      amount: serializer.fromJson<Decimal?>(json['amount']),
      pct: serializer.fromJson<Decimal?>(json['pct']),
      adjustment: serializer.fromJson<String>(json['adjustment']),
      startDate: serializer.fromJson<String>(json['startDate']),
      endDate: serializer.fromJson<String?>(json['endDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'hlc': serializer.toJson<String>(hlc),
      'deviceId': serializer.toJson<String>(deviceId),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'portfolioId': serializer.toJson<String>(portfolioId),
      'kind': serializer.toJson<String>(kind),
      'frequency': serializer.toJson<String>(frequency),
      'amount': serializer.toJson<Decimal?>(amount),
      'pct': serializer.toJson<Decimal?>(pct),
      'adjustment': serializer.toJson<String>(adjustment),
      'startDate': serializer.toJson<String>(startDate),
      'endDate': serializer.toJson<String?>(endDate),
    };
  }

  HypoCashflowRuleRow copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? hlc,
    String? deviceId,
    Value<String?> deletedAt = const Value.absent(),
    String? portfolioId,
    String? kind,
    String? frequency,
    Value<Decimal?> amount = const Value.absent(),
    Value<Decimal?> pct = const Value.absent(),
    String? adjustment,
    String? startDate,
    Value<String?> endDate = const Value.absent(),
  }) => HypoCashflowRuleRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    hlc: hlc ?? this.hlc,
    deviceId: deviceId ?? this.deviceId,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    portfolioId: portfolioId ?? this.portfolioId,
    kind: kind ?? this.kind,
    frequency: frequency ?? this.frequency,
    amount: amount.present ? amount.value : this.amount,
    pct: pct.present ? pct.value : this.pct,
    adjustment: adjustment ?? this.adjustment,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
  );
  HypoCashflowRuleRow copyWithCompanion(HypoCashflowRulesCompanion data) {
    return HypoCashflowRuleRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      portfolioId: data.portfolioId.present
          ? data.portfolioId.value
          : this.portfolioId,
      kind: data.kind.present ? data.kind.value : this.kind,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      amount: data.amount.present ? data.amount.value : this.amount,
      pct: data.pct.present ? data.pct.value : this.pct,
      adjustment: data.adjustment.present
          ? data.adjustment.value
          : this.adjustment,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HypoCashflowRuleRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hlc: $hlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('portfolioId: $portfolioId, ')
          ..write('kind: $kind, ')
          ..write('frequency: $frequency, ')
          ..write('amount: $amount, ')
          ..write('pct: $pct, ')
          ..write('adjustment: $adjustment, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    hlc,
    deviceId,
    deletedAt,
    portfolioId,
    kind,
    frequency,
    amount,
    pct,
    adjustment,
    startDate,
    endDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HypoCashflowRuleRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.hlc == this.hlc &&
          other.deviceId == this.deviceId &&
          other.deletedAt == this.deletedAt &&
          other.portfolioId == this.portfolioId &&
          other.kind == this.kind &&
          other.frequency == this.frequency &&
          other.amount == this.amount &&
          other.pct == this.pct &&
          other.adjustment == this.adjustment &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate);
}

class HypoCashflowRulesCompanion extends UpdateCompanion<HypoCashflowRuleRow> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> hlc;
  final Value<String> deviceId;
  final Value<String?> deletedAt;
  final Value<String> portfolioId;
  final Value<String> kind;
  final Value<String> frequency;
  final Value<Decimal?> amount;
  final Value<Decimal?> pct;
  final Value<String> adjustment;
  final Value<String> startDate;
  final Value<String?> endDate;
  final Value<int> rowid;
  const HypoCashflowRulesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.portfolioId = const Value.absent(),
    this.kind = const Value.absent(),
    this.frequency = const Value.absent(),
    this.amount = const Value.absent(),
    this.pct = const Value.absent(),
    this.adjustment = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HypoCashflowRulesCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    required String hlc,
    required String deviceId,
    this.deletedAt = const Value.absent(),
    required String portfolioId,
    required String kind,
    required String frequency,
    this.amount = const Value.absent(),
    this.pct = const Value.absent(),
    required String adjustment,
    required String startDate,
    this.endDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       hlc = Value(hlc),
       deviceId = Value(deviceId),
       portfolioId = Value(portfolioId),
       kind = Value(kind),
       frequency = Value(frequency),
       adjustment = Value(adjustment),
       startDate = Value(startDate);
  static Insertable<HypoCashflowRuleRow> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? hlc,
    Expression<String>? deviceId,
    Expression<String>? deletedAt,
    Expression<String>? portfolioId,
    Expression<String>? kind,
    Expression<String>? frequency,
    Expression<String>? amount,
    Expression<String>? pct,
    Expression<String>? adjustment,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (hlc != null) 'hlc': hlc,
      if (deviceId != null) 'device_id': deviceId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (portfolioId != null) 'portfolio_id': portfolioId,
      if (kind != null) 'kind': kind,
      if (frequency != null) 'frequency': frequency,
      if (amount != null) 'amount': amount,
      if (pct != null) 'pct': pct,
      if (adjustment != null) 'adjustment': adjustment,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HypoCashflowRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? hlc,
    Value<String>? deviceId,
    Value<String?>? deletedAt,
    Value<String>? portfolioId,
    Value<String>? kind,
    Value<String>? frequency,
    Value<Decimal?>? amount,
    Value<Decimal?>? pct,
    Value<String>? adjustment,
    Value<String>? startDate,
    Value<String?>? endDate,
    Value<int>? rowid,
  }) {
    return HypoCashflowRulesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hlc: hlc ?? this.hlc,
      deviceId: deviceId ?? this.deviceId,
      deletedAt: deletedAt ?? this.deletedAt,
      portfolioId: portfolioId ?? this.portfolioId,
      kind: kind ?? this.kind,
      frequency: frequency ?? this.frequency,
      amount: amount ?? this.amount,
      pct: pct ?? this.pct,
      adjustment: adjustment ?? this.adjustment,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (portfolioId.present) {
      map['portfolio_id'] = Variable<String>(portfolioId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(
        $HypoCashflowRulesTable.$converteramountn.toSql(amount.value),
      );
    }
    if (pct.present) {
      map['pct'] = Variable<String>(
        $HypoCashflowRulesTable.$converterpctn.toSql(pct.value),
      );
    }
    if (adjustment.present) {
      map['adjustment'] = Variable<String>(adjustment.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HypoCashflowRulesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hlc: $hlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('portfolioId: $portfolioId, ')
          ..write('kind: $kind, ')
          ..write('frequency: $frequency, ')
          ..write('amount: $amount, ')
          ..write('pct: $pct, ')
          ..write('adjustment: $adjustment, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HypoScenariosTable extends HypoScenarios
    with TableInfo<$HypoScenariosTable, HypoScenarioRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HypoScenariosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _portfolioIdMeta = const VerificationMeta(
    'portfolioId',
  );
  @override
  late final GeneratedColumn<String> portfolioId = GeneratedColumn<String>(
    'portfolio_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES hypo_portfolios (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assumptionsJsonMeta = const VerificationMeta(
    'assumptionsJson',
  );
  @override
  late final GeneratedColumn<String> assumptionsJson = GeneratedColumn<String>(
    'assumptions_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    hlc,
    deviceId,
    deletedAt,
    portfolioId,
    name,
    kind,
    assumptionsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hypo_scenarios';
  @override
  VerificationContext validateIntegrity(
    Insertable<HypoScenarioRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('portfolio_id')) {
      context.handle(
        _portfolioIdMeta,
        portfolioId.isAcceptableOrUnknown(
          data['portfolio_id']!,
          _portfolioIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('assumptions_json')) {
      context.handle(
        _assumptionsJsonMeta,
        assumptionsJson.isAcceptableOrUnknown(
          data['assumptions_json']!,
          _assumptionsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assumptionsJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HypoScenarioRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HypoScenarioRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      portfolioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}portfolio_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      assumptionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assumptions_json'],
      )!,
    );
  }

  @override
  $HypoScenariosTable createAlias(String alias) {
    return $HypoScenariosTable(attachedDatabase, alias);
  }
}

class HypoScenarioRow extends DataClass implements Insertable<HypoScenarioRow> {
  /// UUID v7 gerado no app.
  final String id;

  /// Instante UTC da criação (ISO-8601 com ms).
  final String createdAt;

  /// Instante UTC da última escrita.
  final String updatedAt;

  /// HLC da última alteração.
  final String hlc;

  /// Dispositivo que fez a última alteração.
  final String deviceId;

  /// Tombstone: preenchido na exclusão lógica.
  final String? deletedAt;

  /// Nulo para cenários dos simuladores.
  final String? portfolioId;
  final String name;
  final String kind;
  final String assumptionsJson;
  const HypoScenarioRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.hlc,
    required this.deviceId,
    this.deletedAt,
    this.portfolioId,
    required this.name,
    required this.kind,
    required this.assumptionsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['hlc'] = Variable<String>(hlc);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || portfolioId != null) {
      map['portfolio_id'] = Variable<String>(portfolioId);
    }
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['assumptions_json'] = Variable<String>(assumptionsJson);
    return map;
  }

  HypoScenariosCompanion toCompanion(bool nullToAbsent) {
    return HypoScenariosCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      hlc: Value(hlc),
      deviceId: Value(deviceId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      portfolioId: portfolioId == null && nullToAbsent
          ? const Value.absent()
          : Value(portfolioId),
      name: Value(name),
      kind: Value(kind),
      assumptionsJson: Value(assumptionsJson),
    );
  }

  factory HypoScenarioRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HypoScenarioRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      portfolioId: serializer.fromJson<String?>(json['portfolioId']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      assumptionsJson: serializer.fromJson<String>(json['assumptionsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'hlc': serializer.toJson<String>(hlc),
      'deviceId': serializer.toJson<String>(deviceId),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'portfolioId': serializer.toJson<String?>(portfolioId),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'assumptionsJson': serializer.toJson<String>(assumptionsJson),
    };
  }

  HypoScenarioRow copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? hlc,
    String? deviceId,
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> portfolioId = const Value.absent(),
    String? name,
    String? kind,
    String? assumptionsJson,
  }) => HypoScenarioRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    hlc: hlc ?? this.hlc,
    deviceId: deviceId ?? this.deviceId,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    portfolioId: portfolioId.present ? portfolioId.value : this.portfolioId,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    assumptionsJson: assumptionsJson ?? this.assumptionsJson,
  );
  HypoScenarioRow copyWithCompanion(HypoScenariosCompanion data) {
    return HypoScenarioRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      portfolioId: data.portfolioId.present
          ? data.portfolioId.value
          : this.portfolioId,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      assumptionsJson: data.assumptionsJson.present
          ? data.assumptionsJson.value
          : this.assumptionsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HypoScenarioRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hlc: $hlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('portfolioId: $portfolioId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('assumptionsJson: $assumptionsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    hlc,
    deviceId,
    deletedAt,
    portfolioId,
    name,
    kind,
    assumptionsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HypoScenarioRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.hlc == this.hlc &&
          other.deviceId == this.deviceId &&
          other.deletedAt == this.deletedAt &&
          other.portfolioId == this.portfolioId &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.assumptionsJson == this.assumptionsJson);
}

class HypoScenariosCompanion extends UpdateCompanion<HypoScenarioRow> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> hlc;
  final Value<String> deviceId;
  final Value<String?> deletedAt;
  final Value<String?> portfolioId;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> assumptionsJson;
  final Value<int> rowid;
  const HypoScenariosCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.portfolioId = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.assumptionsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HypoScenariosCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    required String hlc,
    required String deviceId,
    this.deletedAt = const Value.absent(),
    this.portfolioId = const Value.absent(),
    required String name,
    required String kind,
    required String assumptionsJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       hlc = Value(hlc),
       deviceId = Value(deviceId),
       name = Value(name),
       kind = Value(kind),
       assumptionsJson = Value(assumptionsJson);
  static Insertable<HypoScenarioRow> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? hlc,
    Expression<String>? deviceId,
    Expression<String>? deletedAt,
    Expression<String>? portfolioId,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? assumptionsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (hlc != null) 'hlc': hlc,
      if (deviceId != null) 'device_id': deviceId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (portfolioId != null) 'portfolio_id': portfolioId,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (assumptionsJson != null) 'assumptions_json': assumptionsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HypoScenariosCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? hlc,
    Value<String>? deviceId,
    Value<String?>? deletedAt,
    Value<String?>? portfolioId,
    Value<String>? name,
    Value<String>? kind,
    Value<String>? assumptionsJson,
    Value<int>? rowid,
  }) {
    return HypoScenariosCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hlc: hlc ?? this.hlc,
      deviceId: deviceId ?? this.deviceId,
      deletedAt: deletedAt ?? this.deletedAt,
      portfolioId: portfolioId ?? this.portfolioId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      assumptionsJson: assumptionsJson ?? this.assumptionsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (portfolioId.present) {
      map['portfolio_id'] = Variable<String>(portfolioId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (assumptionsJson.present) {
      map['assumptions_json'] = Variable<String>(assumptionsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HypoScenariosCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hlc: $hlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('portfolioId: $portfolioId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('assumptionsJson: $assumptionsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DevSyncPeersTable extends DevSyncPeers
    with TableInfo<$DevSyncPeersTable, DevSyncPeerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevSyncPeersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _peerDeviceIdMeta = const VerificationMeta(
    'peerDeviceId',
  );
  @override
  late final GeneratedColumn<String> peerDeviceId = GeneratedColumn<String>(
    'peer_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _peerNameMeta = const VerificationMeta(
    'peerName',
  );
  @override
  late final GeneratedColumn<String> peerName = GeneratedColumn<String>(
    'peer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastHlcReceivedMeta = const VerificationMeta(
    'lastHlcReceived',
  );
  @override
  late final GeneratedColumn<String> lastHlcReceived = GeneratedColumn<String>(
    'last_hlc_received',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastHlcSentMeta = const VerificationMeta(
    'lastHlcSent',
  );
  @override
  late final GeneratedColumn<String> lastHlcSent = GeneratedColumn<String>(
    'last_hlc_sent',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta(
    'lastSyncAt',
  );
  @override
  late final GeneratedColumn<String> lastSyncAt = GeneratedColumn<String>(
    'last_sync_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    peerDeviceId,
    peerName,
    lastHlcReceived,
    lastHlcSent,
    lastSyncAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dev_sync_peers';
  @override
  VerificationContext validateIntegrity(
    Insertable<DevSyncPeerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('peer_device_id')) {
      context.handle(
        _peerDeviceIdMeta,
        peerDeviceId.isAcceptableOrUnknown(
          data['peer_device_id']!,
          _peerDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_peerDeviceIdMeta);
    }
    if (data.containsKey('peer_name')) {
      context.handle(
        _peerNameMeta,
        peerName.isAcceptableOrUnknown(data['peer_name']!, _peerNameMeta),
      );
    } else if (isInserting) {
      context.missing(_peerNameMeta);
    }
    if (data.containsKey('last_hlc_received')) {
      context.handle(
        _lastHlcReceivedMeta,
        lastHlcReceived.isAcceptableOrUnknown(
          data['last_hlc_received']!,
          _lastHlcReceivedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastHlcReceivedMeta);
    }
    if (data.containsKey('last_hlc_sent')) {
      context.handle(
        _lastHlcSentMeta,
        lastHlcSent.isAcceptableOrUnknown(
          data['last_hlc_sent']!,
          _lastHlcSentMeta,
        ),
      );
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(
          data['last_sync_at']!,
          _lastSyncAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSyncAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {peerDeviceId};
  @override
  DevSyncPeerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DevSyncPeerRow(
      peerDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}peer_device_id'],
      )!,
      peerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}peer_name'],
      )!,
      lastHlcReceived: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_hlc_received'],
      )!,
      lastHlcSent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_hlc_sent'],
      ),
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_sync_at'],
      )!,
    );
  }

  @override
  $DevSyncPeersTable createAlias(String alias) {
    return $DevSyncPeersTable(attachedDatabase, alias);
  }
}

class DevSyncPeerRow extends DataClass implements Insertable<DevSyncPeerRow> {
  final String peerDeviceId;
  final String peerName;

  /// Maior HLC do último save importado desse dispositivo.
  final String lastHlcReceived;

  /// Maior HLC deste PC que esse dispositivo confirmou ter recebido (vem no
  /// manifesto dos saves dele).
  final String? lastHlcSent;
  final String lastSyncAt;
  const DevSyncPeerRow({
    required this.peerDeviceId,
    required this.peerName,
    required this.lastHlcReceived,
    this.lastHlcSent,
    required this.lastSyncAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['peer_device_id'] = Variable<String>(peerDeviceId);
    map['peer_name'] = Variable<String>(peerName);
    map['last_hlc_received'] = Variable<String>(lastHlcReceived);
    if (!nullToAbsent || lastHlcSent != null) {
      map['last_hlc_sent'] = Variable<String>(lastHlcSent);
    }
    map['last_sync_at'] = Variable<String>(lastSyncAt);
    return map;
  }

  DevSyncPeersCompanion toCompanion(bool nullToAbsent) {
    return DevSyncPeersCompanion(
      peerDeviceId: Value(peerDeviceId),
      peerName: Value(peerName),
      lastHlcReceived: Value(lastHlcReceived),
      lastHlcSent: lastHlcSent == null && nullToAbsent
          ? const Value.absent()
          : Value(lastHlcSent),
      lastSyncAt: Value(lastSyncAt),
    );
  }

  factory DevSyncPeerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DevSyncPeerRow(
      peerDeviceId: serializer.fromJson<String>(json['peerDeviceId']),
      peerName: serializer.fromJson<String>(json['peerName']),
      lastHlcReceived: serializer.fromJson<String>(json['lastHlcReceived']),
      lastHlcSent: serializer.fromJson<String?>(json['lastHlcSent']),
      lastSyncAt: serializer.fromJson<String>(json['lastSyncAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'peerDeviceId': serializer.toJson<String>(peerDeviceId),
      'peerName': serializer.toJson<String>(peerName),
      'lastHlcReceived': serializer.toJson<String>(lastHlcReceived),
      'lastHlcSent': serializer.toJson<String?>(lastHlcSent),
      'lastSyncAt': serializer.toJson<String>(lastSyncAt),
    };
  }

  DevSyncPeerRow copyWith({
    String? peerDeviceId,
    String? peerName,
    String? lastHlcReceived,
    Value<String?> lastHlcSent = const Value.absent(),
    String? lastSyncAt,
  }) => DevSyncPeerRow(
    peerDeviceId: peerDeviceId ?? this.peerDeviceId,
    peerName: peerName ?? this.peerName,
    lastHlcReceived: lastHlcReceived ?? this.lastHlcReceived,
    lastHlcSent: lastHlcSent.present ? lastHlcSent.value : this.lastHlcSent,
    lastSyncAt: lastSyncAt ?? this.lastSyncAt,
  );
  DevSyncPeerRow copyWithCompanion(DevSyncPeersCompanion data) {
    return DevSyncPeerRow(
      peerDeviceId: data.peerDeviceId.present
          ? data.peerDeviceId.value
          : this.peerDeviceId,
      peerName: data.peerName.present ? data.peerName.value : this.peerName,
      lastHlcReceived: data.lastHlcReceived.present
          ? data.lastHlcReceived.value
          : this.lastHlcReceived,
      lastHlcSent: data.lastHlcSent.present
          ? data.lastHlcSent.value
          : this.lastHlcSent,
      lastSyncAt: data.lastSyncAt.present
          ? data.lastSyncAt.value
          : this.lastSyncAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DevSyncPeerRow(')
          ..write('peerDeviceId: $peerDeviceId, ')
          ..write('peerName: $peerName, ')
          ..write('lastHlcReceived: $lastHlcReceived, ')
          ..write('lastHlcSent: $lastHlcSent, ')
          ..write('lastSyncAt: $lastSyncAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    peerDeviceId,
    peerName,
    lastHlcReceived,
    lastHlcSent,
    lastSyncAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DevSyncPeerRow &&
          other.peerDeviceId == this.peerDeviceId &&
          other.peerName == this.peerName &&
          other.lastHlcReceived == this.lastHlcReceived &&
          other.lastHlcSent == this.lastHlcSent &&
          other.lastSyncAt == this.lastSyncAt);
}

class DevSyncPeersCompanion extends UpdateCompanion<DevSyncPeerRow> {
  final Value<String> peerDeviceId;
  final Value<String> peerName;
  final Value<String> lastHlcReceived;
  final Value<String?> lastHlcSent;
  final Value<String> lastSyncAt;
  final Value<int> rowid;
  const DevSyncPeersCompanion({
    this.peerDeviceId = const Value.absent(),
    this.peerName = const Value.absent(),
    this.lastHlcReceived = const Value.absent(),
    this.lastHlcSent = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevSyncPeersCompanion.insert({
    required String peerDeviceId,
    required String peerName,
    required String lastHlcReceived,
    this.lastHlcSent = const Value.absent(),
    required String lastSyncAt,
    this.rowid = const Value.absent(),
  }) : peerDeviceId = Value(peerDeviceId),
       peerName = Value(peerName),
       lastHlcReceived = Value(lastHlcReceived),
       lastSyncAt = Value(lastSyncAt);
  static Insertable<DevSyncPeerRow> custom({
    Expression<String>? peerDeviceId,
    Expression<String>? peerName,
    Expression<String>? lastHlcReceived,
    Expression<String>? lastHlcSent,
    Expression<String>? lastSyncAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (peerDeviceId != null) 'peer_device_id': peerDeviceId,
      if (peerName != null) 'peer_name': peerName,
      if (lastHlcReceived != null) 'last_hlc_received': lastHlcReceived,
      if (lastHlcSent != null) 'last_hlc_sent': lastHlcSent,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevSyncPeersCompanion copyWith({
    Value<String>? peerDeviceId,
    Value<String>? peerName,
    Value<String>? lastHlcReceived,
    Value<String?>? lastHlcSent,
    Value<String>? lastSyncAt,
    Value<int>? rowid,
  }) {
    return DevSyncPeersCompanion(
      peerDeviceId: peerDeviceId ?? this.peerDeviceId,
      peerName: peerName ?? this.peerName,
      lastHlcReceived: lastHlcReceived ?? this.lastHlcReceived,
      lastHlcSent: lastHlcSent ?? this.lastHlcSent,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (peerDeviceId.present) {
      map['peer_device_id'] = Variable<String>(peerDeviceId.value);
    }
    if (peerName.present) {
      map['peer_name'] = Variable<String>(peerName.value);
    }
    if (lastHlcReceived.present) {
      map['last_hlc_received'] = Variable<String>(lastHlcReceived.value);
    }
    if (lastHlcSent.present) {
      map['last_hlc_sent'] = Variable<String>(lastHlcSent.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<String>(lastSyncAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevSyncPeersCompanion(')
          ..write('peerDeviceId: $peerDeviceId, ')
          ..write('peerName: $peerName, ')
          ..write('lastHlcReceived: $lastHlcReceived, ')
          ..write('lastHlcSent: $lastHlcSent, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DevSyncHistoryTable extends DevSyncHistory
    with TableInfo<$DevSyncHistoryTable, DevSyncHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevSyncHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _peerDeviceIdMeta = const VerificationMeta(
    'peerDeviceId',
  );
  @override
  late final GeneratedColumn<String> peerDeviceId = GeneratedColumn<String>(
    'peer_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _peerNameMeta = const VerificationMeta(
    'peerName',
  );
  @override
  late final GeneratedColumn<String> peerName = GeneratedColumn<String>(
    'peer_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<String> at = GeneratedColumn<String>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxHlcMeta = const VerificationMeta('maxHlc');
  @override
  late final GeneratedColumn<String> maxHlc = GeneratedColumn<String>(
    'max_hlc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countsJsonMeta = const VerificationMeta(
    'countsJson',
  );
  @override
  late final GeneratedColumn<String> countsJson = GeneratedColumn<String>(
    'counts_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    direction,
    peerDeviceId,
    peerName,
    fileName,
    at,
    maxHlc,
    countsJson,
    result,
    message,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dev_sync_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<DevSyncHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('peer_device_id')) {
      context.handle(
        _peerDeviceIdMeta,
        peerDeviceId.isAcceptableOrUnknown(
          data['peer_device_id']!,
          _peerDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('peer_name')) {
      context.handle(
        _peerNameMeta,
        peerName.isAcceptableOrUnknown(data['peer_name']!, _peerNameMeta),
      );
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('max_hlc')) {
      context.handle(
        _maxHlcMeta,
        maxHlc.isAcceptableOrUnknown(data['max_hlc']!, _maxHlcMeta),
      );
    }
    if (data.containsKey('counts_json')) {
      context.handle(
        _countsJsonMeta,
        countsJson.isAcceptableOrUnknown(data['counts_json']!, _countsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_countsJsonMeta);
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
      );
    } else if (isInserting) {
      context.missing(_resultMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DevSyncHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DevSyncHistoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      peerDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}peer_device_id'],
      ),
      peerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}peer_name'],
      ),
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}at'],
      )!,
      maxHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}max_hlc'],
      ),
      countsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}counts_json'],
      )!,
      result: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      ),
    );
  }

  @override
  $DevSyncHistoryTable createAlias(String alias) {
    return $DevSyncHistoryTable(attachedDatabase, alias);
  }
}

class DevSyncHistoryRow extends DataClass
    implements Insertable<DevSyncHistoryRow> {
  final String id;

  /// `export` ou `import`.
  final String direction;
  final String? peerDeviceId;
  final String? peerName;
  final String fileName;
  final String at;
  final String? maxHlc;

  /// Contagens por tabela (JSON). Nunca valores patrimoniais.
  final String countsJson;

  /// `ok` ou `failed`.
  final String result;
  final String? message;
  const DevSyncHistoryRow({
    required this.id,
    required this.direction,
    this.peerDeviceId,
    this.peerName,
    required this.fileName,
    required this.at,
    this.maxHlc,
    required this.countsJson,
    required this.result,
    this.message,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['direction'] = Variable<String>(direction);
    if (!nullToAbsent || peerDeviceId != null) {
      map['peer_device_id'] = Variable<String>(peerDeviceId);
    }
    if (!nullToAbsent || peerName != null) {
      map['peer_name'] = Variable<String>(peerName);
    }
    map['file_name'] = Variable<String>(fileName);
    map['at'] = Variable<String>(at);
    if (!nullToAbsent || maxHlc != null) {
      map['max_hlc'] = Variable<String>(maxHlc);
    }
    map['counts_json'] = Variable<String>(countsJson);
    map['result'] = Variable<String>(result);
    if (!nullToAbsent || message != null) {
      map['message'] = Variable<String>(message);
    }
    return map;
  }

  DevSyncHistoryCompanion toCompanion(bool nullToAbsent) {
    return DevSyncHistoryCompanion(
      id: Value(id),
      direction: Value(direction),
      peerDeviceId: peerDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(peerDeviceId),
      peerName: peerName == null && nullToAbsent
          ? const Value.absent()
          : Value(peerName),
      fileName: Value(fileName),
      at: Value(at),
      maxHlc: maxHlc == null && nullToAbsent
          ? const Value.absent()
          : Value(maxHlc),
      countsJson: Value(countsJson),
      result: Value(result),
      message: message == null && nullToAbsent
          ? const Value.absent()
          : Value(message),
    );
  }

  factory DevSyncHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DevSyncHistoryRow(
      id: serializer.fromJson<String>(json['id']),
      direction: serializer.fromJson<String>(json['direction']),
      peerDeviceId: serializer.fromJson<String?>(json['peerDeviceId']),
      peerName: serializer.fromJson<String?>(json['peerName']),
      fileName: serializer.fromJson<String>(json['fileName']),
      at: serializer.fromJson<String>(json['at']),
      maxHlc: serializer.fromJson<String?>(json['maxHlc']),
      countsJson: serializer.fromJson<String>(json['countsJson']),
      result: serializer.fromJson<String>(json['result']),
      message: serializer.fromJson<String?>(json['message']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'direction': serializer.toJson<String>(direction),
      'peerDeviceId': serializer.toJson<String?>(peerDeviceId),
      'peerName': serializer.toJson<String?>(peerName),
      'fileName': serializer.toJson<String>(fileName),
      'at': serializer.toJson<String>(at),
      'maxHlc': serializer.toJson<String?>(maxHlc),
      'countsJson': serializer.toJson<String>(countsJson),
      'result': serializer.toJson<String>(result),
      'message': serializer.toJson<String?>(message),
    };
  }

  DevSyncHistoryRow copyWith({
    String? id,
    String? direction,
    Value<String?> peerDeviceId = const Value.absent(),
    Value<String?> peerName = const Value.absent(),
    String? fileName,
    String? at,
    Value<String?> maxHlc = const Value.absent(),
    String? countsJson,
    String? result,
    Value<String?> message = const Value.absent(),
  }) => DevSyncHistoryRow(
    id: id ?? this.id,
    direction: direction ?? this.direction,
    peerDeviceId: peerDeviceId.present ? peerDeviceId.value : this.peerDeviceId,
    peerName: peerName.present ? peerName.value : this.peerName,
    fileName: fileName ?? this.fileName,
    at: at ?? this.at,
    maxHlc: maxHlc.present ? maxHlc.value : this.maxHlc,
    countsJson: countsJson ?? this.countsJson,
    result: result ?? this.result,
    message: message.present ? message.value : this.message,
  );
  DevSyncHistoryRow copyWithCompanion(DevSyncHistoryCompanion data) {
    return DevSyncHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      direction: data.direction.present ? data.direction.value : this.direction,
      peerDeviceId: data.peerDeviceId.present
          ? data.peerDeviceId.value
          : this.peerDeviceId,
      peerName: data.peerName.present ? data.peerName.value : this.peerName,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      at: data.at.present ? data.at.value : this.at,
      maxHlc: data.maxHlc.present ? data.maxHlc.value : this.maxHlc,
      countsJson: data.countsJson.present
          ? data.countsJson.value
          : this.countsJson,
      result: data.result.present ? data.result.value : this.result,
      message: data.message.present ? data.message.value : this.message,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DevSyncHistoryRow(')
          ..write('id: $id, ')
          ..write('direction: $direction, ')
          ..write('peerDeviceId: $peerDeviceId, ')
          ..write('peerName: $peerName, ')
          ..write('fileName: $fileName, ')
          ..write('at: $at, ')
          ..write('maxHlc: $maxHlc, ')
          ..write('countsJson: $countsJson, ')
          ..write('result: $result, ')
          ..write('message: $message')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    direction,
    peerDeviceId,
    peerName,
    fileName,
    at,
    maxHlc,
    countsJson,
    result,
    message,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DevSyncHistoryRow &&
          other.id == this.id &&
          other.direction == this.direction &&
          other.peerDeviceId == this.peerDeviceId &&
          other.peerName == this.peerName &&
          other.fileName == this.fileName &&
          other.at == this.at &&
          other.maxHlc == this.maxHlc &&
          other.countsJson == this.countsJson &&
          other.result == this.result &&
          other.message == this.message);
}

class DevSyncHistoryCompanion extends UpdateCompanion<DevSyncHistoryRow> {
  final Value<String> id;
  final Value<String> direction;
  final Value<String?> peerDeviceId;
  final Value<String?> peerName;
  final Value<String> fileName;
  final Value<String> at;
  final Value<String?> maxHlc;
  final Value<String> countsJson;
  final Value<String> result;
  final Value<String?> message;
  final Value<int> rowid;
  const DevSyncHistoryCompanion({
    this.id = const Value.absent(),
    this.direction = const Value.absent(),
    this.peerDeviceId = const Value.absent(),
    this.peerName = const Value.absent(),
    this.fileName = const Value.absent(),
    this.at = const Value.absent(),
    this.maxHlc = const Value.absent(),
    this.countsJson = const Value.absent(),
    this.result = const Value.absent(),
    this.message = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevSyncHistoryCompanion.insert({
    required String id,
    required String direction,
    this.peerDeviceId = const Value.absent(),
    this.peerName = const Value.absent(),
    required String fileName,
    required String at,
    this.maxHlc = const Value.absent(),
    required String countsJson,
    required String result,
    this.message = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       direction = Value(direction),
       fileName = Value(fileName),
       at = Value(at),
       countsJson = Value(countsJson),
       result = Value(result);
  static Insertable<DevSyncHistoryRow> custom({
    Expression<String>? id,
    Expression<String>? direction,
    Expression<String>? peerDeviceId,
    Expression<String>? peerName,
    Expression<String>? fileName,
    Expression<String>? at,
    Expression<String>? maxHlc,
    Expression<String>? countsJson,
    Expression<String>? result,
    Expression<String>? message,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (direction != null) 'direction': direction,
      if (peerDeviceId != null) 'peer_device_id': peerDeviceId,
      if (peerName != null) 'peer_name': peerName,
      if (fileName != null) 'file_name': fileName,
      if (at != null) 'at': at,
      if (maxHlc != null) 'max_hlc': maxHlc,
      if (countsJson != null) 'counts_json': countsJson,
      if (result != null) 'result': result,
      if (message != null) 'message': message,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevSyncHistoryCompanion copyWith({
    Value<String>? id,
    Value<String>? direction,
    Value<String?>? peerDeviceId,
    Value<String?>? peerName,
    Value<String>? fileName,
    Value<String>? at,
    Value<String?>? maxHlc,
    Value<String>? countsJson,
    Value<String>? result,
    Value<String?>? message,
    Value<int>? rowid,
  }) {
    return DevSyncHistoryCompanion(
      id: id ?? this.id,
      direction: direction ?? this.direction,
      peerDeviceId: peerDeviceId ?? this.peerDeviceId,
      peerName: peerName ?? this.peerName,
      fileName: fileName ?? this.fileName,
      at: at ?? this.at,
      maxHlc: maxHlc ?? this.maxHlc,
      countsJson: countsJson ?? this.countsJson,
      result: result ?? this.result,
      message: message ?? this.message,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (peerDeviceId.present) {
      map['peer_device_id'] = Variable<String>(peerDeviceId.value);
    }
    if (peerName.present) {
      map['peer_name'] = Variable<String>(peerName.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (at.present) {
      map['at'] = Variable<String>(at.value);
    }
    if (maxHlc.present) {
      map['max_hlc'] = Variable<String>(maxHlc.value);
    }
    if (countsJson.present) {
      map['counts_json'] = Variable<String>(countsJson.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevSyncHistoryCompanion(')
          ..write('id: $id, ')
          ..write('direction: $direction, ')
          ..write('peerDeviceId: $peerDeviceId, ')
          ..write('peerName: $peerName, ')
          ..write('fileName: $fileName, ')
          ..write('at: $at, ')
          ..write('maxHlc: $maxHlc, ')
          ..write('countsJson: $countsJson, ')
          ..write('result: $result, ')
          ..write('message: $message, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DevBackupsTable extends DevBackups
    with TableInfo<$DevBackupsTable, DevBackupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevBackupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<String> at = GeneratedColumn<String>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appVersionMeta = const VerificationMeta(
    'appVersion',
  );
  @override
  late final GeneratedColumn<String> appVersion = GeneratedColumn<String>(
    'app_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encryptionMeta = const VerificationMeta(
    'encryption',
  );
  @override
  late final GeneratedColumn<String> encryption = GeneratedColumn<String>(
    'encryption',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    path,
    at,
    reason,
    schemaVersion,
    appVersion,
    size,
    sha256,
    encryption,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dev_backups';
  @override
  VerificationContext validateIntegrity(
    Insertable<DevBackupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('app_version')) {
      context.handle(
        _appVersionMeta,
        appVersion.isAcceptableOrUnknown(data['app_version']!, _appVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_appVersionMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('encryption')) {
      context.handle(
        _encryptionMeta,
        encryption.isAcceptableOrUnknown(data['encryption']!, _encryptionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DevBackupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DevBackupRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}at'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      appVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_version'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      encryption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encryption'],
      )!,
    );
  }

  @override
  $DevBackupsTable createAlias(String alias) {
    return $DevBackupsTable(attachedDatabase, alias);
  }
}

class DevBackupRow extends DataClass implements Insertable<DevBackupRow> {
  final String id;
  final String path;
  final String at;

  /// `manual`, `pre-migracao`, `pre-importacao` ou `pre-restauracao`.
  final String reason;
  final int schemaVersion;
  final String appVersion;
  final int size;
  final String sha256;

  /// `none` na v1.0. Preparação para o banco criptografado da F5B
  /// (DECISIONS D-24).
  final String encryption;
  const DevBackupRow({
    required this.id,
    required this.path,
    required this.at,
    required this.reason,
    required this.schemaVersion,
    required this.appVersion,
    required this.size,
    required this.sha256,
    required this.encryption,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['path'] = Variable<String>(path);
    map['at'] = Variable<String>(at);
    map['reason'] = Variable<String>(reason);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['app_version'] = Variable<String>(appVersion);
    map['size'] = Variable<int>(size);
    map['sha256'] = Variable<String>(sha256);
    map['encryption'] = Variable<String>(encryption);
    return map;
  }

  DevBackupsCompanion toCompanion(bool nullToAbsent) {
    return DevBackupsCompanion(
      id: Value(id),
      path: Value(path),
      at: Value(at),
      reason: Value(reason),
      schemaVersion: Value(schemaVersion),
      appVersion: Value(appVersion),
      size: Value(size),
      sha256: Value(sha256),
      encryption: Value(encryption),
    );
  }

  factory DevBackupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DevBackupRow(
      id: serializer.fromJson<String>(json['id']),
      path: serializer.fromJson<String>(json['path']),
      at: serializer.fromJson<String>(json['at']),
      reason: serializer.fromJson<String>(json['reason']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      appVersion: serializer.fromJson<String>(json['appVersion']),
      size: serializer.fromJson<int>(json['size']),
      sha256: serializer.fromJson<String>(json['sha256']),
      encryption: serializer.fromJson<String>(json['encryption']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'path': serializer.toJson<String>(path),
      'at': serializer.toJson<String>(at),
      'reason': serializer.toJson<String>(reason),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'appVersion': serializer.toJson<String>(appVersion),
      'size': serializer.toJson<int>(size),
      'sha256': serializer.toJson<String>(sha256),
      'encryption': serializer.toJson<String>(encryption),
    };
  }

  DevBackupRow copyWith({
    String? id,
    String? path,
    String? at,
    String? reason,
    int? schemaVersion,
    String? appVersion,
    int? size,
    String? sha256,
    String? encryption,
  }) => DevBackupRow(
    id: id ?? this.id,
    path: path ?? this.path,
    at: at ?? this.at,
    reason: reason ?? this.reason,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    appVersion: appVersion ?? this.appVersion,
    size: size ?? this.size,
    sha256: sha256 ?? this.sha256,
    encryption: encryption ?? this.encryption,
  );
  DevBackupRow copyWithCompanion(DevBackupsCompanion data) {
    return DevBackupRow(
      id: data.id.present ? data.id.value : this.id,
      path: data.path.present ? data.path.value : this.path,
      at: data.at.present ? data.at.value : this.at,
      reason: data.reason.present ? data.reason.value : this.reason,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      appVersion: data.appVersion.present
          ? data.appVersion.value
          : this.appVersion,
      size: data.size.present ? data.size.value : this.size,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      encryption: data.encryption.present
          ? data.encryption.value
          : this.encryption,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DevBackupRow(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('at: $at, ')
          ..write('reason: $reason, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('appVersion: $appVersion, ')
          ..write('size: $size, ')
          ..write('sha256: $sha256, ')
          ..write('encryption: $encryption')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    path,
    at,
    reason,
    schemaVersion,
    appVersion,
    size,
    sha256,
    encryption,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DevBackupRow &&
          other.id == this.id &&
          other.path == this.path &&
          other.at == this.at &&
          other.reason == this.reason &&
          other.schemaVersion == this.schemaVersion &&
          other.appVersion == this.appVersion &&
          other.size == this.size &&
          other.sha256 == this.sha256 &&
          other.encryption == this.encryption);
}

class DevBackupsCompanion extends UpdateCompanion<DevBackupRow> {
  final Value<String> id;
  final Value<String> path;
  final Value<String> at;
  final Value<String> reason;
  final Value<int> schemaVersion;
  final Value<String> appVersion;
  final Value<int> size;
  final Value<String> sha256;
  final Value<String> encryption;
  final Value<int> rowid;
  const DevBackupsCompanion({
    this.id = const Value.absent(),
    this.path = const Value.absent(),
    this.at = const Value.absent(),
    this.reason = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.size = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.encryption = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevBackupsCompanion.insert({
    required String id,
    required String path,
    required String at,
    required String reason,
    required int schemaVersion,
    required String appVersion,
    required int size,
    required String sha256,
    this.encryption = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       path = Value(path),
       at = Value(at),
       reason = Value(reason),
       schemaVersion = Value(schemaVersion),
       appVersion = Value(appVersion),
       size = Value(size),
       sha256 = Value(sha256);
  static Insertable<DevBackupRow> custom({
    Expression<String>? id,
    Expression<String>? path,
    Expression<String>? at,
    Expression<String>? reason,
    Expression<int>? schemaVersion,
    Expression<String>? appVersion,
    Expression<int>? size,
    Expression<String>? sha256,
    Expression<String>? encryption,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (path != null) 'path': path,
      if (at != null) 'at': at,
      if (reason != null) 'reason': reason,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (appVersion != null) 'app_version': appVersion,
      if (size != null) 'size': size,
      if (sha256 != null) 'sha256': sha256,
      if (encryption != null) 'encryption': encryption,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevBackupsCompanion copyWith({
    Value<String>? id,
    Value<String>? path,
    Value<String>? at,
    Value<String>? reason,
    Value<int>? schemaVersion,
    Value<String>? appVersion,
    Value<int>? size,
    Value<String>? sha256,
    Value<String>? encryption,
    Value<int>? rowid,
  }) {
    return DevBackupsCompanion(
      id: id ?? this.id,
      path: path ?? this.path,
      at: at ?? this.at,
      reason: reason ?? this.reason,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      appVersion: appVersion ?? this.appVersion,
      size: size ?? this.size,
      sha256: sha256 ?? this.sha256,
      encryption: encryption ?? this.encryption,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (at.present) {
      map['at'] = Variable<String>(at.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (appVersion.present) {
      map['app_version'] = Variable<String>(appVersion.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (encryption.present) {
      map['encryption'] = Variable<String>(encryption.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevBackupsCompanion(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('at: $at, ')
          ..write('reason: $reason, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('appVersion: $appVersion, ')
          ..write('size: $size, ')
          ..write('sha256: $sha256, ')
          ..write('encryption: $encryption, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MktPricesTable extends MktPrices
    with TableInfo<$MktPricesTable, MktPriceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MktPricesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marketMeta = const VerificationMeta('market');
  @override
  late final GeneratedColumn<String> market = GeneratedColumn<String>(
    'market',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refDateMeta = const VerificationMeta(
    'refDate',
  );
  @override
  late final GeneratedColumn<String> refDate = GeneratedColumn<String>(
    'ref_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataTypeMeta = const VerificationMeta(
    'dataType',
  );
  @override
  late final GeneratedColumn<String> dataType = GeneratedColumn<String>(
    'data_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openMeta = const VerificationMeta('open');
  @override
  late final GeneratedColumn<String> open = GeneratedColumn<String>(
    'open',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _highMeta = const VerificationMeta('high');
  @override
  late final GeneratedColumn<String> high = GeneratedColumn<String>(
    'high',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lowMeta = const VerificationMeta('low');
  @override
  late final GeneratedColumn<String> low = GeneratedColumn<String>(
    'low',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closeMeta = const VerificationMeta('close');
  @override
  late final GeneratedColumn<String> close = GeneratedColumn<String>(
    'close',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _volumeMeta = const VerificationMeta('volume');
  @override
  late final GeneratedColumn<String> volume = GeneratedColumn<String>(
    'volume',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quoteFactorMeta = const VerificationMeta(
    'quoteFactor',
  );
  @override
  late final GeneratedColumn<String> quoteFactor = GeneratedColumn<String>(
    'quote_factor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectedAtMeta = const VerificationMeta(
    'collectedAt',
  );
  @override
  late final GeneratedColumn<String> collectedAt = GeneratedColumn<String>(
    'collected_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    symbol,
    market,
    refDate,
    source,
    dataType,
    open,
    high,
    low,
    close,
    volume,
    currency,
    quoteFactor,
    collectedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mkt_prices';
  @override
  VerificationContext validateIntegrity(
    Insertable<MktPriceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('market')) {
      context.handle(
        _marketMeta,
        market.isAcceptableOrUnknown(data['market']!, _marketMeta),
      );
    } else if (isInserting) {
      context.missing(_marketMeta);
    }
    if (data.containsKey('ref_date')) {
      context.handle(
        _refDateMeta,
        refDate.isAcceptableOrUnknown(data['ref_date']!, _refDateMeta),
      );
    } else if (isInserting) {
      context.missing(_refDateMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('data_type')) {
      context.handle(
        _dataTypeMeta,
        dataType.isAcceptableOrUnknown(data['data_type']!, _dataTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_dataTypeMeta);
    }
    if (data.containsKey('open')) {
      context.handle(
        _openMeta,
        open.isAcceptableOrUnknown(data['open']!, _openMeta),
      );
    }
    if (data.containsKey('high')) {
      context.handle(
        _highMeta,
        high.isAcceptableOrUnknown(data['high']!, _highMeta),
      );
    }
    if (data.containsKey('low')) {
      context.handle(
        _lowMeta,
        low.isAcceptableOrUnknown(data['low']!, _lowMeta),
      );
    }
    if (data.containsKey('close')) {
      context.handle(
        _closeMeta,
        close.isAcceptableOrUnknown(data['close']!, _closeMeta),
      );
    } else if (isInserting) {
      context.missing(_closeMeta);
    }
    if (data.containsKey('volume')) {
      context.handle(
        _volumeMeta,
        volume.isAcceptableOrUnknown(data['volume']!, _volumeMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('quote_factor')) {
      context.handle(
        _quoteFactorMeta,
        quoteFactor.isAcceptableOrUnknown(
          data['quote_factor']!,
          _quoteFactorMeta,
        ),
      );
    }
    if (data.containsKey('collected_at')) {
      context.handle(
        _collectedAtMeta,
        collectedAt.isAcceptableOrUnknown(
          data['collected_at']!,
          _collectedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    symbol,
    market,
    refDate,
    source,
    dataType,
  };
  @override
  MktPriceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MktPriceRow(
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      market: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}market'],
      )!,
      refDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_date'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      dataType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_type'],
      )!,
      open: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}open'],
      ),
      high: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}high'],
      ),
      low: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}low'],
      ),
      close: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}close'],
      )!,
      volume: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}volume'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      quoteFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quote_factor'],
      ),
      collectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collected_at'],
      )!,
    );
  }

  @override
  $MktPricesTable createAlias(String alias) {
    return $MktPricesTable(attachedDatabase, alias);
  }
}

class MktPriceRow extends DataClass implements Insertable<MktPriceRow> {
  final String symbol;
  final String market;
  final String refDate;
  final String source;

  /// `close`, `adjusted` ou `calculated`.
  final String dataType;
  final String? open;
  final String? high;
  final String? low;
  final String close;
  final String? volume;
  final String currency;
  final String? quoteFactor;
  final String collectedAt;
  const MktPriceRow({
    required this.symbol,
    required this.market,
    required this.refDate,
    required this.source,
    required this.dataType,
    this.open,
    this.high,
    this.low,
    required this.close,
    this.volume,
    required this.currency,
    this.quoteFactor,
    required this.collectedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['symbol'] = Variable<String>(symbol);
    map['market'] = Variable<String>(market);
    map['ref_date'] = Variable<String>(refDate);
    map['source'] = Variable<String>(source);
    map['data_type'] = Variable<String>(dataType);
    if (!nullToAbsent || open != null) {
      map['open'] = Variable<String>(open);
    }
    if (!nullToAbsent || high != null) {
      map['high'] = Variable<String>(high);
    }
    if (!nullToAbsent || low != null) {
      map['low'] = Variable<String>(low);
    }
    map['close'] = Variable<String>(close);
    if (!nullToAbsent || volume != null) {
      map['volume'] = Variable<String>(volume);
    }
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || quoteFactor != null) {
      map['quote_factor'] = Variable<String>(quoteFactor);
    }
    map['collected_at'] = Variable<String>(collectedAt);
    return map;
  }

  MktPricesCompanion toCompanion(bool nullToAbsent) {
    return MktPricesCompanion(
      symbol: Value(symbol),
      market: Value(market),
      refDate: Value(refDate),
      source: Value(source),
      dataType: Value(dataType),
      open: open == null && nullToAbsent ? const Value.absent() : Value(open),
      high: high == null && nullToAbsent ? const Value.absent() : Value(high),
      low: low == null && nullToAbsent ? const Value.absent() : Value(low),
      close: Value(close),
      volume: volume == null && nullToAbsent
          ? const Value.absent()
          : Value(volume),
      currency: Value(currency),
      quoteFactor: quoteFactor == null && nullToAbsent
          ? const Value.absent()
          : Value(quoteFactor),
      collectedAt: Value(collectedAt),
    );
  }

  factory MktPriceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MktPriceRow(
      symbol: serializer.fromJson<String>(json['symbol']),
      market: serializer.fromJson<String>(json['market']),
      refDate: serializer.fromJson<String>(json['refDate']),
      source: serializer.fromJson<String>(json['source']),
      dataType: serializer.fromJson<String>(json['dataType']),
      open: serializer.fromJson<String?>(json['open']),
      high: serializer.fromJson<String?>(json['high']),
      low: serializer.fromJson<String?>(json['low']),
      close: serializer.fromJson<String>(json['close']),
      volume: serializer.fromJson<String?>(json['volume']),
      currency: serializer.fromJson<String>(json['currency']),
      quoteFactor: serializer.fromJson<String?>(json['quoteFactor']),
      collectedAt: serializer.fromJson<String>(json['collectedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'symbol': serializer.toJson<String>(symbol),
      'market': serializer.toJson<String>(market),
      'refDate': serializer.toJson<String>(refDate),
      'source': serializer.toJson<String>(source),
      'dataType': serializer.toJson<String>(dataType),
      'open': serializer.toJson<String?>(open),
      'high': serializer.toJson<String?>(high),
      'low': serializer.toJson<String?>(low),
      'close': serializer.toJson<String>(close),
      'volume': serializer.toJson<String?>(volume),
      'currency': serializer.toJson<String>(currency),
      'quoteFactor': serializer.toJson<String?>(quoteFactor),
      'collectedAt': serializer.toJson<String>(collectedAt),
    };
  }

  MktPriceRow copyWith({
    String? symbol,
    String? market,
    String? refDate,
    String? source,
    String? dataType,
    Value<String?> open = const Value.absent(),
    Value<String?> high = const Value.absent(),
    Value<String?> low = const Value.absent(),
    String? close,
    Value<String?> volume = const Value.absent(),
    String? currency,
    Value<String?> quoteFactor = const Value.absent(),
    String? collectedAt,
  }) => MktPriceRow(
    symbol: symbol ?? this.symbol,
    market: market ?? this.market,
    refDate: refDate ?? this.refDate,
    source: source ?? this.source,
    dataType: dataType ?? this.dataType,
    open: open.present ? open.value : this.open,
    high: high.present ? high.value : this.high,
    low: low.present ? low.value : this.low,
    close: close ?? this.close,
    volume: volume.present ? volume.value : this.volume,
    currency: currency ?? this.currency,
    quoteFactor: quoteFactor.present ? quoteFactor.value : this.quoteFactor,
    collectedAt: collectedAt ?? this.collectedAt,
  );
  MktPriceRow copyWithCompanion(MktPricesCompanion data) {
    return MktPriceRow(
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      market: data.market.present ? data.market.value : this.market,
      refDate: data.refDate.present ? data.refDate.value : this.refDate,
      source: data.source.present ? data.source.value : this.source,
      dataType: data.dataType.present ? data.dataType.value : this.dataType,
      open: data.open.present ? data.open.value : this.open,
      high: data.high.present ? data.high.value : this.high,
      low: data.low.present ? data.low.value : this.low,
      close: data.close.present ? data.close.value : this.close,
      volume: data.volume.present ? data.volume.value : this.volume,
      currency: data.currency.present ? data.currency.value : this.currency,
      quoteFactor: data.quoteFactor.present
          ? data.quoteFactor.value
          : this.quoteFactor,
      collectedAt: data.collectedAt.present
          ? data.collectedAt.value
          : this.collectedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MktPriceRow(')
          ..write('symbol: $symbol, ')
          ..write('market: $market, ')
          ..write('refDate: $refDate, ')
          ..write('source: $source, ')
          ..write('dataType: $dataType, ')
          ..write('open: $open, ')
          ..write('high: $high, ')
          ..write('low: $low, ')
          ..write('close: $close, ')
          ..write('volume: $volume, ')
          ..write('currency: $currency, ')
          ..write('quoteFactor: $quoteFactor, ')
          ..write('collectedAt: $collectedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    symbol,
    market,
    refDate,
    source,
    dataType,
    open,
    high,
    low,
    close,
    volume,
    currency,
    quoteFactor,
    collectedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MktPriceRow &&
          other.symbol == this.symbol &&
          other.market == this.market &&
          other.refDate == this.refDate &&
          other.source == this.source &&
          other.dataType == this.dataType &&
          other.open == this.open &&
          other.high == this.high &&
          other.low == this.low &&
          other.close == this.close &&
          other.volume == this.volume &&
          other.currency == this.currency &&
          other.quoteFactor == this.quoteFactor &&
          other.collectedAt == this.collectedAt);
}

class MktPricesCompanion extends UpdateCompanion<MktPriceRow> {
  final Value<String> symbol;
  final Value<String> market;
  final Value<String> refDate;
  final Value<String> source;
  final Value<String> dataType;
  final Value<String?> open;
  final Value<String?> high;
  final Value<String?> low;
  final Value<String> close;
  final Value<String?> volume;
  final Value<String> currency;
  final Value<String?> quoteFactor;
  final Value<String> collectedAt;
  final Value<int> rowid;
  const MktPricesCompanion({
    this.symbol = const Value.absent(),
    this.market = const Value.absent(),
    this.refDate = const Value.absent(),
    this.source = const Value.absent(),
    this.dataType = const Value.absent(),
    this.open = const Value.absent(),
    this.high = const Value.absent(),
    this.low = const Value.absent(),
    this.close = const Value.absent(),
    this.volume = const Value.absent(),
    this.currency = const Value.absent(),
    this.quoteFactor = const Value.absent(),
    this.collectedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MktPricesCompanion.insert({
    required String symbol,
    required String market,
    required String refDate,
    required String source,
    required String dataType,
    this.open = const Value.absent(),
    this.high = const Value.absent(),
    this.low = const Value.absent(),
    required String close,
    this.volume = const Value.absent(),
    required String currency,
    this.quoteFactor = const Value.absent(),
    required String collectedAt,
    this.rowid = const Value.absent(),
  }) : symbol = Value(symbol),
       market = Value(market),
       refDate = Value(refDate),
       source = Value(source),
       dataType = Value(dataType),
       close = Value(close),
       currency = Value(currency),
       collectedAt = Value(collectedAt);
  static Insertable<MktPriceRow> custom({
    Expression<String>? symbol,
    Expression<String>? market,
    Expression<String>? refDate,
    Expression<String>? source,
    Expression<String>? dataType,
    Expression<String>? open,
    Expression<String>? high,
    Expression<String>? low,
    Expression<String>? close,
    Expression<String>? volume,
    Expression<String>? currency,
    Expression<String>? quoteFactor,
    Expression<String>? collectedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (symbol != null) 'symbol': symbol,
      if (market != null) 'market': market,
      if (refDate != null) 'ref_date': refDate,
      if (source != null) 'source': source,
      if (dataType != null) 'data_type': dataType,
      if (open != null) 'open': open,
      if (high != null) 'high': high,
      if (low != null) 'low': low,
      if (close != null) 'close': close,
      if (volume != null) 'volume': volume,
      if (currency != null) 'currency': currency,
      if (quoteFactor != null) 'quote_factor': quoteFactor,
      if (collectedAt != null) 'collected_at': collectedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MktPricesCompanion copyWith({
    Value<String>? symbol,
    Value<String>? market,
    Value<String>? refDate,
    Value<String>? source,
    Value<String>? dataType,
    Value<String?>? open,
    Value<String?>? high,
    Value<String?>? low,
    Value<String>? close,
    Value<String?>? volume,
    Value<String>? currency,
    Value<String?>? quoteFactor,
    Value<String>? collectedAt,
    Value<int>? rowid,
  }) {
    return MktPricesCompanion(
      symbol: symbol ?? this.symbol,
      market: market ?? this.market,
      refDate: refDate ?? this.refDate,
      source: source ?? this.source,
      dataType: dataType ?? this.dataType,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      volume: volume ?? this.volume,
      currency: currency ?? this.currency,
      quoteFactor: quoteFactor ?? this.quoteFactor,
      collectedAt: collectedAt ?? this.collectedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (market.present) {
      map['market'] = Variable<String>(market.value);
    }
    if (refDate.present) {
      map['ref_date'] = Variable<String>(refDate.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (dataType.present) {
      map['data_type'] = Variable<String>(dataType.value);
    }
    if (open.present) {
      map['open'] = Variable<String>(open.value);
    }
    if (high.present) {
      map['high'] = Variable<String>(high.value);
    }
    if (low.present) {
      map['low'] = Variable<String>(low.value);
    }
    if (close.present) {
      map['close'] = Variable<String>(close.value);
    }
    if (volume.present) {
      map['volume'] = Variable<String>(volume.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (quoteFactor.present) {
      map['quote_factor'] = Variable<String>(quoteFactor.value);
    }
    if (collectedAt.present) {
      map['collected_at'] = Variable<String>(collectedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MktPricesCompanion(')
          ..write('symbol: $symbol, ')
          ..write('market: $market, ')
          ..write('refDate: $refDate, ')
          ..write('source: $source, ')
          ..write('dataType: $dataType, ')
          ..write('open: $open, ')
          ..write('high: $high, ')
          ..write('low: $low, ')
          ..write('close: $close, ')
          ..write('volume: $volume, ')
          ..write('currency: $currency, ')
          ..write('quoteFactor: $quoteFactor, ')
          ..write('collectedAt: $collectedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MktQuotesTable extends MktQuotes
    with TableInfo<$MktQuotesTable, MktQuoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MktQuotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marketMeta = const VerificationMeta('market');
  @override
  late final GeneratedColumn<String> market = GeneratedColumn<String>(
    'market',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<String> price = GeneratedColumn<String>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refAtMeta = const VerificationMeta('refAt');
  @override
  late final GeneratedColumn<String> refAt = GeneratedColumn<String>(
    'ref_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _delayNoteMeta = const VerificationMeta(
    'delayNote',
  );
  @override
  late final GeneratedColumn<String> delayNote = GeneratedColumn<String>(
    'delay_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dataTypeMeta = const VerificationMeta(
    'dataType',
  );
  @override
  late final GeneratedColumn<String> dataType = GeneratedColumn<String>(
    'data_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectedAtMeta = const VerificationMeta(
    'collectedAt',
  );
  @override
  late final GeneratedColumn<String> collectedAt = GeneratedColumn<String>(
    'collected_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    symbol,
    market,
    source,
    price,
    currency,
    refAt,
    delayNote,
    dataType,
    collectedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mkt_quotes';
  @override
  VerificationContext validateIntegrity(
    Insertable<MktQuoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('market')) {
      context.handle(
        _marketMeta,
        market.isAcceptableOrUnknown(data['market']!, _marketMeta),
      );
    } else if (isInserting) {
      context.missing(_marketMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('ref_at')) {
      context.handle(
        _refAtMeta,
        refAt.isAcceptableOrUnknown(data['ref_at']!, _refAtMeta),
      );
    } else if (isInserting) {
      context.missing(_refAtMeta);
    }
    if (data.containsKey('delay_note')) {
      context.handle(
        _delayNoteMeta,
        delayNote.isAcceptableOrUnknown(data['delay_note']!, _delayNoteMeta),
      );
    }
    if (data.containsKey('data_type')) {
      context.handle(
        _dataTypeMeta,
        dataType.isAcceptableOrUnknown(data['data_type']!, _dataTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_dataTypeMeta);
    }
    if (data.containsKey('collected_at')) {
      context.handle(
        _collectedAtMeta,
        collectedAt.isAcceptableOrUnknown(
          data['collected_at']!,
          _collectedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {symbol, market, source};
  @override
  MktQuoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MktQuoteRow(
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      market: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}market'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}price'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      refAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_at'],
      )!,
      delayNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delay_note'],
      ),
      dataType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_type'],
      )!,
      collectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collected_at'],
      )!,
    );
  }

  @override
  $MktQuotesTable createAlias(String alias) {
    return $MktQuotesTable(attachedDatabase, alias);
  }
}

class MktQuoteRow extends DataClass implements Insertable<MktQuoteRow> {
  final String symbol;
  final String market;
  final String source;
  final String price;
  final String currency;

  /// Instante UTC a que o preço se refere (do provedor).
  final String refAt;

  /// Atraso informado pelo provedor (por exemplo, "até 30 min").
  final String? delayNote;

  /// `intraday` ou `close`.
  final String dataType;
  final String collectedAt;
  const MktQuoteRow({
    required this.symbol,
    required this.market,
    required this.source,
    required this.price,
    required this.currency,
    required this.refAt,
    this.delayNote,
    required this.dataType,
    required this.collectedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['symbol'] = Variable<String>(symbol);
    map['market'] = Variable<String>(market);
    map['source'] = Variable<String>(source);
    map['price'] = Variable<String>(price);
    map['currency'] = Variable<String>(currency);
    map['ref_at'] = Variable<String>(refAt);
    if (!nullToAbsent || delayNote != null) {
      map['delay_note'] = Variable<String>(delayNote);
    }
    map['data_type'] = Variable<String>(dataType);
    map['collected_at'] = Variable<String>(collectedAt);
    return map;
  }

  MktQuotesCompanion toCompanion(bool nullToAbsent) {
    return MktQuotesCompanion(
      symbol: Value(symbol),
      market: Value(market),
      source: Value(source),
      price: Value(price),
      currency: Value(currency),
      refAt: Value(refAt),
      delayNote: delayNote == null && nullToAbsent
          ? const Value.absent()
          : Value(delayNote),
      dataType: Value(dataType),
      collectedAt: Value(collectedAt),
    );
  }

  factory MktQuoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MktQuoteRow(
      symbol: serializer.fromJson<String>(json['symbol']),
      market: serializer.fromJson<String>(json['market']),
      source: serializer.fromJson<String>(json['source']),
      price: serializer.fromJson<String>(json['price']),
      currency: serializer.fromJson<String>(json['currency']),
      refAt: serializer.fromJson<String>(json['refAt']),
      delayNote: serializer.fromJson<String?>(json['delayNote']),
      dataType: serializer.fromJson<String>(json['dataType']),
      collectedAt: serializer.fromJson<String>(json['collectedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'symbol': serializer.toJson<String>(symbol),
      'market': serializer.toJson<String>(market),
      'source': serializer.toJson<String>(source),
      'price': serializer.toJson<String>(price),
      'currency': serializer.toJson<String>(currency),
      'refAt': serializer.toJson<String>(refAt),
      'delayNote': serializer.toJson<String?>(delayNote),
      'dataType': serializer.toJson<String>(dataType),
      'collectedAt': serializer.toJson<String>(collectedAt),
    };
  }

  MktQuoteRow copyWith({
    String? symbol,
    String? market,
    String? source,
    String? price,
    String? currency,
    String? refAt,
    Value<String?> delayNote = const Value.absent(),
    String? dataType,
    String? collectedAt,
  }) => MktQuoteRow(
    symbol: symbol ?? this.symbol,
    market: market ?? this.market,
    source: source ?? this.source,
    price: price ?? this.price,
    currency: currency ?? this.currency,
    refAt: refAt ?? this.refAt,
    delayNote: delayNote.present ? delayNote.value : this.delayNote,
    dataType: dataType ?? this.dataType,
    collectedAt: collectedAt ?? this.collectedAt,
  );
  MktQuoteRow copyWithCompanion(MktQuotesCompanion data) {
    return MktQuoteRow(
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      market: data.market.present ? data.market.value : this.market,
      source: data.source.present ? data.source.value : this.source,
      price: data.price.present ? data.price.value : this.price,
      currency: data.currency.present ? data.currency.value : this.currency,
      refAt: data.refAt.present ? data.refAt.value : this.refAt,
      delayNote: data.delayNote.present ? data.delayNote.value : this.delayNote,
      dataType: data.dataType.present ? data.dataType.value : this.dataType,
      collectedAt: data.collectedAt.present
          ? data.collectedAt.value
          : this.collectedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MktQuoteRow(')
          ..write('symbol: $symbol, ')
          ..write('market: $market, ')
          ..write('source: $source, ')
          ..write('price: $price, ')
          ..write('currency: $currency, ')
          ..write('refAt: $refAt, ')
          ..write('delayNote: $delayNote, ')
          ..write('dataType: $dataType, ')
          ..write('collectedAt: $collectedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    symbol,
    market,
    source,
    price,
    currency,
    refAt,
    delayNote,
    dataType,
    collectedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MktQuoteRow &&
          other.symbol == this.symbol &&
          other.market == this.market &&
          other.source == this.source &&
          other.price == this.price &&
          other.currency == this.currency &&
          other.refAt == this.refAt &&
          other.delayNote == this.delayNote &&
          other.dataType == this.dataType &&
          other.collectedAt == this.collectedAt);
}

class MktQuotesCompanion extends UpdateCompanion<MktQuoteRow> {
  final Value<String> symbol;
  final Value<String> market;
  final Value<String> source;
  final Value<String> price;
  final Value<String> currency;
  final Value<String> refAt;
  final Value<String?> delayNote;
  final Value<String> dataType;
  final Value<String> collectedAt;
  final Value<int> rowid;
  const MktQuotesCompanion({
    this.symbol = const Value.absent(),
    this.market = const Value.absent(),
    this.source = const Value.absent(),
    this.price = const Value.absent(),
    this.currency = const Value.absent(),
    this.refAt = const Value.absent(),
    this.delayNote = const Value.absent(),
    this.dataType = const Value.absent(),
    this.collectedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MktQuotesCompanion.insert({
    required String symbol,
    required String market,
    required String source,
    required String price,
    required String currency,
    required String refAt,
    this.delayNote = const Value.absent(),
    required String dataType,
    required String collectedAt,
    this.rowid = const Value.absent(),
  }) : symbol = Value(symbol),
       market = Value(market),
       source = Value(source),
       price = Value(price),
       currency = Value(currency),
       refAt = Value(refAt),
       dataType = Value(dataType),
       collectedAt = Value(collectedAt);
  static Insertable<MktQuoteRow> custom({
    Expression<String>? symbol,
    Expression<String>? market,
    Expression<String>? source,
    Expression<String>? price,
    Expression<String>? currency,
    Expression<String>? refAt,
    Expression<String>? delayNote,
    Expression<String>? dataType,
    Expression<String>? collectedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (symbol != null) 'symbol': symbol,
      if (market != null) 'market': market,
      if (source != null) 'source': source,
      if (price != null) 'price': price,
      if (currency != null) 'currency': currency,
      if (refAt != null) 'ref_at': refAt,
      if (delayNote != null) 'delay_note': delayNote,
      if (dataType != null) 'data_type': dataType,
      if (collectedAt != null) 'collected_at': collectedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MktQuotesCompanion copyWith({
    Value<String>? symbol,
    Value<String>? market,
    Value<String>? source,
    Value<String>? price,
    Value<String>? currency,
    Value<String>? refAt,
    Value<String?>? delayNote,
    Value<String>? dataType,
    Value<String>? collectedAt,
    Value<int>? rowid,
  }) {
    return MktQuotesCompanion(
      symbol: symbol ?? this.symbol,
      market: market ?? this.market,
      source: source ?? this.source,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      refAt: refAt ?? this.refAt,
      delayNote: delayNote ?? this.delayNote,
      dataType: dataType ?? this.dataType,
      collectedAt: collectedAt ?? this.collectedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (market.present) {
      map['market'] = Variable<String>(market.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (price.present) {
      map['price'] = Variable<String>(price.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (refAt.present) {
      map['ref_at'] = Variable<String>(refAt.value);
    }
    if (delayNote.present) {
      map['delay_note'] = Variable<String>(delayNote.value);
    }
    if (dataType.present) {
      map['data_type'] = Variable<String>(dataType.value);
    }
    if (collectedAt.present) {
      map['collected_at'] = Variable<String>(collectedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MktQuotesCompanion(')
          ..write('symbol: $symbol, ')
          ..write('market: $market, ')
          ..write('source: $source, ')
          ..write('price: $price, ')
          ..write('currency: $currency, ')
          ..write('refAt: $refAt, ')
          ..write('delayNote: $delayNote, ')
          ..write('dataType: $dataType, ')
          ..write('collectedAt: $collectedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MktCorporateEventsTable extends MktCorporateEvents
    with TableInfo<$MktCorporateEventsTable, MktCorporateEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MktCorporateEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marketMeta = const VerificationMeta('market');
  @override
  late final GeneratedColumn<String> market = GeneratedColumn<String>(
    'market',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventKindMeta = const VerificationMeta(
    'eventKind',
  );
  @override
  late final GeneratedColumn<String> eventKind = GeneratedColumn<String>(
    'event_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exDateMeta = const VerificationMeta('exDate');
  @override
  late final GeneratedColumn<String> exDate = GeneratedColumn<String>(
    'ex_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<String> seq = GeneratedColumn<String>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _comDateMeta = const VerificationMeta(
    'comDate',
  );
  @override
  late final GeneratedColumn<String> comDate = GeneratedColumn<String>(
    'com_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentDateMeta = const VerificationMeta(
    'paymentDate',
  );
  @override
  late final GeneratedColumn<String> paymentDate = GeneratedColumn<String>(
    'payment_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _factorMeta = const VerificationMeta('factor');
  @override
  late final GeneratedColumn<String> factor = GeneratedColumn<String>(
    'factor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
    'amount',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawLabelMeta = const VerificationMeta(
    'rawLabel',
  );
  @override
  late final GeneratedColumn<String> rawLabel = GeneratedColumn<String>(
    'raw_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isinMeta = const VerificationMeta('isin');
  @override
  late final GeneratedColumn<String> isin = GeneratedColumn<String>(
    'isin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectedAtMeta = const VerificationMeta(
    'collectedAt',
  );
  @override
  late final GeneratedColumn<String> collectedAt = GeneratedColumn<String>(
    'collected_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    symbol,
    market,
    eventKind,
    exDate,
    source,
    seq,
    comDate,
    paymentDate,
    factor,
    amount,
    currency,
    status,
    rawLabel,
    isin,
    collectedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mkt_corporate_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<MktCorporateEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('market')) {
      context.handle(
        _marketMeta,
        market.isAcceptableOrUnknown(data['market']!, _marketMeta),
      );
    } else if (isInserting) {
      context.missing(_marketMeta);
    }
    if (data.containsKey('event_kind')) {
      context.handle(
        _eventKindMeta,
        eventKind.isAcceptableOrUnknown(data['event_kind']!, _eventKindMeta),
      );
    } else if (isInserting) {
      context.missing(_eventKindMeta);
    }
    if (data.containsKey('ex_date')) {
      context.handle(
        _exDateMeta,
        exDate.isAcceptableOrUnknown(data['ex_date']!, _exDateMeta),
      );
    } else if (isInserting) {
      context.missing(_exDateMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('com_date')) {
      context.handle(
        _comDateMeta,
        comDate.isAcceptableOrUnknown(data['com_date']!, _comDateMeta),
      );
    }
    if (data.containsKey('payment_date')) {
      context.handle(
        _paymentDateMeta,
        paymentDate.isAcceptableOrUnknown(
          data['payment_date']!,
          _paymentDateMeta,
        ),
      );
    }
    if (data.containsKey('factor')) {
      context.handle(
        _factorMeta,
        factor.isAcceptableOrUnknown(data['factor']!, _factorMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('raw_label')) {
      context.handle(
        _rawLabelMeta,
        rawLabel.isAcceptableOrUnknown(data['raw_label']!, _rawLabelMeta),
      );
    }
    if (data.containsKey('isin')) {
      context.handle(
        _isinMeta,
        isin.isAcceptableOrUnknown(data['isin']!, _isinMeta),
      );
    }
    if (data.containsKey('collected_at')) {
      context.handle(
        _collectedAtMeta,
        collectedAt.isAcceptableOrUnknown(
          data['collected_at']!,
          _collectedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    symbol,
    market,
    eventKind,
    exDate,
    source,
    seq,
  };
  @override
  MktCorporateEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MktCorporateEventRow(
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      market: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}market'],
      )!,
      eventKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_kind'],
      )!,
      exDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ex_date'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seq'],
      )!,
      comDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}com_date'],
      ),
      paymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_date'],
      ),
      factor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}factor'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      rawLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_label'],
      ),
      isin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isin'],
      ),
      collectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collected_at'],
      )!,
    );
  }

  @override
  $MktCorporateEventsTable createAlias(String alias) {
    return $MktCorporateEventsTable(attachedDatabase, alias);
  }
}

class MktCorporateEventRow extends DataClass
    implements Insertable<MktCorporateEventRow> {
  final String symbol;
  final String market;

  /// `split`, `reverse_split`, `bonus_shares`, `cash_dividend`, `jcp`,
  /// `fii_income`, `amortization`, `other_cash`.
  final String eventKind;
  final String exDate;
  final String source;

  /// Desempate de eventos iguais na mesma data (por exemplo, dois JCP).
  final String seq;
  final String? comDate;
  final String? paymentDate;

  /// Multiplicador da quantidade (2 = desdobramento 1:2).
  final String? factor;

  /// Valor por ação ou cota.
  final String? amount;
  final String? currency;

  /// `paid`, `announced` ou `suspect`.
  final String status;
  final String? rawLabel;
  final String? isin;
  final String collectedAt;
  const MktCorporateEventRow({
    required this.symbol,
    required this.market,
    required this.eventKind,
    required this.exDate,
    required this.source,
    required this.seq,
    this.comDate,
    this.paymentDate,
    this.factor,
    this.amount,
    this.currency,
    required this.status,
    this.rawLabel,
    this.isin,
    required this.collectedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['symbol'] = Variable<String>(symbol);
    map['market'] = Variable<String>(market);
    map['event_kind'] = Variable<String>(eventKind);
    map['ex_date'] = Variable<String>(exDate);
    map['source'] = Variable<String>(source);
    map['seq'] = Variable<String>(seq);
    if (!nullToAbsent || comDate != null) {
      map['com_date'] = Variable<String>(comDate);
    }
    if (!nullToAbsent || paymentDate != null) {
      map['payment_date'] = Variable<String>(paymentDate);
    }
    if (!nullToAbsent || factor != null) {
      map['factor'] = Variable<String>(factor);
    }
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<String>(amount);
    }
    if (!nullToAbsent || currency != null) {
      map['currency'] = Variable<String>(currency);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || rawLabel != null) {
      map['raw_label'] = Variable<String>(rawLabel);
    }
    if (!nullToAbsent || isin != null) {
      map['isin'] = Variable<String>(isin);
    }
    map['collected_at'] = Variable<String>(collectedAt);
    return map;
  }

  MktCorporateEventsCompanion toCompanion(bool nullToAbsent) {
    return MktCorporateEventsCompanion(
      symbol: Value(symbol),
      market: Value(market),
      eventKind: Value(eventKind),
      exDate: Value(exDate),
      source: Value(source),
      seq: Value(seq),
      comDate: comDate == null && nullToAbsent
          ? const Value.absent()
          : Value(comDate),
      paymentDate: paymentDate == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentDate),
      factor: factor == null && nullToAbsent
          ? const Value.absent()
          : Value(factor),
      amount: amount == null && nullToAbsent
          ? const Value.absent()
          : Value(amount),
      currency: currency == null && nullToAbsent
          ? const Value.absent()
          : Value(currency),
      status: Value(status),
      rawLabel: rawLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(rawLabel),
      isin: isin == null && nullToAbsent ? const Value.absent() : Value(isin),
      collectedAt: Value(collectedAt),
    );
  }

  factory MktCorporateEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MktCorporateEventRow(
      symbol: serializer.fromJson<String>(json['symbol']),
      market: serializer.fromJson<String>(json['market']),
      eventKind: serializer.fromJson<String>(json['eventKind']),
      exDate: serializer.fromJson<String>(json['exDate']),
      source: serializer.fromJson<String>(json['source']),
      seq: serializer.fromJson<String>(json['seq']),
      comDate: serializer.fromJson<String?>(json['comDate']),
      paymentDate: serializer.fromJson<String?>(json['paymentDate']),
      factor: serializer.fromJson<String?>(json['factor']),
      amount: serializer.fromJson<String?>(json['amount']),
      currency: serializer.fromJson<String?>(json['currency']),
      status: serializer.fromJson<String>(json['status']),
      rawLabel: serializer.fromJson<String?>(json['rawLabel']),
      isin: serializer.fromJson<String?>(json['isin']),
      collectedAt: serializer.fromJson<String>(json['collectedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'symbol': serializer.toJson<String>(symbol),
      'market': serializer.toJson<String>(market),
      'eventKind': serializer.toJson<String>(eventKind),
      'exDate': serializer.toJson<String>(exDate),
      'source': serializer.toJson<String>(source),
      'seq': serializer.toJson<String>(seq),
      'comDate': serializer.toJson<String?>(comDate),
      'paymentDate': serializer.toJson<String?>(paymentDate),
      'factor': serializer.toJson<String?>(factor),
      'amount': serializer.toJson<String?>(amount),
      'currency': serializer.toJson<String?>(currency),
      'status': serializer.toJson<String>(status),
      'rawLabel': serializer.toJson<String?>(rawLabel),
      'isin': serializer.toJson<String?>(isin),
      'collectedAt': serializer.toJson<String>(collectedAt),
    };
  }

  MktCorporateEventRow copyWith({
    String? symbol,
    String? market,
    String? eventKind,
    String? exDate,
    String? source,
    String? seq,
    Value<String?> comDate = const Value.absent(),
    Value<String?> paymentDate = const Value.absent(),
    Value<String?> factor = const Value.absent(),
    Value<String?> amount = const Value.absent(),
    Value<String?> currency = const Value.absent(),
    String? status,
    Value<String?> rawLabel = const Value.absent(),
    Value<String?> isin = const Value.absent(),
    String? collectedAt,
  }) => MktCorporateEventRow(
    symbol: symbol ?? this.symbol,
    market: market ?? this.market,
    eventKind: eventKind ?? this.eventKind,
    exDate: exDate ?? this.exDate,
    source: source ?? this.source,
    seq: seq ?? this.seq,
    comDate: comDate.present ? comDate.value : this.comDate,
    paymentDate: paymentDate.present ? paymentDate.value : this.paymentDate,
    factor: factor.present ? factor.value : this.factor,
    amount: amount.present ? amount.value : this.amount,
    currency: currency.present ? currency.value : this.currency,
    status: status ?? this.status,
    rawLabel: rawLabel.present ? rawLabel.value : this.rawLabel,
    isin: isin.present ? isin.value : this.isin,
    collectedAt: collectedAt ?? this.collectedAt,
  );
  MktCorporateEventRow copyWithCompanion(MktCorporateEventsCompanion data) {
    return MktCorporateEventRow(
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      market: data.market.present ? data.market.value : this.market,
      eventKind: data.eventKind.present ? data.eventKind.value : this.eventKind,
      exDate: data.exDate.present ? data.exDate.value : this.exDate,
      source: data.source.present ? data.source.value : this.source,
      seq: data.seq.present ? data.seq.value : this.seq,
      comDate: data.comDate.present ? data.comDate.value : this.comDate,
      paymentDate: data.paymentDate.present
          ? data.paymentDate.value
          : this.paymentDate,
      factor: data.factor.present ? data.factor.value : this.factor,
      amount: data.amount.present ? data.amount.value : this.amount,
      currency: data.currency.present ? data.currency.value : this.currency,
      status: data.status.present ? data.status.value : this.status,
      rawLabel: data.rawLabel.present ? data.rawLabel.value : this.rawLabel,
      isin: data.isin.present ? data.isin.value : this.isin,
      collectedAt: data.collectedAt.present
          ? data.collectedAt.value
          : this.collectedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MktCorporateEventRow(')
          ..write('symbol: $symbol, ')
          ..write('market: $market, ')
          ..write('eventKind: $eventKind, ')
          ..write('exDate: $exDate, ')
          ..write('source: $source, ')
          ..write('seq: $seq, ')
          ..write('comDate: $comDate, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('factor: $factor, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('status: $status, ')
          ..write('rawLabel: $rawLabel, ')
          ..write('isin: $isin, ')
          ..write('collectedAt: $collectedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    symbol,
    market,
    eventKind,
    exDate,
    source,
    seq,
    comDate,
    paymentDate,
    factor,
    amount,
    currency,
    status,
    rawLabel,
    isin,
    collectedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MktCorporateEventRow &&
          other.symbol == this.symbol &&
          other.market == this.market &&
          other.eventKind == this.eventKind &&
          other.exDate == this.exDate &&
          other.source == this.source &&
          other.seq == this.seq &&
          other.comDate == this.comDate &&
          other.paymentDate == this.paymentDate &&
          other.factor == this.factor &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.status == this.status &&
          other.rawLabel == this.rawLabel &&
          other.isin == this.isin &&
          other.collectedAt == this.collectedAt);
}

class MktCorporateEventsCompanion
    extends UpdateCompanion<MktCorporateEventRow> {
  final Value<String> symbol;
  final Value<String> market;
  final Value<String> eventKind;
  final Value<String> exDate;
  final Value<String> source;
  final Value<String> seq;
  final Value<String?> comDate;
  final Value<String?> paymentDate;
  final Value<String?> factor;
  final Value<String?> amount;
  final Value<String?> currency;
  final Value<String> status;
  final Value<String?> rawLabel;
  final Value<String?> isin;
  final Value<String> collectedAt;
  final Value<int> rowid;
  const MktCorporateEventsCompanion({
    this.symbol = const Value.absent(),
    this.market = const Value.absent(),
    this.eventKind = const Value.absent(),
    this.exDate = const Value.absent(),
    this.source = const Value.absent(),
    this.seq = const Value.absent(),
    this.comDate = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.factor = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.status = const Value.absent(),
    this.rawLabel = const Value.absent(),
    this.isin = const Value.absent(),
    this.collectedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MktCorporateEventsCompanion.insert({
    required String symbol,
    required String market,
    required String eventKind,
    required String exDate,
    required String source,
    required String seq,
    this.comDate = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.factor = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    required String status,
    this.rawLabel = const Value.absent(),
    this.isin = const Value.absent(),
    required String collectedAt,
    this.rowid = const Value.absent(),
  }) : symbol = Value(symbol),
       market = Value(market),
       eventKind = Value(eventKind),
       exDate = Value(exDate),
       source = Value(source),
       seq = Value(seq),
       status = Value(status),
       collectedAt = Value(collectedAt);
  static Insertable<MktCorporateEventRow> custom({
    Expression<String>? symbol,
    Expression<String>? market,
    Expression<String>? eventKind,
    Expression<String>? exDate,
    Expression<String>? source,
    Expression<String>? seq,
    Expression<String>? comDate,
    Expression<String>? paymentDate,
    Expression<String>? factor,
    Expression<String>? amount,
    Expression<String>? currency,
    Expression<String>? status,
    Expression<String>? rawLabel,
    Expression<String>? isin,
    Expression<String>? collectedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (symbol != null) 'symbol': symbol,
      if (market != null) 'market': market,
      if (eventKind != null) 'event_kind': eventKind,
      if (exDate != null) 'ex_date': exDate,
      if (source != null) 'source': source,
      if (seq != null) 'seq': seq,
      if (comDate != null) 'com_date': comDate,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (factor != null) 'factor': factor,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (status != null) 'status': status,
      if (rawLabel != null) 'raw_label': rawLabel,
      if (isin != null) 'isin': isin,
      if (collectedAt != null) 'collected_at': collectedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MktCorporateEventsCompanion copyWith({
    Value<String>? symbol,
    Value<String>? market,
    Value<String>? eventKind,
    Value<String>? exDate,
    Value<String>? source,
    Value<String>? seq,
    Value<String?>? comDate,
    Value<String?>? paymentDate,
    Value<String?>? factor,
    Value<String?>? amount,
    Value<String?>? currency,
    Value<String>? status,
    Value<String?>? rawLabel,
    Value<String?>? isin,
    Value<String>? collectedAt,
    Value<int>? rowid,
  }) {
    return MktCorporateEventsCompanion(
      symbol: symbol ?? this.symbol,
      market: market ?? this.market,
      eventKind: eventKind ?? this.eventKind,
      exDate: exDate ?? this.exDate,
      source: source ?? this.source,
      seq: seq ?? this.seq,
      comDate: comDate ?? this.comDate,
      paymentDate: paymentDate ?? this.paymentDate,
      factor: factor ?? this.factor,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      rawLabel: rawLabel ?? this.rawLabel,
      isin: isin ?? this.isin,
      collectedAt: collectedAt ?? this.collectedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (market.present) {
      map['market'] = Variable<String>(market.value);
    }
    if (eventKind.present) {
      map['event_kind'] = Variable<String>(eventKind.value);
    }
    if (exDate.present) {
      map['ex_date'] = Variable<String>(exDate.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (seq.present) {
      map['seq'] = Variable<String>(seq.value);
    }
    if (comDate.present) {
      map['com_date'] = Variable<String>(comDate.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<String>(paymentDate.value);
    }
    if (factor.present) {
      map['factor'] = Variable<String>(factor.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rawLabel.present) {
      map['raw_label'] = Variable<String>(rawLabel.value);
    }
    if (isin.present) {
      map['isin'] = Variable<String>(isin.value);
    }
    if (collectedAt.present) {
      map['collected_at'] = Variable<String>(collectedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MktCorporateEventsCompanion(')
          ..write('symbol: $symbol, ')
          ..write('market: $market, ')
          ..write('eventKind: $eventKind, ')
          ..write('exDate: $exDate, ')
          ..write('source: $source, ')
          ..write('seq: $seq, ')
          ..write('comDate: $comDate, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('factor: $factor, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('status: $status, ')
          ..write('rawLabel: $rawLabel, ')
          ..write('isin: $isin, ')
          ..write('collectedAt: $collectedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MktIndicatorsTable extends MktIndicators
    with TableInfo<$MktIndicatorsTable, MktIndicatorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MktIndicatorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seriesCodeMeta = const VerificationMeta(
    'seriesCode',
  );
  @override
  late final GeneratedColumn<String> seriesCode = GeneratedColumn<String>(
    'series_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refDateMeta = const VerificationMeta(
    'refDate',
  );
  @override
  late final GeneratedColumn<String> refDate = GeneratedColumn<String>(
    'ref_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectedAtMeta = const VerificationMeta(
    'collectedAt',
  );
  @override
  late final GeneratedColumn<String> collectedAt = GeneratedColumn<String>(
    'collected_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    seriesCode,
    refDate,
    source,
    value,
    unit,
    collectedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mkt_indicators';
  @override
  VerificationContext validateIntegrity(
    Insertable<MktIndicatorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('series_code')) {
      context.handle(
        _seriesCodeMeta,
        seriesCode.isAcceptableOrUnknown(data['series_code']!, _seriesCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_seriesCodeMeta);
    }
    if (data.containsKey('ref_date')) {
      context.handle(
        _refDateMeta,
        refDate.isAcceptableOrUnknown(data['ref_date']!, _refDateMeta),
      );
    } else if (isInserting) {
      context.missing(_refDateMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('collected_at')) {
      context.handle(
        _collectedAtMeta,
        collectedAt.isAcceptableOrUnknown(
          data['collected_at']!,
          _collectedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seriesCode, refDate, source};
  @override
  MktIndicatorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MktIndicatorRow(
      seriesCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_code'],
      )!,
      refDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_date'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      collectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collected_at'],
      )!,
    );
  }

  @override
  $MktIndicatorsTable createAlias(String alias) {
    return $MktIndicatorsTable(attachedDatabase, alias);
  }
}

class MktIndicatorRow extends DataClass implements Insertable<MktIndicatorRow> {
  final String seriesCode;
  final String refDate;
  final String source;
  final String value;

  /// `pct_day`, `pct_month`, `pct_year` ou `index`.
  final String unit;
  final String collectedAt;
  const MktIndicatorRow({
    required this.seriesCode,
    required this.refDate,
    required this.source,
    required this.value,
    required this.unit,
    required this.collectedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['series_code'] = Variable<String>(seriesCode);
    map['ref_date'] = Variable<String>(refDate);
    map['source'] = Variable<String>(source);
    map['value'] = Variable<String>(value);
    map['unit'] = Variable<String>(unit);
    map['collected_at'] = Variable<String>(collectedAt);
    return map;
  }

  MktIndicatorsCompanion toCompanion(bool nullToAbsent) {
    return MktIndicatorsCompanion(
      seriesCode: Value(seriesCode),
      refDate: Value(refDate),
      source: Value(source),
      value: Value(value),
      unit: Value(unit),
      collectedAt: Value(collectedAt),
    );
  }

  factory MktIndicatorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MktIndicatorRow(
      seriesCode: serializer.fromJson<String>(json['seriesCode']),
      refDate: serializer.fromJson<String>(json['refDate']),
      source: serializer.fromJson<String>(json['source']),
      value: serializer.fromJson<String>(json['value']),
      unit: serializer.fromJson<String>(json['unit']),
      collectedAt: serializer.fromJson<String>(json['collectedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seriesCode': serializer.toJson<String>(seriesCode),
      'refDate': serializer.toJson<String>(refDate),
      'source': serializer.toJson<String>(source),
      'value': serializer.toJson<String>(value),
      'unit': serializer.toJson<String>(unit),
      'collectedAt': serializer.toJson<String>(collectedAt),
    };
  }

  MktIndicatorRow copyWith({
    String? seriesCode,
    String? refDate,
    String? source,
    String? value,
    String? unit,
    String? collectedAt,
  }) => MktIndicatorRow(
    seriesCode: seriesCode ?? this.seriesCode,
    refDate: refDate ?? this.refDate,
    source: source ?? this.source,
    value: value ?? this.value,
    unit: unit ?? this.unit,
    collectedAt: collectedAt ?? this.collectedAt,
  );
  MktIndicatorRow copyWithCompanion(MktIndicatorsCompanion data) {
    return MktIndicatorRow(
      seriesCode: data.seriesCode.present
          ? data.seriesCode.value
          : this.seriesCode,
      refDate: data.refDate.present ? data.refDate.value : this.refDate,
      source: data.source.present ? data.source.value : this.source,
      value: data.value.present ? data.value.value : this.value,
      unit: data.unit.present ? data.unit.value : this.unit,
      collectedAt: data.collectedAt.present
          ? data.collectedAt.value
          : this.collectedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MktIndicatorRow(')
          ..write('seriesCode: $seriesCode, ')
          ..write('refDate: $refDate, ')
          ..write('source: $source, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('collectedAt: $collectedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(seriesCode, refDate, source, value, unit, collectedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MktIndicatorRow &&
          other.seriesCode == this.seriesCode &&
          other.refDate == this.refDate &&
          other.source == this.source &&
          other.value == this.value &&
          other.unit == this.unit &&
          other.collectedAt == this.collectedAt);
}

class MktIndicatorsCompanion extends UpdateCompanion<MktIndicatorRow> {
  final Value<String> seriesCode;
  final Value<String> refDate;
  final Value<String> source;
  final Value<String> value;
  final Value<String> unit;
  final Value<String> collectedAt;
  final Value<int> rowid;
  const MktIndicatorsCompanion({
    this.seriesCode = const Value.absent(),
    this.refDate = const Value.absent(),
    this.source = const Value.absent(),
    this.value = const Value.absent(),
    this.unit = const Value.absent(),
    this.collectedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MktIndicatorsCompanion.insert({
    required String seriesCode,
    required String refDate,
    required String source,
    required String value,
    required String unit,
    required String collectedAt,
    this.rowid = const Value.absent(),
  }) : seriesCode = Value(seriesCode),
       refDate = Value(refDate),
       source = Value(source),
       value = Value(value),
       unit = Value(unit),
       collectedAt = Value(collectedAt);
  static Insertable<MktIndicatorRow> custom({
    Expression<String>? seriesCode,
    Expression<String>? refDate,
    Expression<String>? source,
    Expression<String>? value,
    Expression<String>? unit,
    Expression<String>? collectedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (seriesCode != null) 'series_code': seriesCode,
      if (refDate != null) 'ref_date': refDate,
      if (source != null) 'source': source,
      if (value != null) 'value': value,
      if (unit != null) 'unit': unit,
      if (collectedAt != null) 'collected_at': collectedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MktIndicatorsCompanion copyWith({
    Value<String>? seriesCode,
    Value<String>? refDate,
    Value<String>? source,
    Value<String>? value,
    Value<String>? unit,
    Value<String>? collectedAt,
    Value<int>? rowid,
  }) {
    return MktIndicatorsCompanion(
      seriesCode: seriesCode ?? this.seriesCode,
      refDate: refDate ?? this.refDate,
      source: source ?? this.source,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      collectedAt: collectedAt ?? this.collectedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seriesCode.present) {
      map['series_code'] = Variable<String>(seriesCode.value);
    }
    if (refDate.present) {
      map['ref_date'] = Variable<String>(refDate.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (collectedAt.present) {
      map['collected_at'] = Variable<String>(collectedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MktIndicatorsCompanion(')
          ..write('seriesCode: $seriesCode, ')
          ..write('refDate: $refDate, ')
          ..write('source: $source, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('collectedAt: $collectedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MktFxRatesTable extends MktFxRates
    with TableInfo<$MktFxRatesTable, MktFxRateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MktFxRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _baseMeta = const VerificationMeta('base');
  @override
  late final GeneratedColumn<String> base = GeneratedColumn<String>(
    'base',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quoteMeta = const VerificationMeta('quote');
  @override
  late final GeneratedColumn<String> quote = GeneratedColumn<String>(
    'quote',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refDateMeta = const VerificationMeta(
    'refDate',
  );
  @override
  late final GeneratedColumn<String> refDate = GeneratedColumn<String>(
    'ref_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bidMeta = const VerificationMeta('bid');
  @override
  late final GeneratedColumn<String> bid = GeneratedColumn<String>(
    'bid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _askMeta = const VerificationMeta('ask');
  @override
  late final GeneratedColumn<String> ask = GeneratedColumn<String>(
    'ask',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refAtMeta = const VerificationMeta('refAt');
  @override
  late final GeneratedColumn<String> refAt = GeneratedColumn<String>(
    'ref_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectedAtMeta = const VerificationMeta(
    'collectedAt',
  );
  @override
  late final GeneratedColumn<String> collectedAt = GeneratedColumn<String>(
    'collected_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    base,
    quote,
    refDate,
    kind,
    source,
    bid,
    ask,
    refAt,
    collectedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mkt_fx_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<MktFxRateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('base')) {
      context.handle(
        _baseMeta,
        base.isAcceptableOrUnknown(data['base']!, _baseMeta),
      );
    } else if (isInserting) {
      context.missing(_baseMeta);
    }
    if (data.containsKey('quote')) {
      context.handle(
        _quoteMeta,
        quote.isAcceptableOrUnknown(data['quote']!, _quoteMeta),
      );
    } else if (isInserting) {
      context.missing(_quoteMeta);
    }
    if (data.containsKey('ref_date')) {
      context.handle(
        _refDateMeta,
        refDate.isAcceptableOrUnknown(data['ref_date']!, _refDateMeta),
      );
    } else if (isInserting) {
      context.missing(_refDateMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('bid')) {
      context.handle(
        _bidMeta,
        bid.isAcceptableOrUnknown(data['bid']!, _bidMeta),
      );
    }
    if (data.containsKey('ask')) {
      context.handle(
        _askMeta,
        ask.isAcceptableOrUnknown(data['ask']!, _askMeta),
      );
    }
    if (data.containsKey('ref_at')) {
      context.handle(
        _refAtMeta,
        refAt.isAcceptableOrUnknown(data['ref_at']!, _refAtMeta),
      );
    }
    if (data.containsKey('collected_at')) {
      context.handle(
        _collectedAtMeta,
        collectedAt.isAcceptableOrUnknown(
          data['collected_at']!,
          _collectedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {base, quote, refDate, kind, source};
  @override
  MktFxRateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MktFxRateRow(
      base: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base'],
      )!,
      quote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quote'],
      )!,
      refDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_date'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      bid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bid'],
      ),
      ask: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ask'],
      ),
      refAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_at'],
      ),
      collectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collected_at'],
      )!,
    );
  }

  @override
  $MktFxRatesTable createAlias(String alias) {
    return $MktFxRatesTable(attachedDatabase, alias);
  }
}

class MktFxRateRow extends DataClass implements Insertable<MktFxRateRow> {
  final String base;
  final String quote;
  final String refDate;

  /// `ptax_close` ou `reference`.
  final String kind;
  final String source;
  final String? bid;
  final String? ask;
  final String? refAt;
  final String collectedAt;
  const MktFxRateRow({
    required this.base,
    required this.quote,
    required this.refDate,
    required this.kind,
    required this.source,
    this.bid,
    this.ask,
    this.refAt,
    required this.collectedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['base'] = Variable<String>(base);
    map['quote'] = Variable<String>(quote);
    map['ref_date'] = Variable<String>(refDate);
    map['kind'] = Variable<String>(kind);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || bid != null) {
      map['bid'] = Variable<String>(bid);
    }
    if (!nullToAbsent || ask != null) {
      map['ask'] = Variable<String>(ask);
    }
    if (!nullToAbsent || refAt != null) {
      map['ref_at'] = Variable<String>(refAt);
    }
    map['collected_at'] = Variable<String>(collectedAt);
    return map;
  }

  MktFxRatesCompanion toCompanion(bool nullToAbsent) {
    return MktFxRatesCompanion(
      base: Value(base),
      quote: Value(quote),
      refDate: Value(refDate),
      kind: Value(kind),
      source: Value(source),
      bid: bid == null && nullToAbsent ? const Value.absent() : Value(bid),
      ask: ask == null && nullToAbsent ? const Value.absent() : Value(ask),
      refAt: refAt == null && nullToAbsent
          ? const Value.absent()
          : Value(refAt),
      collectedAt: Value(collectedAt),
    );
  }

  factory MktFxRateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MktFxRateRow(
      base: serializer.fromJson<String>(json['base']),
      quote: serializer.fromJson<String>(json['quote']),
      refDate: serializer.fromJson<String>(json['refDate']),
      kind: serializer.fromJson<String>(json['kind']),
      source: serializer.fromJson<String>(json['source']),
      bid: serializer.fromJson<String?>(json['bid']),
      ask: serializer.fromJson<String?>(json['ask']),
      refAt: serializer.fromJson<String?>(json['refAt']),
      collectedAt: serializer.fromJson<String>(json['collectedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'base': serializer.toJson<String>(base),
      'quote': serializer.toJson<String>(quote),
      'refDate': serializer.toJson<String>(refDate),
      'kind': serializer.toJson<String>(kind),
      'source': serializer.toJson<String>(source),
      'bid': serializer.toJson<String?>(bid),
      'ask': serializer.toJson<String?>(ask),
      'refAt': serializer.toJson<String?>(refAt),
      'collectedAt': serializer.toJson<String>(collectedAt),
    };
  }

  MktFxRateRow copyWith({
    String? base,
    String? quote,
    String? refDate,
    String? kind,
    String? source,
    Value<String?> bid = const Value.absent(),
    Value<String?> ask = const Value.absent(),
    Value<String?> refAt = const Value.absent(),
    String? collectedAt,
  }) => MktFxRateRow(
    base: base ?? this.base,
    quote: quote ?? this.quote,
    refDate: refDate ?? this.refDate,
    kind: kind ?? this.kind,
    source: source ?? this.source,
    bid: bid.present ? bid.value : this.bid,
    ask: ask.present ? ask.value : this.ask,
    refAt: refAt.present ? refAt.value : this.refAt,
    collectedAt: collectedAt ?? this.collectedAt,
  );
  MktFxRateRow copyWithCompanion(MktFxRatesCompanion data) {
    return MktFxRateRow(
      base: data.base.present ? data.base.value : this.base,
      quote: data.quote.present ? data.quote.value : this.quote,
      refDate: data.refDate.present ? data.refDate.value : this.refDate,
      kind: data.kind.present ? data.kind.value : this.kind,
      source: data.source.present ? data.source.value : this.source,
      bid: data.bid.present ? data.bid.value : this.bid,
      ask: data.ask.present ? data.ask.value : this.ask,
      refAt: data.refAt.present ? data.refAt.value : this.refAt,
      collectedAt: data.collectedAt.present
          ? data.collectedAt.value
          : this.collectedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MktFxRateRow(')
          ..write('base: $base, ')
          ..write('quote: $quote, ')
          ..write('refDate: $refDate, ')
          ..write('kind: $kind, ')
          ..write('source: $source, ')
          ..write('bid: $bid, ')
          ..write('ask: $ask, ')
          ..write('refAt: $refAt, ')
          ..write('collectedAt: $collectedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    base,
    quote,
    refDate,
    kind,
    source,
    bid,
    ask,
    refAt,
    collectedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MktFxRateRow &&
          other.base == this.base &&
          other.quote == this.quote &&
          other.refDate == this.refDate &&
          other.kind == this.kind &&
          other.source == this.source &&
          other.bid == this.bid &&
          other.ask == this.ask &&
          other.refAt == this.refAt &&
          other.collectedAt == this.collectedAt);
}

class MktFxRatesCompanion extends UpdateCompanion<MktFxRateRow> {
  final Value<String> base;
  final Value<String> quote;
  final Value<String> refDate;
  final Value<String> kind;
  final Value<String> source;
  final Value<String?> bid;
  final Value<String?> ask;
  final Value<String?> refAt;
  final Value<String> collectedAt;
  final Value<int> rowid;
  const MktFxRatesCompanion({
    this.base = const Value.absent(),
    this.quote = const Value.absent(),
    this.refDate = const Value.absent(),
    this.kind = const Value.absent(),
    this.source = const Value.absent(),
    this.bid = const Value.absent(),
    this.ask = const Value.absent(),
    this.refAt = const Value.absent(),
    this.collectedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MktFxRatesCompanion.insert({
    required String base,
    required String quote,
    required String refDate,
    required String kind,
    required String source,
    this.bid = const Value.absent(),
    this.ask = const Value.absent(),
    this.refAt = const Value.absent(),
    required String collectedAt,
    this.rowid = const Value.absent(),
  }) : base = Value(base),
       quote = Value(quote),
       refDate = Value(refDate),
       kind = Value(kind),
       source = Value(source),
       collectedAt = Value(collectedAt);
  static Insertable<MktFxRateRow> custom({
    Expression<String>? base,
    Expression<String>? quote,
    Expression<String>? refDate,
    Expression<String>? kind,
    Expression<String>? source,
    Expression<String>? bid,
    Expression<String>? ask,
    Expression<String>? refAt,
    Expression<String>? collectedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (base != null) 'base': base,
      if (quote != null) 'quote': quote,
      if (refDate != null) 'ref_date': refDate,
      if (kind != null) 'kind': kind,
      if (source != null) 'source': source,
      if (bid != null) 'bid': bid,
      if (ask != null) 'ask': ask,
      if (refAt != null) 'ref_at': refAt,
      if (collectedAt != null) 'collected_at': collectedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MktFxRatesCompanion copyWith({
    Value<String>? base,
    Value<String>? quote,
    Value<String>? refDate,
    Value<String>? kind,
    Value<String>? source,
    Value<String?>? bid,
    Value<String?>? ask,
    Value<String?>? refAt,
    Value<String>? collectedAt,
    Value<int>? rowid,
  }) {
    return MktFxRatesCompanion(
      base: base ?? this.base,
      quote: quote ?? this.quote,
      refDate: refDate ?? this.refDate,
      kind: kind ?? this.kind,
      source: source ?? this.source,
      bid: bid ?? this.bid,
      ask: ask ?? this.ask,
      refAt: refAt ?? this.refAt,
      collectedAt: collectedAt ?? this.collectedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (base.present) {
      map['base'] = Variable<String>(base.value);
    }
    if (quote.present) {
      map['quote'] = Variable<String>(quote.value);
    }
    if (refDate.present) {
      map['ref_date'] = Variable<String>(refDate.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (bid.present) {
      map['bid'] = Variable<String>(bid.value);
    }
    if (ask.present) {
      map['ask'] = Variable<String>(ask.value);
    }
    if (refAt.present) {
      map['ref_at'] = Variable<String>(refAt.value);
    }
    if (collectedAt.present) {
      map['collected_at'] = Variable<String>(collectedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MktFxRatesCompanion(')
          ..write('base: $base, ')
          ..write('quote: $quote, ')
          ..write('refDate: $refDate, ')
          ..write('kind: $kind, ')
          ..write('source: $source, ')
          ..write('bid: $bid, ')
          ..write('ask: $ask, ')
          ..write('refAt: $refAt, ')
          ..write('collectedAt: $collectedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MktTreasuryPricesTable extends MktTreasuryPrices
    with TableInfo<$MktTreasuryPricesTable, MktTreasuryPriceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MktTreasuryPricesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maturityDateMeta = const VerificationMeta(
    'maturityDate',
  );
  @override
  late final GeneratedColumn<String> maturityDate = GeneratedColumn<String>(
    'maturity_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refDateMeta = const VerificationMeta(
    'refDate',
  );
  @override
  late final GeneratedColumn<String> refDate = GeneratedColumn<String>(
    'ref_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _buyRateMeta = const VerificationMeta(
    'buyRate',
  );
  @override
  late final GeneratedColumn<String> buyRate = GeneratedColumn<String>(
    'buy_rate',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sellRateMeta = const VerificationMeta(
    'sellRate',
  );
  @override
  late final GeneratedColumn<String> sellRate = GeneratedColumn<String>(
    'sell_rate',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _buyPuMeta = const VerificationMeta('buyPu');
  @override
  late final GeneratedColumn<String> buyPu = GeneratedColumn<String>(
    'buy_pu',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sellPuMeta = const VerificationMeta('sellPu');
  @override
  late final GeneratedColumn<String> sellPu = GeneratedColumn<String>(
    'sell_pu',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _basePuMeta = const VerificationMeta('basePu');
  @override
  late final GeneratedColumn<String> basePu = GeneratedColumn<String>(
    'base_pu',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectedAtMeta = const VerificationMeta(
    'collectedAt',
  );
  @override
  late final GeneratedColumn<String> collectedAt = GeneratedColumn<String>(
    'collected_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    title,
    maturityDate,
    refDate,
    source,
    buyRate,
    sellRate,
    buyPu,
    sellPu,
    basePu,
    collectedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mkt_treasury_prices';
  @override
  VerificationContext validateIntegrity(
    Insertable<MktTreasuryPriceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('maturity_date')) {
      context.handle(
        _maturityDateMeta,
        maturityDate.isAcceptableOrUnknown(
          data['maturity_date']!,
          _maturityDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_maturityDateMeta);
    }
    if (data.containsKey('ref_date')) {
      context.handle(
        _refDateMeta,
        refDate.isAcceptableOrUnknown(data['ref_date']!, _refDateMeta),
      );
    } else if (isInserting) {
      context.missing(_refDateMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('buy_rate')) {
      context.handle(
        _buyRateMeta,
        buyRate.isAcceptableOrUnknown(data['buy_rate']!, _buyRateMeta),
      );
    }
    if (data.containsKey('sell_rate')) {
      context.handle(
        _sellRateMeta,
        sellRate.isAcceptableOrUnknown(data['sell_rate']!, _sellRateMeta),
      );
    }
    if (data.containsKey('buy_pu')) {
      context.handle(
        _buyPuMeta,
        buyPu.isAcceptableOrUnknown(data['buy_pu']!, _buyPuMeta),
      );
    }
    if (data.containsKey('sell_pu')) {
      context.handle(
        _sellPuMeta,
        sellPu.isAcceptableOrUnknown(data['sell_pu']!, _sellPuMeta),
      );
    }
    if (data.containsKey('base_pu')) {
      context.handle(
        _basePuMeta,
        basePu.isAcceptableOrUnknown(data['base_pu']!, _basePuMeta),
      );
    }
    if (data.containsKey('collected_at')) {
      context.handle(
        _collectedAtMeta,
        collectedAt.isAcceptableOrUnknown(
          data['collected_at']!,
          _collectedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    title,
    maturityDate,
    refDate,
    source,
  };
  @override
  MktTreasuryPriceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MktTreasuryPriceRow(
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      maturityDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}maturity_date'],
      )!,
      refDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_date'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      buyRate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}buy_rate'],
      ),
      sellRate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sell_rate'],
      ),
      buyPu: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}buy_pu'],
      ),
      sellPu: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sell_pu'],
      ),
      basePu: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_pu'],
      ),
      collectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collected_at'],
      )!,
    );
  }

  @override
  $MktTreasuryPricesTable createAlias(String alias) {
    return $MktTreasuryPricesTable(attachedDatabase, alias);
  }
}

class MktTreasuryPriceRow extends DataClass
    implements Insertable<MktTreasuryPriceRow> {
  final String title;
  final String maturityDate;
  final String refDate;
  final String source;
  final String? buyRate;
  final String? sellRate;
  final String? buyPu;
  final String? sellPu;
  final String? basePu;
  final String collectedAt;
  const MktTreasuryPriceRow({
    required this.title,
    required this.maturityDate,
    required this.refDate,
    required this.source,
    this.buyRate,
    this.sellRate,
    this.buyPu,
    this.sellPu,
    this.basePu,
    required this.collectedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['title'] = Variable<String>(title);
    map['maturity_date'] = Variable<String>(maturityDate);
    map['ref_date'] = Variable<String>(refDate);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || buyRate != null) {
      map['buy_rate'] = Variable<String>(buyRate);
    }
    if (!nullToAbsent || sellRate != null) {
      map['sell_rate'] = Variable<String>(sellRate);
    }
    if (!nullToAbsent || buyPu != null) {
      map['buy_pu'] = Variable<String>(buyPu);
    }
    if (!nullToAbsent || sellPu != null) {
      map['sell_pu'] = Variable<String>(sellPu);
    }
    if (!nullToAbsent || basePu != null) {
      map['base_pu'] = Variable<String>(basePu);
    }
    map['collected_at'] = Variable<String>(collectedAt);
    return map;
  }

  MktTreasuryPricesCompanion toCompanion(bool nullToAbsent) {
    return MktTreasuryPricesCompanion(
      title: Value(title),
      maturityDate: Value(maturityDate),
      refDate: Value(refDate),
      source: Value(source),
      buyRate: buyRate == null && nullToAbsent
          ? const Value.absent()
          : Value(buyRate),
      sellRate: sellRate == null && nullToAbsent
          ? const Value.absent()
          : Value(sellRate),
      buyPu: buyPu == null && nullToAbsent
          ? const Value.absent()
          : Value(buyPu),
      sellPu: sellPu == null && nullToAbsent
          ? const Value.absent()
          : Value(sellPu),
      basePu: basePu == null && nullToAbsent
          ? const Value.absent()
          : Value(basePu),
      collectedAt: Value(collectedAt),
    );
  }

  factory MktTreasuryPriceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MktTreasuryPriceRow(
      title: serializer.fromJson<String>(json['title']),
      maturityDate: serializer.fromJson<String>(json['maturityDate']),
      refDate: serializer.fromJson<String>(json['refDate']),
      source: serializer.fromJson<String>(json['source']),
      buyRate: serializer.fromJson<String?>(json['buyRate']),
      sellRate: serializer.fromJson<String?>(json['sellRate']),
      buyPu: serializer.fromJson<String?>(json['buyPu']),
      sellPu: serializer.fromJson<String?>(json['sellPu']),
      basePu: serializer.fromJson<String?>(json['basePu']),
      collectedAt: serializer.fromJson<String>(json['collectedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'title': serializer.toJson<String>(title),
      'maturityDate': serializer.toJson<String>(maturityDate),
      'refDate': serializer.toJson<String>(refDate),
      'source': serializer.toJson<String>(source),
      'buyRate': serializer.toJson<String?>(buyRate),
      'sellRate': serializer.toJson<String?>(sellRate),
      'buyPu': serializer.toJson<String?>(buyPu),
      'sellPu': serializer.toJson<String?>(sellPu),
      'basePu': serializer.toJson<String?>(basePu),
      'collectedAt': serializer.toJson<String>(collectedAt),
    };
  }

  MktTreasuryPriceRow copyWith({
    String? title,
    String? maturityDate,
    String? refDate,
    String? source,
    Value<String?> buyRate = const Value.absent(),
    Value<String?> sellRate = const Value.absent(),
    Value<String?> buyPu = const Value.absent(),
    Value<String?> sellPu = const Value.absent(),
    Value<String?> basePu = const Value.absent(),
    String? collectedAt,
  }) => MktTreasuryPriceRow(
    title: title ?? this.title,
    maturityDate: maturityDate ?? this.maturityDate,
    refDate: refDate ?? this.refDate,
    source: source ?? this.source,
    buyRate: buyRate.present ? buyRate.value : this.buyRate,
    sellRate: sellRate.present ? sellRate.value : this.sellRate,
    buyPu: buyPu.present ? buyPu.value : this.buyPu,
    sellPu: sellPu.present ? sellPu.value : this.sellPu,
    basePu: basePu.present ? basePu.value : this.basePu,
    collectedAt: collectedAt ?? this.collectedAt,
  );
  MktTreasuryPriceRow copyWithCompanion(MktTreasuryPricesCompanion data) {
    return MktTreasuryPriceRow(
      title: data.title.present ? data.title.value : this.title,
      maturityDate: data.maturityDate.present
          ? data.maturityDate.value
          : this.maturityDate,
      refDate: data.refDate.present ? data.refDate.value : this.refDate,
      source: data.source.present ? data.source.value : this.source,
      buyRate: data.buyRate.present ? data.buyRate.value : this.buyRate,
      sellRate: data.sellRate.present ? data.sellRate.value : this.sellRate,
      buyPu: data.buyPu.present ? data.buyPu.value : this.buyPu,
      sellPu: data.sellPu.present ? data.sellPu.value : this.sellPu,
      basePu: data.basePu.present ? data.basePu.value : this.basePu,
      collectedAt: data.collectedAt.present
          ? data.collectedAt.value
          : this.collectedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MktTreasuryPriceRow(')
          ..write('title: $title, ')
          ..write('maturityDate: $maturityDate, ')
          ..write('refDate: $refDate, ')
          ..write('source: $source, ')
          ..write('buyRate: $buyRate, ')
          ..write('sellRate: $sellRate, ')
          ..write('buyPu: $buyPu, ')
          ..write('sellPu: $sellPu, ')
          ..write('basePu: $basePu, ')
          ..write('collectedAt: $collectedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    title,
    maturityDate,
    refDate,
    source,
    buyRate,
    sellRate,
    buyPu,
    sellPu,
    basePu,
    collectedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MktTreasuryPriceRow &&
          other.title == this.title &&
          other.maturityDate == this.maturityDate &&
          other.refDate == this.refDate &&
          other.source == this.source &&
          other.buyRate == this.buyRate &&
          other.sellRate == this.sellRate &&
          other.buyPu == this.buyPu &&
          other.sellPu == this.sellPu &&
          other.basePu == this.basePu &&
          other.collectedAt == this.collectedAt);
}

class MktTreasuryPricesCompanion extends UpdateCompanion<MktTreasuryPriceRow> {
  final Value<String> title;
  final Value<String> maturityDate;
  final Value<String> refDate;
  final Value<String> source;
  final Value<String?> buyRate;
  final Value<String?> sellRate;
  final Value<String?> buyPu;
  final Value<String?> sellPu;
  final Value<String?> basePu;
  final Value<String> collectedAt;
  final Value<int> rowid;
  const MktTreasuryPricesCompanion({
    this.title = const Value.absent(),
    this.maturityDate = const Value.absent(),
    this.refDate = const Value.absent(),
    this.source = const Value.absent(),
    this.buyRate = const Value.absent(),
    this.sellRate = const Value.absent(),
    this.buyPu = const Value.absent(),
    this.sellPu = const Value.absent(),
    this.basePu = const Value.absent(),
    this.collectedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MktTreasuryPricesCompanion.insert({
    required String title,
    required String maturityDate,
    required String refDate,
    required String source,
    this.buyRate = const Value.absent(),
    this.sellRate = const Value.absent(),
    this.buyPu = const Value.absent(),
    this.sellPu = const Value.absent(),
    this.basePu = const Value.absent(),
    required String collectedAt,
    this.rowid = const Value.absent(),
  }) : title = Value(title),
       maturityDate = Value(maturityDate),
       refDate = Value(refDate),
       source = Value(source),
       collectedAt = Value(collectedAt);
  static Insertable<MktTreasuryPriceRow> custom({
    Expression<String>? title,
    Expression<String>? maturityDate,
    Expression<String>? refDate,
    Expression<String>? source,
    Expression<String>? buyRate,
    Expression<String>? sellRate,
    Expression<String>? buyPu,
    Expression<String>? sellPu,
    Expression<String>? basePu,
    Expression<String>? collectedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (title != null) 'title': title,
      if (maturityDate != null) 'maturity_date': maturityDate,
      if (refDate != null) 'ref_date': refDate,
      if (source != null) 'source': source,
      if (buyRate != null) 'buy_rate': buyRate,
      if (sellRate != null) 'sell_rate': sellRate,
      if (buyPu != null) 'buy_pu': buyPu,
      if (sellPu != null) 'sell_pu': sellPu,
      if (basePu != null) 'base_pu': basePu,
      if (collectedAt != null) 'collected_at': collectedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MktTreasuryPricesCompanion copyWith({
    Value<String>? title,
    Value<String>? maturityDate,
    Value<String>? refDate,
    Value<String>? source,
    Value<String?>? buyRate,
    Value<String?>? sellRate,
    Value<String?>? buyPu,
    Value<String?>? sellPu,
    Value<String?>? basePu,
    Value<String>? collectedAt,
    Value<int>? rowid,
  }) {
    return MktTreasuryPricesCompanion(
      title: title ?? this.title,
      maturityDate: maturityDate ?? this.maturityDate,
      refDate: refDate ?? this.refDate,
      source: source ?? this.source,
      buyRate: buyRate ?? this.buyRate,
      sellRate: sellRate ?? this.sellRate,
      buyPu: buyPu ?? this.buyPu,
      sellPu: sellPu ?? this.sellPu,
      basePu: basePu ?? this.basePu,
      collectedAt: collectedAt ?? this.collectedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (maturityDate.present) {
      map['maturity_date'] = Variable<String>(maturityDate.value);
    }
    if (refDate.present) {
      map['ref_date'] = Variable<String>(refDate.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (buyRate.present) {
      map['buy_rate'] = Variable<String>(buyRate.value);
    }
    if (sellRate.present) {
      map['sell_rate'] = Variable<String>(sellRate.value);
    }
    if (buyPu.present) {
      map['buy_pu'] = Variable<String>(buyPu.value);
    }
    if (sellPu.present) {
      map['sell_pu'] = Variable<String>(sellPu.value);
    }
    if (basePu.present) {
      map['base_pu'] = Variable<String>(basePu.value);
    }
    if (collectedAt.present) {
      map['collected_at'] = Variable<String>(collectedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MktTreasuryPricesCompanion(')
          ..write('title: $title, ')
          ..write('maturityDate: $maturityDate, ')
          ..write('refDate: $refDate, ')
          ..write('source: $source, ')
          ..write('buyRate: $buyRate, ')
          ..write('sellRate: $sellRate, ')
          ..write('buyPu: $buyPu, ')
          ..write('sellPu: $sellPu, ')
          ..write('basePu: $basePu, ')
          ..write('collectedAt: $collectedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MktFundQuotasTable extends MktFundQuotas
    with TableInfo<$MktFundQuotasTable, MktFundQuotaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MktFundQuotasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cnpjMeta = const VerificationMeta('cnpj');
  @override
  late final GeneratedColumn<String> cnpj = GeneratedColumn<String>(
    'cnpj',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refDateMeta = const VerificationMeta(
    'refDate',
  );
  @override
  late final GeneratedColumn<String> refDate = GeneratedColumn<String>(
    'ref_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quotaMeta = const VerificationMeta('quota');
  @override
  late final GeneratedColumn<String> quota = GeneratedColumn<String>(
    'quota',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _navMeta = const VerificationMeta('nav');
  @override
  late final GeneratedColumn<String> nav = GeneratedColumn<String>(
    'nav',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _holdersMeta = const VerificationMeta(
    'holders',
  );
  @override
  late final GeneratedColumn<String> holders = GeneratedColumn<String>(
    'holders',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isinMeta = const VerificationMeta('isin');
  @override
  late final GeneratedColumn<String> isin = GeneratedColumn<String>(
    'isin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectedAtMeta = const VerificationMeta(
    'collectedAt',
  );
  @override
  late final GeneratedColumn<String> collectedAt = GeneratedColumn<String>(
    'collected_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    cnpj,
    refDate,
    kind,
    source,
    quota,
    nav,
    holders,
    isin,
    name,
    collectedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mkt_fund_quotas';
  @override
  VerificationContext validateIntegrity(
    Insertable<MktFundQuotaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cnpj')) {
      context.handle(
        _cnpjMeta,
        cnpj.isAcceptableOrUnknown(data['cnpj']!, _cnpjMeta),
      );
    } else if (isInserting) {
      context.missing(_cnpjMeta);
    }
    if (data.containsKey('ref_date')) {
      context.handle(
        _refDateMeta,
        refDate.isAcceptableOrUnknown(data['ref_date']!, _refDateMeta),
      );
    } else if (isInserting) {
      context.missing(_refDateMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('quota')) {
      context.handle(
        _quotaMeta,
        quota.isAcceptableOrUnknown(data['quota']!, _quotaMeta),
      );
    }
    if (data.containsKey('nav')) {
      context.handle(
        _navMeta,
        nav.isAcceptableOrUnknown(data['nav']!, _navMeta),
      );
    }
    if (data.containsKey('holders')) {
      context.handle(
        _holdersMeta,
        holders.isAcceptableOrUnknown(data['holders']!, _holdersMeta),
      );
    }
    if (data.containsKey('isin')) {
      context.handle(
        _isinMeta,
        isin.isAcceptableOrUnknown(data['isin']!, _isinMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('collected_at')) {
      context.handle(
        _collectedAtMeta,
        collectedAt.isAcceptableOrUnknown(
          data['collected_at']!,
          _collectedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cnpj, refDate, kind, source};
  @override
  MktFundQuotaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MktFundQuotaRow(
      cnpj: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cnpj'],
      )!,
      refDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_date'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      quota: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quota'],
      ),
      nav: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nav'],
      ),
      holders: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}holders'],
      ),
      isin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isin'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      collectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collected_at'],
      )!,
    );
  }

  @override
  $MktFundQuotasTable createAlias(String alias) {
    return $MktFundQuotasTable(attachedDatabase, alias);
  }
}

class MktFundQuotaRow extends DataClass implements Insertable<MktFundQuotaRow> {
  final String cnpj;
  final String refDate;

  /// `daily` (cota diária) ou `fii_monthly` (informe mensal de FII).
  final String kind;
  final String source;

  /// Cota diária ou valor patrimonial por cota.
  final String? quota;

  /// Patrimônio líquido.
  final String? nav;
  final String? holders;
  final String? isin;
  final String? name;
  final String collectedAt;
  const MktFundQuotaRow({
    required this.cnpj,
    required this.refDate,
    required this.kind,
    required this.source,
    this.quota,
    this.nav,
    this.holders,
    this.isin,
    this.name,
    required this.collectedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cnpj'] = Variable<String>(cnpj);
    map['ref_date'] = Variable<String>(refDate);
    map['kind'] = Variable<String>(kind);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || quota != null) {
      map['quota'] = Variable<String>(quota);
    }
    if (!nullToAbsent || nav != null) {
      map['nav'] = Variable<String>(nav);
    }
    if (!nullToAbsent || holders != null) {
      map['holders'] = Variable<String>(holders);
    }
    if (!nullToAbsent || isin != null) {
      map['isin'] = Variable<String>(isin);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['collected_at'] = Variable<String>(collectedAt);
    return map;
  }

  MktFundQuotasCompanion toCompanion(bool nullToAbsent) {
    return MktFundQuotasCompanion(
      cnpj: Value(cnpj),
      refDate: Value(refDate),
      kind: Value(kind),
      source: Value(source),
      quota: quota == null && nullToAbsent
          ? const Value.absent()
          : Value(quota),
      nav: nav == null && nullToAbsent ? const Value.absent() : Value(nav),
      holders: holders == null && nullToAbsent
          ? const Value.absent()
          : Value(holders),
      isin: isin == null && nullToAbsent ? const Value.absent() : Value(isin),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      collectedAt: Value(collectedAt),
    );
  }

  factory MktFundQuotaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MktFundQuotaRow(
      cnpj: serializer.fromJson<String>(json['cnpj']),
      refDate: serializer.fromJson<String>(json['refDate']),
      kind: serializer.fromJson<String>(json['kind']),
      source: serializer.fromJson<String>(json['source']),
      quota: serializer.fromJson<String?>(json['quota']),
      nav: serializer.fromJson<String?>(json['nav']),
      holders: serializer.fromJson<String?>(json['holders']),
      isin: serializer.fromJson<String?>(json['isin']),
      name: serializer.fromJson<String?>(json['name']),
      collectedAt: serializer.fromJson<String>(json['collectedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cnpj': serializer.toJson<String>(cnpj),
      'refDate': serializer.toJson<String>(refDate),
      'kind': serializer.toJson<String>(kind),
      'source': serializer.toJson<String>(source),
      'quota': serializer.toJson<String?>(quota),
      'nav': serializer.toJson<String?>(nav),
      'holders': serializer.toJson<String?>(holders),
      'isin': serializer.toJson<String?>(isin),
      'name': serializer.toJson<String?>(name),
      'collectedAt': serializer.toJson<String>(collectedAt),
    };
  }

  MktFundQuotaRow copyWith({
    String? cnpj,
    String? refDate,
    String? kind,
    String? source,
    Value<String?> quota = const Value.absent(),
    Value<String?> nav = const Value.absent(),
    Value<String?> holders = const Value.absent(),
    Value<String?> isin = const Value.absent(),
    Value<String?> name = const Value.absent(),
    String? collectedAt,
  }) => MktFundQuotaRow(
    cnpj: cnpj ?? this.cnpj,
    refDate: refDate ?? this.refDate,
    kind: kind ?? this.kind,
    source: source ?? this.source,
    quota: quota.present ? quota.value : this.quota,
    nav: nav.present ? nav.value : this.nav,
    holders: holders.present ? holders.value : this.holders,
    isin: isin.present ? isin.value : this.isin,
    name: name.present ? name.value : this.name,
    collectedAt: collectedAt ?? this.collectedAt,
  );
  MktFundQuotaRow copyWithCompanion(MktFundQuotasCompanion data) {
    return MktFundQuotaRow(
      cnpj: data.cnpj.present ? data.cnpj.value : this.cnpj,
      refDate: data.refDate.present ? data.refDate.value : this.refDate,
      kind: data.kind.present ? data.kind.value : this.kind,
      source: data.source.present ? data.source.value : this.source,
      quota: data.quota.present ? data.quota.value : this.quota,
      nav: data.nav.present ? data.nav.value : this.nav,
      holders: data.holders.present ? data.holders.value : this.holders,
      isin: data.isin.present ? data.isin.value : this.isin,
      name: data.name.present ? data.name.value : this.name,
      collectedAt: data.collectedAt.present
          ? data.collectedAt.value
          : this.collectedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MktFundQuotaRow(')
          ..write('cnpj: $cnpj, ')
          ..write('refDate: $refDate, ')
          ..write('kind: $kind, ')
          ..write('source: $source, ')
          ..write('quota: $quota, ')
          ..write('nav: $nav, ')
          ..write('holders: $holders, ')
          ..write('isin: $isin, ')
          ..write('name: $name, ')
          ..write('collectedAt: $collectedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    cnpj,
    refDate,
    kind,
    source,
    quota,
    nav,
    holders,
    isin,
    name,
    collectedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MktFundQuotaRow &&
          other.cnpj == this.cnpj &&
          other.refDate == this.refDate &&
          other.kind == this.kind &&
          other.source == this.source &&
          other.quota == this.quota &&
          other.nav == this.nav &&
          other.holders == this.holders &&
          other.isin == this.isin &&
          other.name == this.name &&
          other.collectedAt == this.collectedAt);
}

class MktFundQuotasCompanion extends UpdateCompanion<MktFundQuotaRow> {
  final Value<String> cnpj;
  final Value<String> refDate;
  final Value<String> kind;
  final Value<String> source;
  final Value<String?> quota;
  final Value<String?> nav;
  final Value<String?> holders;
  final Value<String?> isin;
  final Value<String?> name;
  final Value<String> collectedAt;
  final Value<int> rowid;
  const MktFundQuotasCompanion({
    this.cnpj = const Value.absent(),
    this.refDate = const Value.absent(),
    this.kind = const Value.absent(),
    this.source = const Value.absent(),
    this.quota = const Value.absent(),
    this.nav = const Value.absent(),
    this.holders = const Value.absent(),
    this.isin = const Value.absent(),
    this.name = const Value.absent(),
    this.collectedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MktFundQuotasCompanion.insert({
    required String cnpj,
    required String refDate,
    required String kind,
    required String source,
    this.quota = const Value.absent(),
    this.nav = const Value.absent(),
    this.holders = const Value.absent(),
    this.isin = const Value.absent(),
    this.name = const Value.absent(),
    required String collectedAt,
    this.rowid = const Value.absent(),
  }) : cnpj = Value(cnpj),
       refDate = Value(refDate),
       kind = Value(kind),
       source = Value(source),
       collectedAt = Value(collectedAt);
  static Insertable<MktFundQuotaRow> custom({
    Expression<String>? cnpj,
    Expression<String>? refDate,
    Expression<String>? kind,
    Expression<String>? source,
    Expression<String>? quota,
    Expression<String>? nav,
    Expression<String>? holders,
    Expression<String>? isin,
    Expression<String>? name,
    Expression<String>? collectedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cnpj != null) 'cnpj': cnpj,
      if (refDate != null) 'ref_date': refDate,
      if (kind != null) 'kind': kind,
      if (source != null) 'source': source,
      if (quota != null) 'quota': quota,
      if (nav != null) 'nav': nav,
      if (holders != null) 'holders': holders,
      if (isin != null) 'isin': isin,
      if (name != null) 'name': name,
      if (collectedAt != null) 'collected_at': collectedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MktFundQuotasCompanion copyWith({
    Value<String>? cnpj,
    Value<String>? refDate,
    Value<String>? kind,
    Value<String>? source,
    Value<String?>? quota,
    Value<String?>? nav,
    Value<String?>? holders,
    Value<String?>? isin,
    Value<String?>? name,
    Value<String>? collectedAt,
    Value<int>? rowid,
  }) {
    return MktFundQuotasCompanion(
      cnpj: cnpj ?? this.cnpj,
      refDate: refDate ?? this.refDate,
      kind: kind ?? this.kind,
      source: source ?? this.source,
      quota: quota ?? this.quota,
      nav: nav ?? this.nav,
      holders: holders ?? this.holders,
      isin: isin ?? this.isin,
      name: name ?? this.name,
      collectedAt: collectedAt ?? this.collectedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cnpj.present) {
      map['cnpj'] = Variable<String>(cnpj.value);
    }
    if (refDate.present) {
      map['ref_date'] = Variable<String>(refDate.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (quota.present) {
      map['quota'] = Variable<String>(quota.value);
    }
    if (nav.present) {
      map['nav'] = Variable<String>(nav.value);
    }
    if (holders.present) {
      map['holders'] = Variable<String>(holders.value);
    }
    if (isin.present) {
      map['isin'] = Variable<String>(isin.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (collectedAt.present) {
      map['collected_at'] = Variable<String>(collectedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MktFundQuotasCompanion(')
          ..write('cnpj: $cnpj, ')
          ..write('refDate: $refDate, ')
          ..write('kind: $kind, ')
          ..write('source: $source, ')
          ..write('quota: $quota, ')
          ..write('nav: $nav, ')
          ..write('holders: $holders, ')
          ..write('isin: $isin, ')
          ..write('name: $name, ')
          ..write('collectedAt: $collectedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MktInstrumentsTable extends MktInstruments
    with TableInfo<$MktInstrumentsTable, MktInstrumentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MktInstrumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marketMeta = const VerificationMeta('market');
  @override
  late final GeneratedColumn<String> market = GeneratedColumn<String>(
    'market',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isinMeta = const VerificationMeta('isin');
  @override
  late final GeneratedColumn<String> isin = GeneratedColumn<String>(
    'isin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectedAtMeta = const VerificationMeta(
    'collectedAt',
  );
  @override
  late final GeneratedColumn<String> collectedAt = GeneratedColumn<String>(
    'collected_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    symbol,
    market,
    source,
    isin,
    name,
    sourceId,
    collectedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mkt_instruments';
  @override
  VerificationContext validateIntegrity(
    Insertable<MktInstrumentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('market')) {
      context.handle(
        _marketMeta,
        market.isAcceptableOrUnknown(data['market']!, _marketMeta),
      );
    } else if (isInserting) {
      context.missing(_marketMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('isin')) {
      context.handle(
        _isinMeta,
        isin.isAcceptableOrUnknown(data['isin']!, _isinMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('collected_at')) {
      context.handle(
        _collectedAtMeta,
        collectedAt.isAcceptableOrUnknown(
          data['collected_at']!,
          _collectedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {symbol, market, source};
  @override
  MktInstrumentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MktInstrumentRow(
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      market: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}market'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      isin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isin'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      ),
      collectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collected_at'],
      )!,
    );
  }

  @override
  $MktInstrumentsTable createAlias(String alias) {
    return $MktInstrumentsTable(attachedDatabase, alias);
  }
}

class MktInstrumentRow extends DataClass
    implements Insertable<MktInstrumentRow> {
  final String symbol;
  final String market;
  final String source;
  final String? isin;
  final String? name;

  /// Identificador do instrumento na fonte (por exemplo, id da CoinGecko).
  final String? sourceId;
  final String collectedAt;
  const MktInstrumentRow({
    required this.symbol,
    required this.market,
    required this.source,
    this.isin,
    this.name,
    this.sourceId,
    required this.collectedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['symbol'] = Variable<String>(symbol);
    map['market'] = Variable<String>(market);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || isin != null) {
      map['isin'] = Variable<String>(isin);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    map['collected_at'] = Variable<String>(collectedAt);
    return map;
  }

  MktInstrumentsCompanion toCompanion(bool nullToAbsent) {
    return MktInstrumentsCompanion(
      symbol: Value(symbol),
      market: Value(market),
      source: Value(source),
      isin: isin == null && nullToAbsent ? const Value.absent() : Value(isin),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      collectedAt: Value(collectedAt),
    );
  }

  factory MktInstrumentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MktInstrumentRow(
      symbol: serializer.fromJson<String>(json['symbol']),
      market: serializer.fromJson<String>(json['market']),
      source: serializer.fromJson<String>(json['source']),
      isin: serializer.fromJson<String?>(json['isin']),
      name: serializer.fromJson<String?>(json['name']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      collectedAt: serializer.fromJson<String>(json['collectedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'symbol': serializer.toJson<String>(symbol),
      'market': serializer.toJson<String>(market),
      'source': serializer.toJson<String>(source),
      'isin': serializer.toJson<String?>(isin),
      'name': serializer.toJson<String?>(name),
      'sourceId': serializer.toJson<String?>(sourceId),
      'collectedAt': serializer.toJson<String>(collectedAt),
    };
  }

  MktInstrumentRow copyWith({
    String? symbol,
    String? market,
    String? source,
    Value<String?> isin = const Value.absent(),
    Value<String?> name = const Value.absent(),
    Value<String?> sourceId = const Value.absent(),
    String? collectedAt,
  }) => MktInstrumentRow(
    symbol: symbol ?? this.symbol,
    market: market ?? this.market,
    source: source ?? this.source,
    isin: isin.present ? isin.value : this.isin,
    name: name.present ? name.value : this.name,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    collectedAt: collectedAt ?? this.collectedAt,
  );
  MktInstrumentRow copyWithCompanion(MktInstrumentsCompanion data) {
    return MktInstrumentRow(
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      market: data.market.present ? data.market.value : this.market,
      source: data.source.present ? data.source.value : this.source,
      isin: data.isin.present ? data.isin.value : this.isin,
      name: data.name.present ? data.name.value : this.name,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      collectedAt: data.collectedAt.present
          ? data.collectedAt.value
          : this.collectedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MktInstrumentRow(')
          ..write('symbol: $symbol, ')
          ..write('market: $market, ')
          ..write('source: $source, ')
          ..write('isin: $isin, ')
          ..write('name: $name, ')
          ..write('sourceId: $sourceId, ')
          ..write('collectedAt: $collectedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(symbol, market, source, isin, name, sourceId, collectedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MktInstrumentRow &&
          other.symbol == this.symbol &&
          other.market == this.market &&
          other.source == this.source &&
          other.isin == this.isin &&
          other.name == this.name &&
          other.sourceId == this.sourceId &&
          other.collectedAt == this.collectedAt);
}

class MktInstrumentsCompanion extends UpdateCompanion<MktInstrumentRow> {
  final Value<String> symbol;
  final Value<String> market;
  final Value<String> source;
  final Value<String?> isin;
  final Value<String?> name;
  final Value<String?> sourceId;
  final Value<String> collectedAt;
  final Value<int> rowid;
  const MktInstrumentsCompanion({
    this.symbol = const Value.absent(),
    this.market = const Value.absent(),
    this.source = const Value.absent(),
    this.isin = const Value.absent(),
    this.name = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.collectedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MktInstrumentsCompanion.insert({
    required String symbol,
    required String market,
    required String source,
    this.isin = const Value.absent(),
    this.name = const Value.absent(),
    this.sourceId = const Value.absent(),
    required String collectedAt,
    this.rowid = const Value.absent(),
  }) : symbol = Value(symbol),
       market = Value(market),
       source = Value(source),
       collectedAt = Value(collectedAt);
  static Insertable<MktInstrumentRow> custom({
    Expression<String>? symbol,
    Expression<String>? market,
    Expression<String>? source,
    Expression<String>? isin,
    Expression<String>? name,
    Expression<String>? sourceId,
    Expression<String>? collectedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (symbol != null) 'symbol': symbol,
      if (market != null) 'market': market,
      if (source != null) 'source': source,
      if (isin != null) 'isin': isin,
      if (name != null) 'name': name,
      if (sourceId != null) 'source_id': sourceId,
      if (collectedAt != null) 'collected_at': collectedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MktInstrumentsCompanion copyWith({
    Value<String>? symbol,
    Value<String>? market,
    Value<String>? source,
    Value<String?>? isin,
    Value<String?>? name,
    Value<String?>? sourceId,
    Value<String>? collectedAt,
    Value<int>? rowid,
  }) {
    return MktInstrumentsCompanion(
      symbol: symbol ?? this.symbol,
      market: market ?? this.market,
      source: source ?? this.source,
      isin: isin ?? this.isin,
      name: name ?? this.name,
      sourceId: sourceId ?? this.sourceId,
      collectedAt: collectedAt ?? this.collectedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (market.present) {
      map['market'] = Variable<String>(market.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (isin.present) {
      map['isin'] = Variable<String>(isin.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (collectedAt.present) {
      map['collected_at'] = Variable<String>(collectedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MktInstrumentsCompanion(')
          ..write('symbol: $symbol, ')
          ..write('market: $market, ')
          ..write('source: $source, ')
          ..write('isin: $isin, ')
          ..write('name: $name, ')
          ..write('sourceId: $sourceId, ')
          ..write('collectedAt: $collectedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DevProviderStateTable extends DevProviderState
    with TableInfo<$DevProviderStateTable, DevProviderStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevProviderStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
  );
  static const VerificationMeta _lastSuccessAtMeta = const VerificationMeta(
    'lastSuccessAt',
  );
  @override
  late final GeneratedColumn<String> lastSuccessAt = GeneratedColumn<String>(
    'last_success_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorAtMeta = const VerificationMeta(
    'lastErrorAt',
  );
  @override
  late final GeneratedColumn<String> lastErrorAt = GeneratedColumn<String>(
    'last_error_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quotaUsedMeta = const VerificationMeta(
    'quotaUsed',
  );
  @override
  late final GeneratedColumn<int> quotaUsed = GeneratedColumn<int>(
    'quota_used',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _quotaPeriodMeta = const VerificationMeta(
    'quotaPeriod',
  );
  @override
  late final GeneratedColumn<String> quotaPeriod = GeneratedColumn<String>(
    'quota_period',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    provider,
    enabled,
    lastSuccessAt,
    lastErrorAt,
    lastError,
    quotaUsed,
    quotaPeriod,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dev_provider_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<DevProviderStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    } else if (isInserting) {
      context.missing(_enabledMeta);
    }
    if (data.containsKey('last_success_at')) {
      context.handle(
        _lastSuccessAtMeta,
        lastSuccessAt.isAcceptableOrUnknown(
          data['last_success_at']!,
          _lastSuccessAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error_at')) {
      context.handle(
        _lastErrorAtMeta,
        lastErrorAt.isAcceptableOrUnknown(
          data['last_error_at']!,
          _lastErrorAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('quota_used')) {
      context.handle(
        _quotaUsedMeta,
        quotaUsed.isAcceptableOrUnknown(data['quota_used']!, _quotaUsedMeta),
      );
    }
    if (data.containsKey('quota_period')) {
      context.handle(
        _quotaPeriodMeta,
        quotaPeriod.isAcceptableOrUnknown(
          data['quota_period']!,
          _quotaPeriodMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {provider};
  @override
  DevProviderStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DevProviderStateRow(
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      lastSuccessAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_success_at'],
      ),
      lastErrorAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      quotaUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quota_used'],
      )!,
      quotaPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quota_period'],
      ),
    );
  }

  @override
  $DevProviderStateTable createAlias(String alias) {
    return $DevProviderStateTable(attachedDatabase, alias);
  }
}

class DevProviderStateRow extends DataClass
    implements Insertable<DevProviderStateRow> {
  final String provider;
  final bool enabled;
  final String? lastSuccessAt;
  final String? lastErrorAt;
  final String? lastError;
  final int quotaUsed;

  /// Período da cota (`2026-10` para cotas mensais).
  final String? quotaPeriod;
  const DevProviderStateRow({
    required this.provider,
    required this.enabled,
    this.lastSuccessAt,
    this.lastErrorAt,
    this.lastError,
    required this.quotaUsed,
    this.quotaPeriod,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['provider'] = Variable<String>(provider);
    map['enabled'] = Variable<bool>(enabled);
    if (!nullToAbsent || lastSuccessAt != null) {
      map['last_success_at'] = Variable<String>(lastSuccessAt);
    }
    if (!nullToAbsent || lastErrorAt != null) {
      map['last_error_at'] = Variable<String>(lastErrorAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['quota_used'] = Variable<int>(quotaUsed);
    if (!nullToAbsent || quotaPeriod != null) {
      map['quota_period'] = Variable<String>(quotaPeriod);
    }
    return map;
  }

  DevProviderStateCompanion toCompanion(bool nullToAbsent) {
    return DevProviderStateCompanion(
      provider: Value(provider),
      enabled: Value(enabled),
      lastSuccessAt: lastSuccessAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuccessAt),
      lastErrorAt: lastErrorAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      quotaUsed: Value(quotaUsed),
      quotaPeriod: quotaPeriod == null && nullToAbsent
          ? const Value.absent()
          : Value(quotaPeriod),
    );
  }

  factory DevProviderStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DevProviderStateRow(
      provider: serializer.fromJson<String>(json['provider']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      lastSuccessAt: serializer.fromJson<String?>(json['lastSuccessAt']),
      lastErrorAt: serializer.fromJson<String?>(json['lastErrorAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      quotaUsed: serializer.fromJson<int>(json['quotaUsed']),
      quotaPeriod: serializer.fromJson<String?>(json['quotaPeriod']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'provider': serializer.toJson<String>(provider),
      'enabled': serializer.toJson<bool>(enabled),
      'lastSuccessAt': serializer.toJson<String?>(lastSuccessAt),
      'lastErrorAt': serializer.toJson<String?>(lastErrorAt),
      'lastError': serializer.toJson<String?>(lastError),
      'quotaUsed': serializer.toJson<int>(quotaUsed),
      'quotaPeriod': serializer.toJson<String?>(quotaPeriod),
    };
  }

  DevProviderStateRow copyWith({
    String? provider,
    bool? enabled,
    Value<String?> lastSuccessAt = const Value.absent(),
    Value<String?> lastErrorAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    int? quotaUsed,
    Value<String?> quotaPeriod = const Value.absent(),
  }) => DevProviderStateRow(
    provider: provider ?? this.provider,
    enabled: enabled ?? this.enabled,
    lastSuccessAt: lastSuccessAt.present
        ? lastSuccessAt.value
        : this.lastSuccessAt,
    lastErrorAt: lastErrorAt.present ? lastErrorAt.value : this.lastErrorAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    quotaUsed: quotaUsed ?? this.quotaUsed,
    quotaPeriod: quotaPeriod.present ? quotaPeriod.value : this.quotaPeriod,
  );
  DevProviderStateRow copyWithCompanion(DevProviderStateCompanion data) {
    return DevProviderStateRow(
      provider: data.provider.present ? data.provider.value : this.provider,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      lastSuccessAt: data.lastSuccessAt.present
          ? data.lastSuccessAt.value
          : this.lastSuccessAt,
      lastErrorAt: data.lastErrorAt.present
          ? data.lastErrorAt.value
          : this.lastErrorAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      quotaUsed: data.quotaUsed.present ? data.quotaUsed.value : this.quotaUsed,
      quotaPeriod: data.quotaPeriod.present
          ? data.quotaPeriod.value
          : this.quotaPeriod,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DevProviderStateRow(')
          ..write('provider: $provider, ')
          ..write('enabled: $enabled, ')
          ..write('lastSuccessAt: $lastSuccessAt, ')
          ..write('lastErrorAt: $lastErrorAt, ')
          ..write('lastError: $lastError, ')
          ..write('quotaUsed: $quotaUsed, ')
          ..write('quotaPeriod: $quotaPeriod')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    provider,
    enabled,
    lastSuccessAt,
    lastErrorAt,
    lastError,
    quotaUsed,
    quotaPeriod,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DevProviderStateRow &&
          other.provider == this.provider &&
          other.enabled == this.enabled &&
          other.lastSuccessAt == this.lastSuccessAt &&
          other.lastErrorAt == this.lastErrorAt &&
          other.lastError == this.lastError &&
          other.quotaUsed == this.quotaUsed &&
          other.quotaPeriod == this.quotaPeriod);
}

class DevProviderStateCompanion extends UpdateCompanion<DevProviderStateRow> {
  final Value<String> provider;
  final Value<bool> enabled;
  final Value<String?> lastSuccessAt;
  final Value<String?> lastErrorAt;
  final Value<String?> lastError;
  final Value<int> quotaUsed;
  final Value<String?> quotaPeriod;
  final Value<int> rowid;
  const DevProviderStateCompanion({
    this.provider = const Value.absent(),
    this.enabled = const Value.absent(),
    this.lastSuccessAt = const Value.absent(),
    this.lastErrorAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.quotaUsed = const Value.absent(),
    this.quotaPeriod = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevProviderStateCompanion.insert({
    required String provider,
    required bool enabled,
    this.lastSuccessAt = const Value.absent(),
    this.lastErrorAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.quotaUsed = const Value.absent(),
    this.quotaPeriod = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : provider = Value(provider),
       enabled = Value(enabled);
  static Insertable<DevProviderStateRow> custom({
    Expression<String>? provider,
    Expression<bool>? enabled,
    Expression<String>? lastSuccessAt,
    Expression<String>? lastErrorAt,
    Expression<String>? lastError,
    Expression<int>? quotaUsed,
    Expression<String>? quotaPeriod,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (provider != null) 'provider': provider,
      if (enabled != null) 'enabled': enabled,
      if (lastSuccessAt != null) 'last_success_at': lastSuccessAt,
      if (lastErrorAt != null) 'last_error_at': lastErrorAt,
      if (lastError != null) 'last_error': lastError,
      if (quotaUsed != null) 'quota_used': quotaUsed,
      if (quotaPeriod != null) 'quota_period': quotaPeriod,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevProviderStateCompanion copyWith({
    Value<String>? provider,
    Value<bool>? enabled,
    Value<String?>? lastSuccessAt,
    Value<String?>? lastErrorAt,
    Value<String?>? lastError,
    Value<int>? quotaUsed,
    Value<String?>? quotaPeriod,
    Value<int>? rowid,
  }) {
    return DevProviderStateCompanion(
      provider: provider ?? this.provider,
      enabled: enabled ?? this.enabled,
      lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
      lastErrorAt: lastErrorAt ?? this.lastErrorAt,
      lastError: lastError ?? this.lastError,
      quotaUsed: quotaUsed ?? this.quotaUsed,
      quotaPeriod: quotaPeriod ?? this.quotaPeriod,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (lastSuccessAt.present) {
      map['last_success_at'] = Variable<String>(lastSuccessAt.value);
    }
    if (lastErrorAt.present) {
      map['last_error_at'] = Variable<String>(lastErrorAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (quotaUsed.present) {
      map['quota_used'] = Variable<int>(quotaUsed.value);
    }
    if (quotaPeriod.present) {
      map['quota_period'] = Variable<String>(quotaPeriod.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevProviderStateCompanion(')
          ..write('provider: $provider, ')
          ..write('enabled: $enabled, ')
          ..write('lastSuccessAt: $lastSuccessAt, ')
          ..write('lastErrorAt: $lastErrorAt, ')
          ..write('lastError: $lastError, ')
          ..write('quotaUsed: $quotaUsed, ')
          ..write('quotaPeriod: $quotaPeriod, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DevIdentityTable devIdentity = $DevIdentityTable(this);
  late final $DevSettingsTable devSettings = $DevSettingsTable(this);
  late final $SharedSettingsTable sharedSettings = $SharedSettingsTable(this);
  late final $InstitutionsTable institutions = $InstitutionsTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $AssetsTable assets = $AssetsTable(this);
  late final $FixedIncomeTermsTable fixedIncomeTerms = $FixedIncomeTermsTable(
    this,
  );
  late final $OperationsTable operations = $OperationsTable(this);
  late final $ManualValuationsTable manualValuations = $ManualValuationsTable(
    this,
  );
  late final $AssetAliasesTable assetAliases = $AssetAliasesTable(this);
  late final $HypoPortfoliosTable hypoPortfolios = $HypoPortfoliosTable(this);
  late final $HypoHoldingsTable hypoHoldings = $HypoHoldingsTable(this);
  late final $HypoCashflowRulesTable hypoCashflowRules =
      $HypoCashflowRulesTable(this);
  late final $HypoScenariosTable hypoScenarios = $HypoScenariosTable(this);
  late final $DevSyncPeersTable devSyncPeers = $DevSyncPeersTable(this);
  late final $DevSyncHistoryTable devSyncHistory = $DevSyncHistoryTable(this);
  late final $DevBackupsTable devBackups = $DevBackupsTable(this);
  late final $MktPricesTable mktPrices = $MktPricesTable(this);
  late final $MktQuotesTable mktQuotes = $MktQuotesTable(this);
  late final $MktCorporateEventsTable mktCorporateEvents =
      $MktCorporateEventsTable(this);
  late final $MktIndicatorsTable mktIndicators = $MktIndicatorsTable(this);
  late final $MktFxRatesTable mktFxRates = $MktFxRatesTable(this);
  late final $MktTreasuryPricesTable mktTreasuryPrices =
      $MktTreasuryPricesTable(this);
  late final $MktFundQuotasTable mktFundQuotas = $MktFundQuotasTable(this);
  late final $MktInstrumentsTable mktInstruments = $MktInstrumentsTable(this);
  late final $DevProviderStateTable devProviderState = $DevProviderStateTable(
    this,
  );
  late final Index sharedSettingsHlc = Index(
    'shared_settings_hlc',
    'CREATE INDEX shared_settings_hlc ON shared_settings (hlc)',
  );
  late final Index sharedSettingsKey = Index(
    'shared_settings_key',
    'CREATE INDEX shared_settings_key ON shared_settings ("key")',
  );
  late final Index institutionsHlc = Index(
    'institutions_hlc',
    'CREATE INDEX institutions_hlc ON institutions (hlc)',
  );
  late final Index institutionsNameKey = Index(
    'institutions_name_key',
    'CREATE INDEX institutions_name_key ON institutions (name_key)',
  );
  late final Index accountsHlc = Index(
    'accounts_hlc',
    'CREATE INDEX accounts_hlc ON accounts (hlc)',
  );
  late final Index accountsInstitution = Index(
    'accounts_institution',
    'CREATE INDEX accounts_institution ON accounts (institution_id)',
  );
  late final Index assetsHlc = Index(
    'assets_hlc',
    'CREATE INDEX assets_hlc ON assets (hlc)',
  );
  late final Index assetsSymbol = Index(
    'assets_symbol',
    'CREATE INDEX assets_symbol ON assets (symbol, market)',
  );
  late final Index fixedIncomeTermsHlc = Index(
    'fixed_income_terms_hlc',
    'CREATE INDEX fixed_income_terms_hlc ON fixed_income_terms (hlc)',
  );
  late final Index fixedIncomeTermsAsset = Index(
    'fixed_income_terms_asset',
    'CREATE INDEX fixed_income_terms_asset ON fixed_income_terms (asset_id)',
  );
  late final Index operationsHlc = Index(
    'operations_hlc',
    'CREATE INDEX operations_hlc ON operations (hlc)',
  );
  late final Index operationsAssetDate = Index(
    'operations_asset_date',
    'CREATE INDEX operations_asset_date ON operations (asset_id, trade_date)',
  );
  late final Index operationsAccountDate = Index(
    'operations_account_date',
    'CREATE INDEX operations_account_date ON operations (account_id, trade_date)',
  );
  late final Index operationsDate = Index(
    'operations_date',
    'CREATE INDEX operations_date ON operations (trade_date)',
  );
  late final Index manualValuationsHlc = Index(
    'manual_valuations_hlc',
    'CREATE INDEX manual_valuations_hlc ON manual_valuations (hlc)',
  );
  late final Index manualValuationsAssetDate = Index(
    'manual_valuations_asset_date',
    'CREATE INDEX manual_valuations_asset_date ON manual_valuations (asset_id, ref_date)',
  );
  late final Index assetAliasesHlc = Index(
    'asset_aliases_hlc',
    'CREATE INDEX asset_aliases_hlc ON asset_aliases (hlc)',
  );
  late final Index assetAliasesAlias = Index(
    'asset_aliases_alias',
    'CREATE INDEX asset_aliases_alias ON asset_aliases (alias_id)',
  );
  late final Index hypoPortfoliosHlc = Index(
    'hypo_portfolios_hlc',
    'CREATE INDEX hypo_portfolios_hlc ON hypo_portfolios (hlc)',
  );
  late final Index hypoHoldingsHlc = Index(
    'hypo_holdings_hlc',
    'CREATE INDEX hypo_holdings_hlc ON hypo_holdings (hlc)',
  );
  late final Index hypoHoldingsPortfolio = Index(
    'hypo_holdings_portfolio',
    'CREATE INDEX hypo_holdings_portfolio ON hypo_holdings (portfolio_id)',
  );
  late final Index hypoCashflowRulesHlc = Index(
    'hypo_cashflow_rules_hlc',
    'CREATE INDEX hypo_cashflow_rules_hlc ON hypo_cashflow_rules (hlc)',
  );
  late final Index hypoScenariosHlc = Index(
    'hypo_scenarios_hlc',
    'CREATE INDEX hypo_scenarios_hlc ON hypo_scenarios (hlc)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    devIdentity,
    devSettings,
    sharedSettings,
    institutions,
    accounts,
    assets,
    fixedIncomeTerms,
    operations,
    manualValuations,
    assetAliases,
    hypoPortfolios,
    hypoHoldings,
    hypoCashflowRules,
    hypoScenarios,
    devSyncPeers,
    devSyncHistory,
    devBackups,
    mktPrices,
    mktQuotes,
    mktCorporateEvents,
    mktIndicators,
    mktFxRates,
    mktTreasuryPrices,
    mktFundQuotas,
    mktInstruments,
    devProviderState,
    sharedSettingsHlc,
    sharedSettingsKey,
    institutionsHlc,
    institutionsNameKey,
    accountsHlc,
    accountsInstitution,
    assetsHlc,
    assetsSymbol,
    fixedIncomeTermsHlc,
    fixedIncomeTermsAsset,
    operationsHlc,
    operationsAssetDate,
    operationsAccountDate,
    operationsDate,
    manualValuationsHlc,
    manualValuationsAssetDate,
    assetAliasesHlc,
    assetAliasesAlias,
    hypoPortfoliosHlc,
    hypoHoldingsHlc,
    hypoHoldingsPortfolio,
    hypoCashflowRulesHlc,
    hypoScenariosHlc,
  ];
}

typedef $$DevIdentityTableCreateCompanionBuilder =
    DevIdentityCompanion Function({
      required String deviceId,
      required String deviceName,
      required String createdAt,
      required String lastHlc,
      Value<int> rowid,
    });
typedef $$DevIdentityTableUpdateCompanionBuilder =
    DevIdentityCompanion Function({
      Value<String> deviceId,
      Value<String> deviceName,
      Value<String> createdAt,
      Value<String> lastHlc,
      Value<int> rowid,
    });

class $$DevIdentityTableFilterComposer
    extends Composer<_$AppDatabase, $DevIdentityTable> {
  $$DevIdentityTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastHlc => $composableBuilder(
    column: $table.lastHlc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DevIdentityTableOrderingComposer
    extends Composer<_$AppDatabase, $DevIdentityTable> {
  $$DevIdentityTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastHlc => $composableBuilder(
    column: $table.lastHlc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevIdentityTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevIdentityTable> {
  $$DevIdentityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get lastHlc =>
      $composableBuilder(column: $table.lastHlc, builder: (column) => column);
}

class $$DevIdentityTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevIdentityTable,
          DevIdentityRow,
          $$DevIdentityTableFilterComposer,
          $$DevIdentityTableOrderingComposer,
          $$DevIdentityTableAnnotationComposer,
          $$DevIdentityTableCreateCompanionBuilder,
          $$DevIdentityTableUpdateCompanionBuilder,
          (
            DevIdentityRow,
            BaseReferences<_$AppDatabase, $DevIdentityTable, DevIdentityRow>,
          ),
          DevIdentityRow,
          PrefetchHooks Function()
        > {
  $$DevIdentityTableTableManager(_$AppDatabase db, $DevIdentityTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevIdentityTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevIdentityTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevIdentityTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> deviceId = const Value.absent(),
                Value<String> deviceName = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> lastHlc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevIdentityCompanion(
                deviceId: deviceId,
                deviceName: deviceName,
                createdAt: createdAt,
                lastHlc: lastHlc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String deviceId,
                required String deviceName,
                required String createdAt,
                required String lastHlc,
                Value<int> rowid = const Value.absent(),
              }) => DevIdentityCompanion.insert(
                deviceId: deviceId,
                deviceName: deviceName,
                createdAt: createdAt,
                lastHlc: lastHlc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DevIdentityTable, DevIdentityRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DevIdentityTable,
                    DevIdentityRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DevIdentityTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevIdentityTable,
      DevIdentityRow,
      $$DevIdentityTableFilterComposer,
      $$DevIdentityTableOrderingComposer,
      $$DevIdentityTableAnnotationComposer,
      $$DevIdentityTableCreateCompanionBuilder,
      $$DevIdentityTableUpdateCompanionBuilder,
      (
        DevIdentityRow,
        BaseReferences<_$AppDatabase, $DevIdentityTable, DevIdentityRow>,
      ),
      DevIdentityRow,
      PrefetchHooks Function()
    >;
typedef $$DevSettingsTableCreateCompanionBuilder =
    DevSettingsCompanion Function({
      required String key,
      required String valueJson,
      required String updatedAt,
      Value<int> rowid,
    });
typedef $$DevSettingsTableUpdateCompanionBuilder =
    DevSettingsCompanion Function({
      Value<String> key,
      Value<String> valueJson,
      Value<String> updatedAt,
      Value<int> rowid,
    });

class $$DevSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $DevSettingsTable> {
  $$DevSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DevSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $DevSettingsTable> {
  $$DevSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevSettingsTable> {
  $$DevSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get valueJson =>
      $composableBuilder(column: $table.valueJson, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DevSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevSettingsTable,
          DevSettingRow,
          $$DevSettingsTableFilterComposer,
          $$DevSettingsTableOrderingComposer,
          $$DevSettingsTableAnnotationComposer,
          $$DevSettingsTableCreateCompanionBuilder,
          $$DevSettingsTableUpdateCompanionBuilder,
          (
            DevSettingRow,
            BaseReferences<_$AppDatabase, $DevSettingsTable, DevSettingRow>,
          ),
          DevSettingRow,
          PrefetchHooks Function()
        > {
  $$DevSettingsTableTableManager(_$AppDatabase db, $DevSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> valueJson = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevSettingsCompanion(
                key: key,
                valueJson: valueJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String valueJson,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DevSettingsCompanion.insert(
                key: key,
                valueJson: valueJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DevSettingsTable, DevSettingRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DevSettingsTable,
                    DevSettingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DevSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevSettingsTable,
      DevSettingRow,
      $$DevSettingsTableFilterComposer,
      $$DevSettingsTableOrderingComposer,
      $$DevSettingsTableAnnotationComposer,
      $$DevSettingsTableCreateCompanionBuilder,
      $$DevSettingsTableUpdateCompanionBuilder,
      (
        DevSettingRow,
        BaseReferences<_$AppDatabase, $DevSettingsTable, DevSettingRow>,
      ),
      DevSettingRow,
      PrefetchHooks Function()
    >;
typedef $$SharedSettingsTableCreateCompanionBuilder =
    SharedSettingsCompanion Function({
      required String id,
      required String createdAt,
      required String updatedAt,
      required String hlc,
      required String deviceId,
      Value<String?> deletedAt,
      required String key,
      required String valueJson,
      Value<int> rowid,
    });
typedef $$SharedSettingsTableUpdateCompanionBuilder =
    SharedSettingsCompanion Function({
      Value<String> id,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String> hlc,
      Value<String> deviceId,
      Value<String?> deletedAt,
      Value<String> key,
      Value<String> valueJson,
      Value<int> rowid,
    });

class $$SharedSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SharedSettingsTable> {
  $$SharedSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SharedSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SharedSettingsTable> {
  $$SharedSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SharedSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SharedSettingsTable> {
  $$SharedSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get valueJson =>
      $composableBuilder(column: $table.valueJson, builder: (column) => column);
}

class $$SharedSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SharedSettingsTable,
          SharedSettingRow,
          $$SharedSettingsTableFilterComposer,
          $$SharedSettingsTableOrderingComposer,
          $$SharedSettingsTableAnnotationComposer,
          $$SharedSettingsTableCreateCompanionBuilder,
          $$SharedSettingsTableUpdateCompanionBuilder,
          (
            SharedSettingRow,
            BaseReferences<
              _$AppDatabase,
              $SharedSettingsTable,
              SharedSettingRow
            >,
          ),
          SharedSettingRow,
          PrefetchHooks Function()
        > {
  $$SharedSettingsTableTableManager(
    _$AppDatabase db,
    $SharedSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SharedSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SharedSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SharedSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> valueJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SharedSettingsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hlc: hlc,
                deviceId: deviceId,
                deletedAt: deletedAt,
                key: key,
                valueJson: valueJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                required String hlc,
                required String deviceId,
                Value<String?> deletedAt = const Value.absent(),
                required String key,
                required String valueJson,
                Value<int> rowid = const Value.absent(),
              }) => SharedSettingsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hlc: hlc,
                deviceId: deviceId,
                deletedAt: deletedAt,
                key: key,
                valueJson: valueJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SharedSettingsTable, SharedSettingRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SharedSettingsTable,
                    SharedSettingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SharedSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SharedSettingsTable,
      SharedSettingRow,
      $$SharedSettingsTableFilterComposer,
      $$SharedSettingsTableOrderingComposer,
      $$SharedSettingsTableAnnotationComposer,
      $$SharedSettingsTableCreateCompanionBuilder,
      $$SharedSettingsTableUpdateCompanionBuilder,
      (
        SharedSettingRow,
        BaseReferences<_$AppDatabase, $SharedSettingsTable, SharedSettingRow>,
      ),
      SharedSettingRow,
      PrefetchHooks Function()
    >;
typedef $$InstitutionsTableCreateCompanionBuilder =
    InstitutionsCompanion Function({
      required String id,
      required String createdAt,
      required String updatedAt,
      required String hlc,
      required String deviceId,
      Value<String?> deletedAt,
      required String name,
      required String nameKey,
      required String kind,
      required String country,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$InstitutionsTableUpdateCompanionBuilder =
    InstitutionsCompanion Function({
      Value<String> id,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String> hlc,
      Value<String> deviceId,
      Value<String?> deletedAt,
      Value<String> name,
      Value<String> nameKey,
      Value<String> kind,
      Value<String> country,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$InstitutionsTableReferences
    extends BaseReferences<_$AppDatabase, $InstitutionsTable, InstitutionRow> {
  $$InstitutionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AccountsTable, List<AccountRow>>
  _accountsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.accounts,
    aliasName: 'institutions__id__accounts__institution_id',
  );

  $$AccountsTableProcessedTableManager get accountsRefs {
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.institutionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_accountsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InstitutionsTableFilterComposer
    extends Composer<_$AppDatabase, $InstitutionsTable> {
  $$InstitutionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> accountsRefs(
    Expression<bool> Function($$AccountsTableFilterComposer f) f,
  ) {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.institutionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InstitutionsTableOrderingComposer
    extends Composer<_$AppDatabase, $InstitutionsTable> {
  $$InstitutionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InstitutionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstitutionsTable> {
  $$InstitutionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> accountsRefs<T extends Object>(
    Expression<T> Function($$AccountsTableAnnotationComposer a) f,
  ) {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.institutionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InstitutionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InstitutionsTable,
          InstitutionRow,
          $$InstitutionsTableFilterComposer,
          $$InstitutionsTableOrderingComposer,
          $$InstitutionsTableAnnotationComposer,
          $$InstitutionsTableCreateCompanionBuilder,
          $$InstitutionsTableUpdateCompanionBuilder,
          (InstitutionRow, $$InstitutionsTableReferences),
          InstitutionRow,
          PrefetchHooks Function({bool accountsRefs})
        > {
  $$InstitutionsTableTableManager(_$AppDatabase db, $InstitutionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstitutionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstitutionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InstitutionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameKey = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstitutionsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hlc: hlc,
                deviceId: deviceId,
                deletedAt: deletedAt,
                name: name,
                nameKey: nameKey,
                kind: kind,
                country: country,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                required String hlc,
                required String deviceId,
                Value<String?> deletedAt = const Value.absent(),
                required String name,
                required String nameKey,
                required String kind,
                required String country,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstitutionsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hlc: hlc,
                deviceId: deviceId,
                deletedAt: deletedAt,
                name: name,
                nameKey: nameKey,
                kind: kind,
                country: country,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InstitutionsTable, InstitutionRow>(table),
                  $$InstitutionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (accountsRefs) db.accounts],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (accountsRefs)
                    await $_getPrefetchedData<
                      InstitutionRow,
                      $InstitutionsTable,
                      AccountRow
                    >(
                      currentTable: table,
                      referencedTable: $$InstitutionsTableReferences
                          ._accountsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$InstitutionsTableReferences(
                            db,
                            table,
                            p0,
                          ).accountsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.institutionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$InstitutionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InstitutionsTable,
      InstitutionRow,
      $$InstitutionsTableFilterComposer,
      $$InstitutionsTableOrderingComposer,
      $$InstitutionsTableAnnotationComposer,
      $$InstitutionsTableCreateCompanionBuilder,
      $$InstitutionsTableUpdateCompanionBuilder,
      (InstitutionRow, $$InstitutionsTableReferences),
      InstitutionRow,
      PrefetchHooks Function({bool accountsRefs})
    >;
typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  required String id,
  required String createdAt,
  required String updatedAt,
  required String hlc,
  required String deviceId,
  Value<String?> deletedAt,
  required String institutionId,
  required String name,
  required String kind,
  required String currency,
  Value<String?> archivedAt,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> id,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String> hlc,
  Value<String> deviceId,
  Value<String?> deletedAt,
  Value<String> institutionId,
  Value<String> name,
  Value<String> kind,
  Value<String> currency,
  Value<String?> archivedAt,
  Value<int> rowid,
});

final class $$AccountsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountsTable, AccountRow> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $InstitutionsTable _institutionIdTable(_$AppDatabase db) =>
      db.institutions.createAlias('accounts__institution_id__institutions__id');

  $$InstitutionsTableProcessedTableManager get institutionId {
    final $_column = $_itemColumn<String>('institution_id')!;

    final manager = $$InstitutionsTableTableManager(
      $_db,
      $_db.institutions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_institutionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$OperationsTable, List<OperationRow>>
  _operationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.operations,
    aliasName: 'accounts__id__operations__account_id',
  );

  $$OperationsTableProcessedTableManager get operationsRefs {
    final manager = $$OperationsTableTableManager(
      $_db,
      $_db.operations,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_operationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ManualValuationsTable, List<ManualValuationRow>>
  _manualValuationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.manualValuations,
    aliasName: 'accounts__id__manual_valuations__account_id',
  );

  $$ManualValuationsTableProcessedTableManager get manualValuationsRefs {
    final manager = $$ManualValuationsTableTableManager(
      $_db,
      $_db.manualValuations,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _manualValuationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$InstitutionsTableFilterComposer get institutionId {
    final $$InstitutionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.institutionId,
      referencedTable: $db.institutions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstitutionsTableFilterComposer(
            $db: $db,
            $table: $db.institutions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> operationsRefs(
    Expression<bool> Function($$OperationsTableFilterComposer f) f,
  ) {
    final $$OperationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.operations,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationsTableFilterComposer(
            $db: $db,
            $table: $db.operations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> manualValuationsRefs(
    Expression<bool> Function($$ManualValuationsTableFilterComposer f) f,
  ) {
    final $$ManualValuationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.manualValuations,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ManualValuationsTableFilterComposer(
            $db: $db,
            $table: $db.manualValuations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$InstitutionsTableOrderingComposer get institutionId {
    final $$InstitutionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.institutionId,
      referencedTable: $db.institutions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstitutionsTableOrderingComposer(
            $db: $db,
            $table: $db.institutions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  $$InstitutionsTableAnnotationComposer get institutionId {
    final $$InstitutionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.institutionId,
      referencedTable: $db.institutions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstitutionsTableAnnotationComposer(
            $db: $db,
            $table: $db.institutions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> operationsRefs<T extends Object>(
    Expression<T> Function($$OperationsTableAnnotationComposer a) f,
  ) {
    final $$OperationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.operations,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationsTableAnnotationComposer(
            $db: $db,
            $table: $db.operations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> manualValuationsRefs<T extends Object>(
    Expression<T> Function($$ManualValuationsTableAnnotationComposer a) f,
  ) {
    final $$ManualValuationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.manualValuations,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ManualValuationsTableAnnotationComposer(
            $db: $db,
            $table: $db.manualValuations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          AccountRow,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (AccountRow, $$AccountsTableReferences),
          AccountRow,
          PrefetchHooks Function({
            bool institutionId,
            bool operationsRefs,
            bool manualValuationsRefs,
          })
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> institutionId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hlc: hlc,
                deviceId: deviceId,
                deletedAt: deletedAt,
                institutionId: institutionId,
                name: name,
                kind: kind,
                currency: currency,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                required String hlc,
                required String deviceId,
                Value<String?> deletedAt = const Value.absent(),
                required String institutionId,
                required String name,
                required String kind,
                required String currency,
                Value<String?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hlc: hlc,
                deviceId: deviceId,
                deletedAt: deletedAt,
                institutionId: institutionId,
                name: name,
                kind: kind,
                currency: currency,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountsTable, AccountRow>(table),
                  $$AccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                institutionId = false,
                operationsRefs = false,
                manualValuationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (operationsRefs) db.operations,
                    if (manualValuationsRefs) db.manualValuations,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (institutionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.institutionId,
                            referencedTable: $$AccountsTableReferences
                                ._institutionIdTable(db),
                            referencedColumn: $$AccountsTableReferences
                                ._institutionIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (operationsRefs)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          OperationRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._operationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).operationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (manualValuationsRefs)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          ManualValuationRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._manualValuationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).manualValuationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      AccountRow,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (AccountRow, $$AccountsTableReferences),
      AccountRow,
      PrefetchHooks Function({
        bool institutionId,
        bool operationsRefs,
        bool manualValuationsRefs,
      })
    >;
typedef $$AssetsTableCreateCompanionBuilder = AssetsCompanion Function({
  required String id,
  required String createdAt,
  required String updatedAt,
  required String hlc,
  required String deviceId,
  Value<String?> deletedAt,
  required String symbol,
  required String market,
  required String assetClass,
  required String name,
  required String currency,
  required String country,
  Value<String?> isin,
  Value<String?> sector,
  Value<String?> segment,
  Value<String?> liquidity,
  required String priceSource,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$AssetsTableUpdateCompanionBuilder = AssetsCompanion Function({
  Value<String> id,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String> hlc,
  Value<String> deviceId,
  Value<String?> deletedAt,
  Value<String> symbol,
  Value<String> market,
  Value<String> assetClass,
  Value<String> name,
  Value<String> currency,
  Value<String> country,
  Value<String?> isin,
  Value<String?> sector,
  Value<String?> segment,
  Value<String?> liquidity,
  Value<String> priceSource,
  Value<String?> notes,
  Value<int> rowid,
});

final class $$AssetsTableReferences
    extends BaseReferences<_$AppDatabase, $AssetsTable, AssetRow> {
  $$AssetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FixedIncomeTermsTable, List<FixedIncomeTermsRow>>
  _fixedIncomeTermsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.fixedIncomeTerms,
    aliasName: 'assets__id__fixed_income_terms__asset_id',
  );

  $$FixedIncomeTermsTableProcessedTableManager get fixedIncomeTermsRefs {
    final manager = $$FixedIncomeTermsTableTableManager(
      $_db,
      $_db.fixedIncomeTerms,
    ).filter((f) => f.assetId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _fixedIncomeTermsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OperationsTable, List<OperationRow>>
  _operationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.operations,
    aliasName: 'assets__id__operations__asset_id',
  );

  $$OperationsTableProcessedTableManager get operationsRefs {
    final manager = $$OperationsTableTableManager(
      $_db,
      $_db.operations,
    ).filter((f) => f.assetId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_operationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ManualValuationsTable, List<ManualValuationRow>>
  _manualValuationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.manualValuations,
    aliasName: 'assets__id__manual_valuations__asset_id',
  );

  $$ManualValuationsTableProcessedTableManager get manualValuationsRefs {
    final manager = $$ManualValuationsTableTableManager(
      $_db,
      $_db.manualValuations,
    ).filter((f) => f.assetId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _manualValuationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HypoHoldingsTable, List<HypoHoldingRow>>
  _hypoHoldingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.hypoHoldings,
    aliasName: 'assets__id__hypo_holdings__asset_id',
  );

  $$HypoHoldingsTableProcessedTableManager get hypoHoldingsRefs {
    final manager = $$HypoHoldingsTableTableManager(
      $_db,
      $_db.hypoHoldings,
    ).filter((f) => f.assetId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_hypoHoldingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AssetsTableFilterComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetClass => $composableBuilder(
    column: $table.assetClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isin => $composableBuilder(
    column: $table.isin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sector => $composableBuilder(
    column: $table.sector,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get segment => $composableBuilder(
    column: $table.segment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get liquidity => $composableBuilder(
    column: $table.liquidity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priceSource => $composableBuilder(
    column: $table.priceSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> fixedIncomeTermsRefs(
    Expression<bool> Function($$FixedIncomeTermsTableFilterComposer f) f,
  ) {
    final $$FixedIncomeTermsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fixedIncomeTerms,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixedIncomeTermsTableFilterComposer(
            $db: $db,
            $table: $db.fixedIncomeTerms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> operationsRefs(
    Expression<bool> Function($$OperationsTableFilterComposer f) f,
  ) {
    final $$OperationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.operations,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationsTableFilterComposer(
            $db: $db,
            $table: $db.operations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> manualValuationsRefs(
    Expression<bool> Function($$ManualValuationsTableFilterComposer f) f,
  ) {
    final $$ManualValuationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.manualValuations,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ManualValuationsTableFilterComposer(
            $db: $db,
            $table: $db.manualValuations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> hypoHoldingsRefs(
    Expression<bool> Function($$HypoHoldingsTableFilterComposer f) f,
  ) {
    final $$HypoHoldingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hypoHoldings,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HypoHoldingsTableFilterComposer(
            $db: $db,
            $table: $db.hypoHoldings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetClass => $composableBuilder(
    column: $table.assetClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isin => $composableBuilder(
    column: $table.isin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sector => $composableBuilder(
    column: $table.sector,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get segment => $composableBuilder(
    column: $table.segment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get liquidity => $composableBuilder(
    column: $table.liquidity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priceSource => $composableBuilder(
    column: $table.priceSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get market =>
      $composableBuilder(column: $table.market, builder: (column) => column);

  GeneratedColumn<String> get assetClass => $composableBuilder(
    column: $table.assetClass,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get isin =>
      $composableBuilder(column: $table.isin, builder: (column) => column);

  GeneratedColumn<String> get sector =>
      $composableBuilder(column: $table.sector, builder: (column) => column);

  GeneratedColumn<String> get segment =>
      $composableBuilder(column: $table.segment, builder: (column) => column);

  GeneratedColumn<String> get liquidity =>
      $composableBuilder(column: $table.liquidity, builder: (column) => column);

  GeneratedColumn<String> get priceSource => $composableBuilder(
    column: $table.priceSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> fixedIncomeTermsRefs<T extends Object>(
    Expression<T> Function($$FixedIncomeTermsTableAnnotationComposer a) f,
  ) {
    final $$FixedIncomeTermsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fixedIncomeTerms,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixedIncomeTermsTableAnnotationComposer(
            $db: $db,
            $table: $db.fixedIncomeTerms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> operationsRefs<T extends Object>(
    Expression<T> Function($$OperationsTableAnnotationComposer a) f,
  ) {
    final $$OperationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.operations,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationsTableAnnotationComposer(
            $db: $db,
            $table: $db.operations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> manualValuationsRefs<T extends Object>(
    Expression<T> Function($$ManualValuationsTableAnnotationComposer a) f,
  ) {
    final $$ManualValuationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.manualValuations,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ManualValuationsTableAnnotationComposer(
            $db: $db,
            $table: $db.manualValuations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> hypoHoldingsRefs<T extends Object>(
    Expression<T> Function($$HypoHoldingsTableAnnotationComposer a) f,
  ) {
    final $$HypoHoldingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hypoHoldings,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HypoHoldingsTableAnnotationComposer(
            $db: $db,
            $table: $db.hypoHoldings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AssetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssetsTable,
          AssetRow,
          $$AssetsTableFilterComposer,
          $$AssetsTableOrderingComposer,
          $$AssetsTableAnnotationComposer,
          $$AssetsTableCreateCompanionBuilder,
          $$AssetsTableUpdateCompanionBuilder,
          (AssetRow, $$AssetsTableReferences),
          AssetRow,
          PrefetchHooks Function({
            bool fixedIncomeTermsRefs,
            bool operationsRefs,
            bool manualValuationsRefs,
            bool hypoHoldingsRefs,
          })
        > {
  $$AssetsTableTableManager(_$AppDatabase db, $AssetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> symbol = const Value.absent(),
                Value<String> market = const Value.absent(),
                Value<String> assetClass = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<String?> isin = const Value.absent(),
                Value<String?> sector = const Value.absent(),
                Value<String?> segment = const Value.absent(),
                Value<String?> liquidity = const Value.absent(),
                Value<String> priceSource = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssetsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hlc: hlc,
                deviceId: deviceId,
                deletedAt: deletedAt,
                symbol: symbol,
                market: market,
                assetClass: assetClass,
                name: name,
                currency: currency,
                country: country,
                isin: isin,
                sector: sector,
                segment: segment,
                liquidity: liquidity,
                priceSource: priceSource,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                required String hlc,
                required String deviceId,
                Value<String?> deletedAt = const Value.absent(),
                required String symbol,
                required String market,
                required String assetClass,
                required String name,
                required String currency,
                required String country,
                Value<String?> isin = const Value.absent(),
                Value<String?> sector = const Value.absent(),
                Value<String?> segment = const Value.absent(),
                Value<String?> liquidity = const Value.absent(),
                required String priceSource,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssetsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hlc: hlc,
                deviceId: deviceId,
                deletedAt: deletedAt,
                symbol: symbol,
                market: market,
                assetClass: assetClass,
                name: name,
                currency: currency,
                country: country,
                isin: isin,
                sector: sector,
                segment: segment,
                liquidity: liquidity,
                priceSource: priceSource,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AssetsTable, AssetRow>(table),
                  $$AssetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                fixedIncomeTermsRefs = false,
                operationsRefs = false,
                manualValuationsRefs = false,
                hypoHoldingsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (fixedIncomeTermsRefs) db.fixedIncomeTerms,
                    if (operationsRefs) db.operations,
                    if (manualValuationsRefs) db.manualValuations,
                    if (hypoHoldingsRefs) db.hypoHoldings,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (fixedIncomeTermsRefs)
                        await $_getPrefetchedData<
                          AssetRow,
                          $AssetsTable,
                          FixedIncomeTermsRow
                        >(
                          currentTable: table,
                          referencedTable: $$AssetsTableReferences
                              ._fixedIncomeTermsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssetsTableReferences(
                                db,
                                table,
                                p0,
                              ).fixedIncomeTermsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.assetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (operationsRefs)
                        await $_getPrefetchedData<
                          AssetRow,
                          $AssetsTable,
                          OperationRow
                        >(
                          currentTable: table,
                          referencedTable: $$AssetsTableReferences
                              ._operationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssetsTableReferences(
                                db,
                                table,
                                p0,
                              ).operationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.assetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (manualValuationsRefs)
                        await $_getPrefetchedData<
                          AssetRow,
                          $AssetsTable,
                          ManualValuationRow
                        >(
                          currentTable: table,
                          referencedTable: $$AssetsTableReferences
                              ._manualValuationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssetsTableReferences(
                                db,
                                table,
                                p0,
                              ).manualValuationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.assetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (hypoHoldingsRefs)
                        await $_getPrefetchedData<
                          AssetRow,
                          $AssetsTable,
                          HypoHoldingRow
                        >(
                          currentTable: table,
                          referencedTable: $$AssetsTableReferences
                              ._hypoHoldingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssetsTableReferences(
                                db,
                                table,
                                p0,
                              ).hypoHoldingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.assetId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssetsTable,
      AssetRow,
      $$AssetsTableFilterComposer,
      $$AssetsTableOrderingComposer,
      $$AssetsTableAnnotationComposer,
      $$AssetsTableCreateCompanionBuilder,
      $$AssetsTableUpdateCompanionBuilder,
      (AssetRow, $$AssetsTableReferences),
      AssetRow,
      PrefetchHooks Function({
        bool fixedIncomeTermsRefs,
        bool operationsRefs,
        bool manualValuationsRefs,
        bool hypoHoldingsRefs,
      })
    >;
typedef $$FixedIncomeTermsTableCreateCompanionBuilder =
    FixedIncomeTermsCompanion Function({
      required String id,
      required String createdAt,
      required String updatedAt,
      required String hlc,
      required String deviceId,
      Value<String?> deletedAt,
      required String assetId,
      required String product,
      Value<String?> issuer,
      required String indexer,
      required Decimal rate,
      Value<Decimal?> spread,
      required String dayCount,
      required String issueDate,
      required String maturityDate,
      Value<String?> graceUntil,
      required String liquidity,
      required String taxRegime,
      Value<String?> costsNotes,
      Value<int> rowid,
    });
typedef $$FixedIncomeTermsTableUpdateCompanionBuilder =
    FixedIncomeTermsCompanion Function({
      Value<String> id,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String> hlc,
      Value<String> deviceId,
      Value<String?> deletedAt,
      Value<String> assetId,
      Value<String> product,
      Value<String?> issuer,
      Value<String> indexer,
      Value<Decimal> rate,
      Value<Decimal?> spread,
      Value<String> dayCount,
      Value<String> issueDate,
      Value<String> maturityDate,
      Value<String?> graceUntil,
      Value<String> liquidity,
      Value<String> taxRegime,
      Value<String?> costsNotes,
      Value<int> rowid,
    });

final class $$FixedIncomeTermsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $FixedIncomeTermsTable,
          FixedIncomeTermsRow
        > {
  $$FixedIncomeTermsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AssetsTable _assetIdTable(_$AppDatabase db) =>
      db.assets.createAlias('fixed_income_terms__asset_id__assets__id');

  $$AssetsTableProcessedTableManager get assetId {
    final $_column = $_itemColumn<String>('asset_id')!;

    final manager = $$AssetsTableTableManager(
      $_db,
      $_db.assets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FixedIncomeTermsTableFilterComposer
    extends Composer<_$AppDatabase, $FixedIncomeTermsTable> {
  $$FixedIncomeTermsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get product => $composableBuilder(
    column: $table.product,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get issuer => $composableBuilder(
    column: $table.issuer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get indexer => $composableBuilder(
    column: $table.indexer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal, Decimal, String> get rate =>
      $composableBuilder(
        column: $table.rate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get spread =>
      $composableBuilder(
        column: $table.spread,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get dayCount => $composableBuilder(
    column: $table.dayCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get issueDate => $composableBuilder(
    column: $table.issueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get maturityDate => $composableBuilder(
    column: $table.maturityDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get graceUntil => $composableBuilder(
    column: $table.graceUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get liquidity => $composableBuilder(
    column: $table.liquidity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxRegime => $composableBuilder(
    column: $table.taxRegime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get costsNotes => $composableBuilder(
    column: $table.costsNotes,
    builder: (column) => ColumnFilters(column),
  );

  $$AssetsTableFilterComposer get assetId {
    final $$AssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableFilterComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FixedIncomeTermsTableOrderingComposer
    extends Composer<_$AppDatabase, $FixedIncomeTermsTable> {
  $$FixedIncomeTermsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get product => $composableBuilder(
    column: $table.product,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get issuer => $composableBuilder(
    column: $table.issuer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get indexer => $composableBuilder(
    column: $table.indexer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spread => $composableBuilder(
    column: $table.spread,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayCount => $composableBuilder(
    column: $table.dayCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get issueDate => $composableBuilder(
    column: $table.issueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get maturityDate => $composableBuilder(
    column: $table.maturityDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get graceUntil => $composableBuilder(
    column: $table.graceUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get liquidity => $composableBuilder(
    column: $table.liquidity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxRegime => $composableBuilder(
    column: $table.taxRegime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get costsNotes => $composableBuilder(
    column: $table.costsNotes,
    builder: (column) => ColumnOrderings(column),
  );

  $$AssetsTableOrderingComposer get assetId {
    final $$AssetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableOrderingComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FixedIncomeTermsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FixedIncomeTermsTable> {
  $$FixedIncomeTermsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get product =>
      $composableBuilder(column: $table.product, builder: (column) => column);

  GeneratedColumn<String> get issuer =>
      $composableBuilder(column: $table.issuer, builder: (column) => column);

  GeneratedColumn<String> get indexer =>
      $composableBuilder(column: $table.indexer, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal, String> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get spread =>
      $composableBuilder(column: $table.spread, builder: (column) => column);

  GeneratedColumn<String> get dayCount =>
      $composableBuilder(column: $table.dayCount, builder: (column) => column);

  GeneratedColumn<String> get issueDate =>
      $composableBuilder(column: $table.issueDate, builder: (column) => column);

  GeneratedColumn<String> get maturityDate => $composableBuilder(
    column: $table.maturityDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get graceUntil => $composableBuilder(
    column: $table.graceUntil,
    builder: (column) => column,
  );

  GeneratedColumn<String> get liquidity =>
      $composableBuilder(column: $table.liquidity, builder: (column) => column);

  GeneratedColumn<String> get taxRegime =>
      $composableBuilder(column: $table.taxRegime, builder: (column) => column);

  GeneratedColumn<String> get costsNotes => $composableBuilder(
    column: $table.costsNotes,
    builder: (column) => column,
  );

  $$AssetsTableAnnotationComposer get assetId {
    final $$AssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FixedIncomeTermsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FixedIncomeTermsTable,
          FixedIncomeTermsRow,
          $$FixedIncomeTermsTableFilterComposer,
          $$FixedIncomeTermsTableOrderingComposer,
          $$FixedIncomeTermsTableAnnotationComposer,
          $$FixedIncomeTermsTableCreateCompanionBuilder,
          $$FixedIncomeTermsTableUpdateCompanionBuilder,
          (FixedIncomeTermsRow, $$FixedIncomeTermsTableReferences),
          FixedIncomeTermsRow,
          PrefetchHooks Function({bool assetId})
        > {
  $$FixedIncomeTermsTableTableManager(
    _$AppDatabase db,
    $FixedIncomeTermsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FixedIncomeTermsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FixedIncomeTermsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FixedIncomeTermsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> assetId = const Value.absent(),
                Value<String> product = const Value.absent(),
                Value<String?> issuer = const Value.absent(),
                Value<String> indexer = const Value.absent(),
                Value<Decimal> rate = const Value.absent(),
                Value<Decimal?> spread = const Value.absent(),
                Value<String> dayCount = const Value.absent(),
                Value<String> issueDate = const Value.absent(),
                Value<String> maturityDate = const Value.absent(),
                Value<String?> graceUntil = const Value.absent(),
                Value<String> liquidity = const Value.absent(),
                Value<String> taxRegime = const Value.absent(),
                Value<String?> costsNotes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FixedIncomeTermsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hlc: hlc,
                deviceId: deviceId,
                deletedAt: deletedAt,
                assetId: assetId,
                product: product,
                issuer: issuer,
                indexer: indexer,
                rate: rate,
                spread: spread,
                dayCount: dayCount,
                issueDate: issueDate,
                maturityDate: maturityDate,
                graceUntil: graceUntil,
                liquidity: liquidity,
                taxRegime: taxRegime,
                costsNotes: costsNotes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                required String hlc,
                required String deviceId,
                Value<String?> deletedAt = const Value.absent(),
                required String assetId,
                required String product,
                Value<String?> issuer = const Value.absent(),
                required String indexer,
                required Decimal rate,
                Value<Decimal?> spread = const Value.absent(),
                required String dayCount,
                required String issueDate,
                required String maturityDate,
                Value<String?> graceUntil = const Value.absent(),
                required String liquidity,
                required String taxRegime,
                Value<String?> costsNotes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FixedIncomeTermsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hlc: hlc,
                deviceId: deviceId,
                deletedAt: deletedAt,
                assetId: assetId,
                product: product,
                issuer: issuer,
                indexer: indexer,
                rate: rate,
                spread: spread,
                dayCount: dayCount,
                issueDate: issueDate,
                maturityDate: maturityDate,
                graceUntil: graceUntil,
                liquidity: liquidity,
                taxRegime: taxRegime,
                costsNotes: costsNotes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FixedIncomeTermsTable, FixedIncomeTermsRow>(
                    table,
                  ),
                  $$FixedIncomeTermsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({assetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (assetId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.assetId,
                        referencedTable: $$FixedIncomeTermsTableReferences
                            ._assetIdTable(db),
                        referencedColumn: $$FixedIncomeTermsTableReferences
                            ._assetIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FixedIncomeTermsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FixedIncomeTermsTable,
      FixedIncomeTermsRow,
      $$FixedIncomeTermsTableFilterComposer,
      $$FixedIncomeTermsTableOrderingComposer,
      $$FixedIncomeTermsTableAnnotationComposer,
      $$FixedIncomeTermsTableCreateCompanionBuilder,
      $$FixedIncomeTermsTableUpdateCompanionBuilder,
      (FixedIncomeTermsRow, $$FixedIncomeTermsTableReferences),
      FixedIncomeTermsRow,
      PrefetchHooks Function({bool assetId})
    >;
typedef $$OperationsTableCreateCompanionBuilder = OperationsCompanion Function({
  required String id,
  required String createdAt,
  required String updatedAt,
  required String hlc,
  required String deviceId,
  Value<String?> deletedAt,
  required String accountId,
  Value<String?> assetId,
  required String type,
  required String tradeDate,
  Value<String?> settlementDate,
  Value<Decimal?> quantity,
  Value<Decimal?> unitPrice,
  Value<Decimal?> grossAmount,
  required Decimal fees,
  required Decimal taxes,
  required String currency,
  Value<Decimal?> fxRate,
  Value<Decimal?> ratioFrom,
  Value<Decimal?> ratioTo,
  Value<String?> transferGroupId,
  Value<String?> relatedOperationId,
  Value<String?> justification,
  Value<String?> notes,
  required String origin,
  Value<int> rowid,
});
typedef $$OperationsTableUpdateCompanionBuilder = OperationsCompanion Function({
  Value<String> id,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String> hlc,
  Value<String> deviceId,
  Value<String?> deletedAt,
  Value<String> accountId,
  Value<String?> assetId,
  Value<String> type,
  Value<String> tradeDate,
  Value<String?> settlementDate,
  Value<Decimal?> quantity,
  Value<Decimal?> unitPrice,
  Value<Decimal?> grossAmount,
  Value<Decimal> fees,
  Value<Decimal> taxes,
  Value<String> currency,
  Value<Decimal?> fxRate,
  Value<Decimal?> ratioFrom,
  Value<Decimal?> ratioTo,
  Value<String?> transferGroupId,
  Value<String?> relatedOperationId,
  Value<String?> justification,
  Value<String?> notes,
  Value<String> origin,
  Value<int> rowid,
});

final class $$OperationsTableReferences
    extends BaseReferences<_$AppDatabase, $OperationsTable, OperationRow> {
  $$OperationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('operations__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AssetsTable _assetIdTable(_$AppDatabase db) =>
      db.assets.createAlias('operations__asset_id__assets__id');

  $$AssetsTableProcessedTableManager? get assetId {
    final $_column = $_itemColumn<String>('asset_id');
    if ($_column == null) return null;
    final manager = $$AssetsTableTableManager(
      $_db,
      $_db.assets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $OperationsTable _relatedOperationIdTable(_$AppDatabase db) => db
      .operations
      .createAlias('operations__related_operation_id__operations__id');

  $$OperationsTableProcessedTableManager? get relatedOperationId {
    final $_column = $_itemColumn<String>('related_operation_id');
    if ($_column == null) return null;
    final manager = $$OperationsTableTableManager(
      $_db,
      $_db.operations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_relatedOperationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OperationsTableFilterComposer
    extends Composer<_$AppDatabase, $OperationsTable> {
  $$OperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tradeDate => $composableBuilder(
    column: $table.tradeDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settlementDate => $composableBuilder(
    column: $table.settlementDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get quantity =>
      $composableBuilder(
        column: $table.quantity,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get unitPrice =>
      $composableBuilder(
        column: $table.unitPrice,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get grossAmount =>
      $composableBuilder(
        column: $table.grossAmount,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal, Decimal, String> get fees =>
      $composableBuilder(
        column: $table.fees,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal, Decimal, String> get taxes =>
      $composableBuilder(
        column: $table.taxes,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get fxRate =>
      $composableBuilder(
        column: $table.fxRate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get ratioFrom =>
      $composableBuilder(
        column: $table.ratioFrom,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get ratioTo =>
      $composableBuilder(
        column: $table.ratioTo,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get transferGroupId => $composableBuilder(
    column: $table.transferGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get justification => $composableBuilder(
    column: $table.justification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetsTableFilterComposer get assetId {
    final $$AssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableFilterComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OperationsTableFilterComposer get relatedOperationId {
    final $$OperationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.relatedOperationId,
      referencedTable: $db.operations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationsTableFilterComposer(
            $db: $db,
            $table: $db.operations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OperationsTableOrderingComposer
    extends Composer<_$AppDatabase, $OperationsTable> {
  $$OperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tradeDate => $composableBuilder(
    column: $table.tradeDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settlementDate => $composableBuilder(
    column: $table.settlementDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grossAmount => $composableBuilder(
    column: $table.grossAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fees => $composableBuilder(
    column: $table.fees,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxes => $composableBuilder(
    column: $table.taxes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fxRate => $composableBuilder(
    column: $table.fxRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ratioFrom => $composableBuilder(
    column: $table.ratioFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ratioTo => $composableBuilder(
    column: $table.ratioTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transferGroupId => $composableBuilder(
    column: $table.transferGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get justification => $composableBuilder(
    column: $table.justification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetsTableOrderingComposer get assetId {
    final $$AssetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableOrderingComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OperationsTableOrderingComposer get relatedOperationId {
    final $$OperationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.relatedOperationId,
      referencedTable: $db.operations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationsTableOrderingComposer(
            $db: $db,
            $table: $db.operations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OperationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OperationsTable> {
  $$OperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get tradeDate =>
      $composableBuilder(column: $table.tradeDate, builder: (column) => column);

  GeneratedColumn<String> get settlementDate => $composableBuilder(
    column: $table.settlementDate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Decimal?, String> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get grossAmount =>
      $composableBuilder(
        column: $table.grossAmount,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Decimal, String> get fees =>
      $composableBuilder(column: $table.fees, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal, String> get taxes =>
      $composableBuilder(column: $table.taxes, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get fxRate =>
      $composableBuilder(column: $table.fxRate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get ratioFrom =>
      $composableBuilder(column: $table.ratioFrom, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get ratioTo =>
      $composableBuilder(column: $table.ratioTo, builder: (column) => column);

  GeneratedColumn<String> get transferGroupId => $composableBuilder(
    column: $table.transferGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get justification => $composableBuilder(
    column: $table.justification,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetsTableAnnotationComposer get assetId {
    final $$AssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OperationsTableAnnotationComposer get relatedOperationId {
    final $$OperationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.relatedOperationId,
      referencedTable: $db.operations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationsTableAnnotationComposer(
            $db: $db,
            $table: $db.operations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OperationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OperationsTable,
          OperationRow,
          $$OperationsTableFilterComposer,
          $$OperationsTableOrderingComposer,
          $$OperationsTableAnnotationComposer,
          $$OperationsTableCreateCompanionBuilder,
          $$OperationsTableUpdateCompanionBuilder,
          (OperationRow, $$OperationsTableReferences),
          OperationRow,
          PrefetchHooks Function({
            bool accountId,
            bool assetId,
            bool relatedOperationId,
          })
        > {
  $$OperationsTableTableManager(_$AppDatabase db, $OperationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OperationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String?> assetId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> tradeDate = const Value.absent(),
                Value<String?> settlementDate = const Value.absent(),
                Value<Decimal?> quantity = const Value.absent(),
                Value<Decimal?> unitPrice = const Value.absent(),
                Value<Decimal?> grossAmount = const Value.absent(),
                Value<Decimal> fees = const Value.absent(),
                Value<Decimal> taxes = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<Decimal?> fxRate = const Value.absent(),
                Value<Decimal?> ratioFrom = const Value.absent(),
                Value<Decimal?> ratioTo = const Value.absent(),
                Value<String?> transferGroupId = const Value.absent(),
                Value<String?> relatedOperationId = const Value.absent(),
                Value<String?> justification = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OperationsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hlc: hlc,
                deviceId: deviceId,
                deletedAt: deletedAt,
                accountId: accountId,
                assetId: assetId,
                type: type,
                tradeDate: tradeDate,
                settlementDate: settlementDate,
                quantity: quantity,
                unitPrice: unitPrice,
                grossAmount: grossAmount,
                fees: fees,
                taxes: taxes,
                currency: currency,
                fxRate: fxRate,
                ratioFrom: ratioFrom,
                ratioTo: ratioTo,
                transferGroupId: transferGroupId,
                relatedOperationId: relatedOperationId,
                justification: justification,
                notes: notes,
                origin: origin,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                required String hlc,
                required String deviceId,
                Value<String?> deletedAt = const Value.absent(),
                required String accountId,
                Value<String?> assetId = const Value.absent(),
                required String type,
                required String tradeDate,
                Value<String?> settlementDate = const Value.absent(),
                Value<Decimal?> quantity = const Value.absent(),
                Value<Decimal?> unitPrice = const Value.absent(),
                Value<Decimal?> grossAmount = const Value.absent(),
                required Decimal fees,
                required Decimal taxes,
                required String currency,
                Value<Decimal?> fxRate = const Value.absent(),
                Value<Decimal?> ratioFrom = const Value.absent(),
                Value<Decimal?> ratioTo = const Value.absent(),
                Value<String?> transferGroupId = const Value.absent(),
                Value<String?> relatedOperationId = const Value.absent(),
                Value<String?> justification = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String origin,
                Value<int> rowid = const Value.absent(),
              }) => OperationsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hlc: hlc,
                deviceId: deviceId,
                deletedAt: deletedAt,
                accountId: accountId,
                assetId: assetId,
                type: type,
                tradeDate: tradeDate,
                settlementDate: settlementDate,
                quantity: quantity,
                unitPrice: unitPrice,
                grossAmount: grossAmount,
                fees: fees,
                taxes: taxes,
                currency: currency,
                fxRate: fxRate,
                ratioFrom: ratioFrom,
                ratioTo: ratioTo,
                transferGroupId: transferGroupId,
                relatedOperationId: relatedOperationId,
                justification: justification,
                notes: notes,
                origin: origin,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OperationsTable, OperationRow>(table),
                  $$OperationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                accountId = false,
                assetId = false,
                relatedOperationId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (accountId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.accountId,
                            referencedTable: $$OperationsTableReferences
                                ._accountIdTable(db),
                            referencedColumn: $$OperationsTableReferences
                                ._accountIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (assetId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.assetId,
                            referencedTable: $$OperationsTableReferences
                                ._assetIdTable(db),
                            referencedColumn: $$OperationsTableReferences
                                ._assetIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (relatedOperationId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.relatedOperationId,
                            referencedTable: $$OperationsTableReferences
                                ._relatedOperationIdTable(db),
                            referencedColumn: $$OperationsTableReferences
                                ._relatedOperationIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$OperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OperationsTable,
      OperationRow,
      $$OperationsTableFilterComposer,
      $$OperationsTableOrderingComposer,
      $$OperationsTableAnnotationComposer,
      $$OperationsTableCreateCompanionBuilder,
      $$OperationsTableUpdateCompanionBuilder,
      (OperationRow, $$OperationsTableReferences),
      OperationRow,
      PrefetchHooks Function({
        bool accountId,
        bool assetId,
        bool relatedOperationId,
      })
    >;
typedef $$ManualValuationsTableCreateCompanionBuilder =
    ManualValuationsCompanion Function({
      required String id,
      required String createdAt,
      required String updatedAt,
      required String hlc,
      required String deviceId,
      Value<String?> deletedAt,
      required String assetId,
      Value<String?> accountId,
      required String refDate,
      required String kind,
      required Decimal value,
      required String currency,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$ManualValuationsTableUpdateCompanionBuilder =
    ManualValuationsCompanion Function({
      Value<String> id,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String> hlc,
      Value<String> deviceId,
      Value<String?> deletedAt,
      Value<String> assetId,
      Value<String?> accountId,
      Value<String> refDate,
      Value<String> kind,
      Value<Decimal> value,
      Value<String> currency,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$ManualValuationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ManualValuationsTable,
          ManualValuationRow
        > {
  $$ManualValuationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AssetsTable _assetIdTable(_$AppDatabase db) =>
      db.assets.createAlias('manual_valuations__asset_id__assets__id');

  $$AssetsTableProcessedTableManager get assetId {
    final $_column = $_itemColumn<String>('asset_id')!;

    final manager = $$AssetsTableTableManager(
      $_db,
      $_db.assets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('manual_valuations__account_id__accounts__id');

  $$AccountsTableProcessedTableManager? get accountId {
    final $_column = $_itemColumn<String>('account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ManualValuationsTableFilterComposer
    extends Composer<_$AppDatabase, $ManualValuationsTable> {
  $$ManualValuationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refDate => $composableBuilder(
    column: $table.refDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal, Decimal, String> get value =>
      $composableBuilder(
        column: $table.value,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$AssetsTableFilterComposer get assetId {
    final $$AssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableFilterComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ManualValuationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ManualValuationsTable> {
  $$ManualValuationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refDate => $composableBuilder(
    column: $table.refDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$AssetsTableOrderingComposer get assetId {
    final $$AssetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableOrderingComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ManualValuationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ManualValuationsTable> {
  $$ManualValuationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get refDate =>
      $composableBuilder(column: $table.refDate, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal, String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$AssetsTableAnnotationComposer get assetId {
    final $$AssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ManualValuationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ManualValuationsTable,
          ManualValuationRow,
          $$ManualValuationsTableFilterComposer,
          $$ManualValuationsTableOrderingComposer,
          $$ManualValuationsTableAnnotationComposer,
          $$ManualValuationsTableCreateCompanionBuilder,
          $$ManualValuationsTableUpdateCompanionBuilder,
          (ManualValuationRow, $$ManualValuationsTableReferences),
          ManualValuationRow,
          PrefetchHooks Function({bool assetId, bool accountId})
        > {
  $$ManualValuationsTableTableManager(
    _$AppDatabase db,
    $ManualValuationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ManualValuationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ManualValuationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ManualValuationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> assetId = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<String> refDate = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<Decimal> value = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ManualValuationsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hlc: hlc,
                deviceId: deviceId,
                deletedAt: deletedAt,
                assetId: assetId,
                accountId: accountId,
                refDate: refDate,
                kind: kind,
                value: value,
                currency: currency,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                required String hlc,
                required String deviceId,
                Value<String?> deletedAt = const Value.absent(),
                required String assetId,
                Value<String?> accountId = const Value.absent(),
                required String refDate,
                required String kind,
                required Decimal value,
                required String currency,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ManualValuationsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hlc: hlc,
                deviceId: deviceId,
                deletedAt: deletedAt,
                assetId: assetId,
                accountId: accountId,
                refDate: refDate,
                kind: kind,
                value: value,
                currency: currency,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ManualValuationsTable, ManualValuationRow>(
                    table,
                  ),
                  $$ManualValuationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({assetId = false, accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (assetId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.assetId,
                        referencedTable: $$ManualValuationsTableReferences
                            ._assetIdTable(db),
                        referencedColumn: $$ManualValuationsTableReferences
                            ._assetIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable: $$ManualValuationsTableReferences
                            ._accountIdTable(db),
                        referencedColumn: $$ManualValuationsTableReferences
                            ._accountIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ManualValuationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ManualValuationsTable,
      ManualValuationRow,
      $$ManualValuationsTableFilterComposer,
      $$ManualValuationsTableOrderingComposer,
      $$ManualValuationsTableAnnotationComposer,
      $$ManualValuationsTableCreateCompanionBuilder,
      $$ManualValuationsTableUpdateCompanionBuilder,
      (ManualValuationRow, $$ManualValuationsTableReferences),
      ManualValuationRow,
      PrefetchHooks Function({bool assetId, bool accountId})
    >;
typedef $$AssetAliasesTableCreateCompanionBuilder =
    AssetAliasesCompanion Function({
      required String id,
      required String createdAt,
      required String updatedAt,
      required String hlc,
      required String deviceId,
      Value<String?> deletedAt,
      required String entity,
      required String aliasId,
      required String canonicalId,
      Value<int> rowid,
    });
typedef $$AssetAliasesTableUpdateCompanionBuilder =
    AssetAliasesCompanion Function({
      Value<String> id,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String> hlc,
      Value<String> deviceId,
      Value<String?> deletedAt,
      Value<String> entity,
      Value<String> aliasId,
      Value<String> canonicalId,
      Value<int> rowid,
    });

class $$AssetAliasesTableFilterComposer
    extends Composer<_$AppDatabase, $AssetAliasesTable> {
  $$AssetAliasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aliasId => $composableBuilder(
    column: $table.aliasId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get canonicalId => $composableBuilder(
    column: $table.canonicalId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AssetAliasesTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetAliasesTable> {
  $$AssetAliasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aliasId => $composableBuilder(
    column: $table.aliasId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get canonicalId => $composableBuilder(
    column: $table.canonicalId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssetAliasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetAliasesTable> {
  $$AssetAliasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get aliasId =>
      $composableBuilder(column: $table.aliasId, builder: (column) => column);

  GeneratedColumn<String> get canonicalId => $composableBuilder(
    column: $table.canonicalId,
    builder: (column) => column,
  );
}

class $$AssetAliasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssetAliasesTable,
          AssetAliasRow,
          $$AssetAliasesTableFilterComposer,
          $$AssetAliasesTableOrderingComposer,
          $$AssetAliasesTableAnnotationComposer,
          $$AssetAliasesTableCreateCompanionBuilder,
          $$AssetAliasesTableUpdateCompanionBuilder,
          (
            AssetAliasRow,
            BaseReferences<_$AppDatabase, $AssetAliasesTable, AssetAliasRow>,
          ),
          AssetAliasRow,
          PrefetchHooks Function()
        > {
  $$AssetAliasesTableTableManager(_$AppDatabase db, $AssetAliasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetAliasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetAliasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetAliasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> aliasId = const Value.absent(),
                Value<String> canonicalId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssetAliasesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hlc: hlc,
                deviceId: deviceId,
                deletedAt: deletedAt,
                entity: entity,
                aliasId: aliasId,
                canonicalId: canonicalId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                required String hlc,
                required String deviceId,
                Value<String?> deletedAt = const Value.absent(),
                required String entity,
                required String aliasId,
                required String canonicalId,
                Value<int> rowid = const Value.absent(),
              }) => AssetAliasesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hlc: hlc,
                deviceId: deviceId,
                deletedAt: deletedAt,
                entity: entity,
                aliasId: aliasId,
                canonicalId: canonicalId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AssetAliasesTable, AssetAliasRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AssetAliasesTable,
                    AssetAliasRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssetAliasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssetAliasesTable,
      AssetAliasRow,
      $$AssetAliasesTableFilterComposer,
      $$AssetAliasesTableOrderingComposer,
      $$AssetAliasesTableAnnotationComposer,
      $$AssetAliasesTableCreateCompanionBuilder,
      $$AssetAliasesTableUpdateCompanionBuilder,
      (
        AssetAliasRow,
        BaseReferences<_$AppDatabase, $AssetAliasesTable, AssetAliasRow>,
      ),
      AssetAliasRow,
      PrefetchHooks Function()
    >;
typedef $$HypoPortfoliosTableCreateCompanionBuilder =
    HypoPortfoliosCompanion Function({
      required String id,
      required String createdAt,
      required String updatedAt,
      required String hlc,
      required String deviceId,
      Value<String?> deletedAt,
      required String name,
      Value<String?> description,
      Value<String?> objective,
      required String startDate,
      required String baseCurrency,
      required Decimal initialCapital,
      required String compositionMode,
      Value<String?> benchmarkJson,
      required String rebalanceJson,
      required String assumptionsJson,
      Value<String?> methodology,
      Value<String?> archivedAt,
      Value<String?> duplicatedFromId,
      Value<int> rowid,
    });
typedef $$HypoPortfoliosTableUpdateCompanionBuilder =
    HypoPortfoliosCompanion Function({
      Value<String> id,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String> hlc,
      Value<String> deviceId,
      Value<String?> deletedAt,
      Value<String> name,
      Value<String?> description,
      Value<String?> objective,
      Value<String> startDate,
      Value<String> baseCurrency,
      Value<Decimal> initialCapital,
      Value<String> compositionMode,
      Value<String?> benchmarkJson,
      Value<String> rebalanceJson,
      Value<String> assumptionsJson,
      Value<String?> methodology,
      Value<String?> archivedAt,
      Value<String?> duplicatedFromId,
      Value<int> rowid,
    });

final class $$HypoPortfoliosTableReferences
    extends
        BaseReferences<_$AppDatabase, $HypoPortfoliosTable, HypoPortfolioRow> {
  $$HypoPortfoliosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$HypoHoldingsTable, List<HypoHoldingRow>>
  _hypoHoldingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.hypoHoldings,
    aliasName: 'hypo_portfolios__id__hypo_holdings__portfolio_id',
  );

  $$HypoHoldingsTableProcessedTableManager get hypoHoldingsRefs {
    final manager = $$HypoHoldingsTableTableManager(
      $_db,
      $_db.hypoHoldings,
    ).filter((f) => f.portfolioId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_hypoHoldingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HypoCashflowRulesTable, List<HypoCashflowRuleRow>>
  _hypoCashflowRulesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.hypoCashflowRules,
        aliasName: 'hypo_portfolios__id__hypo_cashflow_rules__portfolio_id',
      );

  $$HypoCashflowRulesTableProcessedTableManager get hypoCashflowRulesRefs {
    final manager = $$HypoCashflowRulesTableTableManager(
      $_db,
      $_db.hypoCashflowRules,
    ).filter((f) => f.portfolioId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _hypoCashflowRulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HypoScenariosTable, List<HypoScenarioRow>>
  _hypoScenariosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.hypoScenarios,
    aliasName: 'hypo_portfolios__id__hypo_scenarios__portfolio_id',
  );

  $$HypoScenariosTableProcessedTableManager get hypoScenariosRefs {
    final manager = $$HypoScenariosTableTableManager(
      $_db,
      $_db.hypoScenarios,
    ).filter((f) => f.portfolioId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_hypoScenariosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HypoPortfoliosTableFilterComposer
    extends Composer<_$AppDatabase, $HypoPortfoliosTable> {
  $$HypoPortfoliosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get objective => $composableBuilder(
    column: $table.objective,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal, Decimal, String> get initialCapital =>
      $composableBuilder(
        column: $table.initialCapital,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get compositionMode => $composableBuilder(
    column: $table.compositionMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get benchmarkJson => $composableBuilder(
    column: $table.benchmarkJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rebalanceJson => $composableBuilder(
    column: $table.rebalanceJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assumptionsJson => $composableBuilder(
    column: $table.assumptionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get methodology => $composableBuilder(
    column: $table.methodology,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get duplicatedFromId => $composableBuilder(
    column: $table.duplicatedFromId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> hypoHoldingsRefs(
    Expression<bool> Function($$HypoHoldingsTableFilterComposer f) f,
  ) {
    final $$HypoHoldingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hypoHoldings,
      getReferencedColumn: (t) => t.portfolioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HypoHoldingsTableFilterComposer(
            $db: $db,
            $table: $db.hypoHoldings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> hypoCashflowRulesRefs(
    Expression<bool> Function($$HypoCashflowRulesTableFilterComposer f) f,
  ) {
    final $$HypoCashflowRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hypoCashflowRules,
      getReferencedColumn: (t) => t.portfolioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HypoCashflowRulesTableFilterComposer(
            $db: $db,
            $table: $db.hypoCashflowRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> hypoScenariosRefs(
    Expression<bool> Function($$HypoScenariosTableFilterComposer f) f,
  ) {
    final $$HypoScenariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hypoScenarios,
      getReferencedColumn: (t) => t.portfolioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HypoScenariosTableFilterComposer(
            $db: $db,
            $table: $db.hypoScenarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HypoPortfoliosTableOrderingComposer
    extends Composer<_$AppDatabase, $HypoPortfoliosTable> {
  $$HypoPortfoliosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get objective => $composableBuilder(
    column: $table.objective,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get initialCapital => $composableBuilder(
    column: $table.initialCapital,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get compositionMode => $composableBuilder(
    column: $table.compositionMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get benchmarkJson => $composableBuilder(
    column: $table.benchmarkJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rebalanceJson => $composableBuilder(
    column: $table.rebalanceJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assumptionsJson => $composableBuilder(
    column: $table.assumptionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get methodology => $composableBuilder(
    column: $table.methodology,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get duplicatedFromId => $composableBuilder(
    column: $table.duplicatedFromId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HypoPortfoliosTableAnnotationComposer
    extends Composer<_$AppDatabase, $HypoPortfoliosTable> {
  $$HypoPortfoliosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get objective =>
      $composableBuilder(column: $table.objective, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Decimal, String> get initialCapital =>
      $composableBuilder(
        column: $table.initialCapital,
        builder: (column) => column,
      );

  GeneratedColumn<String> get compositionMode => $composableBuilder(
    column: $table.compositionMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get benchmarkJson => $composableBuilder(
    column: $table.benchmarkJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rebalanceJson => $composableBuilder(
    column: $table.rebalanceJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assumptionsJson => $composableBuilder(
    column: $table.assumptionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get methodology => $composableBuilder(
    column: $table.methodology,
    builder: (column) => column,
  );

  GeneratedColumn<String> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get duplicatedFromId => $composableBuilder(
    column: $table.duplicatedFromId,
    builder: (column) => column,
  );

  Expression<T> hypoHoldingsRefs<T extends Object>(
    Expression<T> Function($$HypoHoldingsTableAnnotationComposer a) f,
  ) {
    final $$HypoHoldingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hypoHoldings,
      getReferencedColumn: (t) => t.portfolioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HypoHoldingsTableAnnotationComposer(
            $db: $db,
            $table: $db.hypoHoldings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> hypoCashflowRulesRefs<T extends Object>(
    Expression<T> Function($$HypoCashflowRulesTableAnnotationComposer a) f,
  ) {
    final $$HypoCashflowRulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.hypoCashflowRules,
          getReferencedColumn: (t) => t.portfolioId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HypoCashflowRulesTableAnnotationComposer(
                $db: $db,
                $table: $db.hypoCashflowRules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> hypoScenariosRefs<T extends Object>(
    Expression<T> Function($$HypoScenariosTableAnnotationComposer a) f,
  ) {
    final $$HypoScenariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hypoScenarios,
      getReferencedColumn: (t) => t.portfolioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HypoScenariosTableAnnotationComposer(
            $db: $db,
            $table: $db.hypoScenarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HypoPortfoliosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HypoPortfoliosTable,
          HypoPortfolioRow,
          $$HypoPortfoliosTableFilterComposer,
          $$HypoPortfoliosTableOrderingComposer,
          $$HypoPortfoliosTableAnnotationComposer,
          $$HypoPortfoliosTableCreateCompanionBuilder,
          $$HypoPortfoliosTableUpdateCompanionBuilder,
          (HypoPortfolioRow, $$HypoPortfoliosTableReferences),
          HypoPortfolioRow,
          PrefetchHooks Function({
            bool hypoHoldingsRefs,
            bool hypoCashflowRulesRefs,
            bool hypoScenariosRefs,
          })
        > {
  $$HypoPortfoliosTableTableManager(
    _$AppDatabase db,
    $HypoPortfoliosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HypoPortfoliosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HypoPortfoliosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HypoPortfoliosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> objective = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<String> baseCurrency = const Value.absent(),
                Value<Decimal> initialCapital = const Value.absent(),
                Value<String> compositionMode = const Value.absent(),
                Value<String?> benchmarkJson = const Value.absent(),
                Value<String> rebalanceJson = const Value.absent(),
                Value<String> assumptionsJson = const Value.absent(),
                Value<String?> methodology = const Value.absent(),
                Value<String?> archivedAt = const Value.absent(),
                Value<String?> duplicatedFromId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HypoPortfoliosCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hlc: hlc,
                deviceId: deviceId,
                deletedAt: deletedAt,
                name: name,
                description: description,
                objective: objective,
                startDate: startDate,
                baseCurrency: baseCurrency,
                initialCapital: initialCapital,
                compositionMode: compositionMode,
                benchmarkJson: benchmarkJson,
                rebalanceJson: rebalanceJson,
                assumptionsJson: assumptionsJson,
                methodology: methodology,
                archivedAt: archivedAt,
                duplicatedFromId: duplicatedFromId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                required String hlc,
                required String deviceId,
                Value<String?> deletedAt = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> objective = const Value.absent(),
                required String startDate,
                required String baseCurrency,
                required Decimal initialCapital,
                required String compositionMode,
                Value<String?> benchmarkJson = const Value.absent(),
                required String rebalanceJson,
                required String assumptionsJson,
                Value<String?> methodology = const Value.absent(),
                Value<String?> archivedAt = const Value.absent(),
                Value<String?> duplicatedFromId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HypoPortfoliosCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hlc: hlc,
                deviceId: deviceId,
                deletedAt: deletedAt,
                name: name,
                description: description,
                objective: objective,
                startDate: startDate,
                baseCurrency: baseCurrency,
                initialCapital: initialCapital,
                compositionMode: compositionMode,
                benchmarkJson: benchmarkJson,
                rebalanceJson: rebalanceJson,
                assumptionsJson: assumptionsJson,
                methodology: methodology,
                archivedAt: archivedAt,
                duplicatedFromId: duplicatedFromId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HypoPortfoliosTable, HypoPortfolioRow>(table),
                  $$HypoPortfoliosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                hypoHoldingsRefs = false,
                hypoCashflowRulesRefs = false,
                hypoScenariosRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (hypoHoldingsRefs) db.hypoHoldings,
                    if (hypoCashflowRulesRefs) db.hypoCashflowRules,
                    if (hypoScenariosRefs) db.hypoScenarios,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (hypoHoldingsRefs)
                        await $_getPrefetchedData<
                          HypoPortfolioRow,
                          $HypoPortfoliosTable,
                          HypoHoldingRow
                        >(
                          currentTable: table,
                          referencedTable: $$HypoPortfoliosTableReferences
                              ._hypoHoldingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HypoPortfoliosTableReferences(
                                db,
                                table,
                                p0,
                              ).hypoHoldingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.portfolioId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (hypoCashflowRulesRefs)
                        await $_getPrefetchedData<
                          HypoPortfolioRow,
                          $HypoPortfoliosTable,
                          HypoCashflowRuleRow
                        >(
                          currentTable: table,
                          referencedTable: $$HypoPortfoliosTableReferences
                              ._hypoCashflowRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HypoPortfoliosTableReferences(
                                db,
                                table,
                                p0,
                              ).hypoCashflowRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.portfolioId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (hypoScenariosRefs)
                        await $_getPrefetchedData<
                          HypoPortfolioRow,
                          $HypoPortfoliosTable,
                          HypoScenarioRow
                        >(
                          currentTable: table,
                          referencedTable: $$HypoPortfoliosTableReferences
                              ._hypoScenariosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HypoPortfoliosTableReferences(
                                db,
                                table,
                                p0,
                              ).hypoScenariosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.portfolioId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$HypoPortfoliosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HypoPortfoliosTable,
      HypoPortfolioRow,
      $$HypoPortfoliosTableFilterComposer,
      $$HypoPortfoliosTableOrderingComposer,
      $$HypoPortfoliosTableAnnotationComposer,
      $$HypoPortfoliosTableCreateCompanionBuilder,
      $$HypoPortfoliosTableUpdateCompanionBuilder,
      (HypoPortfolioRow, $$HypoPortfoliosTableReferences),
      HypoPortfolioRow,
      PrefetchHooks Function({
        bool hypoHoldingsRefs,
        bool hypoCashflowRulesRefs,
        bool hypoScenariosRefs,
      })
    >;
typedef $$HypoHoldingsTableCreateCompanionBuilder =
    HypoHoldingsCompanion Function({
      required String id,
      required String createdAt,
      required String updatedAt,
      required String hlc,
      required String deviceId,
      Value<String?> deletedAt,
      required String portfolioId,
      required String assetId,
      Value<Decimal?> weightPct,
      Value<Decimal?> quantity,
      Value<Decimal?> amount,
      Value<int> rowid,
    });
typedef $$HypoHoldingsTableUpdateCompanionBuilder =
    HypoHoldingsCompanion Function({
      Value<String> id,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String> hlc,
      Value<String> deviceId,
      Value<String?> deletedAt,
      Value<String> portfolioId,
      Value<String> assetId,
      Value<Decimal?> weightPct,
      Value<Decimal?> quantity,
      Value<Decimal?> amount,
      Value<int> rowid,
    });

final class $$HypoHoldingsTableReferences
    extends BaseReferences<_$AppDatabase, $HypoHoldingsTable, HypoHoldingRow> {
  $$HypoHoldingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HypoPortfoliosTable _portfolioIdTable(_$AppDatabase db) => db
      .hypoPortfolios
      .createAlias('hypo_holdings__portfolio_id__hypo_portfolios__id');

  $$HypoPortfoliosTableProcessedTableManager get portfolioId {
    final $_column = $_itemColumn<String>('portfolio_id')!;

    final manager = $$HypoPortfoliosTableTableManager(
      $_db,
      $_db.hypoPortfolios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_portfolioIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AssetsTable _assetIdTable(_$AppDatabase db) =>
      db.assets.createAlias('hypo_holdings__asset_id__assets__id');

  $$AssetsTableProcessedTableManager get assetId {
    final $_column = $_itemColumn<String>('asset_id')!;

    final manager = $$AssetsTableTableManager(
      $_db,
      $_db.assets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HypoHoldingsTableFilterComposer
    extends Composer<_$AppDatabase, $HypoHoldingsTable> {
  $$HypoHoldingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get weightPct =>
      $composableBuilder(
        column: $table.weightPct,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get quantity =>
      $composableBuilder(
        column: $table.quantity,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get amount =>
      $composableBuilder(
        column: $table.amount,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$HypoPortfoliosTableFilterComposer get portfolioId {
    final $$HypoPortfoliosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.portfolioId,
      referencedTable: $db.hypoPortfolios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HypoPortfoliosTableFilterComposer(
            $db: $db,
            $table: $db.hypoPortfolios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetsTableFilterComposer get assetId {
    final $$AssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableFilterComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HypoHoldingsTableOrderingComposer
    extends Composer<_$AppDatabase, $HypoHoldingsTable> {
  $$HypoHoldingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weightPct => $composableBuilder(
    column: $table.weightPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  $$HypoPortfoliosTableOrderingComposer get portfolioId {
    final $$HypoPortfoliosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.portfolioId,
      referencedTable: $db.hypoPortfolios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HypoPortfoliosTableOrderingComposer(
            $db: $db,
            $table: $db.hypoPortfolios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetsTableOrderingComposer get assetId {
    final $$AssetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableOrderingComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HypoHoldingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HypoHoldingsTable> {
  $$HypoHoldingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get weightPct =>
      $composableBuilder(column: $table.weightPct, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  $$HypoPortfoliosTableAnnotationComposer get portfolioId {
    final $$HypoPortfoliosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.portfolioId,
      referencedTable: $db.hypoPortfolios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HypoPortfoliosTableAnnotationComposer(
            $db: $db,
            $table: $db.hypoPortfolios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetsTableAnnotationComposer get assetId {
    final $$AssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HypoHoldingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HypoHoldingsTable,
          HypoHoldingRow,
          $$HypoHoldingsTableFilterComposer,
          $$HypoHoldingsTableOrderingComposer,
          $$HypoHoldingsTableAnnotationComposer,
          $$HypoHoldingsTableCreateCompanionBuilder,
          $$HypoHoldingsTableUpdateCompanionBuilder,
          (HypoHoldingRow, $$HypoHoldingsTableReferences),
          HypoHoldingRow,
          PrefetchHooks Function({bool portfolioId, bool assetId})
        > {
  $$HypoHoldingsTableTableManager(_$AppDatabase db, $HypoHoldingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HypoHoldingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HypoHoldingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HypoHoldingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> portfolioId = const Value.absent(),
                Value<String> assetId = const Value.absent(),
                Value<Decimal?> weightPct = const Value.absent(),
                Value<Decimal?> quantity = const Value.absent(),
                Value<Decimal?> amount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HypoHoldingsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hlc: hlc,
                deviceId: deviceId,
                deletedAt: deletedAt,
                portfolioId: portfolioId,
                assetId: assetId,
                weightPct: weightPct,
                quantity: quantity,
                amount: amount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                required String hlc,
                required String deviceId,
                Value<String?> deletedAt = const Value.absent(),
                required String portfolioId,
                required String assetId,
                Value<Decimal?> weightPct = const Value.absent(),
                Value<Decimal?> quantity = const Value.absent(),
                Value<Decimal?> amount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HypoHoldingsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hlc: hlc,
                deviceId: deviceId,
                deletedAt: deletedAt,
                portfolioId: portfolioId,
                assetId: assetId,
                weightPct: weightPct,
                quantity: quantity,
                amount: amount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HypoHoldingsTable, HypoHoldingRow>(table),
                  $$HypoHoldingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({portfolioId = false, assetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (portfolioId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.portfolioId,
                        referencedTable: $$HypoHoldingsTableReferences
                            ._portfolioIdTable(db),
                        referencedColumn: $$HypoHoldingsTableReferences
                            ._portfolioIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (assetId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.assetId,
                        referencedTable: $$HypoHoldingsTableReferences
                            ._assetIdTable(db),
                        referencedColumn: $$HypoHoldingsTableReferences
                            ._assetIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HypoHoldingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HypoHoldingsTable,
      HypoHoldingRow,
      $$HypoHoldingsTableFilterComposer,
      $$HypoHoldingsTableOrderingComposer,
      $$HypoHoldingsTableAnnotationComposer,
      $$HypoHoldingsTableCreateCompanionBuilder,
      $$HypoHoldingsTableUpdateCompanionBuilder,
      (HypoHoldingRow, $$HypoHoldingsTableReferences),
      HypoHoldingRow,
      PrefetchHooks Function({bool portfolioId, bool assetId})
    >;
typedef $$HypoCashflowRulesTableCreateCompanionBuilder =
    HypoCashflowRulesCompanion Function({
      required String id,
      required String createdAt,
      required String updatedAt,
      required String hlc,
      required String deviceId,
      Value<String?> deletedAt,
      required String portfolioId,
      required String kind,
      required String frequency,
      Value<Decimal?> amount,
      Value<Decimal?> pct,
      required String adjustment,
      required String startDate,
      Value<String?> endDate,
      Value<int> rowid,
    });
typedef $$HypoCashflowRulesTableUpdateCompanionBuilder =
    HypoCashflowRulesCompanion Function({
      Value<String> id,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String> hlc,
      Value<String> deviceId,
      Value<String?> deletedAt,
      Value<String> portfolioId,
      Value<String> kind,
      Value<String> frequency,
      Value<Decimal?> amount,
      Value<Decimal?> pct,
      Value<String> adjustment,
      Value<String> startDate,
      Value<String?> endDate,
      Value<int> rowid,
    });

final class $$HypoCashflowRulesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $HypoCashflowRulesTable,
          HypoCashflowRuleRow
        > {
  $$HypoCashflowRulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HypoPortfoliosTable _portfolioIdTable(_$AppDatabase db) => db
      .hypoPortfolios
      .createAlias('hypo_cashflow_rules__portfolio_id__hypo_portfolios__id');

  $$HypoPortfoliosTableProcessedTableManager get portfolioId {
    final $_column = $_itemColumn<String>('portfolio_id')!;

    final manager = $$HypoPortfoliosTableTableManager(
      $_db,
      $_db.hypoPortfolios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_portfolioIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HypoCashflowRulesTableFilterComposer
    extends Composer<_$AppDatabase, $HypoCashflowRulesTable> {
  $$HypoCashflowRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get amount =>
      $composableBuilder(
        column: $table.amount,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get pct =>
      $composableBuilder(
        column: $table.pct,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get adjustment => $composableBuilder(
    column: $table.adjustment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  $$HypoPortfoliosTableFilterComposer get portfolioId {
    final $$HypoPortfoliosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.portfolioId,
      referencedTable: $db.hypoPortfolios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HypoPortfoliosTableFilterComposer(
            $db: $db,
            $table: $db.hypoPortfolios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HypoCashflowRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $HypoCashflowRulesTable> {
  $$HypoCashflowRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pct => $composableBuilder(
    column: $table.pct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adjustment => $composableBuilder(
    column: $table.adjustment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$HypoPortfoliosTableOrderingComposer get portfolioId {
    final $$HypoPortfoliosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.portfolioId,
      referencedTable: $db.hypoPortfolios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HypoPortfoliosTableOrderingComposer(
            $db: $db,
            $table: $db.hypoPortfolios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HypoCashflowRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HypoCashflowRulesTable> {
  $$HypoCashflowRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get pct =>
      $composableBuilder(column: $table.pct, builder: (column) => column);

  GeneratedColumn<String> get adjustment => $composableBuilder(
    column: $table.adjustment,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  $$HypoPortfoliosTableAnnotationComposer get portfolioId {
    final $$HypoPortfoliosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.portfolioId,
      referencedTable: $db.hypoPortfolios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HypoPortfoliosTableAnnotationComposer(
            $db: $db,
            $table: $db.hypoPortfolios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HypoCashflowRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HypoCashflowRulesTable,
          HypoCashflowRuleRow,
          $$HypoCashflowRulesTableFilterComposer,
          $$HypoCashflowRulesTableOrderingComposer,
          $$HypoCashflowRulesTableAnnotationComposer,
          $$HypoCashflowRulesTableCreateCompanionBuilder,
          $$HypoCashflowRulesTableUpdateCompanionBuilder,
          (HypoCashflowRuleRow, $$HypoCashflowRulesTableReferences),
          HypoCashflowRuleRow,
          PrefetchHooks Function({bool portfolioId})
        > {
  $$HypoCashflowRulesTableTableManager(
    _$AppDatabase db,
    $HypoCashflowRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HypoCashflowRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HypoCashflowRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HypoCashflowRulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> portfolioId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<Decimal?> amount = const Value.absent(),
                Value<Decimal?> pct = const Value.absent(),
                Value<String> adjustment = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<String?> endDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HypoCashflowRulesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hlc: hlc,
                deviceId: deviceId,
                deletedAt: deletedAt,
                portfolioId: portfolioId,
                kind: kind,
                frequency: frequency,
                amount: amount,
                pct: pct,
                adjustment: adjustment,
                startDate: startDate,
                endDate: endDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                required String hlc,
                required String deviceId,
                Value<String?> deletedAt = const Value.absent(),
                required String portfolioId,
                required String kind,
                required String frequency,
                Value<Decimal?> amount = const Value.absent(),
                Value<Decimal?> pct = const Value.absent(),
                required String adjustment,
                required String startDate,
                Value<String?> endDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HypoCashflowRulesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hlc: hlc,
                deviceId: deviceId,
                deletedAt: deletedAt,
                portfolioId: portfolioId,
                kind: kind,
                frequency: frequency,
                amount: amount,
                pct: pct,
                adjustment: adjustment,
                startDate: startDate,
                endDate: endDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HypoCashflowRulesTable, HypoCashflowRuleRow>(
                    table,
                  ),
                  $$HypoCashflowRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({portfolioId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (portfolioId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.portfolioId,
                        referencedTable: $$HypoCashflowRulesTableReferences
                            ._portfolioIdTable(db),
                        referencedColumn: $$HypoCashflowRulesTableReferences
                            ._portfolioIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HypoCashflowRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HypoCashflowRulesTable,
      HypoCashflowRuleRow,
      $$HypoCashflowRulesTableFilterComposer,
      $$HypoCashflowRulesTableOrderingComposer,
      $$HypoCashflowRulesTableAnnotationComposer,
      $$HypoCashflowRulesTableCreateCompanionBuilder,
      $$HypoCashflowRulesTableUpdateCompanionBuilder,
      (HypoCashflowRuleRow, $$HypoCashflowRulesTableReferences),
      HypoCashflowRuleRow,
      PrefetchHooks Function({bool portfolioId})
    >;
typedef $$HypoScenariosTableCreateCompanionBuilder =
    HypoScenariosCompanion Function({
      required String id,
      required String createdAt,
      required String updatedAt,
      required String hlc,
      required String deviceId,
      Value<String?> deletedAt,
      Value<String?> portfolioId,
      required String name,
      required String kind,
      required String assumptionsJson,
      Value<int> rowid,
    });
typedef $$HypoScenariosTableUpdateCompanionBuilder =
    HypoScenariosCompanion Function({
      Value<String> id,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String> hlc,
      Value<String> deviceId,
      Value<String?> deletedAt,
      Value<String?> portfolioId,
      Value<String> name,
      Value<String> kind,
      Value<String> assumptionsJson,
      Value<int> rowid,
    });

final class $$HypoScenariosTableReferences
    extends
        BaseReferences<_$AppDatabase, $HypoScenariosTable, HypoScenarioRow> {
  $$HypoScenariosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HypoPortfoliosTable _portfolioIdTable(_$AppDatabase db) => db
      .hypoPortfolios
      .createAlias('hypo_scenarios__portfolio_id__hypo_portfolios__id');

  $$HypoPortfoliosTableProcessedTableManager? get portfolioId {
    final $_column = $_itemColumn<String>('portfolio_id');
    if ($_column == null) return null;
    final manager = $$HypoPortfoliosTableTableManager(
      $_db,
      $_db.hypoPortfolios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_portfolioIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HypoScenariosTableFilterComposer
    extends Composer<_$AppDatabase, $HypoScenariosTable> {
  $$HypoScenariosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assumptionsJson => $composableBuilder(
    column: $table.assumptionsJson,
    builder: (column) => ColumnFilters(column),
  );

  $$HypoPortfoliosTableFilterComposer get portfolioId {
    final $$HypoPortfoliosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.portfolioId,
      referencedTable: $db.hypoPortfolios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HypoPortfoliosTableFilterComposer(
            $db: $db,
            $table: $db.hypoPortfolios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HypoScenariosTableOrderingComposer
    extends Composer<_$AppDatabase, $HypoScenariosTable> {
  $$HypoScenariosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assumptionsJson => $composableBuilder(
    column: $table.assumptionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$HypoPortfoliosTableOrderingComposer get portfolioId {
    final $$HypoPortfoliosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.portfolioId,
      referencedTable: $db.hypoPortfolios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HypoPortfoliosTableOrderingComposer(
            $db: $db,
            $table: $db.hypoPortfolios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HypoScenariosTableAnnotationComposer
    extends Composer<_$AppDatabase, $HypoScenariosTable> {
  $$HypoScenariosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get assumptionsJson => $composableBuilder(
    column: $table.assumptionsJson,
    builder: (column) => column,
  );

  $$HypoPortfoliosTableAnnotationComposer get portfolioId {
    final $$HypoPortfoliosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.portfolioId,
      referencedTable: $db.hypoPortfolios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HypoPortfoliosTableAnnotationComposer(
            $db: $db,
            $table: $db.hypoPortfolios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HypoScenariosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HypoScenariosTable,
          HypoScenarioRow,
          $$HypoScenariosTableFilterComposer,
          $$HypoScenariosTableOrderingComposer,
          $$HypoScenariosTableAnnotationComposer,
          $$HypoScenariosTableCreateCompanionBuilder,
          $$HypoScenariosTableUpdateCompanionBuilder,
          (HypoScenarioRow, $$HypoScenariosTableReferences),
          HypoScenarioRow,
          PrefetchHooks Function({bool portfolioId})
        > {
  $$HypoScenariosTableTableManager(_$AppDatabase db, $HypoScenariosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HypoScenariosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HypoScenariosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HypoScenariosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> portfolioId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> assumptionsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HypoScenariosCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hlc: hlc,
                deviceId: deviceId,
                deletedAt: deletedAt,
                portfolioId: portfolioId,
                name: name,
                kind: kind,
                assumptionsJson: assumptionsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                required String hlc,
                required String deviceId,
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> portfolioId = const Value.absent(),
                required String name,
                required String kind,
                required String assumptionsJson,
                Value<int> rowid = const Value.absent(),
              }) => HypoScenariosCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hlc: hlc,
                deviceId: deviceId,
                deletedAt: deletedAt,
                portfolioId: portfolioId,
                name: name,
                kind: kind,
                assumptionsJson: assumptionsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HypoScenariosTable, HypoScenarioRow>(table),
                  $$HypoScenariosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({portfolioId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (portfolioId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.portfolioId,
                        referencedTable: $$HypoScenariosTableReferences
                            ._portfolioIdTable(db),
                        referencedColumn: $$HypoScenariosTableReferences
                            ._portfolioIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HypoScenariosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HypoScenariosTable,
      HypoScenarioRow,
      $$HypoScenariosTableFilterComposer,
      $$HypoScenariosTableOrderingComposer,
      $$HypoScenariosTableAnnotationComposer,
      $$HypoScenariosTableCreateCompanionBuilder,
      $$HypoScenariosTableUpdateCompanionBuilder,
      (HypoScenarioRow, $$HypoScenariosTableReferences),
      HypoScenarioRow,
      PrefetchHooks Function({bool portfolioId})
    >;
typedef $$DevSyncPeersTableCreateCompanionBuilder =
    DevSyncPeersCompanion Function({
      required String peerDeviceId,
      required String peerName,
      required String lastHlcReceived,
      Value<String?> lastHlcSent,
      required String lastSyncAt,
      Value<int> rowid,
    });
typedef $$DevSyncPeersTableUpdateCompanionBuilder =
    DevSyncPeersCompanion Function({
      Value<String> peerDeviceId,
      Value<String> peerName,
      Value<String> lastHlcReceived,
      Value<String?> lastHlcSent,
      Value<String> lastSyncAt,
      Value<int> rowid,
    });

class $$DevSyncPeersTableFilterComposer
    extends Composer<_$AppDatabase, $DevSyncPeersTable> {
  $$DevSyncPeersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get peerDeviceId => $composableBuilder(
    column: $table.peerDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get peerName => $composableBuilder(
    column: $table.peerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastHlcReceived => $composableBuilder(
    column: $table.lastHlcReceived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastHlcSent => $composableBuilder(
    column: $table.lastHlcSent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DevSyncPeersTableOrderingComposer
    extends Composer<_$AppDatabase, $DevSyncPeersTable> {
  $$DevSyncPeersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get peerDeviceId => $composableBuilder(
    column: $table.peerDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get peerName => $composableBuilder(
    column: $table.peerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastHlcReceived => $composableBuilder(
    column: $table.lastHlcReceived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastHlcSent => $composableBuilder(
    column: $table.lastHlcSent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevSyncPeersTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevSyncPeersTable> {
  $$DevSyncPeersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get peerDeviceId => $composableBuilder(
    column: $table.peerDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get peerName =>
      $composableBuilder(column: $table.peerName, builder: (column) => column);

  GeneratedColumn<String> get lastHlcReceived => $composableBuilder(
    column: $table.lastHlcReceived,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastHlcSent => $composableBuilder(
    column: $table.lastHlcSent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => column,
  );
}

class $$DevSyncPeersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevSyncPeersTable,
          DevSyncPeerRow,
          $$DevSyncPeersTableFilterComposer,
          $$DevSyncPeersTableOrderingComposer,
          $$DevSyncPeersTableAnnotationComposer,
          $$DevSyncPeersTableCreateCompanionBuilder,
          $$DevSyncPeersTableUpdateCompanionBuilder,
          (
            DevSyncPeerRow,
            BaseReferences<_$AppDatabase, $DevSyncPeersTable, DevSyncPeerRow>,
          ),
          DevSyncPeerRow,
          PrefetchHooks Function()
        > {
  $$DevSyncPeersTableTableManager(_$AppDatabase db, $DevSyncPeersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevSyncPeersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevSyncPeersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevSyncPeersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> peerDeviceId = const Value.absent(),
                Value<String> peerName = const Value.absent(),
                Value<String> lastHlcReceived = const Value.absent(),
                Value<String?> lastHlcSent = const Value.absent(),
                Value<String> lastSyncAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevSyncPeersCompanion(
                peerDeviceId: peerDeviceId,
                peerName: peerName,
                lastHlcReceived: lastHlcReceived,
                lastHlcSent: lastHlcSent,
                lastSyncAt: lastSyncAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String peerDeviceId,
                required String peerName,
                required String lastHlcReceived,
                Value<String?> lastHlcSent = const Value.absent(),
                required String lastSyncAt,
                Value<int> rowid = const Value.absent(),
              }) => DevSyncPeersCompanion.insert(
                peerDeviceId: peerDeviceId,
                peerName: peerName,
                lastHlcReceived: lastHlcReceived,
                lastHlcSent: lastHlcSent,
                lastSyncAt: lastSyncAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DevSyncPeersTable, DevSyncPeerRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DevSyncPeersTable,
                    DevSyncPeerRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DevSyncPeersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevSyncPeersTable,
      DevSyncPeerRow,
      $$DevSyncPeersTableFilterComposer,
      $$DevSyncPeersTableOrderingComposer,
      $$DevSyncPeersTableAnnotationComposer,
      $$DevSyncPeersTableCreateCompanionBuilder,
      $$DevSyncPeersTableUpdateCompanionBuilder,
      (
        DevSyncPeerRow,
        BaseReferences<_$AppDatabase, $DevSyncPeersTable, DevSyncPeerRow>,
      ),
      DevSyncPeerRow,
      PrefetchHooks Function()
    >;
typedef $$DevSyncHistoryTableCreateCompanionBuilder =
    DevSyncHistoryCompanion Function({
      required String id,
      required String direction,
      Value<String?> peerDeviceId,
      Value<String?> peerName,
      required String fileName,
      required String at,
      Value<String?> maxHlc,
      required String countsJson,
      required String result,
      Value<String?> message,
      Value<int> rowid,
    });
typedef $$DevSyncHistoryTableUpdateCompanionBuilder =
    DevSyncHistoryCompanion Function({
      Value<String> id,
      Value<String> direction,
      Value<String?> peerDeviceId,
      Value<String?> peerName,
      Value<String> fileName,
      Value<String> at,
      Value<String?> maxHlc,
      Value<String> countsJson,
      Value<String> result,
      Value<String?> message,
      Value<int> rowid,
    });

class $$DevSyncHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $DevSyncHistoryTable> {
  $$DevSyncHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get peerDeviceId => $composableBuilder(
    column: $table.peerDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get peerName => $composableBuilder(
    column: $table.peerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get maxHlc => $composableBuilder(
    column: $table.maxHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countsJson => $composableBuilder(
    column: $table.countsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DevSyncHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $DevSyncHistoryTable> {
  $$DevSyncHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get peerDeviceId => $composableBuilder(
    column: $table.peerDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get peerName => $composableBuilder(
    column: $table.peerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get maxHlc => $composableBuilder(
    column: $table.maxHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countsJson => $composableBuilder(
    column: $table.countsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevSyncHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevSyncHistoryTable> {
  $$DevSyncHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get peerDeviceId => $composableBuilder(
    column: $table.peerDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get peerName =>
      $composableBuilder(column: $table.peerName, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get maxHlc =>
      $composableBuilder(column: $table.maxHlc, builder: (column) => column);

  GeneratedColumn<String> get countsJson => $composableBuilder(
    column: $table.countsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);
}

class $$DevSyncHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevSyncHistoryTable,
          DevSyncHistoryRow,
          $$DevSyncHistoryTableFilterComposer,
          $$DevSyncHistoryTableOrderingComposer,
          $$DevSyncHistoryTableAnnotationComposer,
          $$DevSyncHistoryTableCreateCompanionBuilder,
          $$DevSyncHistoryTableUpdateCompanionBuilder,
          (
            DevSyncHistoryRow,
            BaseReferences<
              _$AppDatabase,
              $DevSyncHistoryTable,
              DevSyncHistoryRow
            >,
          ),
          DevSyncHistoryRow,
          PrefetchHooks Function()
        > {
  $$DevSyncHistoryTableTableManager(
    _$AppDatabase db,
    $DevSyncHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevSyncHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevSyncHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevSyncHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<String?> peerDeviceId = const Value.absent(),
                Value<String?> peerName = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> at = const Value.absent(),
                Value<String?> maxHlc = const Value.absent(),
                Value<String> countsJson = const Value.absent(),
                Value<String> result = const Value.absent(),
                Value<String?> message = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevSyncHistoryCompanion(
                id: id,
                direction: direction,
                peerDeviceId: peerDeviceId,
                peerName: peerName,
                fileName: fileName,
                at: at,
                maxHlc: maxHlc,
                countsJson: countsJson,
                result: result,
                message: message,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String direction,
                Value<String?> peerDeviceId = const Value.absent(),
                Value<String?> peerName = const Value.absent(),
                required String fileName,
                required String at,
                Value<String?> maxHlc = const Value.absent(),
                required String countsJson,
                required String result,
                Value<String?> message = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevSyncHistoryCompanion.insert(
                id: id,
                direction: direction,
                peerDeviceId: peerDeviceId,
                peerName: peerName,
                fileName: fileName,
                at: at,
                maxHlc: maxHlc,
                countsJson: countsJson,
                result: result,
                message: message,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DevSyncHistoryTable, DevSyncHistoryRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DevSyncHistoryTable,
                    DevSyncHistoryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DevSyncHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevSyncHistoryTable,
      DevSyncHistoryRow,
      $$DevSyncHistoryTableFilterComposer,
      $$DevSyncHistoryTableOrderingComposer,
      $$DevSyncHistoryTableAnnotationComposer,
      $$DevSyncHistoryTableCreateCompanionBuilder,
      $$DevSyncHistoryTableUpdateCompanionBuilder,
      (
        DevSyncHistoryRow,
        BaseReferences<_$AppDatabase, $DevSyncHistoryTable, DevSyncHistoryRow>,
      ),
      DevSyncHistoryRow,
      PrefetchHooks Function()
    >;
typedef $$DevBackupsTableCreateCompanionBuilder = DevBackupsCompanion Function({
  required String id,
  required String path,
  required String at,
  required String reason,
  required int schemaVersion,
  required String appVersion,
  required int size,
  required String sha256,
  Value<String> encryption,
  Value<int> rowid,
});
typedef $$DevBackupsTableUpdateCompanionBuilder = DevBackupsCompanion Function({
  Value<String> id,
  Value<String> path,
  Value<String> at,
  Value<String> reason,
  Value<int> schemaVersion,
  Value<String> appVersion,
  Value<int> size,
  Value<String> sha256,
  Value<String> encryption,
  Value<int> rowid,
});

class $$DevBackupsTableFilterComposer
    extends Composer<_$AppDatabase, $DevBackupsTable> {
  $$DevBackupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryption => $composableBuilder(
    column: $table.encryption,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DevBackupsTableOrderingComposer
    extends Composer<_$AppDatabase, $DevBackupsTable> {
  $$DevBackupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryption => $composableBuilder(
    column: $table.encryption,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevBackupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevBackupsTable> {
  $$DevBackupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<String> get encryption => $composableBuilder(
    column: $table.encryption,
    builder: (column) => column,
  );
}

class $$DevBackupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevBackupsTable,
          DevBackupRow,
          $$DevBackupsTableFilterComposer,
          $$DevBackupsTableOrderingComposer,
          $$DevBackupsTableAnnotationComposer,
          $$DevBackupsTableCreateCompanionBuilder,
          $$DevBackupsTableUpdateCompanionBuilder,
          (
            DevBackupRow,
            BaseReferences<_$AppDatabase, $DevBackupsTable, DevBackupRow>,
          ),
          DevBackupRow,
          PrefetchHooks Function()
        > {
  $$DevBackupsTableTableManager(_$AppDatabase db, $DevBackupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevBackupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevBackupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevBackupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> at = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<String> appVersion = const Value.absent(),
                Value<int> size = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<String> encryption = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevBackupsCompanion(
                id: id,
                path: path,
                at: at,
                reason: reason,
                schemaVersion: schemaVersion,
                appVersion: appVersion,
                size: size,
                sha256: sha256,
                encryption: encryption,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String path,
                required String at,
                required String reason,
                required int schemaVersion,
                required String appVersion,
                required int size,
                required String sha256,
                Value<String> encryption = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevBackupsCompanion.insert(
                id: id,
                path: path,
                at: at,
                reason: reason,
                schemaVersion: schemaVersion,
                appVersion: appVersion,
                size: size,
                sha256: sha256,
                encryption: encryption,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DevBackupsTable, DevBackupRow>(table),
                  BaseReferences<_$AppDatabase, $DevBackupsTable, DevBackupRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DevBackupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevBackupsTable,
      DevBackupRow,
      $$DevBackupsTableFilterComposer,
      $$DevBackupsTableOrderingComposer,
      $$DevBackupsTableAnnotationComposer,
      $$DevBackupsTableCreateCompanionBuilder,
      $$DevBackupsTableUpdateCompanionBuilder,
      (
        DevBackupRow,
        BaseReferences<_$AppDatabase, $DevBackupsTable, DevBackupRow>,
      ),
      DevBackupRow,
      PrefetchHooks Function()
    >;
typedef $$MktPricesTableCreateCompanionBuilder = MktPricesCompanion Function({
  required String symbol,
  required String market,
  required String refDate,
  required String source,
  required String dataType,
  Value<String?> open,
  Value<String?> high,
  Value<String?> low,
  required String close,
  Value<String?> volume,
  required String currency,
  Value<String?> quoteFactor,
  required String collectedAt,
  Value<int> rowid,
});
typedef $$MktPricesTableUpdateCompanionBuilder = MktPricesCompanion Function({
  Value<String> symbol,
  Value<String> market,
  Value<String> refDate,
  Value<String> source,
  Value<String> dataType,
  Value<String?> open,
  Value<String?> high,
  Value<String?> low,
  Value<String> close,
  Value<String?> volume,
  Value<String> currency,
  Value<String?> quoteFactor,
  Value<String> collectedAt,
  Value<int> rowid,
});

class $$MktPricesTableFilterComposer
    extends Composer<_$AppDatabase, $MktPricesTable> {
  $$MktPricesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refDate => $composableBuilder(
    column: $table.refDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataType => $composableBuilder(
    column: $table.dataType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get open => $composableBuilder(
    column: $table.open,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get high => $composableBuilder(
    column: $table.high,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get low => $composableBuilder(
    column: $table.low,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get close => $composableBuilder(
    column: $table.close,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quoteFactor => $composableBuilder(
    column: $table.quoteFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectedAt => $composableBuilder(
    column: $table.collectedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MktPricesTableOrderingComposer
    extends Composer<_$AppDatabase, $MktPricesTable> {
  $$MktPricesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refDate => $composableBuilder(
    column: $table.refDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataType => $composableBuilder(
    column: $table.dataType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get open => $composableBuilder(
    column: $table.open,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get high => $composableBuilder(
    column: $table.high,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get low => $composableBuilder(
    column: $table.low,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get close => $composableBuilder(
    column: $table.close,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quoteFactor => $composableBuilder(
    column: $table.quoteFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectedAt => $composableBuilder(
    column: $table.collectedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MktPricesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MktPricesTable> {
  $$MktPricesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get market =>
      $composableBuilder(column: $table.market, builder: (column) => column);

  GeneratedColumn<String> get refDate =>
      $composableBuilder(column: $table.refDate, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get dataType =>
      $composableBuilder(column: $table.dataType, builder: (column) => column);

  GeneratedColumn<String> get open =>
      $composableBuilder(column: $table.open, builder: (column) => column);

  GeneratedColumn<String> get high =>
      $composableBuilder(column: $table.high, builder: (column) => column);

  GeneratedColumn<String> get low =>
      $composableBuilder(column: $table.low, builder: (column) => column);

  GeneratedColumn<String> get close =>
      $composableBuilder(column: $table.close, builder: (column) => column);

  GeneratedColumn<String> get volume =>
      $composableBuilder(column: $table.volume, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get quoteFactor => $composableBuilder(
    column: $table.quoteFactor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collectedAt => $composableBuilder(
    column: $table.collectedAt,
    builder: (column) => column,
  );
}

class $$MktPricesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MktPricesTable,
          MktPriceRow,
          $$MktPricesTableFilterComposer,
          $$MktPricesTableOrderingComposer,
          $$MktPricesTableAnnotationComposer,
          $$MktPricesTableCreateCompanionBuilder,
          $$MktPricesTableUpdateCompanionBuilder,
          (
            MktPriceRow,
            BaseReferences<_$AppDatabase, $MktPricesTable, MktPriceRow>,
          ),
          MktPriceRow,
          PrefetchHooks Function()
        > {
  $$MktPricesTableTableManager(_$AppDatabase db, $MktPricesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MktPricesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MktPricesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MktPricesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> symbol = const Value.absent(),
                Value<String> market = const Value.absent(),
                Value<String> refDate = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> dataType = const Value.absent(),
                Value<String?> open = const Value.absent(),
                Value<String?> high = const Value.absent(),
                Value<String?> low = const Value.absent(),
                Value<String> close = const Value.absent(),
                Value<String?> volume = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> quoteFactor = const Value.absent(),
                Value<String> collectedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MktPricesCompanion(
                symbol: symbol,
                market: market,
                refDate: refDate,
                source: source,
                dataType: dataType,
                open: open,
                high: high,
                low: low,
                close: close,
                volume: volume,
                currency: currency,
                quoteFactor: quoteFactor,
                collectedAt: collectedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String symbol,
                required String market,
                required String refDate,
                required String source,
                required String dataType,
                Value<String?> open = const Value.absent(),
                Value<String?> high = const Value.absent(),
                Value<String?> low = const Value.absent(),
                required String close,
                Value<String?> volume = const Value.absent(),
                required String currency,
                Value<String?> quoteFactor = const Value.absent(),
                required String collectedAt,
                Value<int> rowid = const Value.absent(),
              }) => MktPricesCompanion.insert(
                symbol: symbol,
                market: market,
                refDate: refDate,
                source: source,
                dataType: dataType,
                open: open,
                high: high,
                low: low,
                close: close,
                volume: volume,
                currency: currency,
                quoteFactor: quoteFactor,
                collectedAt: collectedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MktPricesTable, MktPriceRow>(table),
                  BaseReferences<_$AppDatabase, $MktPricesTable, MktPriceRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MktPricesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MktPricesTable,
      MktPriceRow,
      $$MktPricesTableFilterComposer,
      $$MktPricesTableOrderingComposer,
      $$MktPricesTableAnnotationComposer,
      $$MktPricesTableCreateCompanionBuilder,
      $$MktPricesTableUpdateCompanionBuilder,
      (
        MktPriceRow,
        BaseReferences<_$AppDatabase, $MktPricesTable, MktPriceRow>,
      ),
      MktPriceRow,
      PrefetchHooks Function()
    >;
typedef $$MktQuotesTableCreateCompanionBuilder = MktQuotesCompanion Function({
  required String symbol,
  required String market,
  required String source,
  required String price,
  required String currency,
  required String refAt,
  Value<String?> delayNote,
  required String dataType,
  required String collectedAt,
  Value<int> rowid,
});
typedef $$MktQuotesTableUpdateCompanionBuilder = MktQuotesCompanion Function({
  Value<String> symbol,
  Value<String> market,
  Value<String> source,
  Value<String> price,
  Value<String> currency,
  Value<String> refAt,
  Value<String?> delayNote,
  Value<String> dataType,
  Value<String> collectedAt,
  Value<int> rowid,
});

class $$MktQuotesTableFilterComposer
    extends Composer<_$AppDatabase, $MktQuotesTable> {
  $$MktQuotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refAt => $composableBuilder(
    column: $table.refAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get delayNote => $composableBuilder(
    column: $table.delayNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataType => $composableBuilder(
    column: $table.dataType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectedAt => $composableBuilder(
    column: $table.collectedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MktQuotesTableOrderingComposer
    extends Composer<_$AppDatabase, $MktQuotesTable> {
  $$MktQuotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refAt => $composableBuilder(
    column: $table.refAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get delayNote => $composableBuilder(
    column: $table.delayNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataType => $composableBuilder(
    column: $table.dataType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectedAt => $composableBuilder(
    column: $table.collectedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MktQuotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MktQuotesTable> {
  $$MktQuotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get market =>
      $composableBuilder(column: $table.market, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get refAt =>
      $composableBuilder(column: $table.refAt, builder: (column) => column);

  GeneratedColumn<String> get delayNote =>
      $composableBuilder(column: $table.delayNote, builder: (column) => column);

  GeneratedColumn<String> get dataType =>
      $composableBuilder(column: $table.dataType, builder: (column) => column);

  GeneratedColumn<String> get collectedAt => $composableBuilder(
    column: $table.collectedAt,
    builder: (column) => column,
  );
}

class $$MktQuotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MktQuotesTable,
          MktQuoteRow,
          $$MktQuotesTableFilterComposer,
          $$MktQuotesTableOrderingComposer,
          $$MktQuotesTableAnnotationComposer,
          $$MktQuotesTableCreateCompanionBuilder,
          $$MktQuotesTableUpdateCompanionBuilder,
          (
            MktQuoteRow,
            BaseReferences<_$AppDatabase, $MktQuotesTable, MktQuoteRow>,
          ),
          MktQuoteRow,
          PrefetchHooks Function()
        > {
  $$MktQuotesTableTableManager(_$AppDatabase db, $MktQuotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MktQuotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MktQuotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MktQuotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> symbol = const Value.absent(),
                Value<String> market = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> price = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> refAt = const Value.absent(),
                Value<String?> delayNote = const Value.absent(),
                Value<String> dataType = const Value.absent(),
                Value<String> collectedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MktQuotesCompanion(
                symbol: symbol,
                market: market,
                source: source,
                price: price,
                currency: currency,
                refAt: refAt,
                delayNote: delayNote,
                dataType: dataType,
                collectedAt: collectedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String symbol,
                required String market,
                required String source,
                required String price,
                required String currency,
                required String refAt,
                Value<String?> delayNote = const Value.absent(),
                required String dataType,
                required String collectedAt,
                Value<int> rowid = const Value.absent(),
              }) => MktQuotesCompanion.insert(
                symbol: symbol,
                market: market,
                source: source,
                price: price,
                currency: currency,
                refAt: refAt,
                delayNote: delayNote,
                dataType: dataType,
                collectedAt: collectedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MktQuotesTable, MktQuoteRow>(table),
                  BaseReferences<_$AppDatabase, $MktQuotesTable, MktQuoteRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MktQuotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MktQuotesTable,
      MktQuoteRow,
      $$MktQuotesTableFilterComposer,
      $$MktQuotesTableOrderingComposer,
      $$MktQuotesTableAnnotationComposer,
      $$MktQuotesTableCreateCompanionBuilder,
      $$MktQuotesTableUpdateCompanionBuilder,
      (
        MktQuoteRow,
        BaseReferences<_$AppDatabase, $MktQuotesTable, MktQuoteRow>,
      ),
      MktQuoteRow,
      PrefetchHooks Function()
    >;
typedef $$MktCorporateEventsTableCreateCompanionBuilder =
    MktCorporateEventsCompanion Function({
      required String symbol,
      required String market,
      required String eventKind,
      required String exDate,
      required String source,
      required String seq,
      Value<String?> comDate,
      Value<String?> paymentDate,
      Value<String?> factor,
      Value<String?> amount,
      Value<String?> currency,
      required String status,
      Value<String?> rawLabel,
      Value<String?> isin,
      required String collectedAt,
      Value<int> rowid,
    });
typedef $$MktCorporateEventsTableUpdateCompanionBuilder =
    MktCorporateEventsCompanion Function({
      Value<String> symbol,
      Value<String> market,
      Value<String> eventKind,
      Value<String> exDate,
      Value<String> source,
      Value<String> seq,
      Value<String?> comDate,
      Value<String?> paymentDate,
      Value<String?> factor,
      Value<String?> amount,
      Value<String?> currency,
      Value<String> status,
      Value<String?> rawLabel,
      Value<String?> isin,
      Value<String> collectedAt,
      Value<int> rowid,
    });

class $$MktCorporateEventsTableFilterComposer
    extends Composer<_$AppDatabase, $MktCorporateEventsTable> {
  $$MktCorporateEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventKind => $composableBuilder(
    column: $table.eventKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exDate => $composableBuilder(
    column: $table.exDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comDate => $composableBuilder(
    column: $table.comDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get factor => $composableBuilder(
    column: $table.factor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawLabel => $composableBuilder(
    column: $table.rawLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isin => $composableBuilder(
    column: $table.isin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectedAt => $composableBuilder(
    column: $table.collectedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MktCorporateEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $MktCorporateEventsTable> {
  $$MktCorporateEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventKind => $composableBuilder(
    column: $table.eventKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exDate => $composableBuilder(
    column: $table.exDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comDate => $composableBuilder(
    column: $table.comDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get factor => $composableBuilder(
    column: $table.factor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawLabel => $composableBuilder(
    column: $table.rawLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isin => $composableBuilder(
    column: $table.isin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectedAt => $composableBuilder(
    column: $table.collectedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MktCorporateEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MktCorporateEventsTable> {
  $$MktCorporateEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get market =>
      $composableBuilder(column: $table.market, builder: (column) => column);

  GeneratedColumn<String> get eventKind =>
      $composableBuilder(column: $table.eventKind, builder: (column) => column);

  GeneratedColumn<String> get exDate =>
      $composableBuilder(column: $table.exDate, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get comDate =>
      $composableBuilder(column: $table.comDate, builder: (column) => column);

  GeneratedColumn<String> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get factor =>
      $composableBuilder(column: $table.factor, builder: (column) => column);

  GeneratedColumn<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get rawLabel =>
      $composableBuilder(column: $table.rawLabel, builder: (column) => column);

  GeneratedColumn<String> get isin =>
      $composableBuilder(column: $table.isin, builder: (column) => column);

  GeneratedColumn<String> get collectedAt => $composableBuilder(
    column: $table.collectedAt,
    builder: (column) => column,
  );
}

class $$MktCorporateEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MktCorporateEventsTable,
          MktCorporateEventRow,
          $$MktCorporateEventsTableFilterComposer,
          $$MktCorporateEventsTableOrderingComposer,
          $$MktCorporateEventsTableAnnotationComposer,
          $$MktCorporateEventsTableCreateCompanionBuilder,
          $$MktCorporateEventsTableUpdateCompanionBuilder,
          (
            MktCorporateEventRow,
            BaseReferences<
              _$AppDatabase,
              $MktCorporateEventsTable,
              MktCorporateEventRow
            >,
          ),
          MktCorporateEventRow,
          PrefetchHooks Function()
        > {
  $$MktCorporateEventsTableTableManager(
    _$AppDatabase db,
    $MktCorporateEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MktCorporateEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MktCorporateEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MktCorporateEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> symbol = const Value.absent(),
                Value<String> market = const Value.absent(),
                Value<String> eventKind = const Value.absent(),
                Value<String> exDate = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> seq = const Value.absent(),
                Value<String?> comDate = const Value.absent(),
                Value<String?> paymentDate = const Value.absent(),
                Value<String?> factor = const Value.absent(),
                Value<String?> amount = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> rawLabel = const Value.absent(),
                Value<String?> isin = const Value.absent(),
                Value<String> collectedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MktCorporateEventsCompanion(
                symbol: symbol,
                market: market,
                eventKind: eventKind,
                exDate: exDate,
                source: source,
                seq: seq,
                comDate: comDate,
                paymentDate: paymentDate,
                factor: factor,
                amount: amount,
                currency: currency,
                status: status,
                rawLabel: rawLabel,
                isin: isin,
                collectedAt: collectedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String symbol,
                required String market,
                required String eventKind,
                required String exDate,
                required String source,
                required String seq,
                Value<String?> comDate = const Value.absent(),
                Value<String?> paymentDate = const Value.absent(),
                Value<String?> factor = const Value.absent(),
                Value<String?> amount = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                required String status,
                Value<String?> rawLabel = const Value.absent(),
                Value<String?> isin = const Value.absent(),
                required String collectedAt,
                Value<int> rowid = const Value.absent(),
              }) => MktCorporateEventsCompanion.insert(
                symbol: symbol,
                market: market,
                eventKind: eventKind,
                exDate: exDate,
                source: source,
                seq: seq,
                comDate: comDate,
                paymentDate: paymentDate,
                factor: factor,
                amount: amount,
                currency: currency,
                status: status,
                rawLabel: rawLabel,
                isin: isin,
                collectedAt: collectedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MktCorporateEventsTable, MktCorporateEventRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $MktCorporateEventsTable,
                    MktCorporateEventRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MktCorporateEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MktCorporateEventsTable,
      MktCorporateEventRow,
      $$MktCorporateEventsTableFilterComposer,
      $$MktCorporateEventsTableOrderingComposer,
      $$MktCorporateEventsTableAnnotationComposer,
      $$MktCorporateEventsTableCreateCompanionBuilder,
      $$MktCorporateEventsTableUpdateCompanionBuilder,
      (
        MktCorporateEventRow,
        BaseReferences<
          _$AppDatabase,
          $MktCorporateEventsTable,
          MktCorporateEventRow
        >,
      ),
      MktCorporateEventRow,
      PrefetchHooks Function()
    >;
typedef $$MktIndicatorsTableCreateCompanionBuilder =
    MktIndicatorsCompanion Function({
      required String seriesCode,
      required String refDate,
      required String source,
      required String value,
      required String unit,
      required String collectedAt,
      Value<int> rowid,
    });
typedef $$MktIndicatorsTableUpdateCompanionBuilder =
    MktIndicatorsCompanion Function({
      Value<String> seriesCode,
      Value<String> refDate,
      Value<String> source,
      Value<String> value,
      Value<String> unit,
      Value<String> collectedAt,
      Value<int> rowid,
    });

class $$MktIndicatorsTableFilterComposer
    extends Composer<_$AppDatabase, $MktIndicatorsTable> {
  $$MktIndicatorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get seriesCode => $composableBuilder(
    column: $table.seriesCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refDate => $composableBuilder(
    column: $table.refDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectedAt => $composableBuilder(
    column: $table.collectedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MktIndicatorsTableOrderingComposer
    extends Composer<_$AppDatabase, $MktIndicatorsTable> {
  $$MktIndicatorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get seriesCode => $composableBuilder(
    column: $table.seriesCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refDate => $composableBuilder(
    column: $table.refDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectedAt => $composableBuilder(
    column: $table.collectedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MktIndicatorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MktIndicatorsTable> {
  $$MktIndicatorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get seriesCode => $composableBuilder(
    column: $table.seriesCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get refDate =>
      $composableBuilder(column: $table.refDate, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get collectedAt => $composableBuilder(
    column: $table.collectedAt,
    builder: (column) => column,
  );
}

class $$MktIndicatorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MktIndicatorsTable,
          MktIndicatorRow,
          $$MktIndicatorsTableFilterComposer,
          $$MktIndicatorsTableOrderingComposer,
          $$MktIndicatorsTableAnnotationComposer,
          $$MktIndicatorsTableCreateCompanionBuilder,
          $$MktIndicatorsTableUpdateCompanionBuilder,
          (
            MktIndicatorRow,
            BaseReferences<_$AppDatabase, $MktIndicatorsTable, MktIndicatorRow>,
          ),
          MktIndicatorRow,
          PrefetchHooks Function()
        > {
  $$MktIndicatorsTableTableManager(_$AppDatabase db, $MktIndicatorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MktIndicatorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MktIndicatorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MktIndicatorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> seriesCode = const Value.absent(),
                Value<String> refDate = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String> collectedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MktIndicatorsCompanion(
                seriesCode: seriesCode,
                refDate: refDate,
                source: source,
                value: value,
                unit: unit,
                collectedAt: collectedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String seriesCode,
                required String refDate,
                required String source,
                required String value,
                required String unit,
                required String collectedAt,
                Value<int> rowid = const Value.absent(),
              }) => MktIndicatorsCompanion.insert(
                seriesCode: seriesCode,
                refDate: refDate,
                source: source,
                value: value,
                unit: unit,
                collectedAt: collectedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MktIndicatorsTable, MktIndicatorRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $MktIndicatorsTable,
                    MktIndicatorRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MktIndicatorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MktIndicatorsTable,
      MktIndicatorRow,
      $$MktIndicatorsTableFilterComposer,
      $$MktIndicatorsTableOrderingComposer,
      $$MktIndicatorsTableAnnotationComposer,
      $$MktIndicatorsTableCreateCompanionBuilder,
      $$MktIndicatorsTableUpdateCompanionBuilder,
      (
        MktIndicatorRow,
        BaseReferences<_$AppDatabase, $MktIndicatorsTable, MktIndicatorRow>,
      ),
      MktIndicatorRow,
      PrefetchHooks Function()
    >;
typedef $$MktFxRatesTableCreateCompanionBuilder = MktFxRatesCompanion Function({
  required String base,
  required String quote,
  required String refDate,
  required String kind,
  required String source,
  Value<String?> bid,
  Value<String?> ask,
  Value<String?> refAt,
  required String collectedAt,
  Value<int> rowid,
});
typedef $$MktFxRatesTableUpdateCompanionBuilder = MktFxRatesCompanion Function({
  Value<String> base,
  Value<String> quote,
  Value<String> refDate,
  Value<String> kind,
  Value<String> source,
  Value<String?> bid,
  Value<String?> ask,
  Value<String?> refAt,
  Value<String> collectedAt,
  Value<int> rowid,
});

class $$MktFxRatesTableFilterComposer
    extends Composer<_$AppDatabase, $MktFxRatesTable> {
  $$MktFxRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get base => $composableBuilder(
    column: $table.base,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quote => $composableBuilder(
    column: $table.quote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refDate => $composableBuilder(
    column: $table.refDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bid => $composableBuilder(
    column: $table.bid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ask => $composableBuilder(
    column: $table.ask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refAt => $composableBuilder(
    column: $table.refAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectedAt => $composableBuilder(
    column: $table.collectedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MktFxRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $MktFxRatesTable> {
  $$MktFxRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get base => $composableBuilder(
    column: $table.base,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quote => $composableBuilder(
    column: $table.quote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refDate => $composableBuilder(
    column: $table.refDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bid => $composableBuilder(
    column: $table.bid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ask => $composableBuilder(
    column: $table.ask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refAt => $composableBuilder(
    column: $table.refAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectedAt => $composableBuilder(
    column: $table.collectedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MktFxRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MktFxRatesTable> {
  $$MktFxRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get base =>
      $composableBuilder(column: $table.base, builder: (column) => column);

  GeneratedColumn<String> get quote =>
      $composableBuilder(column: $table.quote, builder: (column) => column);

  GeneratedColumn<String> get refDate =>
      $composableBuilder(column: $table.refDate, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get bid =>
      $composableBuilder(column: $table.bid, builder: (column) => column);

  GeneratedColumn<String> get ask =>
      $composableBuilder(column: $table.ask, builder: (column) => column);

  GeneratedColumn<String> get refAt =>
      $composableBuilder(column: $table.refAt, builder: (column) => column);

  GeneratedColumn<String> get collectedAt => $composableBuilder(
    column: $table.collectedAt,
    builder: (column) => column,
  );
}

class $$MktFxRatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MktFxRatesTable,
          MktFxRateRow,
          $$MktFxRatesTableFilterComposer,
          $$MktFxRatesTableOrderingComposer,
          $$MktFxRatesTableAnnotationComposer,
          $$MktFxRatesTableCreateCompanionBuilder,
          $$MktFxRatesTableUpdateCompanionBuilder,
          (
            MktFxRateRow,
            BaseReferences<_$AppDatabase, $MktFxRatesTable, MktFxRateRow>,
          ),
          MktFxRateRow,
          PrefetchHooks Function()
        > {
  $$MktFxRatesTableTableManager(_$AppDatabase db, $MktFxRatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MktFxRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MktFxRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MktFxRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> base = const Value.absent(),
                Value<String> quote = const Value.absent(),
                Value<String> refDate = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> bid = const Value.absent(),
                Value<String?> ask = const Value.absent(),
                Value<String?> refAt = const Value.absent(),
                Value<String> collectedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MktFxRatesCompanion(
                base: base,
                quote: quote,
                refDate: refDate,
                kind: kind,
                source: source,
                bid: bid,
                ask: ask,
                refAt: refAt,
                collectedAt: collectedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String base,
                required String quote,
                required String refDate,
                required String kind,
                required String source,
                Value<String?> bid = const Value.absent(),
                Value<String?> ask = const Value.absent(),
                Value<String?> refAt = const Value.absent(),
                required String collectedAt,
                Value<int> rowid = const Value.absent(),
              }) => MktFxRatesCompanion.insert(
                base: base,
                quote: quote,
                refDate: refDate,
                kind: kind,
                source: source,
                bid: bid,
                ask: ask,
                refAt: refAt,
                collectedAt: collectedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MktFxRatesTable, MktFxRateRow>(table),
                  BaseReferences<_$AppDatabase, $MktFxRatesTable, MktFxRateRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MktFxRatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MktFxRatesTable,
      MktFxRateRow,
      $$MktFxRatesTableFilterComposer,
      $$MktFxRatesTableOrderingComposer,
      $$MktFxRatesTableAnnotationComposer,
      $$MktFxRatesTableCreateCompanionBuilder,
      $$MktFxRatesTableUpdateCompanionBuilder,
      (
        MktFxRateRow,
        BaseReferences<_$AppDatabase, $MktFxRatesTable, MktFxRateRow>,
      ),
      MktFxRateRow,
      PrefetchHooks Function()
    >;
typedef $$MktTreasuryPricesTableCreateCompanionBuilder =
    MktTreasuryPricesCompanion Function({
      required String title,
      required String maturityDate,
      required String refDate,
      required String source,
      Value<String?> buyRate,
      Value<String?> sellRate,
      Value<String?> buyPu,
      Value<String?> sellPu,
      Value<String?> basePu,
      required String collectedAt,
      Value<int> rowid,
    });
typedef $$MktTreasuryPricesTableUpdateCompanionBuilder =
    MktTreasuryPricesCompanion Function({
      Value<String> title,
      Value<String> maturityDate,
      Value<String> refDate,
      Value<String> source,
      Value<String?> buyRate,
      Value<String?> sellRate,
      Value<String?> buyPu,
      Value<String?> sellPu,
      Value<String?> basePu,
      Value<String> collectedAt,
      Value<int> rowid,
    });

class $$MktTreasuryPricesTableFilterComposer
    extends Composer<_$AppDatabase, $MktTreasuryPricesTable> {
  $$MktTreasuryPricesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get maturityDate => $composableBuilder(
    column: $table.maturityDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refDate => $composableBuilder(
    column: $table.refDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get buyRate => $composableBuilder(
    column: $table.buyRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sellRate => $composableBuilder(
    column: $table.sellRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get buyPu => $composableBuilder(
    column: $table.buyPu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sellPu => $composableBuilder(
    column: $table.sellPu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get basePu => $composableBuilder(
    column: $table.basePu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectedAt => $composableBuilder(
    column: $table.collectedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MktTreasuryPricesTableOrderingComposer
    extends Composer<_$AppDatabase, $MktTreasuryPricesTable> {
  $$MktTreasuryPricesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get maturityDate => $composableBuilder(
    column: $table.maturityDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refDate => $composableBuilder(
    column: $table.refDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get buyRate => $composableBuilder(
    column: $table.buyRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sellRate => $composableBuilder(
    column: $table.sellRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get buyPu => $composableBuilder(
    column: $table.buyPu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sellPu => $composableBuilder(
    column: $table.sellPu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get basePu => $composableBuilder(
    column: $table.basePu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectedAt => $composableBuilder(
    column: $table.collectedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MktTreasuryPricesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MktTreasuryPricesTable> {
  $$MktTreasuryPricesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get maturityDate => $composableBuilder(
    column: $table.maturityDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get refDate =>
      $composableBuilder(column: $table.refDate, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get buyRate =>
      $composableBuilder(column: $table.buyRate, builder: (column) => column);

  GeneratedColumn<String> get sellRate =>
      $composableBuilder(column: $table.sellRate, builder: (column) => column);

  GeneratedColumn<String> get buyPu =>
      $composableBuilder(column: $table.buyPu, builder: (column) => column);

  GeneratedColumn<String> get sellPu =>
      $composableBuilder(column: $table.sellPu, builder: (column) => column);

  GeneratedColumn<String> get basePu =>
      $composableBuilder(column: $table.basePu, builder: (column) => column);

  GeneratedColumn<String> get collectedAt => $composableBuilder(
    column: $table.collectedAt,
    builder: (column) => column,
  );
}

class $$MktTreasuryPricesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MktTreasuryPricesTable,
          MktTreasuryPriceRow,
          $$MktTreasuryPricesTableFilterComposer,
          $$MktTreasuryPricesTableOrderingComposer,
          $$MktTreasuryPricesTableAnnotationComposer,
          $$MktTreasuryPricesTableCreateCompanionBuilder,
          $$MktTreasuryPricesTableUpdateCompanionBuilder,
          (
            MktTreasuryPriceRow,
            BaseReferences<
              _$AppDatabase,
              $MktTreasuryPricesTable,
              MktTreasuryPriceRow
            >,
          ),
          MktTreasuryPriceRow,
          PrefetchHooks Function()
        > {
  $$MktTreasuryPricesTableTableManager(
    _$AppDatabase db,
    $MktTreasuryPricesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MktTreasuryPricesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MktTreasuryPricesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MktTreasuryPricesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> title = const Value.absent(),
                Value<String> maturityDate = const Value.absent(),
                Value<String> refDate = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> buyRate = const Value.absent(),
                Value<String?> sellRate = const Value.absent(),
                Value<String?> buyPu = const Value.absent(),
                Value<String?> sellPu = const Value.absent(),
                Value<String?> basePu = const Value.absent(),
                Value<String> collectedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MktTreasuryPricesCompanion(
                title: title,
                maturityDate: maturityDate,
                refDate: refDate,
                source: source,
                buyRate: buyRate,
                sellRate: sellRate,
                buyPu: buyPu,
                sellPu: sellPu,
                basePu: basePu,
                collectedAt: collectedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String title,
                required String maturityDate,
                required String refDate,
                required String source,
                Value<String?> buyRate = const Value.absent(),
                Value<String?> sellRate = const Value.absent(),
                Value<String?> buyPu = const Value.absent(),
                Value<String?> sellPu = const Value.absent(),
                Value<String?> basePu = const Value.absent(),
                required String collectedAt,
                Value<int> rowid = const Value.absent(),
              }) => MktTreasuryPricesCompanion.insert(
                title: title,
                maturityDate: maturityDate,
                refDate: refDate,
                source: source,
                buyRate: buyRate,
                sellRate: sellRate,
                buyPu: buyPu,
                sellPu: sellPu,
                basePu: basePu,
                collectedAt: collectedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MktTreasuryPricesTable, MktTreasuryPriceRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $MktTreasuryPricesTable,
                    MktTreasuryPriceRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MktTreasuryPricesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MktTreasuryPricesTable,
      MktTreasuryPriceRow,
      $$MktTreasuryPricesTableFilterComposer,
      $$MktTreasuryPricesTableOrderingComposer,
      $$MktTreasuryPricesTableAnnotationComposer,
      $$MktTreasuryPricesTableCreateCompanionBuilder,
      $$MktTreasuryPricesTableUpdateCompanionBuilder,
      (
        MktTreasuryPriceRow,
        BaseReferences<
          _$AppDatabase,
          $MktTreasuryPricesTable,
          MktTreasuryPriceRow
        >,
      ),
      MktTreasuryPriceRow,
      PrefetchHooks Function()
    >;
typedef $$MktFundQuotasTableCreateCompanionBuilder =
    MktFundQuotasCompanion Function({
      required String cnpj,
      required String refDate,
      required String kind,
      required String source,
      Value<String?> quota,
      Value<String?> nav,
      Value<String?> holders,
      Value<String?> isin,
      Value<String?> name,
      required String collectedAt,
      Value<int> rowid,
    });
typedef $$MktFundQuotasTableUpdateCompanionBuilder =
    MktFundQuotasCompanion Function({
      Value<String> cnpj,
      Value<String> refDate,
      Value<String> kind,
      Value<String> source,
      Value<String?> quota,
      Value<String?> nav,
      Value<String?> holders,
      Value<String?> isin,
      Value<String?> name,
      Value<String> collectedAt,
      Value<int> rowid,
    });

class $$MktFundQuotasTableFilterComposer
    extends Composer<_$AppDatabase, $MktFundQuotasTable> {
  $$MktFundQuotasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cnpj => $composableBuilder(
    column: $table.cnpj,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refDate => $composableBuilder(
    column: $table.refDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quota => $composableBuilder(
    column: $table.quota,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nav => $composableBuilder(
    column: $table.nav,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get holders => $composableBuilder(
    column: $table.holders,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isin => $composableBuilder(
    column: $table.isin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectedAt => $composableBuilder(
    column: $table.collectedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MktFundQuotasTableOrderingComposer
    extends Composer<_$AppDatabase, $MktFundQuotasTable> {
  $$MktFundQuotasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cnpj => $composableBuilder(
    column: $table.cnpj,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refDate => $composableBuilder(
    column: $table.refDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quota => $composableBuilder(
    column: $table.quota,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nav => $composableBuilder(
    column: $table.nav,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get holders => $composableBuilder(
    column: $table.holders,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isin => $composableBuilder(
    column: $table.isin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectedAt => $composableBuilder(
    column: $table.collectedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MktFundQuotasTableAnnotationComposer
    extends Composer<_$AppDatabase, $MktFundQuotasTable> {
  $$MktFundQuotasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cnpj =>
      $composableBuilder(column: $table.cnpj, builder: (column) => column);

  GeneratedColumn<String> get refDate =>
      $composableBuilder(column: $table.refDate, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get quota =>
      $composableBuilder(column: $table.quota, builder: (column) => column);

  GeneratedColumn<String> get nav =>
      $composableBuilder(column: $table.nav, builder: (column) => column);

  GeneratedColumn<String> get holders =>
      $composableBuilder(column: $table.holders, builder: (column) => column);

  GeneratedColumn<String> get isin =>
      $composableBuilder(column: $table.isin, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get collectedAt => $composableBuilder(
    column: $table.collectedAt,
    builder: (column) => column,
  );
}

class $$MktFundQuotasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MktFundQuotasTable,
          MktFundQuotaRow,
          $$MktFundQuotasTableFilterComposer,
          $$MktFundQuotasTableOrderingComposer,
          $$MktFundQuotasTableAnnotationComposer,
          $$MktFundQuotasTableCreateCompanionBuilder,
          $$MktFundQuotasTableUpdateCompanionBuilder,
          (
            MktFundQuotaRow,
            BaseReferences<_$AppDatabase, $MktFundQuotasTable, MktFundQuotaRow>,
          ),
          MktFundQuotaRow,
          PrefetchHooks Function()
        > {
  $$MktFundQuotasTableTableManager(_$AppDatabase db, $MktFundQuotasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MktFundQuotasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MktFundQuotasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MktFundQuotasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cnpj = const Value.absent(),
                Value<String> refDate = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> quota = const Value.absent(),
                Value<String?> nav = const Value.absent(),
                Value<String?> holders = const Value.absent(),
                Value<String?> isin = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String> collectedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MktFundQuotasCompanion(
                cnpj: cnpj,
                refDate: refDate,
                kind: kind,
                source: source,
                quota: quota,
                nav: nav,
                holders: holders,
                isin: isin,
                name: name,
                collectedAt: collectedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cnpj,
                required String refDate,
                required String kind,
                required String source,
                Value<String?> quota = const Value.absent(),
                Value<String?> nav = const Value.absent(),
                Value<String?> holders = const Value.absent(),
                Value<String?> isin = const Value.absent(),
                Value<String?> name = const Value.absent(),
                required String collectedAt,
                Value<int> rowid = const Value.absent(),
              }) => MktFundQuotasCompanion.insert(
                cnpj: cnpj,
                refDate: refDate,
                kind: kind,
                source: source,
                quota: quota,
                nav: nav,
                holders: holders,
                isin: isin,
                name: name,
                collectedAt: collectedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MktFundQuotasTable, MktFundQuotaRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $MktFundQuotasTable,
                    MktFundQuotaRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MktFundQuotasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MktFundQuotasTable,
      MktFundQuotaRow,
      $$MktFundQuotasTableFilterComposer,
      $$MktFundQuotasTableOrderingComposer,
      $$MktFundQuotasTableAnnotationComposer,
      $$MktFundQuotasTableCreateCompanionBuilder,
      $$MktFundQuotasTableUpdateCompanionBuilder,
      (
        MktFundQuotaRow,
        BaseReferences<_$AppDatabase, $MktFundQuotasTable, MktFundQuotaRow>,
      ),
      MktFundQuotaRow,
      PrefetchHooks Function()
    >;
typedef $$MktInstrumentsTableCreateCompanionBuilder =
    MktInstrumentsCompanion Function({
      required String symbol,
      required String market,
      required String source,
      Value<String?> isin,
      Value<String?> name,
      Value<String?> sourceId,
      required String collectedAt,
      Value<int> rowid,
    });
typedef $$MktInstrumentsTableUpdateCompanionBuilder =
    MktInstrumentsCompanion Function({
      Value<String> symbol,
      Value<String> market,
      Value<String> source,
      Value<String?> isin,
      Value<String?> name,
      Value<String?> sourceId,
      Value<String> collectedAt,
      Value<int> rowid,
    });

class $$MktInstrumentsTableFilterComposer
    extends Composer<_$AppDatabase, $MktInstrumentsTable> {
  $$MktInstrumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isin => $composableBuilder(
    column: $table.isin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectedAt => $composableBuilder(
    column: $table.collectedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MktInstrumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $MktInstrumentsTable> {
  $$MktInstrumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isin => $composableBuilder(
    column: $table.isin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectedAt => $composableBuilder(
    column: $table.collectedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MktInstrumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MktInstrumentsTable> {
  $$MktInstrumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get market =>
      $composableBuilder(column: $table.market, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get isin =>
      $composableBuilder(column: $table.isin, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get collectedAt => $composableBuilder(
    column: $table.collectedAt,
    builder: (column) => column,
  );
}

class $$MktInstrumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MktInstrumentsTable,
          MktInstrumentRow,
          $$MktInstrumentsTableFilterComposer,
          $$MktInstrumentsTableOrderingComposer,
          $$MktInstrumentsTableAnnotationComposer,
          $$MktInstrumentsTableCreateCompanionBuilder,
          $$MktInstrumentsTableUpdateCompanionBuilder,
          (
            MktInstrumentRow,
            BaseReferences<
              _$AppDatabase,
              $MktInstrumentsTable,
              MktInstrumentRow
            >,
          ),
          MktInstrumentRow,
          PrefetchHooks Function()
        > {
  $$MktInstrumentsTableTableManager(
    _$AppDatabase db,
    $MktInstrumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MktInstrumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MktInstrumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MktInstrumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> symbol = const Value.absent(),
                Value<String> market = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> isin = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<String> collectedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MktInstrumentsCompanion(
                symbol: symbol,
                market: market,
                source: source,
                isin: isin,
                name: name,
                sourceId: sourceId,
                collectedAt: collectedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String symbol,
                required String market,
                required String source,
                Value<String?> isin = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                required String collectedAt,
                Value<int> rowid = const Value.absent(),
              }) => MktInstrumentsCompanion.insert(
                symbol: symbol,
                market: market,
                source: source,
                isin: isin,
                name: name,
                sourceId: sourceId,
                collectedAt: collectedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MktInstrumentsTable, MktInstrumentRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $MktInstrumentsTable,
                    MktInstrumentRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MktInstrumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MktInstrumentsTable,
      MktInstrumentRow,
      $$MktInstrumentsTableFilterComposer,
      $$MktInstrumentsTableOrderingComposer,
      $$MktInstrumentsTableAnnotationComposer,
      $$MktInstrumentsTableCreateCompanionBuilder,
      $$MktInstrumentsTableUpdateCompanionBuilder,
      (
        MktInstrumentRow,
        BaseReferences<_$AppDatabase, $MktInstrumentsTable, MktInstrumentRow>,
      ),
      MktInstrumentRow,
      PrefetchHooks Function()
    >;
typedef $$DevProviderStateTableCreateCompanionBuilder =
    DevProviderStateCompanion Function({
      required String provider,
      required bool enabled,
      Value<String?> lastSuccessAt,
      Value<String?> lastErrorAt,
      Value<String?> lastError,
      Value<int> quotaUsed,
      Value<String?> quotaPeriod,
      Value<int> rowid,
    });
typedef $$DevProviderStateTableUpdateCompanionBuilder =
    DevProviderStateCompanion Function({
      Value<String> provider,
      Value<bool> enabled,
      Value<String?> lastSuccessAt,
      Value<String?> lastErrorAt,
      Value<String?> lastError,
      Value<int> quotaUsed,
      Value<String?> quotaPeriod,
      Value<int> rowid,
    });

class $$DevProviderStateTableFilterComposer
    extends Composer<_$AppDatabase, $DevProviderStateTable> {
  $$DevProviderStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorAt => $composableBuilder(
    column: $table.lastErrorAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quotaUsed => $composableBuilder(
    column: $table.quotaUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quotaPeriod => $composableBuilder(
    column: $table.quotaPeriod,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DevProviderStateTableOrderingComposer
    extends Composer<_$AppDatabase, $DevProviderStateTable> {
  $$DevProviderStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorAt => $composableBuilder(
    column: $table.lastErrorAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quotaUsed => $composableBuilder(
    column: $table.quotaUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quotaPeriod => $composableBuilder(
    column: $table.quotaPeriod,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevProviderStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevProviderStateTable> {
  $$DevProviderStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<String> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastErrorAt => $composableBuilder(
    column: $table.lastErrorAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<int> get quotaUsed =>
      $composableBuilder(column: $table.quotaUsed, builder: (column) => column);

  GeneratedColumn<String> get quotaPeriod => $composableBuilder(
    column: $table.quotaPeriod,
    builder: (column) => column,
  );
}

class $$DevProviderStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevProviderStateTable,
          DevProviderStateRow,
          $$DevProviderStateTableFilterComposer,
          $$DevProviderStateTableOrderingComposer,
          $$DevProviderStateTableAnnotationComposer,
          $$DevProviderStateTableCreateCompanionBuilder,
          $$DevProviderStateTableUpdateCompanionBuilder,
          (
            DevProviderStateRow,
            BaseReferences<
              _$AppDatabase,
              $DevProviderStateTable,
              DevProviderStateRow
            >,
          ),
          DevProviderStateRow,
          PrefetchHooks Function()
        > {
  $$DevProviderStateTableTableManager(
    _$AppDatabase db,
    $DevProviderStateTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevProviderStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevProviderStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevProviderStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> provider = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<String?> lastSuccessAt = const Value.absent(),
                Value<String?> lastErrorAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> quotaUsed = const Value.absent(),
                Value<String?> quotaPeriod = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevProviderStateCompanion(
                provider: provider,
                enabled: enabled,
                lastSuccessAt: lastSuccessAt,
                lastErrorAt: lastErrorAt,
                lastError: lastError,
                quotaUsed: quotaUsed,
                quotaPeriod: quotaPeriod,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String provider,
                required bool enabled,
                Value<String?> lastSuccessAt = const Value.absent(),
                Value<String?> lastErrorAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> quotaUsed = const Value.absent(),
                Value<String?> quotaPeriod = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevProviderStateCompanion.insert(
                provider: provider,
                enabled: enabled,
                lastSuccessAt: lastSuccessAt,
                lastErrorAt: lastErrorAt,
                lastError: lastError,
                quotaUsed: quotaUsed,
                quotaPeriod: quotaPeriod,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DevProviderStateTable, DevProviderStateRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $DevProviderStateTable,
                    DevProviderStateRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DevProviderStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevProviderStateTable,
      DevProviderStateRow,
      $$DevProviderStateTableFilterComposer,
      $$DevProviderStateTableOrderingComposer,
      $$DevProviderStateTableAnnotationComposer,
      $$DevProviderStateTableCreateCompanionBuilder,
      $$DevProviderStateTableUpdateCompanionBuilder,
      (
        DevProviderStateRow,
        BaseReferences<
          _$AppDatabase,
          $DevProviderStateTable,
          DevProviderStateRow
        >,
      ),
      DevProviderStateRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DevIdentityTableTableManager get devIdentity =>
      $$DevIdentityTableTableManager(_db, _db.devIdentity);
  $$DevSettingsTableTableManager get devSettings =>
      $$DevSettingsTableTableManager(_db, _db.devSettings);
  $$SharedSettingsTableTableManager get sharedSettings =>
      $$SharedSettingsTableTableManager(_db, _db.sharedSettings);
  $$InstitutionsTableTableManager get institutions =>
      $$InstitutionsTableTableManager(_db, _db.institutions);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$AssetsTableTableManager get assets =>
      $$AssetsTableTableManager(_db, _db.assets);
  $$FixedIncomeTermsTableTableManager get fixedIncomeTerms =>
      $$FixedIncomeTermsTableTableManager(_db, _db.fixedIncomeTerms);
  $$OperationsTableTableManager get operations =>
      $$OperationsTableTableManager(_db, _db.operations);
  $$ManualValuationsTableTableManager get manualValuations =>
      $$ManualValuationsTableTableManager(_db, _db.manualValuations);
  $$AssetAliasesTableTableManager get assetAliases =>
      $$AssetAliasesTableTableManager(_db, _db.assetAliases);
  $$HypoPortfoliosTableTableManager get hypoPortfolios =>
      $$HypoPortfoliosTableTableManager(_db, _db.hypoPortfolios);
  $$HypoHoldingsTableTableManager get hypoHoldings =>
      $$HypoHoldingsTableTableManager(_db, _db.hypoHoldings);
  $$HypoCashflowRulesTableTableManager get hypoCashflowRules =>
      $$HypoCashflowRulesTableTableManager(_db, _db.hypoCashflowRules);
  $$HypoScenariosTableTableManager get hypoScenarios =>
      $$HypoScenariosTableTableManager(_db, _db.hypoScenarios);
  $$DevSyncPeersTableTableManager get devSyncPeers =>
      $$DevSyncPeersTableTableManager(_db, _db.devSyncPeers);
  $$DevSyncHistoryTableTableManager get devSyncHistory =>
      $$DevSyncHistoryTableTableManager(_db, _db.devSyncHistory);
  $$DevBackupsTableTableManager get devBackups =>
      $$DevBackupsTableTableManager(_db, _db.devBackups);
  $$MktPricesTableTableManager get mktPrices =>
      $$MktPricesTableTableManager(_db, _db.mktPrices);
  $$MktQuotesTableTableManager get mktQuotes =>
      $$MktQuotesTableTableManager(_db, _db.mktQuotes);
  $$MktCorporateEventsTableTableManager get mktCorporateEvents =>
      $$MktCorporateEventsTableTableManager(_db, _db.mktCorporateEvents);
  $$MktIndicatorsTableTableManager get mktIndicators =>
      $$MktIndicatorsTableTableManager(_db, _db.mktIndicators);
  $$MktFxRatesTableTableManager get mktFxRates =>
      $$MktFxRatesTableTableManager(_db, _db.mktFxRates);
  $$MktTreasuryPricesTableTableManager get mktTreasuryPrices =>
      $$MktTreasuryPricesTableTableManager(_db, _db.mktTreasuryPrices);
  $$MktFundQuotasTableTableManager get mktFundQuotas =>
      $$MktFundQuotasTableTableManager(_db, _db.mktFundQuotas);
  $$MktInstrumentsTableTableManager get mktInstruments =>
      $$MktInstrumentsTableTableManager(_db, _db.mktInstruments);
  $$DevProviderStateTableTableManager get devProviderState =>
      $$DevProviderStateTableTableManager(_db, _db.devProviderState);
}
