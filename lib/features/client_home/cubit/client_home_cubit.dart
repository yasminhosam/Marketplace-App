import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marketplace_app/core/models/product_model.dart';
import 'package:marketplace_app/core/services/category_service.dart';
import 'package:marketplace_app/core/services/product_service.dart';
import 'package:marketplace_app/features/client_home/cubit/client_home_state.dart';

class ClientHomeCubit extends Cubit<ClientHomeState>{
  final ProductService _productService;
  final CategoryService _categoryService;

  StreamSubscription<List<ProductModel>>? _productsSubscription;
  ClientHomeCubit({
    required ProductService productService, 
    required CategoryService categoryService
  }) : _productService = productService, _categoryService = categoryService,super(ClientHomeInitial());

  Future<void> loadHomeData() async{
    emit(ClientHomeLoading());
    try{
      final categories = await _categoryService.getAllCategories();
      
      _productsSubscription?.cancel();
      _productsSubscription= _productService.getAllProducts().listen(
          (products){
            String? currentSelectedCategoryId;
            if(state is ClientHomeLoaded){
              currentSelectedCategoryId =( state as ClientHomeLoaded).selectedCategoryId;
            }
            List<ProductModel> displayed =products;
            if(currentSelectedCategoryId !=null){
              displayed=products.where((p)=> p.categoryId == currentSelectedCategoryId).toList();
            }
            emit(ClientHomeLoaded(categories: categories, allProducts: products, displayedProducts: displayed));
          },
        onError: (error){
            emit(ClientHomeError("Failed to load products: $error"));
        }
      );
    }catch(e){
      emit(ClientHomeError("Failed to load data: $e"));
    }
  }
  void selectedCategory(String? categoryId){
    final currentState = state;
    if(currentState is ClientHomeLoaded){
      List<ProductModel> filteredList;
      if(categoryId == null){
        filteredList=currentState.allProducts;
      }else{
        filteredList=currentState.allProducts
            .where((product)=> product.categoryId == categoryId)
            .toList();
      }
      emit(ClientHomeLoaded(
        categories: currentState.categories,
        allProducts: currentState.allProducts,
        displayedProducts: filteredList,
        selectedCategoryId: categoryId,
      ));

    }
    
  }
  @override
  Future<void> close() {
    _productsSubscription?.cancel();
    return super.close();
  }
}