
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketplace_app/core/models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CategoryModel>> getAllCategories () async{
    try{
      final snapshot =await _firestore.collection("categories").orderBy('priority').get();
      final List<CategoryModel> categoryList = snapshot.docs.map((doc){
        return CategoryModel.fromMap(doc.data(), doc.id);
      }).toList();
      return categoryList;
    }catch(e){
      throw Exception("Failed to load categories: $e");
    }
  }

}