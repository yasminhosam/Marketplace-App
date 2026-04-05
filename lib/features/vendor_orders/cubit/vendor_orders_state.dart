// استوردنا الموديل الحقيقي بتاع التيم
import 'package:marketplace_app/core/models/order_model.dart';

abstract class VendorOrdersState {}

class VendorOrdersInitial extends VendorOrdersState {}

class VendorOrdersLoading extends VendorOrdersState {}

class VendorOrdersLoaded extends VendorOrdersState {
  final List<OrderModel> orders; // غيرناها للموديل الحقيقي

  VendorOrdersLoaded(this.orders);
}

class VendorOrdersError extends VendorOrdersState {
  final String errorMessage;

  VendorOrdersError(this.errorMessage);
}
