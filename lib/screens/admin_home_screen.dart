import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:sportscbr/blocs/admin_orders_bloc.dart';
import 'package:sportscbr/blocs/admin_users_bloc.dart';
import 'package:sportscbr/screens/login_screen.dart';
import 'package:sportscbr/tabs/admin_clientes_tab.dart';
import 'package:sportscbr/tabs/admin_orders_tab.dart';
import 'package:sportscbr/tabs/admin_products_tab.dart';
import 'package:sportscbr/widgets/admin_edit_category.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  PageController _pageController = PageController();
  int _page = 0;
  late AdminUsersBloc _adminUsersBloc;
  late AdminOrdersBloc _adminOrdersBloc;

  @override
  void initState() {
    super.initState();
    _adminUsersBloc = AdminUsersBloc();
    _adminOrdersBloc = AdminOrdersBloc();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: const Color.fromARGB(100, 73, 5, 182),
          primaryColor: Colors.white,
          textTheme: Theme.of(context).textTheme.copyWith(
                bodySmall: const TextStyle(color: Colors.white),
              ),
        ),
        child: BottomNavigationBar(
          currentIndex: _page,
          onTap: (p) {
            _pageController.animateToPage(p, duration: const Duration(milliseconds: 500), curve: Curves.ease);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                color: Colors.white,
              ),
              label: "Usuários",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.shopping_cart,
                color: Colors.white,
              ),
              label: "Pedidos",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.list,
                color: Colors.white,
              ),
              label: "Produtos",
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: BlocProvider(
          blocs: [
            Bloc((_) => _adminUsersBloc),
            Bloc((_) => _adminOrdersBloc),
          ],
          dependencies: const [],
          child: PageView(
            controller: _pageController,
            onPageChanged: (p) {
              setState(() {
                _page = p;
              });
            },
            children: const [
              AdminClientsTab(),
              AdminOrdersTab(),
              AdminProductsTab()
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloating(),
    );
  }

  Widget _buildFloating() {
    switch (_page) {
      case 0:
        return SpeedDial(
          backgroundColor: Colors.white,
          overlayOpacity: 0.4,
          overlayColor: Colors.black,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.check, color: Color.fromARGB(100, 73, 5, 182)),
              backgroundColor: Colors.white,
              label: "Confirmar logoff",
              labelStyle: const TextStyle(fontSize: 14),
              onTap: () {
                _adminUsersBloc.logout();
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
            ),
          ],
          child: const Icon(Icons.power_settings_new_outlined),
        );

      case 1:
        return SpeedDial(
          backgroundColor: Colors.white,
          overlayOpacity: 0.4,
          overlayColor: Colors.black,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.arrow_downward, color: Color.fromARGB(100, 73, 5, 182)),
              backgroundColor: Colors.white,
              label: "Concluídos abaixo",
              labelStyle: const TextStyle(fontSize: 14),
              onTap: () {
                _adminOrdersBloc.setOrderCriteria(SortCriteria.READY_LAST);
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.arrow_upward, color: Color.fromARGB(100, 73, 5, 182)),
              backgroundColor: Colors.white,
              label: "Concluídos acima",
              labelStyle: const TextStyle(fontSize: 14),
              onTap: () {
                _adminOrdersBloc.setOrderCriteria(SortCriteria.READY_FIRST);
              },
            ),
          ],
          child: const Icon(Icons.sort),
        );
      case 2:
        return FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const AdminEditCategoryDialog(),
            );
          },
          backgroundColor: Colors.white,
          child: const Icon(Icons.add),
        );
      default:
        return Container(); // Retorno de widget vazio para outros valores de _page
    }
  }
}
