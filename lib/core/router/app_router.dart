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

final appRouter = GoRouter(
  initialLocation: '/login',
  refreshListenable: GoRouterRefreshStream(
    // native GoRouter helper — see explanation below
    Supabase.instance.client.auth.onAuthStateChange,
  ),
  redirect: (context, state) {
    // native GoRouter property — runs before every navigation
    final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
    final isGoingToLogin =
        state.matchedLocation == '/login' || state.matchedLocation == '/signup';

    if (!isLoggedIn && !isGoingToLogin) {
      return '/login'; // not logged in, trying to reach anything else → send to login
    }
    if (isLoggedIn && isGoingToLogin) {
      return '/home'; // already logged in, but sitting on login screen → send to home
    }
    return null; // no redirect needed, proceed as normal
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    ShellRoute(
      // native GoRouter — wraps matching routes with a persistent shell
      builder: (context, state, child) => HomeShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Dashboard content goes here')),
          ),
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
