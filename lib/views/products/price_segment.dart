import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app.dart';
import '../../controllers/price_segment_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/user_segment_controller.dart';
import '../../models/price_segment_model.dart';
import '../shared/crud_list_page.dart';

class PriceSegmentPage extends StatelessWidget {
  PriceSegmentPage({super.key});

  final controller = Get.put(PriceSegmentController());
  final productCtrl = Get.isRegistered<ProductController>()
      ? Get.find<ProductController>()
      : Get.put(ProductController());
  final segmentCtrl = Get.isRegistered<UserSegmentController>()
      ? Get.find<UserSegmentController>()
      : Get.put(UserSegmentController());
  final _requestedProductIds = <int>{};

  void _ensureProductLoaded(int productId) {
    if (productCtrl.productById.containsKey(productId) ||
        _requestedProductIds.contains(productId)) {
      return;
    }
    _requestedProductIds.add(productId);
    productCtrl.getProduct(productId).whenComplete(() {
      _requestedProductIds.remove(productId);
    });
  }

  // =============================
  // Helpers
  // =============================

  String _productName(int productId) {
    final product = productCtrl.productById[productId];
    if (product == null) {
      _ensureProductLoaded(productId);
      return 'Product #$productId';
    }
    if (product.name.trim().isEmpty) {
      return 'Product #$productId';
    }
    return '${product.name} (#$productId)';
  }

  String _productArabicName(int productId) {
    final product = productCtrl.productById[productId];
    if (product == null) {
      _ensureProductLoaded(productId);
      return '';
    }
    return product.arabicName;
  }

