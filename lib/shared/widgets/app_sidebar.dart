import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';

class NavEntry {
  final String label;
  final String route;
  const NavEntry({required this.label, required this.route});
}

const List<NavEntry> kNavEntries = [
  NavEntry(label: "Dashboard", route: '/home'),
  NavEntry(label: "Routines", route: '/routines'),
  NavEntry(label: "Goals", route: '/goals'),
  NavEntry(label: "Shopping", route: '/shopping'),
  NavEntry(label: "Calendar", route: '/calendar'),
  NavEntry(label: "Transactions", route: '/transactions'),
  NavEntry(label: "Notes", route: '/notes'),
  NavEntry(label: "Wishlist", route: '/wishlist'),
  NavEntry(label: "Stats", route: '/stats'),
];

const double kItemHeight = 48;

String _iconFor(AppColors colors, String route) {
  switch (route) {
    case '/home':
      return colors.dashboardPath;
    case '/routines':
      return colors.routinePath;
    case '/goals':
      return colors.goalPath;
    case '/shopping':
      return colors.shoplistPath;
    case '/calendar':
      return colors.calendarPath;
    case '/transactions':
      return colors.financialPath;
    case '/notes':
      return colors.notesPath;
    case '/wishlist':
      return colors.wishlistPath;
    case '/stats':
      return colors.statisticsPath;
    default:
      return colors.logoPath;
  }
}

class AppSidebar extends StatelessWidget {
  final AppColors colors;
  final double width;
  const AppSidebar({super.key, required this.colors, required this.width});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final selectedIndex = kNavEntries.indexWhere(
      (e) => e.route == currentRoute,
    );

    return Container(
      width: width,
      color: colors.sidebar,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      colors.logoPath,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) {
                        print('Logo failed to load: $error');
                        return const Icon(
                          Icons.broken_image,
                          color: Colors.red,
                          size: 40,
                        );
                      },
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      "Spotlight\nManager",
                      style: AppTypography.heading2.copyWith(
                        color: colors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Stack(
                children: [
                  if (selectedIndex >= 0)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      top: selectedIndex * kItemHeight,
                      left: 0,
                      right: 0,
                      height: kItemHeight,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  Column(
                    children: kNavEntries.map((entry) {
                      final isSelected = entry.route == currentRoute;
                      return _SidebarItem(
                        entry: entry,
                        isSelected: isSelected,
                        colors: colors,
                        iconPath: _iconFor(colors, entry.route),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const Spacer(),
              _ProfileFooter(colors: colors),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

// Converted to Stateful so it can track hover locally.
class _SidebarItem extends StatefulWidget {
  final NavEntry entry;
  final bool isSelected;
  final AppColors colors;
  final String iconPath;
  const _SidebarItem({
    required this.entry,
    required this.isSelected,
    required this.colors,
    required this.iconPath,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final isSelected = widget.isSelected;
    final colors = widget.colors;

    return SizedBox(
      height: kItemHeight,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () => context.go(entry.route),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md - 2,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              // subtle tint on hover, only when not already the selected pill
              color: (!isSelected && _isHovered)
                  ? colors.primary.withOpacity(0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  widget.iconPath,
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(
                    isSelected ? Colors.white : colors.textPrimary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    entry.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : colors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 17,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isSelected ? 1 : 0,
                  child: const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileFooter extends StatelessWidget {
  final AppColors colors;
  const _ProfileFooter({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            "Bacteria",
            style: TextStyle(
              color: colors.textTitle,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class AppBottomNav extends StatefulWidget {
  final AppColors colors;
  const AppBottomNav({super.key, required this.colors});

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  static const _routes = ['/home', '/quick-input', '/settings'];

  // -1 means "no icon hovered"
  int _hoveredIndex = -1;

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _routes.indexOf(currentRoute).clamp(0, 2);

    final screenWidth = MediaQuery.of(context).size.width;
    final pillWidth = screenWidth * 0.5576;
    final circleSize = pillWidth * 0.2783;
    final iconSize = pillWidth * 0.1333;
    final pillHeight = circleSize + 20;
    final slotWidth = pillWidth / 3;

    final icons = [colors.homePath, colors.inputPath, colors.profilePath];

    return Container(
      width: pillWidth,
      height: pillHeight,
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(pillHeight / 2),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            left: selectedIndex * slotWidth + (slotWidth - circleSize) / 2,
            top: (pillHeight - circleSize) / 2,
            width: circleSize,
            height: circleSize,
            child: Container(
              decoration: BoxDecoration(
                color: colors.textSecondary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: List.generate(3, (index) {
              final isHovered = _hoveredIndex == index;
              return SizedBox(
                width: slotWidth,
                height: pillHeight,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _hoveredIndex = index),
                  onExit: (_) => setState(() {
                    if (_hoveredIndex == index) _hoveredIndex = -1;
                  }),
                  child: GestureDetector(
                    onTap: () => context.go(_routes[index]),
                    child: Center(
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 150),
                        scale: isHovered ? 1.15 : 1.0,
                        curve: Curves.easeOut,
                        child: SvgPicture.asset(
                          icons[index],
                          width: iconSize,
                          height: iconSize,
                          colorFilter: ColorFilter.mode(
                            colors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
