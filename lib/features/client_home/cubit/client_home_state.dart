
import 'package:marketplace_app/core/models/category_model.dart';
import 'package:marketplace_app/core/models/product_model.dart';

sealed class ClientHomeState {}

final class ClientHomeInitial extends ClientHomeState {}
final class ClientHomeLoading extends ClientHomeState {}
final class ClientHomeLoaded extends ClientHomeState {
  final List<CategoryModel> categories;
  final List<ProductModel> allProducts;
  final List<ProductModel> displayedProducts;
  final String? selectedCategoryId;

  ClientHomeLoaded({required this.categories, required this.allProducts, required this.displayedProducts, this.selectedCategoryId});


}

final class ClientHomeError extends ClientHomeState {
  final String message ;
  ClientHomeError(this.message);

}