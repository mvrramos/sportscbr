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

    Widget buildContend() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            width: 120,
            child: Image.network(
              cartProduct.productData!.images![0],
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
                    'Tamanho:  ${cartProduct.size}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    'R\$ ${cartProduct.productData!.price!.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: cartProduct.quantity! > 1
                            ? () {
                                cartBloc.decProduct(cartProduct);
                              }
                            : null, //desebilita caso for menor que 1
                        icon: const Icon(Icons.remove),
                        color: Theme.of(context).primaryColor,
                      ),
                      Text(cartProduct.quantity.toString()),
                      IconButton(
                        onPressed: () {
                          cartBloc.incProduct(cartProduct);
                        },
                        color: Theme.of(context).primaryColor,
                        icon: const Icon(Icons.add),
                      ),
                      TextButton(
                        onPressed: () {
                          //remove todos
                          cartBloc.removeCartItem(cartProduct);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[500],
                        ),
                        child: const Text('Remover'),
                      ),
                    ],
                  )
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
              future: FirebaseFirestore.instance.collection('products').doc(cartProduct.category).collection('itens').doc(cartProduct.pid).get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  //salva os dados para mostrar depois
                  cartProduct.productData = ProductData.fromDocument(snapshot.data!);
                  return buildContend(); //mostra os itens
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
          : buildContend(),
    );
  }
}
