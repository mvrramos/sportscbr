import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:sportscbr/blocs/Admin/admin_orders_bloc.dart';
import 'package:sportscbr/tiles/Admin/admin_order_tile.dart';

class AdminOrdersTab extends StatelessWidget {
  const AdminOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final adminOrdersBloc = BlocProvider.getBloc<AdminOrdersBloc>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: StreamBuilder<List>(
          stream: adminOrdersBloc.outOrders,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color.fromARGB(100, 73, 5, 182)),
                ),
              );
            } else if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "Nenhum pedido encontrado",
                  style: TextStyle(color: Colors.black),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return AdminOrderTile(snapshot.data![index]);
                },
              );
            }
          }),
    );
  }
}
