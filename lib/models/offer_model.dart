class OfferModel {
  final int id;
  final String title;
  final String description;
  final double discountPercent;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;
  final int? segmentId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String imageUrl;

  OfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.discountPercent,
    required this.isActive,
    required this.startDate,
    required this.endDate,
    required this.imageUrl,
    this.segmentId,
    this.createdAt,
    this.updatedAt,

  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      discountPercent:
      (json['discount_percent'] ?? 0).toDouble(),
      isActive: json['is_active'] ?? true,
      imageUrl: json['image_url'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      segmentId: json['segment_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}
