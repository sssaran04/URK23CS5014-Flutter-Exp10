final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Email is required';
  if (!_emailPattern.hasMatch(email)) return 'Enter a valid email address';
  return null;
}

String? validatePassword(String? value) {
  final password = value ?? '';
  if (password.isEmpty) return 'Password is required';
  if (password.length < 6) return 'Password must be at least 6 characters';
  return null;
}
