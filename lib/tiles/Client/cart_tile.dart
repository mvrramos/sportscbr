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

    Widget buildContent(ProductData productData) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            width: 110,
            child: Image.network(
              productData.images![0],
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
                    productData.title ?? 'Produto sem título',
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
                    "R\$ ${productData.price?.toStringAsFixed(2) ?? '0.00'}",
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
                          style: TextStyle(color: Colors.grey, fontSize: 14),
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
              // Caso ainda não tenha os dados, recarrega os itens
              future: FirebaseFirestore.instance.collection('products').doc(cartProduct.category).collection(cartProduct.category!).doc(cartProduct.pid).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 70,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Container(
                    height: 70,
                    alignment: Alignment.center,
                    child: const Text('Erro ao carregar produto'),
                  );
                } else if (snapshot.hasData && snapshot.data!.exists) {
                  cartProduct.productData = ProductData.fromDocument(snapshot.data!);
                  return buildContent(cartProduct.productData!);
                } else {
                  return Container(
                    height: 70,
                    alignment: Alignment.center,
                    child: const Text('Produto não encontrado'),
                  );
                }
              },
            )
          : buildContent(cartProduct.productData!),
    );
  }
}
