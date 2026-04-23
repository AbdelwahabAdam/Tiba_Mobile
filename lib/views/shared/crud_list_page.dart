import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/base_crud_controller.dart';

class CrudListPage<T> extends StatelessWidget {
  final BaseCrudController<T> controller;
  final Widget Function(T) itemBuilder;
  final Function(String)? onSearch;

  const CrudListPage({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.items;
      final hasMore = controller.hasMore.value;
      final loading = controller.loading.value;
      final isEmpty = items.isEmpty && !loading;

      return RefreshIndicator(
        onRefresh: () => controller.fetch(reset: true),
        child: Column(
          children: [
            // ── Search bar ──
            if (onSearch != null)
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    hintText: 'Search...',
                    suffixIcon: controller.search.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () => onSearch!(''),
                          )
                        : null,
                  ),
                  onChanged: onSearch,
                ),
              ),

            // ── Content ──
            Expanded(
              child: isEmpty
                  ? _EmptyState()
                  : NotificationListener<ScrollNotification>(
                      onNotification: (scroll) {
                        if (scroll.metrics.pixels >=
                            scroll.metrics.maxScrollExtent - 100) {
                          controller.fetch();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 6, bottom: 100),
                        itemCount: items.length + (hasMore ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i == items.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          }
                          return itemBuilder(items[i]);
                        },
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No items found',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pull down to refresh',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
