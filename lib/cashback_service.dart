// lib/features/cashback/services/cashback_service.dart
// Serviço de cashback — apenas leitura para o cliente
// Escrita via RPCs do Supabase (segurança server-side)


import 'package:cashflyseguros/supabase_cliente.dart';

import 'cashback_transaction.dart';

class CashbackService {
  final _client = SupabaseService.client;

  /// Busca histórico de cashback do usuário autenticado
  Future<List<CashbackTransaction>> getTransactions() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('cashback_transactions')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);

    return (response as List)
        .map((e) => CashbackTransaction.fromMap(e))
        .toList();
  }

  /// Busca saldo atual de cashback
  Future<double> getBalance() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return 0.0;

    final response = await _client
        .from('users_profile')
        .select('cashback_balance')
        .eq('id', userId)
        .single();

    return (response['cashback_balance'] as num).toDouble();
  }

  /// [ADMIN ONLY] Adicionar cashback via RPC
  /// Normalmente chamado pelo backend/webhook após venda de seguro
  Future<void> addCashback({
    required String userId,
    required double amount,
    required String description,
    String type = 'earn',
  }) async {
    await _client.rpc('add_cashback', params: {
      'p_user_id': userId,
      'p_amount': amount,
      'p_description': description,
      'p_type': type,
    });
  }

  /// [ADMIN ONLY] Completar indicação e distribuir cashback
  Future<void> completeReferral({
    required String referredId,
    required double buyerCashback,
    required double referrerCashback,
    String description = 'Compra de seguro',
  }) async {
    await _client.rpc('complete_referral', params: {
      'p_referred_id': referredId,
      'p_buyer_cashback': buyerCashback,
      'p_referrer_cashback': referrerCashback,
      'p_description': description,
    });
  }
}