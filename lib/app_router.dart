// lib/app_router.dart
// Roteamento com middleware de autenticação (go_router)

import 'package:cashflyseguros/register_screen.dart';
import 'package:cashflyseguros/supabase_cliente.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'deshbord_screen.dart';
import 'forgot_password_screen.dart';
import 'insurance_page.dart';
import 'login_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  debugLogDiagnostics: false,

  // ── Redirect global (auth guard) ──────────────────────────
  redirect: (context, state) {
    final isAuthenticated = SupabaseService.currentUser != null;

    // Rotas públicas — sem necessidade de login
    final publicRoutes = ['/login', '/register', '/forgot-password', '/cotacao'];
    final isPublic = publicRoutes.any((r) => state.matchedLocation.startsWith(r));

    if (!isAuthenticated && !isPublic) return '/login';
    if (isAuthenticated && (state.matchedLocation == '/login' ||
        state.matchedLocation == '/register')) return '/dashboard';
    return null;
  },

  refreshListenable: _AuthNotifier(),

  routes: [
    // ── Pública: cotação (visitor-first) ───────────────────
    GoRoute(
      path: '/cotacao',
      builder: (_, __) => const DashboardScreen(tabIndex: 3),
    ),
    // ── Auth ───────────────────────────────────────────────
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (_, state) => RegisterScreen(
        referralCode: state.uri.queryParameters['ref'],
        prefillName: state.uri.queryParameters['name'],
      ),
    ),
    GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),

    // ── App (protegido) ────────────────────────────────────
    GoRoute(path: '/dashboard',  builder: (_, __) => const DashboardScreen(tabIndex: 0)),
    GoRoute(path: '/cashback',   builder: (_, __) => const DashboardScreen(tabIndex: 1)),
    GoRoute(path: '/referrals',  builder: (_, __) => const DashboardScreen(tabIndex: 2)),
    GoRoute(path: '/cotacao',  builder: (_, __) => const DashboardScreen(tabIndex: 3)),
    GoRoute(path: '/profile',    builder: (_, __) => const DashboardScreen(tabIndex: 4)),
  ],

  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Página não encontrada: \${state.uri}'),
          TextButton(
            onPressed: () => context.go('/dashboard'),
            child: const Text('Ir para o Dashboard'),
          ),
        ],
      ),
    ),
  ),
);

class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier() {
    SupabaseService.authStateChanges.listen((_) => notifyListeners());
  }
}