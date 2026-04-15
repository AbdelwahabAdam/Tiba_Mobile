import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app.dart';
import '../../controllers/user_segment_controller.dart';
import '../../models/user_segment_model.dart';
import '../shared/crud_list_page.dart';

class UserSegmentPage extends StatelessWidget {
  UserSegmentPage({super.key});

  final controller = Get.find<UserSegmentController>();

  // =============================
  // CREATE FORM
  // =============================

  void _showCreateDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final arabicCtrl = TextEditingController();
    bool isActive = true;
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                sheetHandle(),
                const Text(
                  'Add User Segment',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
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
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saving
                        ? null
                        : () async {
                            setState(() => saving = true);
                            await controller.createUserSegment({
                              'name': nameCtrl.text.trim(),
                              'arabic_name': arabicCtrl.text.trim(),
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =============================
  // EDIT FORM (unchanged)
  // =============================

  void _showEditDialog(BuildContext context, UserSegmentModel seg) {
    final nameCtrl = TextEditingController(text: seg.name);
    final arabicCtrl = TextEditingController(text: seg.arabicName);
    bool isActive = seg.isActive;
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                sheetHandle(),
                const Text(
                  'Edit User Segment',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
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
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saving
                        ? null
                        : () async {
                            setState(() => saving = true);
                            await controller.updateUserSegment(seg.id, {
                              'name': nameCtrl.text.trim(),
                              'arabic_name': arabicCtrl.text.trim(),
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
                ),
              ],
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
        title: Obx(() => Text('User Segments (${controller.items.length})')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
      body: CrudListPage<UserSegmentModel>(
        controller: controller,
        onSearch: (v) {
          controller.search.value = v;
          controller.fetch(reset: true);
        },
        itemBuilder: (item) => Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.group_rounded,
                color: Colors.teal.shade400,
                size: 22,
              ),
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
                  onPressed: () async {
                    if (await confirmDelete(
                      context,
                      title: 'Delete Segment',
                      message: 'Delete "${item.name}"? This cannot be undone.',
                    )) {
                      await controller.deleteUserSegment(item.id);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
