import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sportscbr/blocs/admin_users_bloc.dart';

class AdminOrderHeader extends StatelessWidget {
  const AdminOrderHeader(this.order, {super.key});
  final DocumentSnapshot order;

  @override
  Widget build(BuildContext context) {
    final adminUserBloc = BlocProvider.getBloc<AdminUsersBloc>();
    final user = adminUserBloc.getUser(order['clientId']);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${user?['name']}"),
              Text("${user?['address']}")
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "Produtos: ${order['productsPrice']}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              "Total: ${order['totalPrice']}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            )
          ],
        ),
      ],
    );
  }
}
