import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sportscbr/blocs/product_bloc.dart';
import 'package:sportscbr/screens/product_screen.dart';

class ProductTile extends StatelessWidget {
  final String type;
  final ProductData product;

  const ProductTile(this.type, this.product, {super.key, required CachedNetworkImage image});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProductScreen(product)));
      },
      child: Card(
        child: type == "grid"
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 0.8,
                    child: Image.network(
                      product.images[0],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            product.title,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            "R\$ ${product.price}",
                            style: const TextStyle(color: Colors.black, fontSize: 11.5, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              )
            : Row(
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: Image.network(
                      product.images[0],
                      fit: BoxFit.cover,
                      height: 250.0,
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            product.title,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            "R\$ ${product.price}",
                            style: const TextStyle(color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
