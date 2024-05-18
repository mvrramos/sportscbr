import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportscbr/tiles/Client/place_tile.dart';

class PlacesTab extends StatelessWidget {
  const PlacesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('places').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No data available'),
          );
        } else {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(100, 73, 5, 182),
              foregroundColor: Colors.white,
              title: const Text("Minha loja"),
            ),
            body: ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot doc) {
                return PlaceTile(doc); // Assuming PlaceTile accepts a DocumentSnapshot
              }).toList(),
            ),
          );
        }
      },
    );
  }
}
