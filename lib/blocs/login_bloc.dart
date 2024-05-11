// ignore_for_file: body_might_complete_normally_catch_error

import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

mixin LoginValidator {
  final validateEmail = StreamTransformer<String, String>.fromHandlers(handleData: (email, sink) {
    if (email.contains("@") && email.length > 6) {
      sink.add(email);
    } else {
      sink.addError("Email inváldo");
    }
  });

  final validatePassword = StreamTransformer<String, String>.fromHandlers(handleData: (password, sink) {
    if (password.length > 5) {
      sink.add(password);
    } else {
      sink.addError("A senha deve ter pelo menos 6 caracteres");
    }
  });
}

class LoginBloc extends BlocBase with LoginValidator {
  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _stateController = BehaviorSubject<LoginState>();

  Stream<String> get outEmail => _emailController.stream.transform(validateEmail);
  Stream<String> get outPassword => _passwordController.stream.transform(validatePassword);
  Stream<LoginState> get outState => _stateController.stream;
  Stream<bool> get outSubmitValue => Rx.combineLatest2(outEmail, outPassword, (a, b) => true);

  late StreamSubscription _streamSubscription;

  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;

  LoginBloc() {
    _streamSubscription = FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        if (await verifyPrivileges(user)) {
          _stateController.add(LoginState.success);
        } else {
          FirebaseAuth.instance.signOut();
          _stateController.add(LoginState.fail);
        }
      } else {
        _stateController.add(LoginState.idle);
      }
    });
  }

  Future<void> submit() async {
    final email = _emailController.value;
    final password = _passwordController.value;

    _stateController.add(LoginState.loading);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _stateController.add(LoginState.success);
    } catch (error) {
      _stateController.add(LoginState.fail);
    }
  }

  Future<bool> verifyPrivileges(user) async {
    return await FirebaseFirestore.instance.collection('admins').doc(user.uid).get().then((doc) {
      return true;
    }).catchError((error) {
      return false;
    });
  }

  void recoverPassword() {
    final email = _emailController.value;

    FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  @override
  void dispose() {
    _emailController.close();
    _passwordController.close();
    _stateController.close();
    _streamSubscription.cancel();
    super.dispose();
  }
}

enum LoginState {
  idle,
  loading,
  success,
  fail,
}
