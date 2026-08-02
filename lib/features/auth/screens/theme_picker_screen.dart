import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/router/app_router.dart' show invalidateProfileCache;
import '../../../shared/widgets/app_button.dart';
import '../../../core/router/app_router.dart';

/// Static per-theme color pair. These are the raw brand hex values for the
/// picker itself — intentionally NOT pulled from AppThemes, since AppThemes
/// resolves off `themeProvider` (i.e. the theme the user has already
/// committed to), and this screen is where that choice is made.
class _ThemeOption {
  final String label;
  final AppThemeName name;
  final Color primary;
  final Color secondary;

  const _ThemeOption({
    required this.label,
    required this.name,
    required this.primary,
    required this.secondary,
  });
}

const _kThemeOptions = <_ThemeOption>[
  _ThemeOption(
    label: 'Blue',
    name: AppThemeName.blueLight,
    primary: Color(0xFF445D82),
    secondary: Color(0xFF7C93B3),
  ),
  _ThemeOption(
    label: 'Yellow',
    name: AppThemeName.yellowLight,
    primary: Color(0xFFC9BE3F),
    secondary: Color(0xFFEDE9B8),
  ),
  _ThemeOption(
    label: 'Silver',
    name: AppThemeName.silverLight,
    primary: Color(0xFF6E7A85),
    secondary: Color(0xFFC7CDD3),
  ),
  _ThemeOption(
    label: 'Pink',
    name: AppThemeName.pinkLight,
    primary: Color(0xFFE0899C),
    secondary: Color(0xFFF2C6CE),
  ),
];

/// Neutral backdrop shown before the user has picked anything.
const _kNeutralBackground = Color(0xFF2A2F3A);

const _kDesktopBreakpoint = 700.0;
const _kAnimDuration = Duration(milliseconds: 500);

class ThemePickerScreen extends ConsumerStatefulWidget {
  const ThemePickerScreen({super.key});

  @override
  ConsumerState<ThemePickerScreen> createState() => _ThemePickerScreenState();
}

class _ThemePickerScreenState extends ConsumerState<ThemePickerScreen> {
  bool _isSaving = false;
  _ThemeOption? _selected;

  /// Tapping a circle only previews the theme — background + ring animate,
  /// nothing is saved yet.
  void _previewTheme(_ThemeOption option) {
    if (_isSaving) return;
    setState(() => _selected = option);
  }

