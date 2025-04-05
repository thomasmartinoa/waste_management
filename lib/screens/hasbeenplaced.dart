import 'package:flutter/material.dart';
import 'package:wastemanagement/screens/HomeScreen.dart';

class Hasbeenplaced extends StatelessWidget {
  final List<String> categories;
  final String wasteType;
  final String date;
  final String time;
  final String location;

  const Hasbeenplaced({
    super.key,
    required this.categories,
    required this.wasteType,
    required this.date,
    required this.time,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Your pickup has\nbeen placed',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 36,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Pickup Details:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text("🗂️ Category: ${categories.join(", ")}",
                  style: _detailStyle()),
              const SizedBox(height: 10),
              Text("♻️ Waste Type: $wasteType", style: _detailStyle()),
              const SizedBox(height: 10),
              Text("📅 Date: $date", style: _detailStyle()),
              const SizedBox(height: 10),
              Text("⏰ Time: $time", style: _detailStyle()),
              const SizedBox(height: 10),
              Text("📍 Location:\n$location", style: _detailStyle()),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () {
                     Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>  Homescreen(),
                        ),
                      );
                  },
                  child: const Text(
                    'back to Home',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromARGB(200, 0, 0, 0),
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _detailStyle() => const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        fontFamily: 'Poppins',
      );
}
