import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketplace_app/core/models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createProduct(ProductModel product) async{
    try{
      final productRef=_firestore.collection('products').doc();

      final productMap=product.toMap();
      productMap['id']=productRef.id;
      // Add createdAt for stats calculation
      productMap['createdAt'] = FieldValue.serverTimestamp();

      await productRef.set(productMap);
    }catch(e){
      throw Exception('Failed to add product: ${e.toString()}');
    }
  }
  

  Stream<List<ProductModel>> getVendorProductsStream(String vendorId) {
    return _firestore.collection('products')
        .where('vendorId', isEqualTo: vendorId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
  Stream<List<ProductModel>>  getAllProducts(){
   
      return _firestore.collection("products")
      .orderBy('createdAt',descending: true)
          .snapshots()
          .map((snapshot){
            return snapshot.docs.map((doc) {
              return ProductModel.fromMap(doc.data(), doc.id);
            }).toList();
      });
      
  } 
}
