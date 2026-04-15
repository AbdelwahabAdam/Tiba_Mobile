import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../app.dart';
import '../../controllers/category_controller.dart';
import '../../models/category_model.dart';
import '../../core/services/upload_service.dart';
import '../shared/crud_list_page.dart';

class CategoryPage extends StatelessWidget {
  CategoryPage({super.key});

  final controller = Get.put(CategoryController());

  // ─────────────────────────────────────────────
  // Create / Edit Bottom Sheet
  // ─────────────────────────────────────────────
  void _showEditDialog(BuildContext context, {CategoryModel? category}) {
    final nameCtrl = TextEditingController(text: category?.name ?? '');
    final arabicCtrl = TextEditingController(text: category?.arabicName ?? '');
    final imageCtrl = TextEditingController(text: category?.imageUrl ?? '');

    String imagePreviewUrl = category?.imageUrl ?? '';
    bool isActive = category?.isActive ?? true;
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
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  sheetHandle(),
                  Text(
                    category == null ? 'Create Category' : 'Edit Category',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (imagePreviewUrl.isNotEmpty)
                    _imagePreview(imagePreviewUrl),

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
                      IconButton(
                        icon: const Icon(Icons.upload),
                        onPressed: () {
                          _pickAndUploadImage(
                            context,
                            folder: 'categories',
                            onUploaded: (url) {
                              setState(() {
                                imagePreviewUrl = url;
                                imageCtrl.text = url;
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),

                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: arabicCtrl,
                    decoration: const InputDecoration(labelText: 'Arabic Name'),
                  ),

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
                            if (category == null) {
                              await controller.createCategory(
                                name: nameCtrl.text.trim(),
                                arabicName: arabicCtrl.text.trim(),
                                isActive: isActive,
                                imageUrl: imageCtrl.text.trim(),
                              );
                            } else {
                              await controller.updateCategory(
                                id: category.id,
                                name: nameCtrl.text.trim(),
                                arabicName: arabicCtrl.text.trim(),
                                isActive: isActive,
                                imageUrl: imageCtrl.text.trim(),
                              );
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
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // Image Upload Helpers
  // ─────────────────────────────────────────────
  Future<void> _pickAndUploadImage(
    BuildContext context, {
    required String folder,
    required void Function(String) onUploaded,
  }) async {
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
        folder: folder,
      );
      Get.back();
      onUploaded(imageUrl);
    } catch (e) {
      Get.back();
      Get.snackbar('Upload failed', e.toString());
    }
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

  void _confirmDelete(BuildContext context, CategoryModel item) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await controller.deleteCategory(item.id);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Page UI
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Categories (${controller.items.length})')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: CrudListPage<CategoryModel>(
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
                fallbackIcon: Icons.category_outlined,
              ),
              title: Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.arabicName,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
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
                    onPressed: () => _showEditDialog(context, category: item),
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
