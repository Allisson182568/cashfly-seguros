// lib/models/user_profile.dart

class UserProfile {
  final String id;
  final String email;
  final String name;
  final String referralCode;
  final String? referredBy;
  final double cashbackBalance;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.referralCode,
    this.referredBy,
    required this.cashbackBalance,
    required this.createdAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      referralCode: map['referral_code'] as String,
      referredBy: map['referred_by'] as String?,
      cashbackBalance: (map['cashback_balance'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  UserProfile copyWith({
    String? name,
    double? cashbackBalance,
  }) {
    return UserProfile(
      id: id,
      email: email,
      name: name ?? this.name,
      referralCode: referralCode,
      referredBy: referredBy,
      cashbackBalance: cashbackBalance ?? this.cashbackBalance,
      createdAt: createdAt,
    );
  }
}