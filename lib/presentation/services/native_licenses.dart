import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Licenças das bibliotecas nativas que o app distribui e que o Flutter não
/// conhece (não são pacotes Dart): o SQLCipher e o OpenSSL embutido nele
/// (`sqlcipher.dll`; DECISIONS D-32 e D-38). As dos pacotes Dart e do motor
/// do Flutter já entram sozinhas na tela de licenças.
abstract final class NativeLicenses {
  static var _registered = false;

  /// Registra uma vez só (a tela de licenças pode abrir várias vezes).
  static void ensureRegistered() {
    if (_registered) return;
    _registered = true;
    LicenseRegistry.addLicense(() async* {
      yield LicenseEntryWithLineBreaks(const [
        'SQLCipher',
      ], await rootBundle.loadString('assets/licenses/sqlcipher.txt'));
      yield LicenseEntryWithLineBreaks(const [
        'OpenSSL',
      ], await rootBundle.loadString('assets/licenses/openssl.txt'));
    });
  }
}
