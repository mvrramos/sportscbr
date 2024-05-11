// ignore_for_file: unnecessary_null_comparison, no_logic_in_create_state

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportscbr/blocs/admin_category_bloc.dart';
import 'package:sportscbr/widgets/admin_source_sheet.dart';

class AdminEditCategoryDialog extends StatefulWidget {
  const AdminEditCategoryDialog(this.category, {super.key});
  final DocumentSnapshot category;

  @override
  State<AdminEditCategoryDialog> createState() => _AdminEditCategoryDialogState(category);
}

class _AdminEditCategoryDialogState extends State<AdminEditCategoryDialog> {
  final AdminCategoryBloc _adminCategoryBloc;
  final TextEditingController _controller;

  _AdminEditCategoryDialogState(DocumentSnapshot category)
      : _adminCategoryBloc = AdminCategoryBloc(category),
        _controller = TextEditingController(text: category['title'] ?? '');

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
