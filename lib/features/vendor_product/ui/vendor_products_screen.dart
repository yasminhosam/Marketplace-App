import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marketplace_app/core/models/product_model.dart';
import 'package:marketplace_app/features/vendor_product/cubit/vendor_products_cubit.dart';
import 'package:marketplace_app/features/vendor_product/cubit/vendor_products_state.dart';

class VendorProductsScreen extends StatefulWidget {
  const VendorProductsScreen({super.key});

  @override
  State<VendorProductsScreen> createState() => _VendorProductsScreenState();
}

class _VendorProductsScreenState extends State<VendorProductsScreen> {
  final Color bgColor = const Color(0xFF13161E);
  final Color cardColor = const Color(0xFF1E212B);

  @override
  void initState() {
    super.initState();
    //context.read<VendorProductsCubit>().fetchVendorProducts();
    context.read<VendorProductsCubit>().loadDummyProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Products',
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
          switch (state) {
            case VendorProductsLoading():
              return const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              );

            case VendorProductsError(:final message):
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Error: $message',
                    style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              );

            case VendorProductsLoaded(:final products):
              if (products.isEmpty) {
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
                  childAspectRatio: 0.75,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(products[index]);
                },
              );
          }
        },
      ),
    );
  }


  Widget _buildProductCard(ProductModel product) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  // Fallback if the network image fails to load
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                    size: 40,
                  ),
                )
                    : const Icon(
                  Icons.image,
                  color: Colors.grey,
                  size: 40,
                ),
              ),
            ),
          ),


          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}