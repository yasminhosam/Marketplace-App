import 'package:marketplace_app/core/models/order_model.dart';

abstract class CustomerOrdersState {}

class CustomerOrdersInitial
    extends CustomerOrdersState {}

class CustomerOrdersLoading
    extends CustomerOrdersState {}

class CustomerOrdersLoaded
    extends CustomerOrdersState {
  final List<OrderModel> orders;

  CustomerOrdersLoaded(this.orders);
}

class CustomerOrdersError
    extends CustomerOrdersState {
  final String errorMessage;

  CustomerOrdersError(
    this.errorMessage,
  );
}
