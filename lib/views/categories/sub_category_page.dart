import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../app.dart';
import '../../controllers/sub_category_controller.dart';
import '../../models/sub_category_model.dart';
import '../../core/services/upload_service.dart';
import '../shared/crud_list_page.dart';

class SubCategoryPage extends StatelessWidget {
  SubCategoryPage({super.key});

  final controller = Get.put(SubCategoryController());

  // ─────────────────────────────────────────────
  // Edit Bottom Sheet
  // ─────────────────────────────────────────────
  void _showEditDialog(BuildContext context, SubCategoryModel sub) async {
    final nameCtrl = TextEditingController(text: sub.name);
    final arabicCtrl = TextEditingController(text: sub.arabicName);
    final imageCtrl = TextEditingController(text: sub.imageUrl);

    String imagePreviewUrl = sub.imageUrl;
    bool isActive = sub.isActive;
    int? selectedCategoryId = sub.categoryId;
    bool saving = false;

    await controller.loadCategories();

    // Ensure selected category exists in the list
    final categoryIds = controller.categories.map((c) => c.id).toSet();

    if (!categoryIds.contains(selectedCategoryId)) {
      selectedCategoryId = null;
    }

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
                  const Text(
                    'Edit Subcategory',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
                            folder: 'subcategories',
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

                  Obx(
                    () => DropdownButtonFormField<int>(
                      value:
                          controller.categories.any(
                            (c) => c.id == selectedCategoryId,
                          )
                          ? selectedCategoryId
                          : null,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: controller.categories
                          .map(
                            (c) => DropdownMenuItem<int>(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedCategoryId = v),
                    ),
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

                  ElevatedButton(
                    onPressed: saving
                        ? null
                        : () async {
                            setState(() => saving = true);
                            await controller.updateSubCategory(sub.id, {
                              'category_id': selectedCategoryId,
                              'name': nameCtrl.text.trim(),
                              'arabic_name': arabicCtrl.text.trim(),
                              'image_url': imageCtrl.text.trim(),
                              'is_active': isActive,
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
          ),
        );
      },
    );
  }

  void _showCreateDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final arabicCtrl = TextEditingController();
    final imageCtrl = TextEditingController();

    String imagePreviewUrl = '';
    bool isActive = true;
    int? selectedCategoryId;
    bool saving = false;

    await controller.loadCategories();

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
                  const Text(
                    'Create Subcategory',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
                            folder: 'subcategories',
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

                  Obx(
                    () => DropdownButtonFormField<int>(
                      value:
                          controller.categories.any(
                            (c) => c.id == selectedCategoryId,
                          )
                          ? selectedCategoryId
                          : null,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: controller.categories
                          .map(
                            (c) => DropdownMenuItem<int>(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedCategoryId = v),
                    ),
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

                  ElevatedButton(
                    onPressed: saving
                        ? null
                        : () async {
                            setState(() => saving = true);
                            await controller.createSubCategory({
                              'category_id': selectedCategoryId,
                              'name': nameCtrl.text.trim(),
                              'arabic_name': arabicCtrl.text.trim(),
                              'image_url': imageCtrl.text.trim(),
                              'is_active': isActive,
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
                        : const Text('Create'),
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
  // Image Helpers
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

  Future<void> _confirmDelete(
    BuildContext context,
    SubCategoryModel item,
  ) async {
    if (await confirmDelete(
      context,
      title: 'Delete Subcategory',
      message: 'Delete "${item.name}"? This cannot be undone.',
    )) {
      await controller.deleteSubCategory(item.id);
    }
  }

  // ─────────────────────────────────────────────
  // Page UI
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Subcategories (${controller.items.length})')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: CrudListPage<SubCategoryModel>(
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
                fallbackIcon: Icons.list_alt_rounded,
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
                    onPressed: () => _showEditDialog(context, item),
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
