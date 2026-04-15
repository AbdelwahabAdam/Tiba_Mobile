import '../models/user_segment_model.dart';
import 'base_crud_controller.dart';
import '../core/services/api_service.dart';

class UserSegmentController extends BaseCrudController<UserSegmentModel> {
  @override
  String get endpoint => '/user_segments';

  @override
  UserSegmentModel fromJson(Map<String, dynamic> json) =>
      UserSegmentModel.fromJson(json);

  Future<UserSegmentModel> getUserSegment(int id) async {
    final res = await ApiService.dio.get('$endpoint/get/$id');
    return fromJson(res.data);
  }

  Future<void> createUserSegment(Map<String, dynamic> data) async {
    await ApiService.dio.post('$endpoint/create', data: data);
    fetch(reset: true);
  }

  Future<void> updateUserSegment(int id, Map<String, dynamic> data) async {
    await ApiService.dio.put('$endpoint/update/$id', data: data);
    fetch(reset: true);
  }

  Future<void> deleteUserSegment(int id) async {
    await ApiService.dio.delete('$endpoint/delete/$id');
    fetch(reset: true);
  }
}
