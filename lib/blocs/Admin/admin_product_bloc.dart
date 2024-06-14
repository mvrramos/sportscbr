import 'dart:io';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';

mixin AdminProductValidator {
  String? validateImage(List<dynamic>? images) {
    if (images == null || images.isEmpty) return "Adicione imagens do produto";
    return null;
  }

  String? validateTitle(String? text) {
    if (text == null || text.isEmpty) return "Preencha o título do produto";
    return null;
  }

  String? validateDescription(String? text) {
    if (text == null || text.isEmpty) return "Preencha a descrição do produto";
    return null;
  }

  String? validatePrice(String? text) {
    if (text == null || text.isEmpty) return "Preço inválido";
    double? price = double.tryParse(text);
    if (price == null) return "Preço inválido";
    return null;
  }
}

  class AdminProductBloc extends BlocBase with AdminProductValidator {
  final _dataController = BehaviorSubject<Map<String, dynamic>>();
  Stream<Map<String, dynamic>> get outData => _dataController.stream;

  final _loadingController = BehaviorSubject<bool>();
  Stream<bool> get outLoading => _loadingController.stream;

  final _createdController = BehaviorSubject<bool>();
  Stream<bool> get outCreated => _createdController.stream;

  String categoryId;
  DocumentSnapshot? product;
  late Map<String, dynamic> unsavedData;

  AdminProductBloc(this.categoryId, this.product) {
    if (product != null && product!.exists && product!.data() != null) {
      Map<String, dynamic> data = product!.data() as Map<String, dynamic>;
      unsavedData = {
        ...data,
        'images': List<String>.from(data['images'] ?? []),
        'sizes': List<String>.from(data['sizes'] ?? []),
      };
      _createdController.add(true);
    } else {
      unsavedData = {};
      _createdController.add(false);
    }
    _dataController.add(unsavedData);
  }

  void saveImages(List<dynamic> images) {
    unsavedData['images'] = images;
    _dataController.add(unsavedData);
  }

  void saveTitle(String title) {
    unsavedData['title'] = title;
    _dataController.add(unsavedData);
  }

  void saveDescription(String description) {
    unsavedData['description'] = description;
    _dataController.add(unsavedData);
  }

  void savePrice(String price) {
    unsavedData['price'] = double.parse(price);
    _dataController.add(unsavedData);
  }

  void saveSizes(List<dynamic> sizes) {
    unsavedData['sizes'] = sizes;
    _dataController.add(unsavedData);
  }

  Future<bool> saveProduct() async {
    _loadingController.add(true);
    try {
      if (product != null) {
        await _uploadImages(product!.id);
        await product!.reference.update(unsavedData);
      } else {
        DocumentReference dr = FirebaseFirestore.instance.collection('products').doc();
        await dr.set(Map.from(unsavedData)..remove('images'));
        await _uploadImages(dr.id);
        await dr.update(unsavedData);
      }
      _createdController.add(true);
      _loadingController.add(false);
      return true;
    } catch (e) {
      _loadingController.add(false);
      return false;
    }
  }

  Future<void> _uploadImages(String path) async {
    List<dynamic> images = unsavedData['images'];

    for (var i = 0; i < images.length; i++) {
      if (images[i] is String) continue;

      File imageFile = File(images[i]);
      try {
        Reference ref = FirebaseStorage.instance.ref().child('products').child(path).child(DateTime.now().microsecondsSinceEpoch.toString());
        UploadTask uploadTask = ref.putFile(imageFile);
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        images[i] = downloadUrl;
      } catch (e) {
        rethrow;
      }
    }
    unsavedData['images'] = images; // Atualize o unsavedData com as URLs das imagens
  }

  void deleteProduct() {
    if (product != null) {
      product!.reference.delete();
    }
  }

  @override
  void dispose() {
    _dataController.close();
    _loadingController.close();
    _createdController.close();
    super.dispose();
  }
}
