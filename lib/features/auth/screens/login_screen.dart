import 'package:flutter/material.dart'; // native Flutter
import 'package:supabase_flutter/supabase_flutter.dart'; // native package
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import 'package:go_router/go_router.dart'; // native package

class LoginScreen extends StatefulWidget {
  // StatefulWidget, not Stateless — this screen needs to remember loading/error state
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // TODO: navigate to /home once login succeeds — added once GoRouter navigation is wired for real
    } on AuthException catch (e) {
      // native Supabase exception type
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        AppThemes.blueLight; // placeholder, same as your other widgets for now

    return Scaffold(
      // native Flutter widget — the basic screen frame
      backgroundColor: colors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Welcome back",
                style: AppTypography.heading1.copyWith(
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: "Email",
                hint: "you@example.com",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: "Password",
                controller: _passwordController,
                obscureText: true,
              ),
              if (_errorMessage != null) ...[
                // native Dart syntax — spread + conditional list items
                const SizedBox(height: AppSpacing.sm),
                Text(_errorMessage!, style: TextStyle(color: colors.error)),
              ],
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: "Log In",
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),
              TextButton(
                // native Flutter
                onPressed: () =>
                    context.go('/signup'), // native GoRouter method
                child: const Text("Don't have an account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
