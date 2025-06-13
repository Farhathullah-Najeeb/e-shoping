import 'package:flutter/material.dart';

class LoginProvider extends ChangeNotifier {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _emailError;
  String? _passwordError;

  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  bool get obscurePassword => _obscurePassword;
  bool get rememberMe => _rememberMe;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleRememberMe(bool? value) {
    _rememberMe = value ?? false;
    notifyListeners();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      _emailError = 'Email is required';
      return _emailError;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      _emailError = 'Please enter a valid email address';
      return _emailError;
    }
    _emailError = null;
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      _passwordError = 'Password is required';
      return _passwordError;
    }
    if (value.length < 6) {
      _passwordError = 'Password must be at least 6 characters';
      return _passwordError;
    }
    _passwordError = null;
    return null;
  }

  void clearErrors() {
    _emailError = null;
    _passwordError = null;
    notifyListeners();
  }

  void resetForm() {
    _emailController.clear();
    _passwordController.clear();
    _obscurePassword = true;
    _rememberMe = false;
    clearErrors();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
