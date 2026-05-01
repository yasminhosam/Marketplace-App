import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/models/cart_model.dart';
import '../cubit/main_cart_cubit.dart';

class ItemCard extends StatelessWidget {
  final CartItemModel item;
  final String clientId;

  const ItemCard({
    super.key,
    required this.item,
    required this.clientId,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CartCubit>();
    final width = MediaQuery.of(context).size.width;

    return Card(
      color: const Color(0xFF1E212B),
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 90,
                height: 90,
                color: const Color(0xFF1E212B),
                child: Image.network(
                  item.imageUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Sold by: ${item.storeName}",
                    style: const TextStyle(color: Color(0xFF1A65FF), fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "\$${item.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  onPressed: () => cubit.removeItem(clientId, item.productId),
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => cubit.updateQuantity(clientId, item.productId, false),
                        icon: const Icon(Icons.remove, color: Colors.white, size: 16),
                      ),
                      Text(
                        "${item.selectedQuantity}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => cubit.updateQuantity(clientId, item.productId, true),
                        icon: const Icon(Icons.add, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}