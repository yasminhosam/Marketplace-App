import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marketplace_app/core/models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createProduct(ProductModel product) async{
    try{
      final productRef=_firestore.collection('products').doc();

      final productMap=product.toMap();
      productMap['id']=productRef.id;

      await productRef.set(productMap);
    }catch(e){
      throw Exception('Failed to add product: ${e.toString()}');
    }
  }

  Future<List<ProductModel>> getVendorProducts ( String vendorId)async{
    try {
      final snapshot = await _firestore.collection('products')
          .where('vendorId',isEqualTo: vendorId).get();
      final List<ProductModel> productList= snapshot.docs.map((doc){
        final data = doc.data();
        return ProductModel.fromMap(data,doc.id);
      }).toList();

      return productList;

    }catch (e) {

      throw Exception('Failed to load vendor products: $e');
    }
  }

}