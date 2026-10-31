import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Returns the SHA-256 hex of salt + password.
String hashPassword(String salt, String password) {
  return sha256.convert(utf8.encode(salt + password)).toString();
}
