// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:sportscbr/blocs/signup_bloc.dart';
import 'package:sportscbr/widgets/input_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _signUpBloc = SignUpBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(100, 73, 5, 182),
        foregroundColor: Colors.white,
        title: const Text(
          "Realizar cadastro",
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Container(),
          SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InputField(Icons.home_rounded, "Endereço", false, _signUpBloc.outName, _signUpBloc.changeName),
                  InputField(Icons.person, "Nome", false, _signUpBloc.outName, _signUpBloc.changeName),
                  InputField(Icons.email, "Email", false, _signUpBloc.outEmail, _signUpBloc.changeEmail),
                  InputField(Icons.password, "Senha", true, _signUpBloc.outEmail, _signUpBloc.changePassword),
                  InputField(Icons.password, "Confirmação de senha", true, _signUpBloc.outEmail, _signUpBloc.changeConfirmPassword),
                  const SizedBox(height: 30),
                  StreamBuilder(
                    stream: _signUpBloc.outSubmitValue,
                    builder: (context, snapshot) {
                      return SizedBox(
                        height: 50,
                        child: ElevatedButton(
                            onPressed: snapshot.hasData ? _signUpBloc.submit : null,
                            style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(100, 73, 5, 182)),
                            child: const Text(
                              "Cadastrar",
                              style: TextStyle(color: Colors.white),
                            )),
                      );
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
