class ProductModel {
  final int id;
  final String name;
  final String arabicName;
  final String manufacturerName;
  final String arabicManufacturerName;
  final String description;
  final String arabicDescription;
  final String imageUrl;
  final int? categoryId;
  final int? subcategoryId;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.manufacturerName,
    required this.arabicManufacturerName,
    required this.description,
    required this.arabicDescription,
    required this.imageUrl,
    required this.categoryId,
    required this.subcategoryId,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'] ?? '',
      arabicName: json['arabic_name'] ?? '',
      manufacturerName: json['manufacturer_name'] ?? '',
      arabicManufacturerName: json['arabic_manufacturer_name'] ?? '',
      description: json['description'] ?? '',
      arabicDescription: json['arabic_description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      categoryId: json['category_id'],
      subcategoryId: json['subcategory_id'],
      isActive: json['is_active'] ?? true,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }
}
