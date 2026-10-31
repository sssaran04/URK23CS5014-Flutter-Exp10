import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../utils/password_hasher.dart';

/// Checks a login against the users collection. It only ever reads.
class AuthService {
  AuthService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const Duration _timeout = Duration(seconds: 15);

  final FirebaseFirestore _firestore;

  /// Returns the user if the credentials match, otherwise null.
  Future<AppUser?> login(String email, String password) async {
    // Firestore READ: fetch the user by email, always from the server.
    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email.trim().toLowerCase())
        .get(const GetOptions(source: Source.server))
        .timeout(_timeout);

    // Manual matching: hash salt + entered password, compare with the stored hash.
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final salt = data['salt'] as String?;
      final storedHash = data['password'] as String?;
      if (salt != null &&
          storedHash != null &&
          hashPassword(salt, password) == storedHash) {
        return AppUser.fromFirestore(doc);
      }
    }
    return null;
  }
}
