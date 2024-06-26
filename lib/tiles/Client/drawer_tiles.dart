import 'package:flutter/material.dart';
import 'package:sportscbr/screens/Client/cart_screen.dart';
import 'package:sportscbr/screens/Client/profile_screen.dart';
import 'package:sportscbr/tabs/Client/home_tab.dart';
import 'package:sportscbr/tabs/Client/orders_tab.dart';
import 'package:sportscbr/tabs/Client/places_tab.dart';
import 'package:sportscbr/tabs/Client/products_tab.dart';

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
          switch (page) {
            case 0:
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => HomeTab(),
              ));
              break;
            case 1:
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ProductsTab(),
              ));
              break;
            case 2:
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const PlacesTab(),
              ));
              break;
            case 3:
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const OrdersTab(),
              ));
              break;
            case 4:
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const CartScreen(),
              ));
            case 5:
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ));
              break;
            default:
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
