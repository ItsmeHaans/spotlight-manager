import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _appName = 'YourAppName'; // swap in your real app name
  static const _totalDuration = Duration(milliseconds: 1500);
  static const _navDelayAfterAnim = Duration(milliseconds: 700);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _totalDuration)
      ..forward();
    _redirect();
  }

  Future<void> _redirect() async {
    // wait for the animation to finish, then a short beat, then navigate
    await Future.delayed(_totalDuration + _navDelayAfterAnim);
    if (!mounted) return;

    final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
    context.go(isLoggedIn ? '/home' : '/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    // --- sizes pulled from Figma ---
    // desktop frame 1731x1080 -> used ~1:1 as logical px
    // phone frame 1080x2400 -> assumed 3x export, divided by 3 for logical px
    final imageSize = isDesktop
        ? const Size(588, 392)
        : const Size(588 / 3, 392 / 3); // ~196 x 131
    final fontSize = isDesktop ? 150.0 : 120.0 / 3; // 150 desktop, 40 phone

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xFF1488FC), // bottom
              Color(0xFF50BCFC), // top
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AnimatedLogo(t: t, size: imageSize),
                  const SizedBox(height: 24),
                  _AnimatedLetters(t: t, text: _appName, fontSize: fontSize),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Fades + scales the logo in over the first 35% of the timeline.
class _AnimatedLogo extends StatelessWidget {
  final double t;
  final Size size;

  const _AnimatedLogo({required this.t, required this.size});

  static const _start = 0.0;
  static const _end = 0.35;

  @override
  Widget build(BuildContext context) {
    final localT = ((t - _start) / (_end - _start)).clamp(0.0, 1.0);
    final eased = Curves.easeOut.transform(localT);

    return Opacity(
      opacity: eased,
      child: Transform.scale(
        scale: 0.85 + (0.15 * eased), // 0.85 -> 1.0
        child: SvgPicture.asset(
          'assets/svg/whiteIcon.svg',
          width: size.width,
          height: size.height,
        ),
      ),
    );
  }
}

/// Reveals [text] one letter at a time, each with its own fade + upward ease,
/// staggered so letters ripple in quickly rather than popping together.
class _AnimatedLetters extends StatelessWidget {
  final double t;
  final String text;
  final double fontSize;

  const _AnimatedLetters({
    required this.t,
    required this.text,
    required this.fontSize,
  });

  // text animates across this slice of the overall timeline
  static const _groupStart = 0.35;
  static const _groupEnd = 1.0;
  // how long (as a fraction of the group range) each individual letter takes
  static const _letterSpan = 0.4;

  @override
  Widget build(BuildContext context) {
    final letters = text.characters.toList();
    final n = letters.length;
    final groupRange = _groupEnd - _groupStart;
    // available range for stagger start-points, so the last letter's
    // animation still finishes exactly at _groupEnd
    final staggerRange = groupRange * (1 - _letterSpan);
    final letterDuration = groupRange * _letterSpan;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(letters.length, (i) {
        final start = _groupStart + (n > 1 ? staggerRange * (i / (n - 1)) : 0);
        final end = start + letterDuration;

        final localT = ((t - start) / (end - start)).clamp(0.0, 1.0);
        final eased = Curves.easeOut.transform(localT);

        return Opacity(
          opacity: eased,
          child: Transform.translate(
            offset: Offset(0, (1 - eased) * 12), // subtle rise while fading in
            child: Text(
              letters[i],
              style: GoogleFonts.inter(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        );
      }),
    );
  }
}
