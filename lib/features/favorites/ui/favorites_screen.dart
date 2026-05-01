import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marketplace_app/core/models/product_model.dart';
import 'package:marketplace_app/features/favorites/cubit/favorites_cubit.dart';
import 'package:marketplace_app/features/favorites/cubit/favorites_state.dart';
import 'package:marketplace_app/core/theme/app_colors.dart';

import '../../../core/services/cart_service.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<FavoritesCubit>()..loadFavorites(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Row(
            children: [
              Icon(Icons.favorite, color: AppColors.primaryBlue, size: 24),
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
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
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
            Icon(
              Icons.heart_broken_outlined,
              size: 80,
              color: AppColors.secondaryText,
            ),
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
              style: TextStyle(
                color: AppColors.hintText,
                fontSize: 14,
                height: 1.5,
              ),
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
          const Divider(color: AppColors.divider, height: 32, thickness: 1),
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildFavoriteCard(context, product);
      },
    );
  }

  Widget _buildFavoriteCard(BuildContext context, ProductModel product) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: AppColors.background,
              child: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_outlined,
                        color: AppColors.hintText,
                      ),
                    )
                  : const Icon(Icons.image_outlined, color: AppColors.hintText),
            ),
          ),
          const SizedBox(width: 16),

          // Product Details
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
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  context.read<FavoritesCubit>().removeFavorite(product.id);
                },
                icon: const Icon(Icons.favorite, color: Colors.redAccent),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 16),
              CartToggleButton(product: product),
            ],
          ),
        ],
      ),
    );
  }
}

class CartToggleButton extends StatefulWidget {
  final ProductModel product;

  const CartToggleButton({super.key, required this.product});

  @override
  State<CartToggleButton> createState() => _CartToggleButtonState();
}

class _CartToggleButtonState extends State<CartToggleButton> {
  bool _isInCart = false; // Starts as false by default
  @override
  void initState() {
    super.initState();
    _checkCartStatus();
  }

  Future<void> _checkCartStatus() async {
    final clientId = FirebaseAuth.instance.currentUser?.uid;
    if (clientId != null) {
      final inCart = await CartService().isProductInCart(
        clientId: clientId,
        productId: widget.product.id,
      );
      if (mounted && inCart) {
        setState(() {
          _isInCart = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isInCart ? Icons.shopping_cart : Icons.add_shopping_cart,
        color: _isInCart ? Colors.greenAccent : AppColors.primaryBlue,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onPressed: () {
        setState(() {
          _isInCart = !_isInCart;
        });

        final clientId = FirebaseAuth.instance.currentUser?.uid;
        if (clientId != null) {
          if (_isInCart) {
            CartService().addToCart(
              clientId: clientId,
              product: widget.product,
              quantity: 1,
            );
          } else {
            CartService().removeFromCart(
              clientId: clientId,
              productId: widget.product.id,
            );
          }
        }
      },
    );
  }
}
