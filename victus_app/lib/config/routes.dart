import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/email_verification_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/server/presentation/screens/server_detail_screen.dart';
import '../features/account/presentation/screens/account_screen.dart';
import '../features/notifications/presentation/screens/notification_center_screen.dart';
import '../features/billing/presentation/screens/billing_screen.dart';
import '../features/billing/presentation/screens/ticket_detail_screen.dart';
import '../core/widgets/app_bottom_nav.dart';
import '../core/theme/app_animations.dart';

class ServersScreen extends StatelessWidget {
  const ServersScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: Colors.black,
    body: Center(child: Text('Servers', style: TextStyle(color: Colors.white))),
  );
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuthenticated = session != null;
      final isGoingToAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/email-verification';
      final isSplash = state.matchedLocation == '/splash';

      if (isSplash) {
        return null; // Let splash screen handle its own logic
      }

      if (!isAuthenticated && !isGoingToAuth) {
        return '/login';
      }

      if (isAuthenticated && isGoingToAuth) {
        return '/home/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder: AppAnimations.fadeTransition,
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: AppAnimations.fadeSlideTransition,
        ),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SignUpScreen(),
          transitionsBuilder: AppAnimations.fadeSlideTransition,
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
          transitionsBuilder: AppAnimations.fadeSlideTransition,
        ),
      ),
      GoRoute(
        path: '/email-verification',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const EmailVerificationScreen(),
          transitionsBuilder: AppAnimations.fadeTransition,
        ),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/home/dashboard',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
              transitionsBuilder: AppAnimations.fadeTransition,
            ),
          ),
          GoRoute(
            path: '/home/servers',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ServersScreen(),
              transitionsBuilder: AppAnimations.fadeTransition,
            ),
          ),
          GoRoute(
            path: '/home/billing',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const BillingScreen(),
              transitionsBuilder: AppAnimations.fadeTransition,
            ),
          ),
          GoRoute(
            path: '/home/account',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const AccountScreen(),
              transitionsBuilder: AppAnimations.fadeTransition,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/server/:id',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ServerDetailScreen(serverId: id),
            transitionsBuilder: AppAnimations.fadeSlideTransition,
          );
        },
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const NotificationCenterScreen(),
          transitionsBuilder: AppAnimations.fadeSlideTransition,
        ),
      ),
      GoRoute(
        path: '/ticket/:id',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: TicketDetailScreen(ticketId: id),
            transitionsBuilder: AppAnimations.fadeSlideTransition,
          );
        },
      ),
    ],
  );
});

/// Main shell with bottom navigation
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home/dashboard')) return 0;
    if (location.startsWith('/home/servers')) return 1;
    if (location.startsWith('/home/billing')) return 2;
    if (location.startsWith('/home/account')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home/dashboard');
      case 1:
        context.go('/home/servers');
      case 2:
        context.go('/home/billing');
      case 3:
        context.go('/home/account');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: VictusBottomNav(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }
}
