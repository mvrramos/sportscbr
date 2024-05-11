import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserBloc extends BlocBase {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? firebaseUser;
  Map<String, dynamic> userData = {};

  final _userController = StreamController<User?>.broadcast();
  Stream<User?> get userStream => _userController.stream;

  final _isLoadingController = StreamController<bool>.broadcast();
  Stream<bool> isLoadingStream() => _isLoadingController.stream;

  UserBloc() {
    _loadCurrentUser();
  }

  Future<void> signUp({
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

      await _saveUserData(userData);

      onSuccess();
    } catch (error) {
      onFail();
    }

    _isLoadingController.sink.add(false);
  }

  void signIn({required String email, required String pass, required VoidCallback onSuccess, required VoidCallback onFail}) async {
    _isLoadingController.sink.add(true);

    _auth.signInWithEmailAndPassword(email: email, password: pass).then((userCredential) async {
      firebaseUser = userCredential.user!;

      await _loadCurrentUser();

      onSuccess();
      _isLoadingController.sink.add(false);
    }).catchError((e) {
      onFail();
      _isLoadingController.sink.add(false);
    });
  }

  void signOut() async {
    await _auth.signOut();

    userData = {};
    firebaseUser = null;

    _userController.sink.add(null);
  }

  bool isLoggedIn() {
    return firebaseUser != null;
  }

  void recoverPass(String email) {
    _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    this.userData = userData;

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(firebaseUser!.uid);

    await userDocRef.set(userData);
  }

  Future<void> _loadCurrentUser() async {
    firebaseUser ??= _auth.currentUser;

    if (firebaseUser != null) {
      DocumentSnapshot docUser = await FirebaseFirestore.instance.collection('users').doc(firebaseUser!.uid).get();

      if (docUser.exists) {
        userData = docUser.data() as Map<String, dynamic>;
      }
    }

    _userController.sink.add(firebaseUser);
  }

  @override
  void dispose() {
    _userController.close();
    _isLoadingController.close();
    super.dispose();
  }
}
