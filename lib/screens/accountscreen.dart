import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastemanagement/screens/Signup_Screen.dart';
import 'edit_profile_screen.dart';


class Accountscreen extends StatelessWidget {
  const Accountscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("Not logged in"));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Redirect to EditProfileScreen if user data not found
            if (!snapshot.hasData || !snapshot.data!.exists) {
              Future.microtask(() {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              });
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final name = data['name'] ?? 'Your Name';
            final email = data['email'] ?? 'your@email.com';
            final phone = data['phone'] ?? 'N/A';
            final profileImage = data['profile_image'];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    'Account',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 36,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 30),
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: const Color(0xFFEBEBEB),
                    backgroundImage: profileImage != null ? NetworkImage(profileImage) : null,
                    child: profileImage == null
                        ? const Icon(Icons.person, size: 40, color: Colors.black54)
                        : null,
                  ),
                  const SizedBox(height: 20),
                  Text(name, style: _textStyle(18, FontWeight.w500)),
                  Text(email, style: _textStyle(14, FontWeight.w300)),
                  const SizedBox(height: 20),
                  Text('Phone: $phone', style: _textStyle(14, FontWeight.w400)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Edit Profile"),
                  ),
                  const SizedBox(height: 40),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Settings", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const Divider(thickness: 1.2),
                  SwitchListTile(
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: (value) {
                      // TODO: Add theme toggle logic here
                    },
                    title: const Text("Dark Theme", style: TextStyle(fontFamily: 'Poppins')),
                    activeColor: Colors.black,
                  ),
                  ListTile(
                    title: const Text("Sign Out", style: TextStyle(fontFamily: 'Poppins')),
                    trailing: const Icon(Icons.logout),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => SignupScreen()), 
                        (route) => false,
                      );
                    },
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  TextStyle _textStyle(double size, FontWeight weight) {
    return TextStyle(fontFamily: 'Poppins', fontSize: size, fontWeight: weight, color: Colors.black);
  }
}
