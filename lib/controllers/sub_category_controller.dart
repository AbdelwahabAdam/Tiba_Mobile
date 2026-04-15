import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../models/simple_category_model.dart';
import '../models/sub_category_model.dart';
import 'base_crud_controller.dart';
import '../core/services/api_service.dart';

class SubCategoryController extends BaseCrudController<SubCategoryModel> {
  @override
  String get endpoint => '/subcategories';
  final categories = <SimpleCategory>[].obs;

  @override
  SubCategoryModel fromJson(Map<String, dynamic> json) =>
      SubCategoryModel.fromJson(json);

  void onSearchChanged(String v) => updateSearch(v);

  Future<SubCategoryModel> getSubCategory(int id) async {
    final res = await ApiService.dio.get('$endpoint/get/$id');
    return fromJson(res.data);
  }

  Future<void> createSubCategory(Map<String, dynamic> data) async {
    await ApiService.dio.post('$endpoint/create', data: data);
    fetch(reset: true);
  }

  Future<void> updateSubCategory(int id, Map<String, dynamic> data) async {
    await ApiService.dio.put('$endpoint/update/$id', data: data);
    fetch(reset: true);
  }

  Future<void> deleteSubCategory(int id) async {
    await ApiService.dio.delete('$endpoint/delete/$id');
    fetch(reset: true);
  }

  Future<void> loadCategories() async {
    final res = await ApiService.dio.get(
      '/categories',
      queryParameters: {'limit': 1000},
    );

    categories.assignAll(
      (res.data['items'] as List)
          .map((e) => SimpleCategory.fromJson(e))
          .toList(),
    );
  }
}
