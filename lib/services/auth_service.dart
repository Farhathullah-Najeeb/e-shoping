// ignore_for_file: avoid_print

import 'package:machine_test_farhathullah/models/user.dart';

class AuthService {
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));

    // Updated credentials
    if (email == 'mail@gmail.com' && password == 'password') {
      return User(id: '123', username: 'John Doe', email: 'mail@gmail.com');
    } else if (email == 'admin@example.com' && password == 'admin123') {
      return User(
        id: '456',
        username: 'Admin User',
        email: 'admin@example.com',
      );
    } else {
      throw Exception('Invalid username or password');
    }
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(seconds: 1));
    print('User logged out successfully from service.');
  }
}
