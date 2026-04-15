import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app.dart';
import '../../controllers/order_controller.dart';
import '../../models/order_model.dart';
import '../shared/crud_list_page.dart';

class OrderPage extends StatelessWidget {
  OrderPage({super.key});

  final controller = Get.put(OrderController());

  Color _orderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'returned':
        return Colors.purple;
      case 'processing':
        return Colors.teal;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  Color _itemStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'cancelled':
        return Colors.red;
      case 'returned':
        return Colors.purple;
      case 'out_of_stock':
        return Colors.grey;
      case 'active':
      default:
        return Colors.green;
    }
  }

  Widget _statusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 0.8),
      ),
      child: Text(
        status.toUpperCase().replaceAll('_', ' '),
        style: TextStyle(
          color: color.withAlpha(220),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showEditOrderDialog(BuildContext context, OrderModel order) {
    String status = order.status;
    bool saving = false;

    const statuses = [
      'pending',
      'processing',
      'shipped',
      'delivered',
      'cancelled',
      'returned',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF0F4F8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              MediaQuery.of(context).viewInsets.bottom + 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                sheetHandle(),
                const Text(
                  'Update Order Status',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: status,
                  items: statuses
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => status = v!),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setState(() => saving = true);
                          await controller.updateOrder(order.id, {
                            'status': status,
                          });
                          Get.back();
                        },
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditItemDialog(
    BuildContext context,
    OrderModel order,
    OrderItemModel item,
  ) {
    String status = item.status;
    final qtyController = TextEditingController(text: item.qty.toString());
    final priceController = TextEditingController(
      text: item.price.toStringAsFixed(2),
    );
    bool saving = false;

    const itemStatuses = ['active', 'cancelled', 'returned', 'out_of_stock'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF0F4F8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              MediaQuery.of(context).viewInsets.bottom + 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sheetHandle(),
                Center(
                  child: Text(
                    'Edit Item #${item.id}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: itemStatuses
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.toUpperCase().replaceAll('_', ' ')),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => status = v!),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setState(() => saving = true);
                          await controller.updateOrderItem(order.id, item.id, {
                            'qty': int.tryParse(qtyController.text) ?? item.qty,
                            'price':
                                double.tryParse(priceController.text) ??
                                item.price,
                            'status': status,
                          });
                          Get.back();
                        },
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      qtyController.dispose();
      priceController.dispose();
    });
  }

  Widget _buildItemRow(
    BuildContext context,
    OrderModel order,
    OrderItemModel item,
  ) {
    final itemColor = _itemStatusColor(item.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: itemColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.inventory_2_rounded, color: itemColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName != null
                      ? '${item.productName} (#${item.productId})'
                      : 'Product #${item.productId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Qty: ${item.qty}  ·  \$${item.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _statusChip(item.status, itemColor),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded, size: 18),
            visualDensity: VisualDensity.compact,
            onPressed: () => _showEditItemDialog(context, order, item),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Orders (${controller.items.length})')),
      ),
      body: CrudListPage<OrderModel>(
        controller: controller,
        onSearch: (v) {
          controller.search.value = v;
          controller.fetch(reset: true);
        },
        itemBuilder: (item) {
          final statusColor = _orderStatusColor(item.status);
          return Card(
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: statusColor,
                    size: 22,
                  ),
                ),
                title: Text(
                  'Order #${item.id}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total: \$${item.total.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _statusChip(item.status, statusColor),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, size: 20),
                      onPressed: () => _showEditOrderDialog(context, item),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_rounded,
                        size: 20,
                        color: Colors.red.shade400,
                      ),
                      onPressed: () async {
                        if (await confirmDelete(
                          context,
                          title: 'Delete Order',
                          message:
                              'Delete Order #${item.id}? This cannot be undone.',
                        )) {
                          await controller.deleteOrder(item.id);
                        }
                      },
                    ),
                  ],
                ),
                children: [
                  if (item.items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'No items',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            'Items (${item.items.length})',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        ...item.items.map(
                          (orderItem) =>
                              _buildItemRow(context, item, orderItem),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
