// ignore_for_file: body_might_complete_normally_nullable, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportscbr/blocs/Admin/admin_product_bloc.dart';
import 'package:sportscbr/widgets/Admin/admin_add_product_sizes.dart';
import 'package:sportscbr/widgets/Admin/admin_widgets_image.dart';

class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen(this.categoryId, this.product, {super.key});

  final String categoryId;
  final DocumentSnapshot product;

  @override
  // ignore: no_logic_in_create_state
  State<AdminProductScreen> createState() => _AdminProductScreenState(categoryId, product);
}

class _AdminProductScreenState extends State<AdminProductScreen> with AdminProductValidator {
  final _formKey = GlobalKey<FormState>();
  final AdminProductBloc _adminProductBloc;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _AdminProductScreenState(String categoryId, DocumentSnapshot product) : _adminProductBloc = AdminProductBloc(categoryId, product);

  @override
  Widget build(BuildContext context) {
    InputDecoration buildDecoration(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
      );
    }

    return Scaffold(
      // key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(100, 73, 5, 182),
        title: StreamBuilder<bool>(
            stream: _adminProductBloc.outCreated,
            initialData: false,
            builder: (context, snapshot) {
              return Text(snapshot.data! ? "Editar produto" : "Adicionar produto", style: const TextStyle(color: Colors.white, fontSize: 18));
            }),
        actions: <Widget>[
          StreamBuilder<bool>(
            stream: _adminProductBloc.outCreated,
            initialData: false,
            builder: (context, snapshot) {
              if (snapshot.data!) {
                return StreamBuilder(
                  stream: _adminProductBloc.outLoading,
                  builder: (context, snapshot) {
                    return IconButton(
                      onPressed: snapshot.data != null
                          ? null
                          : () {
                              _adminProductBloc.deleteProduct();
                              Navigator.of(context).pop();
                            },
                      icon: const Icon(Icons.remove),
                    );
                  },
                );
              } else {
                return Container();
              }
            },
          ),
          StreamBuilder<bool>(
            stream: _adminProductBloc.outLoading,
            initialData: false,
            builder: (context, snapshot) {
              return IconButton(
                onPressed: snapshot.data! ? null : saveProduct,
                icon: const Icon(Icons.save),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: StreamBuilder<Map<String, dynamic>>(
              stream: _adminProductBloc.outData,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Container();
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      "Imagens",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    AdminImagesWidget(
                      context,
                      initialValue: snapshot.data!['images'] ?? [],
                      onSaved: (images) => _adminProductBloc.saveImages(images!),
                      validator: (images) => validateImage(images),
                    ),
                    TextFormField(
                      initialValue: snapshot.data!['title'] as String? ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: buildDecoration("Titulo"),
                      onSaved: (title) => _adminProductBloc.saveTitle(title ?? ''),
                      validator: (title) => validateTitle(title),
                    ),
                    TextFormField(
                      initialValue: snapshot.data!['description'] as String? ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: buildDecoration("Descrição"),
                      maxLines: 2,
                      onSaved: (description) => _adminProductBloc.saveDescription(description!),
                      validator: (description) => validateDescription(description),
                    ),
                    TextFormField(
                      initialValue: snapshot.data!['price']?.toString() ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      keyboardType: TextInputType.number,
                      decoration: buildDecoration("Preço"),
                      onSaved: (price) => _adminProductBloc.savePrice(price ?? ''),
                      validator: (price) => validatePrice(price),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Tamanhos",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    AdminProductSizes(
                      context,
                      initialValue: snapshot.data!['sizes'] ?? [],
                      onSaved: (sizes) => _adminProductBloc.saveSizes(sizes!),
                      validator: (s) {
                        if (s!.isEmpty) return "";
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          StreamBuilder<bool>(
            stream: _adminProductBloc.outLoading,
            initialData: false,
            builder: (context, snapshot) {
              return IgnorePointer(
                ignoring: !snapshot.data!,
                child: Container(
                  color: snapshot.data! ? Colors.black54 : Colors.transparent,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void saveProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_scaffoldKey.currentState != null) {
        _scaffoldKey.currentState!.showBottomSheet((context) => const SnackBar(
              content: Text("Salvando produto...", style: TextStyle(color: Colors.white)),
              duration: Duration(milliseconds: 500),
              backgroundColor: Color.fromARGB(100, 73, 5, 182),
            ));
      }

      bool success = await _adminProductBloc.saveProduct();
      ScaffoldMessenger.of(context).removeCurrentSnackBar(); // Remova o SnackBar anterior

      if (success) {
        // Recarrega a página se o produto for salvo com sucesso
        setState(() {});
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? "Produto salvo com sucesso" : "Erro ao salvar o produto", style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(100, 73, 5, 182),
      ));
    } else {}
  }
}
