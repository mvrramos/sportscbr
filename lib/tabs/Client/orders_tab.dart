import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportscbr/blocs/Client/login_bloc.dart';
import 'package:sportscbr/screens/login_screen.dart';
import 'package:sportscbr/tiles/Client/order_tile.dart';

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final loginBloc = Provider.of<LoginBloc>(context);

    if (loginBloc.currentUser != null) {
      return StreamBuilder<List<DocumentSnapshot>>(
        stream: loginBloc.ordersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar os pedidos.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum pedido encontrado.'));
          } else {
            return Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: const Color.fromARGB(100, 73, 5, 182),
                foregroundColor: Colors.white,
                title: const Text(
                  'Pedidos',
                ),
              ),
              body: ListView(
                children: snapshot.data!.map((doc) => OrderTile(doc.id)).toList().reversed.toList(),
              ),
            );
          }
        },
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.list,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Faça login para adicionar produtos!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              child: const Text(
                'Entrar',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
