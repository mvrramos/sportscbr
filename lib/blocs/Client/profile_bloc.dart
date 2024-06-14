import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class ProfileBloc {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _nameController = BehaviorSubject<String>();
  final _emailController = BehaviorSubject<String>();
  final _addressController = BehaviorSubject<String>();
  final _loadingController = BehaviorSubject<bool>();

  Stream<String> get outName => _nameController.stream;
  Stream<String> get outEmail => _emailController.stream;
  Stream<String> get outAddress => _addressController.stream;
  Stream<bool> get outLoading => _loadingController.stream;

  Function(String) get changeName => _nameController.sink.add;
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changeAddress => _addressController.sink.add;

  void loadUserData() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
    if (userDoc.exists) {
      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
      _nameController.add(data?['name'] ?? '');
      _emailController.add(currentUser.email ?? '');
      _addressController.add(data?['address'] ?? '');
    }
  }

  Future<void> saveProfile() async {
    _loadingController.add(true);
    User currentUser = _auth.currentUser!;
    try {
      await _firestore.collection('users').doc(currentUser.uid).set({
        'name': _nameController.value,
        'address': _addressController.value,
      }, SetOptions(merge: true));

      if (currentUser.email != _emailController.value) {
        await currentUser.updateEmail(_emailController.value);
      }
      _loadingController.add(false);
    } catch (e) {
      _loadingController.add(false);
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    _loadingController.add(true);
    User currentUser = _auth.currentUser!;
    try {
      await _firestore.collection('users').doc(currentUser.uid).delete();
      await currentUser.delete();
      _loadingController.add(false);
    } catch (e) {
      _loadingController.add(false);
      rethrow;
    }
  }

  void dispose() {
    _nameController.close();
    _emailController.close();
    _addressController.close();
    _loadingController.close();
  }
}
