class CategoryModel {
  final int id;
  final String name;
  final String arabicName;
  final bool isActive;
  final String imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.isActive,
    required this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      arabicName: json['arabic_name'] ?? '',
      isActive: json['is_active'] ?? false,
      imageUrl: json['image_url'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}
