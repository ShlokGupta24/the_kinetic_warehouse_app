import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/products/presentation/screens/add_product_screen.dart';
import '../../features/products/presentation/screens/edit_product_screen.dart';
import '../../features/products/presentation/screens/product_list_screen.dart';
import '../../features/ledger/presentation/screens/ledger_screen.dart';
import '../../features/ledger/presentation/screens/add_transaction_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/users/presentation/screens/users_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../widgets/shared_bottom_nav_bar.dart';
import '../theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

part 'app_router.g.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

@riverpod
GoRouter goRouter(Ref ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSigningUp = state.matchedLocation == '/signup';

      if (isLoggedIn) {
        if (isLoggingIn || isSigningUp) return '/home';
      } else {
        if (!isLoggingIn && !isSigningUp) return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final index = navigationShell.currentIndex;
          
          Widget? fab;
          if (index == 1) { // Products
            fab = FloatingActionButton(
              onPressed: () => context.push('/add-product'),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            );
          } else if (index == 2) { // Ledger
            fab = FloatingActionButton(
              onPressed: () => context.push('/add-transaction'),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            );
          }

          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: SharedBottomNavBar(
              navigationShell: navigationShell,
            ),
            floatingActionButton: fab != null 
              ? Padding(
                  padding: EdgeInsets.only(bottom: 24.h), // Slightly above bottom nav
                  child: fab,
                )
              : null,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/products',
                builder: (context, state) => const ProductListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ledger',
                builder: (context, state) => const LedgerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      // Standalone app routes outside the bottom nav shell
      GoRoute(
        path: '/add-product',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AddProductScreen(),
      ),
      GoRoute(
        path: '/edit-product',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final product = state.extra as Map<String, dynamic>? ?? {};
          return EditProductScreen(product: product);
        },
      ),
      GoRoute(
        path: '/add-transaction',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '/users',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const UsersScreen(),
      ),
    ],
  );
}
