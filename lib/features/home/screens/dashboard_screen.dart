import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/app_card.dart';

/// Root dashboard screen. Switches between the mobile 2x4 shortcut grid
/// and the desktop bento-style overview depending on available width.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppThemes.of(ref.watch(themeProvider));

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 700;
        return isDesktop
            ? _DesktopDashboard(colors: colors)
            : _MobileDashboard(colors: colors);
      },
    );
  }
}

class _MobileDashboard extends StatelessWidget {
  const _MobileDashboard({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    // Order matches the sidebar list (minus Dashboard itself).
    final shortcuts = <_Shortcut>[
      _Shortcut('Routine', colors.routinePath, '/routines'),
      _Shortcut('Shop List', colors.shoplistPath, '/shopping'),
      _Shortcut('Calendar', colors.calendarPath, '/calendar'),
      _Shortcut('Statistics', colors.statisticsPath, '/stats'),
      _Shortcut('Goal', colors.goalPath, '/goals'),
      _Shortcut('Notes', colors.notesPath, '/notes'),
      _Shortcut('Financial', colors.financialPath, '/financial'),
      _Shortcut('Wishlist', colors.wishlistPath, '/wishlist'),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  SvgPicture.asset(colors.logoPath, width: 40, height: 40),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Spotlight\nManager',
                      style: AppTypography.body.copyWith(
                        color: colors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: colors.textPrimary),
                    onPressed: () {
                      // TODO: navigate to settings
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  100, // extra scroll space below the last row
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 462 / 545,
                ),
                itemCount: shortcuts.length,
                itemBuilder: (context, index) {
                  final shortcut = shortcuts[index];
                  return AppCard(
                    onTap: () => context.go(shortcut.route),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          shortcut.iconPath,
                          width: 100,
                          height: 100,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          shortcut.label,
                          textAlign: TextAlign.center,
                          style: AppTypography.body.copyWith(
                            color: colors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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
}

class _Shortcut {
  final String label;
  final String iconPath;
  final String route;
  const _Shortcut(this.label, this.iconPath, this.route);
}

class _DesktopDashboard extends StatelessWidget {
  const _DesktopDashboard({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.background,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'How is your day, name?',
                style: AppTypography.heading1.copyWith(
                  fontSize: 24,
                  color: colors.textTitle,
                ),
              ),
              Icon(Icons.settings, color: colors.textPrimary),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: Column(
              children: [
                // Main 3-column bento area (rows 1-3 of the mock).
                Expanded(
                  flex: 5,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Column 1: Today To-do (top) / Last Notes + Shop List (bottom split)
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            Expanded(
                              flex: 1,
                              child: _BentoCard(
                                colors: colors,
                                label: "Today's To-do List",
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: _BentoCard(
                                      colors: colors,
                                      label: 'Last Notes',
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Expanded(
                                    flex: 2,
                                    child: _BentoCard(
                                      colors: colors,
                                      label: 'Shop List',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Column 2: Goal Track (top) / Calendar + Monthly Income Expense (bottom split)
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            Expanded(
                              flex: 1,
                              child: _BentoCard(
                                colors: colors,
                                label: 'Goal Track',
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: _BentoCard(
                                      colors: colors,
                                      label: 'Calendar',
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Expanded(
                                    flex: 1,
                                    child: _BentoCard(
                                      colors: colors,
                                      label: 'Monthly Income Expense',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Column 3: Wishlist (top) / Stats (bottom, single tall card)
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            Expanded(
                              flex: 1,
                              child: _BentoCard(
                                colors: colors,
                                label: 'Wishlist',
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Expanded(
                              flex: 2,
                              child: _BentoCard(colors: colors, label: 'Stats'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Bottom: full-width Daily Routine bar.
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Expanded(
                        child: _BentoCard(
                          colors: colors,
                          label: 'Daily Routine',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BentoCard extends StatelessWidget {
  const _BentoCard({required this.colors, required this.label});

  final AppColors colors;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTypography.body.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
