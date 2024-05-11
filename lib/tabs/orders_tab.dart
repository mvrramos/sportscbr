import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportscbr/models/user_model.dart';
import 'package:sportscbr/screens/login_screen.dart';
import 'package:sportscbr/tiles/order_tile.dart';

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    if (UserModel.of(context).isLoggedIn()) {
      String uid = UserModel.of(context).firebaseUser!.uid;

      return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).collection('orders').get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return ListView(
              children: snapshot.data!.docs.map((doc) => OrderTile(doc.id)).toList().reversed.toList(),
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
              Icons.view_list,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 15),
            const Text(
              "Faça o login para acompanhar",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ));
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(100, 73, 5, 182)),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              child: const Text(
                "Entrar",
                style: TextStyle(fontSize: 18),
                selectionColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
  }
}
