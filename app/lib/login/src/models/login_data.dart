import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

class LoginData {
  final String email;
  final String password;

  LoginData({
    @required this.email,
    @required this.password,
  });

  @override
  String toString() {
    return '$runtimeType($email, $password)';
  }

  bool operator ==(Object other) {
    if (other is LoginData) {
      return email == other.email && password == other.password;
    }
    return false;
  }

  int get hashCode => hash2(email, password);

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["emailId"] = email;
    map["password"] = password;

    return map;
  }
}
