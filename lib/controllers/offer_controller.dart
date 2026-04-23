import '../models/offer_model.dart';
import 'base_crud_controller.dart';
import '../core/services/api_service.dart';

class OfferController extends BaseCrudController<OfferModel> {
  @override
  String get endpoint => '/offers';

  @override
  OfferModel fromJson(Map<String, dynamic> json) => OfferModel.fromJson(json);

  void onSearchChanged(String value) => updateSearch(value);

  Future<void> createOffer({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required bool isActive,
    String imageUrl = '',
  }) async {
    await ApiService.dio.post(
      '$endpoint/create',
      data: {
        'title': title,
        'description': description,
        if (imageUrl.isNotEmpty) 'image_url': imageUrl,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'is_active': isActive,
      },
    );
    fetch(reset: true);
  }

  Future<void> updateOffer({
    required int id,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required bool isActive,
    String imageUrl = '',
  }) async {
    await ApiService.dio.put(
      '$endpoint/update/$id',
      data: {
        'title': title,
        'description': description,
        'image_url': imageUrl,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'is_active': isActive,
      },
    );
    fetch(reset: true);
  }

  Future<void> deleteOffer(int id) async {
    await ApiService.dio.delete('$endpoint/delete/$id');
    fetch(reset: true);
  }

  Future<OfferModel> getOffer(int id) async {
    final res = await ApiService.dio.get('$endpoint/get/$id');
    return fromJson(res.data);
  }
}
