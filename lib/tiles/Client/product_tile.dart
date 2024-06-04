import 'package:flutter/material.dart';
import 'package:sportscbr/datas/product_data.dart';
import 'package:sportscbr/screens/Client/product_screen.dart';

class ProductTile extends StatelessWidget {
  const ProductTile(this.type, this.product, {super.key});

  final String type;
  final ProductData product;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          //abrindo tela de produto
          MaterialPageRoute(builder: (context) => ProductScreen(product)),
        );
      },
      child: Card(
        child: type == 'grid'
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 0.8,
                    child: Image.network(
                      product.images![0],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(
                            product.title!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'R\$ ${product.price!}',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Flexible(
                    flex: 1, //proporção do tamanho que quer ocupar
                    child: Image.network(
                      product.images![0],
                      fit: BoxFit.cover,
                      height: 250,
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'R\$ ${product.price?.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
