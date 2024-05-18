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

  final _cartController = StreamController<List<CartProduct>>.broadcast();
  Stream<List<CartProduct>> get cartStream => _cartController.stream;

  final _productsController = BehaviorSubject<List<CartProduct>>.seeded([]);
  Stream<List<CartProduct>> get productsStream => _productsController.stream;

  final _ordersController = BehaviorSubject<List>();
  Stream<List> get ordersStream => _ordersController.stream;

  final _isLoadingController = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isLoadingStream => _isLoadingController.stream;

  CartBloc(this.user) {
    if (user.isLoggedIn()) {
      _loadCartItems();
    }
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

  Future<void> updateCartItem(CartProduct cartProduct) async {
    try {
      await _firestore.collection('users').doc(user.firebaseUser!.uid).collection('cart').doc(cartProduct.cid).update(cartProduct.toMap());
      _productsController.add(List.from(products));
    } catch (e) {
      print("Erro ao atualizar item do carrinho: $e");
    }
  }

  Future<void> _loadCartItems() async {
    //carregando todos os documentos(itens) do carrinho
    QuerySnapshot carry = await FirebaseFirestore.instance.collection('users').doc(user.firebaseUser!.uid).collection('cart').get();
    //transforma cada documento retornado do firebae em um CartProduct
    products = carry.docs.map((doc) => CartProduct.fromDocument(doc)).toList();
    notifyListeners();
  }

  void decProduct(CartProduct cartProduct) {
    //decrementa a quantidade
    cartProduct.quantity = (cartProduct.quantity! - 1);
    //atualiza o firebase
    FirebaseFirestore.instance.collection('users').doc(user.firebaseUser!.uid).collection('cart').doc(cartProduct.cid).update(cartProduct.toMap());
    notifyListeners();
  }

  void incProduct(CartProduct cartProduct) {
    //incrementa a quantidade
    cartProduct.quantity = (cartProduct.quantity! + 1);
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
        price += (c.quantity! * c.productData!.price!.toDouble());
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

    //adicionando o pedido na coleção orders e obtendo uma referêcia para este pedido para salvar ele no usuário depois
    DocumentReference refOrder = await FirebaseFirestore.instance.collection('orders').add({
      'clientId': user.firebaseUser!.uid,
      //trasforma uma lista de CartProducts em uma lista de mapas
      'products': products.map((cartProduct) => cartProduct.toMap()).toList(),
      'shipProce': shipPrice,
      'productsPrice': productsPrice,
      'discount': discount,
      'totalPrice': productsPrice - discount + shipPrice,
      'status': 1 //status do pedido (1) -> preparando, (2) -> enviando, ... etc
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

    couponCode = "";
    discountPercentage = 0;

    isLoading = false;
    notifyListeners();

    return refOrder.id;
  }

  @override
  void dispose() {
    _cartController.close();
    _productsController.close();
    _isLoadingController.close();
    super.dispose();
  }
}
