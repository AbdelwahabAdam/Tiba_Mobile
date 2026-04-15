class UserSegmentModel {
  final int id;
  final String name;
  final String arabicName;
  final bool isActive;

  UserSegmentModel({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.isActive,
  });

  factory UserSegmentModel.fromJson(Map<String, dynamic> json) {
    return UserSegmentModel(
      id: json['id'],
      name: json['name'],
      arabicName: json['arabic_name'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }
}
