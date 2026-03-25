// lib/models/cashback_transaction.dart

enum CashbackType { earn, use }

class CashbackTransaction {
  final String id;
  final String userId;
  final double amount;
  final CashbackType type;
  final String description;
  final DateTime createdAt;

  const CashbackTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  factory CashbackTransaction.fromMap(Map<String, dynamic> map) {
    return CashbackTransaction(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] == 'earn' ? CashbackType.earn : CashbackType.use,
      description: map['description'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  bool get isEarn => type == CashbackType.earn;
}