// ignore_for_file: avoid_print, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:sportscbr/blocs/Client/login_bloc.dart';
import 'package:sportscbr/screens/login_screen.dart';
import 'package:sportscbr/tiles/Client/drawer_tiles.dart';

class CustomDrawer extends StatelessWidget {
  final PageController pageController;
  final LoginBloc _loginBloc = LoginBloc();

  CustomDrawer(this.pageController, {super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Stack(
        children: [
          _buildDrawerBack(),
          _buildDrawerContent(context),
        ],
      ),
    );
  }

  Widget _buildDrawerBack() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
    );
  }

  Widget _buildDrawerContent(BuildContext context) {
    return ListView(
      controller: pageController,
      padding: const EdgeInsets.only(left: 18, top: 16),
      children: [
        _buildDrawerHeader(context),
        const Divider(),
        DrawerTile(Icons.home, "Início", pageController, 0),
        DrawerTile(Icons.checkroom, "Produtos", pageController, 1),
        DrawerTile(Icons.location_on, "Loja", pageController, 2),
        DrawerTile(Icons.featured_play_list, "Meus pedidos", pageController, 3),
      ],
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
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
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Positioned(
            left: 0.0,
            bottom: 0.0,
            child: StreamBuilder<LoginState>(
              stream: _loginBloc.outState,
              builder: (context, snapshot) {
                final isLoggedIn = _loginBloc.isLoggedIn();
                final userName = _loginBloc.userData['name'] ?? '';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Olá, ${isLoggedIn ? userName : ''}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      child: Text(
                        isLoggedIn ? "Sair" : "Entre ou cadastre-se >",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        if (isLoggedIn) {
                          _loginBloc.signOut();
                        } else {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
