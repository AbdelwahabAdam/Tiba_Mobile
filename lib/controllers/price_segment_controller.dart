import '../models/price_segment_model.dart';
import 'base_crud_controller.dart';
import '../core/services/api_service.dart';

class PriceSegmentController extends BaseCrudController<PriceSegmentModel> {
  @override
  String get endpoint => '/price_segments';

  @override
  PriceSegmentModel fromJson(Map<String, dynamic> json) =>
      PriceSegmentModel.fromJson(json);

  Future<PriceSegmentModel> getPriceSegment(int id) async {
    final res = await ApiService.dio.get('$endpoint/get/$id');
    return fromJson(res.data);
  }

  Future<void> createPriceSegment(Map<String, dynamic> data) async {
    await ApiService.dio.post('$endpoint/create', data: data);
    fetch(reset: true);
  }

  Future<void> updatePriceSegment(int id, Map<String, dynamic> data) async {
    await ApiService.dio.put('$endpoint/update/$id', data: data);
    fetch(reset: true);
  }

  Future<void> deletePriceSegment(int id) async {
    await ApiService.dio.delete('$endpoint/delete/$id');
    fetch(reset: true);
  }
}
