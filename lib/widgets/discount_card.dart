import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DiscountCard extends StatelessWidget {
  const DiscountCard({super.key});

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
            color: Colors.grey,
          ),
        ),
        leading: const Icon(Icons.discount_outlined),
        trailing: const Icon(Icons.add),
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Digite o seu cupom"),
              initialValue: CartModel.of(context).couponCode ?? "",
              onFieldSubmitted: (text) {
                FirebaseFirestore.instance.collection('cupons').doc(text).get().then((docSnap) {
                  if (docSnap.data() != null) {
                    CartModel.of(context).setCoupon(text, docSnap.get('percent'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Desconto de ${docSnap.get('percent')}% aplicado!"),
                        backgroundColor: Colors.grey,
                      ),
                    );
                  } else {
                    CartModel.of(context).setCoupon(0 as String, 0);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Cupom não disponível"),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    CartModel.of(context).setCoupon("", 0);
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
