import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marketplace_app/core/models/product_model.dart';
import 'package:marketplace_app/features/favorites/cubit/favorites_cubit.dart';
import 'package:marketplace_app/features/favorites/cubit/favorites_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  // الألوان المطلوبة في التصميم
  static const Color bgColor = Color(0xFF0D1117);
  static const Color cardColor = Color(0xFF141D2B);
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color secondaryText = Color(0xFF8B9CB6);
  static const Color hintText = Color(0xFF4A6080);
  static const Color dividerColor = Color(0xFF1E2A3A);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<FavoritesCubit>()..loadFavorites(),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Row(
            children: [
              Icon(Icons.favorite, color: primaryBlue, size: 24),
              SizedBox(width: 8),
              Text(
                "Favorites",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        body: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            if (state is FavoritesLoading) {
              return const Center(
                child: CircularProgressIndicator(color: primaryBlue),
              );
            } else if (state is FavoritesError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              );
            } else if (state is FavoritesLoaded) {
              if (state.favoriteProducts.isEmpty) {
                return _buildEmptyState();
              }
              return _buildFavoritesList(state.favoriteProducts);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.heart_broken_outlined, size: 80, color: secondaryText),
            SizedBox(height: 24),
            Text(
              "Your favorites list is empty",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "Looks like you haven't added any products yet.\nExplore our products and add your favorites!",
              textAlign: TextAlign.center,
              style: TextStyle(color: hintText, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList(List<ProductModel> products) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      separatorBuilder: (context, index) =>
          const Divider(color: dividerColor, height: 32, thickness: 1),
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildFavoriteCard(context, product);
      },
    );
  }

  Widget _buildFavoriteCard(BuildContext context, ProductModel product) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // صورة المنتج
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: bgColor,
              child: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_outlined, color: hintText),
                    )
                  : const Icon(Icons.image_outlined, color: hintText),
            ),
          ),
          const SizedBox(width: 16),

          // تفاصيل المنتج
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Text(
                  "\$${product.price.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  context.read<FavoritesCubit>().removeFavorite(product.id);
                },
                icon: const Icon(Icons.favorite, color: primaryBlue),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 16),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: primaryBlue,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
