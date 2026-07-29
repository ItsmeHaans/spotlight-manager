import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  static const _buttonColor = Color(0xFF4AB8FB);
  static const _cardColor = Color(0xFF6E7A85); // matches login card

  Future<void> _handleSignup() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = "Passwords don't match");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await ref.read(themeProvider.notifier).loadFromProfile();
      // Redirect happens automatically via GoRouter's auth listener, same as Login
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xFF1488FC), // bottom — matches splash/login
              Color(0xFF50BCFC), // top — matches splash/login
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;
              final cardWidth = isDesktop
                  ? 460.0
                  : constraints.maxWidth * 0.78; // matches login proportion

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Container(
                    width: cardWidth,
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 32 : 24,
                      vertical: isDesktop ? 32 : 24,
                    ),
                    decoration: BoxDecoration(
                      color: _cardColor.withOpacity(0.40),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: isDesktop ? 34 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: isDesktop ? 28 : 22),
                        _AuthField(
                          controller: _emailController,
                          iconAsset: 'assets/svg/username.svg',
                          keyboardType: TextInputType.emailAddress,
                          cardColor: _cardColor,
                        ),
                        const SizedBox(height: 14),
                        _AuthField(
                          controller: _passwordController,
                          iconAsset: 'assets/svg/password.svg',
                          obscureText: true,
                          cardColor: _cardColor,
                        ),
                        const SizedBox(height: 14),
                        _AuthField(
                          controller: _confirmPasswordController,
                          iconAsset: 'assets/svg/password.svg',
                          obscureText: true,
                          cardColor: _cardColor,
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.redAccent),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        SizedBox(height: isDesktop ? 26 : 20),
                        _AuthButton(
                          label: 'Sign Up',
                          isLoading: _isLoading,
                          onPressed: _handleSignup,
                          color: _buttonColor,
                        ),
                        const SizedBox(height: 14),
                        _LoginLink(onTap: () => context.go('/login')),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Same pill-shaped field as the login screen — kept as a private
/// copy here (rather than importing from login_screen.dart) since
/// login_screen's version is private (_LoginField). If you'd rather
/// share one widget between both screens, pull this out into
/// shared/widgets/auth_field.dart and I'll update both screens to use it.
class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String iconAsset;
  final bool obscureText;
  final TextInputType keyboardType;
  final Color cardColor;

  const _AuthField({
    required this.controller,
    required this.iconAsset,
    required this.cardColor,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.67),
        borderRadius: BorderRadius.circular(28),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SvgPicture.asset(
              iconAsset,
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;
  final Color color;

  const _AuthButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: color,
          disabledBackgroundColor: color.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  key: const ValueKey('label'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

class _LoginLink extends StatelessWidget {
  final VoidCallback onTap;
  const _LoginLink({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RichText(
        text: const TextSpan(
          style: TextStyle(color: Colors.white, fontSize: 13),
          children: [
            TextSpan(text: 'Already have an account? '),
            TextSpan(
              text: 'Log In',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
