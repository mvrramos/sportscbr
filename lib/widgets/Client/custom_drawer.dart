import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportscbr/blocs/Client/login_bloc.dart';
import 'package:sportscbr/screens/login_screen.dart';
import 'package:sportscbr/tiles/Client/drawer_tiles.dart';

class CustomDrawer extends StatelessWidget {
  final PageController pageController;

  const CustomDrawer(this.pageController, {super.key});

  @override
  Widget build(BuildContext context) {
    final loginBloc = Provider.of<LoginBloc>(context);

    return Drawer(
      child: Stack(
        children: [
          _buildDrawerBack(),
          _buildDrawerContent(context, loginBloc),
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

  Widget _buildDrawerContent(BuildContext context, LoginBloc loginBloc) {
    return ListView(
      controller: pageController,
      padding: const EdgeInsets.only(left: 18, top: 16),
      children: [
        _buildDrawerHeader(context, loginBloc),
        const Divider(),
        DrawerTile(Icons.home, "Início", pageController, 0),
        DrawerTile(Icons.checkroom, "Produtos", pageController, 1),
        DrawerTile(Icons.location_on, "Loja", pageController, 2),
        DrawerTile(Icons.featured_play_list, "Meus pedidos", pageController, 3),
        DrawerTile(Icons.shopping_cart, "Meu carrinho", pageController, 4),
        const Divider(),
        StreamBuilder<LoginState>(
          stream: loginBloc.outState,
          builder: (context, snapshot) {
            if (loginBloc.isLoggedIn()) {
              return DrawerTile(Icons.settings, "Meu perfil", pageController, 5);
            } else {
              return const SizedBox.shrink(); // Retorna um widget vazio se o usuário não estiver logado
            }
          },
        ),
      ],
    );
  }

  Widget _buildDrawerHeader(BuildContext context, LoginBloc loginBloc) {
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
              stream: loginBloc.outState,
              builder: (context, snapshot) {
                final isLoggedIn = loginBloc.isLoggedIn();
                final userName = loginBloc.userData['name'] ?? '';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Olá, $userName",
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
                          loginBloc.signOut();
                        } else {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
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
