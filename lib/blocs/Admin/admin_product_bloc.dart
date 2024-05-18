// ignore_for_file: unnecessary_null_comparison

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';

mixin AdminProductValidator {
  String? validateImage(List<dynamic>? images) {
    if (images!.isEmpty) return "Adicione imagens do produto";
    return null;
  }

  String? validateTitle(String? text) {
    if (text!.isEmpty) return "Preencha o título do produto";
    return null;
  }

  String? validateDescription(String? text) {
    if (text!.isEmpty) return "Preencha a descrição do produto";
    return null; // Retorna null quando o texto não está vazio ou nulo
  }

  String? validatePrice(String? text) {
    if (text!.isEmpty) return "Preço inválido";
    double? price = double.tryParse(text);
    if (price == null) return "Preço inválido";
    return null;
  }
}

class AdminProductBloc extends BlocBase {
  final _dataController = BehaviorSubject<Map<String, dynamic>>();
  Stream<Map<String, dynamic>> get outData => _dataController.stream;

  final _loadingController = BehaviorSubject<bool>();
  Stream<bool> get outLoading => _loadingController.stream;

  final _createdController = BehaviorSubject<bool>();
  Stream<bool> get outCreated => _createdController.stream;

  String categoryId;
  late DocumentSnapshot product;
  late Map<String, dynamic> unsavedData;

  AdminProductBloc(this.categoryId, this.product) {
    if (product.exists && product.data() != null) {
      Map<String, dynamic> data = product.data() as Map<String, dynamic>;
      if (data.containsKey('images') && data.containsKey('sizes')) {
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
        await _uploadImages(product.id);
        await product.reference.update(unsavedData);
      } else {
        DocumentReference dr = FirebaseFirestore.instance.collection('products').doc(); // Criando um novo documento com um ID automático
        await dr.set(Map.from(unsavedData..remove('images'))); // Usando set() para adicionar um novo documento
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

  Future _uploadImages(String productId) async {
    for (var i = 0; i < unsavedData['images'].length; i++) {
      if (unsavedData['images'][i] is String) continue;

      Reference ref = FirebaseStorage.instance.ref().child('products').child(productId).child(DateTime.now().microsecondsSinceEpoch.toString());

      UploadTask uploadTask = ref.putFile(unsavedData['images'][i]);

      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      unsavedData['images'][i] = downloadUrl;
    }
  }

  void deleteProduct() {
    product.reference.delete();
  }

  @override
  void dispose() {
    _dataController.close();
    _loadingController.close();
    _createdController.close();
    super.dispose();
  }
}
