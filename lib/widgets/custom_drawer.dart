// ignore_for_file: unnecessary_null_comparison

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sportscbr/blocs/user_bloc.dart';
import 'package:sportscbr/screens/login_screen.dart';
import 'package:sportscbr/tiles/drawer_tiles.dart';

class CustomDrawer extends StatelessWidget {
  final PageController pageController;

  const CustomDrawer(this.pageController, {super.key});

  @override
  Widget build(BuildContext context) {
    Widget buildDrawerBack() {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
      );
    }

    return Drawer(
      child: Stack(
        children: [
          buildDrawerBack(),
          ListView(
            controller: pageController,
            padding: const EdgeInsets.only(left: 18, top: 16),
            children: [
              Container(
                margin: const EdgeInsets.only(top: 16, bottom: 8),
                padding: const EdgeInsets.fromLTRB(0, 16, 16, 8),
                height: 170,
                child: Stack(
                  children: [
                    const Positioned(
                      top: 8,
                      left: 0,
                      child: Text(
                        "Sports CBR",
                        style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                    Positioned(
                      left: 0.0,
                      bottom: 0.0,
                      child: StreamBuilder<User?>(
                        stream: BlocProvider.getBloc<UserBloc>().userStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final user = snapshot.data!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Olá, ${user != null ? user.displayName : ""}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                GestureDetector(
                                  child: Text(
                                    user != null ? "Sair" : "Entre ou cadastre-se >",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onTap: () {
                                    if (user == null) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const LoginScreen(),
                                        ),
                                      );
                                    } else {
                                      BlocProvider.getBloc<UserBloc>().signOut();
                                    }
                                  },
                                ),
                              ],
                            );
                          } else {
                            return const SizedBox(); // Return an empty container if snapshot has no data
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              DrawerTile(Icons.home, "Início", pageController, 0),
              DrawerTile(Icons.checkroom, "Produtos", pageController, 1),
              DrawerTile(Icons.location_on, "Loja", pageController, 2),
              DrawerTile(Icons.featured_play_list, "Meus pedidos", pageController, 3),
              DrawerTile(Icons.shopping_cart, "Carrinho", pageController, 4),
            ],
          ),
        ],
      ),
    );
  }
}
