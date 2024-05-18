import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportscbr/blocs/Admin/admin_category_bloc.dart';
import 'package:sportscbr/widgets/Admin/admin_source_sheet.dart';

class AdminEditCategoryDialog extends StatefulWidget {
  final DocumentSnapshot? category;

  const AdminEditCategoryDialog(this.category, {super.key});

  @override
  State<AdminEditCategoryDialog> createState() => _AdminEditCategoryDialogState();
}

class _AdminEditCategoryDialogState extends State<AdminEditCategoryDialog> {
  late AdminCategoryBloc _adminCategoryBloc;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _adminCategoryBloc = AdminCategoryBloc(widget.category);
    _controller = TextEditingController(text: widget.category != null ? widget.category!['title'] : "");
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => AdminImageSourceSheet((image) {
                      Navigator.of(context).pop();
                      _adminCategoryBloc.setImage(image as File);
                    }),
                  );
                },
                child: StreamBuilder(
                  stream: _adminCategoryBloc.outImage,
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      return CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: snapshot.data is File ? Image.file(snapshot.data as File, fit: BoxFit.cover) : Image.network(snapshot.data as String, fit: BoxFit.cover),
                      );
                    } else {
                      return const Icon(Icons.image);
                    }
                  },
                ),
              ),
              title: StreamBuilder<String>(
                  stream: _adminCategoryBloc.outTitle,
                  builder: (context, snapshot) {
                    return TextField(
                      controller: _controller,
                      onChanged: _adminCategoryBloc.setTitle,
                      decoration: InputDecoration(errorText: snapshot.hasError ? snapshot.error?.toString() : null),
                    );
                  }),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StreamBuilder<bool>(
                  stream: _adminCategoryBloc.outDelete,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Container();
                    return TextButton(
                      onPressed: snapshot.data!
                          ? () {
                              _adminCategoryBloc.delete();
                              Navigator.of(context).pop();
                            }
                          : null,
                      child: const Text("Excluir", style: TextStyle(color: Colors.red)),
                    );
                  },
                ),
                StreamBuilder<bool>(
                    stream: _adminCategoryBloc.submitValid,
                    builder: (context, snapshot) {
                      return TextButton(
                        onPressed: snapshot.hasData
                            ? () async {
                                await _adminCategoryBloc.saveData();
                                Navigator.of(context).pop();
                              }
                            : null,
                        child: const Text("Salvar", style: TextStyle(color: Colors.green)),
                      );
                    }),
              ],
            )
          ],
        ),
      ),
    );
  }
}
