import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportscbr/datas/product_data.dart';

class CartProduct {
  late String cid;
  late String category;
  late String pid;
  late int quantity;
  late String sizes;

  ProductData? productData;

  CartProduct(this.sizes, this.category, this.pid, this.quantity);

  CartProduct.fromDocument(DocumentSnapshot document) {
    document.id;
    document['category'];
    document['pid'];
    document['quantity'];
    document['sizes'];
  }

  Map<String, dynamic> toMap() {
    return {
      "category": category,
      "pid": pid,
      "quantity": quantity,
      "sizes": sizes,
      "product": productData?.toResumeMap()
    };
  }
}
