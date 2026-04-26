
import 'package:marketplace_app/core/models/category_model.dart';
import 'package:marketplace_app/core/models/product_model.dart';


sealed class VendorProductsState {}
final class VendorProductsLoading extends VendorProductsState{}
final class VendorProductsLoaded extends VendorProductsState {
  final List<ProductModel> products;
  final List<CategoryModel> categories;
  VendorProductsLoaded(this.products,  this.categories);

}
final class VendorProductsError extends VendorProductsState{
  final String message;
  VendorProductsError(this.message);
}