  /// The Confirm button is what actually commits the choice.
  Future<void> _confirmTheme() async {
    final option = _selected;
    if (option == null || _isSaving) return;

    setState(() => _isSaving = true);

    await ref.read(themeProvider.notifier).setTheme(option.name);

    final userId = Supabase.instance.client.auth.currentUser!.id;
    await Supabase.instance.client.from('profiles').upsert({
      'id': userId,
      'theme_preference': option.name.name,
      'theme_chosen': true,
    });

    markThemeChosen(userId); // CHANGED — was invalidateProfileCache()
    if (mounted) context.go('/profileform');
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final backgroundColor = _selected?.primary ?? _kNeutralBackground;

    return Scaffold(
      body: AnimatedContainer(
        duration: _kAnimDuration,
        curve: Curves.easeInOut,
        color: backgroundColor,
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ---- decorative blobs ----
            ..._buildBlobs(screenSize),

            // ---- foreground content ----
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= _kDesktopBreakpoint;
                  final contentWidth = isDesktop
                      ? constraints.maxWidth * 0.42
                      : constraints.maxWidth;

                  return Center(
                    child: SizedBox(
                      width: contentWidth,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: contentWidth * 0.06,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: contentWidth * (isDesktop ? 0.10 : 0.07),
                            ),
                            AnimatedDefaultTextStyle(
                              duration: _kAnimDuration,
                              curve: Curves.easeInOut,
                              style: AppTypography.heading1.copyWith(
                                color: Colors.white,
                                fontSize: 38,
                              ),
                              child: const Text(
                                'Pick your favorite color',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              height: contentWidth * (isDesktop ? 0.07 : 0.08),
                            ),
                            _CircleGrid(
                              options: _kThemeOptions,
                              selected: _selected,
                              contentWidth: contentWidth,
                              isDesktop: isDesktop,
                              onTap: _isSaving ? null : _previewTheme,
                            ),
                            SizedBox(
                              height: contentWidth * (isDesktop ? 0.07 : 0.09),
                            ),
                            _ConfirmButton(
                              option: _selected,
                              contentWidth: contentWidth,
                              isSaving: _isSaving,
                              onPressed: _confirmTheme,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBlobs(Size screenSize) {
    final shortSide = screenSize.shortestSide;
    final isDesktop = screenSize.width >= _kDesktopBreakpoint;

    // (dx%, dy%, size% of shortest screen side, opacity).
    // Kept strictly in the corners / edges — the center column (grid +
    // confirm button) stays completely clear so nothing sits behind it.
    // Desktop keeps content to the middle ~42% of the width, so the safe
    // "no-blob" zone is roughly x: 0.29–0.71. Mobile content spans the
    // full width, so blobs there are pushed further into the corners and
    // kept small so they never creep behind the grid/button.
    final specs = isDesktop
        ? const [
            (-0.16, -0.14, 0.34, 0.10),
            (0.70, -0.12, 0.30, 0.09),
            (0.30, -0.18, 0.16, 0.06),
            (-0.20, 0.36, 0.22, 0.07),
            (0.90, 0.30, 0.24, 0.07),
            (-0.22, 0.78, 0.34, 0.09),
            (0.86, 0.76, 0.44, 0.10),
            (0.06, 0.92, 0.16, 0.05),
            (0.60, 0.94, 0.14, 0.05),
          ]
        : const [
            (-0.22, -0.08, 0.34, 0.10),
            (0.78, -0.10, 0.32, 0.09),
            (0.34, -0.16, 0.18, 0.06),
            (-0.28, 0.42, 0.24, 0.07),
            (1.02, 0.46, 0.26, 0.07),
            (-0.24, 0.86, 0.34, 0.09),
            (0.86, 0.90, 0.40, 0.10),
          ];

    return specs.map((s) {
      final size = shortSide * s.$3;
      return AnimatedPositioned(
        duration: _kAnimDuration,
        curve: Curves.easeInOut,
        left: screenSize.width * s.$1,
        top: screenSize.height * s.$2,
        width: size,
        height: size,
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(s.$4),
            ),
          ),
        ),
      );
    }).toList();
  }
}

class _CircleGrid extends StatelessWidget {
  final List<_ThemeOption> options;
  final _ThemeOption? selected;
  final double contentWidth;
  final bool isDesktop;
  final ValueChanged<_ThemeOption>? onTap;

  const _CircleGrid({
    required this.options,
    required this.selected,
    required this.contentWidth,
    required this.isDesktop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Desktop: 2x2 grid, bigger circles, tight spacing so the whole
    // cluster reads as one compact block.
    // Mobile: single column, but pulled in tight — much smaller gaps
    // than before so all four options fit comfortably on screen.
    final crossAxisCount = isDesktop ? 2 : 1;
    final circleSize = isDesktop ? contentWidth * 0.34 : contentWidth * 0.32;
    final spacing = isDesktop ? contentWidth * 0.035 : contentWidth * 0.02;

    if (!isDesktop) {
      // Mobile: plain column, spacing fully under your control.
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < options.length; i++) ...[
            if (i != 0) SizedBox(height: spacing),
            GestureDetector(
              onTap: onTap == null ? null : () => onTap!(options[i]),
              child: _ThemeCircle(
                option: options[i],
                isSelected: selected?.name == options[i].name,
                size: circleSize,
              ),
            ),
          ],
        ],
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = selected?.name == option.name;

        return Center(
          child: GestureDetector(
            onTap: onTap == null ? null : () => onTap!(option),
            child: _ThemeCircle(
              option: option,
              isSelected: isSelected,
              size: circleSize,
            ),
          ),
        );
      },
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final _ThemeOption? option;
  final double contentWidth;
  final bool isSaving;
  final VoidCallback onPressed;

  const _ConfirmButton({
    required this.option,
    required this.contentWidth,
    required this.isSaving,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isVisible = option != null;
    final buttonColor = option?.secondary ?? Colors.transparent;
    // Secondary swatches here are all light — dark text reads best on them.
    final textColor = const Color(0xFFFFFFFF);

    return AnimatedOpacity(
      duration: _kAnimDuration,
      curve: Curves.easeInOut,
      opacity: isVisible ? 1 : 0,
      child: IgnorePointer(
        ignoring: !isVisible,
        child: AnimatedContainer(
          duration: _kAnimDuration,
          curve: Curves.easeInOut,
          width: contentWidth * 0.7,
          height: contentWidth * 0.14,
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(contentWidth * 0.07),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: contentWidth * 0.03,
                offset: Offset(0, contentWidth * 0.012),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(contentWidth * 0.07),
              onTap: isSaving ? null : onPressed,
              child: Center(
                child: isSaving
                    ? SizedBox(
                        width: contentWidth * 0.05,
                        height: contentWidth * 0.05,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation(textColor),
                        ),
                      )
                    : Text(
                        'Confirm',
                        style: AppTypography.body.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeCircle extends StatelessWidget {
  final _ThemeOption option;
  final bool isSelected;
  final double size;

  const _ThemeCircle({
    required this.option,
    required this.isSelected,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _kAnimDuration,
      curve: Curves.easeInOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(color: Colors.white, width: size * 0.045)
            : null,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.35),
                  blurRadius: size * 0.18,
                  spreadRadius: size * 0.01,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: size * 0.08,
                  offset: Offset(0, size * 0.03),
                ),
              ],
      ),
      padding: EdgeInsets.all(isSelected ? size * 0.09 : 0),
      child: ClipOval(
        child: AnimatedContainer(
          duration: _kAnimDuration,
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            // Unselected: diagonal split of primary/secondary.
            // Selected: solid secondary fill — the ring + background
            // (now == primary) carry the rest of the theme story.
            gradient: isSelected
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      option.primary,
                      option.primary,
                      option.secondary,
                      option.secondary,
                    ],
                    stops: const [0.0, 0.5, 0.5, 1.0],
                  ),
            color: isSelected ? option.secondary : null,
          ),
        ),
      ),
    );
  }
}
