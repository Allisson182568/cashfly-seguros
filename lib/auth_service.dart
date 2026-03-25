// lib/features/auth/services/auth_service.dart
// Serviço de autenticação via Supabase Auth

import 'package:cashflyseguros/supabase_cliente.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  final _client = SupabaseService.client;

  // ── Cadastro ─────────────────────────────────────────────
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    String? referralCode,
  }) async {
    try {
      final metadata = <String, dynamic>{'name': name};
      if (referralCode != null && referralCode.trim().isNotEmpty) {
        metadata['referral_code'] = referralCode.trim().toUpperCase();
      }

      await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: metadata,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  // ── Login ─────────────────────────────────────────────────
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  // ── Logout ────────────────────────────────────────────────
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  // ── Recuperação de senha ──────────────────────────────────
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
    } catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  // ── Helpers ───────────────────────────────────────────────
  User? get currentUser => _client.auth.currentUser;

  bool get isAuthenticated => currentUser != null;

  String _parseError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('invalid login')) return 'Email ou senha incorretos.';
    if (msg.contains('already registered')) return 'Este email já está cadastrado.';
    if (msg.contains('weak password')) return 'Senha muito fraca. Use ao menos 6 caracteres.';
    if (msg.contains('network')) return 'Erro de conexão. Verifique sua internet.';
    return 'Ocorreu um erro. Tente novamente.';
  }
}