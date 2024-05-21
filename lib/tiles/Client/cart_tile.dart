import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportscbr/blocs/Client/cart_bloc.dart'; // Importe o CartBloc
import 'package:sportscbr/datas/cart_product.dart';
import 'package:sportscbr/datas/product_data.dart';

class CartTile extends StatelessWidget {
  const CartTile(this.cartProduct, this.cartBloc, {super.key});

  final CartProduct cartProduct;
  final CartBloc cartBloc; // Dependência do CartBloc

  @override
  Widget build(BuildContext context) {
    cartBloc.updatePrices();

    Widget buildContent() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            width: 120,
            child: Image.network(
              cartProduct.productData?.images?[0],
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
                    cartProduct.productData!.title!,
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
                    "R\$ ${cartProduct.productData!.price!}",
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
          ? FutureBuilder<DocumentSnapshot>(
              //caso ainda não tenha os dados, recarrega os itens
              future: FirebaseFirestore.instance.collection('products').doc(cartProduct.category).collection('cart').doc(cartProduct.pid).get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  //salva os dados para mostrar depois
                  cartProduct.productData = ProductData.fromDocument(snapshot.data!);
                  return buildContent(); //mostra os itens
                } else {
                  return Container(
                    height: 70,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  );
                }
              },
            )
          //caso já tenha os dados, mostra os itens
          : buildContent(),
    );
  }
}
