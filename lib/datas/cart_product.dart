import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportscbr/datas/product_data.dart';

class CartProduct {
  String? cid;

  String? category;
  String? pid;

  int? quantity;
  String? sizes;

  ProductData? productData;

  CartProduct();

  CartProduct.fromDocument(DocumentSnapshot document) {
    cid = document.id;
    category = document.get('category');
    pid = document.get('pid');
    quantity = document.get('quantity');
    sizes = document.get('sizes');
  }

  //pega o objeto e tranforma em mapa para armazaenar no Firebase
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'pid': pid,
      'quantity': quantity,
      'sizes': sizes,
      'product': productData!.toResumeMap() //guarda apenas o resumo dos produtos adicionados
    };
  }
}
