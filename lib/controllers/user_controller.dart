import 'package:get/get.dart';
import '../models/user_model.dart';
import '../models/user_segment_model.dart';
import 'base_crud_controller.dart';
import '../core/services/api_service.dart';

class UserController extends BaseCrudController<UserModel> {
  @override
  String get endpoint => '/users';

  final segments = <UserSegmentModel>[].obs;
  final segmentsLoaded = false.obs;

  @override
  UserModel fromJson(Map<String, dynamic> json) => UserModel.fromJson(json);

  /// Load user segments ONCE
  Future<void> loadSegments() async {
    if (segmentsLoaded.value) return;

    final res = await ApiService.dio.get(
      '/user_segments',
      queryParameters: {'limit': 1000},
    );

    segments.assignAll(
      (res.data['items'] as List)
          .map((e) => UserSegmentModel.fromJson(e))
          .toList(),
    );

    segmentsLoaded.value = true;
  }

  void onSearchChanged(String value) => updateSearch(value);

  String segmentName(int? id) {
    if (id == null) return '-';

    return segments.firstWhereOrNull((s) => s.id == id)?.name ?? '-';
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    await ApiService.dio.put('$endpoint/update/$id', data: data);
    fetch(reset: true);
  }

  Future<void> deleteUser(int id) async {
    await ApiService.dio.delete('$endpoint/delete/$id');
    fetch(reset: true);
  }
}
