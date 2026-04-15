import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/auth_service.dart';
import '../../routes/app_routes.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _isLoggingOut = false;
  bool _isLoggingOutAll = false;

  Future<void> _logoutCurrentDevice() async {
    final confirmed = await _confirm(
      title: 'Log out?',
      message: 'You will be signed out from this device.',
      confirmLabel: 'Log out',
    );

    if (!confirmed) return;

    setState(() => _isLoggingOut = true);
    final success = await AuthService.logoutCurrentDevice();
    if (!mounted) return;

    if (!success) {
      Get.snackbar(
        'Signed out locally',
        'Server logout failed. Current device has been signed out.',
      );
    }

    Get.offAllNamed(Routes.LOGIN);
  }

  Future<void> _logoutAllDevices() async {
    final confirmed = await _confirm(
      title: 'Log out everywhere?',
      message: 'This will sign you out from all devices.',
      confirmLabel: 'Log out all',
    );

    if (!confirmed) return;

    setState(() => _isLoggingOutAll = true);
    final success = await AuthService.logoutAllDevices();
    if (!mounted) return;

    if (!success) {
      Get.snackbar(
        'Signed out locally',
        'Could not confirm sign-out on all devices. Please sign in again and retry.',
      );
    }

    Get.offAllNamed(Routes.LOGIN);
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final canTap = !_isLoggingOut && !_isLoggingOutAll;

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Session',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage sign-out options for this account.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: canTap ? _logoutCurrentDevice : null,
                      icon: _isLoggingOut
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.logout),
                      label: const Text('Log out'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: canTap ? _logoutAllDevices : null,
                      icon: _isLoggingOutAll
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.devices_other),
                      label: const Text('Log out from all devices'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
