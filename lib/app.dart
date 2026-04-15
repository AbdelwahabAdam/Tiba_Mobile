import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.GATE,
      getPages: AppRoutes.pages,
      theme: AppTheme.light,
    );
  }
}

// ─────────────────────────────────────────────
// Global Design System
// ─────────────────────────────────────────────
class AppTheme {
  static const Color _seed = Color(0xFF00695C); // Teal 800

  static ThemeData get light {
    final cs = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: const Color(0xFFF0F4F8),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: cs.onPrimary,
          letterSpacing: 0.3,
        ),
        iconTheme: IconThemeData(color: cs.onPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.07),
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.error),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade600),
        hintStyle: TextStyle(color: Colors.grey.shade400),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 2,
          shadowColor: cs.primary.withOpacity(0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: const Size(double.infinity, 48),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: cs.primary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cs.primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.55),
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? cs.primary : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? cs.primary.withOpacity(0.4)
              : null,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
      dividerTheme: DividerThemeData(
        thickness: 1,
        space: 0,
        color: Colors.grey.shade200,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shared UI helpers (used across pages)
// ─────────────────────────────────────────────

/// Rounded-top drag handle for bottom sheets
Widget sheetHandle() => Center(
  child: Container(
    width: 40,
    height: 4,
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(2),
    ),
  ),
);

/// Status chip (Active / Inactive)
Widget statusChip(bool isActive) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  decoration: BoxDecoration(
    color: isActive
        ? Colors.green.withOpacity(0.1)
        : Colors.red.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: isActive ? Colors.green.shade300 : Colors.red.shade300,
      width: 0.8,
    ),
  ),
  child: Text(
    isActive ? 'Active' : 'Inactive',
    style: TextStyle(
      color: isActive ? Colors.green.shade700 : Colors.red.shade700,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    ),
  ),
);

/// Square thumbnail with network image or icon fallback
Widget itemThumbnail(
  String? imageUrl, {
  IconData fallbackIcon = Icons.image_outlined,
  Color? iconColor,
  double size = 52,
}) {
  final color = iconColor ?? Colors.teal.shade300;
  final placeholder = Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(fallbackIcon, color: color, size: size * 0.5),
  );

  if (imageUrl == null || imageUrl.isEmpty) return placeholder;

  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.network(
      imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder,
    ),
  );
}

/// Rounded modal bottom sheet helper
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required Widget child,
  bool scrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: scrollControlled,
    backgroundColor: const Color(0xFFF0F4F8),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => child,
  );
}

/// Delete confirmation dialog – resolves to `true` when user confirms.
Future<bool> confirmDelete(
  BuildContext context, {
  String title = 'Delete item',
  String? message,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title),
      content: Text(message ?? 'This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return result ?? false;
}
