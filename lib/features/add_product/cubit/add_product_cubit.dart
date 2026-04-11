import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marketplace_app/core/models/product_model.dart';
import 'package:marketplace_app/core/services/product_service.dart';
import 'package:marketplace_app/core/services/image_service.dart';
import 'package:marketplace_app/features/add_product/cubit/add_product_state.dart';

class AddProductCubit extends Cubit<AddProductState> {
  final ProductService _productService;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final CloudinaryService _cloudinaryService;

  AddProductCubit(this._productService, this._cloudinaryService) : super(AddProductInitial());

  Future<void> saveProduct({
    required String name,
    required String category,
    required double price,
    required int quantity,
    required String description,
    required File? imageFile
  }) async {
    emit(AddProductLoading());
    final vendorId = _firebaseAuth.currentUser?.uid;
    try {
      String finalImageUrl ='';
      if(imageFile !=null){
        final uploadedUrl = await _cloudinaryService.uploadImageToCloudinary(imageFile);
        if (uploadedUrl == null) {
          emit(AddProductFailure('Failed to upload image. Please check your connection.'));
          return;
        }

        finalImageUrl = uploadedUrl;
      }
      if (vendorId != null) {
        final newProduct = ProductModel(
          id: '',
          vendorId: vendorId,
          name: name,
          category: category,
          imageUrl: finalImageUrl,
          price: price,
          quantity: quantity,
          description: description,
        );

        await _productService.createProduct(newProduct);
        emit(AddProductSuccess());
      }

    } catch (e) {
      emit(AddProductFailure(e.toString()));
    }
  }
}
