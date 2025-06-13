// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:machine_test_farhathullah/models/user.dart';
import 'package:machine_test_farhathullah/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get errorMessage => _errorMessage;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.login(email, password);
      print('Login successful for: ${_currentUser!.email}');
      _errorMessage = null;
    } catch (e) {
      print('Login failed: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    _errorMessage = null;
    _authService.logout();
    notifyListeners();
  }

  void clearErrorMessage() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
