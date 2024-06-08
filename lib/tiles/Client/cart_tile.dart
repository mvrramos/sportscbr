import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportscbr/blocs/Client/cart_bloc.dart';
import 'package:sportscbr/datas/cart_product.dart';
import 'package:sportscbr/datas/product_data.dart';

class CartTile extends StatelessWidget {
  const CartTile(this.cartProduct, {super.key});
  final CartProduct cartProduct;

  @override
  Widget build(BuildContext context) {
    final cartBloc = Provider.of<CartBloc>(context);
    cartBloc.updatePrices();

    Widget buildContent() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            width: 120,
            child: Image.network(
              cartProduct.productData?.images?[0] ?? '',
              // fit: BoxFit.cover,
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
                    "${cartProduct.productData?.title}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    "Tamanho ${cartProduct.size}",
                    style: const TextStyle(fontWeight: FontWeight.w300),
                  ),
                  Text(
                    "R\$ ${cartProduct.productData?.price ?? '0'}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: cartProduct.quantity! > 1 ? () => cartBloc.decProduct(cartProduct) : null,
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
      child: cartProduct.productData == null
          ? buildContent()
          : FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('products').doc(cartProduct.category).collection('cart').doc(cartProduct.pid).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 70,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  );
                } else if (snapshot.hasData) {
                  cartProduct.productData = ProductData.fromDocument(snapshot.data!);
                  return buildContent();
                } else {
                  return Container(
                    height: 70,
                    alignment: Alignment.center,
                    child: const Text(
                      'Produto não encontrado',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
              },
            ),
    );
  }
}
