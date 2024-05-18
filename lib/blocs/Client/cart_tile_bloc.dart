import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sportscbr/datas/product_data.dart';

class CartTileBloc {
  final _productController = BehaviorSubject<ProductData?>();

  Stream<ProductData?> get productStream => _productController.stream;

  Future<void> loadProduct(String category, String pid) async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('products').doc(category).collection('camisas').doc(pid).get();

      if (snapshot.exists) {
        final productData = ProductData.fromDocument(snapshot);
        _productController.add(productData);
      } else {
        _productController.add(null);
      }
    } catch (e) {
      _productController.addError(e);
    }
  }

  void dispose() {
    _productController.close();
  }
}
