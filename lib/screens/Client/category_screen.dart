import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportscbr/datas/product_data.dart';
import 'package:sportscbr/tiles/Client/product_tile.dart';

class CategoryScreen extends StatelessWidget {
  final DocumentSnapshot snapshot;

  const CategoryScreen(this.snapshot, {super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(snapshot.get('title')),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.grid_on)),
              Tab(icon: Icon(Icons.list)),
            ],
          ),
        ),
        body: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('products').doc(snapshot.id).collection(snapshot.id).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Erro ao carregar os produtos'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'Nenhum produto encontrado',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 40,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              return TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  GridView.builder(
                    padding: const EdgeInsets.all(4.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 2.0,
                      crossAxisSpacing: 2.0,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      //passa cada documento atraves do index, tranforma em um objeto, passa para o ProductTile
                      ProductData data = ProductData.fromDocument(snapshot.data!.docs[index]);
                      data.category = this.snapshot.id; //passando a catergoria do documento(produto)
                      return ProductTile(
                        "grid",
                        data,
                      );
                    },
                  ),
                  ListView.builder(
                    padding: const EdgeInsets.all(2.0),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      ProductData data = ProductData.fromDocument(snapshot.data!.docs[index]);
                      data.category = this.snapshot.id;
                      return ProductTile(
                        "list",
                        data,
                      );
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
