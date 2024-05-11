// ignore_for_file: use_build_context_synchronously

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sportscbr/blocs/cart_bloc.dart';
import 'package:sportscbr/blocs/user_bloc.dart';
import 'package:sportscbr/datas/cart_product.dart';
import 'package:sportscbr/screens/login_screen.dart';
import 'package:sportscbr/screens/order_screen.dart';
import 'package:sportscbr/tiles/cart_tile.dart';
import 'package:sportscbr/widgets/cart_price.dart';
import 'package:sportscbr/widgets/discount_card.dart';
import 'package:sportscbr/widgets/ship_card.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CartBloc cartBloc = BlocProvider.getBloc<CartBloc>();
    final UserBloc userBloc = BlocProvider.getBloc<UserBloc>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Meu carrinho",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.only(right: 8),
            alignment: Alignment.center,
            child: StreamBuilder<List<CartProduct>>(
              stream: cartBloc.cartStream,
              builder: (context, snapshot) {
                int p = snapshot.data?.length ?? 0;
                return Text(
                  "$p ${p == 1 ? "ITEM" : "ITENS"} ",
                  style: const TextStyle(fontSize: 17),
                );
              },
            ),
          )
        ],
      ),
      body: StreamBuilder<User?>(
        stream: userBloc.userStream,
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            // Verifica se o usuário está logado
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.remove_shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Faça o login para adicionar os produtos",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text(
                      "Entrar",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return StreamBuilder<List<CartProduct>>(
              stream: cartBloc.cartStream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  List<CartProduct> products = snapshot.data!;
                  return ListView(
                    children: [
                      Column(
                        children: products.map((product) {
                          return CartTile(product);
                        }).toList(),
                      ),
                      const DiscountCard(),
                      const ShipCard(),
                      CartPrice(() async {
                        String? orderId = await cartBloc.finishOrder();
                        if (orderId != null) {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => OrderScreen(orderId),
                          ));
                        }
                      }),
                    ],
                  );
                } else {
                  return const Center(
                    child: Text(
                      "Nenhum produto no carrinho",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
