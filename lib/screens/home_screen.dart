import 'package:flutter/material.dart';
import 'package:sportscbr/tabs/home_tab.dart';
import 'package:sportscbr/tabs/orders_tab.dart';
import 'package:sportscbr/tabs/places_tab.dart';
import 'package:sportscbr/tabs/products_tab.dart';
import 'package:sportscbr/widgets/cart_button.dart';
import 'package:sportscbr/widgets/custom_drawer.dart';

class HomeScreen extends StatelessWidget {
  final _pageController = PageController();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        Scaffold(
          body: HomeTab(),
          drawer: CustomDrawer(_pageController),
          floatingActionButton: const CartButton(),
        ),
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: const Text("Produtos"),
            centerTitle: true,
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
          ),
          drawer: CustomDrawer(_pageController),
          body: const ProductsTab(),
          floatingActionButton: const CartButton(),
        ),
        Scaffold(
          appBar: AppBar(
            title: const Text("Lojas"),
            centerTitle: true,
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
          ),
          body: const PlacesTab(),
          drawer: CustomDrawer(_pageController),
        ),
        Scaffold(
          appBar: AppBar(
            title: const Text("Meus Pedidos"),
            centerTitle: true,
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
          ),
          body: const OrdersTab(),
          drawer: CustomDrawer(_pageController),
        )
      ],
    );
  }
}
