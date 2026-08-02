import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/profile_form_screen.dart'; // renamed import target
import '../../features/auth/screens/theme_picker_screen.dart'; // renamed import target
import '../../shared/widgets/app_button.dart';
import '../theme/theme.dart';
import '../theme/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/dashboard_screen.dart';
import '../../features/routines/screens/routine_list_screen.dart';
import '../../features/shopping/screens/shopping_list_screen.dart';
import '../../features/shopping/screens/add_item_sheet.dart';

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('$title screen — coming soon')));
  }
}

bool? _themeChosenCache;
String? _lastThemeCheckedUserId;

Future<bool> _isThemeChosen(String userId) async {
  if (_themeChosenCache != null && _lastThemeCheckedUserId == userId) {
    return _themeChosenCache!;
  }

  final response = await Supabase.instance.client
      .from('profiles')
      .select(
        'theme_chosen',
      ) // CHANGED — check this new column, not theme_preference
      .eq('id', userId)
      .maybeSingle();

  final chosen = response != null && response['theme_chosen'] == true;
  _themeChosenCache = chosen;
  _lastThemeCheckedUserId = userId;
  return chosen;
}

// Cache so we don't hit the DB on every navigation — only once per login
// session. Reset to null whenever auth state changes (login/logout), so a
// freshly logged-in user (or a different user) gets checked again.
bool? _profileCompleteCache;
String? _lastCheckedUserId;

Future<bool> _isProfileComplete(String userId) async {
  if (_profileCompleteCache != null && _lastCheckedUserId == userId) {
    return _profileCompleteCache!;
  }

  final response = await Supabase.instance.client
      .from('profiles')
      .select('display_name, full_name')
      .eq('id', userId)
      .maybeSingle();

  // treat missing row, or either key field still null, as "incomplete"
  final complete =
      response != null &&
      response['display_name'] != null &&
      response['full_name'] != null;

  _profileCompleteCache = complete;
  _lastCheckedUserId = userId;
  return complete;
}

void invalidateProfileCache() {
  _profileCompleteCache = null;
  _lastCheckedUserId = null;
  _themeChosenCache = null;
  _lastThemeCheckedUserId = null;
}

void markThemeChosen(String userId) {
  // NEW — sets the cache directly, no DB round-trip
  _themeChosenCache = true;
  _lastThemeCheckedUserId = userId;
}

final appRouter = GoRouter(
  initialLocation: '/splash',
  refreshListenable: GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  ),
  redirect: (context, state) async {
    final user = Supabase.instance.client.auth.currentUser;
    final isLoggedIn = user != null;
    final isGoingToLogin =
        state.matchedLocation == '/login' || state.matchedLocation == '/signup';
    final isSplash = state.matchedLocation == '/splash';
    final isGoingToThemePicker =
        state.matchedLocation == '/theme-picker';
    final isGoingToProfileForm = state.matchedLocation == '/profileform';

    // If on splash screen and not logged in, show splash; otherwise proceed
    if (isSplash) {
      if (!isLoggedIn) {
        return null;
      }
      // If logged in, fall through to check onboarding status
    }

    if (!isLoggedIn) {
      _profileCompleteCache = null;
      _lastCheckedUserId = null;
      _themeChosenCache = null;
      _lastThemeCheckedUserId = null;
      if (!isGoingToLogin) return '/login';
      return null;
    }

    if (isGoingToLogin) return '/home';

    final themeChosen = await _isThemeChosen(user!.id);
    final profileComplete = await _isProfileComplete(user.id);
    final isOnboardingComplete = themeChosen && profileComplete;

    if (!isOnboardingComplete) {
      if (!themeChosen) {
        if (!isGoingToThemePicker) {
          return '/theme-picker';
        }
      } else {
        // theme chosen but profile not complete
        if (!isGoingToProfileForm) {
          return '/profileform';
        }
      }
      return null;
    } else {
      // onboarding complete: redirect to home if not already in the app
      final isInApp = state.matchedLocation.startsWith('/home') ||
                      state.matchedLocation.startsWith('/routines') ||
                      state.matchedLocation.startsWith('/goals') ||
                      state.matchedLocation.startsWith('/shopping') ||
                      state.matchedLocation.startsWith('/calendar') ||
                      state.matchedLocation.startsWith('/transactions') ||
                      state.matchedLocation.startsWith('/notes') ||
                      state.matchedLocation.startsWith('/wishlist') ||
                      state.matchedLocation.startsWith('/stats') ||
                      state.matchedLocation.startsWith('/quick-input') ||
                      state.matchedLocation.startsWith('/settings');
      if (!isInApp) {
        return '/home';
      }
      return null;
    }
  },
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(
      path: '/theme-picker',
      builder: (context, state) => const ThemePickerScreen(),
    ),
    GoRoute(
      path: '/profileform', // renamed from /profile
      builder: (context, state) => const ProfileFormScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => HomeShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/routines',
          builder: (context, state) => const RoutineListScreen(),
        ),
        GoRoute(
          path: '/goals',
          builder: (context, state) => const _PlaceholderScreen(title: 'Goals'),
        ),
        GoRoute(
          path: '/shopping',
          builder: (context, state) => const ShoppingListScreen(),
        ),
        GoRoute(
          path: '/shopping/add',
          builder: (context, state) => const AddEditShoppingScreen(),
        ),
        GoRoute(
          path:
              '/shopping/edit/:id', // native GoRouter — :id is a path parameter
          builder: (context, state) {
            // For a real implementation, you'd fetch the specific item by state.pathParameters['id']
            // For now, this is a good next question for you to explore — how would you fetch one specific item?
            return const AddEditShoppingScreen(); // simplified for this walkthrough
          },
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Calendar'),
        ),
        GoRoute(
          path: '/transactions',
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Transactions'),
        ),
        GoRoute(
          path: '/notes',
          builder: (context, state) => const _PlaceholderScreen(title: 'Notes'),
        ),
        GoRoute(
          path: '/wishlist',
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Wishlist'),
        ),
        GoRoute(
          path: '/stats',
          builder: (context, state) => const _PlaceholderScreen(title: 'Stats'),
        ),
        GoRoute(
          path: '/quick-input',
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Quick Input'),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Settings'),
        ),
      ],
    ),
  ],
);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}
