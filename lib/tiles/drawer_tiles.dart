import 'package:flutter/material.dart';
import 'package:sportscbr/screens/cart_screen.dart';
import 'package:sportscbr/tabs/home_tab.dart';
import 'package:sportscbr/tabs/orders_tab.dart';
import 'package:sportscbr/tabs/places_tab.dart';
import 'package:sportscbr/tabs/products_tab.dart';

class DrawerTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final PageController controller;
  final int page;

  const DrawerTile(this.icon, this.text, this.controller, this.page, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          if (page == 0) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => HomeTab(),
            ));
          }
          if (page == 1) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const ProductsTab(),
            ));
          }
          if (page == 2) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const PlacesTab(),
            ));
          }
          if (page == 3) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const OrdersTab(),
            ));
          }
          if (page == 4) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const CartScreen(),
            ));
          }
        },
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: Colors.black,
              ),
              const SizedBox(width: 32),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
