import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportscbr/screens/category_screen.dart';

class CategoryTile extends StatelessWidget {
  final DocumentSnapshot snapshot;

  const CategoryTile(this.snapshot, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.white,
        backgroundImage: NetworkImage(snapshot.get('icon')),
      ),
      title: Text(
        snapshot.get('title'),
        style: const TextStyle(color: Colors.white),
      ),
      trailing: const Icon(
        Icons.keyboard_arrow_right,
        color: Colors.white,
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CategoryScreen(snapshot),
        ));
      },
    );
  }
}
