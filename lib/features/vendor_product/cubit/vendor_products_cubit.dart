import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marketplace_app/core/services/product_service.dart';
import 'package:marketplace_app/features/vendor_product/cubit/vendor_products_state.dart';

import '../../../core/models/product_model.dart';

class VendorProductsCubit extends Cubit<VendorProductsState>{
  final ProductService _productService;
  final FirebaseAuth _firebaseAuth =FirebaseAuth.instance;
  VendorProductsCubit(this._productService): super(VendorProductsLoading());

  Future<void> fetchVendorProducts() async{
    emit(VendorProductsLoading());
    final vendorId=_firebaseAuth.currentUser?.uid;
    try{
      if(vendorId !=null){
        final products = await _productService.getVendorProducts(vendorId);
        emit(VendorProductsLoaded(products));

      }
    }catch(e){
      emit(VendorProductsError(e.toString()));
    }
  }
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
      ProductModel(
        id: '3',
        vendorId: 'dummy',
        name: 'Silk Scarf',
        category: 'Accessories',
        price: 24.99,
        quantity: 20,
        description: 'Beautiful floral print silk scarf.',
        imageUrl: 'https://picsum.photos/seed/scarf/300/300',
      ),
      ProductModel(
        id: '4',
        vendorId: 'dummy',
        name: 'Wool Sweater',
        category: 'Clothing',
        price: 39.99,
        quantity: 8,
        description: 'Warm merino wool sweater, navy blue.',
        imageUrl: 'https://picsum.photos/seed/sweater/300/300',
      ),
    ];
    emit(VendorProductsLoaded(dummies));
  }
}