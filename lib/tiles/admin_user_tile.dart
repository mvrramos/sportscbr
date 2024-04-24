import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AdminUserTile extends StatelessWidget {
  const AdminUserTile(this.user, {super.key});
  final Map<String, dynamic> user;

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(color: Colors.white);
    if (user.containsKey('orders')) {
      return ListTile(
        title: Text(
          user['name'],
          style: textStyle,
        ),
        subtitle: Text(
          user['email'],
          style: textStyle,
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "Pedidos: ${user['orders']}",
              style: textStyle,
            ),
            Text(
              "Gastos: R\$${user['totalPrice']}",
              style: textStyle,
            )
          ],
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
              width: 200,
              child: Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: const Color.fromARGB(100, 73, 5, 182),
                  child: Container(
                    color: const Color.fromARGB(100, 73, 5, 182),
                  )),
            ),
            SizedBox(
              height: 20,
              width: 50,
              child: Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: const Color.fromARGB(100, 73, 5, 182),
                  child: Container(
                    color: const Color.fromARGB(100, 73, 5, 182),
                  )),
            )
          ],
        ),
      );
    }
  }
}
