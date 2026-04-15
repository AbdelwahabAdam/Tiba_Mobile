class OrderItemModel {
  final int id;
  final int productId;
  final String? productName;
  final double price;
  final int qty;
  final String status;

  OrderItemModel({
    required this.id,
    required this.productId,
    this.productName,
    required this.price,
    required this.qty,
    required this.status,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'] as String?,
      price: (json['price'] ?? 0).toDouble(),
      qty: json['qty'] ?? 1,
      status: json['status'] ?? 'active',
    );
  }
}

class OrderModel {
  final int id;
  final int userId;
  final int addressId;
  final String status;
  final double total;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.userId,
    required this.addressId,
    required this.status,
    required this.total,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: json['id'],
      userId: json['user_id'],
      addressId: json['address_id'],
      status: json['status'],
      total: (json['total'] ?? 0).toDouble(),
      items: rawItems
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
