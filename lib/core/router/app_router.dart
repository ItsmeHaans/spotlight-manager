import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/profile_form_screen.dart'; // renamed import target
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
    final isGoingToProfileForm = state.matchedLocation == '/profileform';

    if (isSplash)
      return null; // let splash screen decide, don't force-redirect it

    if (!isLoggedIn) {
      _profileCompleteCache = null; // reset cache on logout
      _lastCheckedUserId = null;
      if (!isGoingToLogin) return '/login';
      return null;
    }

    // logged in past this point
    if (isGoingToLogin)
      return '/home'; // will get bounced to /profileform below if needed

    final complete = await _isProfileComplete(user.id);

    if (!complete && !isGoingToProfileForm) {
      return '/profileform'; // force profile completion before anything else
    }
    if (complete && isGoingToProfileForm) {
      return '/home'; // already filled in — don't let them revisit via URL/back button
    }

    return null;
  },
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),

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
