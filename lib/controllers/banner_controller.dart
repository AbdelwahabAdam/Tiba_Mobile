import '../models/banner_model.dart';
import 'base_crud_controller.dart';
import '../core/services/api_service.dart';

class BannerController extends BaseCrudController<BannerModel> {
  @override
  String get endpoint => '/banners';

  @override
  BannerModel fromJson(Map<String, dynamic> json) => BannerModel.fromJson(json);

  void onSearchChanged(String value) => updateSearch(value);

  Future<void> createBanner({
    required String imageUrl,
    String? title,
    required bool isActive,
    required int sortOrder,
  }) async {
    await ApiService.dio.post(
      '$endpoint/create',
      data: {
        'image_url': imageUrl,
        if (title != null && title.isNotEmpty) 'title': title,
        'is_active': isActive,
        'sort_order': sortOrder,
      },
    );
    fetch(reset: true);
  }

  Future<void> updateBanner({
    required int id,
    required String imageUrl,
    String? title,
    required bool isActive,
    required int sortOrder,
  }) async {
    await ApiService.dio.put(
      '$endpoint/update/$id',
      data: {
        'image_url': imageUrl,
        'title': title ?? '',
        'is_active': isActive,
        'sort_order': sortOrder,
      },
    );
    fetch(reset: true);
  }

  Future<void> deleteBanner(int id) async {
    await ApiService.dio.delete('$endpoint/delete/$id');
    fetch(reset: true);
  }
}
