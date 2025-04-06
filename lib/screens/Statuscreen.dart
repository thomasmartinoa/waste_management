import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Statuscreen extends StatelessWidget {
  const Statuscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Status"),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: Text(
            "Please log in to view orders",
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pickup Orders", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            // Pickup Orders
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('pickups')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("No pickups placed yet.");
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final docId = doc.id;

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(color: Colors.black12),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Categories: ${data['categories'].join(', ')}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                            Text("Waste Type: ${data['waste_type']}", style: const TextStyle(color: Colors.black)),
                            Text("Date: ${data['date']}", style: const TextStyle(color: Colors.black)),
                            Text("Time: ${data['time']}", style: const TextStyle(color: Colors.black)),
                            Text("Location: ${data['location']}", style: const TextStyle(color: Colors.black)),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Status: Pending", style: TextStyle(color: Colors.black)),
                                ElevatedButton(
                                  onPressed: () => _cancelPickup(context, user.uid, docId),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text("Cancel"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 30),
            const Text("BinGo Orders", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            // BinGo Orders
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Bingo Orders')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("No BinGo orders placed yet.");
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final docId = doc.id;

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(color: Colors.black12),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Description: ${data['description']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                            Text("Quantity: ${data['quantity']}", style: const TextStyle(color: Colors.black)),
                            Text("Location: ${data['location']}", style: const TextStyle(color: Colors.black)),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Status: Pending", style: TextStyle(color: Colors.black)),
                                ElevatedButton(
                                  onPressed: () => _cancelBingoOrder(context, docId),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text("Cancel"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 30),
            const Text("Deep Clean Orders", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            // Deep Clean Orders
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('DeepClean Orders')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("No Deep Clean orders placed yet.");
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final docId = doc.id;

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(color: Colors.black12),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Rooms: ${data['rooms']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                            Text("Indoor: ${_toYesNo(data['indoor'])}", style: const TextStyle(color: Colors.black)),
                            Text("Outdoor: ${_toYesNo(data['outdoor'])}", style: const TextStyle(color: Colors.black)),
                            Text("Location: ${data['location']}", style: const TextStyle(color: Colors.black)),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Status: Pending", style: TextStyle(color: Colors.black)),
                                ElevatedButton(
                                  onPressed: () => _cancelDeepCleanOrder(context, docId),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text("Cancel"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _cancelPickup(BuildContext context, String userId, String docId) async {
    bool confirm = await _showConfirmationDialog(context);
    if (!confirm) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('pickups')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pickup order cancelled")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to cancel pickup")),
      );
    }
  }

  void _cancelBingoOrder(BuildContext context, String docId) async {
    bool confirm = await _showConfirmationDialog(context);
    if (!confirm) return;

    try {
      await FirebaseFirestore.instance
          .collection('Bingo Orders')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("BinGo order cancelled")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to cancel BinGo order")),
      );
    }
  }

  void _cancelDeepCleanOrder(BuildContext context, String docId) async {
    bool confirm = await _showConfirmationDialog(context);
    if (!confirm) return;

    try {
      await FirebaseFirestore.instance
          .collection('DeepClean Orders')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Deep Clean order cancelled")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to cancel Deep Clean order")),
      );
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Cancel Order"),
            content: const Text("Are you sure you want to cancel this order?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
            ],
          ),
        ) ??
        false;
  }

  String _toYesNo(dynamic value) {
    if (value is bool) return value ? 'Yes' : 'No';
    if (value is String) return value.toLowerCase() == 'true' ? 'Yes' : 'No';
    return 'No';
  }
}
