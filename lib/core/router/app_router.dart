import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // native package
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../shared/widgets/app_button.dart';
import '../theme/theme.dart';
import '../theme/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // native package — add this import
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/dashboard_screen.dart';
import '../../features/routines/screens/routine_list_screen.dart';
import '../../features/auth/screens/splash_screen.dart';

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('$title screen — coming soon')));
  }
}

final appRouter = GoRouter(
  initialLocation: '/splash',
  refreshListenable: GoRouterRefreshStream(
    // native GoRouter helper — see explanation below
    Supabase.instance.client.auth.onAuthStateChange,
  ),
  redirect: (context, state) {
    // native GoRouter property — runs before every navigation
    final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
    final isGoingToLogin =
        state.matchedLocation == '/login' || state.matchedLocation == '/signup';
    final isSplash = state.matchedLocation == '/splash';

    if (isSplash) return null;

    if (!isLoggedIn && !isGoingToLogin) {
      return '/login'; // not logged in, trying to reach anything else → send to login
    }
    if (isLoggedIn && isGoingToLogin) {
      return '/home'; // already logged in, but sitting on login screen → send to home
    }
    return null; // no redirect needed, proceed as normal
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
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Shopping List'),
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
  // native Flutter base class — lets non-widget code trigger rebuilds
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}
