import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Accountscreen extends StatefulWidget {
  const Accountscreen({super.key});

  @override
  State<Accountscreen> createState() => _AccountscreenState();
}

class _AccountscreenState extends State<Accountscreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _profileImage;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileFromFirestore();
  }

  Future<void> _loadProfileFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _profileImageUrl = data['profile_image'];
        });
      } else {
        // Optionally fill email/phone from FirebaseAuth if not in Firestore
        _emailController.text = user.email ?? '';
        _phoneController.text = user.phoneNumber ?? '';
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  Future<void> _saveProfileToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'profile_image': _profileImageUrl ?? '',
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile saved')));
    } catch (e) {
      print('Error saving profile: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${user.uid}.jpg');

        await ref.putFile(_profileImage!);
        final imageUrl = await ref.getDownloadURL();

        setState(() {
          _profileImageUrl = imageUrl;
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'profile_image': imageUrl});
      } catch (e) {
        print('Error uploading image: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to upload image')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Account',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 36,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBEBEB),
                      shape: BoxShape.circle,
                      image:
                          _profileImage != null
                              ? DecorationImage(
                                image: FileImage(_profileImage!),
                                fit: BoxFit.cover,
                              )
                              : _profileImageUrl != null
                              ? DecorationImage(
                                image: NetworkImage(_profileImageUrl!),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        (_profileImage == null && _profileImageUrl == null)
                            ? const Icon(
                              Icons.camera_alt,
                              size: 30,
                              color: Colors.black54,
                            )
                            : null,
                  ),
                ),
                const SizedBox(height: 40),
                _buildTextField("Name", _nameController),
                const SizedBox(height: 20),
                _buildTextField("Email", _emailController),
                const SizedBox(height: 20),
                _buildTextField("Phone number", _phoneController),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveProfileToFirestore,
        backgroundColor: Colors.white,
        child: const Icon(Icons.save, color: Colors.black),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
            ),
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 15),
          ),
        ),
      ],
    );
  }
}
