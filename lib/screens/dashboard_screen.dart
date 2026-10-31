import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../widgets/primary_button.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.user,
    required this.authService,
  });

  final AppUser user;
  final AuthService authService;

  void _logout(BuildContext context) {
    // Clears the stack, so Back cannot return to the dashboard.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => LoginScreen(authService: authService),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome, ${user.name}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.email_outlined,
                          color: Colors.blue,
                        ),
                        title: const Text('Email'),
                        subtitle: Text(user.email),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.phone_outlined,
                          color: Colors.teal,
                        ),
                        title: const Text('Phone'),
                        subtitle: Text(user.phone),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),
              PrimaryButton(label: 'Logout', onPressed: () => _logout(context)),
            ],
          ),
        ),
      ),
    );
  }
}
