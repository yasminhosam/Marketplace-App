import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marketplace_app/core/services/product_service.dart';
import 'package:marketplace_app/features/vendor_product/cubit/vendor_products_state.dart';
import '../../../core/models/product_model.dart';

class VendorProductsCubit extends Cubit<VendorProductsState>{
  final ProductService _productService;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  StreamSubscription? _productsSubscription;

  VendorProductsCubit(this._productService): super(VendorProductsLoading());

  void fetchVendorProducts() {
    emit(VendorProductsLoading());
    final vendorId = _firebaseAuth.currentUser?.uid;
    
    if(vendorId == null) {
      emit(VendorProductsError("User not logged in"));
      return;
    }

    _productsSubscription?.cancel();
    _productsSubscription = _productService.getVendorProductsStream(vendorId).listen(
      (products) {
        emit(VendorProductsLoaded(products));
      },
      onError: (e) {
        emit(VendorProductsError(e.toString()));
      }
    );
  }

  @override
  Future<void> close() {
    _productsSubscription?.cancel();
    return super.close();
  }

  // We keep this just in case, though we prefer the real data stream
  void loadDummyProducts() {
    final dummies = [
      ProductModel(
        id: '1',
        vendorId: 'dummy',
        name: 'Vintage Denim Jacket',
        category: 'Clothing',
        price: 49.99,
        quantity: 10,
        description: 'A classic blue denim jacket in great condition.',
        imageUrl: 'https://picsum.photos/seed/jacket/300/300',
      ),
      ProductModel(
        id: '2',
        vendorId: 'dummy',
        name: 'Leather Sneakers',
        category: 'Shoes',
        price: 89.99,
        quantity: 5,
        description: 'Clean white leather sneakers, barely worn.',
        imageUrl: 'https://picsum.photos/seed/shoes/300/300',
      ),
    ];
    emit(VendorProductsLoaded(dummies));
  }
}
