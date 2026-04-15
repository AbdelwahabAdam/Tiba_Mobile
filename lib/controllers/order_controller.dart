import '../models/order_model.dart';
import 'base_crud_controller.dart';
import '../core/services/api_service.dart';

class OrderController extends BaseCrudController<OrderModel> {
  @override
  String get endpoint => '/orders';

  @override
  OrderModel fromJson(Map<String, dynamic> json) => OrderModel.fromJson(json);

  Future<OrderModel> getOrder(int id) async {
    final res = await ApiService.dio.get('$endpoint/get/$id');
    return fromJson(res.data);
  }

  Future<void> updateOrder(int id, Map<String, dynamic> data) async {
    await ApiService.dio.put('$endpoint/update/$id', data: data);
    fetch(reset: true);
  }

  Future<void> updateOrderItem(
    int orderId,
    int itemId,
    Map<String, dynamic> data,
  ) async {
    await ApiService.dio.put('$endpoint/$orderId/items/$itemId', data: data);
    fetch(reset: true);
  }

  Future<void> deleteOrder(int id) async {
    await ApiService.dio.delete('$endpoint/delete/$id');
    fetch(reset: true);
  }
}
