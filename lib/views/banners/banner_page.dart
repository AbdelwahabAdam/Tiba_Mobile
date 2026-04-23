import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../app.dart';
import '../../controllers/banner_controller.dart';
import '../../models/banner_model.dart';
import '../../core/services/upload_service.dart';
import '../shared/crud_list_page.dart';

class BannerPage extends StatelessWidget {
  BannerPage({super.key});

  final controller = Get.put(BannerController());

  // ─────────────────────────────────────────────
  // Create / Edit Bottom Sheet
  // ─────────────────────────────────────────────
  Future<void> _showForm(BuildContext context, {BannerModel? banner}) async {
    final titleCtrl = TextEditingController(text: banner?.title ?? '');
    final sortCtrl = TextEditingController(
      text: (banner?.sortOrder ?? 0).toString(),
    );
    final imageCtrl = TextEditingController(text: banner?.imageUrl ?? '');

    String imagePreviewUrl = banner?.imageUrl ?? '';
    bool isActive = banner?.isActive ?? true;
    bool saving = false;

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
                Text(
                  banner == null ? 'Add Banner' : 'Edit Banner',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Image preview ──
                if (imagePreviewUrl.isNotEmpty) _imagePreview(imagePreviewUrl),

                // ── Image URL + upload button ──
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: imageCtrl,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Banner Image *',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      icon: const Icon(Icons.upload_rounded, size: 18),
                      label: const Text('Upload'),
                      onPressed: () => _pickAndUploadImage(context, (url) {
                        setState(() {
                          imagePreviewUrl = url;
                          imageCtrl.text = url;
                        });
                      }),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ── Title (optional) ──
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Title (optional)',
                  ),
                ),

                const SizedBox(height: 10),

                // ── Sort order ──
                TextField(
                  controller: sortCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Sort Order'),
                ),

                const SizedBox(height: 4),

                // ── Active switch ──
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  value: isActive,
                  onChanged: (v) => setState(() => isActive = v),
                ),

                const SizedBox(height: 12),

                // ── Save button ──
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          if (imageCtrl.text.trim().isEmpty) {
                            Get.snackbar(
                              'Validation',
                              'Please upload a banner image.',
                            );
                            return;
                          }
                          setState(() => saving = true);
                          try {
                            final sortOrder =
                                int.tryParse(sortCtrl.text.trim()) ?? 0;
                            if (banner == null) {
                              await controller.createBanner(
                                imageUrl: imageCtrl.text.trim(),
                                title: titleCtrl.text.trim(),
                                isActive: isActive,
                                sortOrder: sortOrder,
                              );
                            } else {
                              await controller.updateBanner(
                                id: banner.id,
                                imageUrl: imageCtrl.text.trim(),
                                title: titleCtrl.text.trim(),
                                isActive: isActive,
                                sortOrder: sortOrder,
                              );
                            }
                            Get.back();
                          } catch (e) {
                            setState(() => saving = false);
                            Get.snackbar('Error', e.toString());
                          }
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
  // Delete confirmation dialog
  // ─────────────────────────────────────────────
  Future<void> _confirmDelete(BuildContext context, BannerModel banner) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Banner'),
        content: Text(
          banner.title != null && banner.title!.isNotEmpty
              ? 'Delete "${banner.title}"?'
              : 'Delete this banner?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.deleteBanner(banner.id);
    }
  }

  // ─────────────────────────────────────────────
  // Image Upload Helper
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
        folder: 'banners',
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
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
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

  // ─────────────────────────────────────────────
  // Page UI
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Banners (${controller.items.length})')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: CrudListPage<BannerModel>(
          controller: controller,
          itemBuilder: (item) {
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                leading: itemThumbnail(
                  item.imageUrl,
                  fallbackIcon: Icons.image_outlined,
                  size: 60,
                ),
                title: Text(
                  item.title != null && item.title!.isNotEmpty
                      ? item.title!
                      : 'Banner #${item.id}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Row(
                  children: [
                    statusChip(item.isActive),
                    const SizedBox(width: 8),
                    Text(
                      'Order: ${item.sortOrder}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit',
                      onPressed: () => _showForm(context, banner: item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Delete',
                      onPressed: () => _confirmDelete(context, item),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
