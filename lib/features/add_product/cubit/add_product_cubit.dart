import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marketplace_app/core/models/category_model.dart';
import 'package:marketplace_app/core/models/product_model.dart';
import 'package:marketplace_app/core/services/category_service.dart';
import 'package:marketplace_app/core/services/product_service.dart';
import 'package:marketplace_app/core/services/image_service.dart';
import 'package:marketplace_app/features/add_product/cubit/add_product_state.dart';

class AddProductCubit extends Cubit<AddProductState> {
  final ProductService _productService;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final CloudinaryService _cloudinaryService;
  final CategoryService _categoryService;

  List<CategoryModel> _cachedCategories =[];
  List<CategoryModel> get cachedCategories => _cachedCategories;

  AddProductCubit(
      this._productService,
      this._cloudinaryService,
      this._categoryService
      ) : super(AddProductInitial());

  Future<void> saveProduct({
    required String name,
    required String categoryId,
    required double price,
    required int quantity,
    required String description,
    required File? imageFile
  }) async {
    emit(AddProductLoading());
    final vendorId = _firebaseAuth.currentUser?.uid;

    try {
      String storeName ="Unknown Store";
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users')
      .doc(vendorId).get();
      if (userDoc.exists) {
        storeName = userDoc.data().toString().contains('storeName')
            ? userDoc.get('storeName') ?? "Unknown Store"
            : "Unknown Store";
      }
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
          storeName: storeName ,
          name: name,
          categoryId: categoryId,
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

  Future<void> fetchCategories() async{
    if (_cachedCategories.isNotEmpty) {
      emit(AddProductCategoriesLoaded(_cachedCategories));
      return;
    }

    emit(AddProductCategoriesLoading());
    try{
      _cachedCategories = await _categoryService.getAllCategories();
      emit(AddProductCategoriesLoaded(_cachedCategories));
    }catch(e){
      emit(AddProductCategoriesFailure("Failed to load categories: ${e.toString()}"));
    }
  }
}
