// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:scoped_model/scoped_model.dart';

// class UserModel extends Model {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   User? firebaseUser;
//   Map<String, dynamic> userData = {};

//   bool isLoading = false;

//   static UserModel of(BuildContext context) => ScopedModel.of<UserModel>(context);

//   @override
//   void addListener(VoidCallback listener) {
//     super.addListener(listener);
//     _loadCurrentUser();
//   }

//   Future<void> signUp({
//     required Map<String, dynamic> userData,
//     required String pass,
//     required VoidCallback onSuccess,
//     required VoidCallback onFail,
//   }) async {
//     isLoading = true;
//     notifyListeners();

//     try {
//       final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: userData['email'],
//         password: pass,
//       );

//       firebaseUser = userCredential.user!;

//       await _saveUserData(userData);

//       onSuccess();
//     } catch (error) {
//       onFail();
//     }

//     isLoading = false;
//     notifyListeners();
//   }

//   void signIn({required String email, required String pass, required VoidCallback onSucess, required VoidCallback onFail}) async {
//     isLoading = true;
//     notifyListeners();

//     _auth.signInWithEmailAndPassword(email: email, password: pass).then((userCredential) async {
//       firebaseUser = userCredential.user!;

//       await _loadCurrentUser();

//       onSucess();
//       isLoading = false;
//       notifyListeners();
//     }).catchError((e) {
//       onFail();
//       isLoading = false;
//       notifyListeners();
//     });
//   }

//   void signOut() async {
//     await _auth.signOut();

//     userData = {};
//     firebaseUser = null;

//     notifyListeners();
//   }

//   bool isLoggedIn() {
//     return firebaseUser != null;
//   }

//   void recoverPass(String email) {
//     _auth.sendPasswordResetEmail(email: email);
//   }

//   Future<void> _saveUserData(Map<String, dynamic> userData) async {
//     this.userData = userData;

//     final userDocRef = FirebaseFirestore.instance.collection('users').doc(firebaseUser!.uid);

//     await userDocRef.set(userData);
//   }

//   Future<void> _loadCurrentUser() async {
//     firebaseUser ??= _auth.currentUser;

//     if (firebaseUser != null) {
//       if (userData["name"] == null) {
//         DocumentSnapshot docUser = await FirebaseFirestore.instance.collection('users').doc(firebaseUser!.uid).get();
//         userData = docUser.data() as Map<String, dynamic>;
//       }
//     }
//     notifyListeners();
//   }
// }
