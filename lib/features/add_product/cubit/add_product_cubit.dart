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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService;
  final CategoryService _categoryService;

  List<CategoryModel> _cachedCategories = [];
  List<CategoryModel> get cachedCategories => _cachedCategories;

  AddProductCubit(this._productService, this._cloudinaryService, this._categoryService)
      : super(AddProductInitial());
  Future<void> saveProduct({
    required String name,
    required String categoryId,
    required double price,
    required int quantity,
    required String description,
    required File? imageFile,
  }) async {
    emit(AddProductLoading());
    final vendorId = _firebaseAuth.currentUser?.uid;

    if (vendorId == null) {
      emit(AddProductFailure('User session expired.'));
      return;
    }

    try {
      final userDoc = await _firestore.collection('users').doc(vendorId).get();
      final storeName = userDoc.data()?['name'] ?? 'My Store';

      String finalImageUrl = '';
      if (imageFile != null) {
        finalImageUrl = await _cloudinaryService.uploadImageToCloudinary(imageFile) ?? '';
      }
      final newProduct = ProductModel(
        id: '',
        vendorId: vendorId,
        storeName: storeName,
        name: name,
        categoryId: categoryId,
        imageUrl: finalImageUrl,
        price: price,
        quantity: quantity,
        description: description,
        createdAt: Timestamp.now(),
      );

      await _productService.createProduct(newProduct);
      emit(AddProductSuccess());
    } catch (e) {
      emit(AddProductFailure(e.toString()));
    }
  }
  Future<void> updateProduct({
    required String productId,
    required String name,
    required String categoryId,
    required double price,
    required int quantity,
    required String description,
    required File? imageFile,
    required String existingImageUrl,
    dynamic existingCreatedAt,
  }) async {
    if (price <= 0) {
      emit(AddProductFailure('Price must be greater than zero'));
      return;
    }

    emit(AddProductLoading());
    try {
      final vendorId = _firebaseAuth.currentUser!.uid;
      final userDoc = await _firestore.collection('users').doc(vendorId).get();
      final storeName = userDoc.data()?['name'] ?? 'My Store';

      String finalImageUrl = existingImageUrl;
      if (imageFile != null) {
        final uploadedUrl = await _cloudinaryService.uploadImageToCloudinary(imageFile);
        if (uploadedUrl != null) finalImageUrl = uploadedUrl;
      }

      final updatedProduct = ProductModel(
        id: productId,
        vendorId: vendorId,
        storeName: storeName,
        name: name,
        categoryId: categoryId,
        imageUrl: finalImageUrl,
        price: price,
        quantity: quantity,
        description: description,
        createdAt: existingCreatedAt ?? Timestamp.now(),
      );

      await _productService.updateProduct(updatedProduct);
      emit(AddProductSuccess());
    } catch (e) {
      emit(AddProductFailure(e.toString()));
    }
  }

  Future<void> fetchCategories() async {
    if (_cachedCategories.isNotEmpty) {
      emit(AddProductCategoriesLoaded(_cachedCategories));
      return;
    }
    emit(AddProductCategoriesLoading());
    try {
      _cachedCategories = await _categoryService.getAllCategories();
      emit(AddProductCategoriesLoaded(_cachedCategories));
    } catch (e) {
      emit(AddProductCategoriesFailure(e.toString()));
    }
  }
}