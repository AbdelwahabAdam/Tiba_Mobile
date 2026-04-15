import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../app.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';
import '../shared/crud_list_page.dart';
import '../../core/services/upload_service.dart';

class ProductPage extends StatelessWidget {
  ProductPage({super.key});

  final controller = Get.put(ProductController());

  // ─────────────────────────────────────────────
  // Create / Edit Bottom Sheet
  // ─────────────────────────────────────────────
  Future<void> _showForm(BuildContext context, {ProductModel? product}) async {
    await controller.loadCategories();

    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final arabicNameCtrl = TextEditingController(
      text: product?.arabicName ?? '',
    );
    final manufacturerCtrl = TextEditingController(
      text: product?.manufacturerName ?? '',
    );
    final arabicManufacturerCtrl = TextEditingController(
      text: product?.arabicManufacturerName ?? '',
    );
    final descCtrl = TextEditingController(text: product?.description ?? '');
    final arabicDescCtrl = TextEditingController(
      text: product?.arabicDescription ?? '',
    );
    final imageCtrl = TextEditingController(text: product?.imageUrl ?? '');

    String imagePreviewUrl = product?.imageUrl ?? '';

    int? selectedCategoryId = product?.categoryId;
    int? selectedSubCategoryId = product?.subcategoryId;
    bool isActive = product?.isActive ?? true;
    bool saving = false;

    // 🔥 SAFETY: ensure selected category exists
    final categoryIds = controller.categories.map((c) => c.id).toSet();
    if (!categoryIds.contains(selectedCategoryId)) {
      selectedCategoryId = null;
      selectedSubCategoryId = null;
    }

    if (selectedCategoryId != null) {
      await controller.loadSubCategories(selectedCategoryId);
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF0F4F8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                sheetHandle(),
                _sheetTitle(product),
                const SizedBox(height: 8),

                // ───── Image Preview ─────
                if (imagePreviewUrl.isNotEmpty) _imagePreview(imagePreviewUrl),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: imageCtrl,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Image URL',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.upload),
                      onPressed: () {
                        _pickAndUploadImage(context, (url) {
                          setState(() {
                            imagePreviewUrl = url;
                            imageCtrl.text = url;
                          });
                        });
                      },
                    ),
                  ],
                ),

                _textField(nameCtrl, 'Name'),
                _textField(arabicNameCtrl, 'Arabic Name'),
                _textField(manufacturerCtrl, 'Manufacturer'),
                _textField(arabicManufacturerCtrl, 'Arabic Manufacturer'),
                _textField(descCtrl, 'Description'),
                _textField(arabicDescCtrl, 'Arabic Description'),

                const SizedBox(height: 8),

                // ───── Category Dropdown (SAFE) ─────
                Obx(() {
                  final safeCategoryValue =
                      controller.categories.any(
                        (c) => c.id == selectedCategoryId,
                      )
                      ? selectedCategoryId
                      : null;

                  return DropdownButtonFormField<int>(
                    value: safeCategoryValue,
                    hint: const Text('Select Category'),
                    items: controller.categories
                        .map(
                          (c) => DropdownMenuItem<int>(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) async {
                      setState(() {
                        selectedCategoryId = v;
                        selectedSubCategoryId = null;
                      });

                      controller.subcategories.clear();

                      if (v != null) {
                        await controller.loadSubCategories(v);
                      }
                    },
                  );
                }),

                const SizedBox(height: 8),

                // ───── Subcategory Dropdown (SAFE) ─────
                Obx(() {
                  final safeSubValue =
                      controller.subcategories.any(
                        (s) => s.id == selectedSubCategoryId,
                      )
                      ? selectedSubCategoryId
                      : null;

                  return DropdownButtonFormField<int>(
                    value: safeSubValue,
                    hint: Text(
                      controller.subcategories.isEmpty
                          ? 'Select category first'
                          : 'Select Sub Category',
                    ),
                    items: controller.subcategories
                        .map(
                          (s) => DropdownMenuItem<int>(
                            value: s.id,
                            child: Text(s.name),
                          ),
                        )
                        .toList(),
                    onChanged: controller.subcategories.isEmpty
                        ? null
                        : (v) => setState(() => selectedSubCategoryId = v),
                  );
                }),

                SwitchListTile(
                  title: const Text('Active'),
                  value: isActive,
                  onChanged: (v) => setState(() => isActive = v),
                ),

                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setState(() => saving = true);
                          final payload = {
                            'name': nameCtrl.text.trim(),
                            'arabic_name': arabicNameCtrl.text.trim(),
                            'manufacturer_name': manufacturerCtrl.text.trim(),
                            'arabic_manufacturer_name': arabicManufacturerCtrl
                                .text
                                .trim(),
                            'description': descCtrl.text.trim(),
                            'arabic_description': arabicDescCtrl.text.trim(),
                            'image_url': imageCtrl.text.trim(),
                            'category_id': selectedCategoryId,
                            'subcategory_id': selectedSubCategoryId,
                            'price_segments': [],
                            'is_active': isActive,
                          };

                          if (product == null) {
                            await controller.createProduct(payload);
                          } else {
                            await controller.updateProduct(product.id, payload);
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
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Image Upload
  // ─────────────────────────────────────────────
  Future<void> _pickAndUploadImage(
    BuildContext context,
    void Function(String) onUploaded,
  ) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return;

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final imageUrl = await UploadService.uploadImage(
        file: File(picked.path),
        folder: 'products',
      );

      Get.back();
      onUploaded(imageUrl);
    } catch (e) {
      Get.back();
      Get.snackbar('Upload failed', e.toString());
    }
  }

  // ─────────────────────────────────────────────
  // UI Helpers
  // ─────────────────────────────────────────────
  Widget _sheetTitle(ProductModel? product) {
    return Text(
      product == null ? 'Create Product' : 'Edit Product',
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
    );
  }

  Widget _textField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _imagePreview(String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 160,
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const Text('Invalid image URL'),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, ProductModel item) async {
    if (await confirmDelete(
      context,
      title: 'Delete Product',
      message: 'Delete "${item.name}"? This cannot be undone.',
    )) {
      await controller.deleteProduct(item.id);
    }
  }

  // ─────────────────────────────────────────────
  // Page UI
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Products (${controller.items.length})')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: CrudListPage<ProductModel>(
          controller: controller,
          onSearch: controller.onSearchChanged,
          itemBuilder: (item) => Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              leading: itemThumbnail(
                item.imageUrl,
                fallbackIcon: Icons.shopping_bag_outlined,
              ),
              title: Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.arabicName.isNotEmpty)
                    Text(
                      item.arabicName,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  const SizedBox(height: 5),
                  statusChip(item.isActive),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, size: 20),
                    onPressed: () => _showForm(context, product: item),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_rounded,
                      size: 20,
                      color: Colors.red.shade400,
                    ),
                    onPressed: () => _confirmDelete(context, item),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
