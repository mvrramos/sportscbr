import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sportscbr/blocs/Client/login_bloc.dart';
import 'package:sportscbr/datas/cart_product.dart';

class CartBloc extends BlocBase {
  final LoginBloc user;
  List<CartProduct> products = [];
  String couponCode = "";
  int discountPercentage = 0;
  bool isLoading = false;

  final _cartController = StreamController<List<CartProduct>>.broadcast();
  Stream<List<CartProduct>> get cartStream => _cartController.stream;

  final _productsController = BehaviorSubject<List<CartProduct>>.seeded([]);
  Stream<List<CartProduct>> get productsStream => _productsController.stream;

  final _isLoadingController = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isLoadingStream => _isLoadingController.stream;

  CartBloc(this.user) {
    if (user.isLoggedIn()) {
      _loadCartItems();
    }
  }

  Future<void> addCartItem(CartProduct cartProduct) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.firebaseUser!.uid).collection('cart').add(cartProduct.toMap());
      cartProduct.cid = doc.id;
      products.add(cartProduct);
      _productsController.add(List.from(products));
    } catch (e) {
      print("Erro ao adicionar item no carrinho: $e");
    }
  }

  Future<void> removeCartItem(CartProduct cartProduct) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.firebaseUser!.uid).collection('cart').doc(cartProduct.cid).delete();
      products.remove(cartProduct);
      _productsController.add(List.from(products));
    } catch (e) {
      print("Erro ao remover item do carrinho: $e");
    }
  }

  Future<void> updateCartItem(CartProduct cartProduct) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.firebaseUser!.uid).collection('cart').doc(cartProduct.cid).update(cartProduct.toMap());
      _productsController.add(List.from(products));
    } catch (e) {
      print("Erro ao atualizar item do carrinho: $e");
    }
  }

  Future<void> _loadCartItems() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(user.firebaseUser!.uid).collection('cart').get();
      products = snapshot.docs.map((doc) => CartProduct.fromDocument(doc)).toList();
      _productsController.add(List.from(products));
    } catch (e) {
      print("Erro ao carregar itens do carrinho: $e");
    }
  }

  void decProduct(CartProduct cartProduct) {
    cartProduct.quantity--;
    updateCartItem(cartProduct);
  }

  void incProduct(CartProduct cartProduct) {
    cartProduct.quantity++;
    updateCartItem(cartProduct);
  }

  void setCoupon(String couponCode, int discountPercentage) {
    this.couponCode = couponCode;
    this.discountPercentage = discountPercentage;
    updatePrices();
  }

  void updatePrices() {
    _productsController.add(List.from(products));
  }

  double getProductsPrice() {
    return products.fold(0.0, (total, current) => total + (current.quantity * current.productData!.price));
  }

  double getDiscountPrice() {
    return getProductsPrice() * discountPercentage / 100;
  }

  double getShipPrice() {
    return 14.99;
  }

  Future<String?> finishOrder() async {
    if (products.isEmpty) return null;

    isLoading = true;
    _isLoadingController.add(true);

    double productPrice = getProductsPrice();
    double shipPrice = getShipPrice();
    double discount = getDiscountPrice();

    try {
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
        await doc.reference.delete();
      }

      products.clear();
      discountPercentage = 0;

      isLoading = false;
      _isLoadingController.add(false);

      return refOrder.id;
    } catch (e) {
      isLoading = false;
      _isLoadingController.add(false);
      print("Erro ao finalizar o pedido: $e");
      return null;
    }
  }

  @override
  void dispose() {
    _cartController.close();
    _productsController.close();
    _isLoadingController.close();
    super.dispose();
  }
}
