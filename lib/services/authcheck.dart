import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wastemanagement/screens/HomeScreen.dart';
import 'package:wastemanagement/screens/Signup_screen.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final user = snapshot.data;
            if (user == null) {
              return SignupScreen(); // Redirect to sign-in screen if no user is logged in
            } else {
              return Homescreen(); // Redirect to home screen if user is logged in
            }
          }
          return Center(
            child: CircularProgressIndicator(), // Show loading spinner while checking auth state
          );
        },
      ),
    );
  }
}
