import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportscbr/widgets/Admin/admin_order_header.dart';

class AdminOrderTile extends StatelessWidget {
  AdminOrderTile(this.order, {super.key});

  final DocumentSnapshot order;
  final status = [
    "",
    "Em preparação",
    "Em transporte",
    "Aguardando entrega",
    "Entregue"
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ExpansionTile(
          key: Key(order.id),
          initiallyExpanded: false,
          title: Text(
            "#${order.id.substring(order.id.length - 10)} - ${status[order['status']]}",
            style: const TextStyle(color: Colors.green),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AdminOrderHeader(order),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: order['products'].map<Widget>((p) {
                      return ListTile(
                        title: Text(p['product']['title'] + " " + p['sizes']),
                        subtitle: Text(p['category'] + " - " + p['pid']),
                        trailing: Text(
                          p['quantity'].toString(),
                          style: const TextStyle(fontSize: 15),
                        ),
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          FirebaseFirestore.instance.collection('users').doc(order['clientId']).collection('orders').doc(order.id).delete();

                          order.reference.delete();
                        },
                        child: Text("Excluir", style: TextStyle(color: Colors.red[900])),
                      ),
                      TextButton(
                        onPressed: () {
                          if (order['status'] > 1) {
                            order.reference.update({
                              'status': order['status'] - 1
                            });
                          }
                        },
                        child: const Text("Regredir", style: TextStyle(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () {
                          if (order['status'] < 4 || order['status'] == order.reference) {
                            order.reference.update({
                              'status': order['status'] + 1
                            });
                          }
                        },
                        child: const Text("Avançar", style: TextStyle(color: Colors.green)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
