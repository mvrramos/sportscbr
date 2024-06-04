import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportscbr/blocs/Admin/admin_users_bloc.dart';
import 'package:sportscbr/blocs/Client/cart_bloc.dart';
import 'package:sportscbr/blocs/Client/login_bloc.dart';
import 'package:sportscbr/firebase_options.dart';
import 'package:sportscbr/screens/Client/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final loginBloc = LoginBloc();
    final adminUsersBloc = AdminUsersBloc();

    return MultiProvider(
      providers: [
        StreamProvider<bool>(
          create: (_) => loginBloc.isLoadingStream,
          initialData: false,
          catchError: (_, __) => false,
        ),
        Provider<LoginBloc>(
          create: (_) => loginBloc,
          dispose: (_, loginBloc) => loginBloc.dispose(),
        ),
        Provider<AdminUsersBloc>(
          create: (_) => adminUsersBloc,
          dispose: (_, adminUsersBloc) => adminUsersBloc.dispose(),
        ),
        Provider<CartBloc>(
          create: (_) => CartBloc(loginBloc),
          dispose: (_, cartBloc) => cartBloc.dispose(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
  }
}
