import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/validators.dart';
import '../widgets/app_logo.dart';
import '../widgets/primary_button.dart';
import '../widgets/rounded_input_field.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loading) return;
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    String? error;
    try {
      final user = await widget.authService.login(
        _emailController.text,
        _passwordController.text,
      );
      if (!mounted) return;
      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) =>
                DashboardScreen(user: user, authService: widget.authService),
          ),
        );
        return;
      }
      error = 'Invalid email or password';
    } on TimeoutException {
      error = 'Network error. Check your connection and try again.';
    } on FirebaseException catch (e) {
      error = e.code == 'permission-denied'
          ? 'Permission denied while reading users.'
          : 'Network error. Check your connection and try again.';
    }
    if (mounted) {
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppLogo(),
                    const SizedBox(height: 56),
                    RoundedInputField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      validator: validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                    ),
                    const SizedBox(height: 22),
                    RoundedInputField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      validator: validatePassword,
                      obscureText: _hidePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _login(),
                      suffixIcon: IconButton(
                        tooltip: _hidePassword
                            ? 'Show password'
                            : 'Hide password',
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _hidePassword = !_hidePassword),
                      ),
                    ),
                    const SizedBox(height: 36),
                    PrimaryButton(
                      label: 'Login',
                      loading: _loading,
                      onPressed: _login,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
