import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marketplace_app/core/models/product_model.dart';
import 'package:marketplace_app/core/services/category_service.dart';
import 'package:marketplace_app/core/services/product_service.dart';
import 'package:marketplace_app/core/services/image_service.dart';
import 'package:marketplace_app/features/vendor_product/cubit/vendor_products_cubit.dart';
import 'package:marketplace_app/features/vendor_product/cubit/vendor_products_state.dart';
import 'package:marketplace_app/features/add_product/cubit/add_product_cubit.dart';

import '../../../core/models/category_model.dart';
import '../../add_product/ui/add_product_screen.dart';

class VendorProductsScreen extends StatefulWidget {
  const VendorProductsScreen({super.key});

  @override
  State<VendorProductsScreen> createState() => _VendorProductsScreenState();
}

class _VendorProductsScreenState extends State<VendorProductsScreen> {
  final Color bgColor = const Color(0xFF101622);
  final Color primaryBlue = const Color(0xff135EF3);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
      VendorProductsCubit(ProductService(), CategoryService())
        ..fetchVendorProducts(),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          title: const Text(
            'My Products',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<VendorProductsCubit, VendorProductsState>(
          builder: (context, state) {
            if (state is VendorProductsLoading) {
              return Center(child: CircularProgressIndicator(color: primaryBlue));
            } else if (state is VendorProductsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            } else if (state is VendorProductsLoaded) {
              if (state.products.isEmpty) {
                return const Center(
                  child: Text(
                    'No products found.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.72,
                ),
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(
                    context,
                    state.products[index],
                    state.categories,
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(
      BuildContext context, ProductModel product, List<CategoryModel> categories) {
    String categoryName = "Unknown Category";
    try {
      final matchedCategory =
      categories.firstWhere((cat) => cat.id == product.categoryId);
      categoryName = matchedCategory.name;
    } catch (_) {}

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff101D36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Stack(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (innerContext) => BlocProvider(
                    create: (context) => AddProductCubit(
                      ProductService(),
                      CloudinaryService(),
                      CategoryService(),
                    ),
                    child: AddProductScreen(product: product),
                  ),
                ),
              ).then((_) {
                if (context.mounted) {
                  context.read<VendorProductsCubit>().fetchVendorProducts();
                }
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: product.imageUrl.isNotEmpty
                        ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                    )
                        : const Center(child: Icon(Icons.image, color: Colors.grey, size: 40)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        categoryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _showDeleteDialog(context, product),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.85),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4),
                  ],
                ),
                child: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _showDeleteDialog(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E212B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Product?', style: TextStyle(color: Colors.white, fontSize: 18)),
        content: Text(
          'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              context.read<VendorProductsCubit>().deleteProduct(product.id);
              Navigator.pop(dialogContext);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deleting product...'), duration: Duration(seconds: 1)),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}