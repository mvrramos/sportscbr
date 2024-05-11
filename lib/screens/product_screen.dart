import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportscbr/blocs/cart_bloc.dart';
import 'package:sportscbr/blocs/product_bloc.dart';
import 'package:sportscbr/screens/cart_screen.dart';

class ProductScreen extends StatefulWidget {
  final ProductData product;

  const ProductScreen(this.product, {super.key});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late String sizes = "";

  @override
  Widget build(BuildContext context) {
    final ProductData product = widget.product;
    final cartBloc = Provider.of<CartBloc>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(product.title),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 0.9,
            child: Image.network(
              product.images.first, // Assuming you have at least one image
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            product.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "R\$ ${product.price.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Tamanho",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: product.sizes.length,
              itemBuilder: (context, index) {
                final size = product.sizes[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      sizes = size;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: size == sizes ? Colors.blue : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      size,
                      style: TextStyle(
                        color: size == sizes ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: product.sizes.isNotEmpty
                ? () {
                    if (sizes.isNotEmpty) {
                      final cartProduct = CartProduct(
                        category: product.category,
                        pid: product.id,
                        quantity: 1,
                        sizes: sizes,
                        productData: product,
                      );
                      cartBloc.addCartItem(cartProduct); // Adiciona o produto ao carrinho
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    }
                  }
                : null,
            child: const Text("Adicionar ao carrinho"),
          ),
        ],
      ),
    );
  }
}
