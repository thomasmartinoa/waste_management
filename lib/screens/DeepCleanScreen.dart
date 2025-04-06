// ... Keep your imports the same
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class DeepCleanScreen extends StatefulWidget {
  const DeepCleanScreen({super.key});

  @override
  State<DeepCleanScreen> createState() => _DeepCleanScreenState();
}

class _DeepCleanScreenState extends State<DeepCleanScreen> {
  final _indoorController = TextEditingController();
  final _outdoorController = TextEditingController();
  final _roomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _specialInstructionsController = TextEditingController();

  String? selectedLocation;
  List<String> savedLocations = [];
  bool isLoadingLocations = true;
  File? _selectedImage;

  // Extra services toggle
  bool isCarpetCleaningSelected = false;
  bool isWindowCleaningSelected = false;
  bool isPestControlSelected = false;

  // New toggle for outdoor cleaning
  bool isOutdoorCleaningEnabled = false;

  @override
  void initState() {
    super.initState();
    _fetchSavedLocations();
  }

  Future<void> _fetchSavedLocations() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('locations')
          .orderBy('timestamp', descending: true)
          .get();

      final locations = snapshot.docs
          .map((doc) => doc.data()['full_address']?.toString() ?? '')
          .where((address) => address.isNotEmpty)
          .toList();

      setState(() {
        savedLocations = locations;
        isLoadingLocations = false;
        if (savedLocations.isNotEmpty) {
          selectedLocation = savedLocations.first;
        }
      });
    } catch (e) {
      print('Error fetching locations: $e');
      setState(() => isLoadingLocations = false);
    }
  }

  Future<void> _pickImage() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) setState(() => _selectedImage = File(pickedFile.path));
    } else {
      _showPermissionError();
    }
  }

  Future<void> _takePhoto() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) setState(() => _selectedImage = File(pickedFile.path));
    } else {
      _showPermissionError();
    }
  }

  void _showPermissionError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Permission denied. Please enable it in settings.")),
    );
  }

  Future<void> _submitDeepCleanRequest() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null ||
        _indoorController.text.trim().isEmpty ||
        _roomsController.text.trim().isEmpty ||
        _bathroomsController.text.trim().isEmpty ||
        selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields.")),
      );
      return;
    }

    String? imageUrl;
    if (_selectedImage != null) {
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('deepclean_images')
            .child(uid)
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

    final deepCleanData = {
      'indoor': _indoorController.text.trim(),
      'outdoor': isOutdoorCleaningEnabled ? _outdoorController.text.trim() : '',
      'rooms': _roomsController.text.trim(),
      'bathrooms': _bathroomsController.text.trim(),
      'specialInstructions': _specialInstructionsController.text.trim(),
      'location': selectedLocation,
      'imageUrl': imageUrl ?? '',
      'timestamp': FieldValue.serverTimestamp(),
      'userId': uid,
      'deepCarpetCleaning': isCarpetCleaningSelected,
      'windowCleaning': isWindowCleaningSelected,
      'pestControl': isPestControlSelected,
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('deep_clean')
          .add(deepCleanData);

      await FirebaseFirestore.instance
          .collection('DeepClean Orders')
          .add(deepCleanData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("DeepClean Order Submitted")),
      );

      Navigator.pop(context);
    } catch (e) {
      print("Error submitting: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Submission failed: $e")),
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        actions: [
          TextButton(onPressed: () {
            Navigator.pop(context);
            _takePhoto();
          }, child: const Text('Camera')),
          TextButton(onPressed: () {
            Navigator.pop(context);
            _pickImage();
          }, child: const Text('Gallery')),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, {String? hint}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint ?? '',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildLocationDropdown() {
    if (isLoadingLocations) {
      return const Center(child: CircularProgressIndicator());
    }
    if (savedLocations.isEmpty) {
      return const Text("No saved locations found.");
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedLocation,
          isExpanded: true,
          hint: const Text("Select your location"),
          items: savedLocations.map((location) {
            return DropdownMenuItem(
              value: location,
              child: Text(
                location,
                style: const TextStyle(fontSize: 14, fontFamily: 'Poppins'),
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
    );
  }

  Widget _buildCheckbox(String label, bool value, void Function(bool?) onChanged) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: Text(label, style: const TextStyle(fontFamily: 'Poppins')),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'DeepClean',
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
                    _buildLabel("Indoor areas to clean"),
                    _buildTextField(_indoorController, hint: "Living room, kitchen..."),
                    const SizedBox(height: 16),

                    SwitchListTile(
                      title: const Text("Include Outdoor Cleaning", style: TextStyle(fontFamily: 'Poppins')),
                      value: isOutdoorCleaningEnabled,
                      onChanged: (value) {
                        setState(() {
                          isOutdoorCleaningEnabled = value;
                        });
                      },
                    ),
                    if (isOutdoorCleaningEnabled) ...[
                      _buildLabel("Outdoor areas to clean"),
                      _buildTextField(_outdoorController, hint: "Garden, balcony..."),
                      const SizedBox(height: 16),
                    ],

                    _buildLabel("Number of rooms"),
                    _buildTextField(_roomsController, hint: "e.g. 3"),
                    const SizedBox(height: 16),
                    _buildLabel("Number of bathrooms"),
                    _buildTextField(_bathroomsController, hint: "e.g. 2"),
                    const SizedBox(height: 16),
                    _buildLabel("Special instructions"),
                    _buildTextField(_specialInstructionsController),
                    const SizedBox(height: 24),
                    _buildLabel("Select saved location"),
                    const SizedBox(height: 8),
                    _buildLocationDropdown(),
                    const SizedBox(height: 24),

                    _buildLabel("Extra Services"),
                    _buildCheckbox("Deep Carpet Cleaning", isCarpetCleaningSelected, (val) {
                      setState(() => isCarpetCleaningSelected = val ?? false);
                    }),
                    _buildCheckbox("Window Cleaning", isWindowCleaningSelected, (val) {
                      setState(() => isWindowCleaningSelected = val ?? false);
                    }),
                    _buildCheckbox("Pest Control", isPestControlSelected, (val) {
                      setState(() => isPestControlSelected = val ?? false);
                    }),

                    const SizedBox(height: 16),
                    _buildLabel("Upload Image (Optional)"),
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _selectedImage != null
                            ? Image.file(_selectedImage!, fit: BoxFit.cover)
                            : const Center(child: Icon(Icons.image, size: 40)),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed: _submitDeepCleanRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
