import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

/// `DATA_BLOB` do Windows.
final class _DataBlob extends Struct {
  @Uint32()
  external int cbData;

  external Pointer<Uint8> pbData;
}

typedef _CryptNative = Int32 Function(
  Pointer<_DataBlob> dataIn,
  Pointer<Utf16> description,
  Pointer<_DataBlob> entropy,
  Pointer<Void> reserved,
  Pointer<Void> prompt,
  Uint32 flags,
  Pointer<_DataBlob> dataOut,
);
typedef _CryptDart = int Function(
  Pointer<_DataBlob> dataIn,
  Pointer<Utf16> description,
  Pointer<_DataBlob> entropy,
  Pointer<Void> reserved,
  Pointer<Void> prompt,
  int flags,
  Pointer<_DataBlob> dataOut,
);

/// Proteção de dados do Windows (DPAPI) para o usuário logado
/// (`CryptProtectData`/`CryptUnprotectData`). Só quem está na mesma conta do
/// Windows, no mesmo PC, consegue abrir o que foi protegido.
abstract final class Dpapi {
  static const _uiForbidden = 0x1;

  static final _crypt32 = DynamicLibrary.open('crypt32.dll');
  static final _kernel32 = DynamicLibrary.open('kernel32.dll');
  static final _protect = _crypt32.lookupFunction<_CryptNative, _CryptDart>(
    'CryptProtectData',
  );
  static final _unprotect = _crypt32.lookupFunction<_CryptNative, _CryptDart>(
    'CryptUnprotectData',
  );
  static final _localFree = _kernel32
      .lookupFunction<
        Pointer<Void> Function(Pointer<Void>),
        Pointer<Void> Function(Pointer<Void>)
      >('LocalFree');

  static Uint8List protect(Uint8List data, Uint8List entropy) =>
      _run(_protect, data, entropy, 'CryptProtectData');

  /// Lança [StateError] se o dado não puder ser aberto (outro usuário, outro
  /// PC ou dado alterado).
  static Uint8List unprotect(Uint8List data, Uint8List entropy) =>
      _run(_unprotect, data, entropy, 'CryptUnprotectData');

  static Uint8List _run(
    _CryptDart fn,
    Uint8List data,
    Uint8List entropy,
    String name,
  ) {
    return using((arena) {
      Pointer<_DataBlob> blob(Uint8List bytes) {
        final buffer = arena<Uint8>(bytes.isEmpty ? 1 : bytes.length);
        buffer.asTypedList(bytes.length).setAll(0, bytes);
        final b = arena<_DataBlob>();
        b.ref
          ..cbData = bytes.length
          ..pbData = buffer;
        return b;
      }

      final input = blob(data);
      final extra = blob(entropy);
      final output = arena<_DataBlob>();
      final ok = fn(
        input,
        nullptr,
        extra,
        nullptr,
        nullptr,
        _uiForbidden,
        output,
      );
      // Os buffers de entrada têm dados sensíveis: zera antes de liberar.
      input.ref.pbData.asTypedList(data.length).fillRange(0, data.length, 0);
      if (ok == 0) throw StateError('$name falhou');
      try {
        return Uint8List.fromList(
          output.ref.pbData.asTypedList(output.ref.cbData),
        );
      } finally {
        output.ref.pbData
            .asTypedList(output.ref.cbData)
            .fillRange(0, output.ref.cbData, 0);
        _localFree(output.ref.pbData.cast());
      }
    });
  }
}
