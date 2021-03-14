import 'package:flutter/material.dart';
import 'package:flutter_app/repository/auth_repository.dart';

class LoginModel extends ChangeNotifier {
  final AuthRepository repository;
  String id = '';
  String password = '';
  String message = '';
  bool showPassword = false;

  LoginModel(this.repository);

  void setMessage(String value) {
    message = value;
    notifyListeners();
  }

  void togglePasswordVisible() {
    showPassword = !showPassword;
    notifyListeners();
  }

  String? emptyValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '入力してください';
    }
    return null;
  }

  Future<bool> auth() async {
    print("id: $id, password: $password");

    var results = await repository.auth();

    return results;
  }
}
