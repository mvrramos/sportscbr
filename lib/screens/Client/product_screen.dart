import 'package:flutter/material.dart';
import 'package:sportscbr/blocs/Client/cart_bloc.dart';
import 'package:sportscbr/blocs/Client/login_bloc.dart';
import 'package:sportscbr/datas/cart_product.dart';
import 'package:sportscbr/datas/product_data.dart';
import 'package:sportscbr/screens/Client/cart_screen.dart';
import 'package:sportscbr/screens/login_screen.dart';

class ProductScreen extends StatefulWidget {
  final ProductData product;

  const ProductScreen(this.product, {super.key});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String? size;
  final LoginBloc _loginBloc = LoginBloc();
  late CartBloc _cartBloc;

  @override
  void initState() {
    super.initState();
    _cartBloc = CartBloc(_loginBloc);
  }

  @override
  Widget build(BuildContext context) {
    final ProductData product = widget.product;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.product.title ?? ''),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 250,
            child: Image.network(
              product.images?[0] ?? '',
              fit: BoxFit.scaleDown,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.product.title ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 3,
                ),
                Text(
                  "R\$ ${product.price ?? 0.0}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Tamanho",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                ),
                SizedBox(
                  height: 40,
                  child: GridView(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    scrollDirection: Axis.horizontal,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 4,
                      childAspectRatio: 0.5,
                    ),
                    children: (product.sizes ?? []).map((s) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            size = s;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: s == size ? const Color.fromARGB(150, 73, 5, 182) : Colors.white,
                            borderRadius: const BorderRadius.all(Radius.circular(4)),
                            border: Border.all(
                              color: s == size ? const Color.fromARGB(100, 73, 5, 182) : Colors.white,
                            ),
                          ),
                          width: 40,
                          alignment: Alignment.center,
                          child: Text(
                            s,
                            style: TextStyle(
                              color: s == size ? Colors.white : const Color.fromARGB(150, 73, 5, 182),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(150, 73, 5, 182),
                    ),
                    onPressed: product.sizes != null && product.sizes!.isNotEmpty && size != null
                        ? () {
                            if (_loginBloc.isLoggedIn()) {
                              CartProduct cartProduct = CartProduct();
                              cartProduct.sizes = size!;
                              cartProduct.quantity = 1;
                              cartProduct.pid = widget.product.id;
                              cartProduct.category = widget.product.category;
                              cartProduct.productData = widget.product;

                              _cartBloc.addCartItem(cartProduct);

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const CartScreen(),
                                ),
                              );
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            }
                          }
                        : null,
                    child: Text(
                      _loginBloc.isLoggedIn() ? "Adicionar ao carrinho" : "Entre para comprar",
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Descrição",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
                ),
                Text(
                  widget.product.description ?? '',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
