import 'dart:convert';
import 'package:crypto/crypto.dart';

class HashFunc {
  String getHash(String text) {
    var bytes = utf8.encode(text);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
}
