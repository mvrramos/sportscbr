// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportscbr/blocs/cart_bloc.dart';


class CartTile extends StatelessWidget {
  const CartTile(this.cartProduct, {super.key});

  final CartProduct cartProduct;

  @override
  Widget build(BuildContext context) {
    Widget buildContent() {
      CartModel.of(context).updatePrices();
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            width: 120,
            child: Image.network(
              cartProduct.productData.images[0],
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    cartProduct.productData.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    "Tamanho ${cartProduct.sizes}",
                    style: const TextStyle(fontWeight: FontWeight.w300),
                  ),
                  Text(
                    "R\$ ${cartProduct.productData.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: cartProduct.quantity > 1
                            ? () {
                                CartModel.of(context).decProduct(cartProduct);
                              }
                            : null,
                        icon: const Icon(Icons.remove),
                        color: Colors.red,
                      ),
                      Text(cartProduct.quantity.toString()),
                      IconButton(
                        onPressed: () {
                          CartModel.of(context).incProduct(cartProduct);
                        },
                        icon: const Icon(Icons.add),
                        color: Colors.green,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          CartModel.of(context).removeCartItem(cartProduct);
                        },
                        child: const Text(
                          "Remover",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: cartProduct.productData != null
          ? FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('products').doc(cartProduct.category).collection('camisas').doc(cartProduct.pid).get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  cartProduct.productData = ProductData.fromDocument(snapshot.data!);
                  return buildContent();
                } else {
                  return Container(
                    height: 70,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  );
                }
              },
            )
          : buildContent(),
    );
  }
}
