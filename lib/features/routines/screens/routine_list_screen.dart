import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // native package

import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/loading_overlay.dart';

class RoutineListScreen extends ConsumerStatefulWidget {
  // ConsumerStatefulWidget since we need a controller + toggle state
  const RoutineListScreen({super.key});

  @override
  ConsumerState<RoutineListScreen> createState() => _RoutineListScreenState();
}

class _RoutineListScreenState extends ConsumerState<RoutineListScreen> {
  final _testController = TextEditingController();
  bool _showLoading = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemes.of(ref.watch(themeProvider));

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: const Text("Component Showcase (dummy)")),
      body: LoadingOverlay(
        isLoading: _showLoading,
        child: SingleChildScrollView(
          // native Flutter — lets content scroll if it overflows the screen
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppButton(
                label: "Log Out",
                onPressed: () async {
                  await Supabase.instance.client.auth
                      .signOut(); // native Supabase method
                  // No manual navigation needed — GoRouter's redirect logic sends you
                  // back to /login automatically, the instant auth state changes.
                },
              ),

              Text(
                "AppButton",
                style: AppTypography.heading2.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(label: "Primary", onPressed: () {}),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: "Secondary",
                variant: AppButtonVariant.secondary,
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: "Danger",
                variant: AppButtonVariant.danger,
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(label: "Loading...", isLoading: true, onPressed: () {}),

              const SizedBox(height: AppSpacing.lg),
              Text(
                "AppTextField",
                style: AppTypography.heading2.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                label: "Email",
                hint: "you@example.com",
                controller: _testController,
              ),

              const SizedBox(height: AppSpacing.lg),
              Text(
                "AppCard",
                style: AppTypography.heading2.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppCard(child: Text("Card content here")),

              const SizedBox(height: AppSpacing.lg),
              Text(
                "EmptyState",
                style: AppTypography.heading2.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height:
                    150, // native property — EmptyState wants a Center, so give it bounded space here
                child: EmptyState(
                  message: "Nothing here yet",
                  icon: Icons.checklist,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
              Text(
                "ConfirmDialog",
                style: AppTypography.heading2.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: "Open Confirm Dialog",
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => ConfirmDialog(
                    title: "Delete?",
                    message: "This can't be undone.",
                    onConfirm: () => print("Confirmed!"),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
              Text(
                "LoadingOverlay",
                style: AppTypography.heading2.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: _showLoading ? "Hide Overlay" : "Show Overlay",
                onPressed: () => setState(() => _showLoading = !_showLoading),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
