import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart'; // NEW

class Bingodetailscreen extends StatefulWidget {
  @override
  State<Bingodetailscreen> createState() => _BingodetailscreenState();
}

class _BingodetailscreenState extends State<Bingodetailscreen> {
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();

  String? selectedLocation;
  List<String> savedLocations = [];
  bool isLoadingLocations = true;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _fetchSavedLocations();
  }

  Future<void> _fetchSavedLocations() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      print('User not logged in');
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('locations')
          .orderBy('timestamp', descending: true)
          .get();

      final locations = snapshot.docs
          .map((doc) {
            final data = doc.data();
            return data['full_address']?.toString() ?? '';
          })
          .where((address) => address.isNotEmpty)
          .toList();

      setState(() {
        savedLocations = locations;
        isLoadingLocations = false;
        if (savedLocations.isNotEmpty && selectedLocation == null) {
          selectedLocation = savedLocations.first;
        }
      });
    } catch (e) {
      print('Error fetching locations: $e');
      setState(() {
        isLoadingLocations = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } else {
      _showPermissionError();
    }
  }

  Future<void> _takePhoto() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } else {
      _showPermissionError();
    }
  }

  void _showPermissionError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Permission denied. Please enable it in settings.")),
    );
  }

  Future<void> _submitOrder() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final description = _descriptionController.text.trim();
    final quantity = _quantityController.text.trim();

    if ([uid, description, quantity, selectedLocation].contains(null) ||
        description.isEmpty ||
        quantity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields and select a location")),
      );
      return;
    }

    String? imageUrl;
    if (_selectedImage != null) {
      try {
        print("Selected image path: ${_selectedImage!.path}");

        final ref = FirebaseStorage.instance
            .ref()
            .child('bingo_order_images')
            .child(uid!)
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        await ref.putFile(_selectedImage!);
        imageUrl = await ref.getDownloadURL();
      } catch (e) {
        print("Image upload error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image upload failed: $e")),
        );
        return;
      }
    }

    final orderData = {
      'description': description,
      'quantity': quantity,
      'location': selectedLocation,
      'imageUrl': imageUrl ?? '',
      'timestamp': FieldValue.serverTimestamp(),
      'userId': uid,
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('bingo_orders')
          .add(orderData);

      await FirebaseFirestore.instance
          .collection('Bingo Orders')
          .add(orderData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("BinGo Order Placed Successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to place order: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'BinGo',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Description of waste'),
                    _buildTextField(_descriptionController),
                    SizedBox(height: 20),
                    _buildLabel('Quantity of waste'),
                    _buildTextField(_quantityController),
                    SizedBox(height: 30),
                    isLoadingLocations
                        ? Center(child: CircularProgressIndicator())
                        : savedLocations.isNotEmpty
                            ? Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade400),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: selectedLocation,
                                    hint: Text("Choose saved location"),
                                    items: savedLocations.map((location) {
                                      return DropdownMenuItem<String>(
                                        value: location,
                                        child: Text(
                                          location,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Poppins',
                                            color: Colors.black87,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedLocation = value;
                                      });
                                    },
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  "No saved locations found. Please add a location first.",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                    SizedBox(height: 30),
                    _buildLabel('Upload Image (Optional)'),
                    GestureDetector(
                      onTap: () => _showImageSourceDialog(),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _selectedImage != null
                            ? Image.file(_selectedImage!, fit: BoxFit.cover)
                            : Center(child: Icon(Icons.image, size: 40)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _submitOrder,
                child: Text(
                  'Confirm',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Image Source'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _takePhoto();
            },
            child: Text('Camera'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage();
            },
            child: Text('Gallery'),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
          color: Colors.black.withAlpha(222),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
