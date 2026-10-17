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
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (fixedIncomeTermsRefs) db.fixedIncomeTerms,
                    if (operationsRefs) db.operations,
                    if (manualValuationsRefs) db.manualValuations,
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
}
