import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class AdminUsersBloc extends BlocBase {
  final _usersController = BehaviorSubject<List<Map<String, dynamic>>>();

  Stream<List<Map<String, dynamic>>> get outUsers => _usersController.stream;

  final Map<String, Map<String, dynamic>> _users = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AdminUsersBloc() {
    _addUsersListener();
  }

  void _addUsersListener() {
    _firestore.collection('users').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        String uid = change.doc.id;

        switch (change.type) {
          case DocumentChangeType.added:
            _users[uid] = change.doc.data() as Map<String, dynamic>;
            _subscribeToOrders(uid);
            break;
          case DocumentChangeType.modified:
            _users[uid]?.addAll(change.doc.data() as Map<String, dynamic>);
            _usersController.add(_users.values.toList());
            break;
          case DocumentChangeType.removed:
            _users.remove(uid);
            _unSubscriptionToOrders(uid);
            _usersController.add(_users.values.toList());
            break;
        }
      }
    });
  }

  void _subscribeToOrders(uid) {
    _users[uid]?['subscription'] = _firestore.collection('users').doc(uid).collection('orders').snapshots().listen((orders) async {
      int numOrders = orders.docs.length;
      double totalPrice = 0.0;

      for (DocumentSnapshot d in orders.docs) {
        DocumentSnapshot order = await _firestore.collection('orders').doc(d.id).get();

        totalPrice += order['totalPrice'];
      }
      _users[uid]?.addAll({
        'totalPrice': totalPrice,
        'orders': numOrders,
      });
      _usersController.add(_users.values.toList());
    });
  }

  void _unSubscriptionToOrders(uid) {
    _users[uid]?['subscription'].cancel();
  }

  void onChangedSearch(String search) {
    if (search.trim().isEmpty) {
      _usersController.add(_users.values.toList());
    } else {
      _usersController.add(_filter(search.trim()));
    }
  }

  List<Map<String, dynamic>> _filter(String search) {
    List<Map<String, dynamic>> filteredUsers = List.from(_users.values.toList());
    filteredUsers.retainWhere((user) {
      return user['name'].toString().toUpperCase().contains(search.toUpperCase());
    });
    return filteredUsers;
  }

  Map<String, dynamic>? getUser(String uid) {
    return _users[uid];
  }

  void logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Erro ao fazer logout: $e");
    }
  }

  @override
  void dispose() {
    _usersController.close();
    super.dispose();
  }
}
