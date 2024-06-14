import 'package:flutter/material.dart';
import 'package:sportscbr/tabs/Client/home_tab.dart';
import 'package:sportscbr/tabs/Client/orders_tab.dart';
import 'package:sportscbr/tabs/Client/places_tab.dart';
import 'package:sportscbr/tabs/Client/products_tab.dart';
import 'package:sportscbr/widgets/Client/cart_button.dart';
import 'package:sportscbr/widgets/Client/custom_drawer.dart';

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
            title: const Text("Produtos"),
            centerTitle: true,
          ),
          drawer: CustomDrawer(_pageController),
          body: const ProductsTab(),
        ),
        Scaffold(
          appBar: AppBar(
            title: const Text("Lojas"),
            centerTitle: true,
          ),
          drawer: CustomDrawer(_pageController),
          body: const PlacesTab(),
        ),
        Scaffold(
          appBar: AppBar(
            title: const Text("Meus Pedidos"),
            centerTitle: true,
          ),
          drawer: CustomDrawer(_pageController),
          body: const OrdersTab(),
        )
      ],
    );
  }
}
