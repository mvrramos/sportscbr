// ignore_for_file: constant_identifier_names

import 'dart:core';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

enum SortCriteria {
  READY_FIRST,
  READY_LAST
}

class AdminOrdersBloc extends BlocBase {
  final _adminOrdersController = BehaviorSubject<List>();
  Stream<List> get outOrders => _adminOrdersController.stream;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<DocumentSnapshot> _adminOrders = [];
  SortCriteria _criteria = SortCriteria.READY_FIRST;

  AdminOrdersBloc() {
    _addAdminOrdersListener();
  }

  void _addAdminOrdersListener() {
    _firestore.collection('orders').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        String oid = change.doc.id;

        switch (change.type) {
          case DocumentChangeType.added:
            _adminOrders.add(change.doc);
            break;
          case DocumentChangeType.modified:
            _adminOrders.removeWhere((order) => order.id == oid);
            _adminOrders.add(change.doc);
            break;
          case DocumentChangeType.removed:
            _adminOrders.removeWhere((order) => order.id == oid);

            break;
        }
      }
      _sort();
    });
  }

  void setOrderCriteria(SortCriteria criteria) {
    _criteria = criteria;
    _sort();
  }

  void _sort() {
    switch (_criteria) {
      case SortCriteria.READY_FIRST:
        _adminOrders.sort((a, b) {
          int sa = a['status'];
          int sb = b['status'];

          if (sa < sb) {
            return 1;
          } else if (sa > sb) {
            return -1;
          } else {
            return 0;
          }
        });
        break;
      case SortCriteria.READY_LAST:
        _adminOrders.sort((a, b) {
          int sa = a['status'];
          int sb = b['status'];

          if (sa > sb) {
            return 1;
          } else if (sa < sb) {
            return -1;
          } else {
            return 0;
          }
        });
        break;
    }
    _adminOrdersController.add(_adminOrders);
  }

  void addCategoryOfProducts() {}

  @override
  void dispose() {
    _adminOrdersController.close();
    super.dispose();
  }
}
