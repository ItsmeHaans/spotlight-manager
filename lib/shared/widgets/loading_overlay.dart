import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme.dart';

import '../../core/theme/theme_provider.dart';

class LoadingOverlay extends ConsumerWidget {
  final bool isLoading;
  final Widget
  child; // native concept: any widget can be a "child" — Flutter's core composition pattern

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppThemes.of(
      ref.watch(themeProvider),
    ); // placeholder, same as the others for now

    return Stack(
      // native Flutter widget — stacks children on top of each other, not side by side
      children: [
        child, // your actual screen content, underneath
        if (isLoading) // native Dart syntax — conditionally include a widget in a list
          Container(
            color: colors.secondary.withOpacity(
              0.5,
            ), // native property — semi-transparent overlay
            child: Center(
              child: CircularProgressIndicator(
                color: colors.primary,
              ), // native Flutter widget — the spinning loading indicator
            ),
          ),
      ],
    );
  }
}
