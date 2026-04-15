import 'package:get/get.dart';
import '../core/services/api_service.dart';
import '../core/utils/app_logger.dart';
import '../models/product_model.dart';
import '../models/simple_category_model.dart';
import '../models/simple_subcategory_model.dart';
import 'base_crud_controller.dart';

class ProductController extends BaseCrudController<ProductModel> {
  @override
  String get endpoint => '/products';

  @override
  ProductModel fromJson(Map<String, dynamic> json) =>
      ProductModel.fromJson(json);

  final categories = <SimpleCategory>[].obs;
  final subcategories = <SimpleSubCategory>[].obs;

  /// Holds ALL products by ID (pagination-safe)
  final productById = <int, ProductModel>{}.obs;
  Future<void>? _lookupLoadFuture;

  Future<void> loadCategories() async {
    try {
      final res = await ApiService.dio.get(
        '/categories',
        queryParameters: {'limit': 1000},
      );
      categories.assignAll(
        (res.data['items'] as List)
            .map((e) => SimpleCategory.fromJson(e))
            .toList(),
      );
    } catch (e) {
      appLogger.e('Failed to load categories', error: e);
      Get.snackbar('Error', 'Failed to load categories');
    }
  }

  Future<void> loadSubCategories(int categoryId) async {
    try {
      final res = await ApiService.dio.get(
        '/subcategories',
        queryParameters: {'category_id': categoryId, 'limit': 1000},
      );
      subcategories.assignAll(
        (res.data['items'] as List)
            .map((e) => SimpleSubCategory.fromJson(e))
            .toList(),
      );
    } catch (e) {
      appLogger.e('Failed to load subcategories', error: e);
      Get.snackbar('Error', 'Failed to load subcategories');
    }
  }

  Future<void> createProduct(Map<String, dynamic> data) async {
    try {
      await ApiService.dio.post('$endpoint/create', data: data);
      await loadAllForLookup();
      fetch(reset: true);
    } catch (e) {
      appLogger.e('Failed to create product', error: e);
      Get.snackbar('Error', 'Failed to create product');
    }
  }

  Future<void> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      await ApiService.dio.put('$endpoint/update/$id', data: data);
      await loadAllForLookup();
      fetch(reset: true);
    } catch (e) {
      appLogger.e('Failed to update product', error: e);
      Get.snackbar('Error', 'Failed to update product');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await ApiService.dio.delete('$endpoint/delete/$id');
      productById.remove(id);
      fetch(reset: true);
    } catch (e) {
      appLogger.e('Failed to delete product', error: e);
      Get.snackbar('Error', 'Failed to delete product');
    }
  }

  Future<ProductModel?> getProduct(int id) async {
    if (productById.containsKey(id)) return productById[id];

    try {
      final res = await ApiService.dio.get('$endpoint/get/$id');
      final product = fromJson(res.data);
      productById[id] = product;
      return product;
    } catch (e) {
      appLogger.e('Failed to get product $id', error: e);
      return null;
    }
  }

  void onSearchChanged(String value) => updateSearch(value);

  Future<void> loadAllForLookup() async {
    if (_lookupLoadFuture != null) {
      return _lookupLoadFuture!;
    }

    _lookupLoadFuture = _loadAllForLookupInternal();
    await _lookupLoadFuture;
  }

  Future<void> _loadAllForLookupInternal() async {
    int currentPage = 1;
    const perPage = 200;

    try {
      while (true) {
        final res = await ApiService.dio.get(
          endpoint,
          queryParameters: {
            'page': currentPage,
            'per_page': perPage,
            // Keep both for compatibility across endpoints.
            'limit': perPage,
          },
        );

        final body = res.data as Map<String, dynamic>?;
        final pageItems = (res.data['items'] as List)
            .map((e) => fromJson(e))
            .toList();

        if (pageItems.isEmpty) break;

        for (final p in pageItems) {
          productById[p.id] = p;
        }

        final totalPages = body?['total_pages'];
        if (totalPages is int) {
          if (currentPage >= totalPages) break;
        } else if (pageItems.length < perPage) {
          break;
        }

        currentPage++;
      }
      appLogger.d('Product lookup map: ${productById.length} entries');
    } catch (e) {
      appLogger.e('Failed to load product lookup map', error: e);
    } finally {
      _lookupLoadFuture = null;
    }
  }
}
