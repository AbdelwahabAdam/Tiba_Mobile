import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/user_segment_controller.dart';
import '../../models/user_model.dart';
import '../shared/crud_list_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final controller = Get.put(UserController(), permanent: true);
  final userSegmentCtrl = Get.find<UserSegmentController>();

  @override
  void initState() {
    super.initState();
    controller.loadSegments(); // load once
  }

  void _showEditDialog(BuildContext context, UserModel user) async {
    await controller.loadSegments();

    final emailCtrl = TextEditingController(text: user.email);
    final firstNameCtrl = TextEditingController(text: user.firstName);
    final lastNameCtrl = TextEditingController(text: user.lastName);
    final loyaltyCtrl = TextEditingController(
      text: user.loyaltyPoints.toString(),
    );
    final walletCtrl = TextEditingController(
      text: user.walletBalance.toString(),
    );

    bool isActive = user.isActive;
    bool isDeleted = user.isDeleted;
    bool isVerified = user.isVerified;
    bool receiveEmails = user.receiveEmails;
    int? selectedSegmentId = user.segmentId;
    int selectedRoleId = user.roleId;
    bool saving = false;

    showModalBottomSheet(
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
                const Text(
                  'Edit User',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),

                // Email (read-only)
                TextField(
                  controller: emailCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),

                TextField(
                  controller: firstNameCtrl,
                  decoration: const InputDecoration(labelText: 'First Name'),
                ),

                TextField(
                  controller: lastNameCtrl,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),

                TextField(
                  controller: loyaltyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Loyalty Points',
                  ),
                ),

                TextField(
                  controller: walletCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Wallet Balance',
                  ),
                ),

                const SizedBox(height: 8),

                // Segment
                Obx(
                  () => DropdownButtonFormField<int>(
                    value: selectedSegmentId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'User Segment',
                    ),
                    items: userSegmentCtrl.items
                        .map(
                          (seg) => DropdownMenuItem<int>(
                            value: seg.id,
                            child: Text(
                              seg.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => selectedSegmentId = v),
                  ),
                ),

                // Role
                DropdownButtonFormField<int>(
                  value: selectedRoleId,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Admin')),
                    DropdownMenuItem(value: 2, child: Text('Customer')),
                  ],
                  onChanged: (v) =>
                      setState(() => selectedRoleId = v ?? selectedRoleId),
                ),

                SwitchListTile(
                  title: const Text('Active'),
                  value: isDeleted ? false : isActive,
                  onChanged: isDeleted
                      ? null
                      : (v) => setState(() => isActive = v),
                ),

                SwitchListTile(
                  title: const Text('Scheduled For Deletion'),
                  subtitle: const Text(
                    'When enabled, the account is suspended for 7 days before permanent deletion. Contact admin to undo it.',
                  ),
                  value: isDeleted,
                  onChanged: (v) => setState(() {
                    isDeleted = v;
                    if (v) {
                      isActive = false;
                    }
                  }),
                ),

                SwitchListTile(
                  title: const Text('Verified'),
                  value: isVerified,
                  onChanged: (v) => setState(() => isVerified = v),
                ),

                SwitchListTile(
                  title: const Text('Receive Emails'),
                  subtitle: const Text('Send order status emails to this user'),
                  value: receiveEmails,
                  onChanged: (v) => setState(() => receiveEmails = v),
                ),

                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setState(() => saving = true);
                          await controller.updateUser(user.id, {
                            'first_name': firstNameCtrl.text.trim(),
                            'last_name': lastNameCtrl.text.trim(),
                            'segment_id': selectedSegmentId,
                            'role_id': selectedRoleId,
                            'loyalty_points':
                                int.tryParse(loyaltyCtrl.text) ?? 0,
                            'wallet_balance':
                                double.tryParse(walletCtrl.text) ?? 0.0,
                            'is_active': isActive,
                            'is_deleted': isDeleted,
                            'is_verified': isVerified,
                            'receive_emails': receiveEmails,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Users (${controller.items.length})')),
      ),
      body: CrudListPage<UserModel>(
        controller: controller,
        onSearch: controller.onSearchChanged,
        itemBuilder: (item) {
          final initials =
              '${item.firstName.isNotEmpty ? item.firstName[0] : ''}${item.lastName.isNotEmpty ? item.lastName[0] : ''}'
                  .toUpperCase();
          final roleLabel = item.roleId == 1 ? 'Admin' : 'Customer';
          final roleColor = item.roleId == 1 ? Colors.purple : Colors.teal;
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.12),
                child: Text(
                  initials.isNotEmpty ? initials : '?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              title: Text(
                '${item.firstName} ${item.lastName}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.email,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      statusChip(item.isActive),
                      const SizedBox(width: 6),
                      if (item.isDeleted) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.shade300,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            'Deleted',
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: roleColor.withOpacity(0.35),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          roleLabel,
                          style: TextStyle(
                            color: roleColor.withAlpha(210),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
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
                    onPressed: () => _showEditDialog(context, item),
                  ),
                  IconButton(
                    icon: Icon(
                      item.isDeleted
                          ? Icons.restore_from_trash_rounded
                          : Icons.delete_sweep_rounded,
                      size: 20,
                      color: item.isDeleted
                          ? Colors.green.shade500
                          : Colors.red.shade400,
                    ),
                    onPressed: () async {
                      if (await confirmDelete(
                        context,
                        title: item.isDeleted ? 'Restore User' : 'Suspend User',
                        message: item.isDeleted
                            ? 'Restore ${item.firstName} ${item.lastName} and allow login again?'
                            : 'Suspend ${item.firstName} ${item.lastName} and mark the account for permanent deletion after 7 days?',
                      )) {
                        await controller.setDeletedStatus(
                          item.id,
                          !item.isDeleted,
                        );
                      }
                    },
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
