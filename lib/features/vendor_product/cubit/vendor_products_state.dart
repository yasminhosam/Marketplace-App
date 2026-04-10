
import 'package:marketplace_app/core/models/product_model.dart';


sealed class VendorProductsState {}
final class VendorProductsLoading extends VendorProductsState{}
final class VendorProductsLoaded extends VendorProductsState {
  final List<ProductModel> products;

  VendorProductsLoaded(this.products);

}
final class VendorProductsError extends VendorProductsState{
  final String message;
  VendorProductsError(this.message);
}
