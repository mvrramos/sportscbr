import 'dart:async';
import 'dart:ui';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

enum LoginState {
  idle,
  loading,
  success,
  fail,
}

mixin LoginValidator {
  final validateEmail = StreamTransformer<String, String>.fromHandlers(handleData: (email, sink) {
    if (email.contains("@") && email.length > 6) {
      sink.add(email);
    } else {
      sink.addError("Email inválido");
    }
  });

  final validatePassword = StreamTransformer<String, String>.fromHandlers(handleData: (password, sink) {
    if (password.length >= 6) {
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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? firebaseUser;
  User? get currentUser => _auth.currentUser;
  Map<String, dynamic> userData = {};

  final _userController = StreamController<User?>();
  Stream<User?> get userStream => _userController.stream;

  final _isLoadingController = StreamController<bool>.broadcast();
  Stream<bool> get isLoadingStream => _isLoadingController.stream;

  final _ordersController = BehaviorSubject<List<DocumentSnapshot>>();
  Stream<List<DocumentSnapshot>> get ordersStream => _ordersController.stream;

  Stream<String> get outEmail => _emailController.stream.transform(validateEmail);
  Stream<String> get outPassword => _passwordController.stream.transform(validatePassword);
  Stream<LoginState> get outState => _stateController.stream;
  Stream<bool> get outSubmitValue => Rx.combineLatest2(outEmail, outPassword, (a, b) => true);

  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;

  late StreamSubscription<User?> _streamSubscription;

  LoginBloc() {
    _loadCurrentUser();
    _loadOrders();

    _streamSubscription = _auth.authStateChanges().listen((user) async {
      firebaseUser ??= _auth.currentUser;

      if (firebaseUser != null) {
        if (userData["name"] == null) {
          DocumentSnapshot docUser = await FirebaseFirestore.instance.collection('users').doc(firebaseUser!.uid).get();
          userData = docUser.data() as Map<String, dynamic>;
        }
      } else {
        _stateController.add(LoginState.idle);
      }
    });
  }

  void submit() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.value,
        password: _passwordController.value,
      );
    } catch (e) {
      if (e == 'user-not-found') {
        print('No user found for that email.');
      } else if (e == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  Future<bool> verifyPrivileges(User user) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('admins').doc(user.uid).get();

      return snapshot.exists;
    } catch (error) {
      print("Erro ao verificar privilégios: $error");
      return false;
    }
  }

  void recoverPassword() {
    final email = _emailController.value;
    _auth.sendPasswordResetEmail(email: email);
  }

  void signUp({
    required Map<String, dynamic> userData,
    required String pass,
    required VoidCallback onSuccess,
    required VoidCallback onFail,
  }) async {
    _isLoadingController.sink.add(true);

    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: userData['email'],
        password: pass,
      );

      firebaseUser = userCredential.user!;

      _saveUserData(userData);

      onSuccess();
    } catch (error) {
      onFail();
    } finally {
      _isLoadingController.sink.add(false);
    }
  }

  void signIn({required String email, required String pass, required VoidCallback onSuccess, required VoidCallback onFail}) async {
    _isLoadingController.sink.add(true);

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: pass);
      firebaseUser = userCredential.user!;

      _loadCurrentUser();

      onSuccess();
    } catch (e) {
      onFail();
    } finally {
      _isLoadingController.sink.add(false);
    }
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    userData = {};
    firebaseUser = null;
    _ordersController.add([]);
  }

  bool isLoggedIn() {
    return firebaseUser != null;
  }

  void _saveUserData(Map<String, dynamic> userData) async {
    this.userData = userData;
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(firebaseUser!.uid);
    await userDocRef.set(userData);
  }

  void _loadCurrentUser() async {
    firebaseUser ??= _auth.currentUser;

    if (firebaseUser != null) {
      if (userData["name"] == null) {
        DocumentSnapshot docUser = await FirebaseFirestore.instance.collection('users').doc(firebaseUser!.uid).get();
        userData = docUser.data() as Map<String, dynamic>;
      }
      _userController.add(firebaseUser);
    }
  }

  void _loadOrders() async {
    if (currentUser != null) {
      final ordersSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).collection('orders').get();

      _ordersController.add(ordersSnapshot.docs);
    }
  }

  void deleteOrder(String orderId) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();
    // Notifique os ouvintes sobre a mudança se necessário
    notifyListeners();
  }

  @override
  void dispose() {
    // _emailController.close();
    // _passwordController.close();
    _stateController.close();
    _streamSubscription.cancel();
    _ordersController.close();
    // _isLoadingController.close();
    super.dispose();
  }
}
