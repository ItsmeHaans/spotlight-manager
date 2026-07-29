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

  static const _lines = ['Spotlight', 'Manager'];
  static const _totalDuration = Duration(milliseconds: 1500);
  static const _navDelayAfterAnim = Duration(milliseconds: 1500);

  // --- tune these to match Figma exactly ---
  static const double _logoAspect = 588 / 392; // width:height of whiteIcon.svg

  // landscape (MacBook Air frame): icon left, text right
  static const double _landscapeIconWidthFraction = 0.24; // % of screen width
  static const double _landscapeFontFraction = 0.045; // % of screen width
  static const double _landscapeGapFraction = 0.03;

  // portrait (Frame 20): icon top, text below, centered
  static const double _portraitIconWidthFraction = 0.45; // % of screen width
  static const double _portraitFontFraction = 0.09; // % of screen width
  static const double _portraitGapFraction = 0.04;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _totalDuration)
      ..forward();
    _redirect();
  }

  Future<void> _redirect() async {
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            final isLandscape = width > height;

            final iconWidth =
                width *
                (isLandscape
                    ? _landscapeIconWidthFraction
                    : _portraitIconWidthFraction);
            final iconHeight = iconWidth / _logoAspect;
            final fontSize =
                width *
                (isLandscape
                    ? _landscapeFontFraction * 2
                    : _portraitFontFraction);
            final gap =
                width *
                (isLandscape ? _landscapeGapFraction : _portraitGapFraction);

            return Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final t = _controller.value;
                  final logo = _AnimatedLogo(
                    t: t,
                    width: iconWidth,
                    height: iconHeight,
                  );
                  final text = _AnimatedText(
                    t: t,
                    lines: _lines,
                    fontSize: fontSize,
                    alignLeft: isLandscape,
                  );

                  return isLandscape
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            logo,
                            SizedBox(width: gap),
                            text,
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            logo,
                            SizedBox(height: gap),
                            text,
                          ],
                        );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Fades + scales the logo in over the first 35% of the timeline.
class _AnimatedLogo extends StatelessWidget {
  final double t;
  final double width;
  final double height;

  const _AnimatedLogo({
    required this.t,
    required this.width,
    required this.height,
  });

  static const _start = 0.0;
  static const _end = 0.35;

  @override
  Widget build(BuildContext context) {
    final localT = ((t - _start) / (_end - _start)).clamp(0.0, 1.0);
    final eased = Curves.easeOut.transform(localT);

    return Opacity(
      opacity: eased,
      child: Transform.scale(
        scale: 0.85 + (0.15 * eased),
        child: SvgPicture.asset(
          'assets/svg/whiteLogo.png',
          width: width,
          height: height,
        ),
      ),
    );
  }
}

/// Reveals [lines] letter by letter (across both lines, in reading order),
/// each with its own fade + upward ease, staggered for a quick ripple-in.
class _AnimatedText extends StatelessWidget {
  final double t;
  final List<String> lines;
  final double fontSize;
  final bool alignLeft;

  const _AnimatedText({
    required this.t,
    required this.lines,
    required this.fontSize,
    required this.alignLeft,
  });

  static const _groupStart = 0.35;
  static const _groupEnd = 1.0;
  static const _letterSpan = 0.4;

  @override
  Widget build(BuildContext context) {
    final allLetters = lines.expand((line) => line.characters).toList();
    final n = allLetters.length;
    final groupRange = _groupEnd - _groupStart;
    final staggerRange = groupRange * (1 - _letterSpan);
    final letterDuration = groupRange * _letterSpan;

    int globalIndex = 0;

    Widget buildLetter(String letter) {
      final i = globalIndex++;
      final start = _groupStart + (n > 1 ? staggerRange * (i / (n - 1)) : 0);
      final end = start + letterDuration;
      final localT = ((t - start) / (end - start)).clamp(0.0, 1.0);
      final eased = Curves.easeOut.transform(localT);

      return Opacity(
        opacity: eased,
        child: Transform.translate(
          offset: Offset(0, (1 - eased) * 12),
          child: Text(
            letter,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.05,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: alignLeft
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: lines
          .map(
            (line) => Row(
              mainAxisSize: MainAxisSize.min,
              children: line.characters.map(buildLetter).toList(),
            ),
          )
          .toList(),
    );
  }
}
