import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wastemanagement/screens/hasbeenplaced.dart';

class Pickupscreen extends StatefulWidget {
  final String location;

  const Pickupscreen({super.key, required this.location});

  @override
  State<Pickupscreen> createState() => _PickupscreenState();
}

class _PickupscreenState extends State<Pickupscreen> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _wasteTypeController = TextEditingController();

  List<bool> buttonStates = [false, false, false];
  
  String? selectedLocation;
  List<String> savedLocations = [];
  bool isLoadingLocations = true;

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

  void _changeBtnColor(int index) {
    setState(() {
      buttonStates[index] = !buttonStates[index];
    });
  }

  List<String> _getSelectedCategories() {
    List<String> selected = [];
    if (buttonStates[0]) selected.add("Organic");
    if (buttonStates[1]) selected.add("InOrganic");
    if (buttonStates[2]) selected.add("Hazardous");
    return selected;
  }

  Future<void> _savePickupData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      List<String> selectedCategories = _getSelectedCategories();
      String wasteType = _wasteTypeController.text.trim().isEmpty
          ? "nil"
          : _wasteTypeController.text.trim();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pickups')
          .add({
        'categories': selectedCategories,
        'waste_type': wasteType,
        'date': _dateController.text.trim(),
        'time': _timeController.text.trim(),
        'location': selectedLocation ?? "Not selected",
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pickup scheduled')),
      );
    } catch (e) {
      print("Error saving pickup data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save pickup')),
      );
    }
  }

  void _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text =
            "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
      });
    }
  }

  void _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _timeController.text = pickedTime.format(context);
      });
    }
  }

  void _handleNext() async {
    List<String> selectedCategories = _getSelectedCategories();

    if (selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a location")),
      );
      return;
    }

    if (selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one category")),
      );
      return;
    }

    if (_dateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a date")),
      );
      return;
    }

    if (_timeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a time")),
      );
      return;
    }

    await _savePickupData();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Hasbeenplaced(
          categories: selectedCategories,
          wasteType: _wasteTypeController.text.trim().isEmpty
              ? "nil"
              : _wasteTypeController.text.trim(),
          date: _dateController.text.trim(),
          time: _timeController.text.trim(),
          location: selectedLocation ?? "",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 27, bottom: 10, top: 50),
                  child: Text(
                    "Waste Pick Up",
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 30, top: 25),
                  child: Text(
                    "Select Category",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCategoryButton("Organic", 0),
                    _buildCategoryButton("InOrganic", 1),
                    _buildCategoryButton("Hazardous", 2),
                  ],
                ),
                const SizedBox(height: 25),
                const Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: Text(
                    'Type of waste for selected \ncategory',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: TextField(
                    controller: _wasteTypeController,
                    minLines: 10,
                    maxLines: 100,
                    decoration: InputDecoration(
                      hintText: "Enter the type of waste (optional)...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.black, width: 1.5),
                      ),
                    ),
                  ),
                ),

                isLoadingLocations
                    ? const Center(child: CircularProgressIndicator())
                    : savedLocations.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                            child: DropdownButtonFormField<String>(
                              value: selectedLocation,
                              isExpanded: true,
                              decoration: InputDecoration(
                                hintText: "Select Location",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                                ),
                                prefixIcon: const Icon(Icons.location_on),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              ),
                              items: savedLocations.map((location) {
                                return DropdownMenuItem<String>(
                                  value: location,
                                  child: Text(
                                    location,
                                    style: const TextStyle(
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
                          )
                        : const Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              "No saved locations found. Please add a location first.",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),

                /// DATE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  child: TextField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: InputDecoration(
                      hintText: "Select Date",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                ),

                /// TIME
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: TextField(
                    controller: _timeController,
                    readOnly: true,
                    onTap: () => _selectTime(context),
                    decoration: InputDecoration(
                      hintText: "Select Time",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      prefixIcon: const Icon(Icons.access_time),
                    ),
                  ),
                ),

                const SizedBox(height: 25),
                Center(
                  child: ElevatedButton(
                    onPressed: _handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("Next"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String title, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          _changeBtnColor(index);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonStates[index] ? Colors.black : Colors.white,
          side: const BorderSide(color: Colors.black, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: buttonStates[index] ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
