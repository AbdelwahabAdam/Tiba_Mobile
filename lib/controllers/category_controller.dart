import '../core/services/api_service.dart';
import '../core/utils/app_logger.dart';
import '../models/category_model.dart';
import 'base_crud_controller.dart';

class CategoryController extends BaseCrudController<CategoryModel> {
  @override
  String get endpoint => '/categories';

  @override
  CategoryModel fromJson(Map<String, dynamic> json) =>
      CategoryModel.fromJson(json);

  void onSearchChanged(String value) => updateSearch(value);

  @override
  void onInit() {
    super.onInit();
    appLogger.d('CategoryController initialized');
  }

  Future<void> createCategory({
    required String name,
    required String arabicName,
    required bool isActive,
    String? imageUrl,
  }) async {
    await ApiService.dio.post(
      '$endpoint/create',
      data: {
        'name': name,
        'arabic_name': arabicName,
        'is_active': isActive,
        'image_url': imageUrl,
      },
    );

    fetch(reset: true);
  }

  /// DELETE
  Future<void> deleteCategory(int id) async {
    await ApiService.dio.delete('$endpoint/delete/$id');
    fetch(reset: true);
  }

  /// UPDATE
  Future<void> updateCategory({
    required int id,
    required String name,
    required String arabicName,
    required bool isActive,
    String? imageUrl,
  }) async {
    await ApiService.dio.put(
      '$endpoint/update/$id',
      data: {
        'name': name,
        'arabic_name': arabicName,
        'is_active': isActive,
        'image_url': imageUrl,
      },
    );

    fetch(reset: true);
  }

  Future<CategoryModel> getCategory(int id) async {
    final res = await ApiService.dio.get('$endpoint/get/$id');
    return fromJson(res.data);
  }
}
