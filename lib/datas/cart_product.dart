import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportscbr/blocs/product_bloc.dart';

class CartProduct {
  late String cid;
  late String category;
  late String pid;
  late int quantity;
  late String sizes;

  late ProductData productData;

  CartProduct(sizes);

  CartProduct.fromDocument(DocumentSnapshot document) {
    cid = document.id;
    category = document.get('category');
    pid = document.get('pid');
    quantity = document.get('quantity');
    sizes = document.get('sizes');
  }

  Map<String, dynamic> toMap() {
    return {
      "category": category,
      "pid": pid,
      "quantity": quantity,
      "sizes": sizes,
      "product": productData.toResumeMap()
    };
  }
}
