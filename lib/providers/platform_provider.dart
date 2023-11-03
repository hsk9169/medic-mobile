import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Global variables for App Platform management
class Platform extends ChangeNotifier {
  String _osDiv = '';
  bool _isLoading = false;
  String _fcmToken = '';
  String _errorMsg = '';
  bool _isError = false;
  dynamic _camera;

  String get osDiv => _osDiv;
  bool get isLoading => _isLoading;
  String get fcmToken => _fcmToken;
  String get errorMsg => _errorMsg;
  bool get isError => _isError;
  dynamic get camera => _camera;

  set osDiv(String value) {
    _osDiv = value;
    notifyListeners();
  }

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set fcmToken(String value) {
    _fcmToken = value;
    notifyListeners();
  }

  set errorMsg(String value) {
    _errorMsg = value;
    notifyListeners();
  }

  set isError(bool value) {
    _isError = value;
    notifyListeners();
  }

  set camera(dynamic value) {
    _camera = value;
    notifyListeners();
  }
}
