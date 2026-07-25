import 'package:flutter_riverpod/flutter_riverpod.dart'; // native package
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';

class ThemeNotifier extends Notifier<AppThemeName> {
  // native Riverpod class — modern replacement for StateNotifier
  @override
  AppThemeName build() {
    // native Riverpod — replaces the old constructor; returns the STARTING state
    return AppThemeName.blueLight;
  }

  Future<void> loadFromProfile() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final response = await Supabase.instance.client
        .from('profiles')
        .select('theme_preference')
        .eq('id', userId)
        .maybeSingle();

    final saved = response?['theme_preference'] as String?;
    if (saved != null) {
      state = AppThemeName.values.firstWhere(
        (t) => t.name == saved,
        orElse: () => AppThemeName.blueLight,
      );
    }
  }

  Future<void> setTheme(AppThemeName newTheme) async {
    state = newTheme;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    await Supabase.instance.client
        .from('profiles')
        .update({'theme_preference': newTheme.name})
        .eq('id', userId);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, AppThemeName>(
  // native Riverpod — modern replacement for StateNotifierProvider
  ThemeNotifier.new, // native Dart — shorthand for "() => ThemeNotifier()"
);
