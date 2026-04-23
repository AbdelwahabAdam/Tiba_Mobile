class UserModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;

  final bool isActive;
  final bool isDeleted;
  final bool isVerified;

  final int loyaltyPoints;
  final double walletBalance;

  final int roleId;

  final int? segmentId;
  final bool receiveEmails;
  final DateTime? deletedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isActive,
    required this.isDeleted,
    required this.isVerified,
    required this.loyaltyPoints,
    required this.walletBalance,
    required this.roleId,
    this.segmentId,
    this.receiveEmails = true,
    this.deletedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',

      isActive: json['is_active'] ?? true,
      isDeleted: json['is_deleted'] ?? false,
      isVerified: json['is_verified'] ?? false,

      loyaltyPoints: json['loyalty_points'] ?? 0,
      walletBalance: (json['wallet_balance'] ?? 0).toDouble(),

      roleId: json['role_id'] ?? 0,

      segmentId: json['segment_id'],
      receiveEmails: json['receive_emails'] ?? true,
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'])
          : null,
    );
  }
}
