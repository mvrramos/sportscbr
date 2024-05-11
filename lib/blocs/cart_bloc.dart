import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportscbr/datas/cart_product.dart';
import 'package:sportscbr/models/user_model.dart';

class CartBloc extends BlocBase {
  UserModel user;
  List<CartProduct> products = [];
  String couponCode = "";
  int discountPercentage = 0;
  bool isLoading = false;

  final _cartController = StreamController<List<CartProduct>>.broadcast();
  Stream<List<CartProduct>> get cartStream => _cartController.stream;

  final _isLoadingController = StreamController<bool>.broadcast();
  Stream<bool> get isLoadingStream => _isLoadingController.stream;

  CartBloc(this.user) {
    if (user.isLoggedIn()) {
      _loadCartItems();
    }
  }

  void addCartItem(CartProduct cartProduct) {
    products.add(cartProduct);
    FirebaseFirestore.instance.collection('users').doc(user.firebaseUser?.uid).collection('cart').add(cartProduct.toMap()).then((doc) {
      cartProduct.cid = doc.id;
      _cartController.sink.add(products); // Emitir os produtos atualizados
    });
  }

  void removeCartItem(CartProduct cartProduct) {
    FirebaseFirestore.instance.collection('users').doc(user.firebaseUser!.uid).collection('cart').doc(cartProduct.cid).delete().then((value) {
      products.remove(cartProduct);
      _cartController.sink.add(products); // Emitir os produtos atualizados
    });
  }

  void decProduct(CartProduct cartProduct) {
    cartProduct.quantity--;

    FirebaseFirestore.instance.collection('users').doc(user.firebaseUser!.uid).collection('cart').doc(cartProduct.cid).update(cartProduct.toMap()).then((value) {
      _cartController.sink.add(products); // Emitir os produtos atualizados
    });
  }

  void incProduct(CartProduct cartProduct) {
    cartProduct.quantity++;

    FirebaseFirestore.instance.collection('users').doc(user.firebaseUser!.uid).collection('cart').doc(cartProduct.cid).update(cartProduct.toMap()).then((value) {
      _cartController.sink.add(products); // Emitir os produtos atualizados
    });
  }

  void setCoupon(String couponCode, int discountPercentage) {
    this.couponCode = couponCode;
    this.discountPercentage = discountPercentage;
    updatePrices();
  }

  void updatePrices() {
    _cartController.sink.add(products); // Emitir os produtos atualizados
  }

  double getProductsPrice() {
    double price = 0.0;
    for (CartProduct c in products) {
      price += c.quantity * c.productData.price;
    }
    return price;
  }

  double getDiscountPrice() {
    return getProductsPrice() * discountPercentage / 100;
  }

  double getShipPrice() {
    return 14.99;
  }

  Future<String?> finishOrder() async {
    if (products.isEmpty) {
      return null;
    }

    isLoading = true;
    _isLoadingController.sink.add(true); // Emitir que está carregando

    double productPrice = getProductsPrice();
    double shipPrice = getShipPrice();
    double discount = getDiscountPrice();

    DocumentReference refOrder = await FirebaseFirestore.instance.collection('orders').add({
      "clientId": user.firebaseUser!.uid,
      "products": products.map((cartProduct) => cartProduct.toMap()).toList(),
      "shipPrice": shipPrice,
      "productsPrice": productPrice,
      "discount": discount,
      "totalPrice": productPrice - discount + shipPrice,
      "status": 1
    });

    await FirebaseFirestore.instance.collection('users').doc(user.firebaseUser!.uid).collection('orders').doc(refOrder.id).set({
      "orderId": refOrder.id
    });

    QuerySnapshot query = await FirebaseFirestore.instance.collection('users').doc(user.firebaseUser!.uid).collection('cart').get();

    for (DocumentSnapshot doc in query.docs) {
      doc.reference.delete();
    }

    products.clear();
    discountPercentage = 0;

    isLoading = false;
    _isLoadingController.sink.add(false); // Emitir que parou de carregar

    return refOrder.id;
  }

  void _loadCartItems() {
    FirebaseFirestore.instance.collection('users').doc(user.firebaseUser!.uid).collection('cart').get().then((querySnapshot) {
      products = querySnapshot.docs.map((doc) => CartProduct.fromDocument(doc)).toList();
      _cartController.sink.add(products); // Emitir os produtos carregados
    });
  }

  @override
  void dispose() {
    _cartController.close();
    _isLoadingController.close();
    super.dispose();
  }
}
