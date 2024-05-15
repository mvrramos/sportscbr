import 'package:flutter/material.dart';
import 'package:sportscbr/widgets/Client/custom_drawer.dart';

class HomeTab extends StatelessWidget {
  final _pageController = PageController();

  HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(_pageController),
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/sportscbr.png')
          ],
        ),
      ),
    );
  }
}
