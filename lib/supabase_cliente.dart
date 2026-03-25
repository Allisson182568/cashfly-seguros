// lib/core/supabase_client.dart
// Inicialização e acesso ao cliente Supabase

import 'package:supabase_flutter/supabase_flutter.dart';

/// Acesso global ao cliente Supabase
/// Use: SupabaseService.client
class SupabaseService {
  SupabaseService._();

  // ⚠️ Substitua pelos seus valores do Supabase Dashboard > Settings > API
  static const String _supabaseUrl = 'https://wfoysxuynbcuxybkqmfz.supabase.co';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indmb3lzeHV5bmJjdXh5YmtxbWZ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI3OTk3NDcsImV4cCI6MjA4ODM3NTc0N30.v28Tj6z6PrnyUk_kFSvvchjzwHmV7ZXcJH903hQTiZg';

  /// Inicializa o Supabase - chamar em main()
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  /// Cliente Supabase para uso nos services
  static SupabaseClient get client => Supabase.instance.client;

  /// Usuário autenticado atual
  static User? get currentUser => client.auth.currentUser;

  /// Stream de mudanças de autenticação
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}