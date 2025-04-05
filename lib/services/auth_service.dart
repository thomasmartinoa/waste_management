import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wastemanagement/services/authcheck.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Signup function (Returns UserCredential)
  Future<UserCredential?> signup({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Show success message
      Fluttertoast.showToast(
        msg: "Signup successful!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        textColor: Colors.white,
        fontSize: 14,
      );

      return userCredential; // Return UserCredential on success
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with this email';
      } else {
        message = e.message ?? 'An unknown error occurred';
      }

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        textColor: Colors.white,
        fontSize: 14,
      );

      return null; // Return null if registration fails
    }
  }

  // Signin function
  Future<void> signin({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password';
      } else {
        message = e.message ?? 'An unknown error occurred';
      }

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14,
      );
    }
  }

  // Sign out function
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    Fluttertoast.showToast(
      msg: "Signed out successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color.fromARGB(137, 0, 0, 0),
      textColor: Colors.white,
      fontSize: 14,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthCheck()), // Redirect to auth check
    );
  }
}


// google sign inset

Future<void> signInWithGoogle() async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    
    if (googleUser == null) {
      // User canceled the sign-in process
      return;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    // Show success message
    Fluttertoast.showToast(
      msg: "Login Successful!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );

  } catch (e) {
    debugPrint("Google Sign-In Error: $e");

    // Show error message
    Fluttertoast.showToast(
      msg: "Login Failed: ${e.toString()}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}