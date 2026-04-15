class SubCategoryModel {
  final int id;
  final int categoryId;
  final String name;
  final String arabicName;
  final String imageUrl;
  final bool isActive;

  SubCategoryModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.arabicName,
    required this.imageUrl,
    required this.isActive,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'],
      categoryId: json['category_id'],
      name: json['name'],
      arabicName: json['arabic_name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }
}
