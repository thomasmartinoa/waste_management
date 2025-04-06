import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wastemanagement/screens/homescreen.dart';

class EditProfileScreen extends StatefulWidget {
  final bool fromAccount;

  const EditProfileScreen({super.key, this.fromAccount = false});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _profileImage;
  String? _profileImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? user.email ?? '';
        _phoneController.text = data['phone'] ?? '';
        _profileImageUrl = data['profile_image'];
      });
    } else {
      setState(() {
        _emailController.text = user.email ?? '';
      });
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
        _profileImageUrl = null; // Clear existing URL if new image is selected
      });
    }
  }

  Future<void> _removeImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _profileImage = null;
      _profileImageUrl = null;
    });

    try {
      // Delete from Firebase Storage
      await FirebaseStorage.instance.ref('profile_images/${user.uid}.jpg').delete();
    } catch (e) {
      // It's okay if the file doesn't exist
    }

    // Remove from Firestore
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'profile_image': '',
    });
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.black),
      ),
    );

    try {
      if (_profileImage != null) {
        final ref = FirebaseStorage.instance.ref().child('profile_images/${user.uid}.jpg');
        await ref.putFile(_profileImage!);
        _profileImageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'profile_image': _profileImageUrl ?? '',
      });

      Navigator.pop(context); // Close loading dialog

      if (widget.fromAccount) {
        Navigator.pop(context); // Go back to account screen
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Homescreen()),
          (route) => false,
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final showRemoveButton = _profileImage != null || _profileImageUrl != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Profile set up", style: TextStyle(fontFamily: 'Poppins')),
        elevation: 0,
        automaticallyImplyLeading: widget.fromAccount,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFFEBEBEB),
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!) as ImageProvider
                        : null,
                child: _profileImage == null && _profileImageUrl == null
                    ? const Icon(Icons.upload, color: Colors.black54, size: 30)
                    : null,
              ),
            ),
            if (showRemoveButton)
              TextButton.icon(
                onPressed: _removeImage,
                icon: const Icon(Icons.delete_outline, color: Color.fromARGB(255, 0, 0, 0)),
                label: const Text("Remove Photo", style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
              ),
            const SizedBox(height: 30),
            _buildTextField("Name", _nameController),
            const SizedBox(height: 20),
            _buildTextField("Email", _emailController, readOnly: true),
            const SizedBox(height: 20),
            _buildTextField("Phone Number", _phoneController),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text("Save Changes", style: TextStyle(fontFamily: 'Poppins')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Poppins')),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }
}
