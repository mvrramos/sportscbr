import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderTile extends StatelessWidget {
  final String orderId;

  const OrderTile(this.orderId, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('orders').doc(orderId).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else {
              int status = snapshot.data!.get('status');
              return Column(
                children: [
                  Text(
                    "Código do pedido: ${snapshot.data!.id}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _buildProductText(snapshot.data!),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Status do pedido:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCircle("1", "Preparação", status, 1),
                      Container(
                        height: 1,
                        width: 40,
                        color: Colors.grey,
                      ),
                      _buildCircle("2", "Transporte", status, 2),
                      Container(
                        height: 1,
                        width: 40,
                        color: Colors.grey,
                      ),
                      _buildCircle("3", "Entrega", status, 3),
                    ],
                  )
                ],
              );
            }
          },
        ),
      ),
    );
  }

  String _buildProductText(DocumentSnapshot snapshot) {
    String text = "Descrição:\n";

    List<dynamic> products = snapshot['products'];
    for (Map<String, dynamic> p in products) {
      text += "${p["quantity"]} x ${p["product"]["title"]} (R\$ ${p["product"]["price"].toStringAsFixed(2)})\n";
    }
    text += "Total: R\$ ${snapshot['totalPrice']}";
    return text;
  }

  Widget _buildCircle(String title, String subtitle, int status, int thisStatus) {
    Color backColor;
    Widget child;

    if (status < thisStatus) {
      backColor = Colors.grey;
      child = Text(
        title,
        style: const TextStyle(color: Colors.white),
      );
    } else if (status == thisStatus) {
      backColor = Colors.blue;
      child = Stack(
        alignment: Alignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          )
        ],
      );
    } else {
      backColor = Colors.green;
      child = const Icon(
        Icons.check,
        color: Colors.white,
      );
    }
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: backColor,
          child: child,
        ),
        Text(subtitle),
      ],
    );
  }
}
