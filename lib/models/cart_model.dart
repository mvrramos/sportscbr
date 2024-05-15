// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:scoped_model/scoped_model.dart';
// import 'package:sportscbr/datas/cart_product.dart';
// import 'package:sportscbr/models/user_model.dart';

// class CartModel extends Model {
//   UserModel user;

//   List<CartProduct> products = [];

//   String couponCode = "";
//   int discountPercentage = 0;

//   bool isLoading = false;

//   CartModel(this.user) {
//     if (user.isLoggedIn()) {
//       _loadCartItems();
//     }
//   }

//   static CartModel of(BuildContext context) => ScopedModel.of<CartModel>(context);

//   void addCartItem(CartProduct cartProduct) {
//     products.add(cartProduct);
//     FirebaseFirestore.instance.collection('users').doc(user.firebaseUser?.uid).collection('cart').add(cartProduct.toMap()).then((doc) {
//       cartProduct.cid = doc.id;
//     });

//     notifyListeners();
//   }

//   void removeCartItem(CartProduct cartProduct) {
//     FirebaseFirestore.instance.collection('users').doc(user.firebaseUser!.uid).collection('cart').doc(cartProduct.cid).delete();

//     products.remove(cartProduct);
//     notifyListeners();
//   }

//   void decProduct(CartProduct cartProduct) {
//     cartProduct.quantity--;

//     FirebaseFirestore.instance.collection('users').doc(user.firebaseUser!.uid).collection('cart').doc(cartProduct.cid).update(cartProduct.toMap());

//     notifyListeners();
//   }

//   void incProduct(CartProduct cartProduct) {
//     cartProduct.quantity++;

//     FirebaseFirestore.instance.collection('users').doc(user.firebaseUser!.uid).collection('cart').doc(cartProduct.cid).update(cartProduct.toMap());

//     notifyListeners();
//   }

//   void setCoupon(String couponCode, int discountPercentage) {
//     this.couponCode = couponCode;
//     this.discountPercentage = discountPercentage;
//   }

//   void updatePrices() {
//     notifyListeners();
//   }

//   double getProductsPrice() {
//     double price = 0.0;
//     for (CartProduct c in products) {
//       price += c.quantity * c.productData.price;
//     }
//     return price;
//   }

//   double getDiscountPrice() {
//     return getProductsPrice() * discountPercentage / 100;
//   }

//   double getShipPrice() {
//     return 14.99;
//   }

//   Future<String?> finishOrder() async {
//     if (products.isEmpty) {
//       return null;
//     }

//     isLoading = true;
//     notifyListeners();

//     double productPrice = getProductsPrice();
//     double shipPrice = getShipPrice();
//     double discount = getDiscountPrice();

//     DocumentReference refOrder = await FirebaseFirestore.instance.collection('orders').add({
//       "clientId": user.firebaseUser!.uid,
//       "products": products.map((cartProduct) => cartProduct.toMap()).toList(),
//       "shipPrice": shipPrice,
//       "productsPrice": productPrice,
//       "discount": discount,
//       "totalPrice": productPrice - discount + shipPrice,
//       "status": 1
//     });
//     FirebaseFirestore.instance.collection('users').doc(user.firebaseUser!.uid).collection('orders').doc(refOrder.id).set({
//       "orderId": refOrder.id
//     });

//     QuerySnapshot query = await FirebaseFirestore.instance.collection('users').doc(user.firebaseUser!.uid).collection('cart').get();

//     for (DocumentSnapshot doc in query.docs) {
//       doc.reference.delete();
//     }
//     products.clear();
//     discountPercentage = 0;

//     isLoading = false;
//     notifyListeners();

//     return refOrder.id;
//   }

//   void _loadCartItems() async {
//     QuerySnapshot query = await FirebaseFirestore.instance.collection('users').doc(user.firebaseUser!.uid).collection('cart').get();

//     products = query.docs.map((doc) => CartProduct.fromDocument(doc)).toList();

//     notifyListeners();
//   }
// }
