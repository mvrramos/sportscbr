import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportscbr/screens/Admin/admin_product_screen.dart';
import 'package:sportscbr/widgets/Admin/admin_edit_category_dialog.dart';

class AdminCategoryTile extends StatelessWidget {
  final DocumentSnapshot category;

  const AdminCategoryTile(this.category, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ExpansionTile(
          leading: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AdminEditCategoryDialog(category),
              );
            },
            child: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(category['icon'] ?? []),
              backgroundColor: Colors.transparent,
            ),
          ),
          title: Text(
            category['title'],
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          ),
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: category.reference.collection(category.id).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text("Nenhum produto encontrado");
                } else {
                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      // Acessa o campo 'images' do documento
                      final List<dynamic>? images = doc['images'];
                      if (images != null && images.isNotEmpty) {
                        final String imageUrl = images[0];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            backgroundImage: NetworkImage(imageUrl),
                          ),
                          title: Text(doc['title']),
                          trailing: Text("R\$${doc['price']}"),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => AdminProductScreen(category.id, doc),
                            ));
                          },
                        );
                      } else {
                        // Se não houver link de imagem, exibe um ListTile sem imagem
                        return ListTile(
                          title: Text(doc['title']),
                          trailing: Text("R\$${doc['price']}"),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => AdminProductScreen(category.id, doc),
                            ));
                          },
                        );
                      }
                    }).toList()
                      ..add(ListTile(
                        title: const Text("Adicionar"),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AdminProductScreen(category.id, category),
                          ));
                        },
                        leading: const CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            Icons.add,
                            color: Color.fromARGB(100, 73, 5, 182),
                          ),
                        ),
                      )),
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
