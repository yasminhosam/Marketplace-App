import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marketplace_app/core/models/product_model.dart';
import 'package:marketplace_app/core/services/category_service.dart';
import 'package:marketplace_app/core/services/product_service.dart';
import 'package:marketplace_app/core/theme/app_colors.dart';
import 'package:marketplace_app/features/client_home/cubit/client_home_cubit.dart';
import 'package:marketplace_app/features/client_home/cubit/client_home_state.dart';
import 'package:marketplace_app/features/favorites/cubit/favorites_cubit.dart';
import 'package:marketplace_app/features/favorites/cubit/favorites_state.dart';

import 'package:marketplace_app/core/services/auth_service.dart';
import 'package:marketplace_app/core/models/user_model.dart';
import 'package:marketplace_app/features/client_home/ui/client_profile_screen.dart';
import 'package:marketplace_app/features/client_home/ui/product_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

// تأكد من تعديل هذا المسار ليتطابق مع مكان ملف AppRouter عندك
import 'package:marketplace_app/core/routing/app_router.dart';

import '../../cart/main_cart/ui/main_cart_ui.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _selectedIndex = 0;
  UserModel? _currentUser;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userModel = await AuthService().getUser(user.uid);
        if (mounted) {
          setState(() {
            _currentUser = userModel;
            _isLoadingUser = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClientHomeCubit(
        productService: ProductService(),
        categoryService: CategoryService(),
      )..loadHomeData(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _selectedIndex == 0 ? AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 70,
          title: Row(
            children: [
              Expanded(child: _buildSearchBar()),
              const SizedBox(width: 12),
              Container(
                  decoration: const BoxDecoration(
                    color: AppColors.inputFill,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainCart(),
                        ),
                      );
                    },
                  )
              ),
            ],
          ),
        ) : null,
        body: _buildBody(),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFF13161E),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF1A65FF),
          unselectedItemColor: Colors.grey.shade600,
          showUnselectedLabels: true,
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 1) {
              Navigator.pushNamed(context, AppRouter.clientFavorite).then((_) {
                setState(() {
                  _selectedIndex = 0;
                });
              });
            } else if (index == 2) {
              Navigator.pushNamed(context, AppRouter.clientOrders).then((_) {
                setState(() {
                  _selectedIndex = 0;
                });
              });
            } else {
              setState(() {
                _selectedIndex = index;
              });
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 3) {
      if (_isLoadingUser) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_currentUser == null) {
        return const Center(child: Text("User not found", style: TextStyle(color: Colors.white)));
      }
      return ClientProfileScreen(user: _currentUser!);
    }

    return BlocBuilder<ClientHomeCubit, ClientHomeState>(
      builder: (context, state) {
        if (state is ClientHomeInitial || state is ClientHomeLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ClientHomeError) {
          return Center(
            child: Text(state.message, style: const TextStyle(color: Colors.red)),
          );
        } else if (state is ClientHomeLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildCategoryList(context, state),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Recent Listings",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildProductGrid(state.displayedProducts),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF1E212B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search Tijara products...",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, ClientHomeLoaded state) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = state.selectedCategoryId == null;
            return _buildChip(
              title: "All",
              isSelected: isSelected,
              onTap: () {
                context.read<ClientHomeCubit>().selectedCategory(null);
              },
            );
          }

          final category = state.categories[index - 1];
          final isSelected = state.selectedCategoryId == category.id;

          return _buildChip(
            title: category.name,
            isSelected: isSelected,
            onTap: () {
              context.read<ClientHomeCubit>().selectedCategory(category.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildChip({required String title, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A65FF) : const Color(0xFF1E212B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A65FF) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade400,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(List<ProductModel> products) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade700),
            const SizedBox(height: 16),
            const Text("No items found in this category.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return GestureDetector(
      onTap: () {
        if (_currentUser != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(
                product: product,
                user: _currentUser!,
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E212B),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: product.imageUrl.isNotEmpty
                        ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                    )
                        : _buildPlaceholderImage(),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,

                    child: BlocBuilder<FavoritesCubit, FavoritesState>(
                      builder: (context, state) {
                        final isFavorite = context.read<FavoritesCubit>().isProductFavorite(product.id);

                        return GestureDetector(
                          onTap: () {

                            context.read<FavoritesCubit>().toggleFavorite(product);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.redAccent : Colors.white,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${product.price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Color(0xFF1A65FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (product.quantity == 1)
                        const Text(
                          "1 left",
                          style: TextStyle(color: Colors.orangeAccent, fontSize: 10),
                        ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: const Color(0xFF2C2C3E),
      child: Center(
        child: Icon(Icons.image_outlined, color: Colors.grey.shade600, size: 40),
      ),
    );
  }
}