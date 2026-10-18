import 'package:decimal/decimal.dart';

/// Número JSON lido sem passar por ponto flutuante: guarda o texto exato
/// (regra 6). O `jsonDecode` do Dart converteria `5.61470` em ponto
/// flutuante.
class JsonNumber {
  const JsonNumber(this.text);

  final String text;

  Decimal get decimal => Decimal.parse(text);

  /// Para inteiros (timestamps, contagens). Lança [FormatException] se não
  /// for inteiro.
  int get integer => int.parse(text);

  @override
  bool operator ==(Object other) => other is JsonNumber && other.text == text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => text;
}

/// Leitor de JSON que devolve números como [JsonNumber] (objetos viram
/// `Map<String, Object?>`, listas `List<Object?>`). Usado nas respostas dos
/// provedores de dados de mercado.
abstract final class ExactJson {
  static Object? decode(String source) {
    final parser = _Parser(source);
    parser.skipSpace();
    final value = parser.value();
    parser.skipSpace();
    if (!parser.atEnd) parser.fail('conteúdo depois do fim');
    return value;
  }
}

class _Parser {
  _Parser(this.s);

  final String s;
  int i = 0;

  bool get atEnd => i >= s.length;

  Never fail(String what) =>
      throw FormatException('JSON inválido: $what', s, i);

  void skipSpace() {
    while (i < s.length) {
      final c = s.codeUnitAt(i);
      if (c == 0x20 || c == 0x0A || c == 0x0D || c == 0x09 || c == 0xFEFF) {
        i++;
      } else {
        break;
      }
    }
  }

  Object? value() {
    if (atEnd) fail('fim inesperado');
    final c = s[i];
    switch (c) {
      case '{':
        return object();
      case '[':
        return array();
      case '"':
        return string();
      case 't':
        return literal('true', true);
      case 'f':
        return literal('false', false);
      case 'n':
        return literal('null', null);
      default:
        return number();
    }
  }

  Object? literal(String word, Object? result) {
    if (!s.startsWith(word, i)) fail('valor desconhecido');
    i += word.length;
    return result;
  }

  Map<String, Object?> object() {
    i++; // {
    final map = <String, Object?>{};
    skipSpace();
    if (!atEnd && s[i] == '}') {
      i++;
      return map;
    }
    while (true) {
      skipSpace();
      if (atEnd || s[i] != '"') fail('chave esperada');
      final key = string();
      skipSpace();
      if (atEnd || s[i] != ':') fail('":" esperado');
      i++;
      skipSpace();
      map[key] = value();
      skipSpace();
      if (atEnd) fail('objeto sem fim');
      if (s[i] == ',') {
        i++;
        continue;
      }
      if (s[i] == '}') {
        i++;
        return map;
      }
      fail('"," ou "}" esperado');
    }
  }

  List<Object?> array() {
    i++; // [
    final list = <Object?>[];
    skipSpace();
    if (!atEnd && s[i] == ']') {
      i++;
      return list;
    }
    while (true) {
      skipSpace();
      list.add(value());
      skipSpace();
      if (atEnd) fail('lista sem fim');
      if (s[i] == ',') {
        i++;
        continue;
      }
      if (s[i] == ']') {
        i++;
        return list;
      }
      fail('"," ou "]" esperado');
    }
  }

  String string() {
    i++; // "
    final out = StringBuffer();
    while (true) {
      if (atEnd) fail('texto sem fim');
      final c = s[i];
      if (c == '"') {
        i++;
        return out.toString();
      }
      if (c == r'\') {
        if (i + 1 >= s.length) fail('escape sem fim');
        final e = s[i + 1];
        i += 2;
        switch (e) {
          case '"' || r'\' || '/':
            out.write(e);
          case 'b':
            out.write('\b');
          case 'f':
            out.write('\f');
          case 'n':
            out.write('\n');
          case 'r':
            out.write('\r');
          case 't':
            out.write('\t');
          case 'u':
            if (i + 4 > s.length) fail('escape \\u incompleto');
            final code = int.tryParse(s.substring(i, i + 4), radix: 16);
            if (code == null) fail('escape \\u inválido');
            out.writeCharCode(code);
            i += 4;
          default:
            fail('escape inválido');
        }
        continue;
      }
      out.write(c);
      i++;
    }
  }

  JsonNumber number() {
    final start = i;
    if (s[i] == '-') i++;
    var digits = 0;
    while (i < s.length && _isDigit(s.codeUnitAt(i))) {
      i++;
      digits++;
    }
    if (i < s.length && s[i] == '.') {
      i++;
      while (i < s.length && _isDigit(s.codeUnitAt(i))) {
        i++;
        digits++;
      }
    }
    if (i < s.length && (s[i] == 'e' || s[i] == 'E')) {
      i++;
      if (i < s.length && (s[i] == '+' || s[i] == '-')) i++;
      while (i < s.length && _isDigit(s.codeUnitAt(i))) {
        i++;
      }
    }
    if (digits == 0) fail('número inválido');
    return JsonNumber(s.substring(start, i));
  }

  static bool _isDigit(int c) => c >= 0x30 && c <= 0x39;
}
