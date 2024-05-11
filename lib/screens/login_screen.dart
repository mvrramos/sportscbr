import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sportscbr/blocs/login_bloc.dart';
import 'package:sportscbr/screens/admin_home_screen.dart';
import 'package:sportscbr/screens/home_screen.dart';
import 'package:sportscbr/screens/recover_password.dart';
import 'package:sportscbr/screens/signup_screen.dart';
import 'package:sportscbr/widgets/input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginBloc = LoginBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(100, 73, 5, 182),
        title: TextButton(
          child: const Text(
            "Realizar cadastro",
            style: TextStyle(fontSize: 16),
          ),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const SignUpScreen(),
            ));
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: StreamBuilder<LoginState>(
        stream: _loginBloc.outState,
        initialData: LoginState.loading,
        builder: (context, snapshot) {
          switch (snapshot.data) {
            case LoginState.loading:
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(
                    Color.fromARGB(100, 73, 5, 182),
                  ),
                ),
              );
            case LoginState.fail:
            case LoginState.success:
            case LoginState.idle:
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
                                      ? () {
                                          // Obter usuário atualmente autenticado
                                          User? currentUser = FirebaseAuth.instance.currentUser;
                                          if (currentUser != null) {
                                            // Ver previlegios
                                            _loginBloc.verifyPrivileges(currentUser).then((uid) {
                                              if (uid == currentUser.uid.toString()) {
                                                // Redirecionar para a tela de administração
                                                Navigator.of(context).pushReplacement(
                                                  MaterialPageRoute(
                                                    builder: (context) => const AdminHomeScreen(),
                                                  ),
                                                );
                                              }
                                            });
                                          } else {
                                            // Redirecionar para a tela inicial
                                            Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                                builder: (context) => HomeScreen(),
                                              ),
                                            );
                                          }
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(100, 73, 5, 182)),
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
                              child: const Text("Recuperar senha"))
                        ],
                      ),
                    ),
                  ),
                ],
              );
            default:
              return Container(); // Adicionando um caso padrão
          }
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loginBloc.outState.listen((state) {
      switch (state) {
        case LoginState.success:
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const AdminHomeScreen(),
          ));
          break;
        case LoginState.fail:
          showDialog(
            context: context,
            builder: (context) => const AlertDialog(
              title: Text("Erro ao fazer login"),
              content: Text("Você não possui os privilégios necessários"),
            ),
          );
          break;
        case LoginState.loading:
        case LoginState.idle:
      }
    });
  }

  @override
  void dispose() {
    _loginBloc.dispose();
    super.dispose();
  }
}
