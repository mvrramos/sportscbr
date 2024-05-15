import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class SignUpBloc extends BlocBase {
  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _confirmPasswordController = BehaviorSubject<String>();
  final _nameController = BehaviorSubject<String>();
  final _addressController = BehaviorSubject<String>();

  // Streams expostas para os campos de entrada
  Stream<String> get outEmail => _emailController.stream.transform(validateEmail);
  Stream<String> get outPassword => _passwordController.stream.transform(validatePassword);
  Stream<String> get outConfirmPassword => _confirmPasswordController.stream.transform(validateConfirmPassword());
  Stream<String> get outName => _nameController.stream.transform(validateName);
  Stream<String> get outAddress => _addressController.stream.transform(validateAddress);
  Stream<bool> get outSubmitValue => Rx.combineLatest5(outEmail, outPassword, outConfirmPassword, outName, outAddress, (email, password, confirmPassword, name, address) => true);

  // Funções para inserir dados nos controllers
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;
  Function(String) get changeConfirmPassword => _confirmPasswordController.sink.add;
  Function(String) get changeName => _nameController.sink.add;
  Function(String) get changeAddress => _addressController.sink.add;

  // Validação do endereço
  final validateAddress = StreamTransformer<String, String>.fromHandlers(
    handleData: (address, sink) {
      if (address.length > 4) {
        sink.add(address);
      } else {
        sink.addError("Insira um endereço válido");
      }
    },
  );

  // Validação do nome
  final validateName = StreamTransformer<String, String>.fromHandlers(
    handleData: (name, sink) {
      if (name.length > 2) {
        sink.add(name);
      } else {
        sink.addError("Insira um nome válido");
      }
    },
  );

  // Validação do email
  final validateEmail = StreamTransformer<String, String>.fromHandlers(
    handleData: (email, sink) {
      if (email.contains('@') && email.length > 4) {
        sink.add(email);
      } else {
        sink.addError('Email inválido');
      }
    },
  );

  // Validação da senha
  final validatePassword = StreamTransformer<String, String>.fromHandlers(
    handleData: (password, sink) {
      if (password.length >= 6) {
        sink.add(password);
      } else {
        sink.addError('A senha deve ter pelo menos 6 caracteres');
      }
    },
  );

  // Validação da confirmação de senha
  StreamTransformer<String, String> validateConfirmPassword() {
    return StreamTransformer<String, String>.fromHandlers(
      handleData: (confirmPassword, sink) {
        if (confirmPassword == _passwordController.value) {
          sink.add(confirmPassword);
        } else {
          sink.addError('As senhas não coincidem');
        }
      },
    );
  }

  // Função para registrar o usuário no Firebase Authentication
  Future<void> submit(BuildContext context) async {
    final email = _emailController.value;
    final password = _passwordController.value;
    final name = _nameController.value;
    final address = _addressController.value;

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        // Usuário registrado com sucesso
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'address': address,
          'email': email,
          'name': name,
        });

        // Exibir diálogo de sucesso
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Sucesso'),
              content: const Text('Usuário registrado com sucesso!'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Tratar erros durante o registro
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erro'),
            content: Text('Erro ao registrar usuário: $e'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _nameController.close();
    _emailController.close();
    _passwordController.close();
    _confirmPasswordController.close();
    super.dispose();
  }
}
