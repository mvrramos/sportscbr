import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportscbr/blocs/Client/cart_bloc.dart'; // Importe o CartBloc
import 'package:sportscbr/datas/cart_product.dart';
import 'package:sportscbr/datas/product_data.dart';

class CartTile extends StatelessWidget {
  final CartProduct cartProduct;
  final CartBloc cartBloc; // Dependência do CartBloc

  const CartTile(this.cartProduct, this.cartBloc, {super.key});

  @override
  Widget build(BuildContext context) {
    Widget buildContent(ProductData productData) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            width: 120,
            child: Image.network(
              productData.images[0],
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
                    productData.title,
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
                    "R\$ ${productData.price}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: cartProduct.quantity > 1 ? () => cartBloc.decProduct(cartProduct) : null,
                        icon: const Icon(Icons.remove),
                        color: Colors.red,
                      ),
                      Text(cartProduct.quantity.toString()),
                      IconButton(
                        onPressed: () => cartBloc.incProduct(cartProduct),
                        icon: const Icon(Icons.add),
                        color: Colors.green,
                      ),
                      ElevatedButton(
                        onPressed: () => cartBloc.removeCartItem(cartProduct),
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
          ? StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('products').doc(cartProduct.category).collection('camisas').doc(cartProduct.pid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final productData = ProductData.fromDocument(snapshot.data!);
                  return buildContent(productData);
                } else {
                  return Container(
                    height: 70,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  );
                }
              },
            )
          : Container(), // Remova o buildContent do retorno do StreamBuilder
    );
  }
}