  Future<int?> _showProductPicker(BuildContext context, {int? selectedId}) {
    final searchCtrl = TextEditingController();
    var query = '';

    return showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            final products = productCtrl.productById.values.toList()
              ..sort(
                (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
              );

            final normalizedQuery = query.trim().toLowerCase();
            final filtered = normalizedQuery.isEmpty
                ? products
                : products.where((p) {
                    final idMatch = p.id.toString().contains(normalizedQuery);
                    final nameMatch = p.name.toLowerCase().contains(
                      normalizedQuery,
                    );
                    final arabicMatch = p.arabicName.toLowerCase().contains(
                      normalizedQuery,
                    );
                    return idMatch || nameMatch || arabicMatch;
                  }).toList();

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              backgroundColor: const Color(0xFFF0F4F8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Column(
                    children: [
                      const Text(
                        'Select Product',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: searchCtrl,
                        onChanged: (v) => setState(() => query = v),
                        decoration: const InputDecoration(
                          hintText:
                              'Search by name, Arabic name, or product ID',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: filtered.isEmpty
                            ? const Center(child: Text('No products found'))
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final p = filtered[index];
                                  final title = p.name.trim().isEmpty
                                      ? 'Product #${p.id}'
                                      : '${p.name} (#${p.id})';
                                  return ListTile(
                                    dense: true,
                                    title: Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: p.arabicName.trim().isEmpty
                                        ? null
                                        : Text(
                                            p.arabicName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                    trailing: p.id == selectedId
                                        ? Icon(
                                            Icons.check_circle,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          )
                                        : null,
                                    onTap: () =>
                                        Navigator.of(context).pop(p.id),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(searchCtrl.dispose);
  }

  // =============================
  // Helpers
  // =============================

  static Widget _priceChip(String label, num price, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.35), width: 0.8),
    ),
    child: Text(
      '$label: $price',
      style: TextStyle(
        color: color.withAlpha(210),
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  // =============================
  // Add / Edit Form
  // =============================

  Future<void> _showPriceSegmentForm(
    BuildContext context, {
    PriceSegmentModel? ps,
  }) async {
    final isEdit = ps != null;

    if (productCtrl.productById.isEmpty) {
      await productCtrl.loadAllForLookup();
    }
    if (segmentCtrl.items.isEmpty) {
      await segmentCtrl.fetch(reset: true);
    }

    final segmentItems = segmentCtrl.items.toList(growable: false);

    int? selectedProductId = ps?.productId;
    int? selectedSegmentId = ps?.segmentId;

    bool isRetail = ps?.isRetail ?? true;
    bool isWholesale = ps?.isWholesale ?? false;

    final retailPriceCtrl = TextEditingController(
      text: ps?.retailPrice.toString() ?? '',
    );
    final retailMinQtyCtrl = TextEditingController(
      text: ps?.retailMinQty?.toString() ?? '',
    );
    final retailMaxQtyCtrl = TextEditingController(
      text: ps?.retailMaxQty?.toString() ?? '',
    );

    final wholesalePriceCtrl = TextEditingController(
      text: ps?.wholesalePrice.toString() ?? '',
    );
    final wholesaleMinQtyCtrl = TextEditingController(
      text: ps?.wholesaleMinQty?.toString() ?? '',
    );
    final wholesaleMaxQtyCtrl = TextEditingController(
      text: ps?.wholesaleMaxQty?.toString() ?? '',
    );

    final offerCtrl = TextEditingController(
      text: ps?.offerPercent.toString() ?? '',
    );

    bool saving = false;

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
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  sheetHandle(),
                  Text(
                    isEdit ? 'Edit Price Segment' : 'Add Price Segment',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // PRODUCT PICKER (searchable)
                  if (!isEdit)
                    Builder(
                      builder: (_) {
                        final selectedProduct = selectedProductId == null
                            ? null
                            : productCtrl.productById[selectedProductId!];
                        final selectedLabel = selectedProduct == null
                            ? (selectedProductId == null
                                  ? 'Tap to select a product'
                                  : 'Product #$selectedProductId')
                            : '${selectedProduct.name} (#${selectedProduct.id})';

                        return InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () async {
                            final picked = await _showProductPicker(
                              context,
                              selectedId: selectedProductId,
                            );
                            if (picked != null) {
                              setState(() => selectedProductId = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Product',
                              suffixIcon: Icon(Icons.arrow_drop_down_rounded),
                            ),
                            child: Text(
                              selectedLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    ),

                  // USER SEGMENT DROPDOWN
                  if (!isEdit)
                    DropdownButtonFormField<int>(
                      value: selectedSegmentId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'User Segment',
                      ),
                      items: segmentItems
                          .map(
                            (s) => DropdownMenuItem<int>(
                              value: s.id,
                              child: Text(
                                s.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedSegmentId = v),
                    ),

                  const Divider(),

                  // RETAIL
                  SwitchListTile(
                    title: const Text('Retail'),
                    value: isRetail,
                    onChanged: (v) => setState(() => isRetail = v),
                  ),
                  TextField(
                    controller: retailPriceCtrl,
                    enabled: isRetail,
                    decoration: const InputDecoration(
                      labelText: 'Retail Price',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: retailMinQtyCtrl,
                          enabled: isRetail,
                          decoration: const InputDecoration(
                            labelText: 'Min Qty',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: retailMaxQtyCtrl,
                          enabled: isRetail,
                          decoration: const InputDecoration(
                            labelText: 'Max Qty',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  const Divider(),

                  // WHOLESALE
                  SwitchListTile(
                    title: const Text('Wholesale'),
                    value: isWholesale,
                    onChanged: (v) => setState(() => isWholesale = v),
                  ),
                  TextField(
                    controller: wholesalePriceCtrl,
                    enabled: isWholesale,
                    decoration: const InputDecoration(
                      labelText: 'Wholesale Price',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: wholesaleMinQtyCtrl,
                          enabled: isWholesale,
                          decoration: const InputDecoration(
                            labelText: 'Min Qty',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: wholesaleMaxQtyCtrl,
                          enabled: isWholesale,
                          decoration: const InputDecoration(
                            labelText: 'Max Qty',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  const Divider(),

                  TextField(
                    controller: offerCtrl,
                    decoration: const InputDecoration(labelText: 'Offer %'),
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saving
                          ? null
                          : () async {
                              setState(() => saving = true);
                              final Map<String, dynamic> data = {
                                'is_retail': isRetail,
                                'retail_price':
                                    double.tryParse(retailPriceCtrl.text) ?? 0,
                                'retail_lowest_order_quantity':
                                    int.tryParse(retailMinQtyCtrl.text) ?? 0,
                                'retail_max_order_quantity':
                                    int.tryParse(retailMaxQtyCtrl.text) ?? 0,
                                'is_wholesale': isWholesale,
                                'wholesale_price':
                                    double.tryParse(wholesalePriceCtrl.text) ??
                                    0,
                                'wholesale_lowest_order_quantity':
                                    int.tryParse(wholesaleMinQtyCtrl.text) ?? 0,
                                'wholesale_max_order_quantity':
                                    int.tryParse(wholesaleMaxQtyCtrl.text) ?? 0,
                                'offer_percent':
                                    double.tryParse(offerCtrl.text) ?? 0,
                              };

                              if (isEdit) {
                                await controller.updatePriceSegment(
                                  ps.id,
                                  data,
                                );
                              } else {
                                if (selectedProductId == null ||
                                    selectedSegmentId == null) {
                                  Get.snackbar(
                                    'Missing fields',
                                    'Please select product and user segment',
                                  );
                                  setState(() => saving = false);
                                  return;
                                }

                                final productId = selectedProductId;
                                final segmentId = selectedSegmentId;
                                data.addAll({
                                  'product_id': productId,
                                  'segment_id': segmentId,
                                });
                                await controller.createPriceSegment(data);
                              }

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
                          : Text(isEdit ? 'Update' : 'Create'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // =============================
  // UI
  // =============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Price Segments (${controller.items.length})')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPriceSegmentForm(context),
        child: const Icon(Icons.add),
      ),
      body: CrudListPage<PriceSegmentModel>(
        controller: controller,

        // SEARCH: product name + arabic name
        onSearch: (v) {
          controller.search.value = v;
          controller.fetch(reset: true);
        },

        itemBuilder: (item) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.price_change_rounded,
                      color: Colors.orange.shade600,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(() {
                      final productName = _productName(item.productId);
                      final productArabicName = _productArabicName(
                        item.productId,
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          if (productArabicName.isNotEmpty)
                            Text(
                              productArabicName,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              if (item.isRetail)
                                _priceChip(
                                  'Retail',
                                  item.retailPrice,
                                  Colors.green,
                                ),
                              if (item.isRetail && item.isWholesale)
                                const SizedBox(width: 6),
                              if (item.isWholesale)
                                _priceChip(
                                  'Wholesale',
                                  item.wholesalePrice,
                                  Colors.blue,
                                ),
                            ],
                          ),
                        ],
                      );
                    }),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, size: 20),
                        onPressed: () =>
                            _showPriceSegmentForm(context, ps: item),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_rounded,
                          size: 20,
                          color: Colors.red.shade400,
                        ),
                        onPressed: () async {
                          final productName = _productName(item.productId);
                          if (await confirmDelete(
                            context,
                            title: 'Delete Price Rule',
                            message:
                                'Delete pricing for "$productName"? This cannot be undone.',
                          )) {
                            await controller.deletePriceSegment(item.id);
                          }
                        },
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
