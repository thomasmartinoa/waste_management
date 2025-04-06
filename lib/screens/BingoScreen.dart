import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wastemanagement/screens/BingoDetailscreen.dart';

class Bingoscreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'BinGo',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 36,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Orders List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Bingo Orders')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No orders found"));
                  }

                  final orders = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index].data() as Map<String, dynamic>;
                      final userId = order['userId'] ?? '';

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return SizedBox.shrink();
                          }

                          final userData = userSnapshot.data?.data() as Map<String, dynamic>?;

                          final userName = userData?['name'] ?? 'Unknown';
                          final userPhone = userData?['phone'] ?? 'N/A';

                          return buildOrderCard(
                            title: order['description'] ?? '',
                            weight: order['quantity'] ?? '',
                            address: order['location'] ?? '',
                            name: userName,
                            phone: userPhone,
                            imageUrl: order['imageUrl'] ?? '',
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

            // Bottom Button
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Bingodetailscreen()),
                  );
                },
                child: Text(
                  'BinGo',
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

  Widget buildOrderCard({
    required String title,
    required String weight,
    required String address,
    required String name,
    required String phone,
    required String imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 1),
        borderRadius: BorderRadius.circular(23),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Text('Name: $name', style: _textStyle()),
          SizedBox(height: 6),
          Text('Phone: $phone', style: _textStyle()),
          SizedBox(height: 6),
          Text('Waste: $title', style: _textStyle()),
          SizedBox(height: 6),
          Text('Quantity: $weight', style: _textStyle()),
          SizedBox(height: 6),
          Text('Location: $address', style: _textStyle()),
        ],
      ),
    );
  }

  TextStyle _textStyle() {
    return TextStyle(
      color: Colors.black.withAlpha(222),
      fontSize: 14,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w400,
    );
  }
}
