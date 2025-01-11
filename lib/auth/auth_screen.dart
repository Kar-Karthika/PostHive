import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_1/screen/home.dart';

import 'package:instagram_1/screen/login_screen.dart';
import 'package:instagram_1/screen/signup_screen.dart';
import 'package:instagram_1/widgets/navigation.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool a = true;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }
  void _checkAuthState() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
    
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Navigations_Screen()),
        );
      });
    }
  }

  void go() {
    setState(() {
      a = !a;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (a) {
      return LoginScreen(go);
    } else {
      return SigninScreen(go);
    }
  }
}
