import 'package:marketplace_app/core/models/product_model.dart';

sealed class FavoritesState {}

final class FavoritesInitial extends FavoritesState {}

final class FavoritesLoading extends FavoritesState {}

final class FavoritesLoaded extends FavoritesState {
  final List<ProductModel> favoriteProducts;
  FavoritesLoaded({required this.favoriteProducts});
}

final class FavoritesError extends FavoritesState {
  final String message;
  FavoritesError(this.message);
}
