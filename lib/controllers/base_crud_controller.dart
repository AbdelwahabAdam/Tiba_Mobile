import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/config/api_config.dart';
import '../core/services/api_service.dart';
import '../core/utils/app_logger.dart';
import '../core/validators/input_validator.dart';

abstract class BaseCrudController<T> extends GetxController {
  final items = <T>[].obs;
  final page = 1.obs;
  final hasMore = true.obs;
  final loading = false.obs;
  final search = ''.obs;

  final _box = GetStorage();

  String get endpoint;
  T fromJson(Map<String, dynamic> json);

  String get cacheKey => 'cache_$endpoint';

  @override
  void onInit() {
    loadCache();
    fetch();
    super.onInit();
  }

  void loadCache() {
    if (search.value.isNotEmpty) return;

    final cached = _box.read(cacheKey);
    if (cached != null) {
      items.value = (cached as List)
          .map((e) => fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
  }

  Future<void> fetch({bool reset = false}) async {
    if (reset) {
      page.value = 1;
      hasMore.value = true;
      items.clear();
    }

    if (loading.value || !hasMore.value) return;

    loading.value = true;

    try {
      final res = await ApiService.dio.get(
        endpoint,
        queryParameters: {
          'page': page.value,
          'per_page': ApiConfig.defaultPageSize,
          'limit': ApiConfig.defaultPageSize,
          'q': search.value.isEmpty ? null : search.value,
        },
      );

      final data = _extractItems(res.data);
      final parsed = data
          .map((e) => Map<String, dynamic>.from(e as Map))
          .map(fromJson)
          .toList();

      if (page.value == 1 && search.value.isEmpty) {
        items.assignAll(parsed);
        _box.write(cacheKey, data);
      } else {
        items.addAll(parsed);
      }

      final totalPages = _extractTotalPages(res.data);
      hasMore.value = page.value < totalPages;
      if (hasMore.value) page.value++;
    } on DioException catch (e) {
      appLogger.e('Fetch failed for $endpoint', error: e);
      Get.snackbar('Error', 'Failed to load data');
    } catch (e) {
      appLogger.e('Unexpected error fetching $endpoint', error: e);
    } finally {
      loading.value = false;
    }
  }

  void updateSearch(String value) {
    search.value = InputValidator.sanitizeSearch(value);
    fetch(reset: true);
  }

  List<dynamic> _extractItems(dynamic body) {
    if (body is List) return body;
    if (body is! Map) return const [];

    final map = Map<String, dynamic>.from(body);
    final items = map['items'] ?? map['data'] ?? map['results'];
    if (items is List) return items;

    return const [];
  }

  int _extractTotalPages(dynamic body) {
    if (body is! Map) return 1;
    final map = Map<String, dynamic>.from(body);

    final totalPages = map['total_pages'] ?? map['totalPages'];
    if (totalPages is int) return totalPages;
    if (totalPages is String) return int.tryParse(totalPages) ?? 1;

    final pageSize = ApiConfig.defaultPageSize;
    final total = map['total'] ?? map['count'];
    if (total is int && total > 0 && pageSize > 0) {
      return (total / pageSize).ceil();
    }

    return 1;
  }
}
