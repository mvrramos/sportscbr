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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _productsController = BehaviorSubject<List<CartProduct>>.seeded([]);
  Stream<List<CartProduct>> get productsStream => _productsController.stream;

  final _isLoadingController = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isLoadingStream => _isLoadingController.stream;

  CartBloc(this.user) {
    if (user.isLoggedIn()) {
      _loadCartItems();
    }
  }

  void _loadCartItems() async {
    QuerySnapshot cart = await _firestore.collection('users').doc(user.firebaseUser!.uid).collection('cart').get();
    products = cart.docs.map((doc) => CartProduct.fromDocument(doc)).toList();
    notifyListeners();
  }

  Future<void> addCartItem(CartProduct cartProduct) async {
    products.add(cartProduct); //adiconando produtos ao carrinho
    FirebaseFirestore.instance.collection('users').doc(user.firebaseUser!.uid).collection('cart').add(cartProduct.toMap()).then((doc) {
      //pegando o id do cart
      cartProduct.cid = doc.id;
    });
    notifyListeners();
  }

  Future<void> removeCartItem(CartProduct cartProduct) async {
    //tirando produtos do carrinho
    FirebaseFirestore.instance.collection('users').doc(user.firebaseUser!.uid).collection('cart').doc(cartProduct.cid).delete();

    products.remove(cartProduct);
    notifyListeners();
  }

  void updateCartItem(CartProduct cartProduct) async {
    try {
      await _firestore.collection('users').doc(user.firebaseUser!.uid).collection('cart').doc(cartProduct.cid).update(cartProduct.toMap());
      _productsController.add(List.from(products)); // Notificar os ouvintes
    } catch (e) {
      print("Erro ao atualizar item do carrinho: $e");
    }
  }

  void decProduct(CartProduct cartProduct) {
    //decrementa a quantidade
    cartProduct.quantity = cartProduct.quantity! - 1;
    //atualiza o firebase
    FirebaseFirestore.instance.collection('users').doc(user.firebaseUser!.uid).collection('cart').doc(cartProduct.cid).update(cartProduct.toMap());
    notifyListeners();
  }

  void incProduct(CartProduct cartProduct) {
    //incrementa a quantidade
    cartProduct.quantity = cartProduct.quantity! + 1;
    //atualiza o firebase
    FirebaseFirestore.instance.collection('users').doc(user.firebaseUser!.uid).collection('cart').doc(cartProduct.cid).update(cartProduct.toMap());
    notifyListeners();
  }

  void setCoupon(String couponCode, int discountPercentage) {
    this.couponCode = couponCode;
    this.discountPercentage = discountPercentage;
  }

  void updatePrices() {
    notifyListeners();
  }

  double getProductsPrice() {
    double price = 0.0;
    for (CartProduct c in products) {
      if (c.productData != null) {
        price += c.quantity! * c.productData!.price!.toDouble();
      }
    }
    return price;
  }

  double getDiscountPrice() {
    return getProductsPrice() * (discountPercentage / 100);
  }

  double getShipPrice() {
    return 14.99;
  }

  Future<String?> finishOrder() async {
    if (products.isEmpty) return null;

    isLoading = true;
    notifyListeners();

    double productsPrice = getProductsPrice();
    double shipPrice = getShipPrice();
    double discount = getDiscountPrice();

    DocumentReference refOrder = await FirebaseFirestore.instance.collection('orders').add({
      'clientId': user.firebaseUser!.uid,
      'products': products.map((cartProduct) => cartProduct.toMap()).toList(),
      'shipPrice': shipPrice,
      'productsPrice': productsPrice,
      'discount': discount,
      'totalPrice': productsPrice + shipPrice - discount,
      'status': 1,
    });

    //salvando referência do pedido no usuário
    await FirebaseFirestore.instance.collection('users').doc(user.firebaseUser!.uid).collection('orders').doc(refOrder.id).set({
      'orderId': refOrder.id
    });

    //pegando todos os itens do carrinho
    QuerySnapshot query = await FirebaseFirestore.instance.collection('users').doc(user.firebaseUser!.uid).collection('cart').get();
    //pegando uma referência para cada um dos produtos do carrinho e deletando
    for (DocumentSnapshot doc in query.docs) {
      doc.reference.delete();
    }

    products.clear(); //limpando lista local

    couponCode = '';
    discountPercentage = 0;

    isLoading = false;
    notifyListeners();

    return refOrder.id;
  }

  @override
  void dispose() {
    _productsController.close();
    _isLoadingController.close();
    super.dispose();
  }
}
