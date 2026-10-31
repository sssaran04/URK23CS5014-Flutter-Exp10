import 'package:cloud_firestore/cloud_firestore.dart';

/// The signed-in user. The password hash and salt are never kept here.
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return AppUser(
      id: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
    );
  }

  final String id;
  final String name;
  final String email;
  final String phone;
}
