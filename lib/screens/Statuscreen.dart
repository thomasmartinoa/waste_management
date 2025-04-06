import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Statuscreen extends StatelessWidget {
  const Statuscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            "Please log in to view orders",
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bold "Orders" heading
            const Padding(
              padding: EdgeInsets.only(top: 30, bottom: 10,left: 150),
              child: Text(
                "Orders",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            const SectionHeader(title: "Pickup Orders",),
            _buildOrders(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('pickups')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (data, docId) => _buildOrderCard(
                context,
                content: [
                  "Categories: ${data['categories'].join(', ')}",
                  "Waste Type: ${data['waste_type']}",
                  "Date: ${data['date']}",
                  "Time: ${data['time']}",
                  "Location: ${data['location']}",
                ],
                onCancel: () => _cancelPickup(context, user.uid, docId),
              ),
            ),

            const SizedBox(height: 20),
            const SectionHeader(title: "BinGo Orders"),
            _buildOrders(
              stream: FirebaseFirestore.instance
                  .collection('Bingo Orders')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (data, docId) => _buildOrderCard(
                context,
                content: [
                  "Description: ${data['description']}",
                  "Quantity: ${data['quantity']}",
                  "Location: ${data['location']}",
                ],
                onCancel: () => _cancelBingoOrder(context, docId),
              ),
            ),

            const SizedBox(height: 20),
            const SectionHeader(title: "Deep Clean Orders"),
            _buildOrders(
              stream: FirebaseFirestore.instance
                  .collection('DeepClean Orders')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (data, docId) => _buildOrderCard(
                context,
                content: [
                  "Rooms: ${data['rooms']}",
                  "Indoor: ${_toYesNo(data['indoor'])}",
                  "Outdoor: ${_toYesNo(data['outdoor'])}",
                  "Location: ${data['location']}",
                ],
                onCancel: () => _cancelDeepCleanOrder(context, docId),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrders({
    required Stream<QuerySnapshot> stream,
    required Widget Function(Map<String, dynamic> data, String docId) builder,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text("No orders placed yet.", style: TextStyle(color: Colors.black)),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return builder(data, doc.id);
          }).toList(),
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, {
    required List<String> content,
    required VoidCallback onCancel,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color.fromARGB(255, 0, 0, 0), width: 1),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2.5, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...content.map((text) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(text, style: const TextStyle(color: Colors.black)),
          )),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Status: Pending", style: TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: onCancel,
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
    );
  }

  Future<void> _cancelPickup(BuildContext context, String userId, String docId) async {
    if (!await _showConfirmationDialog(context)) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('pickups')
          .doc(docId)
          .delete();
      _showSnack(context, "Pickup order cancelled");
    } catch (_) {
      _showSnack(context, "Failed to cancel pickup");
    }
  }

  Future<void> _cancelBingoOrder(BuildContext context, String docId) async {
    if (!await _showConfirmationDialog(context)) return;
    try {
      await FirebaseFirestore.instance
          .collection('Bingo Orders')
          .doc(docId)
          .delete();
      _showSnack(context, "BinGo order cancelled");
    } catch (_) {
      _showSnack(context, "Failed to cancel BinGo order");
    }
  }

  Future<void> _cancelDeepCleanOrder(BuildContext context, String docId) async {
    if (!await _showConfirmationDialog(context)) return;
    try {
      await FirebaseFirestore.instance
          .collection('DeepClean Orders')
          .doc(docId)
          .delete();
      _showSnack(context, "Deep Clean order cancelled");
    } catch (_) {
      _showSnack(context, "Failed to cancel Deep Clean order");
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return (await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Cancel Order"),
            content: const Text("Are you sure you want to cancel this order?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("No")),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Yes")),
            ],
          ),
        )) ??
        false;
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _toYesNo(dynamic value) {
    if (value is bool) return value ? 'Yes' : 'No';
    if (value is String) return value.toLowerCase() == 'true' ? 'Yes' : 'No';
    return 'No';
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }
}
