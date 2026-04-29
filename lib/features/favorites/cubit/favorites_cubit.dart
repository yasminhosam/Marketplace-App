import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marketplace_app/core/models/product_model.dart';
import 'package:marketplace_app/features/favorites/cubit/favorites_state.dart';
import 'package:marketplace_app/core/services/favorites_service.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesService _favoritesService;

  FavoritesCubit({required FavoritesService favoritesService})
    : _favoritesService = favoritesService,
      super(FavoritesInitial());

  Future<void> loadFavorites() async {
    emit(FavoritesLoading());
    try {
      final favorites = await _favoritesService.getFavoriteProducts();
      emit(FavoritesLoaded(favoriteProducts: favorites));
    } catch (e) {
      emit(FavoritesError("Failed to load favorites: $e"));
    }
  }

  Future<void> removeFavorite(String productId) async {
    final currentState = state;
    if (currentState is FavoritesLoaded) {
      try {
        await _favoritesService.removeFavorite(productId);

        final updatedList = currentState.favoriteProducts
            .where((product) => product.id != productId)
            .toList();

        emit(FavoritesLoaded(favoriteProducts: updatedList));
      } catch (e) {
        emit(FavoritesError("Failed to remove item: $e"));
      }
    }
  }

  Future<void> toggleFavorite(ProductModel product) async {
    final currentState = state;
    if (currentState is FavoritesLoaded) {
      final isFavorite = currentState.favoriteProducts.any(
        (p) => p.id == product.id,
      );

      try {
        if (isFavorite) {
          await _favoritesService.removeFavorite(product.id);
          final updatedList = currentState.favoriteProducts
              .where((p) => p.id != product.id)
              .toList();
          emit(FavoritesLoaded(favoriteProducts: updatedList));
        } else {
          await _favoritesService.addFavorite(product);
          final updatedList = List<ProductModel>.from(
            currentState.favoriteProducts,
          )..add(product);
          emit(FavoritesLoaded(favoriteProducts: updatedList));
        }
      } catch (e) {
        emit(FavoritesError("Failed to update favorites: $e"));
      }
    }
  }

  bool isProductFavorite(String productId) {
    if (state is FavoritesLoaded) {
      return (state as FavoritesLoaded).favoriteProducts.any(
        (p) => p.id == productId,
      );
    }
    return false;
  }
}
