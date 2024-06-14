// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:io';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';

class AdminCategoryBloc extends BlocBase {
  final _titleController = BehaviorSubject<String>();
  final _imageController = BehaviorSubject();
  final _deleteController = BehaviorSubject<bool>();

  Stream<String> get outTitle => _titleController.stream.transform(StreamTransformer<String, String>.fromHandlers(
        handleData: (title, sink) {
          if (title.isEmpty) {
            sink.add("Insira um título válido");
          } else {
            sink.add(title);
          }
        },
      ));
  Stream<bool> get outDelete => _deleteController.stream;
  Stream get outImage => _imageController.stream;
  Stream<bool> get submitValid => Rx.combineLatest2(outTitle, outDelete, (title, delete) => title != null && delete != null);

  DocumentSnapshot? category;
  File? image;
  String? title;

  AdminCategoryBloc(this.category) {
    if (category != null) {
      title = category?['title'];

      _titleController.add(category?['title']);
      _imageController.add(category?['icon']);
      _deleteController.add(true);
    } else {
      _titleController.add("Insira um título");
      _imageController.add(null);
      _deleteController.add(false);
    }
  }

  void setImage(File file) {
    image = file;
    _imageController.add(file);
  }

  void setTitle(String title) {
    this.title = title;
    _titleController.add(title);
  }

  void delete() {
    category?.reference.delete();
  }

  Future saveData() async {
    if (image == null && category != null && title == category?['title']) return;

    Map<String, dynamic> dataToUpdate = {};

    if (image != null) {
      UploadTask task = FirebaseStorage.instance.ref().child('icons').child(title!).putFile(image!);

      TaskSnapshot snap = await task;
      dataToUpdate['icon'] = await snap.ref.getDownloadURL();
    }

    if (category == null || title != category?['title']) {
      dataToUpdate['title'] = title;
    }

    if (category == null) {
      await FirebaseFirestore.instance.collection('products').doc(title?.toLowerCase()).set(dataToUpdate);
    } else {
      await category?.reference.update(dataToUpdate);
    }
  }

  @override
  void dispose() {
    _titleController.close();
    _imageController.close();
    _deleteController.close();

    super.dispose();
  }
}
