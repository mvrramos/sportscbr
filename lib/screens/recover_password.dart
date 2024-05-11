import 'package:flutter/material.dart';
import 'package:sportscbr/blocs/login_bloc.dart';
import 'package:sportscbr/widgets/input_field.dart';

class RecoverPassword extends StatefulWidget {
  const RecoverPassword({super.key});

  @override
  State<RecoverPassword> createState() => _RecoverPasswordState();
}

class _RecoverPasswordState extends State<RecoverPassword> {
  final _loginBloc = LoginBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(100, 73, 5, 182),
        foregroundColor: Colors.white,
        title: const Text(
          "Recuperar senha",
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: StreamBuilder<String>(
          stream: _loginBloc.outEmail,
          builder: (context, snapshot) {
            return Stack(
              alignment: Alignment.center,
              children: [
                SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 45),
                        const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 160,
                        ),
                        InputField(Icons.person, "E-mail", false, _loginBloc.outEmail, _loginBloc.changeEmail),
                        const SizedBox(height: 40),
                        StreamBuilder(
                          stream: _loginBloc.outEmail,
                          builder: (context, snapshot) {
                            return SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: snapshot.hasData
                                    ? () {
                                        _loginBloc.recoverPassword();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Verifique o seu e-mail"),
                                            duration: Duration(seconds: 3),
                                            backgroundColor: Color.fromARGB(100, 73, 5, 182),
                                          ),
                                        );
                                        Navigator.of(context).pop();
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(100, 73, 5, 182)),
                                child: const Text(
                                  "Recuperar senha",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                )
              ],
            );
          }),
    );
  }
}
