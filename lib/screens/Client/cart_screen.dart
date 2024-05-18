import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportscbr/blocs/Client/cart_bloc.dart';
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          "Meu carrinho",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.only(right: 8),
            alignment: Alignment.center,
            child: StreamBuilder<List<CartProduct>>(
              stream: cartBloc.productsStream,
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
      body: StreamBuilder<List<CartProduct>>(
        stream: cartBloc.productsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            if (cartBloc.user.isLoggedIn()) {
              return const Center(
                child: Text(
                  "Nenhum produto no carrinho",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              );
            } else {
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
            }
          } else {
            return ListView(
              children: [
                Column(
                  children: snapshot.data!.map((product) {
                    return CartTile(product, cartBloc);
                  }).toList(),
                ),
                DiscountCard(cartBloc: cartBloc),
                const ShipCard(),
                CartPrice(
                  () async {
                    String? orderId = await cartBloc.finishOrder();
                    if (orderId != null) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => OrderScreen(orderId),
                        ),
                      );
                    }
                  },
                  cartBloc, // Passando o cartBloc como segundo argumento
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
