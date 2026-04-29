import '../../../../core/models/cart_model.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItemModel> items;

  CartLoaded(this.items);

  double get subtotal =>
      items.fold(0, (s, e) => s + e.price * e.selectedQuantity);

  double get deliveryFee => items.isEmpty ? 0 : 25;

  double get total => subtotal + deliveryFee;
}

class CartError extends CartState {
  final String message;
  CartError(this.message);
}