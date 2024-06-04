import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportscbr/blocs/Client/cart_bloc.dart';
import 'package:sportscbr/blocs/Client/login_bloc.dart';
import 'package:sportscbr/datas/cart_product.dart';
import 'package:sportscbr/screens/Client/order_screen.dart';
import 'package:sportscbr/screens/login_screen.dart';
import 'package:sportscbr/tiles/Client/cart_tile.dart';
import 'package:sportscbr/widgets/Client/cart_price.dart';
import 'package:sportscbr/widgets/Client/discount_card.dart';
import 'package:sportscbr/widgets/Client/ship_card.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartBloc = Provider.of<CartBloc>(context);
    final loginBloc = Provider.of<LoginBloc>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Meu Carrinho'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          Container(
            padding: const EdgeInsets.only(right: 8),
            alignment: Alignment.center,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(loginBloc.firebaseUser!.uid).collection('cart').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Erro');
                } else {
                  int qtyP = snapshot.data!.docs.length;
                  return Text(
                    '$qtyP ${qtyP == 1 ? 'ITEM' : 'ITENS'}',
                    style: const TextStyle(fontSize: 17),
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: loginBloc.currentUser != null
          ? StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(loginBloc.firebaseUser!.uid).collection('cart').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar os itens do carrinho.'));
                } else if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum produto no carrinho!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                } else {
                  final List<CartProduct> products = snapshot.data!.docs.map((doc) => CartProduct.fromDocument(doc)).toList();
                  return ListView(
                    children: [
                      Column(
                        children: products.map((product) => CartTile(product)).toList(),
                      ),
                      DiscountCard(cartBloc),
                      const ShipCard(),
                      CartPrice(cartBloc, () async {
                        String? orderId = await cartBloc.finishOrder();
                        if (orderId != null) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => OrderScreen(orderId),
                            ),
                          );
                        }
                      }),
                    ],
                  );
                }
              },
            )
          : const LoginScreen(),
    );
  }
}
