class PriceSegmentModel {
  final int id;
  final int productId;
  final int segmentId;
  final bool isRetail;
  final double retailPrice;
  final bool isWholesale;
  final double wholesalePrice;
  final double offerPercent;
  final int? retailMinQty;
  final int? retailMaxQty;
  final int? wholesaleMinQty;
  final int? wholesaleMaxQty;

  PriceSegmentModel({
    required this.id,
    required this.productId,
    required this.segmentId,
    required this.isRetail,
    required this.retailPrice,
    required this.isWholesale,
    required this.wholesalePrice,
    required this.offerPercent,
    required this.retailMinQty,
    required this.retailMaxQty,
    required this.wholesaleMinQty,
    required this.wholesaleMaxQty,

  });

  factory PriceSegmentModel.fromJson(Map<String, dynamic> json) {
    return PriceSegmentModel(
      id: json['id'],
      productId: json['product_id'],
      segmentId: json['segment_id'],
      isRetail: json['is_retail'] ?? false,
      retailPrice: (json['retail_price'] ?? 0).toDouble(),
      isWholesale: json['is_wholesale'] ?? false,
      wholesalePrice: (json['wholesale_price'] ?? 0).toDouble(),
      offerPercent: (json['offer_percent'] ?? 0).toDouble(),
      retailMinQty: json['retail_lowest_order_quantity'],
      retailMaxQty: json['retail_max_order_quantity'],
      wholesaleMinQty: json['wholesale_lowest_order_quantity'],
      wholesaleMaxQty: json['wholesale_max_order_quantity'],
    );
  }
}
