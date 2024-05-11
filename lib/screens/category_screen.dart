import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportscbr/blocs/product_bloc.dart';
import 'package:sportscbr/tiles/product_tile.dart';

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
          future: FirebaseFirestore.instance.collection('products').doc(snapshot.id).collection('camisas').get(),
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
                    color: Colors.white,
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
                      mainAxisSpacing: 4.0,
                      crossAxisSpacing: 4.0,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      ProductData data = ProductData.fromDocument(snapshot.data!.docs[index]);
                      data.category = this.snapshot.id;
                      String imageUrl = data.images[0]; // Primeira imagem
                      return ProductTile(
                        "grid",
                        data,
                        image: CachedNetworkImage(
                          imageUrl: imageUrl,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                          cacheKey: imageUrl,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.low,
                        ),
                      );
                    },
                  ),
                  ListView.builder(
                    padding: const EdgeInsets.all(4.0),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      ProductData data = ProductData.fromDocument(snapshot.data!.docs[index]);
                      data.category = this.snapshot.id;
                      String imageUrl = data.images[0];
                      return ProductTile(
                        "list",
                        data,
                        image: CachedNetworkImage(
                          imageUrl: imageUrl,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                          cacheKey: imageUrl,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.low,
                        ),
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
