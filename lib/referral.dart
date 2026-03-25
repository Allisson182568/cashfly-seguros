// lib/models/referral.dart

enum ReferralStatus { pending, completed }

class Referral {
  final String id;
  final String referrerId;
  final String referredId;
  final ReferralStatus status;
  final DateTime createdAt;

  const Referral({
    required this.id,
    required this.referrerId,
    required this.referredId,
    required this.status,
    required this.createdAt,
  });

  factory Referral.fromMap(Map<String, dynamic> map) {
    return Referral(
      id: map['id'] as String,
      referrerId: map['referrer_id'] as String,
      referredId: map['referred_id'] as String,
      status: map['status'] == 'completed'
          ? ReferralStatus.completed
          : ReferralStatus.pending,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  bool get isCompleted => status == ReferralStatus.completed;
}