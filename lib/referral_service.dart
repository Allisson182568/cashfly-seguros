// lib/features/referral/services/referral_service.dart
// Serviço de indicações



import 'package:cashflyseguros/referral.dart';
import 'package:cashflyseguros/supabase_cliente.dart';
import 'package:cashflyseguros/user+profile.dart';

class ReferralService {
  final _client = SupabaseService.client;

  /// Busca indicações feitas pelo usuário autenticado
  Future<List<Referral>> getReferrals() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('referrals')
        .select()
        .eq('referrer_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => Referral.fromMap(e)).toList();
  }

  /// Busca perfil do usuário autenticado
  Future<UserProfile?> getProfile() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from('users_profile')
        .select()
        .eq('id', userId)
        .single();

    return UserProfile.fromMap(response);
  }

  /// Gera o link de indicação completo
  String buildReferralLink(String referralCode, String baseUrl) {
    return '$baseUrl/register?ref=$referralCode';
  }
}