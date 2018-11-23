import 'dart:convert' as convert;

class Cartoon {
  final String base64;

  const Cartoon(this.base64);

  Cartoon.fromBytes(List<int> bytes) : this(convert.base64Encode(bytes));

  List<int> get bytes => convert.base64Decode(base64);
}