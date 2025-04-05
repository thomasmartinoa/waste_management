import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:wastemanagement/screens/pickupscreen.dart';

class Locationscreen extends StatefulWidget {
  const Locationscreen({super.key});

  @override
  State<Locationscreen> createState() => _LocationscreenState();
}

class _LocationscreenState extends State<Locationscreen> {
  final TextEditingController houseController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();

  String _selectedLocation = "No location selected";

  Future<void> _detectLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are disabled.");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permissions are denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        "Location permissions are permanently denied, we cannot request permissions.",
      );
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        setState(() {
          houseController.text = place.subThoroughfare ?? "";
          areaController.text = place.thoroughfare ?? "";
          landmarkController.text = place.locality ?? "";
          pincodeController.text = place.postalCode ?? "";
          cityController.text = place.subAdministrativeArea ?? "";
          stateController.text = place.administrativeArea ?? "";

          _updateLocationDisplay();
        });
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void _updateLocationDisplay() {
    setState(() {
      _selectedLocation =
          "${houseController.text}, ${areaController.text}, ${landmarkController.text}, ${cityController.text}, ${stateController.text} - ${pincodeController.text}"
              .trim()
              .replaceAll(RegExp(r", , |, -"), "");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20, left: 40),
                child: Text(
                  "Add New \nAddress",
                  style: TextStyle(fontSize: 37, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 35),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  height: 450,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black, width: 1.25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10,
                            left: 150,
                            bottom: 25,
                          ),
                          child: InkWell(
                            onTap: _detectLocation,
                            child: const Text(
                              "Detect Exact Location",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ),
                        ),
                        _buildTextField("House no., Building, Apartment", houseController),
                        const SizedBox(height: 20),
                        _buildTextField("Area, Street, Sector", areaController),
                        const SizedBox(height: 20),
                        _buildTextField("Landmark (Optional)", landmarkController),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: _buildTextField("Pincode", pincodeController)),
                            const SizedBox(width: 20),
                            Expanded(child: _buildTextField("City/Town", cityController)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildTextField("State", stateController),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 32.5, right: 32.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _showSavedLocationsBottomSheet,
                      child: const Text(
                        "Select other location",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _saveLocationToFirestore,
                      child: const Text(
                        "Save location",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 32.5),
                child: Text(
                  _selectedLocation,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 5, left: 32.5),
                child: Text(
                  "Confirm to place pickup",
                  style: TextStyle(
                    color: Color.fromARGB(255, 97, 97, 97),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (houseController.text.isEmpty ||
                          areaController.text.isEmpty ||
                          pincodeController.text.isEmpty ||
                          cityController.text.isEmpty ||
                          stateController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please fill all required address fields")),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Pickupscreen(location: _selectedLocation),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text("Confirm"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveLocationToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not logged in')));
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('locations')
          .add({
        'house': houseController.text,
        'area': areaController.text,
        'landmark': landmarkController.text,
        'pincode': pincodeController.text,
        'city': cityController.text,
        'state': stateController.text,
        'full_address': _selectedLocation,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location saved')));
    } catch (e) {
      print('Error saving location: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save location')));
    }
  }

  void _showSavedLocationsBottomSheet() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('locations')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text("No saved addresses found.")),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final address = data['full_address'] ?? 'Unnamed address';
                final docId = doc.id;

                return ListTile(
                  title: Text(address),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.black),
                    onPressed: () => _deleteLocation(user.uid, docId),
                  ),
                  onTap: () {
                    houseController.text = data['house'] ?? '';
                    areaController.text = data['area'] ?? '';
                    landmarkController.text = data['landmark'] ?? '';
                    pincodeController.text = data['pincode'] ?? '';
                    cityController.text = data['city'] ?? '';
                    stateController.text = data['state'] ?? '';
                    _updateLocationDisplay();
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteLocation(String userId, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('locations')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location deleted")));
      setState(() {});
    } catch (e) {
      print("Error deleting location: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to delete location")));
    }
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        onChanged: (value) => _updateLocationDisplay(),
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.black, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.black, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.black, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        ),
      ),
    );
  }
}
