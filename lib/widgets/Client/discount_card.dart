import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportscbr/blocs/Client/cart_bloc.dart'; // Importe o CartBloc

class DiscountCard extends StatelessWidget {
  final CartBloc cartBloc;

  const DiscountCard(this.cartBloc, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        title: const Text(
          "Cupom de desconto",
          textAlign: TextAlign.start,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        leading: const Icon(Icons.discount_outlined),
        trailing: const Icon(Icons.add),
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Digite o seu cupom"),
              initialValue: cartBloc.couponCode, // Use o couponCode do CartBloc
              onFieldSubmitted: (text) {
                cartBloc.setCoupon(text, 0); // Defina o desconto como 0 temporariamente
                FirebaseFirestore.instance.collection('cupons').doc(text).get().then((docSnap) {
                  if (docSnap.data() != null) {
                    int percent = docSnap.get('percent') ?? 0;
                    cartBloc.setCoupon(text, percent); // Defina o cupom com o percentual correto
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Desconto de $percent% aplicado!"),
                        backgroundColor: Colors.grey,
                      ),
                    );
                  } else {
                    cartBloc.setCoupon("", 0); // Limpe o cupom e o desconto
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Cupom não disponível"),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
