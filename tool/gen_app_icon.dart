// Gera o ícone do app a partir de assets/branding/patrion-simbolo.svg.
//
// Uso (na raiz do repositório):
//   dart run tool/gen_app_icon.dart
//
// Saídas:
//   windows/runner/resources/app_icon.ico   16 a 256 px (DECISIONS D-12)
//   assets/branding/patrion-simbolo-256.png símbolo usado dentro do app
//
// O SVG do símbolo só usa <rect> (com cantos arredondados) e <polygon> com
// cores chapadas, então este script rasteriza essas duas formas com
// superamostragem, sem depender de Inkscape ou ImageMagick. Qualquer outro
// elemento gráfico no SVG interrompe o script, para não gerar um ícone
// diferente do desenho.

import 'dart:io';
import 'dart:typed_data';

const _svgPath = 'assets/branding/patrion-simbolo.svg';
const _icoPath = 'windows/runner/resources/app_icon.ico';
const _pngPath = 'assets/branding/patrion-simbolo-256.png';
const _icoSizes = [16, 20, 24, 32, 40, 48, 64, 128, 256];

void main() {
  final svg = File(_svgPath).readAsStringSync();
  final drawing = _Drawing.parse(svg);

  final images = <int, Uint8List>{
    for (final size in _icoSizes) size: drawing.render(size),
  };

  File(_icoPath).writeAsBytesSync(_encodeIco(images));
  File(_pngPath).writeAsBytesSync(_encodePng(256, 256, images[256]!));
  stdout.writeln('Gerados $_icoPath (${_icoSizes.join(', ')} px) e $_pngPath');
}

// ---------------------------------------------------------------------------
// Leitura do SVG
// ---------------------------------------------------------------------------

abstract class _Shape {
  _Shape(this.color);

  /// RGBA, 0 a 255.
  final List<int> color;

  bool contains(double x, double y);
}

class _RoundRect extends _Shape {
  _RoundRect(this.x, this.y, this.w, this.h, this.r, super.color);

  final double x, y, w, h, r;

  @override
  bool contains(double px, double py) {
    if (px < x || py < y || px > x + w || py > y + h) return false;
    final cx = px.clamp(x + r, x + w - r);
    final cy = py.clamp(y + r, y + h - r);
    final dx = px - cx, dy = py - cy;
    return dx * dx + dy * dy <= r * r;
  }
}

class _Polygon extends _Shape {
  _Polygon(this.points, super.color);

  final List<double> points; // x0, y0, x1, y1, ...

  @override
  bool contains(double px, double py) {
    // Regra par-ímpar (raio horizontal).
    var inside = false;
    final n = points.length ~/ 2;
    for (var i = 0, j = n - 1; i < n; j = i++) {
      final xi = points[2 * i], yi = points[2 * i + 1];
      final xj = points[2 * j], yj = points[2 * j + 1];
      if ((yi > py) != (yj > py) &&
          px < (xj - xi) * (py - yi) / (yj - yi) + xi) {
        inside = !inside;
      }
    }
    return inside;
  }
}

class _Drawing {
  _Drawing(this.width, this.height, this.shapes);

  factory _Drawing.parse(String svg) {
    final noComments = svg.replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');
    final viewBox = RegExp(r'viewBox="([^"]+)"').firstMatch(noComments);
    if (viewBox == null) throw const FormatException('SVG sem viewBox');
    final vb = _numbers(viewBox.group(1)!);
    if (vb[0] != 0 || vb[1] != 0) {
      throw const FormatException('viewBox precisa começar em 0 0');
    }

    final shapes = <_Shape>[];
    for (final tag in RegExp(r'<(\w+)([^>]*)>').allMatches(noComments)) {
      final name = tag.group(1)!;
      final attrs = _attributes(tag.group(2)!);
      switch (name) {
        case 'svg':
          continue;
        case 'rect':
          final r = double.parse(attrs['rx'] ?? attrs['ry'] ?? '0');
          shapes.add(
            _RoundRect(
              double.parse(attrs['x'] ?? '0'),
              double.parse(attrs['y'] ?? '0'),
              double.parse(attrs['width']!),
              double.parse(attrs['height']!),
              r,
              _color(attrs['fill']!),
            ),
          );
        case 'polygon':
          shapes.add(
            _Polygon(_numbers(attrs['points']!), _color(attrs['fill']!)),
          );
        default:
          throw FormatException('Elemento SVG não suportado: <$name>');
      }
    }
    return _Drawing(vb[2], vb[3], shapes);
  }

  final double width, height;
  final List<_Shape> shapes;

  /// Rasteriza em [size] x [size] px. Devolve RGBA (não pré-multiplicado),
  /// linha a linha, de cima para baixo.
  Uint8List render(int size) {
    final samples = size <= 64 ? 16 : 8;
    final out = Uint8List(size * size * 4);
    final sx = width / size, sy = height / size;
    for (var py = 0; py < size; py++) {
      for (var px = 0; px < size; px++) {
        double r = 0, g = 0, b = 0, a = 0;
        for (var j = 0; j < samples; j++) {
          for (var i = 0; i < samples; i++) {
            final x = (px + (i + 0.5) / samples) * sx;
            final y = (py + (j + 0.5) / samples) * sy;
            for (var k = shapes.length - 1; k >= 0; k--) {
              if (shapes[k].contains(x, y)) {
                final c = shapes[k].color;
                final alpha = c[3] / 255;
                r += c[0] * alpha;
                g += c[1] * alpha;
                b += c[2] * alpha;
                a += alpha;
                break;
              }
            }
          }
        }
        final o = (py * size + px) * 4;
        if (a > 0) {
          out[o] = (r / a).round();
          out[o + 1] = (g / a).round();
          out[o + 2] = (b / a).round();
          out[o + 3] = (a / (samples * samples) * 255).round();
        }
      }
    }
    return out;
  }

