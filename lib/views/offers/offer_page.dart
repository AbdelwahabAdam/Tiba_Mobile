import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../app.dart';
import '../../controllers/offer_controller.dart';
import '../../models/offer_model.dart';
import '../../core/services/upload_service.dart';
import '../shared/crud_list_page.dart';

class OfferPage extends StatelessWidget {
  OfferPage({super.key});

  final controller = Get.put(OfferController());

  // ─────────────────────────────────────────────
  // Create / Edit Bottom Sheet
  // ─────────────────────────────────────────────
  Future<void> _showForm(BuildContext context, {OfferModel? offer}) async {
    final titleCtrl = TextEditingController(text: offer?.title ?? '');
    final descCtrl = TextEditingController(text: offer?.description ?? '');
    final imageCtrl = TextEditingController(text: offer?.imageUrl ?? '');

    String imagePreviewUrl = offer?.imageUrl ?? '';

    DateTime startDate = offer?.startDate ?? DateTime.now();
    DateTime endDate =
        offer?.endDate ?? DateTime.now().add(const Duration(days: 7));

    bool isActive = offer?.isActive ?? true;
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
                  offer == null ? 'Create Offer' : 'Edit Offer',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

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
                    IconButton(
                      icon: const Icon(Icons.upload),
                      tooltip: 'Upload Image',
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

                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),

                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),

                const SizedBox(height: 8),

                ListTile(
                  title: Text(
                    'Start Date: ${startDate.toLocal().toString().split(' ')[0]}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => startDate = picked);
                    }
                  },
                ),

                ListTile(
                  title: Text(
                    'End Date: ${endDate.toLocal().toString().split(' ')[0]}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDate,
                      firstDate: startDate,
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => endDate = picked);
                    }
                  },
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
                          final payload = {
                            'title': titleCtrl.text.trim(),
                            'description': descCtrl.text.trim(),
                            'image_url': imageCtrl.text.trim(),
                            'start_date': startDate.toIso8601String(),
                            'end_date': endDate.toIso8601String(),
                            'is_active': isActive,
                          };

                          if (offer == null) {
                            await controller.createOffer(
                              title: payload['title'] as String,
                              description: payload['description'] as String,
                              startDate: startDate,
                              endDate: endDate,
                              isActive: isActive,
                            );
                          } else {
                            await controller.updateOffer(
                              id: offer.id,
                              title: payload['title'] as String,
                              description: payload['description'] as String,
                              startDate: startDate,
                              endDate: endDate,
                              isActive: isActive,
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
      ),
    );
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
        folder: 'offers',
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

  // ─────────────────────────────────────────────
  // Page UI
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Offers (${controller.items.length})')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: CrudListPage<OfferModel>(
          controller: controller,
          onSearch: controller.onSearchChanged,
          itemBuilder: (item) {
            final start =
                '${item.startDate.day}/${item.startDate.month}/${item.startDate.year}';
            final end =
                '${item.endDate.day}/${item.endDate.month}/${item.endDate.year}';
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                leading: itemThumbnail(
                  item.imageUrl,
                  fallbackIcon: Icons.local_offer_outlined,
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.description.isNotEmpty)
                      Text(
                        item.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        statusChip(item.isActive),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.shade200,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            '$start → $end',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, size: 20),
                      onPressed: () => _showForm(context, offer: item),
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
                          title: 'Delete Offer',
                          message:
                              'Delete "${item.title}"? This cannot be undone.',
                        )) {
                          controller.deleteOffer(item.id);
                        }
                      },
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
