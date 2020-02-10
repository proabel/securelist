import 'package:flutter/material.dart';

class AppState with ChangeNotifier{
  bool _isAuthenticated = false;
  bool _processing = true;
  bool get auth => _isAuthenticated;
  void setAuth(bool auth){
    _isAuthenticated = auth;
    notifyListeners();
  }
  bool get isProcessing => _processing;
  void setProcessing(bool value){
    _processing = value;
    notifyListeners();
  }
}