  static List<double> _numbers(String text) => text
      .trim()
      .split(RegExp(r'[\s,]+'))
      .map(double.parse)
      .toList(growable: false);

  static Map<String, String> _attributes(String text) => {
    for (final m in RegExp(r'([\w:-]+)="([^"]*)"').allMatches(text))
      m.group(1)!: m.group(2)!,
  };

  static List<int> _color(String hex) {
    final match = RegExp(r'^#([0-9a-fA-F]{6})$').firstMatch(hex);
    if (match == null) throw FormatException('Cor não suportada: $hex');
    final v = int.parse(match.group(1)!, radix: 16);
    return [(v >> 16) & 0xFF, (v >> 8) & 0xFF, v & 0xFF, 255];
  }
}

// ---------------------------------------------------------------------------
// Codificação PNG e ICO
// ---------------------------------------------------------------------------

Uint8List _encodePng(int width, int height, Uint8List rgba) {
  final raw = BytesBuilder();
  for (var y = 0; y < height; y++) {
    raw.addByte(0); // filtro "nenhum"
    raw.add(rgba.sublist(y * width * 4, (y + 1) * width * 4));
  }
  final ihdr = ByteData(13)
    ..setUint32(0, width)
    ..setUint32(4, height)
    ..setUint8(8, 8) // bits por canal
    ..setUint8(9, 6) // RGBA
    ..setUint8(10, 0)
    ..setUint8(11, 0)
    ..setUint8(12, 0);
  final png = BytesBuilder()
    ..add([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
    ..add(_chunk('IHDR', ihdr.buffer.asUint8List()))
    ..add(_chunk('IDAT', ZLibCodec(level: 9).encode(raw.takeBytes())))
    ..add(_chunk('IEND', const []));
  return png.takeBytes();
}

Uint8List _chunk(String type, List<int> data) {
  final typeBytes = type.codeUnits;
  final out = ByteData(12 + data.length);
  out.setUint32(0, data.length);
  for (var i = 0; i < 4; i++) {
    out.setUint8(4 + i, typeBytes[i]);
  }
  for (var i = 0; i < data.length; i++) {
    out.setUint8(8 + i, data[i]);
  }
  out.setUint32(8 + data.length, _crc32([...typeBytes, ...data]));
  return out.buffer.asUint8List();
}

final _crcTable = List<int>.generate(256, (n) {
  var c = n;
  for (var k = 0; k < 8; k++) {
    c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
  }
  return c;
});

int _crc32(List<int> bytes) {
  var c = 0xFFFFFFFF;
  for (final b in bytes) {
    c = _crcTable[(c ^ b) & 0xFF] ^ (c >> 8);
  }
  return c ^ 0xFFFFFFFF;
}

/// Bitmap do ícone no formato DIB de 32 bits (BGRA, de baixo para cima),
/// seguido da máscara AND (toda zero, a transparência vem do alfa).
Uint8List _encodeDib(int size, Uint8List rgba) {
  final maskStride = ((size + 31) ~/ 32) * 4;
  final header = ByteData(40)
    ..setUint32(0, 40, Endian.little)
    ..setInt32(4, size, Endian.little)
    ..setInt32(8, size * 2, Endian.little) // cor + máscara
    ..setUint16(12, 1, Endian.little)
    ..setUint16(14, 32, Endian.little)
    ..setUint32(16, 0, Endian.little) // BI_RGB
    ..setUint32(20, size * size * 4 + maskStride * size, Endian.little);
  final out = BytesBuilder()..add(header.buffer.asUint8List());
  for (var y = size - 1; y >= 0; y--) {
    for (var x = 0; x < size; x++) {
      final o = (y * size + x) * 4;
      out.add([rgba[o + 2], rgba[o + 1], rgba[o], rgba[o + 3]]);
    }
  }
  out.add(Uint8List(maskStride * size));
  return out.takeBytes();
}

/// ICO com DIB nos tamanhos menores e PNG no de 256 px (formato aceito
/// desde o Windows Vista e o que o Explorer usa nas visualizações grandes).
Uint8List _encodeIco(Map<int, Uint8List> images) {
  final sizes = images.keys.toList()..sort();
  final payloads = [
    for (final s in sizes)
      s >= 256 ? _encodePng(s, s, images[s]!) : _encodeDib(s, images[s]!),
  ];
  final header = ByteData(6 + 16 * sizes.length)
    ..setUint16(0, 0, Endian.little)
    ..setUint16(2, 1, Endian.little) // ícone
    ..setUint16(4, sizes.length, Endian.little);
  var offset = header.lengthInBytes;
  for (var i = 0; i < sizes.length; i++) {
    final e = 6 + 16 * i;
    final s = sizes[i];
    header
      ..setUint8(e, s >= 256 ? 0 : s)
      ..setUint8(e + 1, s >= 256 ? 0 : s)
      ..setUint8(e + 2, 0)
      ..setUint8(e + 3, 0)
      ..setUint16(e + 4, 1, Endian.little)
      ..setUint16(e + 6, 32, Endian.little)
      ..setUint32(e + 8, payloads[i].length, Endian.little)
      ..setUint32(e + 12, offset, Endian.little);
    offset += payloads[i].length;
  }
  final out = BytesBuilder()..add(header.buffer.asUint8List());
  payloads.forEach(out.add);
  return out.takeBytes();
}
