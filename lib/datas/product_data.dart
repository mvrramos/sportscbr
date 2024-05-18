import 'package:cloud_firestore/cloud_firestore.dart';

class ProductData {
  late String id;
  late String title;
  late String description;
  late int price;
  late List images;
  late List sizes;
  String? category;

  ProductData.fromDocument(DocumentSnapshot snapshot) {
    id = snapshot.id;
    title = snapshot.get('title');

    description = snapshot.get('description');
    price = snapshot.get('price').toInt();
    images = snapshot.get('images');
    sizes = snapshot.get('sizes');
  }

  Map<String, dynamic> toResumeMap() {
    return {
      "title": title,
      "description": description,
      "price": price,
    };
  }
}
