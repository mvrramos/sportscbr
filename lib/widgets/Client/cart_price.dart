import 'package:flutter/material.dart';
import 'package:sportscbr/blocs/Client/cart_bloc.dart';

class CartPrice extends StatelessWidget {
  final CartBloc cartBloc;
  final VoidCallback onCheckout;

  const CartPrice(this.cartBloc, this.onCheckout, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Resumo do Pedido",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Subtotal"),
                Text("R\$ ${cartBloc.getProductsPrice()}"),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Desconto"),
                Text("R\$ ${cartBloc.getDiscountPrice()}"),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Entrega"),
                Text("R\$ ${cartBloc.getShipPrice()}"),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onCheckout,
              child: const Text("Finalizar Pedido"),
            ),
          ],
        ),
      ),
    );
  }
}
