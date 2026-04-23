class BannerModel {
  final int id;
  final String? title;
  final String imageUrl;
  final bool isActive;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BannerModel({
    required this.id,
    this.title,
    required this.imageUrl,
    required this.isActive,
    required this.sortOrder,
    this.createdAt,
    this.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      title: json['title'] as String?,
      imageUrl: json['image_url'] ?? '',
      isActive: json['is_active'] ?? true,
      sortOrder: json['sort_order'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}
