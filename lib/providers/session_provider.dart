import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:medic_app/models/models.dart';

class Session extends ChangeNotifier {
  String _role = '';
  UserDataRes _userData = UserDataRes();
  MedicData _medicData = MedicData();
  bool _isAuthorized = false;

  String get role => _role;
  UserDataRes get userData => _userData;
  MedicData get medicData => _medicData;
  bool get isAuthorized => _isAuthorized;

  set role(String value) {
    _role = value;
  }

  set userData(UserDataRes value) {
    _userData = value;
  }

  set medicData(MedicData value) {
    _medicData = value;
  }

  set isAuthorized(bool value) {
    _isAuthorized = value;
    notifyListeners();
  }
}
