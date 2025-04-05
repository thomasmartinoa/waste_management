import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wastemanagement/screens/HomeScreen.dart';
import 'package:wastemanagement/screens/Signup_screen.dart';
import 'package:wastemanagement/services/auth_service.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 70, left: 45),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Register",
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
                        "Create an account so you can explore all features",
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
                    padding: const EdgeInsets.only(
                      top: 330,
                      left: 40,
                      right: 40,
                    ),
                    child: Container(
                      height: 490,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.black, width: 1.25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              0.08,
                            ),
                            blurRadius: 10, 
                            spreadRadius: 1, 
                            offset: Offset(
                             0,
                              5,
                            ), 
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 35),
                            child: Text(
                              "Enter Details",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 40,
                              left: 20,
                              right: 20,
                            ),
                            child: TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: "Enter your Email..",
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.5),
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 35,
                              left: 20,
                              right: 20,
                            ),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: "Enter your password..",
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.5),
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 35,
                              left: 20,
                              right: 20,
                            ),
                            child: TextField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: "Confirm your password..",
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.5),
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 35),
                            child: ElevatedButton(
                              onPressed: () async {
                                String email = _emailController.text.trim();
                                String password =
                                    _passwordController.text.trim();
                                String confirmPassword =
                                    _confirmPasswordController.text.trim();

                              
                                bool emailValid = RegExp(
                                  r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                                ).hasMatch(email);

                                if (email.isEmpty ||
                                    password.isEmpty ||
                                    confirmPassword.isEmpty) {
                                  Fluttertoast.showToast(
                                    msg: "Please fill in all fields",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.black,
                                    textColor: Colors.white,
                                  );
                                  return;
                                }

                                if (!emailValid) {
                                  Fluttertoast.showToast(
                                    msg: "Please enter a valid email address",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.black,
                                    textColor: Colors.white,
                                  );
                                  return;
                                }

                                if (password.length < 6) {
                                  Fluttertoast.showToast(
                                    msg:
                                        "Password must be at least 6 characters",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.black,
                                    textColor: Colors.white,
                                  );
                                  return;
                                }

                                if (password != confirmPassword) {
                                  Fluttertoast.showToast(
                                    msg: "Passwords do not match",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.black,
                                    textColor: Colors.white,
                                  );
                                  return;
                                }

                                try {
                                  var userCredential = await AuthService()
                                      .signup(email: email, password: password);

                                  if (userCredential != null) {
                                    Fluttertoast.showToast(
                                      msg: "Signup successful!",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                                      textColor: Colors.white,
                                    );

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Homescreen(),
                                      ),
                                    );
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: "Signup failed. Please try again.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        0,
                                        0,
                                        0,
                                      ),
                                      textColor: Colors.white,
                                    );
                                  }
                                } catch (e) {
                                  Fluttertoast.showToast(
                                    msg: "Error: ${e.toString()}",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      0,
                                      0,
                                      0,
                                    ),
                                    textColor: Colors.white,
                                  );
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignupScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                              ),
                              child: Text("Sign Up"),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20, left: 55),
                            child: Row(
                              children: [
                                Text("Already have an Account?"),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SignupScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Sign in",
                                    style: TextStyle(color: Colors.black),
                                  ),
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
