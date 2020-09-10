import 'package:finesse_nation/Network.dart';
import 'package:finesse_nation/Styles.dart';
import 'package:finesse_nation/login/flutter_login.dart';
import 'package:finesse_nation/main.dart';
import 'package:flutter/material.dart';

/// Handles login and registration.
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'FINESSE',
      theme: LoginTheme(
        primaryColor: primaryBackground,
        accentColor: primaryBackground,
        cardTheme: CardTheme(color: primaryHighlight),
        buttonTheme: LoginButtonTheme(
          splashColor: Colors.grey[800],
        ),
      ),
      emailValidator: validateEmail,
      passwordValidator: validatePassword,
      onLogin: authUser,
      onSignup: createUser,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => HomePage(),
        ));
      },
      onRecoverPassword: recoverPassword,
      messages: LoginMessages(
          recoverPasswordDescription:
              'Email will be sent with a link to reset your password.'),
    );
  }
}
