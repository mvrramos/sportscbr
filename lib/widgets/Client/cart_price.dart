import 'package:flutter/material.dart';
import 'package:sportscbr/blocs/Client/cart_bloc.dart';
import 'package:sportscbr/datas/cart_product.dart';

class CartPrice extends StatelessWidget {
  final VoidCallback buy;
  final CartBloc cartBloc;

  const CartPrice(this.buy, this.cartBloc, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<List<CartProduct>>(
          stream: cartBloc.productsStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text("Nenhum item no carrinho"),
              );
            }

            double price = cartBloc.getProductsPrice();
            double discount = cartBloc.getDiscountPrice();
            double ship = cartBloc.getShipPrice();
            double total = price + ship - discount;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Resumo do pedido",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Subtotal"),
                    Text("R\$ ${price.toStringAsFixed(2)}"),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Desconto"),
                    Text("R\$ ${discount.toStringAsFixed(2)}"),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Entrega"),
                    Text("R\$ ${ship.toStringAsFixed(2)}"),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "R\$ ${total.toStringAsFixed(2)}",
                      style: const TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: buy,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text(
                    "Finalizar pedido",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
