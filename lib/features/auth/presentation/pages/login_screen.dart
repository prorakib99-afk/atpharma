import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Text(
            'Login Screen',
            style: TextStyle(
              fontSize: 22,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Color(0xFF191E28),
            ),
          ),
        ),
      ),
    );
  }
}
