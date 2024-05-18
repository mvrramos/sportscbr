import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sportscbr/blocs/Client/login_bloc.dart';
import 'package:sportscbr/screens/Client/home_screen.dart';
import 'package:sportscbr/screens/Client/recover_password.dart';
import 'package:sportscbr/screens/Client/signup_screen.dart';
import 'package:sportscbr/widgets/Client/input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginBloc = LoginBloc();
  // final _adminUsersBloc = AdminUsersBloc();

  @override
  void initState() {
    super.initState();
    _loginBloc.outState.listen((state) {
      if (state == LoginState.success) {
      } else if (state == LoginState.fail) {
        _showErrorDialog();
      }
    });
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text("Erro ao fazer login"),
        content: Text("Você não possui os privilégios necessários"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(150, 73, 5, 182),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ));
          },
        ),
        actions: [
          TextButton(
            child: const Text(
              "Realizar cadastro",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const SignUpScreen(),
              ));
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: StreamBuilder<LoginState>(
        stream: _loginBloc.outState,
        initialData: LoginState.loading,
        builder: (context, snapshot) {
          if (snapshot.data == LoginState.loading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                  Color.fromARGB(100, 73, 5, 182),
                ),
              ),
            );
          } else {
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(),
                SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 160,
                        ),
                        InputField(Icons.person, "E-mail", false, _loginBloc.outEmail, _loginBloc.changeEmail),
                        InputField(Icons.lock, "Senha", true, _loginBloc.outPassword, _loginBloc.changePassword),
                        const SizedBox(height: 40),
                        StreamBuilder<bool>(
                          stream: _loginBloc.outSubmitValue,
                          builder: (context, snapshot) {
                            return SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: snapshot.hasData
                                    ? () async {
                                        _loginBloc.submit();
                                        String? uid = FirebaseAuth.instance.currentUser?.uid;

                                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                                          builder: (context) => HomeScreen(),
                                        ));
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(100, 73, 5, 182),
                                ),
                                child: const Text(
                                  "Entrar",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const RecoverPassword(),
                            ));
                          },
                          child: const Text("Recuperar senha"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _loginBloc.dispose();
    super.dispose();
  }
}
