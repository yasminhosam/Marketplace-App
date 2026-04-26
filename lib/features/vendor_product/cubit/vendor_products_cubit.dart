import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marketplace_app/core/services/product_service.dart';
import 'package:marketplace_app/features/vendor_product/cubit/vendor_products_state.dart';
import '../../../core/models/product_model.dart';
import '../../../core/services/category_service.dart';

class VendorProductsCubit extends Cubit<VendorProductsState>{
  final ProductService _productService;
  final CategoryService _categoryService;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  StreamSubscription? _productsSubscription;

  VendorProductsCubit(this._productService,this._categoryService)
      : super(VendorProductsLoading());

  Future<void> fetchVendorProducts() async {
    emit(VendorProductsLoading());
    final vendorId = _firebaseAuth.currentUser?.uid;
    
    if(vendorId == null) {
      emit(VendorProductsError("User not logged in"));
      return;
    }
    try {
      final categories = await _categoryService.getAllCategories();
      _productsSubscription?.cancel();
      _productsSubscription =
          _productService.getVendorProductsStream(vendorId).listen(
                  (products) {
                emit(VendorProductsLoaded(products,categories));
              },
              onError: (e) {
                emit(VendorProductsError(e.toString()));
              }
          );
    }catch (e){
      emit(VendorProductsError("Failed to load data: $e"));
    }
  }

  @override
  Future<void> close() {
    _productsSubscription?.cancel();
    return super.close();
  }


}
