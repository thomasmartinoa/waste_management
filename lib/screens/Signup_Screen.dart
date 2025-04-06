import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wastemanagement/screens/HomeScreen.dart';
import 'package:wastemanagement/screens/Register_screen.dart';
import 'package:wastemanagement/services/auth_service.dart';
import 'forgotpasswordpage.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> handleGoogleSignIn() async {
    await signInWithGoogle();

    if (FirebaseAuth.instance.currentUser != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homescreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 70, left: 45),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Hello User",
                        style: TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 140, left: 45),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "We are here to help you through waste management.",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 190, top: 180),
                    child: Image.asset("images/recycle-bin 1.png"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 330, left: 40, right: 40),
                    child: Container(
                      height: 490,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.black, width: 1.25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 35),
                            child: Text(
                              "Sign-In to continue",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
                            child: TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: "Enter your Email..",
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.5),
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 25, left: 20, right: 20),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: "Enter your password..",
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.5),
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => forgotpasswordpage()));
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 30),
                            child: Image.asset("images/or123.png"),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: InkWell(
                              onTap: handleGoogleSignIn,
                              borderRadius: BorderRadius.circular(12.5),
                              child: Container(
                                width: double.infinity,
                                height: 55,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.5),
                                  border: Border.all(color: Colors.black, width: 1),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset("images/Vector Group.png", scale: 25),
                                    const SizedBox(width: 12),
                                    const Text("Continue with Gmail", style: TextStyle(fontSize: 17)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: ElevatedButton(
                              onPressed: () async {
                                String email = _emailController.text.trim();
                                String password = _passwordController.text.trim();

                                if (email.isEmpty || password.isEmpty) {
                                  Fluttertoast.showToast(
                                    msg: "Email and password are required",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.SNACKBAR,
                                    backgroundColor: Colors.black,
                                    textColor: Colors.white,
                                  );
                                  return;
                                }

                                try {
                                  await AuthService().signin(email: email, password: password);
                                  if (FirebaseAuth.instance.currentUser != null) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => Homescreen()),
                                    );
                                  }
                                } catch (e) {
                                  Fluttertoast.showToast(
                                    msg: "Login failed: ${e.toString()}",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.SNACKBAR,
                                    backgroundColor: Colors.black54,
                                    textColor: Colors.white,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                              ),
                              child: Text("Sign In"),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, left: 55),
                            child: Row(
                              children: [
                                Text("Don't have an Account?"),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                                    );
                                  },
                                  child: Text("Signup", style: TextStyle(color: Colors.black)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
